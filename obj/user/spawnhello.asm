
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4d 00 00 00       	call   80007e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 50 80 00       	mov    0x805004,%eax
  80003e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800044:	50                   	push   %eax
  800045:	68 20 2a 80 00       	push   $0x802a20
  80004a:	e8 8b 01 00 00       	call   8001da <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004f:	83 c4 0c             	add    $0xc,%esp
  800052:	6a 00                	push   $0x0
  800054:	68 3e 2a 80 00       	push   $0x802a3e
  800059:	68 3e 2a 80 00       	push   $0x802a3e
  80005e:	e8 d3 1f 00 00       	call   802036 <spawnl>
  800063:	83 c4 10             	add    $0x10,%esp
  800066:	85 c0                	test   %eax,%eax
  800068:	79 12                	jns    80007c <umain+0x49>
		panic("spawn(hello) failed: %e", r);
  80006a:	50                   	push   %eax
  80006b:	68 44 2a 80 00       	push   $0x802a44
  800070:	6a 09                	push   $0x9
  800072:	68 5c 2a 80 00       	push   $0x802a5c
  800077:	e8 85 00 00 00       	call   800101 <_panic>
}
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800086:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800089:	e8 96 0a 00 00       	call   800b24 <sys_getenvid>
  80008e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800093:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800099:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009e:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a3:	85 db                	test   %ebx,%ebx
  8000a5:	7e 07                	jle    8000ae <libmain+0x30>
		binaryname = argv[0];
  8000a7:	8b 06                	mov    (%esi),%eax
  8000a9:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
  8000b3:	e8 7b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 2a 00 00 00       	call   8000e7 <exit>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000cd:	a1 08 50 80 00       	mov    0x805008,%eax
	func();
  8000d2:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000d4:	e8 4b 0a 00 00       	call   800b24 <sys_getenvid>
  8000d9:	83 ec 0c             	sub    $0xc,%esp
  8000dc:	50                   	push   %eax
  8000dd:	e8 91 0c 00 00       	call   800d73 <sys_thread_free>
}
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 89 13 00 00       	call   80147b <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 e7 09 00 00       	call   800ae3 <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800106:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800109:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80010f:	e8 10 0a 00 00       	call   800b24 <sys_getenvid>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	56                   	push   %esi
  80011e:	50                   	push   %eax
  80011f:	68 78 2a 80 00       	push   $0x802a78
  800124:	e8 b1 00 00 00       	call   8001da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800129:	83 c4 18             	add    $0x18,%esp
  80012c:	53                   	push   %ebx
  80012d:	ff 75 10             	pushl  0x10(%ebp)
  800130:	e8 54 00 00 00       	call   800189 <vcprintf>
	cprintf("\n");
  800135:	c7 04 24 3b 2e 80 00 	movl   $0x802e3b,(%esp)
  80013c:	e8 99 00 00 00       	call   8001da <cprintf>
  800141:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800144:	cc                   	int3   
  800145:	eb fd                	jmp    800144 <_panic+0x43>

00800147 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	53                   	push   %ebx
  80014b:	83 ec 04             	sub    $0x4,%esp
  80014e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800151:	8b 13                	mov    (%ebx),%edx
  800153:	8d 42 01             	lea    0x1(%edx),%eax
  800156:	89 03                	mov    %eax,(%ebx)
  800158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800164:	75 1a                	jne    800180 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800166:	83 ec 08             	sub    $0x8,%esp
  800169:	68 ff 00 00 00       	push   $0xff
  80016e:	8d 43 08             	lea    0x8(%ebx),%eax
  800171:	50                   	push   %eax
  800172:	e8 2f 09 00 00       	call   800aa6 <sys_cputs>
		b->idx = 0;
  800177:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800180:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800192:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800199:	00 00 00 
	b.cnt = 0;
  80019c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a6:	ff 75 0c             	pushl  0xc(%ebp)
  8001a9:	ff 75 08             	pushl  0x8(%ebp)
  8001ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	68 47 01 80 00       	push   $0x800147
  8001b8:	e8 54 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bd:	83 c4 08             	add    $0x8,%esp
  8001c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	e8 d4 08 00 00       	call   800aa6 <sys_cputs>

	return b.cnt;
}
  8001d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e3:	50                   	push   %eax
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	e8 9d ff ff ff       	call   800189 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 1c             	sub    $0x1c,%esp
  8001f7:	89 c7                	mov    %eax,%edi
  8001f9:	89 d6                	mov    %edx,%esi
  8001fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800207:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800212:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800215:	39 d3                	cmp    %edx,%ebx
  800217:	72 05                	jb     80021e <printnum+0x30>
  800219:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021c:	77 45                	ja     800263 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	ff 75 18             	pushl  0x18(%ebp)
  800224:	8b 45 14             	mov    0x14(%ebp),%eax
  800227:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80022a:	53                   	push   %ebx
  80022b:	ff 75 10             	pushl  0x10(%ebp)
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	ff 75 e4             	pushl  -0x1c(%ebp)
  800234:	ff 75 e0             	pushl  -0x20(%ebp)
  800237:	ff 75 dc             	pushl  -0x24(%ebp)
  80023a:	ff 75 d8             	pushl  -0x28(%ebp)
  80023d:	e8 3e 25 00 00       	call   802780 <__udivdi3>
  800242:	83 c4 18             	add    $0x18,%esp
  800245:	52                   	push   %edx
  800246:	50                   	push   %eax
  800247:	89 f2                	mov    %esi,%edx
  800249:	89 f8                	mov    %edi,%eax
  80024b:	e8 9e ff ff ff       	call   8001ee <printnum>
  800250:	83 c4 20             	add    $0x20,%esp
  800253:	eb 18                	jmp    80026d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	56                   	push   %esi
  800259:	ff 75 18             	pushl  0x18(%ebp)
  80025c:	ff d7                	call   *%edi
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	eb 03                	jmp    800266 <printnum+0x78>
  800263:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800266:	83 eb 01             	sub    $0x1,%ebx
  800269:	85 db                	test   %ebx,%ebx
  80026b:	7f e8                	jg     800255 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	83 ec 04             	sub    $0x4,%esp
  800274:	ff 75 e4             	pushl  -0x1c(%ebp)
  800277:	ff 75 e0             	pushl  -0x20(%ebp)
  80027a:	ff 75 dc             	pushl  -0x24(%ebp)
  80027d:	ff 75 d8             	pushl  -0x28(%ebp)
  800280:	e8 2b 26 00 00       	call   8028b0 <__umoddi3>
  800285:	83 c4 14             	add    $0x14,%esp
  800288:	0f be 80 9b 2a 80 00 	movsbl 0x802a9b(%eax),%eax
  80028f:	50                   	push   %eax
  800290:	ff d7                	call   *%edi
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a0:	83 fa 01             	cmp    $0x1,%edx
  8002a3:	7e 0e                	jle    8002b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	8b 52 04             	mov    0x4(%edx),%edx
  8002b1:	eb 22                	jmp    8002d5 <getuint+0x38>
	else if (lflag)
  8002b3:	85 d2                	test   %edx,%edx
  8002b5:	74 10                	je     8002c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	eb 0e                	jmp    8002d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e6:	73 0a                	jae    8002f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	88 02                	mov    %al,(%edx)
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fd:	50                   	push   %eax
  8002fe:	ff 75 10             	pushl  0x10(%ebp)
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	ff 75 08             	pushl  0x8(%ebp)
  800307:	e8 05 00 00 00       	call   800311 <vprintfmt>
	va_end(ap);
}
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
  800317:	83 ec 2c             	sub    $0x2c,%esp
  80031a:	8b 75 08             	mov    0x8(%ebp),%esi
  80031d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800320:	8b 7d 10             	mov    0x10(%ebp),%edi
  800323:	eb 12                	jmp    800337 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800325:	85 c0                	test   %eax,%eax
  800327:	0f 84 89 03 00 00    	je     8006b6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	53                   	push   %ebx
  800331:	50                   	push   %eax
  800332:	ff d6                	call   *%esi
  800334:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800337:	83 c7 01             	add    $0x1,%edi
  80033a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033e:	83 f8 25             	cmp    $0x25,%eax
  800341:	75 e2                	jne    800325 <vprintfmt+0x14>
  800343:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800347:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800355:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035c:	ba 00 00 00 00       	mov    $0x0,%edx
  800361:	eb 07                	jmp    80036a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800366:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8d 47 01             	lea    0x1(%edi),%eax
  80036d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800370:	0f b6 07             	movzbl (%edi),%eax
  800373:	0f b6 c8             	movzbl %al,%ecx
  800376:	83 e8 23             	sub    $0x23,%eax
  800379:	3c 55                	cmp    $0x55,%al
  80037b:	0f 87 1a 03 00 00    	ja     80069b <vprintfmt+0x38a>
  800381:	0f b6 c0             	movzbl %al,%eax
  800384:	ff 24 85 e0 2b 80 00 	jmp    *0x802be0(,%eax,4)
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800392:	eb d6                	jmp    80036a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ac:	83 fa 09             	cmp    $0x9,%edx
  8003af:	77 39                	ja     8003ea <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b4:	eb e9                	jmp    80039f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c7:	eb 27                	jmp    8003f0 <vprintfmt+0xdf>
  8003c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d3:	0f 49 c8             	cmovns %eax,%ecx
  8003d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dc:	eb 8c                	jmp    80036a <vprintfmt+0x59>
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e8:	eb 80                	jmp    80036a <vprintfmt+0x59>
  8003ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f4:	0f 89 70 ff ff ff    	jns    80036a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	e9 5e ff ff ff       	jmp    80036a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800412:	e9 53 ff ff ff       	jmp    80036a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	ff 30                	pushl  (%eax)
  800426:	ff d6                	call   *%esi
			break;
  800428:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042e:	e9 04 ff ff ff       	jmp    800337 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 50 04             	lea    0x4(%eax),%edx
  800439:	89 55 14             	mov    %edx,0x14(%ebp)
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	99                   	cltd   
  80043f:	31 d0                	xor    %edx,%eax
  800441:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 0f             	cmp    $0xf,%eax
  800446:	7f 0b                	jg     800453 <vprintfmt+0x142>
  800448:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  80044f:	85 d2                	test   %edx,%edx
  800451:	75 18                	jne    80046b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800453:	50                   	push   %eax
  800454:	68 b3 2a 80 00       	push   $0x802ab3
  800459:	53                   	push   %ebx
  80045a:	56                   	push   %esi
  80045b:	e8 94 fe ff ff       	call   8002f4 <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800466:	e9 cc fe ff ff       	jmp    800337 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046b:	52                   	push   %edx
  80046c:	68 fd 2e 80 00       	push   $0x802efd
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 7c fe ff ff       	call   8002f4 <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047e:	e9 b4 fe ff ff       	jmp    800337 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048e:	85 ff                	test   %edi,%edi
  800490:	b8 ac 2a 80 00       	mov    $0x802aac,%eax
  800495:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800498:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049c:	0f 8e 94 00 00 00    	jle    800536 <vprintfmt+0x225>
  8004a2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a6:	0f 84 98 00 00 00    	je     800544 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b2:	57                   	push   %edi
  8004b3:	e8 86 02 00 00       	call   80073e <strnlen>
  8004b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bb:	29 c1                	sub    %eax,%ecx
  8004bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	eb 0f                	jmp    8004e0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	53                   	push   %ebx
  8004d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	83 ef 01             	sub    $0x1,%edi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	85 ff                	test   %edi,%edi
  8004e2:	7f ed                	jg     8004d1 <vprintfmt+0x1c0>
  8004e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ea:	85 c9                	test   %ecx,%ecx
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	0f 49 c1             	cmovns %ecx,%eax
  8004f4:	29 c1                	sub    %eax,%ecx
  8004f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ff:	89 cb                	mov    %ecx,%ebx
  800501:	eb 4d                	jmp    800550 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800503:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800507:	74 1b                	je     800524 <vprintfmt+0x213>
  800509:	0f be c0             	movsbl %al,%eax
  80050c:	83 e8 20             	sub    $0x20,%eax
  80050f:	83 f8 5e             	cmp    $0x5e,%eax
  800512:	76 10                	jbe    800524 <vprintfmt+0x213>
					putch('?', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	ff 75 0c             	pushl  0xc(%ebp)
  80051a:	6a 3f                	push   $0x3f
  80051c:	ff 55 08             	call   *0x8(%ebp)
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	eb 0d                	jmp    800531 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	52                   	push   %edx
  80052b:	ff 55 08             	call   *0x8(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	83 eb 01             	sub    $0x1,%ebx
  800534:	eb 1a                	jmp    800550 <vprintfmt+0x23f>
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800542:	eb 0c                	jmp    800550 <vprintfmt+0x23f>
  800544:	89 75 08             	mov    %esi,0x8(%ebp)
  800547:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800550:	83 c7 01             	add    $0x1,%edi
  800553:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800557:	0f be d0             	movsbl %al,%edx
  80055a:	85 d2                	test   %edx,%edx
  80055c:	74 23                	je     800581 <vprintfmt+0x270>
  80055e:	85 f6                	test   %esi,%esi
  800560:	78 a1                	js     800503 <vprintfmt+0x1f2>
  800562:	83 ee 01             	sub    $0x1,%esi
  800565:	79 9c                	jns    800503 <vprintfmt+0x1f2>
  800567:	89 df                	mov    %ebx,%edi
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056f:	eb 18                	jmp    800589 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 20                	push   $0x20
  800577:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800579:	83 ef 01             	sub    $0x1,%edi
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	eb 08                	jmp    800589 <vprintfmt+0x278>
  800581:	89 df                	mov    %ebx,%edi
  800583:	8b 75 08             	mov    0x8(%ebp),%esi
  800586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800589:	85 ff                	test   %edi,%edi
  80058b:	7f e4                	jg     800571 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 a2 fd ff ff       	jmp    800337 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800595:	83 fa 01             	cmp    $0x1,%edx
  800598:	7e 16                	jle    8005b0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 08             	lea    0x8(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 50 04             	mov    0x4(%eax),%edx
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ae:	eb 32                	jmp    8005e2 <vprintfmt+0x2d1>
	else if (lflag)
  8005b0:	85 d2                	test   %edx,%edx
  8005b2:	74 18                	je     8005cc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 c1                	mov    %eax,%ecx
  8005c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ca:	eb 16                	jmp    8005e2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005da:	89 c1                	mov    %eax,%ecx
  8005dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f1:	79 74                	jns    800667 <vprintfmt+0x356>
				putch('-', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 2d                	push   $0x2d
  8005f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800601:	f7 d8                	neg    %eax
  800603:	83 d2 00             	adc    $0x0,%edx
  800606:	f7 da                	neg    %edx
  800608:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800610:	eb 55                	jmp    800667 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 83 fc ff ff       	call   80029d <getuint>
			base = 10;
  80061a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061f:	eb 46                	jmp    800667 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	e8 74 fc ff ff       	call   80029d <getuint>
			base = 8;
  800629:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062e:	eb 37                	jmp    800667 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 30                	push   $0x30
  800636:	ff d6                	call   *%esi
			putch('x', putdat);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 78                	push   $0x78
  80063e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800650:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800653:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800658:	eb 0d                	jmp    800667 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 3b fc ff ff       	call   80029d <getuint>
			base = 16;
  800662:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800667:	83 ec 0c             	sub    $0xc,%esp
  80066a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066e:	57                   	push   %edi
  80066f:	ff 75 e0             	pushl  -0x20(%ebp)
  800672:	51                   	push   %ecx
  800673:	52                   	push   %edx
  800674:	50                   	push   %eax
  800675:	89 da                	mov    %ebx,%edx
  800677:	89 f0                	mov    %esi,%eax
  800679:	e8 70 fb ff ff       	call   8001ee <printnum>
			break;
  80067e:	83 c4 20             	add    $0x20,%esp
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800684:	e9 ae fc ff ff       	jmp    800337 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	51                   	push   %ecx
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800696:	e9 9c fc ff ff       	jmp    800337 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 25                	push   $0x25
  8006a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 03                	jmp    8006ab <vprintfmt+0x39a>
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006af:	75 f7                	jne    8006a8 <vprintfmt+0x397>
  8006b1:	e9 81 fc ff ff       	jmp    800337 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 18             	sub    $0x18,%esp
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	74 26                	je     800705 <vsnprintf+0x47>
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	7e 22                	jle    800705 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e3:	ff 75 14             	pushl  0x14(%ebp)
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ec:	50                   	push   %eax
  8006ed:	68 d7 02 80 00       	push   $0x8002d7
  8006f2:	e8 1a fc ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb 05                	jmp    80070a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800712:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800715:	50                   	push   %eax
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	ff 75 08             	pushl  0x8(%ebp)
  80071f:	e8 9a ff ff ff       	call   8006be <vsnprintf>
	va_end(ap);

	return rc;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072c:	b8 00 00 00 00       	mov    $0x0,%eax
  800731:	eb 03                	jmp    800736 <strlen+0x10>
		n++;
  800733:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f7                	jne    800733 <strlen+0xd>
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	ba 00 00 00 00       	mov    $0x0,%edx
  80074c:	eb 03                	jmp    800751 <strnlen+0x13>
		n++;
  80074e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800751:	39 c2                	cmp    %eax,%edx
  800753:	74 08                	je     80075d <strnlen+0x1f>
  800755:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800759:	75 f3                	jne    80074e <strnlen+0x10>
  80075b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800769:	89 c2                	mov    %eax,%edx
  80076b:	83 c2 01             	add    $0x1,%edx
  80076e:	83 c1 01             	add    $0x1,%ecx
  800771:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800775:	88 5a ff             	mov    %bl,-0x1(%edx)
  800778:	84 db                	test   %bl,%bl
  80077a:	75 ef                	jne    80076b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077c:	5b                   	pop    %ebx
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800786:	53                   	push   %ebx
  800787:	e8 9a ff ff ff       	call   800726 <strlen>
  80078c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	01 d8                	add    %ebx,%eax
  800794:	50                   	push   %eax
  800795:	e8 c5 ff ff ff       	call   80075f <strcpy>
	return dst;
}
  80079a:	89 d8                	mov    %ebx,%eax
  80079c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	56                   	push   %esi
  8007a5:	53                   	push   %ebx
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ac:	89 f3                	mov    %esi,%ebx
  8007ae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b1:	89 f2                	mov    %esi,%edx
  8007b3:	eb 0f                	jmp    8007c4 <strncpy+0x23>
		*dst++ = *src;
  8007b5:	83 c2 01             	add    $0x1,%edx
  8007b8:	0f b6 01             	movzbl (%ecx),%eax
  8007bb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007be:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	39 da                	cmp    %ebx,%edx
  8007c6:	75 ed                	jne    8007b5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c8:	89 f0                	mov    %esi,%eax
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007dc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007de:	85 d2                	test   %edx,%edx
  8007e0:	74 21                	je     800803 <strlcpy+0x35>
  8007e2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 09                	jmp    8007f3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	83 c1 01             	add    $0x1,%ecx
  8007f0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f3:	39 c2                	cmp    %eax,%edx
  8007f5:	74 09                	je     800800 <strlcpy+0x32>
  8007f7:	0f b6 19             	movzbl (%ecx),%ebx
  8007fa:	84 db                	test   %bl,%bl
  8007fc:	75 ec                	jne    8007ea <strlcpy+0x1c>
  8007fe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800800:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800803:	29 f0                	sub    %esi,%eax
}
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800812:	eb 06                	jmp    80081a <strcmp+0x11>
		p++, q++;
  800814:	83 c1 01             	add    $0x1,%ecx
  800817:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081a:	0f b6 01             	movzbl (%ecx),%eax
  80081d:	84 c0                	test   %al,%al
  80081f:	74 04                	je     800825 <strcmp+0x1c>
  800821:	3a 02                	cmp    (%edx),%al
  800823:	74 ef                	je     800814 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800825:	0f b6 c0             	movzbl %al,%eax
  800828:	0f b6 12             	movzbl (%edx),%edx
  80082b:	29 d0                	sub    %edx,%eax
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 c3                	mov    %eax,%ebx
  80083b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083e:	eb 06                	jmp    800846 <strncmp+0x17>
		n--, p++, q++;
  800840:	83 c0 01             	add    $0x1,%eax
  800843:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800846:	39 d8                	cmp    %ebx,%eax
  800848:	74 15                	je     80085f <strncmp+0x30>
  80084a:	0f b6 08             	movzbl (%eax),%ecx
  80084d:	84 c9                	test   %cl,%cl
  80084f:	74 04                	je     800855 <strncmp+0x26>
  800851:	3a 0a                	cmp    (%edx),%cl
  800853:	74 eb                	je     800840 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 00             	movzbl (%eax),%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
  80085d:	eb 05                	jmp    800864 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800871:	eb 07                	jmp    80087a <strchr+0x13>
		if (*s == c)
  800873:	38 ca                	cmp    %cl,%dl
  800875:	74 0f                	je     800886 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	0f b6 10             	movzbl (%eax),%edx
  80087d:	84 d2                	test   %dl,%dl
  80087f:	75 f2                	jne    800873 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 03                	jmp    800897 <strfind+0xf>
  800894:	83 c0 01             	add    $0x1,%eax
  800897:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	74 04                	je     8008a2 <strfind+0x1a>
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b0:	85 c9                	test   %ecx,%ecx
  8008b2:	74 36                	je     8008ea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ba:	75 28                	jne    8008e4 <memset+0x40>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	75 23                	jne    8008e4 <memset+0x40>
		c &= 0xFF;
  8008c1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c5:	89 d3                	mov    %edx,%ebx
  8008c7:	c1 e3 08             	shl    $0x8,%ebx
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	c1 e6 18             	shl    $0x18,%esi
  8008cf:	89 d0                	mov    %edx,%eax
  8008d1:	c1 e0 10             	shl    $0x10,%eax
  8008d4:	09 f0                	or     %esi,%eax
  8008d6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d8:	89 d8                	mov    %ebx,%eax
  8008da:	09 d0                	or     %edx,%eax
  8008dc:	c1 e9 02             	shr    $0x2,%ecx
  8008df:	fc                   	cld    
  8008e0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e2:	eb 06                	jmp    8008ea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e7:	fc                   	cld    
  8008e8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ea:	89 f8                	mov    %edi,%eax
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ff:	39 c6                	cmp    %eax,%esi
  800901:	73 35                	jae    800938 <memmove+0x47>
  800903:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800906:	39 d0                	cmp    %edx,%eax
  800908:	73 2e                	jae    800938 <memmove+0x47>
		s += n;
		d += n;
  80090a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	09 fe                	or     %edi,%esi
  800911:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800917:	75 13                	jne    80092c <memmove+0x3b>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0e                	jne    80092c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091e:	83 ef 04             	sub    $0x4,%edi
  800921:	8d 72 fc             	lea    -0x4(%edx),%esi
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	fd                   	std    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 09                	jmp    800935 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092c:	83 ef 01             	sub    $0x1,%edi
  80092f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800932:	fd                   	std    
  800933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800935:	fc                   	cld    
  800936:	eb 1d                	jmp    800955 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800938:	89 f2                	mov    %esi,%edx
  80093a:	09 c2                	or     %eax,%edx
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	75 0f                	jne    800950 <memmove+0x5f>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0a                	jne    800950 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800946:	c1 e9 02             	shr    $0x2,%ecx
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 05                	jmp    800955 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800950:	89 c7                	mov    %eax,%edi
  800952:	fc                   	cld    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 87 ff ff ff       	call   8008f1 <memmove>
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	89 c6                	mov    %eax,%esi
  800979:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097c:	eb 1a                	jmp    800998 <memcmp+0x2c>
		if (*s1 != *s2)
  80097e:	0f b6 08             	movzbl (%eax),%ecx
  800981:	0f b6 1a             	movzbl (%edx),%ebx
  800984:	38 d9                	cmp    %bl,%cl
  800986:	74 0a                	je     800992 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800988:	0f b6 c1             	movzbl %cl,%eax
  80098b:	0f b6 db             	movzbl %bl,%ebx
  80098e:	29 d8                	sub    %ebx,%eax
  800990:	eb 0f                	jmp    8009a1 <memcmp+0x35>
		s1++, s2++;
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800998:	39 f0                	cmp    %esi,%eax
  80099a:	75 e2                	jne    80097e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ac:	89 c1                	mov    %eax,%ecx
  8009ae:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	eb 0a                	jmp    8009c1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b7:	0f b6 10             	movzbl (%eax),%edx
  8009ba:	39 da                	cmp    %ebx,%edx
  8009bc:	74 07                	je     8009c5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009be:	83 c0 01             	add    $0x1,%eax
  8009c1:	39 c8                	cmp    %ecx,%eax
  8009c3:	72 f2                	jb     8009b7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d4:	eb 03                	jmp    8009d9 <strtol+0x11>
		s++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d9:	0f b6 01             	movzbl (%ecx),%eax
  8009dc:	3c 20                	cmp    $0x20,%al
  8009de:	74 f6                	je     8009d6 <strtol+0xe>
  8009e0:	3c 09                	cmp    $0x9,%al
  8009e2:	74 f2                	je     8009d6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e4:	3c 2b                	cmp    $0x2b,%al
  8009e6:	75 0a                	jne    8009f2 <strtol+0x2a>
		s++;
  8009e8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f0:	eb 11                	jmp    800a03 <strtol+0x3b>
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f7:	3c 2d                	cmp    $0x2d,%al
  8009f9:	75 08                	jne    800a03 <strtol+0x3b>
		s++, neg = 1;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a09:	75 15                	jne    800a20 <strtol+0x58>
  800a0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0e:	75 10                	jne    800a20 <strtol+0x58>
  800a10:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a14:	75 7c                	jne    800a92 <strtol+0xca>
		s += 2, base = 16;
  800a16:	83 c1 02             	add    $0x2,%ecx
  800a19:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1e:	eb 16                	jmp    800a36 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a20:	85 db                	test   %ebx,%ebx
  800a22:	75 12                	jne    800a36 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a24:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2c:	75 08                	jne    800a36 <strtol+0x6e>
		s++, base = 8;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3e:	0f b6 11             	movzbl (%ecx),%edx
  800a41:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	80 fb 09             	cmp    $0x9,%bl
  800a49:	77 08                	ja     800a53 <strtol+0x8b>
			dig = *s - '0';
  800a4b:	0f be d2             	movsbl %dl,%edx
  800a4e:	83 ea 30             	sub    $0x30,%edx
  800a51:	eb 22                	jmp    800a75 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a53:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a56:	89 f3                	mov    %esi,%ebx
  800a58:	80 fb 19             	cmp    $0x19,%bl
  800a5b:	77 08                	ja     800a65 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5d:	0f be d2             	movsbl %dl,%edx
  800a60:	83 ea 57             	sub    $0x57,%edx
  800a63:	eb 10                	jmp    800a75 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a68:	89 f3                	mov    %esi,%ebx
  800a6a:	80 fb 19             	cmp    $0x19,%bl
  800a6d:	77 16                	ja     800a85 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6f:	0f be d2             	movsbl %dl,%edx
  800a72:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a75:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a78:	7d 0b                	jge    800a85 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a81:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a83:	eb b9                	jmp    800a3e <strtol+0x76>

	if (endptr)
  800a85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a89:	74 0d                	je     800a98 <strtol+0xd0>
		*endptr = (char *) s;
  800a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8e:	89 0e                	mov    %ecx,(%esi)
  800a90:	eb 06                	jmp    800a98 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	74 98                	je     800a2e <strtol+0x66>
  800a96:	eb 9e                	jmp    800a36 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a98:	89 c2                	mov    %eax,%edx
  800a9a:	f7 da                	neg    %edx
  800a9c:	85 ff                	test   %edi,%edi
  800a9e:	0f 45 c2             	cmovne %edx,%eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 c3                	mov    %eax,%ebx
  800ab9:	89 c7                	mov    %eax,%edi
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	ba 00 00 00 00       	mov    $0x0,%edx
  800acf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad4:	89 d1                	mov    %edx,%ecx
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 d7                	mov    %edx,%edi
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af1:	b8 03 00 00 00       	mov    $0x3,%eax
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	89 cb                	mov    %ecx,%ebx
  800afb:	89 cf                	mov    %ecx,%edi
  800afd:	89 ce                	mov    %ecx,%esi
  800aff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	7e 17                	jle    800b1c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	50                   	push   %eax
  800b09:	6a 03                	push   $0x3
  800b0b:	68 9f 2d 80 00       	push   $0x802d9f
  800b10:	6a 23                	push   $0x23
  800b12:	68 bc 2d 80 00       	push   $0x802dbc
  800b17:	e8 e5 f5 ff ff       	call   800101 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_yield>:

void
sys_yield(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	be 00 00 00 00       	mov    $0x0,%esi
  800b70:	b8 04 00 00 00       	mov    $0x4,%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7e:	89 f7                	mov    %esi,%edi
  800b80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 04                	push   $0x4
  800b8c:	68 9f 2d 80 00       	push   $0x802d9f
  800b91:	6a 23                	push   $0x23
  800b93:	68 bc 2d 80 00       	push   $0x802dbc
  800b98:	e8 64 f5 ff ff       	call   800101 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 05                	push   $0x5
  800bce:	68 9f 2d 80 00       	push   $0x802d9f
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 bc 2d 80 00       	push   $0x802dbc
  800bda:	e8 22 f5 ff ff       	call   800101 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	89 df                	mov    %ebx,%edi
  800c02:	89 de                	mov    %ebx,%esi
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 06                	push   $0x6
  800c10:	68 9f 2d 80 00       	push   $0x802d9f
  800c15:	6a 23                	push   $0x23
  800c17:	68 bc 2d 80 00       	push   $0x802dbc
  800c1c:	e8 e0 f4 ff ff       	call   800101 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c37:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 df                	mov    %ebx,%edi
  800c44:	89 de                	mov    %ebx,%esi
  800c46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 08                	push   $0x8
  800c52:	68 9f 2d 80 00       	push   $0x802d9f
  800c57:	6a 23                	push   $0x23
  800c59:	68 bc 2d 80 00       	push   $0x802dbc
  800c5e:	e8 9e f4 ff ff       	call   800101 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 09                	push   $0x9
  800c94:	68 9f 2d 80 00       	push   $0x802d9f
  800c99:	6a 23                	push   $0x23
  800c9b:	68 bc 2d 80 00       	push   $0x802dbc
  800ca0:	e8 5c f4 ff ff       	call   800101 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 0a                	push   $0xa
  800cd6:	68 9f 2d 80 00       	push   $0x802d9f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 bc 2d 80 00       	push   $0x802dbc
  800ce2:	e8 1a f4 ff ff       	call   800101 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800cf5:	be 00 00 00 00       	mov    $0x0,%esi
  800cfa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d20:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 cb                	mov    %ecx,%ebx
  800d2a:	89 cf                	mov    %ecx,%edi
  800d2c:	89 ce                	mov    %ecx,%esi
  800d2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 17                	jle    800d4b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 0d                	push   $0xd
  800d3a:	68 9f 2d 80 00       	push   $0x802d9f
  800d3f:	6a 23                	push   $0x23
  800d41:	68 bc 2d 80 00       	push   $0x802dbc
  800d46:	e8 b6 f3 ff ff       	call   800101 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 cb                	mov    %ecx,%ebx
  800d68:	89 cf                	mov    %ecx,%edi
  800d6a:	89 ce                	mov    %ecx,%esi
  800d6c:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 cb                	mov    %ecx,%ebx
  800d88:	89 cf                	mov    %ecx,%edi
  800d8a:	89 ce                	mov    %ecx,%esi
  800d8c:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9e:	b8 10 00 00 00       	mov    $0x10,%eax
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 cb                	mov    %ecx,%ebx
  800da8:	89 cf                	mov    %ecx,%edi
  800daa:	89 ce                	mov    %ecx,%esi
  800dac:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	53                   	push   %ebx
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dbf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc3:	74 11                	je     800dd6 <pgfault+0x23>
  800dc5:	89 d8                	mov    %ebx,%eax
  800dc7:	c1 e8 0c             	shr    $0xc,%eax
  800dca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd1:	f6 c4 08             	test   $0x8,%ah
  800dd4:	75 14                	jne    800dea <pgfault+0x37>
		panic("faulting access");
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	68 ca 2d 80 00       	push   $0x802dca
  800dde:	6a 1f                	push   $0x1f
  800de0:	68 da 2d 80 00       	push   $0x802dda
  800de5:	e8 17 f3 ff ff       	call   800101 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	6a 07                	push   $0x7
  800def:	68 00 f0 7f 00       	push   $0x7ff000
  800df4:	6a 00                	push   $0x0
  800df6:	e8 67 fd ff ff       	call   800b62 <sys_page_alloc>
	if (r < 0) {
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	79 12                	jns    800e14 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e02:	50                   	push   %eax
  800e03:	68 e5 2d 80 00       	push   $0x802de5
  800e08:	6a 2d                	push   $0x2d
  800e0a:	68 da 2d 80 00       	push   $0x802dda
  800e0f:	e8 ed f2 ff ff       	call   800101 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e14:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	68 00 10 00 00       	push   $0x1000
  800e22:	53                   	push   %ebx
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	e8 2c fb ff ff       	call   800959 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e2d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e34:	53                   	push   %ebx
  800e35:	6a 00                	push   $0x0
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 62 fd ff ff       	call   800ba5 <sys_page_map>
	if (r < 0) {
  800e43:	83 c4 20             	add    $0x20,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 12                	jns    800e5c <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e4a:	50                   	push   %eax
  800e4b:	68 e5 2d 80 00       	push   $0x802de5
  800e50:	6a 34                	push   $0x34
  800e52:	68 da 2d 80 00       	push   $0x802dda
  800e57:	e8 a5 f2 ff ff       	call   800101 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	68 00 f0 7f 00       	push   $0x7ff000
  800e64:	6a 00                	push   $0x0
  800e66:	e8 7c fd ff ff       	call   800be7 <sys_page_unmap>
	if (r < 0) {
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	79 12                	jns    800e84 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e72:	50                   	push   %eax
  800e73:	68 e5 2d 80 00       	push   $0x802de5
  800e78:	6a 38                	push   $0x38
  800e7a:	68 da 2d 80 00       	push   $0x802dda
  800e7f:	e8 7d f2 ff ff       	call   800101 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e92:	68 b3 0d 80 00       	push   $0x800db3
  800e97:	e8 f5 16 00 00       	call   802591 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e9c:	b8 07 00 00 00       	mov    $0x7,%eax
  800ea1:	cd 30                	int    $0x30
  800ea3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 17                	jns    800ec4 <fork+0x3b>
		panic("fork fault %e");
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	68 fe 2d 80 00       	push   $0x802dfe
  800eb5:	68 85 00 00 00       	push   $0x85
  800eba:	68 da 2d 80 00       	push   $0x802dda
  800ebf:	e8 3d f2 ff ff       	call   800101 <_panic>
  800ec4:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eca:	75 24                	jne    800ef0 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ecc:	e8 53 fc ff ff       	call   800b24 <sys_getenvid>
  800ed1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed6:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800edc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee1:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	e9 64 01 00 00       	jmp    801054 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ef0:	83 ec 04             	sub    $0x4,%esp
  800ef3:	6a 07                	push   $0x7
  800ef5:	68 00 f0 bf ee       	push   $0xeebff000
  800efa:	ff 75 e4             	pushl  -0x1c(%ebp)
  800efd:	e8 60 fc ff ff       	call   800b62 <sys_page_alloc>
  800f02:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f05:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f0a:	89 d8                	mov    %ebx,%eax
  800f0c:	c1 e8 16             	shr    $0x16,%eax
  800f0f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f16:	a8 01                	test   $0x1,%al
  800f18:	0f 84 fc 00 00 00    	je     80101a <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f1e:	89 d8                	mov    %ebx,%eax
  800f20:	c1 e8 0c             	shr    $0xc,%eax
  800f23:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	0f 84 e7 00 00 00    	je     80101a <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f33:	89 c6                	mov    %eax,%esi
  800f35:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f38:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3f:	f6 c6 04             	test   $0x4,%dh
  800f42:	74 39                	je     800f7d <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f53:	50                   	push   %eax
  800f54:	56                   	push   %esi
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 47 fc ff ff       	call   800ba5 <sys_page_map>
		if (r < 0) {
  800f5e:	83 c4 20             	add    $0x20,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	0f 89 b1 00 00 00    	jns    80101a <fork+0x191>
		    	panic("sys page map fault %e");
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	68 0c 2e 80 00       	push   $0x802e0c
  800f71:	6a 55                	push   $0x55
  800f73:	68 da 2d 80 00       	push   $0x802dda
  800f78:	e8 84 f1 ff ff       	call   800101 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f7d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f84:	f6 c2 02             	test   $0x2,%dl
  800f87:	75 0c                	jne    800f95 <fork+0x10c>
  800f89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f90:	f6 c4 08             	test   $0x8,%ah
  800f93:	74 5b                	je     800ff0 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	68 05 08 00 00       	push   $0x805
  800f9d:	56                   	push   %esi
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 fe fb ff ff       	call   800ba5 <sys_page_map>
		if (r < 0) {
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 14                	jns    800fc2 <fork+0x139>
		    	panic("sys page map fault %e");
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 0c 2e 80 00       	push   $0x802e0c
  800fb6:	6a 5c                	push   $0x5c
  800fb8:	68 da 2d 80 00       	push   $0x802dda
  800fbd:	e8 3f f1 ff ff       	call   800101 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	68 05 08 00 00       	push   $0x805
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	56                   	push   %esi
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 d0 fb ff ff       	call   800ba5 <sys_page_map>
		if (r < 0) {
  800fd5:	83 c4 20             	add    $0x20,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	79 3e                	jns    80101a <fork+0x191>
		    	panic("sys page map fault %e");
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	68 0c 2e 80 00       	push   $0x802e0c
  800fe4:	6a 60                	push   $0x60
  800fe6:	68 da 2d 80 00       	push   $0x802dda
  800feb:	e8 11 f1 ff ff       	call   800101 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	6a 05                	push   $0x5
  800ff5:	56                   	push   %esi
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 a6 fb ff ff       	call   800ba5 <sys_page_map>
		if (r < 0) {
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	79 14                	jns    80101a <fork+0x191>
		    	panic("sys page map fault %e");
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	68 0c 2e 80 00       	push   $0x802e0c
  80100e:	6a 65                	push   $0x65
  801010:	68 da 2d 80 00       	push   $0x802dda
  801015:	e8 e7 f0 ff ff       	call   800101 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80101a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801020:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801026:	0f 85 de fe ff ff    	jne    800f0a <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80102c:	a1 04 50 80 00       	mov    0x805004,%eax
  801031:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	50                   	push   %eax
  80103b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80103e:	57                   	push   %edi
  80103f:	e8 69 fc ff ff       	call   800cad <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801044:	83 c4 08             	add    $0x8,%esp
  801047:	6a 02                	push   $0x2
  801049:	57                   	push   %edi
  80104a:	e8 da fb ff ff       	call   800c29 <sys_env_set_status>
	
	return envid;
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sfork>:

envid_t
sfork(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	a3 08 50 80 00       	mov    %eax,0x805008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801074:	68 c7 00 80 00       	push   $0x8000c7
  801079:	e8 d5 fc ff ff       	call   800d53 <sys_thread_create>

	return id;
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801086:	ff 75 08             	pushl  0x8(%ebp)
  801089:	e8 e5 fc ff ff       	call   800d73 <sys_thread_free>
}
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801099:	ff 75 08             	pushl  0x8(%ebp)
  80109c:	e8 f2 fc ff ff       	call   800d93 <sys_thread_join>
}
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	56                   	push   %esi
  8010aa:	53                   	push   %ebx
  8010ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	6a 07                	push   $0x7
  8010b6:	6a 00                	push   $0x0
  8010b8:	56                   	push   %esi
  8010b9:	e8 a4 fa ff ff       	call   800b62 <sys_page_alloc>
	if (r < 0) {
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	79 15                	jns    8010da <queue_append+0x34>
		panic("%e\n", r);
  8010c5:	50                   	push   %eax
  8010c6:	68 52 2e 80 00       	push   $0x802e52
  8010cb:	68 d5 00 00 00       	push   $0xd5
  8010d0:	68 da 2d 80 00       	push   $0x802dda
  8010d5:	e8 27 f0 ff ff       	call   800101 <_panic>
	}	

	wt->envid = envid;
  8010da:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8010e0:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010e3:	75 13                	jne    8010f8 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8010e5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010ec:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010f3:	00 00 00 
  8010f6:	eb 1b                	jmp    801113 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8010f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8010fb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801102:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801109:	00 00 00 
		queue->last = wt;
  80110c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801123:	8b 02                	mov    (%edx),%eax
  801125:	85 c0                	test   %eax,%eax
  801127:	75 17                	jne    801140 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	68 22 2e 80 00       	push   $0x802e22
  801131:	68 ec 00 00 00       	push   $0xec
  801136:	68 da 2d 80 00       	push   $0x802dda
  80113b:	e8 c1 ef ff ff       	call   800101 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801140:	8b 48 04             	mov    0x4(%eax),%ecx
  801143:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801145:	8b 00                	mov    (%eax),%eax
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	53                   	push   %ebx
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801153:	b8 01 00 00 00       	mov    $0x1,%eax
  801158:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80115b:	85 c0                	test   %eax,%eax
  80115d:	74 45                	je     8011a4 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80115f:	e8 c0 f9 ff ff       	call   800b24 <sys_getenvid>
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	83 c3 04             	add    $0x4,%ebx
  80116a:	53                   	push   %ebx
  80116b:	50                   	push   %eax
  80116c:	e8 35 ff ff ff       	call   8010a6 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801171:	e8 ae f9 ff ff       	call   800b24 <sys_getenvid>
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	6a 04                	push   $0x4
  80117b:	50                   	push   %eax
  80117c:	e8 a8 fa ff ff       	call   800c29 <sys_env_set_status>

		if (r < 0) {
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	79 15                	jns    80119d <mutex_lock+0x54>
			panic("%e\n", r);
  801188:	50                   	push   %eax
  801189:	68 52 2e 80 00       	push   $0x802e52
  80118e:	68 02 01 00 00       	push   $0x102
  801193:	68 da 2d 80 00       	push   $0x802dda
  801198:	e8 64 ef ff ff       	call   800101 <_panic>
		}
		sys_yield();
  80119d:	e8 a1 f9 ff ff       	call   800b43 <sys_yield>
  8011a2:	eb 08                	jmp    8011ac <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8011a4:	e8 7b f9 ff ff       	call   800b24 <sys_getenvid>
  8011a9:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8011ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8011bb:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8011bf:	74 36                	je     8011f7 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	8d 43 04             	lea    0x4(%ebx),%eax
  8011c7:	50                   	push   %eax
  8011c8:	e8 4d ff ff ff       	call   80111a <queue_pop>
  8011cd:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	6a 02                	push   $0x2
  8011d5:	50                   	push   %eax
  8011d6:	e8 4e fa ff ff       	call   800c29 <sys_env_set_status>
		if (r < 0) {
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	79 1d                	jns    8011ff <mutex_unlock+0x4e>
			panic("%e\n", r);
  8011e2:	50                   	push   %eax
  8011e3:	68 52 2e 80 00       	push   $0x802e52
  8011e8:	68 16 01 00 00       	push   $0x116
  8011ed:	68 da 2d 80 00       	push   $0x802dda
  8011f2:	e8 0a ef ff ff       	call   800101 <_panic>
  8011f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fc:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8011ff:	e8 3f f9 ff ff       	call   800b43 <sys_yield>
}
  801204:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	53                   	push   %ebx
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801213:	e8 0c f9 ff ff       	call   800b24 <sys_getenvid>
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	6a 07                	push   $0x7
  80121d:	53                   	push   %ebx
  80121e:	50                   	push   %eax
  80121f:	e8 3e f9 ff ff       	call   800b62 <sys_page_alloc>
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 15                	jns    801240 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80122b:	50                   	push   %eax
  80122c:	68 3d 2e 80 00       	push   $0x802e3d
  801231:	68 23 01 00 00       	push   $0x123
  801236:	68 da 2d 80 00       	push   $0x802dda
  80123b:	e8 c1 ee ff ff       	call   800101 <_panic>
	}	
	mtx->locked = 0;
  801240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801246:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80124d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801254:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80125b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801268:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80126b:	eb 20                	jmp    80128d <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80126d:	83 ec 0c             	sub    $0xc,%esp
  801270:	56                   	push   %esi
  801271:	e8 a4 fe ff ff       	call   80111a <queue_pop>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	6a 02                	push   $0x2
  80127b:	50                   	push   %eax
  80127c:	e8 a8 f9 ff ff       	call   800c29 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801281:	8b 43 04             	mov    0x4(%ebx),%eax
  801284:	8b 40 04             	mov    0x4(%eax),%eax
  801287:	89 43 04             	mov    %eax,0x4(%ebx)
  80128a:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80128d:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801291:	75 da                	jne    80126d <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801293:	83 ec 04             	sub    $0x4,%esp
  801296:	68 00 10 00 00       	push   $0x1000
  80129b:	6a 00                	push   $0x0
  80129d:	53                   	push   %ebx
  80129e:	e8 01 f6 ff ff       	call   8008a4 <memset>
	mtx = NULL;
}
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5e                   	pop    %esi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b8:	c1 e8 0c             	shr    $0xc,%eax
}
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012cd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012da:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	c1 ea 16             	shr    $0x16,%edx
  8012e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012eb:	f6 c2 01             	test   $0x1,%dl
  8012ee:	74 11                	je     801301 <fd_alloc+0x2d>
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	c1 ea 0c             	shr    $0xc,%edx
  8012f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fc:	f6 c2 01             	test   $0x1,%dl
  8012ff:	75 09                	jne    80130a <fd_alloc+0x36>
			*fd_store = fd;
  801301:	89 01                	mov    %eax,(%ecx)
			return 0;
  801303:	b8 00 00 00 00       	mov    $0x0,%eax
  801308:	eb 17                	jmp    801321 <fd_alloc+0x4d>
  80130a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80130f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801314:	75 c9                	jne    8012df <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801316:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80131c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801329:	83 f8 1f             	cmp    $0x1f,%eax
  80132c:	77 36                	ja     801364 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80132e:	c1 e0 0c             	shl    $0xc,%eax
  801331:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801336:	89 c2                	mov    %eax,%edx
  801338:	c1 ea 16             	shr    $0x16,%edx
  80133b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801342:	f6 c2 01             	test   $0x1,%dl
  801345:	74 24                	je     80136b <fd_lookup+0x48>
  801347:	89 c2                	mov    %eax,%edx
  801349:	c1 ea 0c             	shr    $0xc,%edx
  80134c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801353:	f6 c2 01             	test   $0x1,%dl
  801356:	74 1a                	je     801372 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801358:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135b:	89 02                	mov    %eax,(%edx)
	return 0;
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	eb 13                	jmp    801377 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801369:	eb 0c                	jmp    801377 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801370:	eb 05                	jmp    801377 <fd_lookup+0x54>
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801382:	ba d4 2e 80 00       	mov    $0x802ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801387:	eb 13                	jmp    80139c <dev_lookup+0x23>
  801389:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80138c:	39 08                	cmp    %ecx,(%eax)
  80138e:	75 0c                	jne    80139c <dev_lookup+0x23>
			*dev = devtab[i];
  801390:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801393:	89 01                	mov    %eax,(%ecx)
			return 0;
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	eb 31                	jmp    8013cd <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80139c:	8b 02                	mov    (%edx),%eax
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	75 e7                	jne    801389 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a2:	a1 04 50 80 00       	mov    0x805004,%eax
  8013a7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	51                   	push   %ecx
  8013b1:	50                   	push   %eax
  8013b2:	68 58 2e 80 00       	push   $0x802e58
  8013b7:	e8 1e ee ff ff       	call   8001da <cprintf>
	*dev = 0;
  8013bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 10             	sub    $0x10,%esp
  8013d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013e7:	c1 e8 0c             	shr    $0xc,%eax
  8013ea:	50                   	push   %eax
  8013eb:	e8 33 ff ff ff       	call   801323 <fd_lookup>
  8013f0:	83 c4 08             	add    $0x8,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 05                	js     8013fc <fd_close+0x2d>
	    || fd != fd2)
  8013f7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013fa:	74 0c                	je     801408 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013fc:	84 db                	test   %bl,%bl
  8013fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801403:	0f 44 c2             	cmove  %edx,%eax
  801406:	eb 41                	jmp    801449 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140e:	50                   	push   %eax
  80140f:	ff 36                	pushl  (%esi)
  801411:	e8 63 ff ff ff       	call   801379 <dev_lookup>
  801416:	89 c3                	mov    %eax,%ebx
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 1a                	js     801439 <fd_close+0x6a>
		if (dev->dev_close)
  80141f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801422:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801425:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 0b                	je     801439 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	56                   	push   %esi
  801432:	ff d0                	call   *%eax
  801434:	89 c3                	mov    %eax,%ebx
  801436:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	56                   	push   %esi
  80143d:	6a 00                	push   $0x0
  80143f:	e8 a3 f7 ff ff       	call   800be7 <sys_page_unmap>
	return r;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 d8                	mov    %ebx,%eax
}
  801449:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801456:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	ff 75 08             	pushl  0x8(%ebp)
  80145d:	e8 c1 fe ff ff       	call   801323 <fd_lookup>
  801462:	83 c4 08             	add    $0x8,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 10                	js     801479 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	6a 01                	push   $0x1
  80146e:	ff 75 f4             	pushl  -0xc(%ebp)
  801471:	e8 59 ff ff ff       	call   8013cf <fd_close>
  801476:	83 c4 10             	add    $0x10,%esp
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <close_all>:

void
close_all(void)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	53                   	push   %ebx
  80147f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801482:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	53                   	push   %ebx
  80148b:	e8 c0 ff ff ff       	call   801450 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801490:	83 c3 01             	add    $0x1,%ebx
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	83 fb 20             	cmp    $0x20,%ebx
  801499:	75 ec                	jne    801487 <close_all+0xc>
		close(i);
}
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	57                   	push   %edi
  8014a4:	56                   	push   %esi
  8014a5:	53                   	push   %ebx
  8014a6:	83 ec 2c             	sub    $0x2c,%esp
  8014a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	ff 75 08             	pushl  0x8(%ebp)
  8014b3:	e8 6b fe ff ff       	call   801323 <fd_lookup>
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	0f 88 c1 00 00 00    	js     801584 <dup+0xe4>
		return r;
	close(newfdnum);
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	56                   	push   %esi
  8014c7:	e8 84 ff ff ff       	call   801450 <close>

	newfd = INDEX2FD(newfdnum);
  8014cc:	89 f3                	mov    %esi,%ebx
  8014ce:	c1 e3 0c             	shl    $0xc,%ebx
  8014d1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014d7:	83 c4 04             	add    $0x4,%esp
  8014da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014dd:	e8 db fd ff ff       	call   8012bd <fd2data>
  8014e2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014e4:	89 1c 24             	mov    %ebx,(%esp)
  8014e7:	e8 d1 fd ff ff       	call   8012bd <fd2data>
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f2:	89 f8                	mov    %edi,%eax
  8014f4:	c1 e8 16             	shr    $0x16,%eax
  8014f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014fe:	a8 01                	test   $0x1,%al
  801500:	74 37                	je     801539 <dup+0x99>
  801502:	89 f8                	mov    %edi,%eax
  801504:	c1 e8 0c             	shr    $0xc,%eax
  801507:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150e:	f6 c2 01             	test   $0x1,%dl
  801511:	74 26                	je     801539 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801513:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	25 07 0e 00 00       	and    $0xe07,%eax
  801522:	50                   	push   %eax
  801523:	ff 75 d4             	pushl  -0x2c(%ebp)
  801526:	6a 00                	push   $0x0
  801528:	57                   	push   %edi
  801529:	6a 00                	push   $0x0
  80152b:	e8 75 f6 ff ff       	call   800ba5 <sys_page_map>
  801530:	89 c7                	mov    %eax,%edi
  801532:	83 c4 20             	add    $0x20,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 2e                	js     801567 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801539:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80153c:	89 d0                	mov    %edx,%eax
  80153e:	c1 e8 0c             	shr    $0xc,%eax
  801541:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	25 07 0e 00 00       	and    $0xe07,%eax
  801550:	50                   	push   %eax
  801551:	53                   	push   %ebx
  801552:	6a 00                	push   $0x0
  801554:	52                   	push   %edx
  801555:	6a 00                	push   $0x0
  801557:	e8 49 f6 ff ff       	call   800ba5 <sys_page_map>
  80155c:	89 c7                	mov    %eax,%edi
  80155e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801561:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801563:	85 ff                	test   %edi,%edi
  801565:	79 1d                	jns    801584 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	6a 00                	push   $0x0
  80156d:	e8 75 f6 ff ff       	call   800be7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	ff 75 d4             	pushl  -0x2c(%ebp)
  801578:	6a 00                	push   $0x0
  80157a:	e8 68 f6 ff ff       	call   800be7 <sys_page_unmap>
	return r;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	89 f8                	mov    %edi,%eax
}
  801584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 14             	sub    $0x14,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	53                   	push   %ebx
  80159b:	e8 83 fd ff ff       	call   801323 <fd_lookup>
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 70                	js     801619 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b3:	ff 30                	pushl  (%eax)
  8015b5:	e8 bf fd ff ff       	call   801379 <dev_lookup>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 4f                	js     801610 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015c4:	8b 42 08             	mov    0x8(%edx),%eax
  8015c7:	83 e0 03             	and    $0x3,%eax
  8015ca:	83 f8 01             	cmp    $0x1,%eax
  8015cd:	75 24                	jne    8015f3 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cf:	a1 04 50 80 00       	mov    0x805004,%eax
  8015d4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	53                   	push   %ebx
  8015de:	50                   	push   %eax
  8015df:	68 99 2e 80 00       	push   $0x802e99
  8015e4:	e8 f1 eb ff ff       	call   8001da <cprintf>
		return -E_INVAL;
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f1:	eb 26                	jmp    801619 <read+0x8d>
	}
	if (!dev->dev_read)
  8015f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f6:	8b 40 08             	mov    0x8(%eax),%eax
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	74 17                	je     801614 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	ff 75 10             	pushl  0x10(%ebp)
  801603:	ff 75 0c             	pushl  0xc(%ebp)
  801606:	52                   	push   %edx
  801607:	ff d0                	call   *%eax
  801609:	89 c2                	mov    %eax,%edx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 09                	jmp    801619 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801610:	89 c2                	mov    %eax,%edx
  801612:	eb 05                	jmp    801619 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801614:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801619:	89 d0                	mov    %edx,%eax
  80161b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	8b 7d 08             	mov    0x8(%ebp),%edi
  80162c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801634:	eb 21                	jmp    801657 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	89 f0                	mov    %esi,%eax
  80163b:	29 d8                	sub    %ebx,%eax
  80163d:	50                   	push   %eax
  80163e:	89 d8                	mov    %ebx,%eax
  801640:	03 45 0c             	add    0xc(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	57                   	push   %edi
  801645:	e8 42 ff ff ff       	call   80158c <read>
		if (m < 0)
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 10                	js     801661 <readn+0x41>
			return m;
		if (m == 0)
  801651:	85 c0                	test   %eax,%eax
  801653:	74 0a                	je     80165f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801655:	01 c3                	add    %eax,%ebx
  801657:	39 f3                	cmp    %esi,%ebx
  801659:	72 db                	jb     801636 <readn+0x16>
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	eb 02                	jmp    801661 <readn+0x41>
  80165f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801661:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801664:	5b                   	pop    %ebx
  801665:	5e                   	pop    %esi
  801666:	5f                   	pop    %edi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	53                   	push   %ebx
  80166d:	83 ec 14             	sub    $0x14,%esp
  801670:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801673:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801676:	50                   	push   %eax
  801677:	53                   	push   %ebx
  801678:	e8 a6 fc ff ff       	call   801323 <fd_lookup>
  80167d:	83 c4 08             	add    $0x8,%esp
  801680:	89 c2                	mov    %eax,%edx
  801682:	85 c0                	test   %eax,%eax
  801684:	78 6b                	js     8016f1 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801690:	ff 30                	pushl  (%eax)
  801692:	e8 e2 fc ff ff       	call   801379 <dev_lookup>
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 4a                	js     8016e8 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a5:	75 24                	jne    8016cb <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a7:	a1 04 50 80 00       	mov    0x805004,%eax
  8016ac:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	53                   	push   %ebx
  8016b6:	50                   	push   %eax
  8016b7:	68 b5 2e 80 00       	push   $0x802eb5
  8016bc:	e8 19 eb ff ff       	call   8001da <cprintf>
		return -E_INVAL;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c9:	eb 26                	jmp    8016f1 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d1:	85 d2                	test   %edx,%edx
  8016d3:	74 17                	je     8016ec <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	ff 75 10             	pushl  0x10(%ebp)
  8016db:	ff 75 0c             	pushl  0xc(%ebp)
  8016de:	50                   	push   %eax
  8016df:	ff d2                	call   *%edx
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	eb 09                	jmp    8016f1 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	eb 05                	jmp    8016f1 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f1:	89 d0                	mov    %edx,%eax
  8016f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	ff 75 08             	pushl  0x8(%ebp)
  801705:	e8 19 fc ff ff       	call   801323 <fd_lookup>
  80170a:	83 c4 08             	add    $0x8,%esp
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 0e                	js     80171f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801711:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801714:	8b 55 0c             	mov    0xc(%ebp),%edx
  801717:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	53                   	push   %ebx
  801725:	83 ec 14             	sub    $0x14,%esp
  801728:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	53                   	push   %ebx
  801730:	e8 ee fb ff ff       	call   801323 <fd_lookup>
  801735:	83 c4 08             	add    $0x8,%esp
  801738:	89 c2                	mov    %eax,%edx
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 68                	js     8017a6 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801748:	ff 30                	pushl  (%eax)
  80174a:	e8 2a fc ff ff       	call   801379 <dev_lookup>
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	78 47                	js     80179d <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801759:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175d:	75 24                	jne    801783 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80175f:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801764:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	53                   	push   %ebx
  80176e:	50                   	push   %eax
  80176f:	68 78 2e 80 00       	push   $0x802e78
  801774:	e8 61 ea ff ff       	call   8001da <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801781:	eb 23                	jmp    8017a6 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801783:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801786:	8b 52 18             	mov    0x18(%edx),%edx
  801789:	85 d2                	test   %edx,%edx
  80178b:	74 14                	je     8017a1 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	ff 75 0c             	pushl  0xc(%ebp)
  801793:	50                   	push   %eax
  801794:	ff d2                	call   *%edx
  801796:	89 c2                	mov    %eax,%edx
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	eb 09                	jmp    8017a6 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	eb 05                	jmp    8017a6 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a6:	89 d0                	mov    %edx,%eax
  8017a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    

008017ad <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 14             	sub    $0x14,%esp
  8017b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	ff 75 08             	pushl  0x8(%ebp)
  8017be:	e8 60 fb ff ff       	call   801323 <fd_lookup>
  8017c3:	83 c4 08             	add    $0x8,%esp
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	78 58                	js     801824 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d2:	50                   	push   %eax
  8017d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d6:	ff 30                	pushl  (%eax)
  8017d8:	e8 9c fb ff ff       	call   801379 <dev_lookup>
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	78 37                	js     80181b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017eb:	74 32                	je     80181f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ed:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f7:	00 00 00 
	stat->st_isdir = 0;
  8017fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801801:	00 00 00 
	stat->st_dev = dev;
  801804:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	53                   	push   %ebx
  80180e:	ff 75 f0             	pushl  -0x10(%ebp)
  801811:	ff 50 14             	call   *0x14(%eax)
  801814:	89 c2                	mov    %eax,%edx
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	eb 09                	jmp    801824 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	eb 05                	jmp    801824 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80181f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801824:	89 d0                	mov    %edx,%eax
  801826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	6a 00                	push   $0x0
  801835:	ff 75 08             	pushl  0x8(%ebp)
  801838:	e8 e3 01 00 00       	call   801a20 <open>
  80183d:	89 c3                	mov    %eax,%ebx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 1b                	js     801861 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	e8 5b ff ff ff       	call   8017ad <fstat>
  801852:	89 c6                	mov    %eax,%esi
	close(fd);
  801854:	89 1c 24             	mov    %ebx,(%esp)
  801857:	e8 f4 fb ff ff       	call   801450 <close>
	return r;
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	89 f0                	mov    %esi,%eax
}
  801861:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	89 c6                	mov    %eax,%esi
  80186f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801871:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801878:	75 12                	jne    80188c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	6a 01                	push   $0x1
  80187f:	e8 79 0e 00 00       	call   8026fd <ipc_find_env>
  801884:	a3 00 50 80 00       	mov    %eax,0x805000
  801889:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188c:	6a 07                	push   $0x7
  80188e:	68 00 60 80 00       	push   $0x806000
  801893:	56                   	push   %esi
  801894:	ff 35 00 50 80 00    	pushl  0x805000
  80189a:	e8 fc 0d 00 00       	call   80269b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80189f:	83 c4 0c             	add    $0xc,%esp
  8018a2:	6a 00                	push   $0x0
  8018a4:	53                   	push   %ebx
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 74 0d 00 00       	call   802620 <ipc_recv>
}
  8018ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bf:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8018c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c7:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d1:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d6:	e8 8d ff ff ff       	call   801868 <fsipc>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e9:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8018f8:	e8 6b ff ff ff       	call   801868 <fsipc>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	53                   	push   %ebx
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	8b 40 0c             	mov    0xc(%eax),%eax
  80190f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801914:	ba 00 00 00 00       	mov    $0x0,%edx
  801919:	b8 05 00 00 00       	mov    $0x5,%eax
  80191e:	e8 45 ff ff ff       	call   801868 <fsipc>
  801923:	85 c0                	test   %eax,%eax
  801925:	78 2c                	js     801953 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	68 00 60 80 00       	push   $0x806000
  80192f:	53                   	push   %ebx
  801930:	e8 2a ee ff ff       	call   80075f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801935:	a1 80 60 80 00       	mov    0x806080,%eax
  80193a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801940:	a1 84 60 80 00       	mov    0x806084,%eax
  801945:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801961:	8b 55 08             	mov    0x8(%ebp),%edx
  801964:	8b 52 0c             	mov    0xc(%edx),%edx
  801967:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80196d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801972:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801977:	0f 47 c2             	cmova  %edx,%eax
  80197a:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80197f:	50                   	push   %eax
  801980:	ff 75 0c             	pushl  0xc(%ebp)
  801983:	68 08 60 80 00       	push   $0x806008
  801988:	e8 64 ef ff ff       	call   8008f1 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 04 00 00 00       	mov    $0x4,%eax
  801997:	e8 cc fe ff ff       	call   801868 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ac:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8019b1:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c1:	e8 a2 fe ff ff       	call   801868 <fsipc>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 4b                	js     801a17 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019cc:	39 c6                	cmp    %eax,%esi
  8019ce:	73 16                	jae    8019e6 <devfile_read+0x48>
  8019d0:	68 e4 2e 80 00       	push   $0x802ee4
  8019d5:	68 eb 2e 80 00       	push   $0x802eeb
  8019da:	6a 7c                	push   $0x7c
  8019dc:	68 00 2f 80 00       	push   $0x802f00
  8019e1:	e8 1b e7 ff ff       	call   800101 <_panic>
	assert(r <= PGSIZE);
  8019e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019eb:	7e 16                	jle    801a03 <devfile_read+0x65>
  8019ed:	68 0b 2f 80 00       	push   $0x802f0b
  8019f2:	68 eb 2e 80 00       	push   $0x802eeb
  8019f7:	6a 7d                	push   $0x7d
  8019f9:	68 00 2f 80 00       	push   $0x802f00
  8019fe:	e8 fe e6 ff ff       	call   800101 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a03:	83 ec 04             	sub    $0x4,%esp
  801a06:	50                   	push   %eax
  801a07:	68 00 60 80 00       	push   $0x806000
  801a0c:	ff 75 0c             	pushl  0xc(%ebp)
  801a0f:	e8 dd ee ff ff       	call   8008f1 <memmove>
	return r;
  801a14:	83 c4 10             	add    $0x10,%esp
}
  801a17:	89 d8                	mov    %ebx,%eax
  801a19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	53                   	push   %ebx
  801a24:	83 ec 20             	sub    $0x20,%esp
  801a27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a2a:	53                   	push   %ebx
  801a2b:	e8 f6 ec ff ff       	call   800726 <strlen>
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a38:	7f 67                	jg     801aa1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a40:	50                   	push   %eax
  801a41:	e8 8e f8 ff ff       	call   8012d4 <fd_alloc>
  801a46:	83 c4 10             	add    $0x10,%esp
		return r;
  801a49:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	78 57                	js     801aa6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a4f:	83 ec 08             	sub    $0x8,%esp
  801a52:	53                   	push   %ebx
  801a53:	68 00 60 80 00       	push   $0x806000
  801a58:	e8 02 ed ff ff       	call   80075f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a60:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a68:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6d:	e8 f6 fd ff ff       	call   801868 <fsipc>
  801a72:	89 c3                	mov    %eax,%ebx
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	85 c0                	test   %eax,%eax
  801a79:	79 14                	jns    801a8f <open+0x6f>
		fd_close(fd, 0);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	6a 00                	push   $0x0
  801a80:	ff 75 f4             	pushl  -0xc(%ebp)
  801a83:	e8 47 f9 ff ff       	call   8013cf <fd_close>
		return r;
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	89 da                	mov    %ebx,%edx
  801a8d:	eb 17                	jmp    801aa6 <open+0x86>
	}

	return fd2num(fd);
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	ff 75 f4             	pushl  -0xc(%ebp)
  801a95:	e8 13 f8 ff ff       	call   8012ad <fd2num>
  801a9a:	89 c2                	mov    %eax,%edx
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	eb 05                	jmp    801aa6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aa1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aa6:	89 d0                	mov    %edx,%eax
  801aa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ab3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab8:	b8 08 00 00 00       	mov    $0x8,%eax
  801abd:	e8 a6 fd ff ff       	call   801868 <fsipc>
}
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	57                   	push   %edi
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801ad0:	6a 00                	push   $0x0
  801ad2:	ff 75 08             	pushl  0x8(%ebp)
  801ad5:	e8 46 ff ff ff       	call   801a20 <open>
  801ada:	89 c7                	mov    %eax,%edi
  801adc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 8c 04 00 00    	js     801f79 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801aed:	83 ec 04             	sub    $0x4,%esp
  801af0:	68 00 02 00 00       	push   $0x200
  801af5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801afb:	50                   	push   %eax
  801afc:	57                   	push   %edi
  801afd:	e8 1e fb ff ff       	call   801620 <readn>
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b0a:	75 0c                	jne    801b18 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801b0c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b13:	45 4c 46 
  801b16:	74 33                	je     801b4b <spawn+0x87>
		close(fd);
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b21:	e8 2a f9 ff ff       	call   801450 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b26:	83 c4 0c             	add    $0xc,%esp
  801b29:	68 7f 45 4c 46       	push   $0x464c457f
  801b2e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801b34:	68 17 2f 80 00       	push   $0x802f17
  801b39:	e8 9c e6 ff ff       	call   8001da <cprintf>
		return -E_NOT_EXEC;
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801b46:	e9 e1 04 00 00       	jmp    80202c <spawn+0x568>
  801b4b:	b8 07 00 00 00       	mov    $0x7,%eax
  801b50:	cd 30                	int    $0x30
  801b52:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801b58:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	0f 88 1e 04 00 00    	js     801f84 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b66:	89 c6                	mov    %eax,%esi
  801b68:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b6e:	69 f6 d4 00 00 00    	imul   $0xd4,%esi,%esi
  801b74:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b7a:	81 c6 58 00 c0 ee    	add    $0xeec00058,%esi
  801b80:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b87:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b8d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b93:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b98:	be 00 00 00 00       	mov    $0x0,%esi
  801b9d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ba0:	eb 13                	jmp    801bb5 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	50                   	push   %eax
  801ba6:	e8 7b eb ff ff       	call   800726 <strlen>
  801bab:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801baf:	83 c3 01             	add    $0x1,%ebx
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801bbc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	75 df                	jne    801ba2 <spawn+0xde>
  801bc3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801bc9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801bcf:	bf 00 10 40 00       	mov    $0x401000,%edi
  801bd4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801bd6:	89 fa                	mov    %edi,%edx
  801bd8:	83 e2 fc             	and    $0xfffffffc,%edx
  801bdb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801be2:	29 c2                	sub    %eax,%edx
  801be4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801bea:	8d 42 f8             	lea    -0x8(%edx),%eax
  801bed:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801bf2:	0f 86 a2 03 00 00    	jbe    801f9a <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	6a 07                	push   $0x7
  801bfd:	68 00 00 40 00       	push   $0x400000
  801c02:	6a 00                	push   $0x0
  801c04:	e8 59 ef ff ff       	call   800b62 <sys_page_alloc>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 90 03 00 00    	js     801fa4 <spawn+0x4e0>
  801c14:	be 00 00 00 00       	mov    $0x0,%esi
  801c19:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801c1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c22:	eb 30                	jmp    801c54 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801c24:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c2a:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c30:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801c39:	57                   	push   %edi
  801c3a:	e8 20 eb ff ff       	call   80075f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c3f:	83 c4 04             	add    $0x4,%esp
  801c42:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801c45:	e8 dc ea ff ff       	call   800726 <strlen>
  801c4a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c4e:	83 c6 01             	add    $0x1,%esi
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801c5a:	7f c8                	jg     801c24 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c5c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c62:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801c68:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c6f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c75:	74 19                	je     801c90 <spawn+0x1cc>
  801c77:	68 a4 2f 80 00       	push   $0x802fa4
  801c7c:	68 eb 2e 80 00       	push   $0x802eeb
  801c81:	68 f2 00 00 00       	push   $0xf2
  801c86:	68 31 2f 80 00       	push   $0x802f31
  801c8b:	e8 71 e4 ff ff       	call   800101 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c90:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c9d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ca0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ca6:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ca9:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801caf:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801cb5:	83 ec 0c             	sub    $0xc,%esp
  801cb8:	6a 07                	push   $0x7
  801cba:	68 00 d0 bf ee       	push   $0xeebfd000
  801cbf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cc5:	68 00 00 40 00       	push   $0x400000
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 d4 ee ff ff       	call   800ba5 <sys_page_map>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	83 c4 20             	add    $0x20,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	0f 88 3c 03 00 00    	js     80201a <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cde:	83 ec 08             	sub    $0x8,%esp
  801ce1:	68 00 00 40 00       	push   $0x400000
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 fa ee ff ff       	call   800be7 <sys_page_unmap>
  801ced:	89 c3                	mov    %eax,%ebx
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	0f 88 20 03 00 00    	js     80201a <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cfa:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801d00:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801d07:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d0d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801d14:	00 00 00 
  801d17:	e9 88 01 00 00       	jmp    801ea4 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801d1c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801d22:	83 38 01             	cmpl   $0x1,(%eax)
  801d25:	0f 85 6b 01 00 00    	jne    801e96 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d2b:	89 c2                	mov    %eax,%edx
  801d2d:	8b 40 18             	mov    0x18(%eax),%eax
  801d30:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d36:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d39:	83 f8 01             	cmp    $0x1,%eax
  801d3c:	19 c0                	sbb    %eax,%eax
  801d3e:	83 e0 fe             	and    $0xfffffffe,%eax
  801d41:	83 c0 07             	add    $0x7,%eax
  801d44:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	8b 7a 04             	mov    0x4(%edx),%edi
  801d4f:	89 f9                	mov    %edi,%ecx
  801d51:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801d57:	8b 7a 10             	mov    0x10(%edx),%edi
  801d5a:	8b 52 14             	mov    0x14(%edx),%edx
  801d5d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801d63:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d66:	89 f0                	mov    %esi,%eax
  801d68:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d6d:	74 14                	je     801d83 <spawn+0x2bf>
		va -= i;
  801d6f:	29 c6                	sub    %eax,%esi
		memsz += i;
  801d71:	01 c2                	add    %eax,%edx
  801d73:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801d79:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801d7b:	29 c1                	sub    %eax,%ecx
  801d7d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d88:	e9 f7 00 00 00       	jmp    801e84 <spawn+0x3c0>
		if (i >= filesz) {
  801d8d:	39 fb                	cmp    %edi,%ebx
  801d8f:	72 27                	jb     801db8 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d91:	83 ec 04             	sub    $0x4,%esp
  801d94:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d9a:	56                   	push   %esi
  801d9b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801da1:	e8 bc ed ff ff       	call   800b62 <sys_page_alloc>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	0f 89 c7 00 00 00    	jns    801e78 <spawn+0x3b4>
  801db1:	89 c3                	mov    %eax,%ebx
  801db3:	e9 fd 01 00 00       	jmp    801fb5 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801db8:	83 ec 04             	sub    $0x4,%esp
  801dbb:	6a 07                	push   $0x7
  801dbd:	68 00 00 40 00       	push   $0x400000
  801dc2:	6a 00                	push   $0x0
  801dc4:	e8 99 ed ff ff       	call   800b62 <sys_page_alloc>
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	0f 88 d7 01 00 00    	js     801fab <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ddd:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dea:	e8 09 f9 ff ff       	call   8016f8 <seek>
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	85 c0                	test   %eax,%eax
  801df4:	0f 88 b5 01 00 00    	js     801faf <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dfa:	83 ec 04             	sub    $0x4,%esp
  801dfd:	89 f8                	mov    %edi,%eax
  801dff:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801e05:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e0a:	ba 00 10 00 00       	mov    $0x1000,%edx
  801e0f:	0f 47 c2             	cmova  %edx,%eax
  801e12:	50                   	push   %eax
  801e13:	68 00 00 40 00       	push   $0x400000
  801e18:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e1e:	e8 fd f7 ff ff       	call   801620 <readn>
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	85 c0                	test   %eax,%eax
  801e28:	0f 88 85 01 00 00    	js     801fb3 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e37:	56                   	push   %esi
  801e38:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e3e:	68 00 00 40 00       	push   $0x400000
  801e43:	6a 00                	push   $0x0
  801e45:	e8 5b ed ff ff       	call   800ba5 <sys_page_map>
  801e4a:	83 c4 20             	add    $0x20,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	79 15                	jns    801e66 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801e51:	50                   	push   %eax
  801e52:	68 3d 2f 80 00       	push   $0x802f3d
  801e57:	68 25 01 00 00       	push   $0x125
  801e5c:	68 31 2f 80 00       	push   $0x802f31
  801e61:	e8 9b e2 ff ff       	call   800101 <_panic>
			sys_page_unmap(0, UTEMP);
  801e66:	83 ec 08             	sub    $0x8,%esp
  801e69:	68 00 00 40 00       	push   $0x400000
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 72 ed ff ff       	call   800be7 <sys_page_unmap>
  801e75:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e7e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801e84:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801e8a:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801e90:	0f 82 f7 fe ff ff    	jb     801d8d <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e96:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801e9d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801ea4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801eab:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801eb1:	0f 8c 65 fe ff ff    	jl     801d1c <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ec0:	e8 8b f5 ff ff       	call   801450 <close>
  801ec5:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ecd:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801ed3:	89 d8                	mov    %ebx,%eax
  801ed5:	c1 e8 16             	shr    $0x16,%eax
  801ed8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801edf:	a8 01                	test   $0x1,%al
  801ee1:	74 42                	je     801f25 <spawn+0x461>
  801ee3:	89 d8                	mov    %ebx,%eax
  801ee5:	c1 e8 0c             	shr    $0xc,%eax
  801ee8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801eef:	f6 c2 01             	test   $0x1,%dl
  801ef2:	74 31                	je     801f25 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801ef4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801efb:	f6 c6 04             	test   $0x4,%dh
  801efe:	74 25                	je     801f25 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801f00:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	25 07 0e 00 00       	and    $0xe07,%eax
  801f0f:	50                   	push   %eax
  801f10:	53                   	push   %ebx
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	6a 00                	push   $0x0
  801f15:	e8 8b ec ff ff       	call   800ba5 <sys_page_map>
			if (r < 0) {
  801f1a:	83 c4 20             	add    $0x20,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	0f 88 b1 00 00 00    	js     801fd6 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801f25:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f2b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801f31:	75 a0                	jne    801ed3 <spawn+0x40f>
  801f33:	e9 b3 00 00 00       	jmp    801feb <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801f38:	50                   	push   %eax
  801f39:	68 5a 2f 80 00       	push   $0x802f5a
  801f3e:	68 86 00 00 00       	push   $0x86
  801f43:	68 31 2f 80 00       	push   $0x802f31
  801f48:	e8 b4 e1 ff ff       	call   800101 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f4d:	83 ec 08             	sub    $0x8,%esp
  801f50:	6a 02                	push   $0x2
  801f52:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f58:	e8 cc ec ff ff       	call   800c29 <sys_env_set_status>
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	85 c0                	test   %eax,%eax
  801f62:	79 2b                	jns    801f8f <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  801f64:	50                   	push   %eax
  801f65:	68 74 2f 80 00       	push   $0x802f74
  801f6a:	68 89 00 00 00       	push   $0x89
  801f6f:	68 31 2f 80 00       	push   $0x802f31
  801f74:	e8 88 e1 ff ff       	call   800101 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801f79:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801f7f:	e9 a8 00 00 00       	jmp    80202c <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801f84:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801f8a:	e9 9d 00 00 00       	jmp    80202c <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801f8f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801f95:	e9 92 00 00 00       	jmp    80202c <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801f9a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801f9f:	e9 88 00 00 00       	jmp    80202c <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	e9 81 00 00 00       	jmp    80202c <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fab:	89 c3                	mov    %eax,%ebx
  801fad:	eb 06                	jmp    801fb5 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801faf:	89 c3                	mov    %eax,%ebx
  801fb1:	eb 02                	jmp    801fb5 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fb3:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fbe:	e8 20 eb ff ff       	call   800ae3 <sys_env_destroy>
	close(fd);
  801fc3:	83 c4 04             	add    $0x4,%esp
  801fc6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fcc:	e8 7f f4 ff ff       	call   801450 <close>
	return r;
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	eb 56                	jmp    80202c <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801fd6:	50                   	push   %eax
  801fd7:	68 8b 2f 80 00       	push   $0x802f8b
  801fdc:	68 82 00 00 00       	push   $0x82
  801fe1:	68 31 2f 80 00       	push   $0x802f31
  801fe6:	e8 16 e1 ff ff       	call   800101 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801feb:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ff2:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ff5:	83 ec 08             	sub    $0x8,%esp
  801ff8:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802005:	e8 61 ec ff ff       	call   800c6b <sys_env_set_trapframe>
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	0f 89 38 ff ff ff    	jns    801f4d <spawn+0x489>
  802015:	e9 1e ff ff ff       	jmp    801f38 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	68 00 00 40 00       	push   $0x400000
  802022:	6a 00                	push   $0x0
  802024:	e8 be eb ff ff       	call   800be7 <sys_page_unmap>
  802029:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	56                   	push   %esi
  80203a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80203b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80203e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802043:	eb 03                	jmp    802048 <spawnl+0x12>
		argc++;
  802045:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802048:	83 c2 04             	add    $0x4,%edx
  80204b:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80204f:	75 f4                	jne    802045 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802051:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802058:	83 e2 f0             	and    $0xfffffff0,%edx
  80205b:	29 d4                	sub    %edx,%esp
  80205d:	8d 54 24 03          	lea    0x3(%esp),%edx
  802061:	c1 ea 02             	shr    $0x2,%edx
  802064:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80206b:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80206d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802070:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802077:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80207e:	00 
  80207f:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
  802086:	eb 0a                	jmp    802092 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802088:	83 c0 01             	add    $0x1,%eax
  80208b:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80208f:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802092:	39 d0                	cmp    %edx,%eax
  802094:	75 f2                	jne    802088 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802096:	83 ec 08             	sub    $0x8,%esp
  802099:	56                   	push   %esi
  80209a:	ff 75 08             	pushl  0x8(%ebp)
  80209d:	e8 22 fa ff ff       	call   801ac4 <spawn>
}
  8020a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a5:	5b                   	pop    %ebx
  8020a6:	5e                   	pop    %esi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    

008020a9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	56                   	push   %esi
  8020ad:	53                   	push   %ebx
  8020ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	ff 75 08             	pushl  0x8(%ebp)
  8020b7:	e8 01 f2 ff ff       	call   8012bd <fd2data>
  8020bc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020be:	83 c4 08             	add    $0x8,%esp
  8020c1:	68 cc 2f 80 00       	push   $0x802fcc
  8020c6:	53                   	push   %ebx
  8020c7:	e8 93 e6 ff ff       	call   80075f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020cc:	8b 46 04             	mov    0x4(%esi),%eax
  8020cf:	2b 06                	sub    (%esi),%eax
  8020d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020de:	00 00 00 
	stat->st_dev = &devpipe;
  8020e1:	c7 83 88 00 00 00 20 	movl   $0x804020,0x88(%ebx)
  8020e8:	40 80 00 
	return 0;
}
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5d                   	pop    %ebp
  8020f6:	c3                   	ret    

008020f7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	53                   	push   %ebx
  8020fb:	83 ec 0c             	sub    $0xc,%esp
  8020fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802101:	53                   	push   %ebx
  802102:	6a 00                	push   $0x0
  802104:	e8 de ea ff ff       	call   800be7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802109:	89 1c 24             	mov    %ebx,(%esp)
  80210c:	e8 ac f1 ff ff       	call   8012bd <fd2data>
  802111:	83 c4 08             	add    $0x8,%esp
  802114:	50                   	push   %eax
  802115:	6a 00                	push   $0x0
  802117:	e8 cb ea ff ff       	call   800be7 <sys_page_unmap>
}
  80211c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80211f:	c9                   	leave  
  802120:	c3                   	ret    

00802121 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	57                   	push   %edi
  802125:	56                   	push   %esi
  802126:	53                   	push   %ebx
  802127:	83 ec 1c             	sub    $0x1c,%esp
  80212a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80212d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80212f:	a1 04 50 80 00       	mov    0x805004,%eax
  802134:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80213a:	83 ec 0c             	sub    $0xc,%esp
  80213d:	ff 75 e0             	pushl  -0x20(%ebp)
  802140:	e8 fd 05 00 00       	call   802742 <pageref>
  802145:	89 c3                	mov    %eax,%ebx
  802147:	89 3c 24             	mov    %edi,(%esp)
  80214a:	e8 f3 05 00 00       	call   802742 <pageref>
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	39 c3                	cmp    %eax,%ebx
  802154:	0f 94 c1             	sete   %cl
  802157:	0f b6 c9             	movzbl %cl,%ecx
  80215a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80215d:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802163:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  802169:	39 ce                	cmp    %ecx,%esi
  80216b:	74 1e                	je     80218b <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80216d:	39 c3                	cmp    %eax,%ebx
  80216f:	75 be                	jne    80212f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802171:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  802177:	ff 75 e4             	pushl  -0x1c(%ebp)
  80217a:	50                   	push   %eax
  80217b:	56                   	push   %esi
  80217c:	68 d3 2f 80 00       	push   $0x802fd3
  802181:	e8 54 e0 ff ff       	call   8001da <cprintf>
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	eb a4                	jmp    80212f <_pipeisclosed+0xe>
	}
}
  80218b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    

00802196 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	57                   	push   %edi
  80219a:	56                   	push   %esi
  80219b:	53                   	push   %ebx
  80219c:	83 ec 28             	sub    $0x28,%esp
  80219f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021a2:	56                   	push   %esi
  8021a3:	e8 15 f1 ff ff       	call   8012bd <fd2data>
  8021a8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8021b2:	eb 4b                	jmp    8021ff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021b4:	89 da                	mov    %ebx,%edx
  8021b6:	89 f0                	mov    %esi,%eax
  8021b8:	e8 64 ff ff ff       	call   802121 <_pipeisclosed>
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	75 48                	jne    802209 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021c1:	e8 7d e9 ff ff       	call   800b43 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021c6:	8b 43 04             	mov    0x4(%ebx),%eax
  8021c9:	8b 0b                	mov    (%ebx),%ecx
  8021cb:	8d 51 20             	lea    0x20(%ecx),%edx
  8021ce:	39 d0                	cmp    %edx,%eax
  8021d0:	73 e2                	jae    8021b4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021d9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021dc:	89 c2                	mov    %eax,%edx
  8021de:	c1 fa 1f             	sar    $0x1f,%edx
  8021e1:	89 d1                	mov    %edx,%ecx
  8021e3:	c1 e9 1b             	shr    $0x1b,%ecx
  8021e6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021e9:	83 e2 1f             	and    $0x1f,%edx
  8021ec:	29 ca                	sub    %ecx,%edx
  8021ee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021f6:	83 c0 01             	add    $0x1,%eax
  8021f9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021fc:	83 c7 01             	add    $0x1,%edi
  8021ff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802202:	75 c2                	jne    8021c6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802204:	8b 45 10             	mov    0x10(%ebp),%eax
  802207:	eb 05                	jmp    80220e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802209:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80220e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802211:	5b                   	pop    %ebx
  802212:	5e                   	pop    %esi
  802213:	5f                   	pop    %edi
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	57                   	push   %edi
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	83 ec 18             	sub    $0x18,%esp
  80221f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802222:	57                   	push   %edi
  802223:	e8 95 f0 ff ff       	call   8012bd <fd2data>
  802228:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80222a:	83 c4 10             	add    $0x10,%esp
  80222d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802232:	eb 3d                	jmp    802271 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802234:	85 db                	test   %ebx,%ebx
  802236:	74 04                	je     80223c <devpipe_read+0x26>
				return i;
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	eb 44                	jmp    802280 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80223c:	89 f2                	mov    %esi,%edx
  80223e:	89 f8                	mov    %edi,%eax
  802240:	e8 dc fe ff ff       	call   802121 <_pipeisclosed>
  802245:	85 c0                	test   %eax,%eax
  802247:	75 32                	jne    80227b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802249:	e8 f5 e8 ff ff       	call   800b43 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80224e:	8b 06                	mov    (%esi),%eax
  802250:	3b 46 04             	cmp    0x4(%esi),%eax
  802253:	74 df                	je     802234 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802255:	99                   	cltd   
  802256:	c1 ea 1b             	shr    $0x1b,%edx
  802259:	01 d0                	add    %edx,%eax
  80225b:	83 e0 1f             	and    $0x1f,%eax
  80225e:	29 d0                	sub    %edx,%eax
  802260:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802268:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80226b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80226e:	83 c3 01             	add    $0x1,%ebx
  802271:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802274:	75 d8                	jne    80224e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802276:	8b 45 10             	mov    0x10(%ebp),%eax
  802279:	eb 05                	jmp    802280 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80227b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	56                   	push   %esi
  80228c:	53                   	push   %ebx
  80228d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802293:	50                   	push   %eax
  802294:	e8 3b f0 ff ff       	call   8012d4 <fd_alloc>
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	89 c2                	mov    %eax,%edx
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	0f 88 2c 01 00 00    	js     8023d2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a6:	83 ec 04             	sub    $0x4,%esp
  8022a9:	68 07 04 00 00       	push   $0x407
  8022ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b1:	6a 00                	push   $0x0
  8022b3:	e8 aa e8 ff ff       	call   800b62 <sys_page_alloc>
  8022b8:	83 c4 10             	add    $0x10,%esp
  8022bb:	89 c2                	mov    %eax,%edx
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	0f 88 0d 01 00 00    	js     8023d2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022c5:	83 ec 0c             	sub    $0xc,%esp
  8022c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022cb:	50                   	push   %eax
  8022cc:	e8 03 f0 ff ff       	call   8012d4 <fd_alloc>
  8022d1:	89 c3                	mov    %eax,%ebx
  8022d3:	83 c4 10             	add    $0x10,%esp
  8022d6:	85 c0                	test   %eax,%eax
  8022d8:	0f 88 e2 00 00 00    	js     8023c0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022de:	83 ec 04             	sub    $0x4,%esp
  8022e1:	68 07 04 00 00       	push   $0x407
  8022e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8022e9:	6a 00                	push   $0x0
  8022eb:	e8 72 e8 ff ff       	call   800b62 <sys_page_alloc>
  8022f0:	89 c3                	mov    %eax,%ebx
  8022f2:	83 c4 10             	add    $0x10,%esp
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	0f 88 c3 00 00 00    	js     8023c0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022fd:	83 ec 0c             	sub    $0xc,%esp
  802300:	ff 75 f4             	pushl  -0xc(%ebp)
  802303:	e8 b5 ef ff ff       	call   8012bd <fd2data>
  802308:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80230a:	83 c4 0c             	add    $0xc,%esp
  80230d:	68 07 04 00 00       	push   $0x407
  802312:	50                   	push   %eax
  802313:	6a 00                	push   $0x0
  802315:	e8 48 e8 ff ff       	call   800b62 <sys_page_alloc>
  80231a:	89 c3                	mov    %eax,%ebx
  80231c:	83 c4 10             	add    $0x10,%esp
  80231f:	85 c0                	test   %eax,%eax
  802321:	0f 88 89 00 00 00    	js     8023b0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802327:	83 ec 0c             	sub    $0xc,%esp
  80232a:	ff 75 f0             	pushl  -0x10(%ebp)
  80232d:	e8 8b ef ff ff       	call   8012bd <fd2data>
  802332:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802339:	50                   	push   %eax
  80233a:	6a 00                	push   $0x0
  80233c:	56                   	push   %esi
  80233d:	6a 00                	push   $0x0
  80233f:	e8 61 e8 ff ff       	call   800ba5 <sys_page_map>
  802344:	89 c3                	mov    %eax,%ebx
  802346:	83 c4 20             	add    $0x20,%esp
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 55                	js     8023a2 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80234d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802353:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802356:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802362:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802368:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80236b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80236d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802370:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802377:	83 ec 0c             	sub    $0xc,%esp
  80237a:	ff 75 f4             	pushl  -0xc(%ebp)
  80237d:	e8 2b ef ff ff       	call   8012ad <fd2num>
  802382:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802385:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802387:	83 c4 04             	add    $0x4,%esp
  80238a:	ff 75 f0             	pushl  -0x10(%ebp)
  80238d:	e8 1b ef ff ff       	call   8012ad <fd2num>
  802392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802395:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802398:	83 c4 10             	add    $0x10,%esp
  80239b:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a0:	eb 30                	jmp    8023d2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023a2:	83 ec 08             	sub    $0x8,%esp
  8023a5:	56                   	push   %esi
  8023a6:	6a 00                	push   $0x0
  8023a8:	e8 3a e8 ff ff       	call   800be7 <sys_page_unmap>
  8023ad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023b0:	83 ec 08             	sub    $0x8,%esp
  8023b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8023b6:	6a 00                	push   $0x0
  8023b8:	e8 2a e8 ff ff       	call   800be7 <sys_page_unmap>
  8023bd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023c0:	83 ec 08             	sub    $0x8,%esp
  8023c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c6:	6a 00                	push   $0x0
  8023c8:	e8 1a e8 ff ff       	call   800be7 <sys_page_unmap>
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    

008023db <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
  8023de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e4:	50                   	push   %eax
  8023e5:	ff 75 08             	pushl  0x8(%ebp)
  8023e8:	e8 36 ef ff ff       	call   801323 <fd_lookup>
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	78 18                	js     80240c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023f4:	83 ec 0c             	sub    $0xc,%esp
  8023f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8023fa:	e8 be ee ff ff       	call   8012bd <fd2data>
	return _pipeisclosed(fd, p);
  8023ff:	89 c2                	mov    %eax,%edx
  802401:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802404:	e8 18 fd ff ff       	call   802121 <_pipeisclosed>
  802409:	83 c4 10             	add    $0x10,%esp
}
  80240c:	c9                   	leave  
  80240d:	c3                   	ret    

0080240e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80240e:	55                   	push   %ebp
  80240f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802411:	b8 00 00 00 00       	mov    $0x0,%eax
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    

00802418 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80241e:	68 eb 2f 80 00       	push   $0x802feb
  802423:	ff 75 0c             	pushl  0xc(%ebp)
  802426:	e8 34 e3 ff ff       	call   80075f <strcpy>
	return 0;
}
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
  802430:	c9                   	leave  
  802431:	c3                   	ret    

00802432 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	57                   	push   %edi
  802436:	56                   	push   %esi
  802437:	53                   	push   %ebx
  802438:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80243e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802443:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802449:	eb 2d                	jmp    802478 <devcons_write+0x46>
		m = n - tot;
  80244b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80244e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802450:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802453:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802458:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80245b:	83 ec 04             	sub    $0x4,%esp
  80245e:	53                   	push   %ebx
  80245f:	03 45 0c             	add    0xc(%ebp),%eax
  802462:	50                   	push   %eax
  802463:	57                   	push   %edi
  802464:	e8 88 e4 ff ff       	call   8008f1 <memmove>
		sys_cputs(buf, m);
  802469:	83 c4 08             	add    $0x8,%esp
  80246c:	53                   	push   %ebx
  80246d:	57                   	push   %edi
  80246e:	e8 33 e6 ff ff       	call   800aa6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802473:	01 de                	add    %ebx,%esi
  802475:	83 c4 10             	add    $0x10,%esp
  802478:	89 f0                	mov    %esi,%eax
  80247a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80247d:	72 cc                	jb     80244b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80247f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802482:	5b                   	pop    %ebx
  802483:	5e                   	pop    %esi
  802484:	5f                   	pop    %edi
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    

00802487 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	83 ec 08             	sub    $0x8,%esp
  80248d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802492:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802496:	74 2a                	je     8024c2 <devcons_read+0x3b>
  802498:	eb 05                	jmp    80249f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80249a:	e8 a4 e6 ff ff       	call   800b43 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80249f:	e8 20 e6 ff ff       	call   800ac4 <sys_cgetc>
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	74 f2                	je     80249a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	78 16                	js     8024c2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024ac:	83 f8 04             	cmp    $0x4,%eax
  8024af:	74 0c                	je     8024bd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024b4:	88 02                	mov    %al,(%edx)
	return 1;
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	eb 05                	jmp    8024c2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024bd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024c2:	c9                   	leave  
  8024c3:	c3                   	ret    

008024c4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024d0:	6a 01                	push   $0x1
  8024d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024d5:	50                   	push   %eax
  8024d6:	e8 cb e5 ff ff       	call   800aa6 <sys_cputs>
}
  8024db:	83 c4 10             	add    $0x10,%esp
  8024de:	c9                   	leave  
  8024df:	c3                   	ret    

008024e0 <getchar>:

int
getchar(void)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024e6:	6a 01                	push   $0x1
  8024e8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024eb:	50                   	push   %eax
  8024ec:	6a 00                	push   $0x0
  8024ee:	e8 99 f0 ff ff       	call   80158c <read>
	if (r < 0)
  8024f3:	83 c4 10             	add    $0x10,%esp
  8024f6:	85 c0                	test   %eax,%eax
  8024f8:	78 0f                	js     802509 <getchar+0x29>
		return r;
	if (r < 1)
  8024fa:	85 c0                	test   %eax,%eax
  8024fc:	7e 06                	jle    802504 <getchar+0x24>
		return -E_EOF;
	return c;
  8024fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802502:	eb 05                	jmp    802509 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802504:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802509:	c9                   	leave  
  80250a:	c3                   	ret    

0080250b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80250b:	55                   	push   %ebp
  80250c:	89 e5                	mov    %esp,%ebp
  80250e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802514:	50                   	push   %eax
  802515:	ff 75 08             	pushl  0x8(%ebp)
  802518:	e8 06 ee ff ff       	call   801323 <fd_lookup>
  80251d:	83 c4 10             	add    $0x10,%esp
  802520:	85 c0                	test   %eax,%eax
  802522:	78 11                	js     802535 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802524:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802527:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80252d:	39 10                	cmp    %edx,(%eax)
  80252f:	0f 94 c0             	sete   %al
  802532:	0f b6 c0             	movzbl %al,%eax
}
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <opencons>:

int
opencons(void)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80253d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802540:	50                   	push   %eax
  802541:	e8 8e ed ff ff       	call   8012d4 <fd_alloc>
  802546:	83 c4 10             	add    $0x10,%esp
		return r;
  802549:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80254b:	85 c0                	test   %eax,%eax
  80254d:	78 3e                	js     80258d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80254f:	83 ec 04             	sub    $0x4,%esp
  802552:	68 07 04 00 00       	push   $0x407
  802557:	ff 75 f4             	pushl  -0xc(%ebp)
  80255a:	6a 00                	push   $0x0
  80255c:	e8 01 e6 ff ff       	call   800b62 <sys_page_alloc>
  802561:	83 c4 10             	add    $0x10,%esp
		return r;
  802564:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802566:	85 c0                	test   %eax,%eax
  802568:	78 23                	js     80258d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80256a:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802570:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802573:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802575:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802578:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80257f:	83 ec 0c             	sub    $0xc,%esp
  802582:	50                   	push   %eax
  802583:	e8 25 ed ff ff       	call   8012ad <fd2num>
  802588:	89 c2                	mov    %eax,%edx
  80258a:	83 c4 10             	add    $0x10,%esp
}
  80258d:	89 d0                	mov    %edx,%eax
  80258f:	c9                   	leave  
  802590:	c3                   	ret    

00802591 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802597:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80259e:	75 2a                	jne    8025ca <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8025a0:	83 ec 04             	sub    $0x4,%esp
  8025a3:	6a 07                	push   $0x7
  8025a5:	68 00 f0 bf ee       	push   $0xeebff000
  8025aa:	6a 00                	push   $0x0
  8025ac:	e8 b1 e5 ff ff       	call   800b62 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8025b1:	83 c4 10             	add    $0x10,%esp
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	79 12                	jns    8025ca <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8025b8:	50                   	push   %eax
  8025b9:	68 52 2e 80 00       	push   $0x802e52
  8025be:	6a 23                	push   $0x23
  8025c0:	68 f7 2f 80 00       	push   $0x802ff7
  8025c5:	e8 37 db ff ff       	call   800101 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8025cd:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8025d2:	83 ec 08             	sub    $0x8,%esp
  8025d5:	68 fc 25 80 00       	push   $0x8025fc
  8025da:	6a 00                	push   $0x0
  8025dc:	e8 cc e6 ff ff       	call   800cad <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8025e1:	83 c4 10             	add    $0x10,%esp
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	79 12                	jns    8025fa <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8025e8:	50                   	push   %eax
  8025e9:	68 52 2e 80 00       	push   $0x802e52
  8025ee:	6a 2c                	push   $0x2c
  8025f0:	68 f7 2f 80 00       	push   $0x802ff7
  8025f5:	e8 07 db ff ff       	call   800101 <_panic>
	}
}
  8025fa:	c9                   	leave  
  8025fb:	c3                   	ret    

008025fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025fd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802602:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802604:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802607:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80260b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802610:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802614:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802616:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802619:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80261a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80261d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80261e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80261f:	c3                   	ret    

00802620 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	56                   	push   %esi
  802624:	53                   	push   %ebx
  802625:	8b 75 08             	mov    0x8(%ebp),%esi
  802628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80262b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80262e:	85 c0                	test   %eax,%eax
  802630:	75 12                	jne    802644 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802632:	83 ec 0c             	sub    $0xc,%esp
  802635:	68 00 00 c0 ee       	push   $0xeec00000
  80263a:	e8 d3 e6 ff ff       	call   800d12 <sys_ipc_recv>
  80263f:	83 c4 10             	add    $0x10,%esp
  802642:	eb 0c                	jmp    802650 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802644:	83 ec 0c             	sub    $0xc,%esp
  802647:	50                   	push   %eax
  802648:	e8 c5 e6 ff ff       	call   800d12 <sys_ipc_recv>
  80264d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802650:	85 f6                	test   %esi,%esi
  802652:	0f 95 c1             	setne  %cl
  802655:	85 db                	test   %ebx,%ebx
  802657:	0f 95 c2             	setne  %dl
  80265a:	84 d1                	test   %dl,%cl
  80265c:	74 09                	je     802667 <ipc_recv+0x47>
  80265e:	89 c2                	mov    %eax,%edx
  802660:	c1 ea 1f             	shr    $0x1f,%edx
  802663:	84 d2                	test   %dl,%dl
  802665:	75 2d                	jne    802694 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802667:	85 f6                	test   %esi,%esi
  802669:	74 0d                	je     802678 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80266b:	a1 04 50 80 00       	mov    0x805004,%eax
  802670:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802676:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802678:	85 db                	test   %ebx,%ebx
  80267a:	74 0d                	je     802689 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80267c:	a1 04 50 80 00       	mov    0x805004,%eax
  802681:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802687:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802689:	a1 04 50 80 00       	mov    0x805004,%eax
  80268e:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802694:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802697:	5b                   	pop    %ebx
  802698:	5e                   	pop    %esi
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    

0080269b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80269b:	55                   	push   %ebp
  80269c:	89 e5                	mov    %esp,%ebp
  80269e:	57                   	push   %edi
  80269f:	56                   	push   %esi
  8026a0:	53                   	push   %ebx
  8026a1:	83 ec 0c             	sub    $0xc,%esp
  8026a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8026ad:	85 db                	test   %ebx,%ebx
  8026af:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026b4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8026b7:	ff 75 14             	pushl  0x14(%ebp)
  8026ba:	53                   	push   %ebx
  8026bb:	56                   	push   %esi
  8026bc:	57                   	push   %edi
  8026bd:	e8 2d e6 ff ff       	call   800cef <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8026c2:	89 c2                	mov    %eax,%edx
  8026c4:	c1 ea 1f             	shr    $0x1f,%edx
  8026c7:	83 c4 10             	add    $0x10,%esp
  8026ca:	84 d2                	test   %dl,%dl
  8026cc:	74 17                	je     8026e5 <ipc_send+0x4a>
  8026ce:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026d1:	74 12                	je     8026e5 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8026d3:	50                   	push   %eax
  8026d4:	68 05 30 80 00       	push   $0x803005
  8026d9:	6a 47                	push   $0x47
  8026db:	68 13 30 80 00       	push   $0x803013
  8026e0:	e8 1c da ff ff       	call   800101 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8026e5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026e8:	75 07                	jne    8026f1 <ipc_send+0x56>
			sys_yield();
  8026ea:	e8 54 e4 ff ff       	call   800b43 <sys_yield>
  8026ef:	eb c6                	jmp    8026b7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8026f1:	85 c0                	test   %eax,%eax
  8026f3:	75 c2                	jne    8026b7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8026f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026f8:	5b                   	pop    %ebx
  8026f9:	5e                   	pop    %esi
  8026fa:	5f                   	pop    %edi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    

008026fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026fd:	55                   	push   %ebp
  8026fe:	89 e5                	mov    %esp,%ebp
  802700:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802703:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802708:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80270e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802714:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80271a:	39 ca                	cmp    %ecx,%edx
  80271c:	75 13                	jne    802731 <ipc_find_env+0x34>
			return envs[i].env_id;
  80271e:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802724:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802729:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80272f:	eb 0f                	jmp    802740 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802731:	83 c0 01             	add    $0x1,%eax
  802734:	3d 00 04 00 00       	cmp    $0x400,%eax
  802739:	75 cd                	jne    802708 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80273b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    

00802742 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802742:	55                   	push   %ebp
  802743:	89 e5                	mov    %esp,%ebp
  802745:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802748:	89 d0                	mov    %edx,%eax
  80274a:	c1 e8 16             	shr    $0x16,%eax
  80274d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802754:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802759:	f6 c1 01             	test   $0x1,%cl
  80275c:	74 1d                	je     80277b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80275e:	c1 ea 0c             	shr    $0xc,%edx
  802761:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802768:	f6 c2 01             	test   $0x1,%dl
  80276b:	74 0e                	je     80277b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80276d:	c1 ea 0c             	shr    $0xc,%edx
  802770:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802777:	ef 
  802778:	0f b7 c0             	movzwl %ax,%eax
}
  80277b:	5d                   	pop    %ebp
  80277c:	c3                   	ret    
  80277d:	66 90                	xchg   %ax,%ax
  80277f:	90                   	nop

00802780 <__udivdi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80278b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80278f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 f6                	test   %esi,%esi
  802799:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80279d:	89 ca                	mov    %ecx,%edx
  80279f:	89 f8                	mov    %edi,%eax
  8027a1:	75 3d                	jne    8027e0 <__udivdi3+0x60>
  8027a3:	39 cf                	cmp    %ecx,%edi
  8027a5:	0f 87 c5 00 00 00    	ja     802870 <__udivdi3+0xf0>
  8027ab:	85 ff                	test   %edi,%edi
  8027ad:	89 fd                	mov    %edi,%ebp
  8027af:	75 0b                	jne    8027bc <__udivdi3+0x3c>
  8027b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b6:	31 d2                	xor    %edx,%edx
  8027b8:	f7 f7                	div    %edi
  8027ba:	89 c5                	mov    %eax,%ebp
  8027bc:	89 c8                	mov    %ecx,%eax
  8027be:	31 d2                	xor    %edx,%edx
  8027c0:	f7 f5                	div    %ebp
  8027c2:	89 c1                	mov    %eax,%ecx
  8027c4:	89 d8                	mov    %ebx,%eax
  8027c6:	89 cf                	mov    %ecx,%edi
  8027c8:	f7 f5                	div    %ebp
  8027ca:	89 c3                	mov    %eax,%ebx
  8027cc:	89 d8                	mov    %ebx,%eax
  8027ce:	89 fa                	mov    %edi,%edx
  8027d0:	83 c4 1c             	add    $0x1c,%esp
  8027d3:	5b                   	pop    %ebx
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
  8027d8:	90                   	nop
  8027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	39 ce                	cmp    %ecx,%esi
  8027e2:	77 74                	ja     802858 <__udivdi3+0xd8>
  8027e4:	0f bd fe             	bsr    %esi,%edi
  8027e7:	83 f7 1f             	xor    $0x1f,%edi
  8027ea:	0f 84 98 00 00 00    	je     802888 <__udivdi3+0x108>
  8027f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	89 c5                	mov    %eax,%ebp
  8027f9:	29 fb                	sub    %edi,%ebx
  8027fb:	d3 e6                	shl    %cl,%esi
  8027fd:	89 d9                	mov    %ebx,%ecx
  8027ff:	d3 ed                	shr    %cl,%ebp
  802801:	89 f9                	mov    %edi,%ecx
  802803:	d3 e0                	shl    %cl,%eax
  802805:	09 ee                	or     %ebp,%esi
  802807:	89 d9                	mov    %ebx,%ecx
  802809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80280d:	89 d5                	mov    %edx,%ebp
  80280f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802813:	d3 ed                	shr    %cl,%ebp
  802815:	89 f9                	mov    %edi,%ecx
  802817:	d3 e2                	shl    %cl,%edx
  802819:	89 d9                	mov    %ebx,%ecx
  80281b:	d3 e8                	shr    %cl,%eax
  80281d:	09 c2                	or     %eax,%edx
  80281f:	89 d0                	mov    %edx,%eax
  802821:	89 ea                	mov    %ebp,%edx
  802823:	f7 f6                	div    %esi
  802825:	89 d5                	mov    %edx,%ebp
  802827:	89 c3                	mov    %eax,%ebx
  802829:	f7 64 24 0c          	mull   0xc(%esp)
  80282d:	39 d5                	cmp    %edx,%ebp
  80282f:	72 10                	jb     802841 <__udivdi3+0xc1>
  802831:	8b 74 24 08          	mov    0x8(%esp),%esi
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e6                	shl    %cl,%esi
  802839:	39 c6                	cmp    %eax,%esi
  80283b:	73 07                	jae    802844 <__udivdi3+0xc4>
  80283d:	39 d5                	cmp    %edx,%ebp
  80283f:	75 03                	jne    802844 <__udivdi3+0xc4>
  802841:	83 eb 01             	sub    $0x1,%ebx
  802844:	31 ff                	xor    %edi,%edi
  802846:	89 d8                	mov    %ebx,%eax
  802848:	89 fa                	mov    %edi,%edx
  80284a:	83 c4 1c             	add    $0x1c,%esp
  80284d:	5b                   	pop    %ebx
  80284e:	5e                   	pop    %esi
  80284f:	5f                   	pop    %edi
  802850:	5d                   	pop    %ebp
  802851:	c3                   	ret    
  802852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802858:	31 ff                	xor    %edi,%edi
  80285a:	31 db                	xor    %ebx,%ebx
  80285c:	89 d8                	mov    %ebx,%eax
  80285e:	89 fa                	mov    %edi,%edx
  802860:	83 c4 1c             	add    $0x1c,%esp
  802863:	5b                   	pop    %ebx
  802864:	5e                   	pop    %esi
  802865:	5f                   	pop    %edi
  802866:	5d                   	pop    %ebp
  802867:	c3                   	ret    
  802868:	90                   	nop
  802869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802870:	89 d8                	mov    %ebx,%eax
  802872:	f7 f7                	div    %edi
  802874:	31 ff                	xor    %edi,%edi
  802876:	89 c3                	mov    %eax,%ebx
  802878:	89 d8                	mov    %ebx,%eax
  80287a:	89 fa                	mov    %edi,%edx
  80287c:	83 c4 1c             	add    $0x1c,%esp
  80287f:	5b                   	pop    %ebx
  802880:	5e                   	pop    %esi
  802881:	5f                   	pop    %edi
  802882:	5d                   	pop    %ebp
  802883:	c3                   	ret    
  802884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802888:	39 ce                	cmp    %ecx,%esi
  80288a:	72 0c                	jb     802898 <__udivdi3+0x118>
  80288c:	31 db                	xor    %ebx,%ebx
  80288e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802892:	0f 87 34 ff ff ff    	ja     8027cc <__udivdi3+0x4c>
  802898:	bb 01 00 00 00       	mov    $0x1,%ebx
  80289d:	e9 2a ff ff ff       	jmp    8027cc <__udivdi3+0x4c>
  8028a2:	66 90                	xchg   %ax,%ax
  8028a4:	66 90                	xchg   %ax,%ax
  8028a6:	66 90                	xchg   %ax,%ax
  8028a8:	66 90                	xchg   %ax,%ax
  8028aa:	66 90                	xchg   %ax,%ax
  8028ac:	66 90                	xchg   %ax,%ax
  8028ae:	66 90                	xchg   %ax,%ax

008028b0 <__umoddi3>:
  8028b0:	55                   	push   %ebp
  8028b1:	57                   	push   %edi
  8028b2:	56                   	push   %esi
  8028b3:	53                   	push   %ebx
  8028b4:	83 ec 1c             	sub    $0x1c,%esp
  8028b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028c7:	85 d2                	test   %edx,%edx
  8028c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028d1:	89 f3                	mov    %esi,%ebx
  8028d3:	89 3c 24             	mov    %edi,(%esp)
  8028d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028da:	75 1c                	jne    8028f8 <__umoddi3+0x48>
  8028dc:	39 f7                	cmp    %esi,%edi
  8028de:	76 50                	jbe    802930 <__umoddi3+0x80>
  8028e0:	89 c8                	mov    %ecx,%eax
  8028e2:	89 f2                	mov    %esi,%edx
  8028e4:	f7 f7                	div    %edi
  8028e6:	89 d0                	mov    %edx,%eax
  8028e8:	31 d2                	xor    %edx,%edx
  8028ea:	83 c4 1c             	add    $0x1c,%esp
  8028ed:	5b                   	pop    %ebx
  8028ee:	5e                   	pop    %esi
  8028ef:	5f                   	pop    %edi
  8028f0:	5d                   	pop    %ebp
  8028f1:	c3                   	ret    
  8028f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028f8:	39 f2                	cmp    %esi,%edx
  8028fa:	89 d0                	mov    %edx,%eax
  8028fc:	77 52                	ja     802950 <__umoddi3+0xa0>
  8028fe:	0f bd ea             	bsr    %edx,%ebp
  802901:	83 f5 1f             	xor    $0x1f,%ebp
  802904:	75 5a                	jne    802960 <__umoddi3+0xb0>
  802906:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80290a:	0f 82 e0 00 00 00    	jb     8029f0 <__umoddi3+0x140>
  802910:	39 0c 24             	cmp    %ecx,(%esp)
  802913:	0f 86 d7 00 00 00    	jbe    8029f0 <__umoddi3+0x140>
  802919:	8b 44 24 08          	mov    0x8(%esp),%eax
  80291d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802921:	83 c4 1c             	add    $0x1c,%esp
  802924:	5b                   	pop    %ebx
  802925:	5e                   	pop    %esi
  802926:	5f                   	pop    %edi
  802927:	5d                   	pop    %ebp
  802928:	c3                   	ret    
  802929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802930:	85 ff                	test   %edi,%edi
  802932:	89 fd                	mov    %edi,%ebp
  802934:	75 0b                	jne    802941 <__umoddi3+0x91>
  802936:	b8 01 00 00 00       	mov    $0x1,%eax
  80293b:	31 d2                	xor    %edx,%edx
  80293d:	f7 f7                	div    %edi
  80293f:	89 c5                	mov    %eax,%ebp
  802941:	89 f0                	mov    %esi,%eax
  802943:	31 d2                	xor    %edx,%edx
  802945:	f7 f5                	div    %ebp
  802947:	89 c8                	mov    %ecx,%eax
  802949:	f7 f5                	div    %ebp
  80294b:	89 d0                	mov    %edx,%eax
  80294d:	eb 99                	jmp    8028e8 <__umoddi3+0x38>
  80294f:	90                   	nop
  802950:	89 c8                	mov    %ecx,%eax
  802952:	89 f2                	mov    %esi,%edx
  802954:	83 c4 1c             	add    $0x1c,%esp
  802957:	5b                   	pop    %ebx
  802958:	5e                   	pop    %esi
  802959:	5f                   	pop    %edi
  80295a:	5d                   	pop    %ebp
  80295b:	c3                   	ret    
  80295c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802960:	8b 34 24             	mov    (%esp),%esi
  802963:	bf 20 00 00 00       	mov    $0x20,%edi
  802968:	89 e9                	mov    %ebp,%ecx
  80296a:	29 ef                	sub    %ebp,%edi
  80296c:	d3 e0                	shl    %cl,%eax
  80296e:	89 f9                	mov    %edi,%ecx
  802970:	89 f2                	mov    %esi,%edx
  802972:	d3 ea                	shr    %cl,%edx
  802974:	89 e9                	mov    %ebp,%ecx
  802976:	09 c2                	or     %eax,%edx
  802978:	89 d8                	mov    %ebx,%eax
  80297a:	89 14 24             	mov    %edx,(%esp)
  80297d:	89 f2                	mov    %esi,%edx
  80297f:	d3 e2                	shl    %cl,%edx
  802981:	89 f9                	mov    %edi,%ecx
  802983:	89 54 24 04          	mov    %edx,0x4(%esp)
  802987:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80298b:	d3 e8                	shr    %cl,%eax
  80298d:	89 e9                	mov    %ebp,%ecx
  80298f:	89 c6                	mov    %eax,%esi
  802991:	d3 e3                	shl    %cl,%ebx
  802993:	89 f9                	mov    %edi,%ecx
  802995:	89 d0                	mov    %edx,%eax
  802997:	d3 e8                	shr    %cl,%eax
  802999:	89 e9                	mov    %ebp,%ecx
  80299b:	09 d8                	or     %ebx,%eax
  80299d:	89 d3                	mov    %edx,%ebx
  80299f:	89 f2                	mov    %esi,%edx
  8029a1:	f7 34 24             	divl   (%esp)
  8029a4:	89 d6                	mov    %edx,%esi
  8029a6:	d3 e3                	shl    %cl,%ebx
  8029a8:	f7 64 24 04          	mull   0x4(%esp)
  8029ac:	39 d6                	cmp    %edx,%esi
  8029ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029b2:	89 d1                	mov    %edx,%ecx
  8029b4:	89 c3                	mov    %eax,%ebx
  8029b6:	72 08                	jb     8029c0 <__umoddi3+0x110>
  8029b8:	75 11                	jne    8029cb <__umoddi3+0x11b>
  8029ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029be:	73 0b                	jae    8029cb <__umoddi3+0x11b>
  8029c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029c4:	1b 14 24             	sbb    (%esp),%edx
  8029c7:	89 d1                	mov    %edx,%ecx
  8029c9:	89 c3                	mov    %eax,%ebx
  8029cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029cf:	29 da                	sub    %ebx,%edx
  8029d1:	19 ce                	sbb    %ecx,%esi
  8029d3:	89 f9                	mov    %edi,%ecx
  8029d5:	89 f0                	mov    %esi,%eax
  8029d7:	d3 e0                	shl    %cl,%eax
  8029d9:	89 e9                	mov    %ebp,%ecx
  8029db:	d3 ea                	shr    %cl,%edx
  8029dd:	89 e9                	mov    %ebp,%ecx
  8029df:	d3 ee                	shr    %cl,%esi
  8029e1:	09 d0                	or     %edx,%eax
  8029e3:	89 f2                	mov    %esi,%edx
  8029e5:	83 c4 1c             	add    $0x1c,%esp
  8029e8:	5b                   	pop    %ebx
  8029e9:	5e                   	pop    %esi
  8029ea:	5f                   	pop    %edi
  8029eb:	5d                   	pop    %ebp
  8029ec:	c3                   	ret    
  8029ed:	8d 76 00             	lea    0x0(%esi),%esi
  8029f0:	29 f9                	sub    %edi,%ecx
  8029f2:	19 d6                	sbb    %edx,%esi
  8029f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029fc:	e9 18 ff ff ff       	jmp    802919 <__umoddi3+0x69>
