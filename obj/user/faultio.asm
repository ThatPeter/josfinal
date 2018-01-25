
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
  800043:	68 e0 21 80 00       	push   $0x8021e0
  800048:	e8 37 01 00 00       	call   800184 <cprintf>
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
  80005e:	68 ee 21 80 00       	push   $0x8021ee
  800063:	e8 1c 01 00 00       	call   800184 <cprintf>
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
  800078:	e8 51 0a 00 00       	call   800ace <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	89 c2                	mov    %eax,%edx
  800084:	c1 e2 07             	shl    $0x7,%edx
  800087:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80008e:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 db                	test   %ebx,%ebx
  800095:	7e 07                	jle    80009e <libmain+0x31>
		binaryname = argv[0];
  800097:	8b 06                	mov    (%esi),%eax
  800099:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 2a 00 00 00       	call   8000d7 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000bd:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000c2:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000c4:	e8 05 0a 00 00       	call   800ace <sys_getenvid>
  8000c9:	83 ec 0c             	sub    $0xc,%esp
  8000cc:	50                   	push   %eax
  8000cd:	e8 4b 0c 00 00       	call   800d1d <sys_thread_free>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	c9                   	leave  
  8000d6:	c3                   	ret    

008000d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000dd:	e8 18 11 00 00       	call   8011fa <close_all>
	sys_env_destroy(0);
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	6a 00                	push   $0x0
  8000e7:	e8 a1 09 00 00       	call   800a8d <sys_env_destroy>
}
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    

008000f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	53                   	push   %ebx
  8000f5:	83 ec 04             	sub    $0x4,%esp
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fb:	8b 13                	mov    (%ebx),%edx
  8000fd:	8d 42 01             	lea    0x1(%edx),%eax
  800100:	89 03                	mov    %eax,(%ebx)
  800102:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800105:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800109:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010e:	75 1a                	jne    80012a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	68 ff 00 00 00       	push   $0xff
  800118:	8d 43 08             	lea    0x8(%ebx),%eax
  80011b:	50                   	push   %eax
  80011c:	e8 2f 09 00 00       	call   800a50 <sys_cputs>
		b->idx = 0;
  800121:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800127:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800143:	00 00 00 
	b.cnt = 0;
  800146:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800150:	ff 75 0c             	pushl  0xc(%ebp)
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015c:	50                   	push   %eax
  80015d:	68 f1 00 80 00       	push   $0x8000f1
  800162:	e8 54 01 00 00       	call   8002bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800167:	83 c4 08             	add    $0x8,%esp
  80016a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800170:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800176:	50                   	push   %eax
  800177:	e8 d4 08 00 00       	call   800a50 <sys_cputs>

	return b.cnt;
}
  80017c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018d:	50                   	push   %eax
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	e8 9d ff ff ff       	call   800133 <vcprintf>
	va_end(ap);

	return cnt;
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 1c             	sub    $0x1c,%esp
  8001a1:	89 c7                	mov    %eax,%edi
  8001a3:	89 d6                	mov    %edx,%esi
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001bf:	39 d3                	cmp    %edx,%ebx
  8001c1:	72 05                	jb     8001c8 <printnum+0x30>
  8001c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c6:	77 45                	ja     80020d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	ff 75 18             	pushl  0x18(%ebp)
  8001ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d4:	53                   	push   %ebx
  8001d5:	ff 75 10             	pushl  0x10(%ebp)
  8001d8:	83 ec 08             	sub    $0x8,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 64 1d 00 00       	call   801f50 <__udivdi3>
  8001ec:	83 c4 18             	add    $0x18,%esp
  8001ef:	52                   	push   %edx
  8001f0:	50                   	push   %eax
  8001f1:	89 f2                	mov    %esi,%edx
  8001f3:	89 f8                	mov    %edi,%eax
  8001f5:	e8 9e ff ff ff       	call   800198 <printnum>
  8001fa:	83 c4 20             	add    $0x20,%esp
  8001fd:	eb 18                	jmp    800217 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	ff 75 18             	pushl  0x18(%ebp)
  800206:	ff d7                	call   *%edi
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	eb 03                	jmp    800210 <printnum+0x78>
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800210:	83 eb 01             	sub    $0x1,%ebx
  800213:	85 db                	test   %ebx,%ebx
  800215:	7f e8                	jg     8001ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	56                   	push   %esi
  80021b:	83 ec 04             	sub    $0x4,%esp
  80021e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800221:	ff 75 e0             	pushl  -0x20(%ebp)
  800224:	ff 75 dc             	pushl  -0x24(%ebp)
  800227:	ff 75 d8             	pushl  -0x28(%ebp)
  80022a:	e8 51 1e 00 00       	call   802080 <__umoddi3>
  80022f:	83 c4 14             	add    $0x14,%esp
  800232:	0f be 80 12 22 80 00 	movsbl 0x802212(%eax),%eax
  800239:	50                   	push   %eax
  80023a:	ff d7                	call   *%edi
}
  80023c:	83 c4 10             	add    $0x10,%esp
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024a:	83 fa 01             	cmp    $0x1,%edx
  80024d:	7e 0e                	jle    80025d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024f:	8b 10                	mov    (%eax),%edx
  800251:	8d 4a 08             	lea    0x8(%edx),%ecx
  800254:	89 08                	mov    %ecx,(%eax)
  800256:	8b 02                	mov    (%edx),%eax
  800258:	8b 52 04             	mov    0x4(%edx),%edx
  80025b:	eb 22                	jmp    80027f <getuint+0x38>
	else if (lflag)
  80025d:	85 d2                	test   %edx,%edx
  80025f:	74 10                	je     800271 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 04             	lea    0x4(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	ba 00 00 00 00       	mov    $0x0,%edx
  80026f:	eb 0e                	jmp    80027f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800287:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	3b 50 04             	cmp    0x4(%eax),%edx
  800290:	73 0a                	jae    80029c <sprintputch+0x1b>
		*b->buf++ = ch;
  800292:	8d 4a 01             	lea    0x1(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	88 02                	mov    %al,(%edx)
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a7:	50                   	push   %eax
  8002a8:	ff 75 10             	pushl  0x10(%ebp)
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	e8 05 00 00 00       	call   8002bb <vprintfmt>
	va_end(ap);
}
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 2c             	sub    $0x2c,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cd:	eb 12                	jmp    8002e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	0f 84 89 03 00 00    	je     800660 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002d7:	83 ec 08             	sub    $0x8,%esp
  8002da:	53                   	push   %ebx
  8002db:	50                   	push   %eax
  8002dc:	ff d6                	call   *%esi
  8002de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e1:	83 c7 01             	add    $0x1,%edi
  8002e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e8:	83 f8 25             	cmp    $0x25,%eax
  8002eb:	75 e2                	jne    8002cf <vprintfmt+0x14>
  8002ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
  80030b:	eb 07                	jmp    800314 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800310:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8d 47 01             	lea    0x1(%edi),%eax
  800317:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031a:	0f b6 07             	movzbl (%edi),%eax
  80031d:	0f b6 c8             	movzbl %al,%ecx
  800320:	83 e8 23             	sub    $0x23,%eax
  800323:	3c 55                	cmp    $0x55,%al
  800325:	0f 87 1a 03 00 00    	ja     800645 <vprintfmt+0x38a>
  80032b:	0f b6 c0             	movzbl %al,%eax
  80032e:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800338:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033c:	eb d6                	jmp    800314 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800341:	b8 00 00 00 00       	mov    $0x0,%eax
  800346:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800349:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800350:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800353:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800356:	83 fa 09             	cmp    $0x9,%edx
  800359:	77 39                	ja     800394 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035e:	eb e9                	jmp    800349 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 48 04             	lea    0x4(%eax),%ecx
  800366:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800369:	8b 00                	mov    (%eax),%eax
  80036b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800371:	eb 27                	jmp    80039a <vprintfmt+0xdf>
  800373:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800376:	85 c0                	test   %eax,%eax
  800378:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037d:	0f 49 c8             	cmovns %eax,%ecx
  800380:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	eb 8c                	jmp    800314 <vprintfmt+0x59>
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800392:	eb 80                	jmp    800314 <vprintfmt+0x59>
  800394:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800397:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039e:	0f 89 70 ff ff ff    	jns    800314 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b1:	e9 5e ff ff ff       	jmp    800314 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bc:	e9 53 ff ff ff       	jmp    800314 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	ff 30                	pushl  (%eax)
  8003d0:	ff d6                	call   *%esi
			break;
  8003d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d8:	e9 04 ff ff ff       	jmp    8002e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	8b 00                	mov    (%eax),%eax
  8003e8:	99                   	cltd   
  8003e9:	31 d0                	xor    %edx,%eax
  8003eb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ed:	83 f8 0f             	cmp    $0xf,%eax
  8003f0:	7f 0b                	jg     8003fd <vprintfmt+0x142>
  8003f2:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  8003f9:	85 d2                	test   %edx,%edx
  8003fb:	75 18                	jne    800415 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fd:	50                   	push   %eax
  8003fe:	68 2a 22 80 00       	push   $0x80222a
  800403:	53                   	push   %ebx
  800404:	56                   	push   %esi
  800405:	e8 94 fe ff ff       	call   80029e <printfmt>
  80040a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800410:	e9 cc fe ff ff       	jmp    8002e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800415:	52                   	push   %edx
  800416:	68 6d 26 80 00       	push   $0x80266d
  80041b:	53                   	push   %ebx
  80041c:	56                   	push   %esi
  80041d:	e8 7c fe ff ff       	call   80029e <printfmt>
  800422:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	e9 b4 fe ff ff       	jmp    8002e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800438:	85 ff                	test   %edi,%edi
  80043a:	b8 23 22 80 00       	mov    $0x802223,%eax
  80043f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800442:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800446:	0f 8e 94 00 00 00    	jle    8004e0 <vprintfmt+0x225>
  80044c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800450:	0f 84 98 00 00 00    	je     8004ee <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 d0             	pushl  -0x30(%ebp)
  80045c:	57                   	push   %edi
  80045d:	e8 86 02 00 00       	call   8006e8 <strnlen>
  800462:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800477:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	eb 0f                	jmp    80048a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	ff 75 e0             	pushl  -0x20(%ebp)
  800482:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	83 ef 01             	sub    $0x1,%edi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 ff                	test   %edi,%edi
  80048c:	7f ed                	jg     80047b <vprintfmt+0x1c0>
  80048e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800491:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800494:	85 c9                	test   %ecx,%ecx
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	0f 49 c1             	cmovns %ecx,%eax
  80049e:	29 c1                	sub    %eax,%ecx
  8004a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a9:	89 cb                	mov    %ecx,%ebx
  8004ab:	eb 4d                	jmp    8004fa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b1:	74 1b                	je     8004ce <vprintfmt+0x213>
  8004b3:	0f be c0             	movsbl %al,%eax
  8004b6:	83 e8 20             	sub    $0x20,%eax
  8004b9:	83 f8 5e             	cmp    $0x5e,%eax
  8004bc:	76 10                	jbe    8004ce <vprintfmt+0x213>
					putch('?', putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	ff 75 0c             	pushl  0xc(%ebp)
  8004c4:	6a 3f                	push   $0x3f
  8004c6:	ff 55 08             	call   *0x8(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	eb 0d                	jmp    8004db <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	52                   	push   %edx
  8004d5:	ff 55 08             	call   *0x8(%ebp)
  8004d8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004db:	83 eb 01             	sub    $0x1,%ebx
  8004de:	eb 1a                	jmp    8004fa <vprintfmt+0x23f>
  8004e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ec:	eb 0c                	jmp    8004fa <vprintfmt+0x23f>
  8004ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fa:	83 c7 01             	add    $0x1,%edi
  8004fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800501:	0f be d0             	movsbl %al,%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	74 23                	je     80052b <vprintfmt+0x270>
  800508:	85 f6                	test   %esi,%esi
  80050a:	78 a1                	js     8004ad <vprintfmt+0x1f2>
  80050c:	83 ee 01             	sub    $0x1,%esi
  80050f:	79 9c                	jns    8004ad <vprintfmt+0x1f2>
  800511:	89 df                	mov    %ebx,%edi
  800513:	8b 75 08             	mov    0x8(%ebp),%esi
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800519:	eb 18                	jmp    800533 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	6a 20                	push   $0x20
  800521:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800523:	83 ef 01             	sub    $0x1,%edi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	eb 08                	jmp    800533 <vprintfmt+0x278>
  80052b:	89 df                	mov    %ebx,%edi
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800533:	85 ff                	test   %edi,%edi
  800535:	7f e4                	jg     80051b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053a:	e9 a2 fd ff ff       	jmp    8002e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053f:	83 fa 01             	cmp    $0x1,%edx
  800542:	7e 16                	jle    80055a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 08             	lea    0x8(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 50 04             	mov    0x4(%eax),%edx
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800555:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800558:	eb 32                	jmp    80058c <vprintfmt+0x2d1>
	else if (lflag)
  80055a:	85 d2                	test   %edx,%edx
  80055c:	74 18                	je     800576 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 c1                	mov    %eax,%ecx
  80056e:	c1 f9 1f             	sar    $0x1f,%ecx
  800571:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800574:	eb 16                	jmp    80058c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 c1                	mov    %eax,%ecx
  800586:	c1 f9 1f             	sar    $0x1f,%ecx
  800589:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800592:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800597:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059b:	79 74                	jns    800611 <vprintfmt+0x356>
				putch('-', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 2d                	push   $0x2d
  8005a3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ab:	f7 d8                	neg    %eax
  8005ad:	83 d2 00             	adc    $0x0,%edx
  8005b0:	f7 da                	neg    %edx
  8005b2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ba:	eb 55                	jmp    800611 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bf:	e8 83 fc ff ff       	call   800247 <getuint>
			base = 10;
  8005c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005c9:	eb 46                	jmp    800611 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 74 fc ff ff       	call   800247 <getuint>
			base = 8;
  8005d3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005d8:	eb 37                	jmp    800611 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	6a 30                	push   $0x30
  8005e0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e2:	83 c4 08             	add    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	6a 78                	push   $0x78
  8005e8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800602:	eb 0d                	jmp    800611 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
  800607:	e8 3b fc ff ff       	call   800247 <getuint>
			base = 16;
  80060c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800618:	57                   	push   %edi
  800619:	ff 75 e0             	pushl  -0x20(%ebp)
  80061c:	51                   	push   %ecx
  80061d:	52                   	push   %edx
  80061e:	50                   	push   %eax
  80061f:	89 da                	mov    %ebx,%edx
  800621:	89 f0                	mov    %esi,%eax
  800623:	e8 70 fb ff ff       	call   800198 <printnum>
			break;
  800628:	83 c4 20             	add    $0x20,%esp
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062e:	e9 ae fc ff ff       	jmp    8002e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	51                   	push   %ecx
  800638:	ff d6                	call   *%esi
			break;
  80063a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800640:	e9 9c fc ff ff       	jmp    8002e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 25                	push   $0x25
  80064b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064d:	83 c4 10             	add    $0x10,%esp
  800650:	eb 03                	jmp    800655 <vprintfmt+0x39a>
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800659:	75 f7                	jne    800652 <vprintfmt+0x397>
  80065b:	e9 81 fc ff ff       	jmp    8002e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800660:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800663:	5b                   	pop    %ebx
  800664:	5e                   	pop    %esi
  800665:	5f                   	pop    %edi
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	83 ec 18             	sub    $0x18,%esp
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800674:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800677:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800685:	85 c0                	test   %eax,%eax
  800687:	74 26                	je     8006af <vsnprintf+0x47>
  800689:	85 d2                	test   %edx,%edx
  80068b:	7e 22                	jle    8006af <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068d:	ff 75 14             	pushl  0x14(%ebp)
  800690:	ff 75 10             	pushl  0x10(%ebp)
  800693:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	68 81 02 80 00       	push   $0x800281
  80069c:	e8 1a fc ff ff       	call   8002bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb 05                	jmp    8006b4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    

008006b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006bf:	50                   	push   %eax
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	ff 75 0c             	pushl  0xc(%ebp)
  8006c6:	ff 75 08             	pushl  0x8(%ebp)
  8006c9:	e8 9a ff ff ff       	call   800668 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006db:	eb 03                	jmp    8006e0 <strlen+0x10>
		n++;
  8006dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e4:	75 f7                	jne    8006dd <strlen+0xd>
		n++;
	return n;
}
  8006e6:	5d                   	pop    %ebp
  8006e7:	c3                   	ret    

008006e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f6:	eb 03                	jmp    8006fb <strnlen+0x13>
		n++;
  8006f8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	39 c2                	cmp    %eax,%edx
  8006fd:	74 08                	je     800707 <strnlen+0x1f>
  8006ff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800703:	75 f3                	jne    8006f8 <strnlen+0x10>
  800705:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800713:	89 c2                	mov    %eax,%edx
  800715:	83 c2 01             	add    $0x1,%edx
  800718:	83 c1 01             	add    $0x1,%ecx
  80071b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80071f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800722:	84 db                	test   %bl,%bl
  800724:	75 ef                	jne    800715 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800726:	5b                   	pop    %ebx
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	53                   	push   %ebx
  80072d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800730:	53                   	push   %ebx
  800731:	e8 9a ff ff ff       	call   8006d0 <strlen>
  800736:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	01 d8                	add    %ebx,%eax
  80073e:	50                   	push   %eax
  80073f:	e8 c5 ff ff ff       	call   800709 <strcpy>
	return dst;
}
  800744:	89 d8                	mov    %ebx,%eax
  800746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	56                   	push   %esi
  80074f:	53                   	push   %ebx
  800750:	8b 75 08             	mov    0x8(%ebp),%esi
  800753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800756:	89 f3                	mov    %esi,%ebx
  800758:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075b:	89 f2                	mov    %esi,%edx
  80075d:	eb 0f                	jmp    80076e <strncpy+0x23>
		*dst++ = *src;
  80075f:	83 c2 01             	add    $0x1,%edx
  800762:	0f b6 01             	movzbl (%ecx),%eax
  800765:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800768:	80 39 01             	cmpb   $0x1,(%ecx)
  80076b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076e:	39 da                	cmp    %ebx,%edx
  800770:	75 ed                	jne    80075f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800772:	89 f0                	mov    %esi,%eax
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	8b 55 10             	mov    0x10(%ebp),%edx
  800786:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800788:	85 d2                	test   %edx,%edx
  80078a:	74 21                	je     8007ad <strlcpy+0x35>
  80078c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800790:	89 f2                	mov    %esi,%edx
  800792:	eb 09                	jmp    80079d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800794:	83 c2 01             	add    $0x1,%edx
  800797:	83 c1 01             	add    $0x1,%ecx
  80079a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 09                	je     8007aa <strlcpy+0x32>
  8007a1:	0f b6 19             	movzbl (%ecx),%ebx
  8007a4:	84 db                	test   %bl,%bl
  8007a6:	75 ec                	jne    800794 <strlcpy+0x1c>
  8007a8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007aa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ad:	29 f0                	sub    %esi,%eax
}
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bc:	eb 06                	jmp    8007c4 <strcmp+0x11>
		p++, q++;
  8007be:	83 c1 01             	add    $0x1,%ecx
  8007c1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c4:	0f b6 01             	movzbl (%ecx),%eax
  8007c7:	84 c0                	test   %al,%al
  8007c9:	74 04                	je     8007cf <strcmp+0x1c>
  8007cb:	3a 02                	cmp    (%edx),%al
  8007cd:	74 ef                	je     8007be <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cf:	0f b6 c0             	movzbl %al,%eax
  8007d2:	0f b6 12             	movzbl (%edx),%edx
  8007d5:	29 d0                	sub    %edx,%eax
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e3:	89 c3                	mov    %eax,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e8:	eb 06                	jmp    8007f0 <strncmp+0x17>
		n--, p++, q++;
  8007ea:	83 c0 01             	add    $0x1,%eax
  8007ed:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f0:	39 d8                	cmp    %ebx,%eax
  8007f2:	74 15                	je     800809 <strncmp+0x30>
  8007f4:	0f b6 08             	movzbl (%eax),%ecx
  8007f7:	84 c9                	test   %cl,%cl
  8007f9:	74 04                	je     8007ff <strncmp+0x26>
  8007fb:	3a 0a                	cmp    (%edx),%cl
  8007fd:	74 eb                	je     8007ea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 00             	movzbl (%eax),%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
  800807:	eb 05                	jmp    80080e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081b:	eb 07                	jmp    800824 <strchr+0x13>
		if (*s == c)
  80081d:	38 ca                	cmp    %cl,%dl
  80081f:	74 0f                	je     800830 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800821:	83 c0 01             	add    $0x1,%eax
  800824:	0f b6 10             	movzbl (%eax),%edx
  800827:	84 d2                	test   %dl,%dl
  800829:	75 f2                	jne    80081d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083c:	eb 03                	jmp    800841 <strfind+0xf>
  80083e:	83 c0 01             	add    $0x1,%eax
  800841:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	74 04                	je     80084c <strfind+0x1a>
  800848:	84 d2                	test   %dl,%dl
  80084a:	75 f2                	jne    80083e <strfind+0xc>
			break;
	return (char *) s;
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	57                   	push   %edi
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 7d 08             	mov    0x8(%ebp),%edi
  800857:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085a:	85 c9                	test   %ecx,%ecx
  80085c:	74 36                	je     800894 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800864:	75 28                	jne    80088e <memset+0x40>
  800866:	f6 c1 03             	test   $0x3,%cl
  800869:	75 23                	jne    80088e <memset+0x40>
		c &= 0xFF;
  80086b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086f:	89 d3                	mov    %edx,%ebx
  800871:	c1 e3 08             	shl    $0x8,%ebx
  800874:	89 d6                	mov    %edx,%esi
  800876:	c1 e6 18             	shl    $0x18,%esi
  800879:	89 d0                	mov    %edx,%eax
  80087b:	c1 e0 10             	shl    $0x10,%eax
  80087e:	09 f0                	or     %esi,%eax
  800880:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800882:	89 d8                	mov    %ebx,%eax
  800884:	09 d0                	or     %edx,%eax
  800886:	c1 e9 02             	shr    $0x2,%ecx
  800889:	fc                   	cld    
  80088a:	f3 ab                	rep stos %eax,%es:(%edi)
  80088c:	eb 06                	jmp    800894 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	fc                   	cld    
  800892:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800894:	89 f8                	mov    %edi,%eax
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5f                   	pop    %edi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	57                   	push   %edi
  80089f:	56                   	push   %esi
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a9:	39 c6                	cmp    %eax,%esi
  8008ab:	73 35                	jae    8008e2 <memmove+0x47>
  8008ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b0:	39 d0                	cmp    %edx,%eax
  8008b2:	73 2e                	jae    8008e2 <memmove+0x47>
		s += n;
		d += n;
  8008b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b7:	89 d6                	mov    %edx,%esi
  8008b9:	09 fe                	or     %edi,%esi
  8008bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c1:	75 13                	jne    8008d6 <memmove+0x3b>
  8008c3:	f6 c1 03             	test   $0x3,%cl
  8008c6:	75 0e                	jne    8008d6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c8:	83 ef 04             	sub    $0x4,%edi
  8008cb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ce:	c1 e9 02             	shr    $0x2,%ecx
  8008d1:	fd                   	std    
  8008d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d4:	eb 09                	jmp    8008df <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d6:	83 ef 01             	sub    $0x1,%edi
  8008d9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008dc:	fd                   	std    
  8008dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008df:	fc                   	cld    
  8008e0:	eb 1d                	jmp    8008ff <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	09 c2                	or     %eax,%edx
  8008e6:	f6 c2 03             	test   $0x3,%dl
  8008e9:	75 0f                	jne    8008fa <memmove+0x5f>
  8008eb:	f6 c1 03             	test   $0x3,%cl
  8008ee:	75 0a                	jne    8008fa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	89 c7                	mov    %eax,%edi
  8008f5:	fc                   	cld    
  8008f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f8:	eb 05                	jmp    8008ff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008fa:	89 c7                	mov    %eax,%edi
  8008fc:	fc                   	cld    
  8008fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ff:	5e                   	pop    %esi
  800900:	5f                   	pop    %edi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800906:	ff 75 10             	pushl  0x10(%ebp)
  800909:	ff 75 0c             	pushl  0xc(%ebp)
  80090c:	ff 75 08             	pushl  0x8(%ebp)
  80090f:	e8 87 ff ff ff       	call   80089b <memmove>
}
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 c6                	mov    %eax,%esi
  800923:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800926:	eb 1a                	jmp    800942 <memcmp+0x2c>
		if (*s1 != *s2)
  800928:	0f b6 08             	movzbl (%eax),%ecx
  80092b:	0f b6 1a             	movzbl (%edx),%ebx
  80092e:	38 d9                	cmp    %bl,%cl
  800930:	74 0a                	je     80093c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800932:	0f b6 c1             	movzbl %cl,%eax
  800935:	0f b6 db             	movzbl %bl,%ebx
  800938:	29 d8                	sub    %ebx,%eax
  80093a:	eb 0f                	jmp    80094b <memcmp+0x35>
		s1++, s2++;
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800942:	39 f0                	cmp    %esi,%eax
  800944:	75 e2                	jne    800928 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800956:	89 c1                	mov    %eax,%ecx
  800958:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095f:	eb 0a                	jmp    80096b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800961:	0f b6 10             	movzbl (%eax),%edx
  800964:	39 da                	cmp    %ebx,%edx
  800966:	74 07                	je     80096f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800968:	83 c0 01             	add    $0x1,%eax
  80096b:	39 c8                	cmp    %ecx,%eax
  80096d:	72 f2                	jb     800961 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096f:	5b                   	pop    %ebx
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	57                   	push   %edi
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097e:	eb 03                	jmp    800983 <strtol+0x11>
		s++;
  800980:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800983:	0f b6 01             	movzbl (%ecx),%eax
  800986:	3c 20                	cmp    $0x20,%al
  800988:	74 f6                	je     800980 <strtol+0xe>
  80098a:	3c 09                	cmp    $0x9,%al
  80098c:	74 f2                	je     800980 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098e:	3c 2b                	cmp    $0x2b,%al
  800990:	75 0a                	jne    80099c <strtol+0x2a>
		s++;
  800992:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800995:	bf 00 00 00 00       	mov    $0x0,%edi
  80099a:	eb 11                	jmp    8009ad <strtol+0x3b>
  80099c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a1:	3c 2d                	cmp    $0x2d,%al
  8009a3:	75 08                	jne    8009ad <strtol+0x3b>
		s++, neg = 1;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b3:	75 15                	jne    8009ca <strtol+0x58>
  8009b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b8:	75 10                	jne    8009ca <strtol+0x58>
  8009ba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009be:	75 7c                	jne    800a3c <strtol+0xca>
		s += 2, base = 16;
  8009c0:	83 c1 02             	add    $0x2,%ecx
  8009c3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c8:	eb 16                	jmp    8009e0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ca:	85 db                	test   %ebx,%ebx
  8009cc:	75 12                	jne    8009e0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d6:	75 08                	jne    8009e0 <strtol+0x6e>
		s++, base = 8;
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e8:	0f b6 11             	movzbl (%ecx),%edx
  8009eb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ee:	89 f3                	mov    %esi,%ebx
  8009f0:	80 fb 09             	cmp    $0x9,%bl
  8009f3:	77 08                	ja     8009fd <strtol+0x8b>
			dig = *s - '0';
  8009f5:	0f be d2             	movsbl %dl,%edx
  8009f8:	83 ea 30             	sub    $0x30,%edx
  8009fb:	eb 22                	jmp    800a1f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a00:	89 f3                	mov    %esi,%ebx
  800a02:	80 fb 19             	cmp    $0x19,%bl
  800a05:	77 08                	ja     800a0f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a07:	0f be d2             	movsbl %dl,%edx
  800a0a:	83 ea 57             	sub    $0x57,%edx
  800a0d:	eb 10                	jmp    800a1f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	80 fb 19             	cmp    $0x19,%bl
  800a17:	77 16                	ja     800a2f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a19:	0f be d2             	movsbl %dl,%edx
  800a1c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a22:	7d 0b                	jge    800a2f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2d:	eb b9                	jmp    8009e8 <strtol+0x76>

	if (endptr)
  800a2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a33:	74 0d                	je     800a42 <strtol+0xd0>
		*endptr = (char *) s;
  800a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a38:	89 0e                	mov    %ecx,(%esi)
  800a3a:	eb 06                	jmp    800a42 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	74 98                	je     8009d8 <strtol+0x66>
  800a40:	eb 9e                	jmp    8009e0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	f7 da                	neg    %edx
  800a46:	85 ff                	test   %edi,%edi
  800a48:	0f 45 c2             	cmovne %edx,%eax
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	89 c6                	mov    %eax,%esi
  800a67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
  800a79:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7e:	89 d1                	mov    %edx,%ecx
  800a80:	89 d3                	mov    %edx,%ebx
  800a82:	89 d7                	mov    %edx,%edi
  800a84:	89 d6                	mov    %edx,%esi
  800a86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa3:	89 cb                	mov    %ecx,%ebx
  800aa5:	89 cf                	mov    %ecx,%edi
  800aa7:	89 ce                	mov    %ecx,%esi
  800aa9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aab:	85 c0                	test   %eax,%eax
  800aad:	7e 17                	jle    800ac6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aaf:	83 ec 0c             	sub    $0xc,%esp
  800ab2:	50                   	push   %eax
  800ab3:	6a 03                	push   $0x3
  800ab5:	68 1f 25 80 00       	push   $0x80251f
  800aba:	6a 23                	push   $0x23
  800abc:	68 3c 25 80 00       	push   $0x80253c
  800ac1:	e8 53 12 00 00       	call   801d19 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad9:	b8 02 00 00 00       	mov    $0x2,%eax
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	89 d7                	mov    %edx,%edi
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_yield>:

void
sys_yield(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	be 00 00 00 00       	mov    $0x0,%esi
  800b1a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b28:	89 f7                	mov    %esi,%edi
  800b2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	7e 17                	jle    800b47 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	50                   	push   %eax
  800b34:	6a 04                	push   $0x4
  800b36:	68 1f 25 80 00       	push   $0x80251f
  800b3b:	6a 23                	push   $0x23
  800b3d:	68 3c 25 80 00       	push   $0x80253c
  800b42:	e8 d2 11 00 00       	call   801d19 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b69:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	7e 17                	jle    800b89 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	50                   	push   %eax
  800b76:	6a 05                	push   $0x5
  800b78:	68 1f 25 80 00       	push   $0x80251f
  800b7d:	6a 23                	push   $0x23
  800b7f:	68 3c 25 80 00       	push   $0x80253c
  800b84:	e8 90 11 00 00       	call   801d19 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9f:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	89 df                	mov    %ebx,%edi
  800bac:	89 de                	mov    %ebx,%esi
  800bae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7e 17                	jle    800bcb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 06                	push   $0x6
  800bba:	68 1f 25 80 00       	push   $0x80251f
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 3c 25 80 00       	push   $0x80253c
  800bc6:	e8 4e 11 00 00       	call   801d19 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be1:	b8 08 00 00 00       	mov    $0x8,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 df                	mov    %ebx,%edi
  800bee:	89 de                	mov    %ebx,%esi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7e 17                	jle    800c0d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 08                	push   $0x8
  800bfc:	68 1f 25 80 00       	push   $0x80251f
  800c01:	6a 23                	push   $0x23
  800c03:	68 3c 25 80 00       	push   $0x80253c
  800c08:	e8 0c 11 00 00       	call   801d19 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c23:	b8 09 00 00 00       	mov    $0x9,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 df                	mov    %ebx,%edi
  800c30:	89 de                	mov    %ebx,%esi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 09                	push   $0x9
  800c3e:	68 1f 25 80 00       	push   $0x80251f
  800c43:	6a 23                	push   $0x23
  800c45:	68 3c 25 80 00       	push   $0x80253c
  800c4a:	e8 ca 10 00 00       	call   801d19 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 0a                	push   $0xa
  800c80:	68 1f 25 80 00       	push   $0x80251f
  800c85:	6a 23                	push   $0x23
  800c87:	68 3c 25 80 00       	push   $0x80253c
  800c8c:	e8 88 10 00 00       	call   801d19 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cca:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 cb                	mov    %ecx,%ebx
  800cd4:	89 cf                	mov    %ecx,%edi
  800cd6:	89 ce                	mov    %ecx,%esi
  800cd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 0d                	push   $0xd
  800ce4:	68 1f 25 80 00       	push   $0x80251f
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 3c 25 80 00       	push   $0x80253c
  800cf0:	e8 24 10 00 00       	call   801d19 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d08:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 cb                	mov    %ecx,%ebx
  800d12:	89 cf                	mov    %ecx,%edi
  800d14:	89 ce                	mov    %ecx,%esi
  800d16:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d28:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 cb                	mov    %ecx,%ebx
  800d32:	89 cf                	mov    %ecx,%edi
  800d34:	89 ce                	mov    %ecx,%esi
  800d36:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	53                   	push   %ebx
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d47:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d49:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d4d:	74 11                	je     800d60 <pgfault+0x23>
  800d4f:	89 d8                	mov    %ebx,%eax
  800d51:	c1 e8 0c             	shr    $0xc,%eax
  800d54:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d5b:	f6 c4 08             	test   $0x8,%ah
  800d5e:	75 14                	jne    800d74 <pgfault+0x37>
		panic("faulting access");
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 4a 25 80 00       	push   $0x80254a
  800d68:	6a 1e                	push   $0x1e
  800d6a:	68 5a 25 80 00       	push   $0x80255a
  800d6f:	e8 a5 0f 00 00       	call   801d19 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	6a 07                	push   $0x7
  800d79:	68 00 f0 7f 00       	push   $0x7ff000
  800d7e:	6a 00                	push   $0x0
  800d80:	e8 87 fd ff ff       	call   800b0c <sys_page_alloc>
	if (r < 0) {
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	79 12                	jns    800d9e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d8c:	50                   	push   %eax
  800d8d:	68 65 25 80 00       	push   $0x802565
  800d92:	6a 2c                	push   $0x2c
  800d94:	68 5a 25 80 00       	push   $0x80255a
  800d99:	e8 7b 0f 00 00       	call   801d19 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	68 00 10 00 00       	push   $0x1000
  800dac:	53                   	push   %ebx
  800dad:	68 00 f0 7f 00       	push   $0x7ff000
  800db2:	e8 4c fb ff ff       	call   800903 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800db7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dbe:	53                   	push   %ebx
  800dbf:	6a 00                	push   $0x0
  800dc1:	68 00 f0 7f 00       	push   $0x7ff000
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 82 fd ff ff       	call   800b4f <sys_page_map>
	if (r < 0) {
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 12                	jns    800de6 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dd4:	50                   	push   %eax
  800dd5:	68 65 25 80 00       	push   $0x802565
  800dda:	6a 33                	push   $0x33
  800ddc:	68 5a 25 80 00       	push   $0x80255a
  800de1:	e8 33 0f 00 00       	call   801d19 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	68 00 f0 7f 00       	push   $0x7ff000
  800dee:	6a 00                	push   $0x0
  800df0:	e8 9c fd ff ff       	call   800b91 <sys_page_unmap>
	if (r < 0) {
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	79 12                	jns    800e0e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800dfc:	50                   	push   %eax
  800dfd:	68 65 25 80 00       	push   $0x802565
  800e02:	6a 37                	push   $0x37
  800e04:	68 5a 25 80 00       	push   $0x80255a
  800e09:	e8 0b 0f 00 00       	call   801d19 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e1c:	68 3d 0d 80 00       	push   $0x800d3d
  800e21:	e8 39 0f 00 00       	call   801d5f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e26:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2b:	cd 30                	int    $0x30
  800e2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 17                	jns    800e4e <fork+0x3b>
		panic("fork fault %e");
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	68 7e 25 80 00       	push   $0x80257e
  800e3f:	68 84 00 00 00       	push   $0x84
  800e44:	68 5a 25 80 00       	push   $0x80255a
  800e49:	e8 cb 0e 00 00       	call   801d19 <_panic>
  800e4e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e54:	75 25                	jne    800e7b <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e56:	e8 73 fc ff ff       	call   800ace <sys_getenvid>
  800e5b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e60:	89 c2                	mov    %eax,%edx
  800e62:	c1 e2 07             	shl    $0x7,%edx
  800e65:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800e6c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	e9 61 01 00 00       	jmp    800fdc <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	6a 07                	push   $0x7
  800e80:	68 00 f0 bf ee       	push   $0xeebff000
  800e85:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e88:	e8 7f fc ff ff       	call   800b0c <sys_page_alloc>
  800e8d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e90:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e95:	89 d8                	mov    %ebx,%eax
  800e97:	c1 e8 16             	shr    $0x16,%eax
  800e9a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea1:	a8 01                	test   $0x1,%al
  800ea3:	0f 84 fc 00 00 00    	je     800fa5 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ea9:	89 d8                	mov    %ebx,%eax
  800eab:	c1 e8 0c             	shr    $0xc,%eax
  800eae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	0f 84 e7 00 00 00    	je     800fa5 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ebe:	89 c6                	mov    %eax,%esi
  800ec0:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ec3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eca:	f6 c6 04             	test   $0x4,%dh
  800ecd:	74 39                	je     800f08 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ecf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	25 07 0e 00 00       	and    $0xe07,%eax
  800ede:	50                   	push   %eax
  800edf:	56                   	push   %esi
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 66 fc ff ff       	call   800b4f <sys_page_map>
		if (r < 0) {
  800ee9:	83 c4 20             	add    $0x20,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	0f 89 b1 00 00 00    	jns    800fa5 <fork+0x192>
		    	panic("sys page map fault %e");
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	68 8c 25 80 00       	push   $0x80258c
  800efc:	6a 54                	push   $0x54
  800efe:	68 5a 25 80 00       	push   $0x80255a
  800f03:	e8 11 0e 00 00       	call   801d19 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f08:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0f:	f6 c2 02             	test   $0x2,%dl
  800f12:	75 0c                	jne    800f20 <fork+0x10d>
  800f14:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1b:	f6 c4 08             	test   $0x8,%ah
  800f1e:	74 5b                	je     800f7b <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	68 05 08 00 00       	push   $0x805
  800f28:	56                   	push   %esi
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 1d fc ff ff       	call   800b4f <sys_page_map>
		if (r < 0) {
  800f32:	83 c4 20             	add    $0x20,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	79 14                	jns    800f4d <fork+0x13a>
		    	panic("sys page map fault %e");
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	68 8c 25 80 00       	push   $0x80258c
  800f41:	6a 5b                	push   $0x5b
  800f43:	68 5a 25 80 00       	push   $0x80255a
  800f48:	e8 cc 0d 00 00       	call   801d19 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	68 05 08 00 00       	push   $0x805
  800f55:	56                   	push   %esi
  800f56:	6a 00                	push   $0x0
  800f58:	56                   	push   %esi
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 ef fb ff ff       	call   800b4f <sys_page_map>
		if (r < 0) {
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 3e                	jns    800fa5 <fork+0x192>
		    	panic("sys page map fault %e");
  800f67:	83 ec 04             	sub    $0x4,%esp
  800f6a:	68 8c 25 80 00       	push   $0x80258c
  800f6f:	6a 5f                	push   $0x5f
  800f71:	68 5a 25 80 00       	push   $0x80255a
  800f76:	e8 9e 0d 00 00       	call   801d19 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	6a 05                	push   $0x5
  800f80:	56                   	push   %esi
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	6a 00                	push   $0x0
  800f85:	e8 c5 fb ff ff       	call   800b4f <sys_page_map>
		if (r < 0) {
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	79 14                	jns    800fa5 <fork+0x192>
		    	panic("sys page map fault %e");
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	68 8c 25 80 00       	push   $0x80258c
  800f99:	6a 64                	push   $0x64
  800f9b:	68 5a 25 80 00       	push   $0x80255a
  800fa0:	e8 74 0d 00 00       	call   801d19 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fa5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fab:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fb1:	0f 85 de fe ff ff    	jne    800e95 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fb7:	a1 04 40 80 00       	mov    0x804004,%eax
  800fbc:	8b 40 70             	mov    0x70(%eax),%eax
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	50                   	push   %eax
  800fc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fc6:	57                   	push   %edi
  800fc7:	e8 8b fc ff ff       	call   800c57 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fcc:	83 c4 08             	add    $0x8,%esp
  800fcf:	6a 02                	push   $0x2
  800fd1:	57                   	push   %edi
  800fd2:	e8 fc fb ff ff       	call   800bd3 <sys_env_set_status>
	
	return envid;
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sfork>:

envid_t
sfork(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
  800ff3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800ff6:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	53                   	push   %ebx
  801000:	68 a4 25 80 00       	push   $0x8025a4
  801005:	e8 7a f1 ff ff       	call   800184 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80100a:	c7 04 24 b7 00 80 00 	movl   $0x8000b7,(%esp)
  801011:	e8 e7 fc ff ff       	call   800cfd <sys_thread_create>
  801016:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801018:	83 c4 08             	add    $0x8,%esp
  80101b:	53                   	push   %ebx
  80101c:	68 a4 25 80 00       	push   $0x8025a4
  801021:	e8 5e f1 ff ff       	call   800184 <cprintf>
	return id;
	//return 0;
}
  801026:	89 f0                	mov    %esi,%eax
  801028:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	05 00 00 00 30       	add    $0x30000000,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
}
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	05 00 00 00 30       	add    $0x30000000,%eax
  80104a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80104f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801061:	89 c2                	mov    %eax,%edx
  801063:	c1 ea 16             	shr    $0x16,%edx
  801066:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106d:	f6 c2 01             	test   $0x1,%dl
  801070:	74 11                	je     801083 <fd_alloc+0x2d>
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 0c             	shr    $0xc,%edx
  801077:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	75 09                	jne    80108c <fd_alloc+0x36>
			*fd_store = fd;
  801083:	89 01                	mov    %eax,(%ecx)
			return 0;
  801085:	b8 00 00 00 00       	mov    $0x0,%eax
  80108a:	eb 17                	jmp    8010a3 <fd_alloc+0x4d>
  80108c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801091:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801096:	75 c9                	jne    801061 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801098:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ab:	83 f8 1f             	cmp    $0x1f,%eax
  8010ae:	77 36                	ja     8010e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b0:	c1 e0 0c             	shl    $0xc,%eax
  8010b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b8:	89 c2                	mov    %eax,%edx
  8010ba:	c1 ea 16             	shr    $0x16,%edx
  8010bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	74 24                	je     8010ed <fd_lookup+0x48>
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 ea 0c             	shr    $0xc,%edx
  8010ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	74 1a                	je     8010f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8010df:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e4:	eb 13                	jmp    8010f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010eb:	eb 0c                	jmp    8010f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f2:	eb 05                	jmp    8010f9 <fd_lookup+0x54>
  8010f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801104:	ba 44 26 80 00       	mov    $0x802644,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801109:	eb 13                	jmp    80111e <dev_lookup+0x23>
  80110b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80110e:	39 08                	cmp    %ecx,(%eax)
  801110:	75 0c                	jne    80111e <dev_lookup+0x23>
			*dev = devtab[i];
  801112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801115:	89 01                	mov    %eax,(%ecx)
			return 0;
  801117:	b8 00 00 00 00       	mov    $0x0,%eax
  80111c:	eb 2e                	jmp    80114c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111e:	8b 02                	mov    (%edx),%eax
  801120:	85 c0                	test   %eax,%eax
  801122:	75 e7                	jne    80110b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801124:	a1 04 40 80 00       	mov    0x804004,%eax
  801129:	8b 40 54             	mov    0x54(%eax),%eax
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	51                   	push   %ecx
  801130:	50                   	push   %eax
  801131:	68 c8 25 80 00       	push   $0x8025c8
  801136:	e8 49 f0 ff ff       	call   800184 <cprintf>
	*dev = 0;
  80113b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 10             	sub    $0x10,%esp
  801156:	8b 75 08             	mov    0x8(%ebp),%esi
  801159:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801166:	c1 e8 0c             	shr    $0xc,%eax
  801169:	50                   	push   %eax
  80116a:	e8 36 ff ff ff       	call   8010a5 <fd_lookup>
  80116f:	83 c4 08             	add    $0x8,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 05                	js     80117b <fd_close+0x2d>
	    || fd != fd2)
  801176:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801179:	74 0c                	je     801187 <fd_close+0x39>
		return (must_exist ? r : 0);
  80117b:	84 db                	test   %bl,%bl
  80117d:	ba 00 00 00 00       	mov    $0x0,%edx
  801182:	0f 44 c2             	cmove  %edx,%eax
  801185:	eb 41                	jmp    8011c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	ff 36                	pushl  (%esi)
  801190:	e8 66 ff ff ff       	call   8010fb <dev_lookup>
  801195:	89 c3                	mov    %eax,%ebx
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 1a                	js     8011b8 <fd_close+0x6a>
		if (dev->dev_close)
  80119e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	74 0b                	je     8011b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ad:	83 ec 0c             	sub    $0xc,%esp
  8011b0:	56                   	push   %esi
  8011b1:	ff d0                	call   *%eax
  8011b3:	89 c3                	mov    %eax,%ebx
  8011b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	56                   	push   %esi
  8011bc:	6a 00                	push   $0x0
  8011be:	e8 ce f9 ff ff       	call   800b91 <sys_page_unmap>
	return r;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	89 d8                	mov    %ebx,%eax
}
  8011c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	ff 75 08             	pushl  0x8(%ebp)
  8011dc:	e8 c4 fe ff ff       	call   8010a5 <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 10                	js     8011f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	6a 01                	push   $0x1
  8011ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f0:	e8 59 ff ff ff       	call   80114e <fd_close>
  8011f5:	83 c4 10             	add    $0x10,%esp
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <close_all>:

void
close_all(void)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801201:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	53                   	push   %ebx
  80120a:	e8 c0 ff ff ff       	call   8011cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80120f:	83 c3 01             	add    $0x1,%ebx
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	83 fb 20             	cmp    $0x20,%ebx
  801218:	75 ec                	jne    801206 <close_all+0xc>
		close(i);
}
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 2c             	sub    $0x2c,%esp
  801228:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 6e fe ff ff       	call   8010a5 <fd_lookup>
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 88 c1 00 00 00    	js     801303 <dup+0xe4>
		return r;
	close(newfdnum);
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	56                   	push   %esi
  801246:	e8 84 ff ff ff       	call   8011cf <close>

	newfd = INDEX2FD(newfdnum);
  80124b:	89 f3                	mov    %esi,%ebx
  80124d:	c1 e3 0c             	shl    $0xc,%ebx
  801250:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801256:	83 c4 04             	add    $0x4,%esp
  801259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125c:	e8 de fd ff ff       	call   80103f <fd2data>
  801261:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801263:	89 1c 24             	mov    %ebx,(%esp)
  801266:	e8 d4 fd ff ff       	call   80103f <fd2data>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801271:	89 f8                	mov    %edi,%eax
  801273:	c1 e8 16             	shr    $0x16,%eax
  801276:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127d:	a8 01                	test   $0x1,%al
  80127f:	74 37                	je     8012b8 <dup+0x99>
  801281:	89 f8                	mov    %edi,%eax
  801283:	c1 e8 0c             	shr    $0xc,%eax
  801286:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 26                	je     8012b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801292:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a5:	6a 00                	push   $0x0
  8012a7:	57                   	push   %edi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 a0 f8 ff ff       	call   800b4f <sys_page_map>
  8012af:	89 c7                	mov    %eax,%edi
  8012b1:	83 c4 20             	add    $0x20,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 2e                	js     8012e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012bb:	89 d0                	mov    %edx,%eax
  8012bd:	c1 e8 0c             	shr    $0xc,%eax
  8012c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cf:	50                   	push   %eax
  8012d0:	53                   	push   %ebx
  8012d1:	6a 00                	push   $0x0
  8012d3:	52                   	push   %edx
  8012d4:	6a 00                	push   $0x0
  8012d6:	e8 74 f8 ff ff       	call   800b4f <sys_page_map>
  8012db:	89 c7                	mov    %eax,%edi
  8012dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e2:	85 ff                	test   %edi,%edi
  8012e4:	79 1d                	jns    801303 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	53                   	push   %ebx
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 a0 f8 ff ff       	call   800b91 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f1:	83 c4 08             	add    $0x8,%esp
  8012f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 93 f8 ff ff       	call   800b91 <sys_page_unmap>
	return r;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	89 f8                	mov    %edi,%eax
}
  801303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5f                   	pop    %edi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	53                   	push   %ebx
  80130f:	83 ec 14             	sub    $0x14,%esp
  801312:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801315:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	53                   	push   %ebx
  80131a:	e8 86 fd ff ff       	call   8010a5 <fd_lookup>
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	89 c2                	mov    %eax,%edx
  801324:	85 c0                	test   %eax,%eax
  801326:	78 6d                	js     801395 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801332:	ff 30                	pushl  (%eax)
  801334:	e8 c2 fd ff ff       	call   8010fb <dev_lookup>
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 4c                	js     80138c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801340:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801343:	8b 42 08             	mov    0x8(%edx),%eax
  801346:	83 e0 03             	and    $0x3,%eax
  801349:	83 f8 01             	cmp    $0x1,%eax
  80134c:	75 21                	jne    80136f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80134e:	a1 04 40 80 00       	mov    0x804004,%eax
  801353:	8b 40 54             	mov    0x54(%eax),%eax
  801356:	83 ec 04             	sub    $0x4,%esp
  801359:	53                   	push   %ebx
  80135a:	50                   	push   %eax
  80135b:	68 09 26 80 00       	push   $0x802609
  801360:	e8 1f ee ff ff       	call   800184 <cprintf>
		return -E_INVAL;
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136d:	eb 26                	jmp    801395 <read+0x8a>
	}
	if (!dev->dev_read)
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	8b 40 08             	mov    0x8(%eax),%eax
  801375:	85 c0                	test   %eax,%eax
  801377:	74 17                	je     801390 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801379:	83 ec 04             	sub    $0x4,%esp
  80137c:	ff 75 10             	pushl  0x10(%ebp)
  80137f:	ff 75 0c             	pushl  0xc(%ebp)
  801382:	52                   	push   %edx
  801383:	ff d0                	call   *%eax
  801385:	89 c2                	mov    %eax,%edx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	eb 09                	jmp    801395 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	eb 05                	jmp    801395 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801390:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801395:	89 d0                	mov    %edx,%eax
  801397:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b0:	eb 21                	jmp    8013d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	29 d8                	sub    %ebx,%eax
  8013b9:	50                   	push   %eax
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	03 45 0c             	add    0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	57                   	push   %edi
  8013c1:	e8 45 ff ff ff       	call   80130b <read>
		if (m < 0)
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 10                	js     8013dd <readn+0x41>
			return m;
		if (m == 0)
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 0a                	je     8013db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d1:	01 c3                	add    %eax,%ebx
  8013d3:	39 f3                	cmp    %esi,%ebx
  8013d5:	72 db                	jb     8013b2 <readn+0x16>
  8013d7:	89 d8                	mov    %ebx,%eax
  8013d9:	eb 02                	jmp    8013dd <readn+0x41>
  8013db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
  8013ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	53                   	push   %ebx
  8013f4:	e8 ac fc ff ff       	call   8010a5 <fd_lookup>
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 68                	js     80146a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	ff 30                	pushl  (%eax)
  80140e:	e8 e8 fc ff ff       	call   8010fb <dev_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 47                	js     801461 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801421:	75 21                	jne    801444 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801423:	a1 04 40 80 00       	mov    0x804004,%eax
  801428:	8b 40 54             	mov    0x54(%eax),%eax
  80142b:	83 ec 04             	sub    $0x4,%esp
  80142e:	53                   	push   %ebx
  80142f:	50                   	push   %eax
  801430:	68 25 26 80 00       	push   $0x802625
  801435:	e8 4a ed ff ff       	call   800184 <cprintf>
		return -E_INVAL;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801442:	eb 26                	jmp    80146a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801444:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801447:	8b 52 0c             	mov    0xc(%edx),%edx
  80144a:	85 d2                	test   %edx,%edx
  80144c:	74 17                	je     801465 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	ff 75 10             	pushl  0x10(%ebp)
  801454:	ff 75 0c             	pushl  0xc(%ebp)
  801457:	50                   	push   %eax
  801458:	ff d2                	call   *%edx
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	eb 09                	jmp    80146a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801461:	89 c2                	mov    %eax,%edx
  801463:	eb 05                	jmp    80146a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801465:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80146a:	89 d0                	mov    %edx,%eax
  80146c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <seek>:

int
seek(int fdnum, off_t offset)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801477:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 08             	pushl  0x8(%ebp)
  80147e:	e8 22 fc ff ff       	call   8010a5 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 0e                	js     801498 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80148a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801490:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801493:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 14             	sub    $0x14,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	53                   	push   %ebx
  8014a9:	e8 f7 fb ff ff       	call   8010a5 <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 65                	js     80151c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	ff 30                	pushl  (%eax)
  8014c3:	e8 33 fc ff ff       	call   8010fb <dev_lookup>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 44                	js     801513 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d6:	75 21                	jne    8014f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014dd:	8b 40 54             	mov    0x54(%eax),%eax
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	53                   	push   %ebx
  8014e4:	50                   	push   %eax
  8014e5:	68 e8 25 80 00       	push   $0x8025e8
  8014ea:	e8 95 ec ff ff       	call   800184 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f7:	eb 23                	jmp    80151c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fc:	8b 52 18             	mov    0x18(%edx),%edx
  8014ff:	85 d2                	test   %edx,%edx
  801501:	74 14                	je     801517 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	50                   	push   %eax
  80150a:	ff d2                	call   *%edx
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	eb 09                	jmp    80151c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	89 c2                	mov    %eax,%edx
  801515:	eb 05                	jmp    80151c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801517:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80151c:	89 d0                	mov    %edx,%eax
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	ff 75 08             	pushl  0x8(%ebp)
  801534:	e8 6c fb ff ff       	call   8010a5 <fd_lookup>
  801539:	83 c4 08             	add    $0x8,%esp
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 58                	js     80159a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154c:	ff 30                	pushl  (%eax)
  80154e:	e8 a8 fb ff ff       	call   8010fb <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 37                	js     801591 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801561:	74 32                	je     801595 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801563:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801566:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156d:	00 00 00 
	stat->st_isdir = 0;
  801570:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801577:	00 00 00 
	stat->st_dev = dev;
  80157a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	53                   	push   %ebx
  801584:	ff 75 f0             	pushl  -0x10(%ebp)
  801587:	ff 50 14             	call   *0x14(%eax)
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	eb 09                	jmp    80159a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	89 c2                	mov    %eax,%edx
  801593:	eb 05                	jmp    80159a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801595:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80159a:	89 d0                	mov    %edx,%eax
  80159c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	6a 00                	push   $0x0
  8015ab:	ff 75 08             	pushl  0x8(%ebp)
  8015ae:	e8 e3 01 00 00       	call   801796 <open>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 1b                	js     8015d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	e8 5b ff ff ff       	call   801523 <fstat>
  8015c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ca:	89 1c 24             	mov    %ebx,(%esp)
  8015cd:	e8 fd fb ff ff       	call   8011cf <close>
	return r;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	89 f0                	mov    %esi,%eax
}
  8015d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
  8015e3:	89 c6                	mov    %eax,%esi
  8015e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015ee:	75 12                	jne    801602 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	6a 01                	push   $0x1
  8015f5:	e8 ce 08 00 00       	call   801ec8 <ipc_find_env>
  8015fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8015ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801602:	6a 07                	push   $0x7
  801604:	68 00 50 80 00       	push   $0x805000
  801609:	56                   	push   %esi
  80160a:	ff 35 00 40 80 00    	pushl  0x804000
  801610:	e8 51 08 00 00       	call   801e66 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801615:	83 c4 0c             	add    $0xc,%esp
  801618:	6a 00                	push   $0x0
  80161a:	53                   	push   %ebx
  80161b:	6a 00                	push   $0x0
  80161d:	e8 cc 07 00 00       	call   801dee <ipc_recv>
}
  801622:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80162f:	8b 45 08             	mov    0x8(%ebp),%eax
  801632:	8b 40 0c             	mov    0xc(%eax),%eax
  801635:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 02 00 00 00       	mov    $0x2,%eax
  80164c:	e8 8d ff ff ff       	call   8015de <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 06 00 00 00       	mov    $0x6,%eax
  80166e:	e8 6b ff ff ff       	call   8015de <fsipc>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 40 0c             	mov    0xc(%eax),%eax
  801685:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 05 00 00 00       	mov    $0x5,%eax
  801694:	e8 45 ff ff ff       	call   8015de <fsipc>
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 2c                	js     8016c9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	68 00 50 80 00       	push   $0x805000
  8016a5:	53                   	push   %ebx
  8016a6:	e8 5e f0 ff ff       	call   800709 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8016bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8016da:	8b 52 0c             	mov    0xc(%edx),%edx
  8016dd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016e3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016e8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016ed:	0f 47 c2             	cmova  %edx,%eax
  8016f0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	68 08 50 80 00       	push   $0x805008
  8016fe:	e8 98 f1 ff ff       	call   80089b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801703:	ba 00 00 00 00       	mov    $0x0,%edx
  801708:	b8 04 00 00 00       	mov    $0x4,%eax
  80170d:	e8 cc fe ff ff       	call   8015de <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	8b 40 0c             	mov    0xc(%eax),%eax
  801722:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801727:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 03 00 00 00       	mov    $0x3,%eax
  801737:	e8 a2 fe ff ff       	call   8015de <fsipc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 4b                	js     80178d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801742:	39 c6                	cmp    %eax,%esi
  801744:	73 16                	jae    80175c <devfile_read+0x48>
  801746:	68 54 26 80 00       	push   $0x802654
  80174b:	68 5b 26 80 00       	push   $0x80265b
  801750:	6a 7c                	push   $0x7c
  801752:	68 70 26 80 00       	push   $0x802670
  801757:	e8 bd 05 00 00       	call   801d19 <_panic>
	assert(r <= PGSIZE);
  80175c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801761:	7e 16                	jle    801779 <devfile_read+0x65>
  801763:	68 7b 26 80 00       	push   $0x80267b
  801768:	68 5b 26 80 00       	push   $0x80265b
  80176d:	6a 7d                	push   $0x7d
  80176f:	68 70 26 80 00       	push   $0x802670
  801774:	e8 a0 05 00 00       	call   801d19 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	50                   	push   %eax
  80177d:	68 00 50 80 00       	push   $0x805000
  801782:	ff 75 0c             	pushl  0xc(%ebp)
  801785:	e8 11 f1 ff ff       	call   80089b <memmove>
	return r;
  80178a:	83 c4 10             	add    $0x10,%esp
}
  80178d:	89 d8                	mov    %ebx,%eax
  80178f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 20             	sub    $0x20,%esp
  80179d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017a0:	53                   	push   %ebx
  8017a1:	e8 2a ef ff ff       	call   8006d0 <strlen>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ae:	7f 67                	jg     801817 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b0:	83 ec 0c             	sub    $0xc,%esp
  8017b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	e8 9a f8 ff ff       	call   801056 <fd_alloc>
  8017bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017bf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 57                	js     80181c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	53                   	push   %ebx
  8017c9:	68 00 50 80 00       	push   $0x805000
  8017ce:	e8 36 ef ff ff       	call   800709 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017de:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e3:	e8 f6 fd ff ff       	call   8015de <fsipc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	79 14                	jns    801805 <open+0x6f>
		fd_close(fd, 0);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	6a 00                	push   $0x0
  8017f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f9:	e8 50 f9 ff ff       	call   80114e <fd_close>
		return r;
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	89 da                	mov    %ebx,%edx
  801803:	eb 17                	jmp    80181c <open+0x86>
	}

	return fd2num(fd);
  801805:	83 ec 0c             	sub    $0xc,%esp
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 1f f8 ff ff       	call   80102f <fd2num>
  801810:	89 c2                	mov    %eax,%edx
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	eb 05                	jmp    80181c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801817:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80181c:	89 d0                	mov    %edx,%eax
  80181e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	b8 08 00 00 00       	mov    $0x8,%eax
  801833:	e8 a6 fd ff ff       	call   8015de <fsipc>
}
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
  80183f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	ff 75 08             	pushl  0x8(%ebp)
  801848:	e8 f2 f7 ff ff       	call   80103f <fd2data>
  80184d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80184f:	83 c4 08             	add    $0x8,%esp
  801852:	68 87 26 80 00       	push   $0x802687
  801857:	53                   	push   %ebx
  801858:	e8 ac ee ff ff       	call   800709 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80185d:	8b 46 04             	mov    0x4(%esi),%eax
  801860:	2b 06                	sub    (%esi),%eax
  801862:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801868:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80186f:	00 00 00 
	stat->st_dev = &devpipe;
  801872:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801879:	30 80 00 
	return 0;
}
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
  801881:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	53                   	push   %ebx
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801892:	53                   	push   %ebx
  801893:	6a 00                	push   $0x0
  801895:	e8 f7 f2 ff ff       	call   800b91 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80189a:	89 1c 24             	mov    %ebx,(%esp)
  80189d:	e8 9d f7 ff ff       	call   80103f <fd2data>
  8018a2:	83 c4 08             	add    $0x8,%esp
  8018a5:	50                   	push   %eax
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 e4 f2 ff ff       	call   800b91 <sys_page_unmap>
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	57                   	push   %edi
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 1c             	sub    $0x1c,%esp
  8018bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018be:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c5:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ce:	e8 35 06 00 00       	call   801f08 <pageref>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	89 3c 24             	mov    %edi,(%esp)
  8018d8:	e8 2b 06 00 00       	call   801f08 <pageref>
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	39 c3                	cmp    %eax,%ebx
  8018e2:	0f 94 c1             	sete   %cl
  8018e5:	0f b6 c9             	movzbl %cl,%ecx
  8018e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018eb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018f1:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8018f4:	39 ce                	cmp    %ecx,%esi
  8018f6:	74 1b                	je     801913 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018f8:	39 c3                	cmp    %eax,%ebx
  8018fa:	75 c4                	jne    8018c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018fc:	8b 42 64             	mov    0x64(%edx),%eax
  8018ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801902:	50                   	push   %eax
  801903:	56                   	push   %esi
  801904:	68 8e 26 80 00       	push   $0x80268e
  801909:	e8 76 e8 ff ff       	call   800184 <cprintf>
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	eb ad                	jmp    8018c0 <_pipeisclosed+0xe>
	}
}
  801913:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801916:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	57                   	push   %edi
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	83 ec 28             	sub    $0x28,%esp
  801927:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80192a:	56                   	push   %esi
  80192b:	e8 0f f7 ff ff       	call   80103f <fd2data>
  801930:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	bf 00 00 00 00       	mov    $0x0,%edi
  80193a:	eb 4b                	jmp    801987 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80193c:	89 da                	mov    %ebx,%edx
  80193e:	89 f0                	mov    %esi,%eax
  801940:	e8 6d ff ff ff       	call   8018b2 <_pipeisclosed>
  801945:	85 c0                	test   %eax,%eax
  801947:	75 48                	jne    801991 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801949:	e8 9f f1 ff ff       	call   800aed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80194e:	8b 43 04             	mov    0x4(%ebx),%eax
  801951:	8b 0b                	mov    (%ebx),%ecx
  801953:	8d 51 20             	lea    0x20(%ecx),%edx
  801956:	39 d0                	cmp    %edx,%eax
  801958:	73 e2                	jae    80193c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80195a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80195d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801961:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801964:	89 c2                	mov    %eax,%edx
  801966:	c1 fa 1f             	sar    $0x1f,%edx
  801969:	89 d1                	mov    %edx,%ecx
  80196b:	c1 e9 1b             	shr    $0x1b,%ecx
  80196e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801971:	83 e2 1f             	and    $0x1f,%edx
  801974:	29 ca                	sub    %ecx,%edx
  801976:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80197a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80197e:	83 c0 01             	add    $0x1,%eax
  801981:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801984:	83 c7 01             	add    $0x1,%edi
  801987:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80198a:	75 c2                	jne    80194e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80198c:	8b 45 10             	mov    0x10(%ebp),%eax
  80198f:	eb 05                	jmp    801996 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801996:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5f                   	pop    %edi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 18             	sub    $0x18,%esp
  8019a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019aa:	57                   	push   %edi
  8019ab:	e8 8f f6 ff ff       	call   80103f <fd2data>
  8019b0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ba:	eb 3d                	jmp    8019f9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019bc:	85 db                	test   %ebx,%ebx
  8019be:	74 04                	je     8019c4 <devpipe_read+0x26>
				return i;
  8019c0:	89 d8                	mov    %ebx,%eax
  8019c2:	eb 44                	jmp    801a08 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019c4:	89 f2                	mov    %esi,%edx
  8019c6:	89 f8                	mov    %edi,%eax
  8019c8:	e8 e5 fe ff ff       	call   8018b2 <_pipeisclosed>
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	75 32                	jne    801a03 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019d1:	e8 17 f1 ff ff       	call   800aed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019d6:	8b 06                	mov    (%esi),%eax
  8019d8:	3b 46 04             	cmp    0x4(%esi),%eax
  8019db:	74 df                	je     8019bc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019dd:	99                   	cltd   
  8019de:	c1 ea 1b             	shr    $0x1b,%edx
  8019e1:	01 d0                	add    %edx,%eax
  8019e3:	83 e0 1f             	and    $0x1f,%eax
  8019e6:	29 d0                	sub    %edx,%eax
  8019e8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019f3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f6:	83 c3 01             	add    $0x1,%ebx
  8019f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019fc:	75 d8                	jne    8019d6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801a01:	eb 05                	jmp    801a08 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	e8 35 f6 ff ff       	call   801056 <fd_alloc>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 2c 01 00 00    	js     801b5a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	68 07 04 00 00       	push   $0x407
  801a36:	ff 75 f4             	pushl  -0xc(%ebp)
  801a39:	6a 00                	push   $0x0
  801a3b:	e8 cc f0 ff ff       	call   800b0c <sys_page_alloc>
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	85 c0                	test   %eax,%eax
  801a47:	0f 88 0d 01 00 00    	js     801b5a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a4d:	83 ec 0c             	sub    $0xc,%esp
  801a50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a53:	50                   	push   %eax
  801a54:	e8 fd f5 ff ff       	call   801056 <fd_alloc>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	0f 88 e2 00 00 00    	js     801b48 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	68 07 04 00 00       	push   $0x407
  801a6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a71:	6a 00                	push   $0x0
  801a73:	e8 94 f0 ff ff       	call   800b0c <sys_page_alloc>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	0f 88 c3 00 00 00    	js     801b48 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8b:	e8 af f5 ff ff       	call   80103f <fd2data>
  801a90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a92:	83 c4 0c             	add    $0xc,%esp
  801a95:	68 07 04 00 00       	push   $0x407
  801a9a:	50                   	push   %eax
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 6a f0 ff ff       	call   800b0c <sys_page_alloc>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 88 89 00 00 00    	js     801b38 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab5:	e8 85 f5 ff ff       	call   80103f <fd2data>
  801aba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ac1:	50                   	push   %eax
  801ac2:	6a 00                	push   $0x0
  801ac4:	56                   	push   %esi
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 83 f0 ff ff       	call   800b4f <sys_page_map>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	83 c4 20             	add    $0x20,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 55                	js     801b2a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ad5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801aea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	ff 75 f4             	pushl  -0xc(%ebp)
  801b05:	e8 25 f5 ff ff       	call   80102f <fd2num>
  801b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b0f:	83 c4 04             	add    $0x4,%esp
  801b12:	ff 75 f0             	pushl  -0x10(%ebp)
  801b15:	e8 15 f5 ff ff       	call   80102f <fd2num>
  801b1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b1d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	ba 00 00 00 00       	mov    $0x0,%edx
  801b28:	eb 30                	jmp    801b5a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b2a:	83 ec 08             	sub    $0x8,%esp
  801b2d:	56                   	push   %esi
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 5c f0 ff ff       	call   800b91 <sys_page_unmap>
  801b35:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 4c f0 ff ff       	call   800b91 <sys_page_unmap>
  801b45:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 3c f0 ff ff       	call   800b91 <sys_page_unmap>
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b5a:	89 d0                	mov    %edx,%eax
  801b5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6c:	50                   	push   %eax
  801b6d:	ff 75 08             	pushl  0x8(%ebp)
  801b70:	e8 30 f5 ff ff       	call   8010a5 <fd_lookup>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 18                	js     801b94 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b7c:	83 ec 0c             	sub    $0xc,%esp
  801b7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b82:	e8 b8 f4 ff ff       	call   80103f <fd2data>
	return _pipeisclosed(fd, p);
  801b87:	89 c2                	mov    %eax,%edx
  801b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8c:	e8 21 fd ff ff       	call   8018b2 <_pipeisclosed>
  801b91:	83 c4 10             	add    $0x10,%esp
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ba6:	68 a6 26 80 00       	push   $0x8026a6
  801bab:	ff 75 0c             	pushl  0xc(%ebp)
  801bae:	e8 56 eb ff ff       	call   800709 <strcpy>
	return 0;
}
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	57                   	push   %edi
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bcb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd1:	eb 2d                	jmp    801c00 <devcons_write+0x46>
		m = n - tot;
  801bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bd6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bd8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bdb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801be0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801be3:	83 ec 04             	sub    $0x4,%esp
  801be6:	53                   	push   %ebx
  801be7:	03 45 0c             	add    0xc(%ebp),%eax
  801bea:	50                   	push   %eax
  801beb:	57                   	push   %edi
  801bec:	e8 aa ec ff ff       	call   80089b <memmove>
		sys_cputs(buf, m);
  801bf1:	83 c4 08             	add    $0x8,%esp
  801bf4:	53                   	push   %ebx
  801bf5:	57                   	push   %edi
  801bf6:	e8 55 ee ff ff       	call   800a50 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bfb:	01 de                	add    %ebx,%esi
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	89 f0                	mov    %esi,%eax
  801c02:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c05:	72 cc                	jb     801bd3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 08             	sub    $0x8,%esp
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c1e:	74 2a                	je     801c4a <devcons_read+0x3b>
  801c20:	eb 05                	jmp    801c27 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c22:	e8 c6 ee ff ff       	call   800aed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c27:	e8 42 ee ff ff       	call   800a6e <sys_cgetc>
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	74 f2                	je     801c22 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 16                	js     801c4a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c34:	83 f8 04             	cmp    $0x4,%eax
  801c37:	74 0c                	je     801c45 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c39:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3c:	88 02                	mov    %al,(%edx)
	return 1;
  801c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c43:	eb 05                	jmp    801c4a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c58:	6a 01                	push   $0x1
  801c5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c5d:	50                   	push   %eax
  801c5e:	e8 ed ed ff ff       	call   800a50 <sys_cputs>
}
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <getchar>:

int
getchar(void)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c6e:	6a 01                	push   $0x1
  801c70:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c73:	50                   	push   %eax
  801c74:	6a 00                	push   $0x0
  801c76:	e8 90 f6 ff ff       	call   80130b <read>
	if (r < 0)
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 0f                	js     801c91 <getchar+0x29>
		return r;
	if (r < 1)
  801c82:	85 c0                	test   %eax,%eax
  801c84:	7e 06                	jle    801c8c <getchar+0x24>
		return -E_EOF;
	return c;
  801c86:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c8a:	eb 05                	jmp    801c91 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c8c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	ff 75 08             	pushl  0x8(%ebp)
  801ca0:	e8 00 f4 ff ff       	call   8010a5 <fd_lookup>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 11                	js     801cbd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb5:	39 10                	cmp    %edx,(%eax)
  801cb7:	0f 94 c0             	sete   %al
  801cba:	0f b6 c0             	movzbl %al,%eax
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <opencons>:

int
opencons(void)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc8:	50                   	push   %eax
  801cc9:	e8 88 f3 ff ff       	call   801056 <fd_alloc>
  801cce:	83 c4 10             	add    $0x10,%esp
		return r;
  801cd1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 3e                	js     801d15 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cd7:	83 ec 04             	sub    $0x4,%esp
  801cda:	68 07 04 00 00       	push   $0x407
  801cdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce2:	6a 00                	push   $0x0
  801ce4:	e8 23 ee ff ff       	call   800b0c <sys_page_alloc>
  801ce9:	83 c4 10             	add    $0x10,%esp
		return r;
  801cec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 23                	js     801d15 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cf2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d07:	83 ec 0c             	sub    $0xc,%esp
  801d0a:	50                   	push   %eax
  801d0b:	e8 1f f3 ff ff       	call   80102f <fd2num>
  801d10:	89 c2                	mov    %eax,%edx
  801d12:	83 c4 10             	add    $0x10,%esp
}
  801d15:	89 d0                	mov    %edx,%eax
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d1e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d21:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d27:	e8 a2 ed ff ff       	call   800ace <sys_getenvid>
  801d2c:	83 ec 0c             	sub    $0xc,%esp
  801d2f:	ff 75 0c             	pushl  0xc(%ebp)
  801d32:	ff 75 08             	pushl  0x8(%ebp)
  801d35:	56                   	push   %esi
  801d36:	50                   	push   %eax
  801d37:	68 b4 26 80 00       	push   $0x8026b4
  801d3c:	e8 43 e4 ff ff       	call   800184 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d41:	83 c4 18             	add    $0x18,%esp
  801d44:	53                   	push   %ebx
  801d45:	ff 75 10             	pushl  0x10(%ebp)
  801d48:	e8 e6 e3 ff ff       	call   800133 <vcprintf>
	cprintf("\n");
  801d4d:	c7 04 24 9f 26 80 00 	movl   $0x80269f,(%esp)
  801d54:	e8 2b e4 ff ff       	call   800184 <cprintf>
  801d59:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d5c:	cc                   	int3   
  801d5d:	eb fd                	jmp    801d5c <_panic+0x43>

00801d5f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d65:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d6c:	75 2a                	jne    801d98 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d6e:	83 ec 04             	sub    $0x4,%esp
  801d71:	6a 07                	push   $0x7
  801d73:	68 00 f0 bf ee       	push   $0xeebff000
  801d78:	6a 00                	push   $0x0
  801d7a:	e8 8d ed ff ff       	call   800b0c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	85 c0                	test   %eax,%eax
  801d84:	79 12                	jns    801d98 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d86:	50                   	push   %eax
  801d87:	68 d8 26 80 00       	push   $0x8026d8
  801d8c:	6a 23                	push   $0x23
  801d8e:	68 dc 26 80 00       	push   $0x8026dc
  801d93:	e8 81 ff ff ff       	call   801d19 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801da0:	83 ec 08             	sub    $0x8,%esp
  801da3:	68 ca 1d 80 00       	push   $0x801dca
  801da8:	6a 00                	push   $0x0
  801daa:	e8 a8 ee ff ff       	call   800c57 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	79 12                	jns    801dc8 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801db6:	50                   	push   %eax
  801db7:	68 d8 26 80 00       	push   $0x8026d8
  801dbc:	6a 2c                	push   $0x2c
  801dbe:	68 dc 26 80 00       	push   $0x8026dc
  801dc3:	e8 51 ff ff ff       	call   801d19 <_panic>
	}
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dca:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dcb:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dd0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dd2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dd5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dd9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dde:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801de2:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801de4:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801de7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801de8:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801deb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dec:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ded:	c3                   	ret    

00801dee <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	8b 75 08             	mov    0x8(%ebp),%esi
  801df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	75 12                	jne    801e12 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	68 00 00 c0 ee       	push   $0xeec00000
  801e08:	e8 af ee ff ff       	call   800cbc <sys_ipc_recv>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	eb 0c                	jmp    801e1e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	50                   	push   %eax
  801e16:	e8 a1 ee ff ff       	call   800cbc <sys_ipc_recv>
  801e1b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e1e:	85 f6                	test   %esi,%esi
  801e20:	0f 95 c1             	setne  %cl
  801e23:	85 db                	test   %ebx,%ebx
  801e25:	0f 95 c2             	setne  %dl
  801e28:	84 d1                	test   %dl,%cl
  801e2a:	74 09                	je     801e35 <ipc_recv+0x47>
  801e2c:	89 c2                	mov    %eax,%edx
  801e2e:	c1 ea 1f             	shr    $0x1f,%edx
  801e31:	84 d2                	test   %dl,%dl
  801e33:	75 2a                	jne    801e5f <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e35:	85 f6                	test   %esi,%esi
  801e37:	74 0d                	je     801e46 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e39:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e44:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	74 0d                	je     801e57 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e55:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e57:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5c:	8b 40 7c             	mov    0x7c(%eax),%eax
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
  801e88:	e8 0c ee ff ff       	call   800c99 <sys_ipc_try_send>
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
  801e9f:	68 ea 26 80 00       	push   $0x8026ea
  801ea4:	6a 47                	push   $0x47
  801ea6:	68 f8 26 80 00       	push   $0x8026f8
  801eab:	e8 69 fe ff ff       	call   801d19 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801eb0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb3:	75 07                	jne    801ebc <ipc_send+0x56>
			sys_yield();
  801eb5:	e8 33 ec ff ff       	call   800aed <sys_yield>
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
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	c1 e2 07             	shl    $0x7,%edx
  801ed8:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801edf:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ee2:	39 ca                	cmp    %ecx,%edx
  801ee4:	75 11                	jne    801ef7 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ee6:	89 c2                	mov    %eax,%edx
  801ee8:	c1 e2 07             	shl    $0x7,%edx
  801eeb:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ef2:	8b 40 54             	mov    0x54(%eax),%eax
  801ef5:	eb 0f                	jmp    801f06 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ef7:	83 c0 01             	add    $0x1,%eax
  801efa:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eff:	75 d2                	jne    801ed3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0e:	89 d0                	mov    %edx,%eax
  801f10:	c1 e8 16             	shr    $0x16,%eax
  801f13:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1f:	f6 c1 01             	test   $0x1,%cl
  801f22:	74 1d                	je     801f41 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f24:	c1 ea 0c             	shr    $0xc,%edx
  801f27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f2e:	f6 c2 01             	test   $0x1,%dl
  801f31:	74 0e                	je     801f41 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f33:	c1 ea 0c             	shr    $0xc,%edx
  801f36:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f3d:	ef 
  801f3e:	0f b7 c0             	movzwl %ax,%eax
}
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    
  801f43:	66 90                	xchg   %ax,%ax
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
