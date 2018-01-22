
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 1e 80 00       	push   $0x801e60
  80003e:	e8 6e 01 00 00       	call   8001b1 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 50             	mov    0x50(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 1e 80 00       	push   $0x801e6e
  800054:	e8 58 01 00 00       	call   8001b1 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800067:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80006e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800071:	e8 85 0a 00 00       	call   800afb <sys_getenvid>
  800076:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	50                   	push   %eax
  80007c:	68 88 1e 80 00       	push   $0x801e88
  800081:	e8 2b 01 00 00       	call   8001b1 <cprintf>
  800086:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80008c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800099:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80009e:	89 c1                	mov    %eax,%ecx
  8000a0:	c1 e1 07             	shl    $0x7,%ecx
  8000a3:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000aa:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000ad:	39 cb                	cmp    %ecx,%ebx
  8000af:	0f 44 fa             	cmove  %edx,%edi
  8000b2:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000b7:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000ba:	83 c0 01             	add    $0x1,%eax
  8000bd:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000c8:	75 d4                	jne    80009e <libmain+0x40>
  8000ca:	89 f0                	mov    %esi,%eax
  8000cc:	84 c0                	test   %al,%al
  8000ce:	74 06                	je     8000d6 <libmain+0x78>
  8000d0:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000da:	7e 0a                	jle    8000e6 <libmain+0x88>
		binaryname = argv[0];
  8000dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000df:	8b 00                	mov    (%eax),%eax
  8000e1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	ff 75 0c             	pushl  0xc(%ebp)
  8000ec:	ff 75 08             	pushl  0x8(%ebp)
  8000ef:	e8 3f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f4:	e8 0b 00 00 00       	call   800104 <exit>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
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
  80010a:	e8 06 0e 00 00       	call   800f15 <close_all>
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
  800214:	e8 b7 19 00 00       	call   801bd0 <__udivdi3>
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
  800257:	e8 a4 1a 00 00       	call   801d00 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 b1 1e 80 00 	movsbl 0x801eb1(%eax),%eax
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
  80035b:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
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
  80041f:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 c9 1e 80 00       	push   $0x801ec9
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
  800443:	68 91 22 80 00       	push   $0x802291
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
  800467:	b8 c2 1e 80 00       	mov    $0x801ec2,%eax
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
  800ae2:	68 bf 21 80 00       	push   $0x8021bf
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 dc 21 80 00       	push   $0x8021dc
  800aee:	e8 41 0f 00 00       	call   801a34 <_panic>

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
  800b63:	68 bf 21 80 00       	push   $0x8021bf
  800b68:	6a 23                	push   $0x23
  800b6a:	68 dc 21 80 00       	push   $0x8021dc
  800b6f:	e8 c0 0e 00 00       	call   801a34 <_panic>

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
  800ba5:	68 bf 21 80 00       	push   $0x8021bf
  800baa:	6a 23                	push   $0x23
  800bac:	68 dc 21 80 00       	push   $0x8021dc
  800bb1:	e8 7e 0e 00 00       	call   801a34 <_panic>

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
  800be7:	68 bf 21 80 00       	push   $0x8021bf
  800bec:	6a 23                	push   $0x23
  800bee:	68 dc 21 80 00       	push   $0x8021dc
  800bf3:	e8 3c 0e 00 00       	call   801a34 <_panic>

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
  800c29:	68 bf 21 80 00       	push   $0x8021bf
  800c2e:	6a 23                	push   $0x23
  800c30:	68 dc 21 80 00       	push   $0x8021dc
  800c35:	e8 fa 0d 00 00       	call   801a34 <_panic>

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
  800c6b:	68 bf 21 80 00       	push   $0x8021bf
  800c70:	6a 23                	push   $0x23
  800c72:	68 dc 21 80 00       	push   $0x8021dc
  800c77:	e8 b8 0d 00 00       	call   801a34 <_panic>
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
  800cad:	68 bf 21 80 00       	push   $0x8021bf
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 dc 21 80 00       	push   $0x8021dc
  800cb9:	e8 76 0d 00 00       	call   801a34 <_panic>

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
  800d11:	68 bf 21 80 00       	push   $0x8021bf
  800d16:	6a 23                	push   $0x23
  800d18:	68 dc 21 80 00       	push   $0x8021dc
  800d1d:	e8 12 0d 00 00       	call   801a34 <_panic>

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

00800d4a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	05 00 00 00 30       	add    $0x30000000,%eax
  800d55:	c1 e8 0c             	shr    $0xc,%eax
}
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	05 00 00 00 30       	add    $0x30000000,%eax
  800d65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d77:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7c:	89 c2                	mov    %eax,%edx
  800d7e:	c1 ea 16             	shr    $0x16,%edx
  800d81:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d88:	f6 c2 01             	test   $0x1,%dl
  800d8b:	74 11                	je     800d9e <fd_alloc+0x2d>
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	c1 ea 0c             	shr    $0xc,%edx
  800d92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d99:	f6 c2 01             	test   $0x1,%dl
  800d9c:	75 09                	jne    800da7 <fd_alloc+0x36>
			*fd_store = fd;
  800d9e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da0:	b8 00 00 00 00       	mov    $0x0,%eax
  800da5:	eb 17                	jmp    800dbe <fd_alloc+0x4d>
  800da7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db1:	75 c9                	jne    800d7c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800db9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc6:	83 f8 1f             	cmp    $0x1f,%eax
  800dc9:	77 36                	ja     800e01 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcb:	c1 e0 0c             	shl    $0xc,%eax
  800dce:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd3:	89 c2                	mov    %eax,%edx
  800dd5:	c1 ea 16             	shr    $0x16,%edx
  800dd8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ddf:	f6 c2 01             	test   $0x1,%dl
  800de2:	74 24                	je     800e08 <fd_lookup+0x48>
  800de4:	89 c2                	mov    %eax,%edx
  800de6:	c1 ea 0c             	shr    $0xc,%edx
  800de9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df0:	f6 c2 01             	test   $0x1,%dl
  800df3:	74 1a                	je     800e0f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df8:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	eb 13                	jmp    800e14 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e06:	eb 0c                	jmp    800e14 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0d:	eb 05                	jmp    800e14 <fd_lookup+0x54>
  800e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	83 ec 08             	sub    $0x8,%esp
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	ba 68 22 80 00       	mov    $0x802268,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e24:	eb 13                	jmp    800e39 <dev_lookup+0x23>
  800e26:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e29:	39 08                	cmp    %ecx,(%eax)
  800e2b:	75 0c                	jne    800e39 <dev_lookup+0x23>
			*dev = devtab[i];
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
  800e37:	eb 2e                	jmp    800e67 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e39:	8b 02                	mov    (%edx),%eax
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	75 e7                	jne    800e26 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e3f:	a1 04 40 80 00       	mov    0x804004,%eax
  800e44:	8b 40 50             	mov    0x50(%eax),%eax
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	51                   	push   %ecx
  800e4b:	50                   	push   %eax
  800e4c:	68 ec 21 80 00       	push   $0x8021ec
  800e51:	e8 5b f3 ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  800e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 10             	sub    $0x10,%esp
  800e71:	8b 75 08             	mov    0x8(%ebp),%esi
  800e74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7a:	50                   	push   %eax
  800e7b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e81:	c1 e8 0c             	shr    $0xc,%eax
  800e84:	50                   	push   %eax
  800e85:	e8 36 ff ff ff       	call   800dc0 <fd_lookup>
  800e8a:	83 c4 08             	add    $0x8,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 05                	js     800e96 <fd_close+0x2d>
	    || fd != fd2)
  800e91:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e94:	74 0c                	je     800ea2 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e96:	84 db                	test   %bl,%bl
  800e98:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9d:	0f 44 c2             	cmove  %edx,%eax
  800ea0:	eb 41                	jmp    800ee3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea2:	83 ec 08             	sub    $0x8,%esp
  800ea5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ea8:	50                   	push   %eax
  800ea9:	ff 36                	pushl  (%esi)
  800eab:	e8 66 ff ff ff       	call   800e16 <dev_lookup>
  800eb0:	89 c3                	mov    %eax,%ebx
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	78 1a                	js     800ed3 <fd_close+0x6a>
		if (dev->dev_close)
  800eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ebf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	74 0b                	je     800ed3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	56                   	push   %esi
  800ecc:	ff d0                	call   *%eax
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	56                   	push   %esi
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 e0 fc ff ff       	call   800bbe <sys_page_unmap>
	return r;
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	89 d8                	mov    %ebx,%eax
}
  800ee3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef3:	50                   	push   %eax
  800ef4:	ff 75 08             	pushl  0x8(%ebp)
  800ef7:	e8 c4 fe ff ff       	call   800dc0 <fd_lookup>
  800efc:	83 c4 08             	add    $0x8,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	78 10                	js     800f13 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f03:	83 ec 08             	sub    $0x8,%esp
  800f06:	6a 01                	push   $0x1
  800f08:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0b:	e8 59 ff ff ff       	call   800e69 <fd_close>
  800f10:	83 c4 10             	add    $0x10,%esp
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <close_all>:

void
close_all(void)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	53                   	push   %ebx
  800f19:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f21:	83 ec 0c             	sub    $0xc,%esp
  800f24:	53                   	push   %ebx
  800f25:	e8 c0 ff ff ff       	call   800eea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2a:	83 c3 01             	add    $0x1,%ebx
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	83 fb 20             	cmp    $0x20,%ebx
  800f33:	75 ec                	jne    800f21 <close_all+0xc>
		close(i);
}
  800f35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 2c             	sub    $0x2c,%esp
  800f43:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	ff 75 08             	pushl  0x8(%ebp)
  800f4d:	e8 6e fe ff ff       	call   800dc0 <fd_lookup>
  800f52:	83 c4 08             	add    $0x8,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	0f 88 c1 00 00 00    	js     80101e <dup+0xe4>
		return r;
	close(newfdnum);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	56                   	push   %esi
  800f61:	e8 84 ff ff ff       	call   800eea <close>

	newfd = INDEX2FD(newfdnum);
  800f66:	89 f3                	mov    %esi,%ebx
  800f68:	c1 e3 0c             	shl    $0xc,%ebx
  800f6b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f71:	83 c4 04             	add    $0x4,%esp
  800f74:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f77:	e8 de fd ff ff       	call   800d5a <fd2data>
  800f7c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f7e:	89 1c 24             	mov    %ebx,(%esp)
  800f81:	e8 d4 fd ff ff       	call   800d5a <fd2data>
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8c:	89 f8                	mov    %edi,%eax
  800f8e:	c1 e8 16             	shr    $0x16,%eax
  800f91:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f98:	a8 01                	test   $0x1,%al
  800f9a:	74 37                	je     800fd3 <dup+0x99>
  800f9c:	89 f8                	mov    %edi,%eax
  800f9e:	c1 e8 0c             	shr    $0xc,%eax
  800fa1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa8:	f6 c2 01             	test   $0x1,%dl
  800fab:	74 26                	je     800fd3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbc:	50                   	push   %eax
  800fbd:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc0:	6a 00                	push   $0x0
  800fc2:	57                   	push   %edi
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 b2 fb ff ff       	call   800b7c <sys_page_map>
  800fca:	89 c7                	mov    %eax,%edi
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 2e                	js     801001 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd6:	89 d0                	mov    %edx,%eax
  800fd8:	c1 e8 0c             	shr    $0xc,%eax
  800fdb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fea:	50                   	push   %eax
  800feb:	53                   	push   %ebx
  800fec:	6a 00                	push   $0x0
  800fee:	52                   	push   %edx
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 86 fb ff ff       	call   800b7c <sys_page_map>
  800ff6:	89 c7                	mov    %eax,%edi
  800ff8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ffb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffd:	85 ff                	test   %edi,%edi
  800fff:	79 1d                	jns    80101e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	53                   	push   %ebx
  801005:	6a 00                	push   $0x0
  801007:	e8 b2 fb ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801012:	6a 00                	push   $0x0
  801014:	e8 a5 fb ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	89 f8                	mov    %edi,%eax
}
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 14             	sub    $0x14,%esp
  80102d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801030:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801033:	50                   	push   %eax
  801034:	53                   	push   %ebx
  801035:	e8 86 fd ff ff       	call   800dc0 <fd_lookup>
  80103a:	83 c4 08             	add    $0x8,%esp
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 6d                	js     8010b0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801049:	50                   	push   %eax
  80104a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104d:	ff 30                	pushl  (%eax)
  80104f:	e8 c2 fd ff ff       	call   800e16 <dev_lookup>
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	78 4c                	js     8010a7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80105e:	8b 42 08             	mov    0x8(%edx),%eax
  801061:	83 e0 03             	and    $0x3,%eax
  801064:	83 f8 01             	cmp    $0x1,%eax
  801067:	75 21                	jne    80108a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801069:	a1 04 40 80 00       	mov    0x804004,%eax
  80106e:	8b 40 50             	mov    0x50(%eax),%eax
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	53                   	push   %ebx
  801075:	50                   	push   %eax
  801076:	68 2d 22 80 00       	push   $0x80222d
  80107b:	e8 31 f1 ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801088:	eb 26                	jmp    8010b0 <read+0x8a>
	}
	if (!dev->dev_read)
  80108a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108d:	8b 40 08             	mov    0x8(%eax),%eax
  801090:	85 c0                	test   %eax,%eax
  801092:	74 17                	je     8010ab <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	ff 75 10             	pushl  0x10(%ebp)
  80109a:	ff 75 0c             	pushl  0xc(%ebp)
  80109d:	52                   	push   %edx
  80109e:	ff d0                	call   *%eax
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	eb 09                	jmp    8010b0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a7:	89 c2                	mov    %eax,%edx
  8010a9:	eb 05                	jmp    8010b0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010b0:	89 d0                	mov    %edx,%eax
  8010b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cb:	eb 21                	jmp    8010ee <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	89 f0                	mov    %esi,%eax
  8010d2:	29 d8                	sub    %ebx,%eax
  8010d4:	50                   	push   %eax
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	03 45 0c             	add    0xc(%ebp),%eax
  8010da:	50                   	push   %eax
  8010db:	57                   	push   %edi
  8010dc:	e8 45 ff ff ff       	call   801026 <read>
		if (m < 0)
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 10                	js     8010f8 <readn+0x41>
			return m;
		if (m == 0)
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	74 0a                	je     8010f6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ec:	01 c3                	add    %eax,%ebx
  8010ee:	39 f3                	cmp    %esi,%ebx
  8010f0:	72 db                	jb     8010cd <readn+0x16>
  8010f2:	89 d8                	mov    %ebx,%eax
  8010f4:	eb 02                	jmp    8010f8 <readn+0x41>
  8010f6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	83 ec 14             	sub    $0x14,%esp
  801107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	53                   	push   %ebx
  80110f:	e8 ac fc ff ff       	call   800dc0 <fd_lookup>
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	89 c2                	mov    %eax,%edx
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 68                	js     801185 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801127:	ff 30                	pushl  (%eax)
  801129:	e8 e8 fc ff ff       	call   800e16 <dev_lookup>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 47                	js     80117c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801135:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801138:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113c:	75 21                	jne    80115f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80113e:	a1 04 40 80 00       	mov    0x804004,%eax
  801143:	8b 40 50             	mov    0x50(%eax),%eax
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	53                   	push   %ebx
  80114a:	50                   	push   %eax
  80114b:	68 49 22 80 00       	push   $0x802249
  801150:	e8 5c f0 ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80115d:	eb 26                	jmp    801185 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80115f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801162:	8b 52 0c             	mov    0xc(%edx),%edx
  801165:	85 d2                	test   %edx,%edx
  801167:	74 17                	je     801180 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	ff 75 10             	pushl  0x10(%ebp)
  80116f:	ff 75 0c             	pushl  0xc(%ebp)
  801172:	50                   	push   %eax
  801173:	ff d2                	call   *%edx
  801175:	89 c2                	mov    %eax,%edx
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	eb 09                	jmp    801185 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	eb 05                	jmp    801185 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801180:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801185:	89 d0                	mov    %edx,%eax
  801187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <seek>:

int
seek(int fdnum, off_t offset)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801192:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	ff 75 08             	pushl  0x8(%ebp)
  801199:	e8 22 fc ff ff       	call   800dc0 <fd_lookup>
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 0e                	js     8011b3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 14             	sub    $0x14,%esp
  8011bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	53                   	push   %ebx
  8011c4:	e8 f7 fb ff ff       	call   800dc0 <fd_lookup>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 65                	js     801237 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dc:	ff 30                	pushl  (%eax)
  8011de:	e8 33 fc ff ff       	call   800e16 <dev_lookup>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 44                	js     80122e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f1:	75 21                	jne    801214 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f8:	8b 40 50             	mov    0x50(%eax),%eax
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	53                   	push   %ebx
  8011ff:	50                   	push   %eax
  801200:	68 0c 22 80 00       	push   $0x80220c
  801205:	e8 a7 ef ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801212:	eb 23                	jmp    801237 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801214:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801217:	8b 52 18             	mov    0x18(%edx),%edx
  80121a:	85 d2                	test   %edx,%edx
  80121c:	74 14                	je     801232 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	ff 75 0c             	pushl  0xc(%ebp)
  801224:	50                   	push   %eax
  801225:	ff d2                	call   *%edx
  801227:	89 c2                	mov    %eax,%edx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	eb 09                	jmp    801237 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122e:	89 c2                	mov    %eax,%edx
  801230:	eb 05                	jmp    801237 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801232:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801237:	89 d0                	mov    %edx,%eax
  801239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	53                   	push   %ebx
  801242:	83 ec 14             	sub    $0x14,%esp
  801245:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801248:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	ff 75 08             	pushl  0x8(%ebp)
  80124f:	e8 6c fb ff ff       	call   800dc0 <fd_lookup>
  801254:	83 c4 08             	add    $0x8,%esp
  801257:	89 c2                	mov    %eax,%edx
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 58                	js     8012b5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801267:	ff 30                	pushl  (%eax)
  801269:	e8 a8 fb ff ff       	call   800e16 <dev_lookup>
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 37                	js     8012ac <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801278:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80127c:	74 32                	je     8012b0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80127e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801281:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801288:	00 00 00 
	stat->st_isdir = 0;
  80128b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801292:	00 00 00 
	stat->st_dev = dev;
  801295:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	53                   	push   %ebx
  80129f:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a2:	ff 50 14             	call   *0x14(%eax)
  8012a5:	89 c2                	mov    %eax,%edx
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	eb 09                	jmp    8012b5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	eb 05                	jmp    8012b5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b5:	89 d0                	mov    %edx,%eax
  8012b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	56                   	push   %esi
  8012c0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c1:	83 ec 08             	sub    $0x8,%esp
  8012c4:	6a 00                	push   $0x0
  8012c6:	ff 75 08             	pushl  0x8(%ebp)
  8012c9:	e8 e3 01 00 00       	call   8014b1 <open>
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 1b                	js     8012f2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	ff 75 0c             	pushl  0xc(%ebp)
  8012dd:	50                   	push   %eax
  8012de:	e8 5b ff ff ff       	call   80123e <fstat>
  8012e3:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e5:	89 1c 24             	mov    %ebx,(%esp)
  8012e8:	e8 fd fb ff ff       	call   800eea <close>
	return r;
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	89 f0                	mov    %esi,%eax
}
  8012f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5e                   	pop    %esi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	56                   	push   %esi
  8012fd:	53                   	push   %ebx
  8012fe:	89 c6                	mov    %eax,%esi
  801300:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801302:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801309:	75 12                	jne    80131d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	6a 01                	push   $0x1
  801310:	e8 3c 08 00 00       	call   801b51 <ipc_find_env>
  801315:	a3 00 40 80 00       	mov    %eax,0x804000
  80131a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131d:	6a 07                	push   $0x7
  80131f:	68 00 50 80 00       	push   $0x805000
  801324:	56                   	push   %esi
  801325:	ff 35 00 40 80 00    	pushl  0x804000
  80132b:	e8 bf 07 00 00       	call   801aef <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801330:	83 c4 0c             	add    $0xc,%esp
  801333:	6a 00                	push   $0x0
  801335:	53                   	push   %ebx
  801336:	6a 00                	push   $0x0
  801338:	e8 3d 07 00 00       	call   801a7a <ipc_recv>
}
  80133d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
  80134d:	8b 40 0c             	mov    0xc(%eax),%eax
  801350:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801355:	8b 45 0c             	mov    0xc(%ebp),%eax
  801358:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135d:	ba 00 00 00 00       	mov    $0x0,%edx
  801362:	b8 02 00 00 00       	mov    $0x2,%eax
  801367:	e8 8d ff ff ff       	call   8012f9 <fsipc>
}
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801374:	8b 45 08             	mov    0x8(%ebp),%eax
  801377:	8b 40 0c             	mov    0xc(%eax),%eax
  80137a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
  801384:	b8 06 00 00 00       	mov    $0x6,%eax
  801389:	e8 6b ff ff ff       	call   8012f9 <fsipc>
}
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	53                   	push   %ebx
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139a:	8b 45 08             	mov    0x8(%ebp),%eax
  80139d:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8013af:	e8 45 ff ff ff       	call   8012f9 <fsipc>
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 2c                	js     8013e4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	68 00 50 80 00       	push   $0x805000
  8013c0:	53                   	push   %ebx
  8013c1:	e8 70 f3 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d1:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013fe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801403:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801408:	0f 47 c2             	cmova  %edx,%eax
  80140b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801410:	50                   	push   %eax
  801411:	ff 75 0c             	pushl  0xc(%ebp)
  801414:	68 08 50 80 00       	push   $0x805008
  801419:	e8 aa f4 ff ff       	call   8008c8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80141e:	ba 00 00 00 00       	mov    $0x0,%edx
  801423:	b8 04 00 00 00       	mov    $0x4,%eax
  801428:	e8 cc fe ff ff       	call   8012f9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801442:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801448:	ba 00 00 00 00       	mov    $0x0,%edx
  80144d:	b8 03 00 00 00       	mov    $0x3,%eax
  801452:	e8 a2 fe ff ff       	call   8012f9 <fsipc>
  801457:	89 c3                	mov    %eax,%ebx
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 4b                	js     8014a8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80145d:	39 c6                	cmp    %eax,%esi
  80145f:	73 16                	jae    801477 <devfile_read+0x48>
  801461:	68 78 22 80 00       	push   $0x802278
  801466:	68 7f 22 80 00       	push   $0x80227f
  80146b:	6a 7c                	push   $0x7c
  80146d:	68 94 22 80 00       	push   $0x802294
  801472:	e8 bd 05 00 00       	call   801a34 <_panic>
	assert(r <= PGSIZE);
  801477:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80147c:	7e 16                	jle    801494 <devfile_read+0x65>
  80147e:	68 9f 22 80 00       	push   $0x80229f
  801483:	68 7f 22 80 00       	push   $0x80227f
  801488:	6a 7d                	push   $0x7d
  80148a:	68 94 22 80 00       	push   $0x802294
  80148f:	e8 a0 05 00 00       	call   801a34 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	50                   	push   %eax
  801498:	68 00 50 80 00       	push   $0x805000
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	e8 23 f4 ff ff       	call   8008c8 <memmove>
	return r;
  8014a5:	83 c4 10             	add    $0x10,%esp
}
  8014a8:	89 d8                	mov    %ebx,%eax
  8014aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 20             	sub    $0x20,%esp
  8014b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014bb:	53                   	push   %ebx
  8014bc:	e8 3c f2 ff ff       	call   8006fd <strlen>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c9:	7f 67                	jg     801532 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cb:	83 ec 0c             	sub    $0xc,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	e8 9a f8 ff ff       	call   800d71 <fd_alloc>
  8014d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014da:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 57                	js     801537 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	53                   	push   %ebx
  8014e4:	68 00 50 80 00       	push   $0x805000
  8014e9:	e8 48 f2 ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fe:	e8 f6 fd ff ff       	call   8012f9 <fsipc>
  801503:	89 c3                	mov    %eax,%ebx
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	79 14                	jns    801520 <open+0x6f>
		fd_close(fd, 0);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	6a 00                	push   $0x0
  801511:	ff 75 f4             	pushl  -0xc(%ebp)
  801514:	e8 50 f9 ff ff       	call   800e69 <fd_close>
		return r;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	89 da                	mov    %ebx,%edx
  80151e:	eb 17                	jmp    801537 <open+0x86>
	}

	return fd2num(fd);
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	ff 75 f4             	pushl  -0xc(%ebp)
  801526:	e8 1f f8 ff ff       	call   800d4a <fd2num>
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	eb 05                	jmp    801537 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801532:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801537:	89 d0                	mov    %edx,%eax
  801539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
  801549:	b8 08 00 00 00       	mov    $0x8,%eax
  80154e:	e8 a6 fd ff ff       	call   8012f9 <fsipc>
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	ff 75 08             	pushl  0x8(%ebp)
  801563:	e8 f2 f7 ff ff       	call   800d5a <fd2data>
  801568:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	68 ab 22 80 00       	push   $0x8022ab
  801572:	53                   	push   %ebx
  801573:	e8 be f1 ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801578:	8b 46 04             	mov    0x4(%esi),%eax
  80157b:	2b 06                	sub    (%esi),%eax
  80157d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801583:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80158a:	00 00 00 
	stat->st_dev = &devpipe;
  80158d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801594:	30 80 00 
	return 0;
}
  801597:	b8 00 00 00 00       	mov    $0x0,%eax
  80159c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5e                   	pop    %esi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015ad:	53                   	push   %ebx
  8015ae:	6a 00                	push   $0x0
  8015b0:	e8 09 f6 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b5:	89 1c 24             	mov    %ebx,(%esp)
  8015b8:	e8 9d f7 ff ff       	call   800d5a <fd2data>
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	50                   	push   %eax
  8015c1:	6a 00                	push   $0x0
  8015c3:	e8 f6 f5 ff ff       	call   800bbe <sys_page_unmap>
}
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	57                   	push   %edi
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 1c             	sub    $0x1c,%esp
  8015d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015d9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015db:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e0:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e9:	e8 a3 05 00 00       	call   801b91 <pageref>
  8015ee:	89 c3                	mov    %eax,%ebx
  8015f0:	89 3c 24             	mov    %edi,(%esp)
  8015f3:	e8 99 05 00 00       	call   801b91 <pageref>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	39 c3                	cmp    %eax,%ebx
  8015fd:	0f 94 c1             	sete   %cl
  801600:	0f b6 c9             	movzbl %cl,%ecx
  801603:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801606:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80160c:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80160f:	39 ce                	cmp    %ecx,%esi
  801611:	74 1b                	je     80162e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801613:	39 c3                	cmp    %eax,%ebx
  801615:	75 c4                	jne    8015db <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801617:	8b 42 60             	mov    0x60(%edx),%eax
  80161a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161d:	50                   	push   %eax
  80161e:	56                   	push   %esi
  80161f:	68 b2 22 80 00       	push   $0x8022b2
  801624:	e8 88 eb ff ff       	call   8001b1 <cprintf>
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb ad                	jmp    8015db <_pipeisclosed+0xe>
	}
}
  80162e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5f                   	pop    %edi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 28             	sub    $0x28,%esp
  801642:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801645:	56                   	push   %esi
  801646:	e8 0f f7 ff ff       	call   800d5a <fd2data>
  80164b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	bf 00 00 00 00       	mov    $0x0,%edi
  801655:	eb 4b                	jmp    8016a2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801657:	89 da                	mov    %ebx,%edx
  801659:	89 f0                	mov    %esi,%eax
  80165b:	e8 6d ff ff ff       	call   8015cd <_pipeisclosed>
  801660:	85 c0                	test   %eax,%eax
  801662:	75 48                	jne    8016ac <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801664:	e8 b1 f4 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801669:	8b 43 04             	mov    0x4(%ebx),%eax
  80166c:	8b 0b                	mov    (%ebx),%ecx
  80166e:	8d 51 20             	lea    0x20(%ecx),%edx
  801671:	39 d0                	cmp    %edx,%eax
  801673:	73 e2                	jae    801657 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801675:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801678:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80167c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80167f:	89 c2                	mov    %eax,%edx
  801681:	c1 fa 1f             	sar    $0x1f,%edx
  801684:	89 d1                	mov    %edx,%ecx
  801686:	c1 e9 1b             	shr    $0x1b,%ecx
  801689:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80168c:	83 e2 1f             	and    $0x1f,%edx
  80168f:	29 ca                	sub    %ecx,%edx
  801691:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801695:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801699:	83 c0 01             	add    $0x1,%eax
  80169c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169f:	83 c7 01             	add    $0x1,%edi
  8016a2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a5:	75 c2                	jne    801669 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8016aa:	eb 05                	jmp    8016b1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5f                   	pop    %edi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 18             	sub    $0x18,%esp
  8016c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c5:	57                   	push   %edi
  8016c6:	e8 8f f6 ff ff       	call   800d5a <fd2data>
  8016cb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d5:	eb 3d                	jmp    801714 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016d7:	85 db                	test   %ebx,%ebx
  8016d9:	74 04                	je     8016df <devpipe_read+0x26>
				return i;
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	eb 44                	jmp    801723 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016df:	89 f2                	mov    %esi,%edx
  8016e1:	89 f8                	mov    %edi,%eax
  8016e3:	e8 e5 fe ff ff       	call   8015cd <_pipeisclosed>
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	75 32                	jne    80171e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016ec:	e8 29 f4 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f1:	8b 06                	mov    (%esi),%eax
  8016f3:	3b 46 04             	cmp    0x4(%esi),%eax
  8016f6:	74 df                	je     8016d7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f8:	99                   	cltd   
  8016f9:	c1 ea 1b             	shr    $0x1b,%edx
  8016fc:	01 d0                	add    %edx,%eax
  8016fe:	83 e0 1f             	and    $0x1f,%eax
  801701:	29 d0                	sub    %edx,%eax
  801703:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801708:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80170e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801711:	83 c3 01             	add    $0x1,%ebx
  801714:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801717:	75 d8                	jne    8016f1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801719:	8b 45 10             	mov    0x10(%ebp),%eax
  80171c:	eb 05                	jmp    801723 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5f                   	pop    %edi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	e8 35 f6 ff ff       	call   800d71 <fd_alloc>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	89 c2                	mov    %eax,%edx
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 2c 01 00 00    	js     801875 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	68 07 04 00 00       	push   $0x407
  801751:	ff 75 f4             	pushl  -0xc(%ebp)
  801754:	6a 00                	push   $0x0
  801756:	e8 de f3 ff ff       	call   800b39 <sys_page_alloc>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	89 c2                	mov    %eax,%edx
  801760:	85 c0                	test   %eax,%eax
  801762:	0f 88 0d 01 00 00    	js     801875 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801768:	83 ec 0c             	sub    $0xc,%esp
  80176b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	e8 fd f5 ff ff       	call   800d71 <fd_alloc>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	0f 88 e2 00 00 00    	js     801863 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	68 07 04 00 00       	push   $0x407
  801789:	ff 75 f0             	pushl  -0x10(%ebp)
  80178c:	6a 00                	push   $0x0
  80178e:	e8 a6 f3 ff ff       	call   800b39 <sys_page_alloc>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	0f 88 c3 00 00 00    	js     801863 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a6:	e8 af f5 ff ff       	call   800d5a <fd2data>
  8017ab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ad:	83 c4 0c             	add    $0xc,%esp
  8017b0:	68 07 04 00 00       	push   $0x407
  8017b5:	50                   	push   %eax
  8017b6:	6a 00                	push   $0x0
  8017b8:	e8 7c f3 ff ff       	call   800b39 <sys_page_alloc>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	0f 88 89 00 00 00    	js     801853 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d0:	e8 85 f5 ff ff       	call   800d5a <fd2data>
  8017d5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017dc:	50                   	push   %eax
  8017dd:	6a 00                	push   $0x0
  8017df:	56                   	push   %esi
  8017e0:	6a 00                	push   $0x0
  8017e2:	e8 95 f3 ff ff       	call   800b7c <sys_page_map>
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	83 c4 20             	add    $0x20,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 55                	js     801845 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801805:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	e8 25 f5 ff ff       	call   800d4a <fd2num>
  801825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801828:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80182a:	83 c4 04             	add    $0x4,%esp
  80182d:	ff 75 f0             	pushl  -0x10(%ebp)
  801830:	e8 15 f5 ff ff       	call   800d4a <fd2num>
  801835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801838:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	eb 30                	jmp    801875 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	56                   	push   %esi
  801849:	6a 00                	push   $0x0
  80184b:	e8 6e f3 ff ff       	call   800bbe <sys_page_unmap>
  801850:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	ff 75 f0             	pushl  -0x10(%ebp)
  801859:	6a 00                	push   $0x0
  80185b:	e8 5e f3 ff ff       	call   800bbe <sys_page_unmap>
  801860:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	ff 75 f4             	pushl  -0xc(%ebp)
  801869:	6a 00                	push   $0x0
  80186b:	e8 4e f3 ff ff       	call   800bbe <sys_page_unmap>
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801875:	89 d0                	mov    %edx,%eax
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801887:	50                   	push   %eax
  801888:	ff 75 08             	pushl  0x8(%ebp)
  80188b:	e8 30 f5 ff ff       	call   800dc0 <fd_lookup>
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	78 18                	js     8018af <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	ff 75 f4             	pushl  -0xc(%ebp)
  80189d:	e8 b8 f4 ff ff       	call   800d5a <fd2data>
	return _pipeisclosed(fd, p);
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a7:	e8 21 fd ff ff       	call   8015cd <_pipeisclosed>
  8018ac:	83 c4 10             	add    $0x10,%esp
}
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c1:	68 ca 22 80 00       	push   $0x8022ca
  8018c6:	ff 75 0c             	pushl  0xc(%ebp)
  8018c9:	e8 68 ee ff ff       	call   800736 <strcpy>
	return 0;
}
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	57                   	push   %edi
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ec:	eb 2d                	jmp    80191b <devcons_write+0x46>
		m = n - tot;
  8018ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018fb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018fe:	83 ec 04             	sub    $0x4,%esp
  801901:	53                   	push   %ebx
  801902:	03 45 0c             	add    0xc(%ebp),%eax
  801905:	50                   	push   %eax
  801906:	57                   	push   %edi
  801907:	e8 bc ef ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  80190c:	83 c4 08             	add    $0x8,%esp
  80190f:	53                   	push   %ebx
  801910:	57                   	push   %edi
  801911:	e8 67 f1 ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801916:	01 de                	add    %ebx,%esi
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	89 f0                	mov    %esi,%eax
  80191d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801920:	72 cc                	jb     8018ee <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801922:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5f                   	pop    %edi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801935:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801939:	74 2a                	je     801965 <devcons_read+0x3b>
  80193b:	eb 05                	jmp    801942 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80193d:	e8 d8 f1 ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801942:	e8 54 f1 ff ff       	call   800a9b <sys_cgetc>
  801947:	85 c0                	test   %eax,%eax
  801949:	74 f2                	je     80193d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 16                	js     801965 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80194f:	83 f8 04             	cmp    $0x4,%eax
  801952:	74 0c                	je     801960 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801954:	8b 55 0c             	mov    0xc(%ebp),%edx
  801957:	88 02                	mov    %al,(%edx)
	return 1;
  801959:	b8 01 00 00 00       	mov    $0x1,%eax
  80195e:	eb 05                	jmp    801965 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801973:	6a 01                	push   $0x1
  801975:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	e8 ff f0 ff ff       	call   800a7d <sys_cputs>
}
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <getchar>:

int
getchar(void)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801989:	6a 01                	push   $0x1
  80198b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	6a 00                	push   $0x0
  801991:	e8 90 f6 ff ff       	call   801026 <read>
	if (r < 0)
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 0f                	js     8019ac <getchar+0x29>
		return r;
	if (r < 1)
  80199d:	85 c0                	test   %eax,%eax
  80199f:	7e 06                	jle    8019a7 <getchar+0x24>
		return -E_EOF;
	return c;
  8019a1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a5:	eb 05                	jmp    8019ac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b7:	50                   	push   %eax
  8019b8:	ff 75 08             	pushl  0x8(%ebp)
  8019bb:	e8 00 f4 ff ff       	call   800dc0 <fd_lookup>
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 11                	js     8019d8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d0:	39 10                	cmp    %edx,(%eax)
  8019d2:	0f 94 c0             	sete   %al
  8019d5:	0f b6 c0             	movzbl %al,%eax
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <opencons>:

int
opencons(void)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	e8 88 f3 ff ff       	call   800d71 <fd_alloc>
  8019e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ec:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 3e                	js     801a30 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	68 07 04 00 00       	push   $0x407
  8019fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fd:	6a 00                	push   $0x0
  8019ff:	e8 35 f1 ff ff       	call   800b39 <sys_page_alloc>
  801a04:	83 c4 10             	add    $0x10,%esp
		return r;
  801a07:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	78 23                	js     801a30 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a16:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	50                   	push   %eax
  801a26:	e8 1f f3 ff ff       	call   800d4a <fd2num>
  801a2b:	89 c2                	mov    %eax,%edx
  801a2d:	83 c4 10             	add    $0x10,%esp
}
  801a30:	89 d0                	mov    %edx,%eax
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a39:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a3c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a42:	e8 b4 f0 ff ff       	call   800afb <sys_getenvid>
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	ff 75 0c             	pushl  0xc(%ebp)
  801a4d:	ff 75 08             	pushl  0x8(%ebp)
  801a50:	56                   	push   %esi
  801a51:	50                   	push   %eax
  801a52:	68 d8 22 80 00       	push   $0x8022d8
  801a57:	e8 55 e7 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a5c:	83 c4 18             	add    $0x18,%esp
  801a5f:	53                   	push   %ebx
  801a60:	ff 75 10             	pushl  0x10(%ebp)
  801a63:	e8 f8 e6 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801a68:	c7 04 24 c3 22 80 00 	movl   $0x8022c3,(%esp)
  801a6f:	e8 3d e7 ff ff       	call   8001b1 <cprintf>
  801a74:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a77:	cc                   	int3   
  801a78:	eb fd                	jmp    801a77 <_panic+0x43>

00801a7a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	75 12                	jne    801a9e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	68 00 00 c0 ee       	push   $0xeec00000
  801a94:	e8 50 f2 ff ff       	call   800ce9 <sys_ipc_recv>
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	eb 0c                	jmp    801aaa <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	50                   	push   %eax
  801aa2:	e8 42 f2 ff ff       	call   800ce9 <sys_ipc_recv>
  801aa7:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801aaa:	85 f6                	test   %esi,%esi
  801aac:	0f 95 c1             	setne  %cl
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	0f 95 c2             	setne  %dl
  801ab4:	84 d1                	test   %dl,%cl
  801ab6:	74 09                	je     801ac1 <ipc_recv+0x47>
  801ab8:	89 c2                	mov    %eax,%edx
  801aba:	c1 ea 1f             	shr    $0x1f,%edx
  801abd:	84 d2                	test   %dl,%dl
  801abf:	75 27                	jne    801ae8 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ac1:	85 f6                	test   %esi,%esi
  801ac3:	74 0a                	je     801acf <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ac5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aca:	8b 40 7c             	mov    0x7c(%eax),%eax
  801acd:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	74 0d                	je     801ae0 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ade:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ae0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae5:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ae8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	57                   	push   %edi
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b01:	85 db                	test   %ebx,%ebx
  801b03:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b08:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b0b:	ff 75 14             	pushl  0x14(%ebp)
  801b0e:	53                   	push   %ebx
  801b0f:	56                   	push   %esi
  801b10:	57                   	push   %edi
  801b11:	e8 b0 f1 ff ff       	call   800cc6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 ea 1f             	shr    $0x1f,%edx
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	84 d2                	test   %dl,%dl
  801b20:	74 17                	je     801b39 <ipc_send+0x4a>
  801b22:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b25:	74 12                	je     801b39 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b27:	50                   	push   %eax
  801b28:	68 fc 22 80 00       	push   $0x8022fc
  801b2d:	6a 47                	push   $0x47
  801b2f:	68 0a 23 80 00       	push   $0x80230a
  801b34:	e8 fb fe ff ff       	call   801a34 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b39:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b3c:	75 07                	jne    801b45 <ipc_send+0x56>
			sys_yield();
  801b3e:	e8 d7 ef ff ff       	call   800b1a <sys_yield>
  801b43:	eb c6                	jmp    801b0b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b45:	85 c0                	test   %eax,%eax
  801b47:	75 c2                	jne    801b0b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b57:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	c1 e2 07             	shl    $0x7,%edx
  801b61:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b68:	8b 52 58             	mov    0x58(%edx),%edx
  801b6b:	39 ca                	cmp    %ecx,%edx
  801b6d:	75 11                	jne    801b80 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b6f:	89 c2                	mov    %eax,%edx
  801b71:	c1 e2 07             	shl    $0x7,%edx
  801b74:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b7b:	8b 40 50             	mov    0x50(%eax),%eax
  801b7e:	eb 0f                	jmp    801b8f <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b80:	83 c0 01             	add    $0x1,%eax
  801b83:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b88:	75 d2                	jne    801b5c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b97:	89 d0                	mov    %edx,%eax
  801b99:	c1 e8 16             	shr    $0x16,%eax
  801b9c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba8:	f6 c1 01             	test   $0x1,%cl
  801bab:	74 1d                	je     801bca <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bad:	c1 ea 0c             	shr    $0xc,%edx
  801bb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bb7:	f6 c2 01             	test   $0x1,%dl
  801bba:	74 0e                	je     801bca <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bbc:	c1 ea 0c             	shr    $0xc,%edx
  801bbf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bc6:	ef 
  801bc7:	0f b7 c0             	movzwl %ax,%eax
}
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    
  801bcc:	66 90                	xchg   %ax,%ax
  801bce:	66 90                	xchg   %ax,%ax

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
