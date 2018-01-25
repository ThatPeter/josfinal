
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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  80003f:	8b 40 54             	mov    0x54(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 00 22 80 00       	push   $0x802200
  800048:	e8 64 01 00 00       	call   8001b1 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 c0 0a 00 00       	call   800b1a <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 54             	mov    0x54(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 20 22 80 00       	push   $0x802220
  80006c:	e8 40 01 00 00       	call   8001b1 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 54             	mov    0x54(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 4c 22 80 00       	push   $0x80224c
  80008d:	e8 1f 01 00 00       	call   8001b1 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 51 0a 00 00       	call   800afb <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	89 c2                	mov    %eax,%edx
  8000b1:	c1 e2 07             	shl    $0x7,%edx
  8000b4:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000bb:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c0:	85 db                	test   %ebx,%ebx
  8000c2:	7e 07                	jle    8000cb <libmain+0x31>
		binaryname = argv[0];
  8000c4:	8b 06                	mov    (%esi),%eax
  8000c6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	e8 5e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d5:	e8 2a 00 00 00       	call   800104 <exit>
}
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000ea:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000ef:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000f1:	e8 05 0a 00 00       	call   800afb <sys_getenvid>
  8000f6:	83 ec 0c             	sub    $0xc,%esp
  8000f9:	50                   	push   %eax
  8000fa:	e8 4b 0c 00 00       	call   800d4a <sys_thread_free>
}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 18 11 00 00       	call   801227 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a1 09 00 00       	call   800aba <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 2f 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 d4 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 57 1d 00 00       	call   801f70 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 44 1e 00 00       	call   8020a0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 75 22 80 00 	movsbl 0x802275(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 89 03 00 00    	je     80068d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 1a 03 00 00    	ja     800672 <vprintfmt+0x38a>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 8d 22 80 00       	push   $0x80228d
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 cd 26 80 00       	push   $0x8026cd
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 86 22 80 00       	mov    $0x802286,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 86 02 00 00       	call   800715 <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	79 74                	jns    80063e <vprintfmt+0x356>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d8:	f7 d8                	neg    %eax
  8005da:	83 d2 00             	adc    $0x0,%edx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e7:	eb 55                	jmp    80063e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 83 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f6:	eb 46                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 74 fc ff ff       	call   800274 <getuint>
			base = 8;
  800600:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800605:	eb 37                	jmp    80063e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062f:	eb 0d                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 3b fc ff ff       	call   800274 <getuint>
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800645:	57                   	push   %edi
  800646:	ff 75 e0             	pushl  -0x20(%ebp)
  800649:	51                   	push   %ecx
  80064a:	52                   	push   %edx
  80064b:	50                   	push   %eax
  80064c:	89 da                	mov    %ebx,%edx
  80064e:	89 f0                	mov    %esi,%eax
  800650:	e8 70 fb ff ff       	call   8001c5 <printnum>
			break;
  800655:	83 c4 20             	add    $0x20,%esp
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 ae fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	51                   	push   %ecx
  800665:	ff d6                	call   *%esi
			break;
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066d:	e9 9c fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 03                	jmp    800682 <vprintfmt+0x39a>
  80067f:	83 ef 01             	sub    $0x1,%edi
  800682:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800686:	75 f7                	jne    80067f <vprintfmt+0x397>
  800688:	e9 81 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800690:	5b                   	pop    %ebx
  800691:	5e                   	pop    %esi
  800692:	5f                   	pop    %edi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 18             	sub    $0x18,%esp
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	74 26                	je     8006dc <vsnprintf+0x47>
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	7e 22                	jle    8006dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ba:	ff 75 14             	pushl  0x14(%ebp)
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	68 ae 02 80 00       	push   $0x8002ae
  8006c9:	e8 1a fc ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 05                	jmp    8006e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ec:	50                   	push   %eax
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	ff 75 08             	pushl  0x8(%ebp)
  8006f6:	e8 9a ff ff ff       	call   800695 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 03                	jmp    80070d <strlen+0x10>
		n++;
  80070a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800711:	75 f7                	jne    80070a <strlen+0xd>
		n++;
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
  800723:	eb 03                	jmp    800728 <strnlen+0x13>
		n++;
  800725:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	39 c2                	cmp    %eax,%edx
  80072a:	74 08                	je     800734 <strnlen+0x1f>
  80072c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800730:	75 f3                	jne    800725 <strnlen+0x10>
  800732:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800740:	89 c2                	mov    %eax,%edx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074f:	84 db                	test   %bl,%bl
  800751:	75 ef                	jne    800742 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800753:	5b                   	pop    %ebx
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075d:	53                   	push   %ebx
  80075e:	e8 9a ff ff ff       	call   8006fd <strlen>
  800763:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	50                   	push   %eax
  80076c:	e8 c5 ff ff ff       	call   800736 <strcpy>
	return dst;
}
  800771:	89 d8                	mov    %ebx,%eax
  800773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	89 f3                	mov    %esi,%ebx
  800785:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	89 f2                	mov    %esi,%edx
  80078a:	eb 0f                	jmp    80079b <strncpy+0x23>
		*dst++ = *src;
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	0f b6 01             	movzbl (%ecx),%eax
  800792:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 39 01             	cmpb   $0x1,(%ecx)
  800798:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	39 da                	cmp    %ebx,%edx
  80079d:	75 ed                	jne    80078c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 21                	je     8007da <strlcpy+0x35>
  8007b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 09                	jmp    8007ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 09                	je     8007d7 <strlcpy+0x32>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ec                	jne    8007c1 <strlcpy+0x1c>
  8007d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007da:	29 f0                	sub    %esi,%eax
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strcmp+0x11>
		p++, q++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	84 c0                	test   %al,%al
  8007f6:	74 04                	je     8007fc <strcmp+0x1c>
  8007f8:	3a 02                	cmp    (%edx),%al
  8007fa:	74 ef                	je     8007eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 c0             	movzbl %al,%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	89 c3                	mov    %eax,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800815:	eb 06                	jmp    80081d <strncmp+0x17>
		n--, p++, q++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 15                	je     800836 <strncmp+0x30>
  800821:	0f b6 08             	movzbl (%eax),%ecx
  800824:	84 c9                	test   %cl,%cl
  800826:	74 04                	je     80082c <strncmp+0x26>
  800828:	3a 0a                	cmp    (%edx),%cl
  80082a:	74 eb                	je     800817 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 00             	movzbl (%eax),%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
  800834:	eb 05                	jmp    80083b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 07                	jmp    800851 <strchr+0x13>
		if (*s == c)
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 0f                	je     80085d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 03                	jmp    80086e <strfind+0xf>
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 04                	je     800879 <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strfind+0xc>
			break;
	return (char *) s;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 36                	je     8008c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800891:	75 28                	jne    8008bb <memset+0x40>
  800893:	f6 c1 03             	test   $0x3,%cl
  800896:	75 23                	jne    8008bb <memset+0x40>
		c &= 0xFF;
  800898:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d3                	mov    %edx,%ebx
  80089e:	c1 e3 08             	shl    $0x8,%ebx
  8008a1:	89 d6                	mov    %edx,%esi
  8008a3:	c1 e6 18             	shl    $0x18,%esi
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	c1 e0 10             	shl    $0x10,%eax
  8008ab:	09 f0                	or     %esi,%eax
  8008ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	09 d0                	or     %edx,%eax
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 06                	jmp    8008c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 35                	jae    80090f <memmove+0x47>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	73 2e                	jae    80090f <memmove+0x47>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	09 fe                	or     %edi,%esi
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 13                	jne    800903 <memmove+0x3b>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0e                	jne    800903 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 09                	jmp    80090c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	83 ef 01             	sub    $0x1,%edi
  800906:	8d 72 ff             	lea    -0x1(%edx),%esi
  800909:	fd                   	std    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090c:	fc                   	cld    
  80090d:	eb 1d                	jmp    80092c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 f2                	mov    %esi,%edx
  800911:	09 c2                	or     %eax,%edx
  800913:	f6 c2 03             	test   $0x3,%dl
  800916:	75 0f                	jne    800927 <memmove+0x5f>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 0a                	jne    800927 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091d:	c1 e9 02             	shr    $0x2,%ecx
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 05                	jmp    80092c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800933:	ff 75 10             	pushl  0x10(%ebp)
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 87 ff ff ff       	call   8008c8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 c6                	mov    %eax,%esi
  800950:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	eb 1a                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	38 d9                	cmp    %bl,%cl
  80095d:	74 0a                	je     800969 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095f:	0f b6 c1             	movzbl %cl,%eax
  800962:	0f b6 db             	movzbl %bl,%ebx
  800965:	29 d8                	sub    %ebx,%eax
  800967:	eb 0f                	jmp    800978 <memcmp+0x35>
		s1++, s2++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 f0                	cmp    %esi,%eax
  800971:	75 e2                	jne    800955 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800983:	89 c1                	mov    %eax,%ecx
  800985:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800988:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	eb 0a                	jmp    800998 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 10             	movzbl (%eax),%edx
  800991:	39 da                	cmp    %ebx,%edx
  800993:	74 07                	je     80099c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 c8                	cmp    %ecx,%eax
  80099a:	72 f2                	jb     80098e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	eb 03                	jmp    8009b0 <strtol+0x11>
		s++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f6                	je     8009ad <strtol+0xe>
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	74 f2                	je     8009ad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bb:	3c 2b                	cmp    $0x2b,%al
  8009bd:	75 0a                	jne    8009c9 <strtol+0x2a>
		s++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c7:	eb 11                	jmp    8009da <strtol+0x3b>
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ce:	3c 2d                	cmp    $0x2d,%al
  8009d0:	75 08                	jne    8009da <strtol+0x3b>
		s++, neg = 1;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 15                	jne    8009f7 <strtol+0x58>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 10                	jne    8009f7 <strtol+0x58>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	75 7c                	jne    800a69 <strtol+0xca>
		s += 2, base = 16;
  8009ed:	83 c1 02             	add    $0x2,%ecx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 16                	jmp    800a0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 12                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 08                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a15:	0f b6 11             	movzbl (%ecx),%edx
  800a18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x8b>
			dig = *s - '0';
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 30             	sub    $0x30,%edx
  800a28:	eb 22                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a34:	0f be d2             	movsbl %dl,%edx
  800a37:	83 ea 57             	sub    $0x57,%edx
  800a3a:	eb 10                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 16                	ja     800a5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4f:	7d 0b                	jge    800a5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5a:	eb b9                	jmp    800a15 <strtol+0x76>

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 0d                	je     800a6f <strtol+0xd0>
		*endptr = (char *) s;
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	89 0e                	mov    %ecx,(%esi)
  800a67:	eb 06                	jmp    800a6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	74 98                	je     800a05 <strtol+0x66>
  800a6d:	eb 9e                	jmp    800a0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	f7 da                	neg    %edx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	0f 45 c2             	cmovne %edx,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 cb                	mov    %ecx,%ebx
  800ad2:	89 cf                	mov    %ecx,%edi
  800ad4:	89 ce                	mov    %ecx,%esi
  800ad6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 03                	push   $0x3
  800ae2:	68 7f 25 80 00       	push   $0x80257f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 9c 25 80 00       	push   $0x80259c
  800aee:	e8 53 12 00 00       	call   801d46 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 04                	push   $0x4
  800b63:	68 7f 25 80 00       	push   $0x80257f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 9c 25 80 00       	push   $0x80259c
  800b6f:	e8 d2 11 00 00       	call   801d46 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b96:	8b 75 18             	mov    0x18(%ebp),%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 05                	push   $0x5
  800ba5:	68 7f 25 80 00       	push   $0x80257f
  800baa:	6a 23                	push   $0x23
  800bac:	68 9c 25 80 00       	push   $0x80259c
  800bb1:	e8 90 11 00 00       	call   801d46 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 06                	push   $0x6
  800be7:	68 7f 25 80 00       	push   $0x80257f
  800bec:	6a 23                	push   $0x23
  800bee:	68 9c 25 80 00       	push   $0x80259c
  800bf3:	e8 4e 11 00 00       	call   801d46 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 08                	push   $0x8
  800c29:	68 7f 25 80 00       	push   $0x80257f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 9c 25 80 00       	push   $0x80259c
  800c35:	e8 0c 11 00 00       	call   801d46 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 09                	push   $0x9
  800c6b:	68 7f 25 80 00       	push   $0x80257f
  800c70:	6a 23                	push   $0x23
  800c72:	68 9c 25 80 00       	push   $0x80259c
  800c77:	e8 ca 10 00 00       	call   801d46 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 0a                	push   $0xa
  800cad:	68 7f 25 80 00       	push   $0x80257f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 9c 25 80 00       	push   $0x80259c
  800cb9:	e8 88 10 00 00       	call   801d46 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0d                	push   $0xd
  800d11:	68 7f 25 80 00       	push   $0x80257f
  800d16:	6a 23                	push   $0x23
  800d18:	68 9c 25 80 00       	push   $0x80259c
  800d1d:	e8 24 10 00 00       	call   801d46 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d35:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 cb                	mov    %ecx,%ebx
  800d3f:	89 cf                	mov    %ecx,%edi
  800d41:	89 ce                	mov    %ecx,%esi
  800d43:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d55:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 cb                	mov    %ecx,%ebx
  800d5f:	89 cf                	mov    %ecx,%edi
  800d61:	89 ce                	mov    %ecx,%esi
  800d63:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d74:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d76:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d7a:	74 11                	je     800d8d <pgfault+0x23>
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	c1 e8 0c             	shr    $0xc,%eax
  800d81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d88:	f6 c4 08             	test   $0x8,%ah
  800d8b:	75 14                	jne    800da1 <pgfault+0x37>
		panic("faulting access");
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	68 aa 25 80 00       	push   $0x8025aa
  800d95:	6a 1e                	push   $0x1e
  800d97:	68 ba 25 80 00       	push   $0x8025ba
  800d9c:	e8 a5 0f 00 00       	call   801d46 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	6a 07                	push   $0x7
  800da6:	68 00 f0 7f 00       	push   $0x7ff000
  800dab:	6a 00                	push   $0x0
  800dad:	e8 87 fd ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0) {
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	79 12                	jns    800dcb <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800db9:	50                   	push   %eax
  800dba:	68 c5 25 80 00       	push   $0x8025c5
  800dbf:	6a 2c                	push   $0x2c
  800dc1:	68 ba 25 80 00       	push   $0x8025ba
  800dc6:	e8 7b 0f 00 00       	call   801d46 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dcb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	68 00 10 00 00       	push   $0x1000
  800dd9:	53                   	push   %ebx
  800dda:	68 00 f0 7f 00       	push   $0x7ff000
  800ddf:	e8 4c fb ff ff       	call   800930 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800de4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800deb:	53                   	push   %ebx
  800dec:	6a 00                	push   $0x0
  800dee:	68 00 f0 7f 00       	push   $0x7ff000
  800df3:	6a 00                	push   $0x0
  800df5:	e8 82 fd ff ff       	call   800b7c <sys_page_map>
	if (r < 0) {
  800dfa:	83 c4 20             	add    $0x20,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	79 12                	jns    800e13 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e01:	50                   	push   %eax
  800e02:	68 c5 25 80 00       	push   $0x8025c5
  800e07:	6a 33                	push   $0x33
  800e09:	68 ba 25 80 00       	push   $0x8025ba
  800e0e:	e8 33 0f 00 00       	call   801d46 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e13:	83 ec 08             	sub    $0x8,%esp
  800e16:	68 00 f0 7f 00       	push   $0x7ff000
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 9c fd ff ff       	call   800bbe <sys_page_unmap>
	if (r < 0) {
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 12                	jns    800e3b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e29:	50                   	push   %eax
  800e2a:	68 c5 25 80 00       	push   $0x8025c5
  800e2f:	6a 37                	push   $0x37
  800e31:	68 ba 25 80 00       	push   $0x8025ba
  800e36:	e8 0b 0f 00 00       	call   801d46 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e49:	68 6a 0d 80 00       	push   $0x800d6a
  800e4e:	e8 39 0f 00 00       	call   801d8c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e53:	b8 07 00 00 00       	mov    $0x7,%eax
  800e58:	cd 30                	int    $0x30
  800e5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 17                	jns    800e7b <fork+0x3b>
		panic("fork fault %e");
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	68 de 25 80 00       	push   $0x8025de
  800e6c:	68 84 00 00 00       	push   $0x84
  800e71:	68 ba 25 80 00       	push   $0x8025ba
  800e76:	e8 cb 0e 00 00       	call   801d46 <_panic>
  800e7b:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e81:	75 25                	jne    800ea8 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e83:	e8 73 fc ff ff       	call   800afb <sys_getenvid>
  800e88:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8d:	89 c2                	mov    %eax,%edx
  800e8f:	c1 e2 07             	shl    $0x7,%edx
  800e92:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800e99:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	e9 61 01 00 00       	jmp    801009 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	6a 07                	push   $0x7
  800ead:	68 00 f0 bf ee       	push   $0xeebff000
  800eb2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eb5:	e8 7f fc ff ff       	call   800b39 <sys_page_alloc>
  800eba:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ebd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	c1 e8 16             	shr    $0x16,%eax
  800ec7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ece:	a8 01                	test   $0x1,%al
  800ed0:	0f 84 fc 00 00 00    	je     800fd2 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	c1 e8 0c             	shr    $0xc,%eax
  800edb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	0f 84 e7 00 00 00    	je     800fd2 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800eeb:	89 c6                	mov    %eax,%esi
  800eed:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ef0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef7:	f6 c6 04             	test   $0x4,%dh
  800efa:	74 39                	je     800f35 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800efc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	25 07 0e 00 00       	and    $0xe07,%eax
  800f0b:	50                   	push   %eax
  800f0c:	56                   	push   %esi
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 66 fc ff ff       	call   800b7c <sys_page_map>
		if (r < 0) {
  800f16:	83 c4 20             	add    $0x20,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	0f 89 b1 00 00 00    	jns    800fd2 <fork+0x192>
		    	panic("sys page map fault %e");
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	68 ec 25 80 00       	push   $0x8025ec
  800f29:	6a 54                	push   $0x54
  800f2b:	68 ba 25 80 00       	push   $0x8025ba
  800f30:	e8 11 0e 00 00       	call   801d46 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f35:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3c:	f6 c2 02             	test   $0x2,%dl
  800f3f:	75 0c                	jne    800f4d <fork+0x10d>
  800f41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f48:	f6 c4 08             	test   $0x8,%ah
  800f4b:	74 5b                	je     800fa8 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	68 05 08 00 00       	push   $0x805
  800f55:	56                   	push   %esi
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 1d fc ff ff       	call   800b7c <sys_page_map>
		if (r < 0) {
  800f5f:	83 c4 20             	add    $0x20,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 14                	jns    800f7a <fork+0x13a>
		    	panic("sys page map fault %e");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 ec 25 80 00       	push   $0x8025ec
  800f6e:	6a 5b                	push   $0x5b
  800f70:	68 ba 25 80 00       	push   $0x8025ba
  800f75:	e8 cc 0d 00 00       	call   801d46 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	68 05 08 00 00       	push   $0x805
  800f82:	56                   	push   %esi
  800f83:	6a 00                	push   $0x0
  800f85:	56                   	push   %esi
  800f86:	6a 00                	push   $0x0
  800f88:	e8 ef fb ff ff       	call   800b7c <sys_page_map>
		if (r < 0) {
  800f8d:	83 c4 20             	add    $0x20,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	79 3e                	jns    800fd2 <fork+0x192>
		    	panic("sys page map fault %e");
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	68 ec 25 80 00       	push   $0x8025ec
  800f9c:	6a 5f                	push   $0x5f
  800f9e:	68 ba 25 80 00       	push   $0x8025ba
  800fa3:	e8 9e 0d 00 00       	call   801d46 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fa8:	83 ec 0c             	sub    $0xc,%esp
  800fab:	6a 05                	push   $0x5
  800fad:	56                   	push   %esi
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 c5 fb ff ff       	call   800b7c <sys_page_map>
		if (r < 0) {
  800fb7:	83 c4 20             	add    $0x20,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 14                	jns    800fd2 <fork+0x192>
		    	panic("sys page map fault %e");
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	68 ec 25 80 00       	push   $0x8025ec
  800fc6:	6a 64                	push   $0x64
  800fc8:	68 ba 25 80 00       	push   $0x8025ba
  800fcd:	e8 74 0d 00 00       	call   801d46 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fde:	0f 85 de fe ff ff    	jne    800ec2 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fe4:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe9:	8b 40 70             	mov    0x70(%eax),%eax
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	50                   	push   %eax
  800ff0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff3:	57                   	push   %edi
  800ff4:	e8 8b fc ff ff       	call   800c84 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800ff9:	83 c4 08             	add    $0x8,%esp
  800ffc:	6a 02                	push   $0x2
  800ffe:	57                   	push   %edi
  800fff:	e8 fc fb ff ff       	call   800c00 <sys_env_set_status>
	
	return envid;
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801009:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sfork>:

envid_t
sfork(void)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801014:	b8 00 00 00 00       	mov    $0x0,%eax
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801023:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	53                   	push   %ebx
  80102d:	68 04 26 80 00       	push   $0x802604
  801032:	e8 7a f1 ff ff       	call   8001b1 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801037:	c7 04 24 e4 00 80 00 	movl   $0x8000e4,(%esp)
  80103e:	e8 e7 fc ff ff       	call   800d2a <sys_thread_create>
  801043:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801045:	83 c4 08             	add    $0x8,%esp
  801048:	53                   	push   %ebx
  801049:	68 04 26 80 00       	push   $0x802604
  80104e:	e8 5e f1 ff ff       	call   8001b1 <cprintf>
	return id;
	//return 0;
}
  801053:	89 f0                	mov    %esi,%eax
  801055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105f:	8b 45 08             	mov    0x8(%ebp),%eax
  801062:	05 00 00 00 30       	add    $0x30000000,%eax
  801067:	c1 e8 0c             	shr    $0xc,%eax
}
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	05 00 00 00 30       	add    $0x30000000,%eax
  801077:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80107c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801089:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108e:	89 c2                	mov    %eax,%edx
  801090:	c1 ea 16             	shr    $0x16,%edx
  801093:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109a:	f6 c2 01             	test   $0x1,%dl
  80109d:	74 11                	je     8010b0 <fd_alloc+0x2d>
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	c1 ea 0c             	shr    $0xc,%edx
  8010a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ab:	f6 c2 01             	test   $0x1,%dl
  8010ae:	75 09                	jne    8010b9 <fd_alloc+0x36>
			*fd_store = fd;
  8010b0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	eb 17                	jmp    8010d0 <fd_alloc+0x4d>
  8010b9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010be:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c3:	75 c9                	jne    80108e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010cb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d8:	83 f8 1f             	cmp    $0x1f,%eax
  8010db:	77 36                	ja     801113 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010dd:	c1 e0 0c             	shl    $0xc,%eax
  8010e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	c1 ea 16             	shr    $0x16,%edx
  8010ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f1:	f6 c2 01             	test   $0x1,%dl
  8010f4:	74 24                	je     80111a <fd_lookup+0x48>
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	c1 ea 0c             	shr    $0xc,%edx
  8010fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 1a                	je     801121 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801107:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110a:	89 02                	mov    %eax,(%edx)
	return 0;
  80110c:	b8 00 00 00 00       	mov    $0x0,%eax
  801111:	eb 13                	jmp    801126 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801113:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801118:	eb 0c                	jmp    801126 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80111a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111f:	eb 05                	jmp    801126 <fd_lookup+0x54>
  801121:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801131:	ba a4 26 80 00       	mov    $0x8026a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801136:	eb 13                	jmp    80114b <dev_lookup+0x23>
  801138:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80113b:	39 08                	cmp    %ecx,(%eax)
  80113d:	75 0c                	jne    80114b <dev_lookup+0x23>
			*dev = devtab[i];
  80113f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801142:	89 01                	mov    %eax,(%ecx)
			return 0;
  801144:	b8 00 00 00 00       	mov    $0x0,%eax
  801149:	eb 2e                	jmp    801179 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80114b:	8b 02                	mov    (%edx),%eax
  80114d:	85 c0                	test   %eax,%eax
  80114f:	75 e7                	jne    801138 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801151:	a1 04 40 80 00       	mov    0x804004,%eax
  801156:	8b 40 54             	mov    0x54(%eax),%eax
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	51                   	push   %ecx
  80115d:	50                   	push   %eax
  80115e:	68 28 26 80 00       	push   $0x802628
  801163:	e8 49 f0 ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801168:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 10             	sub    $0x10,%esp
  801183:	8b 75 08             	mov    0x8(%ebp),%esi
  801186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801189:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801193:	c1 e8 0c             	shr    $0xc,%eax
  801196:	50                   	push   %eax
  801197:	e8 36 ff ff ff       	call   8010d2 <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 05                	js     8011a8 <fd_close+0x2d>
	    || fd != fd2)
  8011a3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a6:	74 0c                	je     8011b4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a8:	84 db                	test   %bl,%bl
  8011aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8011af:	0f 44 c2             	cmove  %edx,%eax
  8011b2:	eb 41                	jmp    8011f5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	ff 36                	pushl  (%esi)
  8011bd:	e8 66 ff ff ff       	call   801128 <dev_lookup>
  8011c2:	89 c3                	mov    %eax,%ebx
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 1a                	js     8011e5 <fd_close+0x6a>
		if (dev->dev_close)
  8011cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ce:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011d1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	74 0b                	je     8011e5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011da:	83 ec 0c             	sub    $0xc,%esp
  8011dd:	56                   	push   %esi
  8011de:	ff d0                	call   *%eax
  8011e0:	89 c3                	mov    %eax,%ebx
  8011e2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	56                   	push   %esi
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 ce f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	89 d8                	mov    %ebx,%eax
}
  8011f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	ff 75 08             	pushl  0x8(%ebp)
  801209:	e8 c4 fe ff ff       	call   8010d2 <fd_lookup>
  80120e:	83 c4 08             	add    $0x8,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 10                	js     801225 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	6a 01                	push   $0x1
  80121a:	ff 75 f4             	pushl  -0xc(%ebp)
  80121d:	e8 59 ff ff ff       	call   80117b <fd_close>
  801222:	83 c4 10             	add    $0x10,%esp
}
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <close_all>:

void
close_all(void)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	53                   	push   %ebx
  80122b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	53                   	push   %ebx
  801237:	e8 c0 ff ff ff       	call   8011fc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123c:	83 c3 01             	add    $0x1,%ebx
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	83 fb 20             	cmp    $0x20,%ebx
  801245:	75 ec                	jne    801233 <close_all+0xc>
		close(i);
}
  801247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 2c             	sub    $0x2c,%esp
  801255:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801258:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 6e fe ff ff       	call   8010d2 <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	0f 88 c1 00 00 00    	js     801330 <dup+0xe4>
		return r;
	close(newfdnum);
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	56                   	push   %esi
  801273:	e8 84 ff ff ff       	call   8011fc <close>

	newfd = INDEX2FD(newfdnum);
  801278:	89 f3                	mov    %esi,%ebx
  80127a:	c1 e3 0c             	shl    $0xc,%ebx
  80127d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801283:	83 c4 04             	add    $0x4,%esp
  801286:	ff 75 e4             	pushl  -0x1c(%ebp)
  801289:	e8 de fd ff ff       	call   80106c <fd2data>
  80128e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801290:	89 1c 24             	mov    %ebx,(%esp)
  801293:	e8 d4 fd ff ff       	call   80106c <fd2data>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129e:	89 f8                	mov    %edi,%eax
  8012a0:	c1 e8 16             	shr    $0x16,%eax
  8012a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012aa:	a8 01                	test   $0x1,%al
  8012ac:	74 37                	je     8012e5 <dup+0x99>
  8012ae:	89 f8                	mov    %edi,%eax
  8012b0:	c1 e8 0c             	shr    $0xc,%eax
  8012b3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ba:	f6 c2 01             	test   $0x1,%dl
  8012bd:	74 26                	je     8012e5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ce:	50                   	push   %eax
  8012cf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d2:	6a 00                	push   $0x0
  8012d4:	57                   	push   %edi
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 a0 f8 ff ff       	call   800b7c <sys_page_map>
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	83 c4 20             	add    $0x20,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 2e                	js     801313 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e8:	89 d0                	mov    %edx,%eax
  8012ea:	c1 e8 0c             	shr    $0xc,%eax
  8012ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f4:	83 ec 0c             	sub    $0xc,%esp
  8012f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fc:	50                   	push   %eax
  8012fd:	53                   	push   %ebx
  8012fe:	6a 00                	push   $0x0
  801300:	52                   	push   %edx
  801301:	6a 00                	push   $0x0
  801303:	e8 74 f8 ff ff       	call   800b7c <sys_page_map>
  801308:	89 c7                	mov    %eax,%edi
  80130a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130f:	85 ff                	test   %edi,%edi
  801311:	79 1d                	jns    801330 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	53                   	push   %ebx
  801317:	6a 00                	push   $0x0
  801319:	e8 a0 f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131e:	83 c4 08             	add    $0x8,%esp
  801321:	ff 75 d4             	pushl  -0x2c(%ebp)
  801324:	6a 00                	push   $0x0
  801326:	e8 93 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	89 f8                	mov    %edi,%eax
}
  801330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 14             	sub    $0x14,%esp
  80133f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	53                   	push   %ebx
  801347:	e8 86 fd ff ff       	call   8010d2 <fd_lookup>
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	89 c2                	mov    %eax,%edx
  801351:	85 c0                	test   %eax,%eax
  801353:	78 6d                	js     8013c2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135f:	ff 30                	pushl  (%eax)
  801361:	e8 c2 fd ff ff       	call   801128 <dev_lookup>
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 4c                	js     8013b9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801370:	8b 42 08             	mov    0x8(%edx),%eax
  801373:	83 e0 03             	and    $0x3,%eax
  801376:	83 f8 01             	cmp    $0x1,%eax
  801379:	75 21                	jne    80139c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137b:	a1 04 40 80 00       	mov    0x804004,%eax
  801380:	8b 40 54             	mov    0x54(%eax),%eax
  801383:	83 ec 04             	sub    $0x4,%esp
  801386:	53                   	push   %ebx
  801387:	50                   	push   %eax
  801388:	68 69 26 80 00       	push   $0x802669
  80138d:	e8 1f ee ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139a:	eb 26                	jmp    8013c2 <read+0x8a>
	}
	if (!dev->dev_read)
  80139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139f:	8b 40 08             	mov    0x8(%eax),%eax
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	74 17                	je     8013bd <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	ff 75 10             	pushl  0x10(%ebp)
  8013ac:	ff 75 0c             	pushl  0xc(%ebp)
  8013af:	52                   	push   %edx
  8013b0:	ff d0                	call   *%eax
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	eb 09                	jmp    8013c2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	eb 05                	jmp    8013c2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013c2:	89 d0                	mov    %edx,%eax
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	57                   	push   %edi
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013dd:	eb 21                	jmp    801400 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	89 f0                	mov    %esi,%eax
  8013e4:	29 d8                	sub    %ebx,%eax
  8013e6:	50                   	push   %eax
  8013e7:	89 d8                	mov    %ebx,%eax
  8013e9:	03 45 0c             	add    0xc(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	57                   	push   %edi
  8013ee:	e8 45 ff ff ff       	call   801338 <read>
		if (m < 0)
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 10                	js     80140a <readn+0x41>
			return m;
		if (m == 0)
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	74 0a                	je     801408 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fe:	01 c3                	add    %eax,%ebx
  801400:	39 f3                	cmp    %esi,%ebx
  801402:	72 db                	jb     8013df <readn+0x16>
  801404:	89 d8                	mov    %ebx,%eax
  801406:	eb 02                	jmp    80140a <readn+0x41>
  801408:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80140a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	53                   	push   %ebx
  801416:	83 ec 14             	sub    $0x14,%esp
  801419:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	53                   	push   %ebx
  801421:	e8 ac fc ff ff       	call   8010d2 <fd_lookup>
  801426:	83 c4 08             	add    $0x8,%esp
  801429:	89 c2                	mov    %eax,%edx
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 68                	js     801497 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	ff 30                	pushl  (%eax)
  80143b:	e8 e8 fc ff ff       	call   801128 <dev_lookup>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 47                	js     80148e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144e:	75 21                	jne    801471 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801450:	a1 04 40 80 00       	mov    0x804004,%eax
  801455:	8b 40 54             	mov    0x54(%eax),%eax
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	53                   	push   %ebx
  80145c:	50                   	push   %eax
  80145d:	68 85 26 80 00       	push   $0x802685
  801462:	e8 4a ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146f:	eb 26                	jmp    801497 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801471:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801474:	8b 52 0c             	mov    0xc(%edx),%edx
  801477:	85 d2                	test   %edx,%edx
  801479:	74 17                	je     801492 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	ff 75 10             	pushl  0x10(%ebp)
  801481:	ff 75 0c             	pushl  0xc(%ebp)
  801484:	50                   	push   %eax
  801485:	ff d2                	call   *%edx
  801487:	89 c2                	mov    %eax,%edx
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	eb 09                	jmp    801497 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148e:	89 c2                	mov    %eax,%edx
  801490:	eb 05                	jmp    801497 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801492:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801497:	89 d0                	mov    %edx,%eax
  801499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <seek>:

int
seek(int fdnum, off_t offset)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 08             	pushl  0x8(%ebp)
  8014ab:	e8 22 fc ff ff       	call   8010d2 <fd_lookup>
  8014b0:	83 c4 08             	add    $0x8,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 0e                	js     8014c5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 14             	sub    $0x14,%esp
  8014ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	53                   	push   %ebx
  8014d6:	e8 f7 fb ff ff       	call   8010d2 <fd_lookup>
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 65                	js     801549 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ee:	ff 30                	pushl  (%eax)
  8014f0:	e8 33 fc ff ff       	call   801128 <dev_lookup>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 44                	js     801540 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801503:	75 21                	jne    801526 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801505:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80150a:	8b 40 54             	mov    0x54(%eax),%eax
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	53                   	push   %ebx
  801511:	50                   	push   %eax
  801512:	68 48 26 80 00       	push   $0x802648
  801517:	e8 95 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801524:	eb 23                	jmp    801549 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801526:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801529:	8b 52 18             	mov    0x18(%edx),%edx
  80152c:	85 d2                	test   %edx,%edx
  80152e:	74 14                	je     801544 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	ff 75 0c             	pushl  0xc(%ebp)
  801536:	50                   	push   %eax
  801537:	ff d2                	call   *%edx
  801539:	89 c2                	mov    %eax,%edx
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	eb 09                	jmp    801549 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	89 c2                	mov    %eax,%edx
  801542:	eb 05                	jmp    801549 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801544:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801549:	89 d0                	mov    %edx,%eax
  80154b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 14             	sub    $0x14,%esp
  801557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	ff 75 08             	pushl  0x8(%ebp)
  801561:	e8 6c fb ff ff       	call   8010d2 <fd_lookup>
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	89 c2                	mov    %eax,%edx
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 58                	js     8015c7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801579:	ff 30                	pushl  (%eax)
  80157b:	e8 a8 fb ff ff       	call   801128 <dev_lookup>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 37                	js     8015be <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801587:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158e:	74 32                	je     8015c2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801590:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801593:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80159a:	00 00 00 
	stat->st_isdir = 0;
  80159d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a4:	00 00 00 
	stat->st_dev = dev;
  8015a7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	53                   	push   %ebx
  8015b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b4:	ff 50 14             	call   *0x14(%eax)
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 09                	jmp    8015c7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	eb 05                	jmp    8015c7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	6a 00                	push   $0x0
  8015d8:	ff 75 08             	pushl  0x8(%ebp)
  8015db:	e8 e3 01 00 00       	call   8017c3 <open>
  8015e0:	89 c3                	mov    %eax,%ebx
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 1b                	js     801604 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	ff 75 0c             	pushl  0xc(%ebp)
  8015ef:	50                   	push   %eax
  8015f0:	e8 5b ff ff ff       	call   801550 <fstat>
  8015f5:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f7:	89 1c 24             	mov    %ebx,(%esp)
  8015fa:	e8 fd fb ff ff       	call   8011fc <close>
	return r;
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	89 f0                	mov    %esi,%eax
}
  801604:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	89 c6                	mov    %eax,%esi
  801612:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801614:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80161b:	75 12                	jne    80162f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	6a 01                	push   $0x1
  801622:	e8 ce 08 00 00       	call   801ef5 <ipc_find_env>
  801627:	a3 00 40 80 00       	mov    %eax,0x804000
  80162c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162f:	6a 07                	push   $0x7
  801631:	68 00 50 80 00       	push   $0x805000
  801636:	56                   	push   %esi
  801637:	ff 35 00 40 80 00    	pushl  0x804000
  80163d:	e8 51 08 00 00       	call   801e93 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801642:	83 c4 0c             	add    $0xc,%esp
  801645:	6a 00                	push   $0x0
  801647:	53                   	push   %ebx
  801648:	6a 00                	push   $0x0
  80164a:	e8 cc 07 00 00       	call   801e1b <ipc_recv>
}
  80164f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801652:	5b                   	pop    %ebx
  801653:	5e                   	pop    %esi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80165c:	8b 45 08             	mov    0x8(%ebp),%eax
  80165f:	8b 40 0c             	mov    0xc(%eax),%eax
  801662:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80166f:	ba 00 00 00 00       	mov    $0x0,%edx
  801674:	b8 02 00 00 00       	mov    $0x2,%eax
  801679:	e8 8d ff ff ff       	call   80160b <fsipc>
}
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	8b 40 0c             	mov    0xc(%eax),%eax
  80168c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801691:	ba 00 00 00 00       	mov    $0x0,%edx
  801696:	b8 06 00 00 00       	mov    $0x6,%eax
  80169b:	e8 6b ff ff ff       	call   80160b <fsipc>
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8016af:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c1:	e8 45 ff ff ff       	call   80160b <fsipc>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 2c                	js     8016f6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	68 00 50 80 00       	push   $0x805000
  8016d2:	53                   	push   %ebx
  8016d3:	e8 5e f0 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d8:	a1 80 50 80 00       	mov    0x805080,%eax
  8016dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e3:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801704:	8b 55 08             	mov    0x8(%ebp),%edx
  801707:	8b 52 0c             	mov    0xc(%edx),%edx
  80170a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801710:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801715:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80171a:	0f 47 c2             	cmova  %edx,%eax
  80171d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801722:	50                   	push   %eax
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	68 08 50 80 00       	push   $0x805008
  80172b:	e8 98 f1 ff ff       	call   8008c8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801730:	ba 00 00 00 00       	mov    $0x0,%edx
  801735:	b8 04 00 00 00       	mov    $0x4,%eax
  80173a:	e8 cc fe ff ff       	call   80160b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	8b 40 0c             	mov    0xc(%eax),%eax
  80174f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801754:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 03 00 00 00       	mov    $0x3,%eax
  801764:	e8 a2 fe ff ff       	call   80160b <fsipc>
  801769:	89 c3                	mov    %eax,%ebx
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 4b                	js     8017ba <devfile_read+0x79>
		return r;
	assert(r <= n);
  80176f:	39 c6                	cmp    %eax,%esi
  801771:	73 16                	jae    801789 <devfile_read+0x48>
  801773:	68 b4 26 80 00       	push   $0x8026b4
  801778:	68 bb 26 80 00       	push   $0x8026bb
  80177d:	6a 7c                	push   $0x7c
  80177f:	68 d0 26 80 00       	push   $0x8026d0
  801784:	e8 bd 05 00 00       	call   801d46 <_panic>
	assert(r <= PGSIZE);
  801789:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178e:	7e 16                	jle    8017a6 <devfile_read+0x65>
  801790:	68 db 26 80 00       	push   $0x8026db
  801795:	68 bb 26 80 00       	push   $0x8026bb
  80179a:	6a 7d                	push   $0x7d
  80179c:	68 d0 26 80 00       	push   $0x8026d0
  8017a1:	e8 a0 05 00 00       	call   801d46 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	50                   	push   %eax
  8017aa:	68 00 50 80 00       	push   $0x805000
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	e8 11 f1 ff ff       	call   8008c8 <memmove>
	return r;
  8017b7:	83 c4 10             	add    $0x10,%esp
}
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 20             	sub    $0x20,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017cd:	53                   	push   %ebx
  8017ce:	e8 2a ef ff ff       	call   8006fd <strlen>
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017db:	7f 67                	jg     801844 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	e8 9a f8 ff ff       	call   801083 <fd_alloc>
  8017e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 57                	js     801849 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	53                   	push   %ebx
  8017f6:	68 00 50 80 00       	push   $0x805000
  8017fb:	e8 36 ef ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801800:	8b 45 0c             	mov    0xc(%ebp),%eax
  801803:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801808:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180b:	b8 01 00 00 00       	mov    $0x1,%eax
  801810:	e8 f6 fd ff ff       	call   80160b <fsipc>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	79 14                	jns    801832 <open+0x6f>
		fd_close(fd, 0);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	6a 00                	push   $0x0
  801823:	ff 75 f4             	pushl  -0xc(%ebp)
  801826:	e8 50 f9 ff ff       	call   80117b <fd_close>
		return r;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	89 da                	mov    %ebx,%edx
  801830:	eb 17                	jmp    801849 <open+0x86>
	}

	return fd2num(fd);
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	ff 75 f4             	pushl  -0xc(%ebp)
  801838:	e8 1f f8 ff ff       	call   80105c <fd2num>
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	eb 05                	jmp    801849 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801844:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801849:	89 d0                	mov    %edx,%eax
  80184b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 08 00 00 00       	mov    $0x8,%eax
  801860:	e8 a6 fd ff ff       	call   80160b <fsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	ff 75 08             	pushl  0x8(%ebp)
  801875:	e8 f2 f7 ff ff       	call   80106c <fd2data>
  80187a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80187c:	83 c4 08             	add    $0x8,%esp
  80187f:	68 e7 26 80 00       	push   $0x8026e7
  801884:	53                   	push   %ebx
  801885:	e8 ac ee ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80188a:	8b 46 04             	mov    0x4(%esi),%eax
  80188d:	2b 06                	sub    (%esi),%eax
  80188f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189c:	00 00 00 
	stat->st_dev = &devpipe;
  80189f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a6:	30 80 00 
	return 0;
}
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018bf:	53                   	push   %ebx
  8018c0:	6a 00                	push   $0x0
  8018c2:	e8 f7 f2 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018c7:	89 1c 24             	mov    %ebx,(%esp)
  8018ca:	e8 9d f7 ff ff       	call   80106c <fd2data>
  8018cf:	83 c4 08             	add    $0x8,%esp
  8018d2:	50                   	push   %eax
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 e4 f2 ff ff       	call   800bbe <sys_page_unmap>
}
  8018da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	57                   	push   %edi
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 1c             	sub    $0x1c,%esp
  8018e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018eb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f2:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018fb:	e8 35 06 00 00       	call   801f35 <pageref>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	89 3c 24             	mov    %edi,(%esp)
  801905:	e8 2b 06 00 00       	call   801f35 <pageref>
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	39 c3                	cmp    %eax,%ebx
  80190f:	0f 94 c1             	sete   %cl
  801912:	0f b6 c9             	movzbl %cl,%ecx
  801915:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801918:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80191e:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801921:	39 ce                	cmp    %ecx,%esi
  801923:	74 1b                	je     801940 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801925:	39 c3                	cmp    %eax,%ebx
  801927:	75 c4                	jne    8018ed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801929:	8b 42 64             	mov    0x64(%edx),%eax
  80192c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80192f:	50                   	push   %eax
  801930:	56                   	push   %esi
  801931:	68 ee 26 80 00       	push   $0x8026ee
  801936:	e8 76 e8 ff ff       	call   8001b1 <cprintf>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb ad                	jmp    8018ed <_pipeisclosed+0xe>
	}
}
  801940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801943:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5f                   	pop    %edi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	57                   	push   %edi
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	83 ec 28             	sub    $0x28,%esp
  801954:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801957:	56                   	push   %esi
  801958:	e8 0f f7 ff ff       	call   80106c <fd2data>
  80195d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	bf 00 00 00 00       	mov    $0x0,%edi
  801967:	eb 4b                	jmp    8019b4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801969:	89 da                	mov    %ebx,%edx
  80196b:	89 f0                	mov    %esi,%eax
  80196d:	e8 6d ff ff ff       	call   8018df <_pipeisclosed>
  801972:	85 c0                	test   %eax,%eax
  801974:	75 48                	jne    8019be <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801976:	e8 9f f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80197b:	8b 43 04             	mov    0x4(%ebx),%eax
  80197e:	8b 0b                	mov    (%ebx),%ecx
  801980:	8d 51 20             	lea    0x20(%ecx),%edx
  801983:	39 d0                	cmp    %edx,%eax
  801985:	73 e2                	jae    801969 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80198e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801991:	89 c2                	mov    %eax,%edx
  801993:	c1 fa 1f             	sar    $0x1f,%edx
  801996:	89 d1                	mov    %edx,%ecx
  801998:	c1 e9 1b             	shr    $0x1b,%ecx
  80199b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80199e:	83 e2 1f             	and    $0x1f,%edx
  8019a1:	29 ca                	sub    %ecx,%edx
  8019a3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ab:	83 c0 01             	add    $0x1,%eax
  8019ae:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b1:	83 c7 01             	add    $0x1,%edi
  8019b4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019b7:	75 c2                	jne    80197b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bc:	eb 05                	jmp    8019c3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	5f                   	pop    %edi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	57                   	push   %edi
  8019cf:	56                   	push   %esi
  8019d0:	53                   	push   %ebx
  8019d1:	83 ec 18             	sub    $0x18,%esp
  8019d4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019d7:	57                   	push   %edi
  8019d8:	e8 8f f6 ff ff       	call   80106c <fd2data>
  8019dd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e7:	eb 3d                	jmp    801a26 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019e9:	85 db                	test   %ebx,%ebx
  8019eb:	74 04                	je     8019f1 <devpipe_read+0x26>
				return i;
  8019ed:	89 d8                	mov    %ebx,%eax
  8019ef:	eb 44                	jmp    801a35 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019f1:	89 f2                	mov    %esi,%edx
  8019f3:	89 f8                	mov    %edi,%eax
  8019f5:	e8 e5 fe ff ff       	call   8018df <_pipeisclosed>
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	75 32                	jne    801a30 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019fe:	e8 17 f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a03:	8b 06                	mov    (%esi),%eax
  801a05:	3b 46 04             	cmp    0x4(%esi),%eax
  801a08:	74 df                	je     8019e9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a0a:	99                   	cltd   
  801a0b:	c1 ea 1b             	shr    $0x1b,%edx
  801a0e:	01 d0                	add    %edx,%eax
  801a10:	83 e0 1f             	and    $0x1f,%eax
  801a13:	29 d0                	sub    %edx,%eax
  801a15:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a20:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a23:	83 c3 01             	add    $0x1,%ebx
  801a26:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a29:	75 d8                	jne    801a03 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2e:	eb 05                	jmp    801a35 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a30:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5f                   	pop    %edi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a48:	50                   	push   %eax
  801a49:	e8 35 f6 ff ff       	call   801083 <fd_alloc>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	89 c2                	mov    %eax,%edx
  801a53:	85 c0                	test   %eax,%eax
  801a55:	0f 88 2c 01 00 00    	js     801b87 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5b:	83 ec 04             	sub    $0x4,%esp
  801a5e:	68 07 04 00 00       	push   $0x407
  801a63:	ff 75 f4             	pushl  -0xc(%ebp)
  801a66:	6a 00                	push   $0x0
  801a68:	e8 cc f0 ff ff       	call   800b39 <sys_page_alloc>
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	89 c2                	mov    %eax,%edx
  801a72:	85 c0                	test   %eax,%eax
  801a74:	0f 88 0d 01 00 00    	js     801b87 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a80:	50                   	push   %eax
  801a81:	e8 fd f5 ff ff       	call   801083 <fd_alloc>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	0f 88 e2 00 00 00    	js     801b75 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a93:	83 ec 04             	sub    $0x4,%esp
  801a96:	68 07 04 00 00       	push   $0x407
  801a9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9e:	6a 00                	push   $0x0
  801aa0:	e8 94 f0 ff ff       	call   800b39 <sys_page_alloc>
  801aa5:	89 c3                	mov    %eax,%ebx
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	0f 88 c3 00 00 00    	js     801b75 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab8:	e8 af f5 ff ff       	call   80106c <fd2data>
  801abd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abf:	83 c4 0c             	add    $0xc,%esp
  801ac2:	68 07 04 00 00       	push   $0x407
  801ac7:	50                   	push   %eax
  801ac8:	6a 00                	push   $0x0
  801aca:	e8 6a f0 ff ff       	call   800b39 <sys_page_alloc>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	0f 88 89 00 00 00    	js     801b65 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae2:	e8 85 f5 ff ff       	call   80106c <fd2data>
  801ae7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aee:	50                   	push   %eax
  801aef:	6a 00                	push   $0x0
  801af1:	56                   	push   %esi
  801af2:	6a 00                	push   $0x0
  801af4:	e8 83 f0 ff ff       	call   800b7c <sys_page_map>
  801af9:	89 c3                	mov    %eax,%ebx
  801afb:	83 c4 20             	add    $0x20,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 55                	js     801b57 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b02:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b17:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b20:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b25:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b32:	e8 25 f5 ff ff       	call   80105c <fd2num>
  801b37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b3c:	83 c4 04             	add    $0x4,%esp
  801b3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b42:	e8 15 f5 ff ff       	call   80105c <fd2num>
  801b47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	ba 00 00 00 00       	mov    $0x0,%edx
  801b55:	eb 30                	jmp    801b87 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	56                   	push   %esi
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 5c f0 ff ff       	call   800bbe <sys_page_unmap>
  801b62:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b65:	83 ec 08             	sub    $0x8,%esp
  801b68:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 4c f0 ff ff       	call   800bbe <sys_page_unmap>
  801b72:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7b:	6a 00                	push   $0x0
  801b7d:	e8 3c f0 ff ff       	call   800bbe <sys_page_unmap>
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b87:	89 d0                	mov    %edx,%eax
  801b89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b99:	50                   	push   %eax
  801b9a:	ff 75 08             	pushl  0x8(%ebp)
  801b9d:	e8 30 f5 ff ff       	call   8010d2 <fd_lookup>
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	78 18                	js     801bc1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ba9:	83 ec 0c             	sub    $0xc,%esp
  801bac:	ff 75 f4             	pushl  -0xc(%ebp)
  801baf:	e8 b8 f4 ff ff       	call   80106c <fd2data>
	return _pipeisclosed(fd, p);
  801bb4:	89 c2                	mov    %eax,%edx
  801bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb9:	e8 21 fd ff ff       	call   8018df <_pipeisclosed>
  801bbe:	83 c4 10             	add    $0x10,%esp
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bd3:	68 06 27 80 00       	push   $0x802706
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	e8 56 eb ff ff       	call   800736 <strcpy>
	return 0;
}
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	57                   	push   %edi
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bf8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bfe:	eb 2d                	jmp    801c2d <devcons_write+0x46>
		m = n - tot;
  801c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c03:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c05:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c08:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c0d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c10:	83 ec 04             	sub    $0x4,%esp
  801c13:	53                   	push   %ebx
  801c14:	03 45 0c             	add    0xc(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	57                   	push   %edi
  801c19:	e8 aa ec ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801c1e:	83 c4 08             	add    $0x8,%esp
  801c21:	53                   	push   %ebx
  801c22:	57                   	push   %edi
  801c23:	e8 55 ee ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c28:	01 de                	add    %ebx,%esi
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	89 f0                	mov    %esi,%eax
  801c2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c32:	72 cc                	jb     801c00 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c37:	5b                   	pop    %ebx
  801c38:	5e                   	pop    %esi
  801c39:	5f                   	pop    %edi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4b:	74 2a                	je     801c77 <devcons_read+0x3b>
  801c4d:	eb 05                	jmp    801c54 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c4f:	e8 c6 ee ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c54:	e8 42 ee ff ff       	call   800a9b <sys_cgetc>
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	74 f2                	je     801c4f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 16                	js     801c77 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c61:	83 f8 04             	cmp    $0x4,%eax
  801c64:	74 0c                	je     801c72 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c69:	88 02                	mov    %al,(%edx)
	return 1;
  801c6b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c70:	eb 05                	jmp    801c77 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c72:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c85:	6a 01                	push   $0x1
  801c87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8a:	50                   	push   %eax
  801c8b:	e8 ed ed ff ff       	call   800a7d <sys_cputs>
}
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <getchar>:

int
getchar(void)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c9b:	6a 01                	push   $0x1
  801c9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca0:	50                   	push   %eax
  801ca1:	6a 00                	push   $0x0
  801ca3:	e8 90 f6 ff ff       	call   801338 <read>
	if (r < 0)
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 0f                	js     801cbe <getchar+0x29>
		return r;
	if (r < 1)
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	7e 06                	jle    801cb9 <getchar+0x24>
		return -E_EOF;
	return c;
  801cb3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cb7:	eb 05                	jmp    801cbe <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cb9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc9:	50                   	push   %eax
  801cca:	ff 75 08             	pushl  0x8(%ebp)
  801ccd:	e8 00 f4 ff ff       	call   8010d2 <fd_lookup>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 11                	js     801cea <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce2:	39 10                	cmp    %edx,(%eax)
  801ce4:	0f 94 c0             	sete   %al
  801ce7:	0f b6 c0             	movzbl %al,%eax
}
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <opencons>:

int
opencons(void)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf5:	50                   	push   %eax
  801cf6:	e8 88 f3 ff ff       	call   801083 <fd_alloc>
  801cfb:	83 c4 10             	add    $0x10,%esp
		return r;
  801cfe:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 3e                	js     801d42 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d04:	83 ec 04             	sub    $0x4,%esp
  801d07:	68 07 04 00 00       	push   $0x407
  801d0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 23 ee ff ff       	call   800b39 <sys_page_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
		return r;
  801d19:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 23                	js     801d42 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d1f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d28:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	50                   	push   %eax
  801d38:	e8 1f f3 ff ff       	call   80105c <fd2num>
  801d3d:	89 c2                	mov    %eax,%edx
  801d3f:	83 c4 10             	add    $0x10,%esp
}
  801d42:	89 d0                	mov    %edx,%eax
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	56                   	push   %esi
  801d4a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d4b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d4e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d54:	e8 a2 ed ff ff       	call   800afb <sys_getenvid>
  801d59:	83 ec 0c             	sub    $0xc,%esp
  801d5c:	ff 75 0c             	pushl  0xc(%ebp)
  801d5f:	ff 75 08             	pushl  0x8(%ebp)
  801d62:	56                   	push   %esi
  801d63:	50                   	push   %eax
  801d64:	68 14 27 80 00       	push   $0x802714
  801d69:	e8 43 e4 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d6e:	83 c4 18             	add    $0x18,%esp
  801d71:	53                   	push   %ebx
  801d72:	ff 75 10             	pushl  0x10(%ebp)
  801d75:	e8 e6 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801d7a:	c7 04 24 ff 26 80 00 	movl   $0x8026ff,(%esp)
  801d81:	e8 2b e4 ff ff       	call   8001b1 <cprintf>
  801d86:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d89:	cc                   	int3   
  801d8a:	eb fd                	jmp    801d89 <_panic+0x43>

00801d8c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d92:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d99:	75 2a                	jne    801dc5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	6a 07                	push   $0x7
  801da0:	68 00 f0 bf ee       	push   $0xeebff000
  801da5:	6a 00                	push   $0x0
  801da7:	e8 8d ed ff ff       	call   800b39 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	79 12                	jns    801dc5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801db3:	50                   	push   %eax
  801db4:	68 38 27 80 00       	push   $0x802738
  801db9:	6a 23                	push   $0x23
  801dbb:	68 3c 27 80 00       	push   $0x80273c
  801dc0:	e8 81 ff ff ff       	call   801d46 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	68 f7 1d 80 00       	push   $0x801df7
  801dd5:	6a 00                	push   $0x0
  801dd7:	e8 a8 ee ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	79 12                	jns    801df5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801de3:	50                   	push   %eax
  801de4:	68 38 27 80 00       	push   $0x802738
  801de9:	6a 2c                	push   $0x2c
  801deb:	68 3c 27 80 00       	push   $0x80273c
  801df0:	e8 51 ff ff ff       	call   801d46 <_panic>
	}
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801df7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dfd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dff:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e02:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e06:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e0b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e0f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e11:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e14:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e15:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e18:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e19:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e1a:	c3                   	ret    

00801e1b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	56                   	push   %esi
  801e1f:	53                   	push   %ebx
  801e20:	8b 75 08             	mov    0x8(%ebp),%esi
  801e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	75 12                	jne    801e3f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	68 00 00 c0 ee       	push   $0xeec00000
  801e35:	e8 af ee ff ff       	call   800ce9 <sys_ipc_recv>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	eb 0c                	jmp    801e4b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	50                   	push   %eax
  801e43:	e8 a1 ee ff ff       	call   800ce9 <sys_ipc_recv>
  801e48:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e4b:	85 f6                	test   %esi,%esi
  801e4d:	0f 95 c1             	setne  %cl
  801e50:	85 db                	test   %ebx,%ebx
  801e52:	0f 95 c2             	setne  %dl
  801e55:	84 d1                	test   %dl,%cl
  801e57:	74 09                	je     801e62 <ipc_recv+0x47>
  801e59:	89 c2                	mov    %eax,%edx
  801e5b:	c1 ea 1f             	shr    $0x1f,%edx
  801e5e:	84 d2                	test   %dl,%dl
  801e60:	75 2a                	jne    801e8c <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e62:	85 f6                	test   %esi,%esi
  801e64:	74 0d                	je     801e73 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e66:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e71:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e73:	85 db                	test   %ebx,%ebx
  801e75:	74 0d                	je     801e84 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e77:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e82:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e84:	a1 04 40 80 00       	mov    0x804004,%eax
  801e89:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5e                   	pop    %esi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	57                   	push   %edi
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ea5:	85 db                	test   %ebx,%ebx
  801ea7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eac:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eaf:	ff 75 14             	pushl  0x14(%ebp)
  801eb2:	53                   	push   %ebx
  801eb3:	56                   	push   %esi
  801eb4:	57                   	push   %edi
  801eb5:	e8 0c ee ff ff       	call   800cc6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eba:	89 c2                	mov    %eax,%edx
  801ebc:	c1 ea 1f             	shr    $0x1f,%edx
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	84 d2                	test   %dl,%dl
  801ec4:	74 17                	je     801edd <ipc_send+0x4a>
  801ec6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec9:	74 12                	je     801edd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ecb:	50                   	push   %eax
  801ecc:	68 4a 27 80 00       	push   $0x80274a
  801ed1:	6a 47                	push   $0x47
  801ed3:	68 58 27 80 00       	push   $0x802758
  801ed8:	e8 69 fe ff ff       	call   801d46 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801edd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee0:	75 07                	jne    801ee9 <ipc_send+0x56>
			sys_yield();
  801ee2:	e8 33 ec ff ff       	call   800b1a <sys_yield>
  801ee7:	eb c6                	jmp    801eaf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	75 c2                	jne    801eaf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f00:	89 c2                	mov    %eax,%edx
  801f02:	c1 e2 07             	shl    $0x7,%edx
  801f05:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f0c:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f0f:	39 ca                	cmp    %ecx,%edx
  801f11:	75 11                	jne    801f24 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f13:	89 c2                	mov    %eax,%edx
  801f15:	c1 e2 07             	shl    $0x7,%edx
  801f18:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f1f:	8b 40 54             	mov    0x54(%eax),%eax
  801f22:	eb 0f                	jmp    801f33 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f24:	83 c0 01             	add    $0x1,%eax
  801f27:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2c:	75 d2                	jne    801f00 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f33:	5d                   	pop    %ebp
  801f34:	c3                   	ret    

00801f35 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	c1 e8 16             	shr    $0x16,%eax
  801f40:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4c:	f6 c1 01             	test   $0x1,%cl
  801f4f:	74 1d                	je     801f6e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f51:	c1 ea 0c             	shr    $0xc,%edx
  801f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5b:	f6 c2 01             	test   $0x1,%dl
  801f5e:	74 0e                	je     801f6e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f60:	c1 ea 0c             	shr    $0xc,%edx
  801f63:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6a:	ef 
  801f6b:	0f b7 c0             	movzwl %ax,%eax
}
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
