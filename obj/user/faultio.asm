
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
  800043:	68 40 22 80 00       	push   $0x802240
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
  80005e:	68 4e 22 80 00       	push   $0x80224e
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
  8000dc:	e8 63 11 00 00       	call   801244 <close_all>
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
  8001e6:	e8 c5 1d 00 00       	call   801fb0 <__udivdi3>
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
  800229:	e8 b2 1e 00 00       	call   8020e0 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 72 22 80 00 	movsbl 0x802272(%eax),%eax
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
  80032d:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  8003f1:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  8003f8:	85 d2                	test   %edx,%edx
  8003fa:	75 18                	jne    800414 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	68 8a 22 80 00       	push   $0x80228a
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
  800415:	68 cd 26 80 00       	push   $0x8026cd
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
  800439:	b8 83 22 80 00       	mov    $0x802283,%eax
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
  800ab4:	68 7f 25 80 00       	push   $0x80257f
  800ab9:	6a 23                	push   $0x23
  800abb:	68 9c 25 80 00       	push   $0x80259c
  800ac0:	e8 b0 12 00 00       	call   801d75 <_panic>

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
  800b35:	68 7f 25 80 00       	push   $0x80257f
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 9c 25 80 00       	push   $0x80259c
  800b41:	e8 2f 12 00 00       	call   801d75 <_panic>

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
  800b77:	68 7f 25 80 00       	push   $0x80257f
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 9c 25 80 00       	push   $0x80259c
  800b83:	e8 ed 11 00 00       	call   801d75 <_panic>

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
  800bb9:	68 7f 25 80 00       	push   $0x80257f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 9c 25 80 00       	push   $0x80259c
  800bc5:	e8 ab 11 00 00       	call   801d75 <_panic>

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
  800bfb:	68 7f 25 80 00       	push   $0x80257f
  800c00:	6a 23                	push   $0x23
  800c02:	68 9c 25 80 00       	push   $0x80259c
  800c07:	e8 69 11 00 00       	call   801d75 <_panic>

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
  800c3d:	68 7f 25 80 00       	push   $0x80257f
  800c42:	6a 23                	push   $0x23
  800c44:	68 9c 25 80 00       	push   $0x80259c
  800c49:	e8 27 11 00 00       	call   801d75 <_panic>
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
  800c7f:	68 7f 25 80 00       	push   $0x80257f
  800c84:	6a 23                	push   $0x23
  800c86:	68 9c 25 80 00       	push   $0x80259c
  800c8b:	e8 e5 10 00 00       	call   801d75 <_panic>

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
  800ce3:	68 7f 25 80 00       	push   $0x80257f
  800ce8:	6a 23                	push   $0x23
  800cea:	68 9c 25 80 00       	push   $0x80259c
  800cef:	e8 81 10 00 00       	call   801d75 <_panic>

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
  800d82:	68 aa 25 80 00       	push   $0x8025aa
  800d87:	6a 1e                	push   $0x1e
  800d89:	68 ba 25 80 00       	push   $0x8025ba
  800d8e:	e8 e2 0f 00 00       	call   801d75 <_panic>
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
  800dac:	68 c5 25 80 00       	push   $0x8025c5
  800db1:	6a 2c                	push   $0x2c
  800db3:	68 ba 25 80 00       	push   $0x8025ba
  800db8:	e8 b8 0f 00 00       	call   801d75 <_panic>
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
  800df4:	68 c5 25 80 00       	push   $0x8025c5
  800df9:	6a 33                	push   $0x33
  800dfb:	68 ba 25 80 00       	push   $0x8025ba
  800e00:	e8 70 0f 00 00       	call   801d75 <_panic>
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
  800e1c:	68 c5 25 80 00       	push   $0x8025c5
  800e21:	6a 37                	push   $0x37
  800e23:	68 ba 25 80 00       	push   $0x8025ba
  800e28:	e8 48 0f 00 00       	call   801d75 <_panic>
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
  800e40:	e8 76 0f 00 00       	call   801dbb <set_pgfault_handler>
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
  800e59:	68 de 25 80 00       	push   $0x8025de
  800e5e:	68 84 00 00 00       	push   $0x84
  800e63:	68 ba 25 80 00       	push   $0x8025ba
  800e68:	e8 08 0f 00 00       	call   801d75 <_panic>
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
  800f15:	68 ec 25 80 00       	push   $0x8025ec
  800f1a:	6a 54                	push   $0x54
  800f1c:	68 ba 25 80 00       	push   $0x8025ba
  800f21:	e8 4f 0e 00 00       	call   801d75 <_panic>
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
  800f5a:	68 ec 25 80 00       	push   $0x8025ec
  800f5f:	6a 5b                	push   $0x5b
  800f61:	68 ba 25 80 00       	push   $0x8025ba
  800f66:	e8 0a 0e 00 00       	call   801d75 <_panic>
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
  800f88:	68 ec 25 80 00       	push   $0x8025ec
  800f8d:	6a 5f                	push   $0x5f
  800f8f:	68 ba 25 80 00       	push   $0x8025ba
  800f94:	e8 dc 0d 00 00       	call   801d75 <_panic>
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
  800fb2:	68 ec 25 80 00       	push   $0x8025ec
  800fb7:	6a 64                	push   $0x64
  800fb9:	68 ba 25 80 00       	push   $0x8025ba
  800fbe:	e8 b2 0d 00 00       	call   801d75 <_panic>
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
  801021:	68 04 26 80 00       	push   $0x802604
  801026:	e8 58 f1 ff ff       	call   800183 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80102b:	c7 04 24 b6 00 80 00 	movl   $0x8000b6,(%esp)
  801032:	e8 c5 fc ff ff       	call   800cfc <sys_thread_create>
  801037:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	53                   	push   %ebx
  80103d:	68 04 26 80 00       	push   $0x802604
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

00801076 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	05 00 00 00 30       	add    $0x30000000,%eax
  801081:	c1 e8 0c             	shr    $0xc,%eax
}
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	05 00 00 00 30       	add    $0x30000000,%eax
  801091:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801096:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a8:	89 c2                	mov    %eax,%edx
  8010aa:	c1 ea 16             	shr    $0x16,%edx
  8010ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b4:	f6 c2 01             	test   $0x1,%dl
  8010b7:	74 11                	je     8010ca <fd_alloc+0x2d>
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 0c             	shr    $0xc,%edx
  8010be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	75 09                	jne    8010d3 <fd_alloc+0x36>
			*fd_store = fd;
  8010ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d1:	eb 17                	jmp    8010ea <fd_alloc+0x4d>
  8010d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010dd:	75 c9                	jne    8010a8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f2:	83 f8 1f             	cmp    $0x1f,%eax
  8010f5:	77 36                	ja     80112d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f7:	c1 e0 0c             	shl    $0xc,%eax
  8010fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	c1 ea 16             	shr    $0x16,%edx
  801104:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110b:	f6 c2 01             	test   $0x1,%dl
  80110e:	74 24                	je     801134 <fd_lookup+0x48>
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 0c             	shr    $0xc,%edx
  801115:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 1a                	je     80113b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801121:	8b 55 0c             	mov    0xc(%ebp),%edx
  801124:	89 02                	mov    %eax,(%edx)
	return 0;
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
  80112b:	eb 13                	jmp    801140 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801132:	eb 0c                	jmp    801140 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801134:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801139:	eb 05                	jmp    801140 <fd_lookup+0x54>
  80113b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114b:	ba a4 26 80 00       	mov    $0x8026a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801150:	eb 13                	jmp    801165 <dev_lookup+0x23>
  801152:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801155:	39 08                	cmp    %ecx,(%eax)
  801157:	75 0c                	jne    801165 <dev_lookup+0x23>
			*dev = devtab[i];
  801159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115e:	b8 00 00 00 00       	mov    $0x0,%eax
  801163:	eb 31                	jmp    801196 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801165:	8b 02                	mov    (%edx),%eax
  801167:	85 c0                	test   %eax,%eax
  801169:	75 e7                	jne    801152 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801176:	83 ec 04             	sub    $0x4,%esp
  801179:	51                   	push   %ecx
  80117a:	50                   	push   %eax
  80117b:	68 28 26 80 00       	push   $0x802628
  801180:	e8 fe ef ff ff       	call   800183 <cprintf>
	*dev = 0;
  801185:	8b 45 0c             	mov    0xc(%ebp),%eax
  801188:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801196:	c9                   	leave  
  801197:	c3                   	ret    

00801198 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 10             	sub    $0x10,%esp
  8011a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011b0:	c1 e8 0c             	shr    $0xc,%eax
  8011b3:	50                   	push   %eax
  8011b4:	e8 33 ff ff ff       	call   8010ec <fd_lookup>
  8011b9:	83 c4 08             	add    $0x8,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 05                	js     8011c5 <fd_close+0x2d>
	    || fd != fd2)
  8011c0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c3:	74 0c                	je     8011d1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011c5:	84 db                	test   %bl,%bl
  8011c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cc:	0f 44 c2             	cmove  %edx,%eax
  8011cf:	eb 41                	jmp    801212 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	ff 36                	pushl  (%esi)
  8011da:	e8 63 ff ff ff       	call   801142 <dev_lookup>
  8011df:	89 c3                	mov    %eax,%ebx
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 1a                	js     801202 <fd_close+0x6a>
		if (dev->dev_close)
  8011e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011eb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ee:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	74 0b                	je     801202 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	56                   	push   %esi
  8011fb:	ff d0                	call   *%eax
  8011fd:	89 c3                	mov    %eax,%ebx
  8011ff:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	56                   	push   %esi
  801206:	6a 00                	push   $0x0
  801208:	e8 83 f9 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	89 d8                	mov    %ebx,%eax
}
  801212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 75 08             	pushl  0x8(%ebp)
  801226:	e8 c1 fe ff ff       	call   8010ec <fd_lookup>
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 10                	js     801242 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	6a 01                	push   $0x1
  801237:	ff 75 f4             	pushl  -0xc(%ebp)
  80123a:	e8 59 ff ff ff       	call   801198 <fd_close>
  80123f:	83 c4 10             	add    $0x10,%esp
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <close_all>:

void
close_all(void)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80124b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801250:	83 ec 0c             	sub    $0xc,%esp
  801253:	53                   	push   %ebx
  801254:	e8 c0 ff ff ff       	call   801219 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801259:	83 c3 01             	add    $0x1,%ebx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	83 fb 20             	cmp    $0x20,%ebx
  801262:	75 ec                	jne    801250 <close_all+0xc>
		close(i);
}
  801264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	57                   	push   %edi
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	83 ec 2c             	sub    $0x2c,%esp
  801272:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801275:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 75 08             	pushl  0x8(%ebp)
  80127c:	e8 6b fe ff ff       	call   8010ec <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	0f 88 c1 00 00 00    	js     80134d <dup+0xe4>
		return r;
	close(newfdnum);
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	56                   	push   %esi
  801290:	e8 84 ff ff ff       	call   801219 <close>

	newfd = INDEX2FD(newfdnum);
  801295:	89 f3                	mov    %esi,%ebx
  801297:	c1 e3 0c             	shl    $0xc,%ebx
  80129a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012a0:	83 c4 04             	add    $0x4,%esp
  8012a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a6:	e8 db fd ff ff       	call   801086 <fd2data>
  8012ab:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ad:	89 1c 24             	mov    %ebx,(%esp)
  8012b0:	e8 d1 fd ff ff       	call   801086 <fd2data>
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012bb:	89 f8                	mov    %edi,%eax
  8012bd:	c1 e8 16             	shr    $0x16,%eax
  8012c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c7:	a8 01                	test   $0x1,%al
  8012c9:	74 37                	je     801302 <dup+0x99>
  8012cb:	89 f8                	mov    %edi,%eax
  8012cd:	c1 e8 0c             	shr    $0xc,%eax
  8012d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d7:	f6 c2 01             	test   $0x1,%dl
  8012da:	74 26                	je     801302 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ef:	6a 00                	push   $0x0
  8012f1:	57                   	push   %edi
  8012f2:	6a 00                	push   $0x0
  8012f4:	e8 55 f8 ff ff       	call   800b4e <sys_page_map>
  8012f9:	89 c7                	mov    %eax,%edi
  8012fb:	83 c4 20             	add    $0x20,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 2e                	js     801330 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801302:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801305:	89 d0                	mov    %edx,%eax
  801307:	c1 e8 0c             	shr    $0xc,%eax
  80130a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	25 07 0e 00 00       	and    $0xe07,%eax
  801319:	50                   	push   %eax
  80131a:	53                   	push   %ebx
  80131b:	6a 00                	push   $0x0
  80131d:	52                   	push   %edx
  80131e:	6a 00                	push   $0x0
  801320:	e8 29 f8 ff ff       	call   800b4e <sys_page_map>
  801325:	89 c7                	mov    %eax,%edi
  801327:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80132a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132c:	85 ff                	test   %edi,%edi
  80132e:	79 1d                	jns    80134d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	53                   	push   %ebx
  801334:	6a 00                	push   $0x0
  801336:	e8 55 f8 ff ff       	call   800b90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133b:	83 c4 08             	add    $0x8,%esp
  80133e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801341:	6a 00                	push   $0x0
  801343:	e8 48 f8 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	89 f8                	mov    %edi,%eax
}
  80134d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	53                   	push   %ebx
  801359:	83 ec 14             	sub    $0x14,%esp
  80135c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801362:	50                   	push   %eax
  801363:	53                   	push   %ebx
  801364:	e8 83 fd ff ff       	call   8010ec <fd_lookup>
  801369:	83 c4 08             	add    $0x8,%esp
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 70                	js     8013e2 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137c:	ff 30                	pushl  (%eax)
  80137e:	e8 bf fd ff ff       	call   801142 <dev_lookup>
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 4f                	js     8013d9 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80138a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138d:	8b 42 08             	mov    0x8(%edx),%eax
  801390:	83 e0 03             	and    $0x3,%eax
  801393:	83 f8 01             	cmp    $0x1,%eax
  801396:	75 24                	jne    8013bc <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801398:	a1 04 40 80 00       	mov    0x804004,%eax
  80139d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	53                   	push   %ebx
  8013a7:	50                   	push   %eax
  8013a8:	68 69 26 80 00       	push   $0x802669
  8013ad:	e8 d1 ed ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ba:	eb 26                	jmp    8013e2 <read+0x8d>
	}
	if (!dev->dev_read)
  8013bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bf:	8b 40 08             	mov    0x8(%eax),%eax
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	74 17                	je     8013dd <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013c6:	83 ec 04             	sub    $0x4,%esp
  8013c9:	ff 75 10             	pushl  0x10(%ebp)
  8013cc:	ff 75 0c             	pushl  0xc(%ebp)
  8013cf:	52                   	push   %edx
  8013d0:	ff d0                	call   *%eax
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	eb 09                	jmp    8013e2 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	eb 05                	jmp    8013e2 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013e2:	89 d0                	mov    %edx,%eax
  8013e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	57                   	push   %edi
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fd:	eb 21                	jmp    801420 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ff:	83 ec 04             	sub    $0x4,%esp
  801402:	89 f0                	mov    %esi,%eax
  801404:	29 d8                	sub    %ebx,%eax
  801406:	50                   	push   %eax
  801407:	89 d8                	mov    %ebx,%eax
  801409:	03 45 0c             	add    0xc(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	57                   	push   %edi
  80140e:	e8 42 ff ff ff       	call   801355 <read>
		if (m < 0)
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 10                	js     80142a <readn+0x41>
			return m;
		if (m == 0)
  80141a:	85 c0                	test   %eax,%eax
  80141c:	74 0a                	je     801428 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141e:	01 c3                	add    %eax,%ebx
  801420:	39 f3                	cmp    %esi,%ebx
  801422:	72 db                	jb     8013ff <readn+0x16>
  801424:	89 d8                	mov    %ebx,%eax
  801426:	eb 02                	jmp    80142a <readn+0x41>
  801428:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80142a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5f                   	pop    %edi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	53                   	push   %ebx
  801436:	83 ec 14             	sub    $0x14,%esp
  801439:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	53                   	push   %ebx
  801441:	e8 a6 fc ff ff       	call   8010ec <fd_lookup>
  801446:	83 c4 08             	add    $0x8,%esp
  801449:	89 c2                	mov    %eax,%edx
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 6b                	js     8014ba <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	50                   	push   %eax
  801456:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801459:	ff 30                	pushl  (%eax)
  80145b:	e8 e2 fc ff ff       	call   801142 <dev_lookup>
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 4a                	js     8014b1 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80146e:	75 24                	jne    801494 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801470:	a1 04 40 80 00       	mov    0x804004,%eax
  801475:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	53                   	push   %ebx
  80147f:	50                   	push   %eax
  801480:	68 85 26 80 00       	push   $0x802685
  801485:	e8 f9 ec ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801492:	eb 26                	jmp    8014ba <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801497:	8b 52 0c             	mov    0xc(%edx),%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	74 17                	je     8014b5 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	ff 75 10             	pushl  0x10(%ebp)
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	50                   	push   %eax
  8014a8:	ff d2                	call   *%edx
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb 09                	jmp    8014ba <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	eb 05                	jmp    8014ba <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ba:	89 d0                	mov    %edx,%eax
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	ff 75 08             	pushl  0x8(%ebp)
  8014ce:	e8 19 fc ff ff       	call   8010ec <fd_lookup>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 0e                	js     8014e8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 14             	sub    $0x14,%esp
  8014f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f7:	50                   	push   %eax
  8014f8:	53                   	push   %ebx
  8014f9:	e8 ee fb ff ff       	call   8010ec <fd_lookup>
  8014fe:	83 c4 08             	add    $0x8,%esp
  801501:	89 c2                	mov    %eax,%edx
  801503:	85 c0                	test   %eax,%eax
  801505:	78 68                	js     80156f <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801511:	ff 30                	pushl  (%eax)
  801513:	e8 2a fc ff ff       	call   801142 <dev_lookup>
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 47                	js     801566 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801522:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801526:	75 24                	jne    80154c <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801528:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80152d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	53                   	push   %ebx
  801537:	50                   	push   %eax
  801538:	68 48 26 80 00       	push   $0x802648
  80153d:	e8 41 ec ff ff       	call   800183 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154a:	eb 23                	jmp    80156f <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80154c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154f:	8b 52 18             	mov    0x18(%edx),%edx
  801552:	85 d2                	test   %edx,%edx
  801554:	74 14                	je     80156a <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	ff 75 0c             	pushl  0xc(%ebp)
  80155c:	50                   	push   %eax
  80155d:	ff d2                	call   *%edx
  80155f:	89 c2                	mov    %eax,%edx
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	eb 09                	jmp    80156f <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801566:	89 c2                	mov    %eax,%edx
  801568:	eb 05                	jmp    80156f <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80156f:	89 d0                	mov    %edx,%eax
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 14             	sub    $0x14,%esp
  80157d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801580:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	ff 75 08             	pushl  0x8(%ebp)
  801587:	e8 60 fb ff ff       	call   8010ec <fd_lookup>
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	89 c2                	mov    %eax,%edx
  801591:	85 c0                	test   %eax,%eax
  801593:	78 58                	js     8015ed <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	ff 30                	pushl  (%eax)
  8015a1:	e8 9c fb ff ff       	call   801142 <dev_lookup>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 37                	js     8015e4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b4:	74 32                	je     8015e8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015b9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c0:	00 00 00 
	stat->st_isdir = 0;
  8015c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ca:	00 00 00 
	stat->st_dev = dev;
  8015cd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	53                   	push   %ebx
  8015d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015da:	ff 50 14             	call   *0x14(%eax)
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	eb 09                	jmp    8015ed <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	eb 05                	jmp    8015ed <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ed:	89 d0                	mov    %edx,%eax
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	6a 00                	push   $0x0
  8015fe:	ff 75 08             	pushl  0x8(%ebp)
  801601:	e8 e3 01 00 00       	call   8017e9 <open>
  801606:	89 c3                	mov    %eax,%ebx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 1b                	js     80162a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	ff 75 0c             	pushl  0xc(%ebp)
  801615:	50                   	push   %eax
  801616:	e8 5b ff ff ff       	call   801576 <fstat>
  80161b:	89 c6                	mov    %eax,%esi
	close(fd);
  80161d:	89 1c 24             	mov    %ebx,(%esp)
  801620:	e8 f4 fb ff ff       	call   801219 <close>
	return r;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	89 f0                	mov    %esi,%eax
}
  80162a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162d:	5b                   	pop    %ebx
  80162e:	5e                   	pop    %esi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    

00801631 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	89 c6                	mov    %eax,%esi
  801638:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801641:	75 12                	jne    801655 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	6a 01                	push   $0x1
  801648:	e8 da 08 00 00       	call   801f27 <ipc_find_env>
  80164d:	a3 00 40 80 00       	mov    %eax,0x804000
  801652:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801655:	6a 07                	push   $0x7
  801657:	68 00 50 80 00       	push   $0x805000
  80165c:	56                   	push   %esi
  80165d:	ff 35 00 40 80 00    	pushl  0x804000
  801663:	e8 5d 08 00 00       	call   801ec5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801668:	83 c4 0c             	add    $0xc,%esp
  80166b:	6a 00                	push   $0x0
  80166d:	53                   	push   %ebx
  80166e:	6a 00                	push   $0x0
  801670:	e8 d5 07 00 00       	call   801e4a <ipc_recv>
}
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	8b 40 0c             	mov    0xc(%eax),%eax
  801688:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801690:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	b8 02 00 00 00       	mov    $0x2,%eax
  80169f:	e8 8d ff ff ff       	call   801631 <fsipc>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8016af:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c1:	e8 6b ff ff ff       	call   801631 <fsipc>
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 04             	sub    $0x4,%esp
  8016cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e7:	e8 45 ff ff ff       	call   801631 <fsipc>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 2c                	js     80171c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	68 00 50 80 00       	push   $0x805000
  8016f8:	53                   	push   %ebx
  8016f9:	e8 0a f0 ff ff       	call   800708 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016fe:	a1 80 50 80 00       	mov    0x805080,%eax
  801703:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801709:	a1 84 50 80 00       	mov    0x805084,%eax
  80170e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80172a:	8b 55 08             	mov    0x8(%ebp),%edx
  80172d:	8b 52 0c             	mov    0xc(%edx),%edx
  801730:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801736:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80173b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801740:	0f 47 c2             	cmova  %edx,%eax
  801743:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801748:	50                   	push   %eax
  801749:	ff 75 0c             	pushl  0xc(%ebp)
  80174c:	68 08 50 80 00       	push   $0x805008
  801751:	e8 44 f1 ff ff       	call   80089a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 04 00 00 00       	mov    $0x4,%eax
  801760:	e8 cc fe ff ff       	call   801631 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
  80176c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80177a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801780:	ba 00 00 00 00       	mov    $0x0,%edx
  801785:	b8 03 00 00 00       	mov    $0x3,%eax
  80178a:	e8 a2 fe ff ff       	call   801631 <fsipc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	85 c0                	test   %eax,%eax
  801793:	78 4b                	js     8017e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801795:	39 c6                	cmp    %eax,%esi
  801797:	73 16                	jae    8017af <devfile_read+0x48>
  801799:	68 b4 26 80 00       	push   $0x8026b4
  80179e:	68 bb 26 80 00       	push   $0x8026bb
  8017a3:	6a 7c                	push   $0x7c
  8017a5:	68 d0 26 80 00       	push   $0x8026d0
  8017aa:	e8 c6 05 00 00       	call   801d75 <_panic>
	assert(r <= PGSIZE);
  8017af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b4:	7e 16                	jle    8017cc <devfile_read+0x65>
  8017b6:	68 db 26 80 00       	push   $0x8026db
  8017bb:	68 bb 26 80 00       	push   $0x8026bb
  8017c0:	6a 7d                	push   $0x7d
  8017c2:	68 d0 26 80 00       	push   $0x8026d0
  8017c7:	e8 a9 05 00 00       	call   801d75 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017cc:	83 ec 04             	sub    $0x4,%esp
  8017cf:	50                   	push   %eax
  8017d0:	68 00 50 80 00       	push   $0x805000
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	e8 bd f0 ff ff       	call   80089a <memmove>
	return r;
  8017dd:	83 c4 10             	add    $0x10,%esp
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 20             	sub    $0x20,%esp
  8017f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f3:	53                   	push   %ebx
  8017f4:	e8 d6 ee ff ff       	call   8006cf <strlen>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801801:	7f 67                	jg     80186a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	e8 8e f8 ff ff       	call   80109d <fd_alloc>
  80180f:	83 c4 10             	add    $0x10,%esp
		return r;
  801812:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801814:	85 c0                	test   %eax,%eax
  801816:	78 57                	js     80186f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	53                   	push   %ebx
  80181c:	68 00 50 80 00       	push   $0x805000
  801821:	e8 e2 ee ff ff       	call   800708 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801831:	b8 01 00 00 00       	mov    $0x1,%eax
  801836:	e8 f6 fd ff ff       	call   801631 <fsipc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	79 14                	jns    801858 <open+0x6f>
		fd_close(fd, 0);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	6a 00                	push   $0x0
  801849:	ff 75 f4             	pushl  -0xc(%ebp)
  80184c:	e8 47 f9 ff ff       	call   801198 <fd_close>
		return r;
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	89 da                	mov    %ebx,%edx
  801856:	eb 17                	jmp    80186f <open+0x86>
	}

	return fd2num(fd);
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	ff 75 f4             	pushl  -0xc(%ebp)
  80185e:	e8 13 f8 ff ff       	call   801076 <fd2num>
  801863:	89 c2                	mov    %eax,%edx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	eb 05                	jmp    80186f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80186f:	89 d0                	mov    %edx,%eax
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 08 00 00 00       	mov    $0x8,%eax
  801886:	e8 a6 fd ff ff       	call   801631 <fsipc>
}
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801895:	83 ec 0c             	sub    $0xc,%esp
  801898:	ff 75 08             	pushl  0x8(%ebp)
  80189b:	e8 e6 f7 ff ff       	call   801086 <fd2data>
  8018a0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018a2:	83 c4 08             	add    $0x8,%esp
  8018a5:	68 e7 26 80 00       	push   $0x8026e7
  8018aa:	53                   	push   %ebx
  8018ab:	e8 58 ee ff ff       	call   800708 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018b0:	8b 46 04             	mov    0x4(%esi),%eax
  8018b3:	2b 06                	sub    (%esi),%eax
  8018b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c2:	00 00 00 
	stat->st_dev = &devpipe;
  8018c5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018cc:	30 80 00 
	return 0;
}
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d7:	5b                   	pop    %ebx
  8018d8:	5e                   	pop    %esi
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018e5:	53                   	push   %ebx
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 a3 f2 ff ff       	call   800b90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ed:	89 1c 24             	mov    %ebx,(%esp)
  8018f0:	e8 91 f7 ff ff       	call   801086 <fd2data>
  8018f5:	83 c4 08             	add    $0x8,%esp
  8018f8:	50                   	push   %eax
  8018f9:	6a 00                	push   $0x0
  8018fb:	e8 90 f2 ff ff       	call   800b90 <sys_page_unmap>
}
  801900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	57                   	push   %edi
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	83 ec 1c             	sub    $0x1c,%esp
  80190e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801911:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801913:	a1 04 40 80 00       	mov    0x804004,%eax
  801918:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	ff 75 e0             	pushl  -0x20(%ebp)
  801924:	e8 43 06 00 00       	call   801f6c <pageref>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	89 3c 24             	mov    %edi,(%esp)
  80192e:	e8 39 06 00 00       	call   801f6c <pageref>
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	39 c3                	cmp    %eax,%ebx
  801938:	0f 94 c1             	sete   %cl
  80193b:	0f b6 c9             	movzbl %cl,%ecx
  80193e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801941:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801947:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80194d:	39 ce                	cmp    %ecx,%esi
  80194f:	74 1e                	je     80196f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801951:	39 c3                	cmp    %eax,%ebx
  801953:	75 be                	jne    801913 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801955:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80195b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80195e:	50                   	push   %eax
  80195f:	56                   	push   %esi
  801960:	68 ee 26 80 00       	push   $0x8026ee
  801965:	e8 19 e8 ff ff       	call   800183 <cprintf>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb a4                	jmp    801913 <_pipeisclosed+0xe>
	}
}
  80196f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5f                   	pop    %edi
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	57                   	push   %edi
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	83 ec 28             	sub    $0x28,%esp
  801983:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801986:	56                   	push   %esi
  801987:	e8 fa f6 ff ff       	call   801086 <fd2data>
  80198c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	bf 00 00 00 00       	mov    $0x0,%edi
  801996:	eb 4b                	jmp    8019e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801998:	89 da                	mov    %ebx,%edx
  80199a:	89 f0                	mov    %esi,%eax
  80199c:	e8 64 ff ff ff       	call   801905 <_pipeisclosed>
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	75 48                	jne    8019ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019a5:	e8 42 f1 ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ad:	8b 0b                	mov    (%ebx),%ecx
  8019af:	8d 51 20             	lea    0x20(%ecx),%edx
  8019b2:	39 d0                	cmp    %edx,%eax
  8019b4:	73 e2                	jae    801998 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	c1 fa 1f             	sar    $0x1f,%edx
  8019c5:	89 d1                	mov    %edx,%ecx
  8019c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8019ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019cd:	83 e2 1f             	and    $0x1f,%edx
  8019d0:	29 ca                	sub    %ecx,%edx
  8019d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019da:	83 c0 01             	add    $0x1,%eax
  8019dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e0:	83 c7 01             	add    $0x1,%edi
  8019e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019e6:	75 c2                	jne    8019aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019eb:	eb 05                	jmp    8019f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	57                   	push   %edi
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 18             	sub    $0x18,%esp
  801a03:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a06:	57                   	push   %edi
  801a07:	e8 7a f6 ff ff       	call   801086 <fd2data>
  801a0c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a16:	eb 3d                	jmp    801a55 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a18:	85 db                	test   %ebx,%ebx
  801a1a:	74 04                	je     801a20 <devpipe_read+0x26>
				return i;
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	eb 44                	jmp    801a64 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a20:	89 f2                	mov    %esi,%edx
  801a22:	89 f8                	mov    %edi,%eax
  801a24:	e8 dc fe ff ff       	call   801905 <_pipeisclosed>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	75 32                	jne    801a5f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a2d:	e8 ba f0 ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a32:	8b 06                	mov    (%esi),%eax
  801a34:	3b 46 04             	cmp    0x4(%esi),%eax
  801a37:	74 df                	je     801a18 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a39:	99                   	cltd   
  801a3a:	c1 ea 1b             	shr    $0x1b,%edx
  801a3d:	01 d0                	add    %edx,%eax
  801a3f:	83 e0 1f             	and    $0x1f,%eax
  801a42:	29 d0                	sub    %edx,%eax
  801a44:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a4f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a52:	83 c3 01             	add    $0x1,%ebx
  801a55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a58:	75 d8                	jne    801a32 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5d:	eb 05                	jmp    801a64 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	e8 20 f6 ff ff       	call   80109d <fd_alloc>
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	89 c2                	mov    %eax,%edx
  801a82:	85 c0                	test   %eax,%eax
  801a84:	0f 88 2c 01 00 00    	js     801bb6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8a:	83 ec 04             	sub    $0x4,%esp
  801a8d:	68 07 04 00 00       	push   $0x407
  801a92:	ff 75 f4             	pushl  -0xc(%ebp)
  801a95:	6a 00                	push   $0x0
  801a97:	e8 6f f0 ff ff       	call   800b0b <sys_page_alloc>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	89 c2                	mov    %eax,%edx
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	0f 88 0d 01 00 00    	js     801bb6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	e8 e8 f5 ff ff       	call   80109d <fd_alloc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	0f 88 e2 00 00 00    	js     801ba4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	68 07 04 00 00       	push   $0x407
  801aca:	ff 75 f0             	pushl  -0x10(%ebp)
  801acd:	6a 00                	push   $0x0
  801acf:	e8 37 f0 ff ff       	call   800b0b <sys_page_alloc>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	0f 88 c3 00 00 00    	js     801ba4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	e8 9a f5 ff ff       	call   801086 <fd2data>
  801aec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aee:	83 c4 0c             	add    $0xc,%esp
  801af1:	68 07 04 00 00       	push   $0x407
  801af6:	50                   	push   %eax
  801af7:	6a 00                	push   $0x0
  801af9:	e8 0d f0 ff ff       	call   800b0b <sys_page_alloc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 89 00 00 00    	js     801b94 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b11:	e8 70 f5 ff ff       	call   801086 <fd2data>
  801b16:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b1d:	50                   	push   %eax
  801b1e:	6a 00                	push   $0x0
  801b20:	56                   	push   %esi
  801b21:	6a 00                	push   $0x0
  801b23:	e8 26 f0 ff ff       	call   800b4e <sys_page_map>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	83 c4 20             	add    $0x20,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 55                	js     801b86 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b46:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b54:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b61:	e8 10 f5 ff ff       	call   801076 <fd2num>
  801b66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b69:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b6b:	83 c4 04             	add    $0x4,%esp
  801b6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b71:	e8 00 f5 ff ff       	call   801076 <fd2num>
  801b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b79:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b84:	eb 30                	jmp    801bb6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	56                   	push   %esi
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 ff ef ff ff       	call   800b90 <sys_page_unmap>
  801b91:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b94:	83 ec 08             	sub    $0x8,%esp
  801b97:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 ef ef ff ff       	call   800b90 <sys_page_unmap>
  801ba1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ba4:	83 ec 08             	sub    $0x8,%esp
  801ba7:	ff 75 f4             	pushl  -0xc(%ebp)
  801baa:	6a 00                	push   $0x0
  801bac:	e8 df ef ff ff       	call   800b90 <sys_page_unmap>
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bb6:	89 d0                	mov    %edx,%eax
  801bb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc8:	50                   	push   %eax
  801bc9:	ff 75 08             	pushl  0x8(%ebp)
  801bcc:	e8 1b f5 ff ff       	call   8010ec <fd_lookup>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 18                	js     801bf0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bde:	e8 a3 f4 ff ff       	call   801086 <fd2data>
	return _pipeisclosed(fd, p);
  801be3:	89 c2                	mov    %eax,%edx
  801be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be8:	e8 18 fd ff ff       	call   801905 <_pipeisclosed>
  801bed:	83 c4 10             	add    $0x10,%esp
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c02:	68 06 27 80 00       	push   $0x802706
  801c07:	ff 75 0c             	pushl  0xc(%ebp)
  801c0a:	e8 f9 ea ff ff       	call   800708 <strcpy>
	return 0;
}
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	57                   	push   %edi
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2d:	eb 2d                	jmp    801c5c <devcons_write+0x46>
		m = n - tot;
  801c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	53                   	push   %ebx
  801c43:	03 45 0c             	add    0xc(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	57                   	push   %edi
  801c48:	e8 4d ec ff ff       	call   80089a <memmove>
		sys_cputs(buf, m);
  801c4d:	83 c4 08             	add    $0x8,%esp
  801c50:	53                   	push   %ebx
  801c51:	57                   	push   %edi
  801c52:	e8 f8 ed ff ff       	call   800a4f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c57:	01 de                	add    %ebx,%esi
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	89 f0                	mov    %esi,%eax
  801c5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c61:	72 cc                	jb     801c2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5f                   	pop    %edi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c7a:	74 2a                	je     801ca6 <devcons_read+0x3b>
  801c7c:	eb 05                	jmp    801c83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c7e:	e8 69 ee ff ff       	call   800aec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c83:	e8 e5 ed ff ff       	call   800a6d <sys_cgetc>
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	74 f2                	je     801c7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 16                	js     801ca6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c90:	83 f8 04             	cmp    $0x4,%eax
  801c93:	74 0c                	je     801ca1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c98:	88 02                	mov    %al,(%edx)
	return 1;
  801c9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9f:	eb 05                	jmp    801ca6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cb4:	6a 01                	push   $0x1
  801cb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	e8 90 ed ff ff       	call   800a4f <sys_cputs>
}
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <getchar>:

int
getchar(void)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cca:	6a 01                	push   $0x1
  801ccc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 7e f6 ff ff       	call   801355 <read>
	if (r < 0)
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 0f                	js     801ced <getchar+0x29>
		return r;
	if (r < 1)
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	7e 06                	jle    801ce8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ce2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ce6:	eb 05                	jmp    801ced <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ce8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf8:	50                   	push   %eax
  801cf9:	ff 75 08             	pushl  0x8(%ebp)
  801cfc:	e8 eb f3 ff ff       	call   8010ec <fd_lookup>
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 11                	js     801d19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d11:	39 10                	cmp    %edx,(%eax)
  801d13:	0f 94 c0             	sete   %al
  801d16:	0f b6 c0             	movzbl %al,%eax
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <opencons>:

int
opencons(void)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	e8 73 f3 ff ff       	call   80109d <fd_alloc>
  801d2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 3e                	js     801d71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	68 07 04 00 00       	push   $0x407
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 c6 ed ff ff       	call   800b0b <sys_page_alloc>
  801d45:	83 c4 10             	add    $0x10,%esp
		return r;
  801d48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 23                	js     801d71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	50                   	push   %eax
  801d67:	e8 0a f3 ff ff       	call   801076 <fd2num>
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	83 c4 10             	add    $0x10,%esp
}
  801d71:	89 d0                	mov    %edx,%eax
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d7a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d7d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d83:	e8 45 ed ff ff       	call   800acd <sys_getenvid>
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	ff 75 0c             	pushl  0xc(%ebp)
  801d8e:	ff 75 08             	pushl  0x8(%ebp)
  801d91:	56                   	push   %esi
  801d92:	50                   	push   %eax
  801d93:	68 14 27 80 00       	push   $0x802714
  801d98:	e8 e6 e3 ff ff       	call   800183 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d9d:	83 c4 18             	add    $0x18,%esp
  801da0:	53                   	push   %ebx
  801da1:	ff 75 10             	pushl  0x10(%ebp)
  801da4:	e8 89 e3 ff ff       	call   800132 <vcprintf>
	cprintf("\n");
  801da9:	c7 04 24 ff 26 80 00 	movl   $0x8026ff,(%esp)
  801db0:	e8 ce e3 ff ff       	call   800183 <cprintf>
  801db5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801db8:	cc                   	int3   
  801db9:	eb fd                	jmp    801db8 <_panic+0x43>

00801dbb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dc1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc8:	75 2a                	jne    801df4 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dca:	83 ec 04             	sub    $0x4,%esp
  801dcd:	6a 07                	push   $0x7
  801dcf:	68 00 f0 bf ee       	push   $0xeebff000
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 30 ed ff ff       	call   800b0b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	79 12                	jns    801df4 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801de2:	50                   	push   %eax
  801de3:	68 38 27 80 00       	push   $0x802738
  801de8:	6a 23                	push   $0x23
  801dea:	68 3c 27 80 00       	push   $0x80273c
  801def:	e8 81 ff ff ff       	call   801d75 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	68 26 1e 80 00       	push   $0x801e26
  801e04:	6a 00                	push   $0x0
  801e06:	e8 4b ee ff ff       	call   800c56 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	79 12                	jns    801e24 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e12:	50                   	push   %eax
  801e13:	68 38 27 80 00       	push   $0x802738
  801e18:	6a 2c                	push   $0x2c
  801e1a:	68 3c 27 80 00       	push   $0x80273c
  801e1f:	e8 51 ff ff ff       	call   801d75 <_panic>
	}
}
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e26:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e27:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e2c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e2e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e31:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e35:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e3a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e3e:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e40:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e43:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e44:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e47:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e48:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e49:	c3                   	ret    

00801e4a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	56                   	push   %esi
  801e4e:	53                   	push   %ebx
  801e4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	75 12                	jne    801e6e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	68 00 00 c0 ee       	push   $0xeec00000
  801e64:	e8 52 ee ff ff       	call   800cbb <sys_ipc_recv>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	eb 0c                	jmp    801e7a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	50                   	push   %eax
  801e72:	e8 44 ee ff ff       	call   800cbb <sys_ipc_recv>
  801e77:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e7a:	85 f6                	test   %esi,%esi
  801e7c:	0f 95 c1             	setne  %cl
  801e7f:	85 db                	test   %ebx,%ebx
  801e81:	0f 95 c2             	setne  %dl
  801e84:	84 d1                	test   %dl,%cl
  801e86:	74 09                	je     801e91 <ipc_recv+0x47>
  801e88:	89 c2                	mov    %eax,%edx
  801e8a:	c1 ea 1f             	shr    $0x1f,%edx
  801e8d:	84 d2                	test   %dl,%dl
  801e8f:	75 2d                	jne    801ebe <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e91:	85 f6                	test   %esi,%esi
  801e93:	74 0d                	je     801ea2 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e95:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9a:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801ea0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ea2:	85 db                	test   %ebx,%ebx
  801ea4:	74 0d                	je     801eb3 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ea6:	a1 04 40 80 00       	mov    0x804004,%eax
  801eab:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801eb1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb8:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	57                   	push   %edi
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 0c             	sub    $0xc,%esp
  801ece:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ed7:	85 db                	test   %ebx,%ebx
  801ed9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ede:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ee1:	ff 75 14             	pushl  0x14(%ebp)
  801ee4:	53                   	push   %ebx
  801ee5:	56                   	push   %esi
  801ee6:	57                   	push   %edi
  801ee7:	e8 ac ed ff ff       	call   800c98 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	c1 ea 1f             	shr    $0x1f,%edx
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	84 d2                	test   %dl,%dl
  801ef6:	74 17                	je     801f0f <ipc_send+0x4a>
  801ef8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efb:	74 12                	je     801f0f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801efd:	50                   	push   %eax
  801efe:	68 4a 27 80 00       	push   $0x80274a
  801f03:	6a 47                	push   $0x47
  801f05:	68 58 27 80 00       	push   $0x802758
  801f0a:	e8 66 fe ff ff       	call   801d75 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f12:	75 07                	jne    801f1b <ipc_send+0x56>
			sys_yield();
  801f14:	e8 d3 eb ff ff       	call   800aec <sys_yield>
  801f19:	eb c6                	jmp    801ee1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	75 c2                	jne    801ee1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f32:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f38:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f3e:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f44:	39 ca                	cmp    %ecx,%edx
  801f46:	75 13                	jne    801f5b <ipc_find_env+0x34>
			return envs[i].env_id;
  801f48:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f4e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f53:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f59:	eb 0f                	jmp    801f6a <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f5b:	83 c0 01             	add    $0x1,%eax
  801f5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f63:	75 cd                	jne    801f32 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f72:	89 d0                	mov    %edx,%eax
  801f74:	c1 e8 16             	shr    $0x16,%eax
  801f77:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f83:	f6 c1 01             	test   $0x1,%cl
  801f86:	74 1d                	je     801fa5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f88:	c1 ea 0c             	shr    $0xc,%edx
  801f8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f92:	f6 c2 01             	test   $0x1,%dl
  801f95:	74 0e                	je     801fa5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f97:	c1 ea 0c             	shr    $0xc,%edx
  801f9a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa1:	ef 
  801fa2:	0f b7 c0             	movzwl %ax,%eax
}
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    
  801fa7:	66 90                	xchg   %ax,%ax
  801fa9:	66 90                	xchg   %ax,%ax
  801fab:	66 90                	xchg   %ax,%ax
  801fad:	66 90                	xchg   %ax,%ax
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
