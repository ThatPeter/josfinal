
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
  800043:	68 00 22 80 00       	push   $0x802200
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
  80005e:	68 0e 22 80 00       	push   $0x80220e
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
  800082:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000dc:	e8 1a 11 00 00       	call   8011fb <close_all>
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
  8001e6:	e8 75 1d 00 00       	call   801f60 <__udivdi3>
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
  800229:	e8 62 1e 00 00       	call   802090 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 32 22 80 00 	movsbl 0x802232(%eax),%eax
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
  80032d:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
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
  8003f1:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  8003f8:	85 d2                	test   %edx,%edx
  8003fa:	75 18                	jne    800414 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	68 4a 22 80 00       	push   $0x80224a
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
  800415:	68 8d 26 80 00       	push   $0x80268d
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
  800439:	b8 43 22 80 00       	mov    $0x802243,%eax
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
  800ab4:	68 3f 25 80 00       	push   $0x80253f
  800ab9:	6a 23                	push   $0x23
  800abb:	68 5c 25 80 00       	push   $0x80255c
  800ac0:	e8 5e 12 00 00       	call   801d23 <_panic>

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
  800b35:	68 3f 25 80 00       	push   $0x80253f
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 5c 25 80 00       	push   $0x80255c
  800b41:	e8 dd 11 00 00       	call   801d23 <_panic>

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
  800b77:	68 3f 25 80 00       	push   $0x80253f
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 5c 25 80 00       	push   $0x80255c
  800b83:	e8 9b 11 00 00       	call   801d23 <_panic>

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
  800bb9:	68 3f 25 80 00       	push   $0x80253f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 5c 25 80 00       	push   $0x80255c
  800bc5:	e8 59 11 00 00       	call   801d23 <_panic>

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
  800bfb:	68 3f 25 80 00       	push   $0x80253f
  800c00:	6a 23                	push   $0x23
  800c02:	68 5c 25 80 00       	push   $0x80255c
  800c07:	e8 17 11 00 00       	call   801d23 <_panic>

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
  800c3d:	68 3f 25 80 00       	push   $0x80253f
  800c42:	6a 23                	push   $0x23
  800c44:	68 5c 25 80 00       	push   $0x80255c
  800c49:	e8 d5 10 00 00       	call   801d23 <_panic>
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
  800c7f:	68 3f 25 80 00       	push   $0x80253f
  800c84:	6a 23                	push   $0x23
  800c86:	68 5c 25 80 00       	push   $0x80255c
  800c8b:	e8 93 10 00 00       	call   801d23 <_panic>

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
  800ce3:	68 3f 25 80 00       	push   $0x80253f
  800ce8:	6a 23                	push   $0x23
  800cea:	68 5c 25 80 00       	push   $0x80255c
  800cef:	e8 2f 10 00 00       	call   801d23 <_panic>

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

00800d3c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d46:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d48:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d4c:	74 11                	je     800d5f <pgfault+0x23>
  800d4e:	89 d8                	mov    %ebx,%eax
  800d50:	c1 e8 0c             	shr    $0xc,%eax
  800d53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d5a:	f6 c4 08             	test   $0x8,%ah
  800d5d:	75 14                	jne    800d73 <pgfault+0x37>
		panic("faulting access");
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	68 6a 25 80 00       	push   $0x80256a
  800d67:	6a 1e                	push   $0x1e
  800d69:	68 7a 25 80 00       	push   $0x80257a
  800d6e:	e8 b0 0f 00 00       	call   801d23 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	6a 07                	push   $0x7
  800d78:	68 00 f0 7f 00       	push   $0x7ff000
  800d7d:	6a 00                	push   $0x0
  800d7f:	e8 87 fd ff ff       	call   800b0b <sys_page_alloc>
	if (r < 0) {
  800d84:	83 c4 10             	add    $0x10,%esp
  800d87:	85 c0                	test   %eax,%eax
  800d89:	79 12                	jns    800d9d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d8b:	50                   	push   %eax
  800d8c:	68 85 25 80 00       	push   $0x802585
  800d91:	6a 2c                	push   $0x2c
  800d93:	68 7a 25 80 00       	push   $0x80257a
  800d98:	e8 86 0f 00 00       	call   801d23 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d9d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	68 00 10 00 00       	push   $0x1000
  800dab:	53                   	push   %ebx
  800dac:	68 00 f0 7f 00       	push   $0x7ff000
  800db1:	e8 4c fb ff ff       	call   800902 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800db6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dbd:	53                   	push   %ebx
  800dbe:	6a 00                	push   $0x0
  800dc0:	68 00 f0 7f 00       	push   $0x7ff000
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 82 fd ff ff       	call   800b4e <sys_page_map>
	if (r < 0) {
  800dcc:	83 c4 20             	add    $0x20,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	79 12                	jns    800de5 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dd3:	50                   	push   %eax
  800dd4:	68 85 25 80 00       	push   $0x802585
  800dd9:	6a 33                	push   $0x33
  800ddb:	68 7a 25 80 00       	push   $0x80257a
  800de0:	e8 3e 0f 00 00       	call   801d23 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	68 00 f0 7f 00       	push   $0x7ff000
  800ded:	6a 00                	push   $0x0
  800def:	e8 9c fd ff ff       	call   800b90 <sys_page_unmap>
	if (r < 0) {
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	79 12                	jns    800e0d <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800dfb:	50                   	push   %eax
  800dfc:	68 85 25 80 00       	push   $0x802585
  800e01:	6a 37                	push   $0x37
  800e03:	68 7a 25 80 00       	push   $0x80257a
  800e08:	e8 16 0f 00 00       	call   801d23 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    

00800e12 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e1b:	68 3c 0d 80 00       	push   $0x800d3c
  800e20:	e8 44 0f 00 00       	call   801d69 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e25:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2a:	cd 30                	int    $0x30
  800e2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 17                	jns    800e4d <fork+0x3b>
		panic("fork fault %e");
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	68 9e 25 80 00       	push   $0x80259e
  800e3e:	68 84 00 00 00       	push   $0x84
  800e43:	68 7a 25 80 00       	push   $0x80257a
  800e48:	e8 d6 0e 00 00       	call   801d23 <_panic>
  800e4d:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e4f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e53:	75 24                	jne    800e79 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e55:	e8 73 fc ff ff       	call   800acd <sys_getenvid>
  800e5a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e5f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800e65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e6a:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	e9 64 01 00 00       	jmp    800fdd <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e79:	83 ec 04             	sub    $0x4,%esp
  800e7c:	6a 07                	push   $0x7
  800e7e:	68 00 f0 bf ee       	push   $0xeebff000
  800e83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e86:	e8 80 fc ff ff       	call   800b0b <sys_page_alloc>
  800e8b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e93:	89 d8                	mov    %ebx,%eax
  800e95:	c1 e8 16             	shr    $0x16,%eax
  800e98:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e9f:	a8 01                	test   $0x1,%al
  800ea1:	0f 84 fc 00 00 00    	je     800fa3 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	c1 e8 0c             	shr    $0xc,%eax
  800eac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800eb3:	f6 c2 01             	test   $0x1,%dl
  800eb6:	0f 84 e7 00 00 00    	je     800fa3 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ebc:	89 c6                	mov    %eax,%esi
  800ebe:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ec1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec8:	f6 c6 04             	test   $0x4,%dh
  800ecb:	74 39                	je     800f06 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ecd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	25 07 0e 00 00       	and    $0xe07,%eax
  800edc:	50                   	push   %eax
  800edd:	56                   	push   %esi
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	6a 00                	push   $0x0
  800ee2:	e8 67 fc ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800ee7:	83 c4 20             	add    $0x20,%esp
  800eea:	85 c0                	test   %eax,%eax
  800eec:	0f 89 b1 00 00 00    	jns    800fa3 <fork+0x191>
		    	panic("sys page map fault %e");
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	68 ac 25 80 00       	push   $0x8025ac
  800efa:	6a 54                	push   $0x54
  800efc:	68 7a 25 80 00       	push   $0x80257a
  800f01:	e8 1d 0e 00 00       	call   801d23 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f06:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0d:	f6 c2 02             	test   $0x2,%dl
  800f10:	75 0c                	jne    800f1e <fork+0x10c>
  800f12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f19:	f6 c4 08             	test   $0x8,%ah
  800f1c:	74 5b                	je     800f79 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	68 05 08 00 00       	push   $0x805
  800f26:	56                   	push   %esi
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	6a 00                	push   $0x0
  800f2b:	e8 1e fc ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800f30:	83 c4 20             	add    $0x20,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	79 14                	jns    800f4b <fork+0x139>
		    	panic("sys page map fault %e");
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	68 ac 25 80 00       	push   $0x8025ac
  800f3f:	6a 5b                	push   $0x5b
  800f41:	68 7a 25 80 00       	push   $0x80257a
  800f46:	e8 d8 0d 00 00       	call   801d23 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	68 05 08 00 00       	push   $0x805
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 f0 fb ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800f5e:	83 c4 20             	add    $0x20,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 3e                	jns    800fa3 <fork+0x191>
		    	panic("sys page map fault %e");
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	68 ac 25 80 00       	push   $0x8025ac
  800f6d:	6a 5f                	push   $0x5f
  800f6f:	68 7a 25 80 00       	push   $0x80257a
  800f74:	e8 aa 0d 00 00       	call   801d23 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	6a 05                	push   $0x5
  800f7e:	56                   	push   %esi
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	e8 c6 fb ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 14                	jns    800fa3 <fork+0x191>
		    	panic("sys page map fault %e");
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	68 ac 25 80 00       	push   $0x8025ac
  800f97:	6a 64                	push   $0x64
  800f99:	68 7a 25 80 00       	push   $0x80257a
  800f9e:	e8 80 0d 00 00       	call   801d23 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fa3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa9:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800faf:	0f 85 de fe ff ff    	jne    800e93 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fb5:	a1 04 40 80 00       	mov    0x804004,%eax
  800fba:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	50                   	push   %eax
  800fc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fc7:	57                   	push   %edi
  800fc8:	e8 89 fc ff ff       	call   800c56 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	6a 02                	push   $0x2
  800fd2:	57                   	push   %edi
  800fd3:	e8 fa fb ff ff       	call   800bd2 <sys_env_set_status>
	
	return envid;
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <sfork>:

envid_t
sfork(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fe8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800ff7:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	53                   	push   %ebx
  801001:	68 c4 25 80 00       	push   $0x8025c4
  801006:	e8 78 f1 ff ff       	call   800183 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80100b:	c7 04 24 b6 00 80 00 	movl   $0x8000b6,(%esp)
  801012:	e8 e5 fc ff ff       	call   800cfc <sys_thread_create>
  801017:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801019:	83 c4 08             	add    $0x8,%esp
  80101c:	53                   	push   %ebx
  80101d:	68 c4 25 80 00       	push   $0x8025c4
  801022:	e8 5c f1 ff ff       	call   800183 <cprintf>
	return id;
}
  801027:	89 f0                	mov    %esi,%eax
  801029:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
  80104b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801050:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801062:	89 c2                	mov    %eax,%edx
  801064:	c1 ea 16             	shr    $0x16,%edx
  801067:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106e:	f6 c2 01             	test   $0x1,%dl
  801071:	74 11                	je     801084 <fd_alloc+0x2d>
  801073:	89 c2                	mov    %eax,%edx
  801075:	c1 ea 0c             	shr    $0xc,%edx
  801078:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107f:	f6 c2 01             	test   $0x1,%dl
  801082:	75 09                	jne    80108d <fd_alloc+0x36>
			*fd_store = fd;
  801084:	89 01                	mov    %eax,(%ecx)
			return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
  80108b:	eb 17                	jmp    8010a4 <fd_alloc+0x4d>
  80108d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801092:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801097:	75 c9                	jne    801062 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801099:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ac:	83 f8 1f             	cmp    $0x1f,%eax
  8010af:	77 36                	ja     8010e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b1:	c1 e0 0c             	shl    $0xc,%eax
  8010b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 16             	shr    $0x16,%edx
  8010be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	74 24                	je     8010ee <fd_lookup+0x48>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 0c             	shr    $0xc,%edx
  8010cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 1a                	je     8010f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010de:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	eb 13                	jmp    8010fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 0c                	jmp    8010fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f3:	eb 05                	jmp    8010fa <fd_lookup+0x54>
  8010f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801105:	ba 64 26 80 00       	mov    $0x802664,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80110a:	eb 13                	jmp    80111f <dev_lookup+0x23>
  80110c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80110f:	39 08                	cmp    %ecx,(%eax)
  801111:	75 0c                	jne    80111f <dev_lookup+0x23>
			*dev = devtab[i];
  801113:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801116:	89 01                	mov    %eax,(%ecx)
			return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	eb 2e                	jmp    80114d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111f:	8b 02                	mov    (%edx),%eax
  801121:	85 c0                	test   %eax,%eax
  801123:	75 e7                	jne    80110c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801125:	a1 04 40 80 00       	mov    0x804004,%eax
  80112a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80112d:	83 ec 04             	sub    $0x4,%esp
  801130:	51                   	push   %ecx
  801131:	50                   	push   %eax
  801132:	68 e8 25 80 00       	push   $0x8025e8
  801137:	e8 47 f0 ff ff       	call   800183 <cprintf>
	*dev = 0;
  80113c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 10             	sub    $0x10,%esp
  801157:	8b 75 08             	mov    0x8(%ebp),%esi
  80115a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801167:	c1 e8 0c             	shr    $0xc,%eax
  80116a:	50                   	push   %eax
  80116b:	e8 36 ff ff ff       	call   8010a6 <fd_lookup>
  801170:	83 c4 08             	add    $0x8,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 05                	js     80117c <fd_close+0x2d>
	    || fd != fd2)
  801177:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80117a:	74 0c                	je     801188 <fd_close+0x39>
		return (must_exist ? r : 0);
  80117c:	84 db                	test   %bl,%bl
  80117e:	ba 00 00 00 00       	mov    $0x0,%edx
  801183:	0f 44 c2             	cmove  %edx,%eax
  801186:	eb 41                	jmp    8011c9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	ff 36                	pushl  (%esi)
  801191:	e8 66 ff ff ff       	call   8010fc <dev_lookup>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 1a                	js     8011b9 <fd_close+0x6a>
		if (dev->dev_close)
  80119f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011a5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	74 0b                	je     8011b9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ae:	83 ec 0c             	sub    $0xc,%esp
  8011b1:	56                   	push   %esi
  8011b2:	ff d0                	call   *%eax
  8011b4:	89 c3                	mov    %eax,%ebx
  8011b6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	56                   	push   %esi
  8011bd:	6a 00                	push   $0x0
  8011bf:	e8 cc f9 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	89 d8                	mov    %ebx,%eax
}
  8011c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 75 08             	pushl  0x8(%ebp)
  8011dd:	e8 c4 fe ff ff       	call   8010a6 <fd_lookup>
  8011e2:	83 c4 08             	add    $0x8,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 10                	js     8011f9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	6a 01                	push   $0x1
  8011ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f1:	e8 59 ff ff ff       	call   80114f <fd_close>
  8011f6:	83 c4 10             	add    $0x10,%esp
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <close_all>:

void
close_all(void)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	53                   	push   %ebx
  80120b:	e8 c0 ff ff ff       	call   8011d0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801210:	83 c3 01             	add    $0x1,%ebx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	83 fb 20             	cmp    $0x20,%ebx
  801219:	75 ec                	jne    801207 <close_all+0xc>
		close(i);
}
  80121b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 2c             	sub    $0x2c,%esp
  801229:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 6e fe ff ff       	call   8010a6 <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	0f 88 c1 00 00 00    	js     801304 <dup+0xe4>
		return r;
	close(newfdnum);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	56                   	push   %esi
  801247:	e8 84 ff ff ff       	call   8011d0 <close>

	newfd = INDEX2FD(newfdnum);
  80124c:	89 f3                	mov    %esi,%ebx
  80124e:	c1 e3 0c             	shl    $0xc,%ebx
  801251:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801257:	83 c4 04             	add    $0x4,%esp
  80125a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125d:	e8 de fd ff ff       	call   801040 <fd2data>
  801262:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801264:	89 1c 24             	mov    %ebx,(%esp)
  801267:	e8 d4 fd ff ff       	call   801040 <fd2data>
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801272:	89 f8                	mov    %edi,%eax
  801274:	c1 e8 16             	shr    $0x16,%eax
  801277:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127e:	a8 01                	test   $0x1,%al
  801280:	74 37                	je     8012b9 <dup+0x99>
  801282:	89 f8                	mov    %edi,%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128e:	f6 c2 01             	test   $0x1,%dl
  801291:	74 26                	je     8012b9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801293:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a2:	50                   	push   %eax
  8012a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a6:	6a 00                	push   $0x0
  8012a8:	57                   	push   %edi
  8012a9:	6a 00                	push   $0x0
  8012ab:	e8 9e f8 ff ff       	call   800b4e <sys_page_map>
  8012b0:	89 c7                	mov    %eax,%edi
  8012b2:	83 c4 20             	add    $0x20,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 2e                	js     8012e7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012bc:	89 d0                	mov    %edx,%eax
  8012be:	c1 e8 0c             	shr    $0xc,%eax
  8012c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d0:	50                   	push   %eax
  8012d1:	53                   	push   %ebx
  8012d2:	6a 00                	push   $0x0
  8012d4:	52                   	push   %edx
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 72 f8 ff ff       	call   800b4e <sys_page_map>
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012e1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e3:	85 ff                	test   %edi,%edi
  8012e5:	79 1d                	jns    801304 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 9e f8 ff ff       	call   800b90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f2:	83 c4 08             	add    $0x8,%esp
  8012f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 91 f8 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	89 f8                	mov    %edi,%eax
}
  801304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	53                   	push   %ebx
  801310:	83 ec 14             	sub    $0x14,%esp
  801313:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801316:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	53                   	push   %ebx
  80131b:	e8 86 fd ff ff       	call   8010a6 <fd_lookup>
  801320:	83 c4 08             	add    $0x8,%esp
  801323:	89 c2                	mov    %eax,%edx
  801325:	85 c0                	test   %eax,%eax
  801327:	78 6d                	js     801396 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801333:	ff 30                	pushl  (%eax)
  801335:	e8 c2 fd ff ff       	call   8010fc <dev_lookup>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 4c                	js     80138d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801341:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801344:	8b 42 08             	mov    0x8(%edx),%eax
  801347:	83 e0 03             	and    $0x3,%eax
  80134a:	83 f8 01             	cmp    $0x1,%eax
  80134d:	75 21                	jne    801370 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80134f:	a1 04 40 80 00       	mov    0x804004,%eax
  801354:	8b 40 7c             	mov    0x7c(%eax),%eax
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	53                   	push   %ebx
  80135b:	50                   	push   %eax
  80135c:	68 29 26 80 00       	push   $0x802629
  801361:	e8 1d ee ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136e:	eb 26                	jmp    801396 <read+0x8a>
	}
	if (!dev->dev_read)
  801370:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801373:	8b 40 08             	mov    0x8(%eax),%eax
  801376:	85 c0                	test   %eax,%eax
  801378:	74 17                	je     801391 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	ff 75 10             	pushl  0x10(%ebp)
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	52                   	push   %edx
  801384:	ff d0                	call   *%eax
  801386:	89 c2                	mov    %eax,%edx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	eb 09                	jmp    801396 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	eb 05                	jmp    801396 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801391:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801396:	89 d0                	mov    %edx,%eax
  801398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b1:	eb 21                	jmp    8013d4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	89 f0                	mov    %esi,%eax
  8013b8:	29 d8                	sub    %ebx,%eax
  8013ba:	50                   	push   %eax
  8013bb:	89 d8                	mov    %ebx,%eax
  8013bd:	03 45 0c             	add    0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	57                   	push   %edi
  8013c2:	e8 45 ff ff ff       	call   80130c <read>
		if (m < 0)
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 10                	js     8013de <readn+0x41>
			return m;
		if (m == 0)
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	74 0a                	je     8013dc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d2:	01 c3                	add    %eax,%ebx
  8013d4:	39 f3                	cmp    %esi,%ebx
  8013d6:	72 db                	jb     8013b3 <readn+0x16>
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	eb 02                	jmp    8013de <readn+0x41>
  8013dc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 14             	sub    $0x14,%esp
  8013ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f3:	50                   	push   %eax
  8013f4:	53                   	push   %ebx
  8013f5:	e8 ac fc ff ff       	call   8010a6 <fd_lookup>
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 68                	js     80146b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	ff 30                	pushl  (%eax)
  80140f:	e8 e8 fc ff ff       	call   8010fc <dev_lookup>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 47                	js     801462 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801422:	75 21                	jne    801445 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801424:	a1 04 40 80 00       	mov    0x804004,%eax
  801429:	8b 40 7c             	mov    0x7c(%eax),%eax
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	53                   	push   %ebx
  801430:	50                   	push   %eax
  801431:	68 45 26 80 00       	push   $0x802645
  801436:	e8 48 ed ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801443:	eb 26                	jmp    80146b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801445:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801448:	8b 52 0c             	mov    0xc(%edx),%edx
  80144b:	85 d2                	test   %edx,%edx
  80144d:	74 17                	je     801466 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	ff 75 10             	pushl  0x10(%ebp)
  801455:	ff 75 0c             	pushl  0xc(%ebp)
  801458:	50                   	push   %eax
  801459:	ff d2                	call   *%edx
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	eb 09                	jmp    80146b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	89 c2                	mov    %eax,%edx
  801464:	eb 05                	jmp    80146b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801466:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <seek>:

int
seek(int fdnum, off_t offset)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801478:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 22 fc ff ff       	call   8010a6 <fd_lookup>
  801484:	83 c4 08             	add    $0x8,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 0e                	js     801499 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80148b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801491:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 14             	sub    $0x14,%esp
  8014a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	53                   	push   %ebx
  8014aa:	e8 f7 fb ff ff       	call   8010a6 <fd_lookup>
  8014af:	83 c4 08             	add    $0x8,%esp
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 65                	js     80151d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	ff 30                	pushl  (%eax)
  8014c4:	e8 33 fc ff ff       	call   8010fc <dev_lookup>
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 44                	js     801514 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d7:	75 21                	jne    8014fa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014de:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014e1:	83 ec 04             	sub    $0x4,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	50                   	push   %eax
  8014e6:	68 08 26 80 00       	push   $0x802608
  8014eb:	e8 93 ec ff ff       	call   800183 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f8:	eb 23                	jmp    80151d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fd:	8b 52 18             	mov    0x18(%edx),%edx
  801500:	85 d2                	test   %edx,%edx
  801502:	74 14                	je     801518 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	ff 75 0c             	pushl  0xc(%ebp)
  80150a:	50                   	push   %eax
  80150b:	ff d2                	call   *%edx
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	eb 09                	jmp    80151d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	89 c2                	mov    %eax,%edx
  801516:	eb 05                	jmp    80151d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801518:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80151d:	89 d0                	mov    %edx,%eax
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	53                   	push   %ebx
  801528:	83 ec 14             	sub    $0x14,%esp
  80152b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	ff 75 08             	pushl  0x8(%ebp)
  801535:	e8 6c fb ff ff       	call   8010a6 <fd_lookup>
  80153a:	83 c4 08             	add    $0x8,%esp
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 58                	js     80159b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	e8 a8 fb ff ff       	call   8010fc <dev_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 37                	js     801592 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801562:	74 32                	je     801596 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801564:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801567:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156e:	00 00 00 
	stat->st_isdir = 0;
  801571:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801578:	00 00 00 
	stat->st_dev = dev;
  80157b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	ff 75 f0             	pushl  -0x10(%ebp)
  801588:	ff 50 14             	call   *0x14(%eax)
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 09                	jmp    80159b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	89 c2                	mov    %eax,%edx
  801594:	eb 05                	jmp    80159b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801596:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	6a 00                	push   $0x0
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 e3 01 00 00       	call   801797 <open>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 1b                	js     8015d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	50                   	push   %eax
  8015c4:	e8 5b ff ff ff       	call   801524 <fstat>
  8015c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015cb:	89 1c 24             	mov    %ebx,(%esp)
  8015ce:	e8 fd fb ff ff       	call   8011d0 <close>
	return r;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	89 f0                	mov    %esi,%eax
}
  8015d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	89 c6                	mov    %eax,%esi
  8015e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015ef:	75 12                	jne    801603 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	6a 01                	push   $0x1
  8015f6:	e8 da 08 00 00       	call   801ed5 <ipc_find_env>
  8015fb:	a3 00 40 80 00       	mov    %eax,0x804000
  801600:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801603:	6a 07                	push   $0x7
  801605:	68 00 50 80 00       	push   $0x805000
  80160a:	56                   	push   %esi
  80160b:	ff 35 00 40 80 00    	pushl  0x804000
  801611:	e8 5d 08 00 00       	call   801e73 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801616:	83 c4 0c             	add    $0xc,%esp
  801619:	6a 00                	push   $0x0
  80161b:	53                   	push   %ebx
  80161c:	6a 00                	push   $0x0
  80161e:	e8 d5 07 00 00       	call   801df8 <ipc_recv>
}
  801623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801630:	8b 45 08             	mov    0x8(%ebp),%eax
  801633:	8b 40 0c             	mov    0xc(%eax),%eax
  801636:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801643:	ba 00 00 00 00       	mov    $0x0,%edx
  801648:	b8 02 00 00 00       	mov    $0x2,%eax
  80164d:	e8 8d ff ff ff       	call   8015df <fsipc>
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	8b 40 0c             	mov    0xc(%eax),%eax
  801660:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	b8 06 00 00 00       	mov    $0x6,%eax
  80166f:	e8 6b ff ff ff       	call   8015df <fsipc>
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	83 ec 04             	sub    $0x4,%esp
  80167d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	8b 40 0c             	mov    0xc(%eax),%eax
  801686:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 05 00 00 00       	mov    $0x5,%eax
  801695:	e8 45 ff ff ff       	call   8015df <fsipc>
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 2c                	js     8016ca <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	68 00 50 80 00       	push   $0x805000
  8016a6:	53                   	push   %ebx
  8016a7:	e8 5c f0 ff ff       	call   800708 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8016bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016db:	8b 52 0c             	mov    0xc(%edx),%edx
  8016de:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016e9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016ee:	0f 47 c2             	cmova  %edx,%eax
  8016f1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016f6:	50                   	push   %eax
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	68 08 50 80 00       	push   $0x805008
  8016ff:	e8 96 f1 ff ff       	call   80089a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	b8 04 00 00 00       	mov    $0x4,%eax
  80170e:	e8 cc fe ff ff       	call   8015df <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	8b 40 0c             	mov    0xc(%eax),%eax
  801723:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801728:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 03 00 00 00       	mov    $0x3,%eax
  801738:	e8 a2 fe ff ff       	call   8015df <fsipc>
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 4b                	js     80178e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801743:	39 c6                	cmp    %eax,%esi
  801745:	73 16                	jae    80175d <devfile_read+0x48>
  801747:	68 74 26 80 00       	push   $0x802674
  80174c:	68 7b 26 80 00       	push   $0x80267b
  801751:	6a 7c                	push   $0x7c
  801753:	68 90 26 80 00       	push   $0x802690
  801758:	e8 c6 05 00 00       	call   801d23 <_panic>
	assert(r <= PGSIZE);
  80175d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801762:	7e 16                	jle    80177a <devfile_read+0x65>
  801764:	68 9b 26 80 00       	push   $0x80269b
  801769:	68 7b 26 80 00       	push   $0x80267b
  80176e:	6a 7d                	push   $0x7d
  801770:	68 90 26 80 00       	push   $0x802690
  801775:	e8 a9 05 00 00       	call   801d23 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80177a:	83 ec 04             	sub    $0x4,%esp
  80177d:	50                   	push   %eax
  80177e:	68 00 50 80 00       	push   $0x805000
  801783:	ff 75 0c             	pushl  0xc(%ebp)
  801786:	e8 0f f1 ff ff       	call   80089a <memmove>
	return r;
  80178b:	83 c4 10             	add    $0x10,%esp
}
  80178e:	89 d8                	mov    %ebx,%eax
  801790:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	53                   	push   %ebx
  80179b:	83 ec 20             	sub    $0x20,%esp
  80179e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017a1:	53                   	push   %ebx
  8017a2:	e8 28 ef ff ff       	call   8006cf <strlen>
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017af:	7f 67                	jg     801818 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b7:	50                   	push   %eax
  8017b8:	e8 9a f8 ff ff       	call   801057 <fd_alloc>
  8017bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8017c0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 57                	js     80181d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	53                   	push   %ebx
  8017ca:	68 00 50 80 00       	push   $0x805000
  8017cf:	e8 34 ef ff ff       	call   800708 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017df:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e4:	e8 f6 fd ff ff       	call   8015df <fsipc>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	79 14                	jns    801806 <open+0x6f>
		fd_close(fd, 0);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	6a 00                	push   $0x0
  8017f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fa:	e8 50 f9 ff ff       	call   80114f <fd_close>
		return r;
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	89 da                	mov    %ebx,%edx
  801804:	eb 17                	jmp    80181d <open+0x86>
	}

	return fd2num(fd);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	ff 75 f4             	pushl  -0xc(%ebp)
  80180c:	e8 1f f8 ff ff       	call   801030 <fd2num>
  801811:	89 c2                	mov    %eax,%edx
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	eb 05                	jmp    80181d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801818:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80181d:	89 d0                	mov    %edx,%eax
  80181f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80182a:	ba 00 00 00 00       	mov    $0x0,%edx
  80182f:	b8 08 00 00 00       	mov    $0x8,%eax
  801834:	e8 a6 fd ff ff       	call   8015df <fsipc>
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	56                   	push   %esi
  80183f:	53                   	push   %ebx
  801840:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801843:	83 ec 0c             	sub    $0xc,%esp
  801846:	ff 75 08             	pushl  0x8(%ebp)
  801849:	e8 f2 f7 ff ff       	call   801040 <fd2data>
  80184e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801850:	83 c4 08             	add    $0x8,%esp
  801853:	68 a7 26 80 00       	push   $0x8026a7
  801858:	53                   	push   %ebx
  801859:	e8 aa ee ff ff       	call   800708 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80185e:	8b 46 04             	mov    0x4(%esi),%eax
  801861:	2b 06                	sub    (%esi),%eax
  801863:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801869:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801870:	00 00 00 
	stat->st_dev = &devpipe;
  801873:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80187a:	30 80 00 
	return 0;
}
  80187d:	b8 00 00 00 00       	mov    $0x0,%eax
  801882:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801893:	53                   	push   %ebx
  801894:	6a 00                	push   $0x0
  801896:	e8 f5 f2 ff ff       	call   800b90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80189b:	89 1c 24             	mov    %ebx,(%esp)
  80189e:	e8 9d f7 ff ff       	call   801040 <fd2data>
  8018a3:	83 c4 08             	add    $0x8,%esp
  8018a6:	50                   	push   %eax
  8018a7:	6a 00                	push   $0x0
  8018a9:	e8 e2 f2 ff ff       	call   800b90 <sys_page_unmap>
}
  8018ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	57                   	push   %edi
  8018b7:	56                   	push   %esi
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 1c             	sub    $0x1c,%esp
  8018bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018bf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c6:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018cc:	83 ec 0c             	sub    $0xc,%esp
  8018cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d2:	e8 40 06 00 00       	call   801f17 <pageref>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	89 3c 24             	mov    %edi,(%esp)
  8018dc:	e8 36 06 00 00       	call   801f17 <pageref>
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	39 c3                	cmp    %eax,%ebx
  8018e6:	0f 94 c1             	sete   %cl
  8018e9:	0f b6 c9             	movzbl %cl,%ecx
  8018ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018ef:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018f5:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  8018fb:	39 ce                	cmp    %ecx,%esi
  8018fd:	74 1e                	je     80191d <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8018ff:	39 c3                	cmp    %eax,%ebx
  801901:	75 be                	jne    8018c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801903:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801909:	ff 75 e4             	pushl  -0x1c(%ebp)
  80190c:	50                   	push   %eax
  80190d:	56                   	push   %esi
  80190e:	68 ae 26 80 00       	push   $0x8026ae
  801913:	e8 6b e8 ff ff       	call   800183 <cprintf>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	eb a4                	jmp    8018c1 <_pipeisclosed+0xe>
	}
}
  80191d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801920:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801923:	5b                   	pop    %ebx
  801924:	5e                   	pop    %esi
  801925:	5f                   	pop    %edi
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	57                   	push   %edi
  80192c:	56                   	push   %esi
  80192d:	53                   	push   %ebx
  80192e:	83 ec 28             	sub    $0x28,%esp
  801931:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801934:	56                   	push   %esi
  801935:	e8 06 f7 ff ff       	call   801040 <fd2data>
  80193a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	bf 00 00 00 00       	mov    $0x0,%edi
  801944:	eb 4b                	jmp    801991 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801946:	89 da                	mov    %ebx,%edx
  801948:	89 f0                	mov    %esi,%eax
  80194a:	e8 64 ff ff ff       	call   8018b3 <_pipeisclosed>
  80194f:	85 c0                	test   %eax,%eax
  801951:	75 48                	jne    80199b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801953:	e8 94 f1 ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801958:	8b 43 04             	mov    0x4(%ebx),%eax
  80195b:	8b 0b                	mov    (%ebx),%ecx
  80195d:	8d 51 20             	lea    0x20(%ecx),%edx
  801960:	39 d0                	cmp    %edx,%eax
  801962:	73 e2                	jae    801946 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801967:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80196b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80196e:	89 c2                	mov    %eax,%edx
  801970:	c1 fa 1f             	sar    $0x1f,%edx
  801973:	89 d1                	mov    %edx,%ecx
  801975:	c1 e9 1b             	shr    $0x1b,%ecx
  801978:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80197b:	83 e2 1f             	and    $0x1f,%edx
  80197e:	29 ca                	sub    %ecx,%edx
  801980:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801984:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801988:	83 c0 01             	add    $0x1,%eax
  80198b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198e:	83 c7 01             	add    $0x1,%edi
  801991:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801994:	75 c2                	jne    801958 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801996:	8b 45 10             	mov    0x10(%ebp),%eax
  801999:	eb 05                	jmp    8019a0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	57                   	push   %edi
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	83 ec 18             	sub    $0x18,%esp
  8019b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019b4:	57                   	push   %edi
  8019b5:	e8 86 f6 ff ff       	call   801040 <fd2data>
  8019ba:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c4:	eb 3d                	jmp    801a03 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019c6:	85 db                	test   %ebx,%ebx
  8019c8:	74 04                	je     8019ce <devpipe_read+0x26>
				return i;
  8019ca:	89 d8                	mov    %ebx,%eax
  8019cc:	eb 44                	jmp    801a12 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ce:	89 f2                	mov    %esi,%edx
  8019d0:	89 f8                	mov    %edi,%eax
  8019d2:	e8 dc fe ff ff       	call   8018b3 <_pipeisclosed>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	75 32                	jne    801a0d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019db:	e8 0c f1 ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019e0:	8b 06                	mov    (%esi),%eax
  8019e2:	3b 46 04             	cmp    0x4(%esi),%eax
  8019e5:	74 df                	je     8019c6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019e7:	99                   	cltd   
  8019e8:	c1 ea 1b             	shr    $0x1b,%edx
  8019eb:	01 d0                	add    %edx,%eax
  8019ed:	83 e0 1f             	and    $0x1f,%eax
  8019f0:	29 d0                	sub    %edx,%eax
  8019f2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019fd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a00:	83 c3 01             	add    $0x1,%ebx
  801a03:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a06:	75 d8                	jne    8019e0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	eb 05                	jmp    801a12 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a25:	50                   	push   %eax
  801a26:	e8 2c f6 ff ff       	call   801057 <fd_alloc>
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	89 c2                	mov    %eax,%edx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	0f 88 2c 01 00 00    	js     801b64 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a38:	83 ec 04             	sub    $0x4,%esp
  801a3b:	68 07 04 00 00       	push   $0x407
  801a40:	ff 75 f4             	pushl  -0xc(%ebp)
  801a43:	6a 00                	push   $0x0
  801a45:	e8 c1 f0 ff ff       	call   800b0b <sys_page_alloc>
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	89 c2                	mov    %eax,%edx
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	0f 88 0d 01 00 00    	js     801b64 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	e8 f4 f5 ff ff       	call   801057 <fd_alloc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	0f 88 e2 00 00 00    	js     801b52 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	68 07 04 00 00       	push   $0x407
  801a78:	ff 75 f0             	pushl  -0x10(%ebp)
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 89 f0 ff ff       	call   800b0b <sys_page_alloc>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	0f 88 c3 00 00 00    	js     801b52 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	ff 75 f4             	pushl  -0xc(%ebp)
  801a95:	e8 a6 f5 ff ff       	call   801040 <fd2data>
  801a9a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9c:	83 c4 0c             	add    $0xc,%esp
  801a9f:	68 07 04 00 00       	push   $0x407
  801aa4:	50                   	push   %eax
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 5f f0 ff ff       	call   800b0b <sys_page_alloc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	0f 88 89 00 00 00    	js     801b42 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	ff 75 f0             	pushl  -0x10(%ebp)
  801abf:	e8 7c f5 ff ff       	call   801040 <fd2data>
  801ac4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801acb:	50                   	push   %eax
  801acc:	6a 00                	push   $0x0
  801ace:	56                   	push   %esi
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 78 f0 ff ff       	call   800b4e <sys_page_map>
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	83 c4 20             	add    $0x20,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 55                	js     801b34 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801adf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801af4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b02:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b09:	83 ec 0c             	sub    $0xc,%esp
  801b0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0f:	e8 1c f5 ff ff       	call   801030 <fd2num>
  801b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b17:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b19:	83 c4 04             	add    $0x4,%esp
  801b1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1f:	e8 0c f5 ff ff       	call   801030 <fd2num>
  801b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b27:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b32:	eb 30                	jmp    801b64 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	56                   	push   %esi
  801b38:	6a 00                	push   $0x0
  801b3a:	e8 51 f0 ff ff       	call   800b90 <sys_page_unmap>
  801b3f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b42:	83 ec 08             	sub    $0x8,%esp
  801b45:	ff 75 f0             	pushl  -0x10(%ebp)
  801b48:	6a 00                	push   $0x0
  801b4a:	e8 41 f0 ff ff       	call   800b90 <sys_page_unmap>
  801b4f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	ff 75 f4             	pushl  -0xc(%ebp)
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 31 f0 ff ff       	call   800b90 <sys_page_unmap>
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b64:	89 d0                	mov    %edx,%eax
  801b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b76:	50                   	push   %eax
  801b77:	ff 75 08             	pushl  0x8(%ebp)
  801b7a:	e8 27 f5 ff ff       	call   8010a6 <fd_lookup>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 18                	js     801b9e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8c:	e8 af f4 ff ff       	call   801040 <fd2data>
	return _pipeisclosed(fd, p);
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b96:	e8 18 fd ff ff       	call   8018b3 <_pipeisclosed>
  801b9b:	83 c4 10             	add    $0x10,%esp
}
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    

00801baa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bb0:	68 c6 26 80 00       	push   $0x8026c6
  801bb5:	ff 75 0c             	pushl  0xc(%ebp)
  801bb8:	e8 4b eb ff ff       	call   800708 <strcpy>
	return 0;
}
  801bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	57                   	push   %edi
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bdb:	eb 2d                	jmp    801c0a <devcons_write+0x46>
		m = n - tot;
  801bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801be0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801be2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801be5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bea:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	53                   	push   %ebx
  801bf1:	03 45 0c             	add    0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	57                   	push   %edi
  801bf6:	e8 9f ec ff ff       	call   80089a <memmove>
		sys_cputs(buf, m);
  801bfb:	83 c4 08             	add    $0x8,%esp
  801bfe:	53                   	push   %ebx
  801bff:	57                   	push   %edi
  801c00:	e8 4a ee ff ff       	call   800a4f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c05:	01 de                	add    %ebx,%esi
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	89 f0                	mov    %esi,%eax
  801c0c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0f:	72 cc                	jb     801bdd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 08             	sub    $0x8,%esp
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c28:	74 2a                	je     801c54 <devcons_read+0x3b>
  801c2a:	eb 05                	jmp    801c31 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c2c:	e8 bb ee ff ff       	call   800aec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c31:	e8 37 ee ff ff       	call   800a6d <sys_cgetc>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	74 f2                	je     801c2c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	78 16                	js     801c54 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c3e:	83 f8 04             	cmp    $0x4,%eax
  801c41:	74 0c                	je     801c4f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c46:	88 02                	mov    %al,(%edx)
	return 1;
  801c48:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4d:	eb 05                	jmp    801c54 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c62:	6a 01                	push   $0x1
  801c64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c67:	50                   	push   %eax
  801c68:	e8 e2 ed ff ff       	call   800a4f <sys_cputs>
}
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <getchar>:

int
getchar(void)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c78:	6a 01                	push   $0x1
  801c7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 87 f6 ff ff       	call   80130c <read>
	if (r < 0)
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 0f                	js     801c9b <getchar+0x29>
		return r;
	if (r < 1)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	7e 06                	jle    801c96 <getchar+0x24>
		return -E_EOF;
	return c;
  801c90:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c94:	eb 05                	jmp    801c9b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c96:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	ff 75 08             	pushl  0x8(%ebp)
  801caa:	e8 f7 f3 ff ff       	call   8010a6 <fd_lookup>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 11                	js     801cc7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbf:	39 10                	cmp    %edx,(%eax)
  801cc1:	0f 94 c0             	sete   %al
  801cc4:	0f b6 c0             	movzbl %al,%eax
}
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <opencons>:

int
opencons(void)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ccf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd2:	50                   	push   %eax
  801cd3:	e8 7f f3 ff ff       	call   801057 <fd_alloc>
  801cd8:	83 c4 10             	add    $0x10,%esp
		return r;
  801cdb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 3e                	js     801d1f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce1:	83 ec 04             	sub    $0x4,%esp
  801ce4:	68 07 04 00 00       	push   $0x407
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 18 ee ff ff       	call   800b0b <sys_page_alloc>
  801cf3:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	78 23                	js     801d1f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cfc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	50                   	push   %eax
  801d15:	e8 16 f3 ff ff       	call   801030 <fd2num>
  801d1a:	89 c2                	mov    %eax,%edx
  801d1c:	83 c4 10             	add    $0x10,%esp
}
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d28:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d2b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d31:	e8 97 ed ff ff       	call   800acd <sys_getenvid>
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 0c             	pushl  0xc(%ebp)
  801d3c:	ff 75 08             	pushl  0x8(%ebp)
  801d3f:	56                   	push   %esi
  801d40:	50                   	push   %eax
  801d41:	68 d4 26 80 00       	push   $0x8026d4
  801d46:	e8 38 e4 ff ff       	call   800183 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d4b:	83 c4 18             	add    $0x18,%esp
  801d4e:	53                   	push   %ebx
  801d4f:	ff 75 10             	pushl  0x10(%ebp)
  801d52:	e8 db e3 ff ff       	call   800132 <vcprintf>
	cprintf("\n");
  801d57:	c7 04 24 bf 26 80 00 	movl   $0x8026bf,(%esp)
  801d5e:	e8 20 e4 ff ff       	call   800183 <cprintf>
  801d63:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d66:	cc                   	int3   
  801d67:	eb fd                	jmp    801d66 <_panic+0x43>

00801d69 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d6f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d76:	75 2a                	jne    801da2 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	6a 07                	push   $0x7
  801d7d:	68 00 f0 bf ee       	push   $0xeebff000
  801d82:	6a 00                	push   $0x0
  801d84:	e8 82 ed ff ff       	call   800b0b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	79 12                	jns    801da2 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d90:	50                   	push   %eax
  801d91:	68 f8 26 80 00       	push   $0x8026f8
  801d96:	6a 23                	push   $0x23
  801d98:	68 fc 26 80 00       	push   $0x8026fc
  801d9d:	e8 81 ff ff ff       	call   801d23 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	68 d4 1d 80 00       	push   $0x801dd4
  801db2:	6a 00                	push   $0x0
  801db4:	e8 9d ee ff ff       	call   800c56 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	79 12                	jns    801dd2 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dc0:	50                   	push   %eax
  801dc1:	68 f8 26 80 00       	push   $0x8026f8
  801dc6:	6a 2c                	push   $0x2c
  801dc8:	68 fc 26 80 00       	push   $0x8026fc
  801dcd:	e8 51 ff ff ff       	call   801d23 <_panic>
	}
}
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dd4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dd5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dda:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ddc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ddf:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801de3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801de8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dec:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dee:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801df1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801df2:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801df5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801df6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801df7:	c3                   	ret    

00801df8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	56                   	push   %esi
  801dfc:	53                   	push   %ebx
  801dfd:	8b 75 08             	mov    0x8(%ebp),%esi
  801e00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e06:	85 c0                	test   %eax,%eax
  801e08:	75 12                	jne    801e1c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e0a:	83 ec 0c             	sub    $0xc,%esp
  801e0d:	68 00 00 c0 ee       	push   $0xeec00000
  801e12:	e8 a4 ee ff ff       	call   800cbb <sys_ipc_recv>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	eb 0c                	jmp    801e28 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e1c:	83 ec 0c             	sub    $0xc,%esp
  801e1f:	50                   	push   %eax
  801e20:	e8 96 ee ff ff       	call   800cbb <sys_ipc_recv>
  801e25:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e28:	85 f6                	test   %esi,%esi
  801e2a:	0f 95 c1             	setne  %cl
  801e2d:	85 db                	test   %ebx,%ebx
  801e2f:	0f 95 c2             	setne  %dl
  801e32:	84 d1                	test   %dl,%cl
  801e34:	74 09                	je     801e3f <ipc_recv+0x47>
  801e36:	89 c2                	mov    %eax,%edx
  801e38:	c1 ea 1f             	shr    $0x1f,%edx
  801e3b:	84 d2                	test   %dl,%dl
  801e3d:	75 2d                	jne    801e6c <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e3f:	85 f6                	test   %esi,%esi
  801e41:	74 0d                	je     801e50 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e43:	a1 04 40 80 00       	mov    0x804004,%eax
  801e48:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e4e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e50:	85 db                	test   %ebx,%ebx
  801e52:	74 0d                	je     801e61 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e54:	a1 04 40 80 00       	mov    0x804004,%eax
  801e59:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e5f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e61:	a1 04 40 80 00       	mov    0x804004,%eax
  801e66:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6f:	5b                   	pop    %ebx
  801e70:	5e                   	pop    %esi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    

00801e73 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	57                   	push   %edi
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e85:	85 db                	test   %ebx,%ebx
  801e87:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e8c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e8f:	ff 75 14             	pushl  0x14(%ebp)
  801e92:	53                   	push   %ebx
  801e93:	56                   	push   %esi
  801e94:	57                   	push   %edi
  801e95:	e8 fe ed ff ff       	call   800c98 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	c1 ea 1f             	shr    $0x1f,%edx
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	84 d2                	test   %dl,%dl
  801ea4:	74 17                	je     801ebd <ipc_send+0x4a>
  801ea6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea9:	74 12                	je     801ebd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801eab:	50                   	push   %eax
  801eac:	68 0a 27 80 00       	push   $0x80270a
  801eb1:	6a 47                	push   $0x47
  801eb3:	68 18 27 80 00       	push   $0x802718
  801eb8:	e8 66 fe ff ff       	call   801d23 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ebd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec0:	75 07                	jne    801ec9 <ipc_send+0x56>
			sys_yield();
  801ec2:	e8 25 ec ff ff       	call   800aec <sys_yield>
  801ec7:	eb c6                	jmp    801e8f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	75 c2                	jne    801e8f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ee0:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ee6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eec:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ef2:	39 ca                	cmp    %ecx,%edx
  801ef4:	75 10                	jne    801f06 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ef6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801efc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f01:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f04:	eb 0f                	jmp    801f15 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f06:	83 c0 01             	add    $0x1,%eax
  801f09:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f0e:	75 d0                	jne    801ee0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    

00801f17 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1d:	89 d0                	mov    %edx,%eax
  801f1f:	c1 e8 16             	shr    $0x16,%eax
  801f22:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2e:	f6 c1 01             	test   $0x1,%cl
  801f31:	74 1d                	je     801f50 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f33:	c1 ea 0c             	shr    $0xc,%edx
  801f36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f3d:	f6 c2 01             	test   $0x1,%dl
  801f40:	74 0e                	je     801f50 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f42:	c1 ea 0c             	shr    $0xc,%edx
  801f45:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f4c:	ef 
  801f4d:	0f b7 c0             	movzwl %ax,%eax
}
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	66 90                	xchg   %ax,%ax
  801f54:	66 90                	xchg   %ax,%ax
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	66 90                	xchg   %ax,%ax
  801f5a:	66 90                	xchg   %ax,%ax
  801f5c:	66 90                	xchg   %ax,%ax
  801f5e:	66 90                	xchg   %ax,%ax

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
