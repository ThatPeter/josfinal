
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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 54             	mov    0x54(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 e0 27 80 00       	push   $0x8027e0
  800047:	e8 8c 01 00 00       	call   8001d8 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 fe 27 80 00       	push   $0x8027fe
  800056:	68 fe 27 80 00       	push   $0x8027fe
  80005b:	e8 9d 1d 00 00       	call   801dfd <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 04 28 80 00       	push   $0x802804
  80006d:	6a 09                	push   $0x9
  80006f:	68 1c 28 80 00       	push   $0x80281c
  800074:	e8 86 00 00 00       	call   8000ff <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 97 0a 00 00       	call   800b22 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	89 c2                	mov    %eax,%edx
  800092:	c1 e2 07             	shl    $0x7,%edx
  800095:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80009c:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 db                	test   %ebx,%ebx
  8000a3:	7e 07                	jle    8000ac <libmain+0x31>
		binaryname = argv[0];
  8000a5:	8b 06                	mov    (%esi),%eax
  8000a7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	e8 7d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b6:	e8 2a 00 00 00       	call   8000e5 <exit>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000cb:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000d0:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000d2:	e8 4b 0a 00 00       	call   800b22 <sys_getenvid>
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	e8 91 0c 00 00       	call   800d71 <sys_thread_free>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000eb:	e8 5e 11 00 00       	call   80124e <close_all>
	sys_env_destroy(0);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 e7 09 00 00       	call   800ae1 <sys_env_destroy>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800104:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800107:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80010d:	e8 10 0a 00 00       	call   800b22 <sys_getenvid>
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	56                   	push   %esi
  80011c:	50                   	push   %eax
  80011d:	68 38 28 80 00       	push   $0x802838
  800122:	e8 b1 00 00 00       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800127:	83 c4 18             	add    $0x18,%esp
  80012a:	53                   	push   %ebx
  80012b:	ff 75 10             	pushl  0x10(%ebp)
  80012e:	e8 54 00 00 00       	call   800187 <vcprintf>
	cprintf("\n");
  800133:	c7 04 24 94 2d 80 00 	movl   $0x802d94,(%esp)
  80013a:	e8 99 00 00 00       	call   8001d8 <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800142:	cc                   	int3   
  800143:	eb fd                	jmp    800142 <_panic+0x43>

00800145 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	53                   	push   %ebx
  800149:	83 ec 04             	sub    $0x4,%esp
  80014c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014f:	8b 13                	mov    (%ebx),%edx
  800151:	8d 42 01             	lea    0x1(%edx),%eax
  800154:	89 03                	mov    %eax,(%ebx)
  800156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800159:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800162:	75 1a                	jne    80017e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	68 ff 00 00 00       	push   $0xff
  80016c:	8d 43 08             	lea    0x8(%ebx),%eax
  80016f:	50                   	push   %eax
  800170:	e8 2f 09 00 00       	call   800aa4 <sys_cputs>
		b->idx = 0;
  800175:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 45 01 80 00       	push   $0x800145
  8001b6:	e8 54 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 d4 08 00 00       	call   800aa4 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 c7                	mov    %eax,%edi
  8001f7:	89 d6                	mov    %edx,%esi
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800202:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800205:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800210:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800213:	39 d3                	cmp    %edx,%ebx
  800215:	72 05                	jb     80021c <printnum+0x30>
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 45                	ja     800261 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	8b 45 14             	mov    0x14(%ebp),%eax
  800225:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800228:	53                   	push   %ebx
  800229:	ff 75 10             	pushl  0x10(%ebp)
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 00 23 00 00       	call   802540 <__udivdi3>
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	52                   	push   %edx
  800244:	50                   	push   %eax
  800245:	89 f2                	mov    %esi,%edx
  800247:	89 f8                	mov    %edi,%eax
  800249:	e8 9e ff ff ff       	call   8001ec <printnum>
  80024e:	83 c4 20             	add    $0x20,%esp
  800251:	eb 18                	jmp    80026b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	ff d7                	call   *%edi
  80025c:	83 c4 10             	add    $0x10,%esp
  80025f:	eb 03                	jmp    800264 <printnum+0x78>
  800261:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	85 db                	test   %ebx,%ebx
  800269:	7f e8                	jg     800253 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	56                   	push   %esi
  80026f:	83 ec 04             	sub    $0x4,%esp
  800272:	ff 75 e4             	pushl  -0x1c(%ebp)
  800275:	ff 75 e0             	pushl  -0x20(%ebp)
  800278:	ff 75 dc             	pushl  -0x24(%ebp)
  80027b:	ff 75 d8             	pushl  -0x28(%ebp)
  80027e:	e8 ed 23 00 00       	call   802670 <__umoddi3>
  800283:	83 c4 14             	add    $0x14,%esp
  800286:	0f be 80 5b 28 80 00 	movsbl 0x80285b(%eax),%eax
  80028d:	50                   	push   %eax
  80028e:	ff d7                	call   *%edi
}
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029e:	83 fa 01             	cmp    $0x1,%edx
  8002a1:	7e 0e                	jle    8002b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	8b 52 04             	mov    0x4(%edx),%edx
  8002af:	eb 22                	jmp    8002d3 <getuint+0x38>
	else if (lflag)
  8002b1:	85 d2                	test   %edx,%edx
  8002b3:	74 10                	je     8002c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b5:	8b 10                	mov    (%eax),%edx
  8002b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 02                	mov    (%edx),%eax
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	eb 0e                	jmp    8002d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 02                	mov    (%edx),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e4:	73 0a                	jae    8002f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	88 02                	mov    %al,(%edx)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	50                   	push   %eax
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	ff 75 0c             	pushl  0xc(%ebp)
  800302:	ff 75 08             	pushl  0x8(%ebp)
  800305:	e8 05 00 00 00       	call   80030f <vprintfmt>
	va_end(ap);
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 2c             	sub    $0x2c,%esp
  800318:	8b 75 08             	mov    0x8(%ebp),%esi
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800321:	eb 12                	jmp    800335 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800323:	85 c0                	test   %eax,%eax
  800325:	0f 84 89 03 00 00    	je     8006b4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	53                   	push   %ebx
  80032f:	50                   	push   %eax
  800330:	ff d6                	call   *%esi
  800332:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800335:	83 c7 01             	add    $0x1,%edi
  800338:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033c:	83 f8 25             	cmp    $0x25,%eax
  80033f:	75 e2                	jne    800323 <vprintfmt+0x14>
  800341:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800345:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800353:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	eb 07                	jmp    800368 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800364:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8d 47 01             	lea    0x1(%edi),%eax
  80036b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036e:	0f b6 07             	movzbl (%edi),%eax
  800371:	0f b6 c8             	movzbl %al,%ecx
  800374:	83 e8 23             	sub    $0x23,%eax
  800377:	3c 55                	cmp    $0x55,%al
  800379:	0f 87 1a 03 00 00    	ja     800699 <vprintfmt+0x38a>
  80037f:	0f b6 c0             	movzbl %al,%eax
  800382:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800390:	eb d6                	jmp    800368 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
  80039a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003aa:	83 fa 09             	cmp    $0x9,%edx
  8003ad:	77 39                	ja     8003e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b2:	eb e9                	jmp    80039d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c5:	eb 27                	jmp    8003ee <vprintfmt+0xdf>
  8003c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d1:	0f 49 c8             	cmovns %eax,%ecx
  8003d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003da:	eb 8c                	jmp    800368 <vprintfmt+0x59>
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e6:	eb 80                	jmp    800368 <vprintfmt+0x59>
  8003e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f2:	0f 89 70 ff ff ff    	jns    800368 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800405:	e9 5e ff ff ff       	jmp    800368 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800410:	e9 53 ff ff ff       	jmp    800368 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8d 50 04             	lea    0x4(%eax),%edx
  80041b:	89 55 14             	mov    %edx,0x14(%ebp)
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	53                   	push   %ebx
  800422:	ff 30                	pushl  (%eax)
  800424:	ff d6                	call   *%esi
			break;
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042c:	e9 04 ff ff ff       	jmp    800335 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	99                   	cltd   
  80043d:	31 d0                	xor    %edx,%eax
  80043f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800441:	83 f8 0f             	cmp    $0xf,%eax
  800444:	7f 0b                	jg     800451 <vprintfmt+0x142>
  800446:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  80044d:	85 d2                	test   %edx,%edx
  80044f:	75 18                	jne    800469 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800451:	50                   	push   %eax
  800452:	68 73 28 80 00       	push   $0x802873
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 94 fe ff ff       	call   8002f2 <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800464:	e9 cc fe ff ff       	jmp    800335 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800469:	52                   	push   %edx
  80046a:	68 ad 2c 80 00       	push   $0x802cad
  80046f:	53                   	push   %ebx
  800470:	56                   	push   %esi
  800471:	e8 7c fe ff ff       	call   8002f2 <printfmt>
  800476:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047c:	e9 b4 fe ff ff       	jmp    800335 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048c:	85 ff                	test   %edi,%edi
  80048e:	b8 6c 28 80 00       	mov    $0x80286c,%eax
  800493:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800496:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049a:	0f 8e 94 00 00 00    	jle    800534 <vprintfmt+0x225>
  8004a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a4:	0f 84 98 00 00 00    	je     800542 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b0:	57                   	push   %edi
  8004b1:	e8 86 02 00 00       	call   80073c <strnlen>
  8004b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b9:	29 c1                	sub    %eax,%ecx
  8004bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	eb 0f                	jmp    8004de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	53                   	push   %ebx
  8004d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	83 ef 01             	sub    $0x1,%edi
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	85 ff                	test   %edi,%edi
  8004e0:	7f ed                	jg     8004cf <vprintfmt+0x1c0>
  8004e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e8:	85 c9                	test   %ecx,%ecx
  8004ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ef:	0f 49 c1             	cmovns %ecx,%eax
  8004f2:	29 c1                	sub    %eax,%ecx
  8004f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fd:	89 cb                	mov    %ecx,%ebx
  8004ff:	eb 4d                	jmp    80054e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800501:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800505:	74 1b                	je     800522 <vprintfmt+0x213>
  800507:	0f be c0             	movsbl %al,%eax
  80050a:	83 e8 20             	sub    $0x20,%eax
  80050d:	83 f8 5e             	cmp    $0x5e,%eax
  800510:	76 10                	jbe    800522 <vprintfmt+0x213>
					putch('?', putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	ff 75 0c             	pushl  0xc(%ebp)
  800518:	6a 3f                	push   $0x3f
  80051a:	ff 55 08             	call   *0x8(%ebp)
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	eb 0d                	jmp    80052f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	ff 75 0c             	pushl  0xc(%ebp)
  800528:	52                   	push   %edx
  800529:	ff 55 08             	call   *0x8(%ebp)
  80052c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052f:	83 eb 01             	sub    $0x1,%ebx
  800532:	eb 1a                	jmp    80054e <vprintfmt+0x23f>
  800534:	89 75 08             	mov    %esi,0x8(%ebp)
  800537:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800540:	eb 0c                	jmp    80054e <vprintfmt+0x23f>
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054e:	83 c7 01             	add    $0x1,%edi
  800551:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800555:	0f be d0             	movsbl %al,%edx
  800558:	85 d2                	test   %edx,%edx
  80055a:	74 23                	je     80057f <vprintfmt+0x270>
  80055c:	85 f6                	test   %esi,%esi
  80055e:	78 a1                	js     800501 <vprintfmt+0x1f2>
  800560:	83 ee 01             	sub    $0x1,%esi
  800563:	79 9c                	jns    800501 <vprintfmt+0x1f2>
  800565:	89 df                	mov    %ebx,%edi
  800567:	8b 75 08             	mov    0x8(%ebp),%esi
  80056a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056d:	eb 18                	jmp    800587 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	53                   	push   %ebx
  800573:	6a 20                	push   $0x20
  800575:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800577:	83 ef 01             	sub    $0x1,%edi
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	eb 08                	jmp    800587 <vprintfmt+0x278>
  80057f:	89 df                	mov    %ebx,%edi
  800581:	8b 75 08             	mov    0x8(%ebp),%esi
  800584:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800587:	85 ff                	test   %edi,%edi
  800589:	7f e4                	jg     80056f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058e:	e9 a2 fd ff ff       	jmp    800335 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 fa 01             	cmp    $0x1,%edx
  800596:	7e 16                	jle    8005ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 50 08             	lea    0x8(%eax),%edx
  80059e:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a1:	8b 50 04             	mov    0x4(%eax),%edx
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ac:	eb 32                	jmp    8005e0 <vprintfmt+0x2d1>
	else if (lflag)
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	74 18                	je     8005ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	eb 16                	jmp    8005e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ef:	79 74                	jns    800665 <vprintfmt+0x356>
				putch('-', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 2d                	push   $0x2d
  8005f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ff:	f7 d8                	neg    %eax
  800601:	83 d2 00             	adc    $0x0,%edx
  800604:	f7 da                	neg    %edx
  800606:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800609:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060e:	eb 55                	jmp    800665 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 83 fc ff ff       	call   80029b <getuint>
			base = 10;
  800618:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061d:	eb 46                	jmp    800665 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 74 fc ff ff       	call   80029b <getuint>
			base = 8;
  800627:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062c:	eb 37                	jmp    800665 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 30                	push   $0x30
  800634:	ff d6                	call   *%esi
			putch('x', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 78                	push   $0x78
  80063c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800651:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800656:	eb 0d                	jmp    800665 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
  80065b:	e8 3b fc ff ff       	call   80029b <getuint>
			base = 16;
  800660:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800665:	83 ec 0c             	sub    $0xc,%esp
  800668:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066c:	57                   	push   %edi
  80066d:	ff 75 e0             	pushl  -0x20(%ebp)
  800670:	51                   	push   %ecx
  800671:	52                   	push   %edx
  800672:	50                   	push   %eax
  800673:	89 da                	mov    %ebx,%edx
  800675:	89 f0                	mov    %esi,%eax
  800677:	e8 70 fb ff ff       	call   8001ec <printnum>
			break;
  80067c:	83 c4 20             	add    $0x20,%esp
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800682:	e9 ae fc ff ff       	jmp    800335 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	51                   	push   %ecx
  80068c:	ff d6                	call   *%esi
			break;
  80068e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800694:	e9 9c fc ff ff       	jmp    800335 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 25                	push   $0x25
  80069f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	eb 03                	jmp    8006a9 <vprintfmt+0x39a>
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ad:	75 f7                	jne    8006a6 <vprintfmt+0x397>
  8006af:	e9 81 fc ff ff       	jmp    800335 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b7:	5b                   	pop    %ebx
  8006b8:	5e                   	pop    %esi
  8006b9:	5f                   	pop    %edi
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 18             	sub    $0x18,%esp
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 26                	je     800703 <vsnprintf+0x47>
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	7e 22                	jle    800703 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e1:	ff 75 14             	pushl  0x14(%ebp)
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	68 d5 02 80 00       	push   $0x8002d5
  8006f0:	e8 1a fc ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 05                	jmp    800708 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800713:	50                   	push   %eax
  800714:	ff 75 10             	pushl  0x10(%ebp)
  800717:	ff 75 0c             	pushl  0xc(%ebp)
  80071a:	ff 75 08             	pushl  0x8(%ebp)
  80071d:	e8 9a ff ff ff       	call   8006bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	eb 03                	jmp    800734 <strlen+0x10>
		n++;
  800731:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800734:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800738:	75 f7                	jne    800731 <strlen+0xd>
		n++;
	return n;
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	eb 03                	jmp    80074f <strnlen+0x13>
		n++;
  80074c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	39 c2                	cmp    %eax,%edx
  800751:	74 08                	je     80075b <strnlen+0x1f>
  800753:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800757:	75 f3                	jne    80074c <strnlen+0x10>
  800759:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800767:	89 c2                	mov    %eax,%edx
  800769:	83 c2 01             	add    $0x1,%edx
  80076c:	83 c1 01             	add    $0x1,%ecx
  80076f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800773:	88 5a ff             	mov    %bl,-0x1(%edx)
  800776:	84 db                	test   %bl,%bl
  800778:	75 ef                	jne    800769 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077a:	5b                   	pop    %ebx
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800784:	53                   	push   %ebx
  800785:	e8 9a ff ff ff       	call   800724 <strlen>
  80078a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	01 d8                	add    %ebx,%eax
  800792:	50                   	push   %eax
  800793:	e8 c5 ff ff ff       	call   80075d <strcpy>
	return dst;
}
  800798:	89 d8                	mov    %ebx,%eax
  80079a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007aa:	89 f3                	mov    %esi,%ebx
  8007ac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007af:	89 f2                	mov    %esi,%edx
  8007b1:	eb 0f                	jmp    8007c2 <strncpy+0x23>
		*dst++ = *src;
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	0f b6 01             	movzbl (%ecx),%eax
  8007b9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c2:	39 da                	cmp    %ebx,%edx
  8007c4:	75 ed                	jne    8007b3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007da:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 21                	je     800801 <strlcpy+0x35>
  8007e0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	eb 09                	jmp    8007f1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f1:	39 c2                	cmp    %eax,%edx
  8007f3:	74 09                	je     8007fe <strlcpy+0x32>
  8007f5:	0f b6 19             	movzbl (%ecx),%ebx
  8007f8:	84 db                	test   %bl,%bl
  8007fa:	75 ec                	jne    8007e8 <strlcpy+0x1c>
  8007fc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800801:	29 f0                	sub    %esi,%eax
}
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800810:	eb 06                	jmp    800818 <strcmp+0x11>
		p++, q++;
  800812:	83 c1 01             	add    $0x1,%ecx
  800815:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800818:	0f b6 01             	movzbl (%ecx),%eax
  80081b:	84 c0                	test   %al,%al
  80081d:	74 04                	je     800823 <strcmp+0x1c>
  80081f:	3a 02                	cmp    (%edx),%al
  800821:	74 ef                	je     800812 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 c0             	movzbl %al,%eax
  800826:	0f b6 12             	movzbl (%edx),%edx
  800829:	29 d0                	sub    %edx,%eax
}
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	53                   	push   %ebx
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	89 c3                	mov    %eax,%ebx
  800839:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083c:	eb 06                	jmp    800844 <strncmp+0x17>
		n--, p++, q++;
  80083e:	83 c0 01             	add    $0x1,%eax
  800841:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800844:	39 d8                	cmp    %ebx,%eax
  800846:	74 15                	je     80085d <strncmp+0x30>
  800848:	0f b6 08             	movzbl (%eax),%ecx
  80084b:	84 c9                	test   %cl,%cl
  80084d:	74 04                	je     800853 <strncmp+0x26>
  80084f:	3a 0a                	cmp    (%edx),%cl
  800851:	74 eb                	je     80083e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 00             	movzbl (%eax),%eax
  800856:	0f b6 12             	movzbl (%edx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb 05                	jmp    800862 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086f:	eb 07                	jmp    800878 <strchr+0x13>
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 0f                	je     800884 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	0f b6 10             	movzbl (%eax),%edx
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f2                	jne    800871 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800890:	eb 03                	jmp    800895 <strfind+0xf>
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	74 04                	je     8008a0 <strfind+0x1a>
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f2                	jne    800892 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ae:	85 c9                	test   %ecx,%ecx
  8008b0:	74 36                	je     8008e8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b8:	75 28                	jne    8008e2 <memset+0x40>
  8008ba:	f6 c1 03             	test   $0x3,%cl
  8008bd:	75 23                	jne    8008e2 <memset+0x40>
		c &= 0xFF;
  8008bf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c3:	89 d3                	mov    %edx,%ebx
  8008c5:	c1 e3 08             	shl    $0x8,%ebx
  8008c8:	89 d6                	mov    %edx,%esi
  8008ca:	c1 e6 18             	shl    $0x18,%esi
  8008cd:	89 d0                	mov    %edx,%eax
  8008cf:	c1 e0 10             	shl    $0x10,%eax
  8008d2:	09 f0                	or     %esi,%eax
  8008d4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d6:	89 d8                	mov    %ebx,%eax
  8008d8:	09 d0                	or     %edx,%eax
  8008da:	c1 e9 02             	shr    $0x2,%ecx
  8008dd:	fc                   	cld    
  8008de:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e0:	eb 06                	jmp    8008e8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	fc                   	cld    
  8008e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	57                   	push   %edi
  8008f3:	56                   	push   %esi
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fd:	39 c6                	cmp    %eax,%esi
  8008ff:	73 35                	jae    800936 <memmove+0x47>
  800901:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800904:	39 d0                	cmp    %edx,%eax
  800906:	73 2e                	jae    800936 <memmove+0x47>
		s += n;
		d += n;
  800908:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090b:	89 d6                	mov    %edx,%esi
  80090d:	09 fe                	or     %edi,%esi
  80090f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800915:	75 13                	jne    80092a <memmove+0x3b>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 0e                	jne    80092a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091c:	83 ef 04             	sub    $0x4,%edi
  80091f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800922:	c1 e9 02             	shr    $0x2,%ecx
  800925:	fd                   	std    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 09                	jmp    800933 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092a:	83 ef 01             	sub    $0x1,%edi
  80092d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800930:	fd                   	std    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800933:	fc                   	cld    
  800934:	eb 1d                	jmp    800953 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 f2                	mov    %esi,%edx
  800938:	09 c2                	or     %eax,%edx
  80093a:	f6 c2 03             	test   $0x3,%dl
  80093d:	75 0f                	jne    80094e <memmove+0x5f>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0a                	jne    80094e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800944:	c1 e9 02             	shr    $0x2,%ecx
  800947:	89 c7                	mov    %eax,%edi
  800949:	fc                   	cld    
  80094a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094c:	eb 05                	jmp    800953 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094e:	89 c7                	mov    %eax,%edi
  800950:	fc                   	cld    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095a:	ff 75 10             	pushl  0x10(%ebp)
  80095d:	ff 75 0c             	pushl  0xc(%ebp)
  800960:	ff 75 08             	pushl  0x8(%ebp)
  800963:	e8 87 ff ff ff       	call   8008ef <memmove>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 c6                	mov    %eax,%esi
  800977:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097a:	eb 1a                	jmp    800996 <memcmp+0x2c>
		if (*s1 != *s2)
  80097c:	0f b6 08             	movzbl (%eax),%ecx
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	38 d9                	cmp    %bl,%cl
  800984:	74 0a                	je     800990 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800986:	0f b6 c1             	movzbl %cl,%eax
  800989:	0f b6 db             	movzbl %bl,%ebx
  80098c:	29 d8                	sub    %ebx,%eax
  80098e:	eb 0f                	jmp    80099f <memcmp+0x35>
		s1++, s2++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	39 f0                	cmp    %esi,%eax
  800998:	75 e2                	jne    80097c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	53                   	push   %ebx
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009aa:	89 c1                	mov    %eax,%ecx
  8009ac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009af:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b3:	eb 0a                	jmp    8009bf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	39 da                	cmp    %ebx,%edx
  8009ba:	74 07                	je     8009c3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	39 c8                	cmp    %ecx,%eax
  8009c1:	72 f2                	jb     8009b5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d2:	eb 03                	jmp    8009d7 <strtol+0x11>
		s++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d7:	0f b6 01             	movzbl (%ecx),%eax
  8009da:	3c 20                	cmp    $0x20,%al
  8009dc:	74 f6                	je     8009d4 <strtol+0xe>
  8009de:	3c 09                	cmp    $0x9,%al
  8009e0:	74 f2                	je     8009d4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e2:	3c 2b                	cmp    $0x2b,%al
  8009e4:	75 0a                	jne    8009f0 <strtol+0x2a>
		s++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ee:	eb 11                	jmp    800a01 <strtol+0x3b>
  8009f0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f5:	3c 2d                	cmp    $0x2d,%al
  8009f7:	75 08                	jne    800a01 <strtol+0x3b>
		s++, neg = 1;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a07:	75 15                	jne    800a1e <strtol+0x58>
  800a09:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0c:	75 10                	jne    800a1e <strtol+0x58>
  800a0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a12:	75 7c                	jne    800a90 <strtol+0xca>
		s += 2, base = 16;
  800a14:	83 c1 02             	add    $0x2,%ecx
  800a17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1c:	eb 16                	jmp    800a34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1e:	85 db                	test   %ebx,%ebx
  800a20:	75 12                	jne    800a34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a27:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2a:	75 08                	jne    800a34 <strtol+0x6e>
		s++, base = 8;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3c:	0f b6 11             	movzbl (%ecx),%edx
  800a3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 09             	cmp    $0x9,%bl
  800a47:	77 08                	ja     800a51 <strtol+0x8b>
			dig = *s - '0';
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 30             	sub    $0x30,%edx
  800a4f:	eb 22                	jmp    800a73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 08                	ja     800a63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 57             	sub    $0x57,%edx
  800a61:	eb 10                	jmp    800a73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 16                	ja     800a83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a76:	7d 0b                	jge    800a83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a81:	eb b9                	jmp    800a3c <strtol+0x76>

	if (endptr)
  800a83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a87:	74 0d                	je     800a96 <strtol+0xd0>
		*endptr = (char *) s;
  800a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8c:	89 0e                	mov    %ecx,(%esi)
  800a8e:	eb 06                	jmp    800a96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	74 98                	je     800a2c <strtol+0x66>
  800a94:	eb 9e                	jmp    800a34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a96:	89 c2                	mov    %eax,%edx
  800a98:	f7 da                	neg    %edx
  800a9a:	85 ff                	test   %edi,%edi
  800a9c:	0f 45 c2             	cmovne %edx,%eax
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  800acd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad2:	89 d1                	mov    %edx,%ecx
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aef:	b8 03 00 00 00       	mov    $0x3,%eax
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 cb                	mov    %ecx,%ebx
  800af9:	89 cf                	mov    %ecx,%edi
  800afb:	89 ce                	mov    %ecx,%esi
  800afd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	7e 17                	jle    800b1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	50                   	push   %eax
  800b07:	6a 03                	push   $0x3
  800b09:	68 5f 2b 80 00       	push   $0x802b5f
  800b0e:	6a 23                	push   $0x23
  800b10:	68 7c 2b 80 00       	push   $0x802b7c
  800b15:	e8 e5 f5 ff ff       	call   8000ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_yield>:

void
sys_yield(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	be 00 00 00 00       	mov    $0x0,%esi
  800b6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7c:	89 f7                	mov    %esi,%edi
  800b7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7e 17                	jle    800b9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	50                   	push   %eax
  800b88:	6a 04                	push   $0x4
  800b8a:	68 5f 2b 80 00       	push   $0x802b5f
  800b8f:	6a 23                	push   $0x23
  800b91:	68 7c 2b 80 00       	push   $0x802b7c
  800b96:	e8 64 f5 ff ff       	call   8000ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbd:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7e 17                	jle    800bdd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 05                	push   $0x5
  800bcc:	68 5f 2b 80 00       	push   $0x802b5f
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 7c 2b 80 00       	push   $0x802b7c
  800bd8:	e8 22 f5 ff ff       	call   8000ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	89 df                	mov    %ebx,%edi
  800c00:	89 de                	mov    %ebx,%esi
  800c02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	7e 17                	jle    800c1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	50                   	push   %eax
  800c0c:	6a 06                	push   $0x6
  800c0e:	68 5f 2b 80 00       	push   $0x802b5f
  800c13:	6a 23                	push   $0x23
  800c15:	68 7c 2b 80 00       	push   $0x802b7c
  800c1a:	e8 e0 f4 ff ff       	call   8000ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	89 df                	mov    %ebx,%edi
  800c42:	89 de                	mov    %ebx,%esi
  800c44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 17                	jle    800c61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 08                	push   $0x8
  800c50:	68 5f 2b 80 00       	push   $0x802b5f
  800c55:	6a 23                	push   $0x23
  800c57:	68 7c 2b 80 00       	push   $0x802b7c
  800c5c:	e8 9e f4 ff ff       	call   8000ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c77:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	89 df                	mov    %ebx,%edi
  800c84:	89 de                	mov    %ebx,%esi
  800c86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 17                	jle    800ca3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 09                	push   $0x9
  800c92:	68 5f 2b 80 00       	push   $0x802b5f
  800c97:	6a 23                	push   $0x23
  800c99:	68 7c 2b 80 00       	push   $0x802b7c
  800c9e:	e8 5c f4 ff ff       	call   8000ff <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 df                	mov    %ebx,%edi
  800cc6:	89 de                	mov    %ebx,%esi
  800cc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7e 17                	jle    800ce5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 0a                	push   $0xa
  800cd4:	68 5f 2b 80 00       	push   $0x802b5f
  800cd9:	6a 23                	push   $0x23
  800cdb:	68 7c 2b 80 00       	push   $0x802b7c
  800ce0:	e8 1a f4 ff ff       	call   8000ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	be 00 00 00 00       	mov    $0x0,%esi
  800cf8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d09:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 cb                	mov    %ecx,%ebx
  800d28:	89 cf                	mov    %ecx,%edi
  800d2a:	89 ce                	mov    %ecx,%esi
  800d2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 17                	jle    800d49 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 0d                	push   $0xd
  800d38:	68 5f 2b 80 00       	push   $0x802b5f
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 7c 2b 80 00       	push   $0x802b7c
  800d44:	e8 b6 f3 ff ff       	call   8000ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 cb                	mov    %ecx,%ebx
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	89 ce                	mov    %ecx,%esi
  800d6a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	53                   	push   %ebx
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d9b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d9d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800da1:	74 11                	je     800db4 <pgfault+0x23>
  800da3:	89 d8                	mov    %ebx,%eax
  800da5:	c1 e8 0c             	shr    $0xc,%eax
  800da8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800daf:	f6 c4 08             	test   $0x8,%ah
  800db2:	75 14                	jne    800dc8 <pgfault+0x37>
		panic("faulting access");
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	68 8a 2b 80 00       	push   $0x802b8a
  800dbc:	6a 1e                	push   $0x1e
  800dbe:	68 9a 2b 80 00       	push   $0x802b9a
  800dc3:	e8 37 f3 ff ff       	call   8000ff <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	6a 07                	push   $0x7
  800dcd:	68 00 f0 7f 00       	push   $0x7ff000
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 87 fd ff ff       	call   800b60 <sys_page_alloc>
	if (r < 0) {
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	79 12                	jns    800df2 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800de0:	50                   	push   %eax
  800de1:	68 a5 2b 80 00       	push   $0x802ba5
  800de6:	6a 2c                	push   $0x2c
  800de8:	68 9a 2b 80 00       	push   $0x802b9a
  800ded:	e8 0d f3 ff ff       	call   8000ff <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800df2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	68 00 10 00 00       	push   $0x1000
  800e00:	53                   	push   %ebx
  800e01:	68 00 f0 7f 00       	push   $0x7ff000
  800e06:	e8 4c fb ff ff       	call   800957 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e0b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e12:	53                   	push   %ebx
  800e13:	6a 00                	push   $0x0
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 82 fd ff ff       	call   800ba3 <sys_page_map>
	if (r < 0) {
  800e21:	83 c4 20             	add    $0x20,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	79 12                	jns    800e3a <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e28:	50                   	push   %eax
  800e29:	68 a5 2b 80 00       	push   $0x802ba5
  800e2e:	6a 33                	push   $0x33
  800e30:	68 9a 2b 80 00       	push   $0x802b9a
  800e35:	e8 c5 f2 ff ff       	call   8000ff <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e3a:	83 ec 08             	sub    $0x8,%esp
  800e3d:	68 00 f0 7f 00       	push   $0x7ff000
  800e42:	6a 00                	push   $0x0
  800e44:	e8 9c fd ff ff       	call   800be5 <sys_page_unmap>
	if (r < 0) {
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	79 12                	jns    800e62 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e50:	50                   	push   %eax
  800e51:	68 a5 2b 80 00       	push   $0x802ba5
  800e56:	6a 37                	push   $0x37
  800e58:	68 9a 2b 80 00       	push   $0x802b9a
  800e5d:	e8 9d f2 ff ff       	call   8000ff <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e70:	68 91 0d 80 00       	push   $0x800d91
  800e75:	e8 d5 14 00 00       	call   80234f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e7a:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7f:	cd 30                	int    $0x30
  800e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 17                	jns    800ea2 <fork+0x3b>
		panic("fork fault %e");
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 be 2b 80 00       	push   $0x802bbe
  800e93:	68 84 00 00 00       	push   $0x84
  800e98:	68 9a 2b 80 00       	push   $0x802b9a
  800e9d:	e8 5d f2 ff ff       	call   8000ff <_panic>
  800ea2:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea8:	75 25                	jne    800ecf <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eaa:	e8 73 fc ff ff       	call   800b22 <sys_getenvid>
  800eaf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	c1 e2 07             	shl    $0x7,%edx
  800eb9:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800ec0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	e9 61 01 00 00       	jmp    801030 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	6a 07                	push   $0x7
  800ed4:	68 00 f0 bf ee       	push   $0xeebff000
  800ed9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800edc:	e8 7f fc ff ff       	call   800b60 <sys_page_alloc>
  800ee1:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ee4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee9:	89 d8                	mov    %ebx,%eax
  800eeb:	c1 e8 16             	shr    $0x16,%eax
  800eee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef5:	a8 01                	test   $0x1,%al
  800ef7:	0f 84 fc 00 00 00    	je     800ff9 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	c1 e8 0c             	shr    $0xc,%eax
  800f02:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	0f 84 e7 00 00 00    	je     800ff9 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f17:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1e:	f6 c6 04             	test   $0x4,%dh
  800f21:	74 39                	je     800f5c <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f32:	50                   	push   %eax
  800f33:	56                   	push   %esi
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	6a 00                	push   $0x0
  800f38:	e8 66 fc ff ff       	call   800ba3 <sys_page_map>
		if (r < 0) {
  800f3d:	83 c4 20             	add    $0x20,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	0f 89 b1 00 00 00    	jns    800ff9 <fork+0x192>
		    	panic("sys page map fault %e");
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	68 cc 2b 80 00       	push   $0x802bcc
  800f50:	6a 54                	push   $0x54
  800f52:	68 9a 2b 80 00       	push   $0x802b9a
  800f57:	e8 a3 f1 ff ff       	call   8000ff <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f63:	f6 c2 02             	test   $0x2,%dl
  800f66:	75 0c                	jne    800f74 <fork+0x10d>
  800f68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6f:	f6 c4 08             	test   $0x8,%ah
  800f72:	74 5b                	je     800fcf <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	68 05 08 00 00       	push   $0x805
  800f7c:	56                   	push   %esi
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 1d fc ff ff       	call   800ba3 <sys_page_map>
		if (r < 0) {
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 14                	jns    800fa1 <fork+0x13a>
		    	panic("sys page map fault %e");
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	68 cc 2b 80 00       	push   $0x802bcc
  800f95:	6a 5b                	push   $0x5b
  800f97:	68 9a 2b 80 00       	push   $0x802b9a
  800f9c:	e8 5e f1 ff ff       	call   8000ff <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	68 05 08 00 00       	push   $0x805
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 ef fb ff ff       	call   800ba3 <sys_page_map>
		if (r < 0) {
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 3e                	jns    800ff9 <fork+0x192>
		    	panic("sys page map fault %e");
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	68 cc 2b 80 00       	push   $0x802bcc
  800fc3:	6a 5f                	push   $0x5f
  800fc5:	68 9a 2b 80 00       	push   $0x802b9a
  800fca:	e8 30 f1 ff ff       	call   8000ff <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	6a 05                	push   $0x5
  800fd4:	56                   	push   %esi
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 c5 fb ff ff       	call   800ba3 <sys_page_map>
		if (r < 0) {
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 14                	jns    800ff9 <fork+0x192>
		    	panic("sys page map fault %e");
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	68 cc 2b 80 00       	push   $0x802bcc
  800fed:	6a 64                	push   $0x64
  800fef:	68 9a 2b 80 00       	push   $0x802b9a
  800ff4:	e8 06 f1 ff ff       	call   8000ff <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fff:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801005:	0f 85 de fe ff ff    	jne    800ee9 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80100b:	a1 04 40 80 00       	mov    0x804004,%eax
  801010:	8b 40 70             	mov    0x70(%eax),%eax
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	50                   	push   %eax
  801017:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80101a:	57                   	push   %edi
  80101b:	e8 8b fc ff ff       	call   800cab <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	6a 02                	push   $0x2
  801025:	57                   	push   %edi
  801026:	e8 fc fb ff ff       	call   800c27 <sys_env_set_status>
	
	return envid;
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sfork>:

envid_t
sfork(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80103b:	b8 00 00 00 00       	mov    $0x0,%eax
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80104a:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	53                   	push   %ebx
  801054:	68 e4 2b 80 00       	push   $0x802be4
  801059:	e8 7a f1 ff ff       	call   8001d8 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80105e:	c7 04 24 c5 00 80 00 	movl   $0x8000c5,(%esp)
  801065:	e8 e7 fc ff ff       	call   800d51 <sys_thread_create>
  80106a:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80106c:	83 c4 08             	add    $0x8,%esp
  80106f:	53                   	push   %ebx
  801070:	68 e4 2b 80 00       	push   $0x802be4
  801075:	e8 5e f1 ff ff       	call   8001d8 <cprintf>
	return id;
	//return 0;
}
  80107a:	89 f0                	mov    %esi,%eax
  80107c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	05 00 00 00 30       	add    $0x30000000,%eax
  80108e:	c1 e8 0c             	shr    $0xc,%eax
}
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	05 00 00 00 30       	add    $0x30000000,%eax
  80109e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	c1 ea 16             	shr    $0x16,%edx
  8010ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c1:	f6 c2 01             	test   $0x1,%dl
  8010c4:	74 11                	je     8010d7 <fd_alloc+0x2d>
  8010c6:	89 c2                	mov    %eax,%edx
  8010c8:	c1 ea 0c             	shr    $0xc,%edx
  8010cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d2:	f6 c2 01             	test   $0x1,%dl
  8010d5:	75 09                	jne    8010e0 <fd_alloc+0x36>
			*fd_store = fd;
  8010d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010de:	eb 17                	jmp    8010f7 <fd_alloc+0x4d>
  8010e0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ea:	75 c9                	jne    8010b5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ec:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010f2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ff:	83 f8 1f             	cmp    $0x1f,%eax
  801102:	77 36                	ja     80113a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801104:	c1 e0 0c             	shl    $0xc,%eax
  801107:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	c1 ea 16             	shr    $0x16,%edx
  801111:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801118:	f6 c2 01             	test   $0x1,%dl
  80111b:	74 24                	je     801141 <fd_lookup+0x48>
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	c1 ea 0c             	shr    $0xc,%edx
  801122:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801129:	f6 c2 01             	test   $0x1,%dl
  80112c:	74 1a                	je     801148 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80112e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801131:	89 02                	mov    %eax,(%edx)
	return 0;
  801133:	b8 00 00 00 00       	mov    $0x0,%eax
  801138:	eb 13                	jmp    80114d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80113a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113f:	eb 0c                	jmp    80114d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801141:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801146:	eb 05                	jmp    80114d <fd_lookup+0x54>
  801148:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801158:	ba 84 2c 80 00       	mov    $0x802c84,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80115d:	eb 13                	jmp    801172 <dev_lookup+0x23>
  80115f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801162:	39 08                	cmp    %ecx,(%eax)
  801164:	75 0c                	jne    801172 <dev_lookup+0x23>
			*dev = devtab[i];
  801166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801169:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	eb 2e                	jmp    8011a0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801172:	8b 02                	mov    (%edx),%eax
  801174:	85 c0                	test   %eax,%eax
  801176:	75 e7                	jne    80115f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801178:	a1 04 40 80 00       	mov    0x804004,%eax
  80117d:	8b 40 54             	mov    0x54(%eax),%eax
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	51                   	push   %ecx
  801184:	50                   	push   %eax
  801185:	68 08 2c 80 00       	push   $0x802c08
  80118a:	e8 49 f0 ff ff       	call   8001d8 <cprintf>
	*dev = 0;
  80118f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801192:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a0:	c9                   	leave  
  8011a1:	c3                   	ret    

008011a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	56                   	push   %esi
  8011a6:	53                   	push   %ebx
  8011a7:	83 ec 10             	sub    $0x10,%esp
  8011aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ba:	c1 e8 0c             	shr    $0xc,%eax
  8011bd:	50                   	push   %eax
  8011be:	e8 36 ff ff ff       	call   8010f9 <fd_lookup>
  8011c3:	83 c4 08             	add    $0x8,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 05                	js     8011cf <fd_close+0x2d>
	    || fd != fd2)
  8011ca:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011cd:	74 0c                	je     8011db <fd_close+0x39>
		return (must_exist ? r : 0);
  8011cf:	84 db                	test   %bl,%bl
  8011d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d6:	0f 44 c2             	cmove  %edx,%eax
  8011d9:	eb 41                	jmp    80121c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	ff 36                	pushl  (%esi)
  8011e4:	e8 66 ff ff ff       	call   80114f <dev_lookup>
  8011e9:	89 c3                	mov    %eax,%ebx
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 1a                	js     80120c <fd_close+0x6a>
		if (dev->dev_close)
  8011f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	74 0b                	je     80120c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	56                   	push   %esi
  801205:	ff d0                	call   *%eax
  801207:	89 c3                	mov    %eax,%ebx
  801209:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	56                   	push   %esi
  801210:	6a 00                	push   $0x0
  801212:	e8 ce f9 ff ff       	call   800be5 <sys_page_unmap>
	return r;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	89 d8                	mov    %ebx,%eax
}
  80121c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	ff 75 08             	pushl  0x8(%ebp)
  801230:	e8 c4 fe ff ff       	call   8010f9 <fd_lookup>
  801235:	83 c4 08             	add    $0x8,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 10                	js     80124c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	6a 01                	push   $0x1
  801241:	ff 75 f4             	pushl  -0xc(%ebp)
  801244:	e8 59 ff ff ff       	call   8011a2 <fd_close>
  801249:	83 c4 10             	add    $0x10,%esp
}
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <close_all>:

void
close_all(void)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	53                   	push   %ebx
  801252:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801255:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125a:	83 ec 0c             	sub    $0xc,%esp
  80125d:	53                   	push   %ebx
  80125e:	e8 c0 ff ff ff       	call   801223 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801263:	83 c3 01             	add    $0x1,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	83 fb 20             	cmp    $0x20,%ebx
  80126c:	75 ec                	jne    80125a <close_all+0xc>
		close(i);
}
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 2c             	sub    $0x2c,%esp
  80127c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80127f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 6e fe ff ff       	call   8010f9 <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	0f 88 c1 00 00 00    	js     801357 <dup+0xe4>
		return r;
	close(newfdnum);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	56                   	push   %esi
  80129a:	e8 84 ff ff ff       	call   801223 <close>

	newfd = INDEX2FD(newfdnum);
  80129f:	89 f3                	mov    %esi,%ebx
  8012a1:	c1 e3 0c             	shl    $0xc,%ebx
  8012a4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012aa:	83 c4 04             	add    $0x4,%esp
  8012ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b0:	e8 de fd ff ff       	call   801093 <fd2data>
  8012b5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012b7:	89 1c 24             	mov    %ebx,(%esp)
  8012ba:	e8 d4 fd ff ff       	call   801093 <fd2data>
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c5:	89 f8                	mov    %edi,%eax
  8012c7:	c1 e8 16             	shr    $0x16,%eax
  8012ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d1:	a8 01                	test   $0x1,%al
  8012d3:	74 37                	je     80130c <dup+0x99>
  8012d5:	89 f8                	mov    %edi,%eax
  8012d7:	c1 e8 0c             	shr    $0xc,%eax
  8012da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e1:	f6 c2 01             	test   $0x1,%dl
  8012e4:	74 26                	je     80130c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f5:	50                   	push   %eax
  8012f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f9:	6a 00                	push   $0x0
  8012fb:	57                   	push   %edi
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 a0 f8 ff ff       	call   800ba3 <sys_page_map>
  801303:	89 c7                	mov    %eax,%edi
  801305:	83 c4 20             	add    $0x20,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 2e                	js     80133a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80130f:	89 d0                	mov    %edx,%eax
  801311:	c1 e8 0c             	shr    $0xc,%eax
  801314:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	25 07 0e 00 00       	and    $0xe07,%eax
  801323:	50                   	push   %eax
  801324:	53                   	push   %ebx
  801325:	6a 00                	push   $0x0
  801327:	52                   	push   %edx
  801328:	6a 00                	push   $0x0
  80132a:	e8 74 f8 ff ff       	call   800ba3 <sys_page_map>
  80132f:	89 c7                	mov    %eax,%edi
  801331:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801334:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801336:	85 ff                	test   %edi,%edi
  801338:	79 1d                	jns    801357 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	53                   	push   %ebx
  80133e:	6a 00                	push   $0x0
  801340:	e8 a0 f8 ff ff       	call   800be5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134b:	6a 00                	push   $0x0
  80134d:	e8 93 f8 ff ff       	call   800be5 <sys_page_unmap>
	return r;
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	89 f8                	mov    %edi,%eax
}
  801357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5e                   	pop    %esi
  80135c:	5f                   	pop    %edi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	53                   	push   %ebx
  801363:	83 ec 14             	sub    $0x14,%esp
  801366:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801369:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	53                   	push   %ebx
  80136e:	e8 86 fd ff ff       	call   8010f9 <fd_lookup>
  801373:	83 c4 08             	add    $0x8,%esp
  801376:	89 c2                	mov    %eax,%edx
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 6d                	js     8013e9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801386:	ff 30                	pushl  (%eax)
  801388:	e8 c2 fd ff ff       	call   80114f <dev_lookup>
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 4c                	js     8013e0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801394:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801397:	8b 42 08             	mov    0x8(%edx),%eax
  80139a:	83 e0 03             	and    $0x3,%eax
  80139d:	83 f8 01             	cmp    $0x1,%eax
  8013a0:	75 21                	jne    8013c3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a7:	8b 40 54             	mov    0x54(%eax),%eax
  8013aa:	83 ec 04             	sub    $0x4,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	50                   	push   %eax
  8013af:	68 49 2c 80 00       	push   $0x802c49
  8013b4:	e8 1f ee ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c1:	eb 26                	jmp    8013e9 <read+0x8a>
	}
	if (!dev->dev_read)
  8013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c6:	8b 40 08             	mov    0x8(%eax),%eax
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	74 17                	je     8013e4 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	ff 75 10             	pushl  0x10(%ebp)
  8013d3:	ff 75 0c             	pushl  0xc(%ebp)
  8013d6:	52                   	push   %edx
  8013d7:	ff d0                	call   *%eax
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	eb 09                	jmp    8013e9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e0:	89 c2                	mov    %eax,%edx
  8013e2:	eb 05                	jmp    8013e9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013e9:	89 d0                	mov    %edx,%eax
  8013eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	57                   	push   %edi
  8013f4:	56                   	push   %esi
  8013f5:	53                   	push   %ebx
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801404:	eb 21                	jmp    801427 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801406:	83 ec 04             	sub    $0x4,%esp
  801409:	89 f0                	mov    %esi,%eax
  80140b:	29 d8                	sub    %ebx,%eax
  80140d:	50                   	push   %eax
  80140e:	89 d8                	mov    %ebx,%eax
  801410:	03 45 0c             	add    0xc(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	57                   	push   %edi
  801415:	e8 45 ff ff ff       	call   80135f <read>
		if (m < 0)
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 10                	js     801431 <readn+0x41>
			return m;
		if (m == 0)
  801421:	85 c0                	test   %eax,%eax
  801423:	74 0a                	je     80142f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801425:	01 c3                	add    %eax,%ebx
  801427:	39 f3                	cmp    %esi,%ebx
  801429:	72 db                	jb     801406 <readn+0x16>
  80142b:	89 d8                	mov    %ebx,%eax
  80142d:	eb 02                	jmp    801431 <readn+0x41>
  80142f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801431:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	83 ec 14             	sub    $0x14,%esp
  801440:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801443:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	53                   	push   %ebx
  801448:	e8 ac fc ff ff       	call   8010f9 <fd_lookup>
  80144d:	83 c4 08             	add    $0x8,%esp
  801450:	89 c2                	mov    %eax,%edx
  801452:	85 c0                	test   %eax,%eax
  801454:	78 68                	js     8014be <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801460:	ff 30                	pushl  (%eax)
  801462:	e8 e8 fc ff ff       	call   80114f <dev_lookup>
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 47                	js     8014b5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801471:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801475:	75 21                	jne    801498 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801477:	a1 04 40 80 00       	mov    0x804004,%eax
  80147c:	8b 40 54             	mov    0x54(%eax),%eax
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	53                   	push   %ebx
  801483:	50                   	push   %eax
  801484:	68 65 2c 80 00       	push   $0x802c65
  801489:	e8 4a ed ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801496:	eb 26                	jmp    8014be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801498:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149b:	8b 52 0c             	mov    0xc(%edx),%edx
  80149e:	85 d2                	test   %edx,%edx
  8014a0:	74 17                	je     8014b9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	ff 75 10             	pushl  0x10(%ebp)
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	50                   	push   %eax
  8014ac:	ff d2                	call   *%edx
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	eb 09                	jmp    8014be <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	eb 05                	jmp    8014be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014be:	89 d0                	mov    %edx,%eax
  8014c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	ff 75 08             	pushl  0x8(%ebp)
  8014d2:	e8 22 fc ff ff       	call   8010f9 <fd_lookup>
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 0e                	js     8014ec <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 14             	sub    $0x14,%esp
  8014f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	53                   	push   %ebx
  8014fd:	e8 f7 fb ff ff       	call   8010f9 <fd_lookup>
  801502:	83 c4 08             	add    $0x8,%esp
  801505:	89 c2                	mov    %eax,%edx
  801507:	85 c0                	test   %eax,%eax
  801509:	78 65                	js     801570 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801515:	ff 30                	pushl  (%eax)
  801517:	e8 33 fc ff ff       	call   80114f <dev_lookup>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 44                	js     801567 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152a:	75 21                	jne    80154d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80152c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801531:	8b 40 54             	mov    0x54(%eax),%eax
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	53                   	push   %ebx
  801538:	50                   	push   %eax
  801539:	68 28 2c 80 00       	push   $0x802c28
  80153e:	e8 95 ec ff ff       	call   8001d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154b:	eb 23                	jmp    801570 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80154d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801550:	8b 52 18             	mov    0x18(%edx),%edx
  801553:	85 d2                	test   %edx,%edx
  801555:	74 14                	je     80156b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	50                   	push   %eax
  80155e:	ff d2                	call   *%edx
  801560:	89 c2                	mov    %eax,%edx
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	eb 09                	jmp    801570 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	89 c2                	mov    %eax,%edx
  801569:	eb 05                	jmp    801570 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801570:	89 d0                	mov    %edx,%eax
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	53                   	push   %ebx
  80157b:	83 ec 14             	sub    $0x14,%esp
  80157e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801581:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	ff 75 08             	pushl  0x8(%ebp)
  801588:	e8 6c fb ff ff       	call   8010f9 <fd_lookup>
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	89 c2                	mov    %eax,%edx
  801592:	85 c0                	test   %eax,%eax
  801594:	78 58                	js     8015ee <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a0:	ff 30                	pushl  (%eax)
  8015a2:	e8 a8 fb ff ff       	call   80114f <dev_lookup>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 37                	js     8015e5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b5:	74 32                	je     8015e9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c1:	00 00 00 
	stat->st_isdir = 0;
  8015c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cb:	00 00 00 
	stat->st_dev = dev;
  8015ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8015db:	ff 50 14             	call   *0x14(%eax)
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	eb 09                	jmp    8015ee <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	eb 05                	jmp    8015ee <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	6a 00                	push   $0x0
  8015ff:	ff 75 08             	pushl  0x8(%ebp)
  801602:	e8 e3 01 00 00       	call   8017ea <open>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 1b                	js     80162b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	50                   	push   %eax
  801617:	e8 5b ff ff ff       	call   801577 <fstat>
  80161c:	89 c6                	mov    %eax,%esi
	close(fd);
  80161e:	89 1c 24             	mov    %ebx,(%esp)
  801621:	e8 fd fb ff ff       	call   801223 <close>
	return r;
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	89 f0                	mov    %esi,%eax
}
  80162b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	89 c6                	mov    %eax,%esi
  801639:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801642:	75 12                	jne    801656 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	6a 01                	push   $0x1
  801649:	e8 6a 0e 00 00       	call   8024b8 <ipc_find_env>
  80164e:	a3 00 40 80 00       	mov    %eax,0x804000
  801653:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801656:	6a 07                	push   $0x7
  801658:	68 00 50 80 00       	push   $0x805000
  80165d:	56                   	push   %esi
  80165e:	ff 35 00 40 80 00    	pushl  0x804000
  801664:	e8 ed 0d 00 00       	call   802456 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801669:	83 c4 0c             	add    $0xc,%esp
  80166c:	6a 00                	push   $0x0
  80166e:	53                   	push   %ebx
  80166f:	6a 00                	push   $0x0
  801671:	e8 68 0d 00 00       	call   8023de <ipc_recv>
}
  801676:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 40 0c             	mov    0xc(%eax),%eax
  801689:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801691:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801696:	ba 00 00 00 00       	mov    $0x0,%edx
  80169b:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a0:	e8 8d ff ff ff       	call   801632 <fsipc>
}
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c2:	e8 6b ff ff ff       	call   801632 <fsipc>
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016de:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e8:	e8 45 ff ff ff       	call   801632 <fsipc>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 2c                	js     80171d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	68 00 50 80 00       	push   $0x805000
  8016f9:	53                   	push   %ebx
  8016fa:	e8 5e f0 ff ff       	call   80075d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ff:	a1 80 50 80 00       	mov    0x805080,%eax
  801704:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170a:	a1 84 50 80 00       	mov    0x805084,%eax
  80170f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 0c             	sub    $0xc,%esp
  801728:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80172b:	8b 55 08             	mov    0x8(%ebp),%edx
  80172e:	8b 52 0c             	mov    0xc(%edx),%edx
  801731:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801737:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80173c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801741:	0f 47 c2             	cmova  %edx,%eax
  801744:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801749:	50                   	push   %eax
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	68 08 50 80 00       	push   $0x805008
  801752:	e8 98 f1 ff ff       	call   8008ef <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 04 00 00 00       	mov    $0x4,%eax
  801761:	e8 cc fe ff ff       	call   801632 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	8b 40 0c             	mov    0xc(%eax),%eax
  801776:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80177b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	b8 03 00 00 00       	mov    $0x3,%eax
  80178b:	e8 a2 fe ff ff       	call   801632 <fsipc>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	85 c0                	test   %eax,%eax
  801794:	78 4b                	js     8017e1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801796:	39 c6                	cmp    %eax,%esi
  801798:	73 16                	jae    8017b0 <devfile_read+0x48>
  80179a:	68 94 2c 80 00       	push   $0x802c94
  80179f:	68 9b 2c 80 00       	push   $0x802c9b
  8017a4:	6a 7c                	push   $0x7c
  8017a6:	68 b0 2c 80 00       	push   $0x802cb0
  8017ab:	e8 4f e9 ff ff       	call   8000ff <_panic>
	assert(r <= PGSIZE);
  8017b0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b5:	7e 16                	jle    8017cd <devfile_read+0x65>
  8017b7:	68 bb 2c 80 00       	push   $0x802cbb
  8017bc:	68 9b 2c 80 00       	push   $0x802c9b
  8017c1:	6a 7d                	push   $0x7d
  8017c3:	68 b0 2c 80 00       	push   $0x802cb0
  8017c8:	e8 32 e9 ff ff       	call   8000ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	50                   	push   %eax
  8017d1:	68 00 50 80 00       	push   $0x805000
  8017d6:	ff 75 0c             	pushl  0xc(%ebp)
  8017d9:	e8 11 f1 ff ff       	call   8008ef <memmove>
	return r;
  8017de:	83 c4 10             	add    $0x10,%esp
}
  8017e1:	89 d8                	mov    %ebx,%eax
  8017e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 20             	sub    $0x20,%esp
  8017f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f4:	53                   	push   %ebx
  8017f5:	e8 2a ef ff ff       	call   800724 <strlen>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801802:	7f 67                	jg     80186b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801804:	83 ec 0c             	sub    $0xc,%esp
  801807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180a:	50                   	push   %eax
  80180b:	e8 9a f8 ff ff       	call   8010aa <fd_alloc>
  801810:	83 c4 10             	add    $0x10,%esp
		return r;
  801813:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801815:	85 c0                	test   %eax,%eax
  801817:	78 57                	js     801870 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	53                   	push   %ebx
  80181d:	68 00 50 80 00       	push   $0x805000
  801822:	e8 36 ef ff ff       	call   80075d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801832:	b8 01 00 00 00       	mov    $0x1,%eax
  801837:	e8 f6 fd ff ff       	call   801632 <fsipc>
  80183c:	89 c3                	mov    %eax,%ebx
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	79 14                	jns    801859 <open+0x6f>
		fd_close(fd, 0);
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	6a 00                	push   $0x0
  80184a:	ff 75 f4             	pushl  -0xc(%ebp)
  80184d:	e8 50 f9 ff ff       	call   8011a2 <fd_close>
		return r;
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	89 da                	mov    %ebx,%edx
  801857:	eb 17                	jmp    801870 <open+0x86>
	}

	return fd2num(fd);
  801859:	83 ec 0c             	sub    $0xc,%esp
  80185c:	ff 75 f4             	pushl  -0xc(%ebp)
  80185f:	e8 1f f8 ff ff       	call   801083 <fd2num>
  801864:	89 c2                	mov    %eax,%edx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	eb 05                	jmp    801870 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801870:	89 d0                	mov    %edx,%eax
  801872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 08 00 00 00       	mov    $0x8,%eax
  801887:	e8 a6 fd ff ff       	call   801632 <fsipc>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	57                   	push   %edi
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80189a:	6a 00                	push   $0x0
  80189c:	ff 75 08             	pushl  0x8(%ebp)
  80189f:	e8 46 ff ff ff       	call   8017ea <open>
  8018a4:	89 c7                	mov    %eax,%edi
  8018a6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	0f 88 89 04 00 00    	js     801d40 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	68 00 02 00 00       	push   $0x200
  8018bf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	57                   	push   %edi
  8018c7:	e8 24 fb ff ff       	call   8013f0 <readn>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018d4:	75 0c                	jne    8018e2 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018d6:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018dd:	45 4c 46 
  8018e0:	74 33                	je     801915 <spawn+0x87>
		close(fd);
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018eb:	e8 33 f9 ff ff       	call   801223 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018f0:	83 c4 0c             	add    $0xc,%esp
  8018f3:	68 7f 45 4c 46       	push   $0x464c457f
  8018f8:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018fe:	68 c7 2c 80 00       	push   $0x802cc7
  801903:	e8 d0 e8 ff ff       	call   8001d8 <cprintf>
		return -E_NOT_EXEC;
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801910:	e9 de 04 00 00       	jmp    801df3 <spawn+0x565>
  801915:	b8 07 00 00 00       	mov    $0x7,%eax
  80191a:	cd 30                	int    $0x30
  80191c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801922:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 1b 04 00 00    	js     801d4b <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801930:	25 ff 03 00 00       	and    $0x3ff,%eax
  801935:	89 c2                	mov    %eax,%edx
  801937:	c1 e2 07             	shl    $0x7,%edx
  80193a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801940:	8d b4 c2 0c 00 c0 ee 	lea    -0x113ffff4(%edx,%eax,8),%esi
  801947:	b9 11 00 00 00       	mov    $0x11,%ecx
  80194c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80194e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801954:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80195a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80195f:	be 00 00 00 00       	mov    $0x0,%esi
  801964:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801967:	eb 13                	jmp    80197c <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	50                   	push   %eax
  80196d:	e8 b2 ed ff ff       	call   800724 <strlen>
  801972:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801976:	83 c3 01             	add    $0x1,%ebx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801983:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801986:	85 c0                	test   %eax,%eax
  801988:	75 df                	jne    801969 <spawn+0xdb>
  80198a:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801990:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801996:	bf 00 10 40 00       	mov    $0x401000,%edi
  80199b:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80199d:	89 fa                	mov    %edi,%edx
  80199f:	83 e2 fc             	and    $0xfffffffc,%edx
  8019a2:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019a9:	29 c2                	sub    %eax,%edx
  8019ab:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019b1:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019b4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019b9:	0f 86 a2 03 00 00    	jbe    801d61 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019bf:	83 ec 04             	sub    $0x4,%esp
  8019c2:	6a 07                	push   $0x7
  8019c4:	68 00 00 40 00       	push   $0x400000
  8019c9:	6a 00                	push   $0x0
  8019cb:	e8 90 f1 ff ff       	call   800b60 <sys_page_alloc>
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	0f 88 90 03 00 00    	js     801d6b <spawn+0x4dd>
  8019db:	be 00 00 00 00       	mov    $0x0,%esi
  8019e0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e9:	eb 30                	jmp    801a1b <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019eb:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019f1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019f7:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a00:	57                   	push   %edi
  801a01:	e8 57 ed ff ff       	call   80075d <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a06:	83 c4 04             	add    $0x4,%esp
  801a09:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a0c:	e8 13 ed ff ff       	call   800724 <strlen>
  801a11:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a15:	83 c6 01             	add    $0x1,%esi
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a21:	7f c8                	jg     8019eb <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a23:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a29:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a2f:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a36:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a3c:	74 19                	je     801a57 <spawn+0x1c9>
  801a3e:	68 54 2d 80 00       	push   $0x802d54
  801a43:	68 9b 2c 80 00       	push   $0x802c9b
  801a48:	68 f2 00 00 00       	push   $0xf2
  801a4d:	68 e1 2c 80 00       	push   $0x802ce1
  801a52:	e8 a8 e6 ff ff       	call   8000ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a57:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a5d:	89 f8                	mov    %edi,%eax
  801a5f:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a64:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a67:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a6d:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a70:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a76:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	6a 07                	push   $0x7
  801a81:	68 00 d0 bf ee       	push   $0xeebfd000
  801a86:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a8c:	68 00 00 40 00       	push   $0x400000
  801a91:	6a 00                	push   $0x0
  801a93:	e8 0b f1 ff ff       	call   800ba3 <sys_page_map>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 20             	add    $0x20,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 3c 03 00 00    	js     801de1 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801aa5:	83 ec 08             	sub    $0x8,%esp
  801aa8:	68 00 00 40 00       	push   $0x400000
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 31 f1 ff ff       	call   800be5 <sys_page_unmap>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	0f 88 20 03 00 00    	js     801de1 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ac1:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ac7:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ace:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ad4:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801adb:	00 00 00 
  801ade:	e9 88 01 00 00       	jmp    801c6b <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801ae3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ae9:	83 38 01             	cmpl   $0x1,(%eax)
  801aec:	0f 85 6b 01 00 00    	jne    801c5d <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	8b 40 18             	mov    0x18(%eax),%eax
  801af7:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801afd:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b00:	83 f8 01             	cmp    $0x1,%eax
  801b03:	19 c0                	sbb    %eax,%eax
  801b05:	83 e0 fe             	and    $0xfffffffe,%eax
  801b08:	83 c0 07             	add    $0x7,%eax
  801b0b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b11:	89 d0                	mov    %edx,%eax
  801b13:	8b 7a 04             	mov    0x4(%edx),%edi
  801b16:	89 f9                	mov    %edi,%ecx
  801b18:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b1e:	8b 7a 10             	mov    0x10(%edx),%edi
  801b21:	8b 52 14             	mov    0x14(%edx),%edx
  801b24:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b2a:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b2d:	89 f0                	mov    %esi,%eax
  801b2f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b34:	74 14                	je     801b4a <spawn+0x2bc>
		va -= i;
  801b36:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b38:	01 c2                	add    %eax,%edx
  801b3a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b40:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b42:	29 c1                	sub    %eax,%ecx
  801b44:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4f:	e9 f7 00 00 00       	jmp    801c4b <spawn+0x3bd>
		if (i >= filesz) {
  801b54:	39 fb                	cmp    %edi,%ebx
  801b56:	72 27                	jb     801b7f <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b61:	56                   	push   %esi
  801b62:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b68:	e8 f3 ef ff ff       	call   800b60 <sys_page_alloc>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 89 c7 00 00 00    	jns    801c3f <spawn+0x3b1>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	e9 fd 01 00 00       	jmp    801d7c <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b7f:	83 ec 04             	sub    $0x4,%esp
  801b82:	6a 07                	push   $0x7
  801b84:	68 00 00 40 00       	push   $0x400000
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 d0 ef ff ff       	call   800b60 <sys_page_alloc>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 d7 01 00 00    	js     801d72 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ba4:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801baa:	50                   	push   %eax
  801bab:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bb1:	e8 0f f9 ff ff       	call   8014c5 <seek>
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 b5 01 00 00    	js     801d76 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	89 f8                	mov    %edi,%eax
  801bc6:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bcc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bd1:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bd6:	0f 47 c2             	cmova  %edx,%eax
  801bd9:	50                   	push   %eax
  801bda:	68 00 00 40 00       	push   $0x400000
  801bdf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801be5:	e8 06 f8 ff ff       	call   8013f0 <readn>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 88 85 01 00 00    	js     801d7a <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bf5:	83 ec 0c             	sub    $0xc,%esp
  801bf8:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bfe:	56                   	push   %esi
  801bff:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c05:	68 00 00 40 00       	push   $0x400000
  801c0a:	6a 00                	push   $0x0
  801c0c:	e8 92 ef ff ff       	call   800ba3 <sys_page_map>
  801c11:	83 c4 20             	add    $0x20,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	79 15                	jns    801c2d <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c18:	50                   	push   %eax
  801c19:	68 ed 2c 80 00       	push   $0x802ced
  801c1e:	68 25 01 00 00       	push   $0x125
  801c23:	68 e1 2c 80 00       	push   $0x802ce1
  801c28:	e8 d2 e4 ff ff       	call   8000ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c2d:	83 ec 08             	sub    $0x8,%esp
  801c30:	68 00 00 40 00       	push   $0x400000
  801c35:	6a 00                	push   $0x0
  801c37:	e8 a9 ef ff ff       	call   800be5 <sys_page_unmap>
  801c3c:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c3f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c45:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c4b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c51:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801c57:	0f 82 f7 fe ff ff    	jb     801b54 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c5d:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c64:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c6b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c72:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c78:	0f 8c 65 fe ff ff    	jl     801ae3 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c87:	e8 97 f5 ff ff       	call   801223 <close>
  801c8c:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c94:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801c9a:	89 d8                	mov    %ebx,%eax
  801c9c:	c1 e8 16             	shr    $0x16,%eax
  801c9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ca6:	a8 01                	test   $0x1,%al
  801ca8:	74 42                	je     801cec <spawn+0x45e>
  801caa:	89 d8                	mov    %ebx,%eax
  801cac:	c1 e8 0c             	shr    $0xc,%eax
  801caf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cb6:	f6 c2 01             	test   $0x1,%dl
  801cb9:	74 31                	je     801cec <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801cbb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801cc2:	f6 c6 04             	test   $0x4,%dh
  801cc5:	74 25                	je     801cec <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801cc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	25 07 0e 00 00       	and    $0xe07,%eax
  801cd6:	50                   	push   %eax
  801cd7:	53                   	push   %ebx
  801cd8:	56                   	push   %esi
  801cd9:	53                   	push   %ebx
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 c2 ee ff ff       	call   800ba3 <sys_page_map>
			if (r < 0) {
  801ce1:	83 c4 20             	add    $0x20,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 b1 00 00 00    	js     801d9d <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801cec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cf2:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801cf8:	75 a0                	jne    801c9a <spawn+0x40c>
  801cfa:	e9 b3 00 00 00       	jmp    801db2 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801cff:	50                   	push   %eax
  801d00:	68 0a 2d 80 00       	push   $0x802d0a
  801d05:	68 86 00 00 00       	push   $0x86
  801d0a:	68 e1 2c 80 00       	push   $0x802ce1
  801d0f:	e8 eb e3 ff ff       	call   8000ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d14:	83 ec 08             	sub    $0x8,%esp
  801d17:	6a 02                	push   $0x2
  801d19:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d1f:	e8 03 ef ff ff       	call   800c27 <sys_env_set_status>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	85 c0                	test   %eax,%eax
  801d29:	79 2b                	jns    801d56 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801d2b:	50                   	push   %eax
  801d2c:	68 24 2d 80 00       	push   $0x802d24
  801d31:	68 89 00 00 00       	push   $0x89
  801d36:	68 e1 2c 80 00       	push   $0x802ce1
  801d3b:	e8 bf e3 ff ff       	call   8000ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d40:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d46:	e9 a8 00 00 00       	jmp    801df3 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d4b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d51:	e9 9d 00 00 00       	jmp    801df3 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d56:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d5c:	e9 92 00 00 00       	jmp    801df3 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d61:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d66:	e9 88 00 00 00       	jmp    801df3 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	e9 81 00 00 00       	jmp    801df3 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	eb 06                	jmp    801d7c <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	eb 02                	jmp    801d7c <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d7a:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d85:	e8 57 ed ff ff       	call   800ae1 <sys_env_destroy>
	close(fd);
  801d8a:	83 c4 04             	add    $0x4,%esp
  801d8d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d93:	e8 8b f4 ff ff       	call   801223 <close>
	return r;
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	eb 56                	jmp    801df3 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801d9d:	50                   	push   %eax
  801d9e:	68 3b 2d 80 00       	push   $0x802d3b
  801da3:	68 82 00 00 00       	push   $0x82
  801da8:	68 e1 2c 80 00       	push   $0x802ce1
  801dad:	e8 4d e3 ff ff       	call   8000ff <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801db2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801db9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dbc:	83 ec 08             	sub    $0x8,%esp
  801dbf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dcc:	e8 98 ee ff ff       	call   800c69 <sys_env_set_trapframe>
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 89 38 ff ff ff    	jns    801d14 <spawn+0x486>
  801ddc:	e9 1e ff ff ff       	jmp    801cff <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801de1:	83 ec 08             	sub    $0x8,%esp
  801de4:	68 00 00 40 00       	push   $0x400000
  801de9:	6a 00                	push   $0x0
  801deb:	e8 f5 ed ff ff       	call   800be5 <sys_page_unmap>
  801df0:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801df3:	89 d8                	mov    %ebx,%eax
  801df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e02:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e0a:	eb 03                	jmp    801e0f <spawnl+0x12>
		argc++;
  801e0c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e0f:	83 c2 04             	add    $0x4,%edx
  801e12:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e16:	75 f4                	jne    801e0c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e18:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e1f:	83 e2 f0             	and    $0xfffffff0,%edx
  801e22:	29 d4                	sub    %edx,%esp
  801e24:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e28:	c1 ea 02             	shr    $0x2,%edx
  801e2b:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e32:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e37:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e3e:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e45:	00 
  801e46:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e48:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4d:	eb 0a                	jmp    801e59 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e4f:	83 c0 01             	add    $0x1,%eax
  801e52:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e56:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e59:	39 d0                	cmp    %edx,%eax
  801e5b:	75 f2                	jne    801e4f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e5d:	83 ec 08             	sub    $0x8,%esp
  801e60:	56                   	push   %esi
  801e61:	ff 75 08             	pushl  0x8(%ebp)
  801e64:	e8 25 fa ff ff       	call   80188e <spawn>
}
  801e69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6c:	5b                   	pop    %ebx
  801e6d:	5e                   	pop    %esi
  801e6e:	5d                   	pop    %ebp
  801e6f:	c3                   	ret    

00801e70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e78:	83 ec 0c             	sub    $0xc,%esp
  801e7b:	ff 75 08             	pushl  0x8(%ebp)
  801e7e:	e8 10 f2 ff ff       	call   801093 <fd2data>
  801e83:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e85:	83 c4 08             	add    $0x8,%esp
  801e88:	68 7c 2d 80 00       	push   $0x802d7c
  801e8d:	53                   	push   %ebx
  801e8e:	e8 ca e8 ff ff       	call   80075d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e93:	8b 46 04             	mov    0x4(%esi),%eax
  801e96:	2b 06                	sub    (%esi),%eax
  801e98:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e9e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea5:	00 00 00 
	stat->st_dev = &devpipe;
  801ea8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801eaf:	30 80 00 
	return 0;
}
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	53                   	push   %ebx
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ec8:	53                   	push   %ebx
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 15 ed ff ff       	call   800be5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed0:	89 1c 24             	mov    %ebx,(%esp)
  801ed3:	e8 bb f1 ff ff       	call   801093 <fd2data>
  801ed8:	83 c4 08             	add    $0x8,%esp
  801edb:	50                   	push   %eax
  801edc:	6a 00                	push   $0x0
  801ede:	e8 02 ed ff ff       	call   800be5 <sys_page_unmap>
}
  801ee3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	57                   	push   %edi
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	83 ec 1c             	sub    $0x1c,%esp
  801ef1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ef4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef6:	a1 04 40 80 00       	mov    0x804004,%eax
  801efb:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801efe:	83 ec 0c             	sub    $0xc,%esp
  801f01:	ff 75 e0             	pushl  -0x20(%ebp)
  801f04:	e8 ef 05 00 00       	call   8024f8 <pageref>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	89 3c 24             	mov    %edi,(%esp)
  801f0e:	e8 e5 05 00 00       	call   8024f8 <pageref>
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	39 c3                	cmp    %eax,%ebx
  801f18:	0f 94 c1             	sete   %cl
  801f1b:	0f b6 c9             	movzbl %cl,%ecx
  801f1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f21:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f27:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801f2a:	39 ce                	cmp    %ecx,%esi
  801f2c:	74 1b                	je     801f49 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f2e:	39 c3                	cmp    %eax,%ebx
  801f30:	75 c4                	jne    801ef6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f32:	8b 42 64             	mov    0x64(%edx),%eax
  801f35:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f38:	50                   	push   %eax
  801f39:	56                   	push   %esi
  801f3a:	68 83 2d 80 00       	push   $0x802d83
  801f3f:	e8 94 e2 ff ff       	call   8001d8 <cprintf>
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	eb ad                	jmp    801ef6 <_pipeisclosed+0xe>
	}
}
  801f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	57                   	push   %edi
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	83 ec 28             	sub    $0x28,%esp
  801f5d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f60:	56                   	push   %esi
  801f61:	e8 2d f1 ff ff       	call   801093 <fd2data>
  801f66:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	bf 00 00 00 00       	mov    $0x0,%edi
  801f70:	eb 4b                	jmp    801fbd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f72:	89 da                	mov    %ebx,%edx
  801f74:	89 f0                	mov    %esi,%eax
  801f76:	e8 6d ff ff ff       	call   801ee8 <_pipeisclosed>
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	75 48                	jne    801fc7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f7f:	e8 bd eb ff ff       	call   800b41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f84:	8b 43 04             	mov    0x4(%ebx),%eax
  801f87:	8b 0b                	mov    (%ebx),%ecx
  801f89:	8d 51 20             	lea    0x20(%ecx),%edx
  801f8c:	39 d0                	cmp    %edx,%eax
  801f8e:	73 e2                	jae    801f72 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f9a:	89 c2                	mov    %eax,%edx
  801f9c:	c1 fa 1f             	sar    $0x1f,%edx
  801f9f:	89 d1                	mov    %edx,%ecx
  801fa1:	c1 e9 1b             	shr    $0x1b,%ecx
  801fa4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fa7:	83 e2 1f             	and    $0x1f,%edx
  801faa:	29 ca                	sub    %ecx,%edx
  801fac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fb4:	83 c0 01             	add    $0x1,%eax
  801fb7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fba:	83 c7 01             	add    $0x1,%edi
  801fbd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc0:	75 c2                	jne    801f84 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc5:	eb 05                	jmp    801fcc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	57                   	push   %edi
  801fd8:	56                   	push   %esi
  801fd9:	53                   	push   %ebx
  801fda:	83 ec 18             	sub    $0x18,%esp
  801fdd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe0:	57                   	push   %edi
  801fe1:	e8 ad f0 ff ff       	call   801093 <fd2data>
  801fe6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff0:	eb 3d                	jmp    80202f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff2:	85 db                	test   %ebx,%ebx
  801ff4:	74 04                	je     801ffa <devpipe_read+0x26>
				return i;
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	eb 44                	jmp    80203e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ffa:	89 f2                	mov    %esi,%edx
  801ffc:	89 f8                	mov    %edi,%eax
  801ffe:	e8 e5 fe ff ff       	call   801ee8 <_pipeisclosed>
  802003:	85 c0                	test   %eax,%eax
  802005:	75 32                	jne    802039 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802007:	e8 35 eb ff ff       	call   800b41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80200c:	8b 06                	mov    (%esi),%eax
  80200e:	3b 46 04             	cmp    0x4(%esi),%eax
  802011:	74 df                	je     801ff2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802013:	99                   	cltd   
  802014:	c1 ea 1b             	shr    $0x1b,%edx
  802017:	01 d0                	add    %edx,%eax
  802019:	83 e0 1f             	and    $0x1f,%eax
  80201c:	29 d0                	sub    %edx,%eax
  80201e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802026:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802029:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202c:	83 c3 01             	add    $0x1,%ebx
  80202f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802032:	75 d8                	jne    80200c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802034:	8b 45 10             	mov    0x10(%ebp),%eax
  802037:	eb 05                	jmp    80203e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80203e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5f                   	pop    %edi
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    

00802046 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80204e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802051:	50                   	push   %eax
  802052:	e8 53 f0 ff ff       	call   8010aa <fd_alloc>
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	89 c2                	mov    %eax,%edx
  80205c:	85 c0                	test   %eax,%eax
  80205e:	0f 88 2c 01 00 00    	js     802190 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802064:	83 ec 04             	sub    $0x4,%esp
  802067:	68 07 04 00 00       	push   $0x407
  80206c:	ff 75 f4             	pushl  -0xc(%ebp)
  80206f:	6a 00                	push   $0x0
  802071:	e8 ea ea ff ff       	call   800b60 <sys_page_alloc>
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	89 c2                	mov    %eax,%edx
  80207b:	85 c0                	test   %eax,%eax
  80207d:	0f 88 0d 01 00 00    	js     802190 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802083:	83 ec 0c             	sub    $0xc,%esp
  802086:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802089:	50                   	push   %eax
  80208a:	e8 1b f0 ff ff       	call   8010aa <fd_alloc>
  80208f:	89 c3                	mov    %eax,%ebx
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	85 c0                	test   %eax,%eax
  802096:	0f 88 e2 00 00 00    	js     80217e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209c:	83 ec 04             	sub    $0x4,%esp
  80209f:	68 07 04 00 00       	push   $0x407
  8020a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a7:	6a 00                	push   $0x0
  8020a9:	e8 b2 ea ff ff       	call   800b60 <sys_page_alloc>
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	0f 88 c3 00 00 00    	js     80217e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020bb:	83 ec 0c             	sub    $0xc,%esp
  8020be:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c1:	e8 cd ef ff ff       	call   801093 <fd2data>
  8020c6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c8:	83 c4 0c             	add    $0xc,%esp
  8020cb:	68 07 04 00 00       	push   $0x407
  8020d0:	50                   	push   %eax
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 88 ea ff ff       	call   800b60 <sys_page_alloc>
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 88 89 00 00 00    	js     80216e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e5:	83 ec 0c             	sub    $0xc,%esp
  8020e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8020eb:	e8 a3 ef ff ff       	call   801093 <fd2data>
  8020f0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020f7:	50                   	push   %eax
  8020f8:	6a 00                	push   $0x0
  8020fa:	56                   	push   %esi
  8020fb:	6a 00                	push   $0x0
  8020fd:	e8 a1 ea ff ff       	call   800ba3 <sys_page_map>
  802102:	89 c3                	mov    %eax,%ebx
  802104:	83 c4 20             	add    $0x20,%esp
  802107:	85 c0                	test   %eax,%eax
  802109:	78 55                	js     802160 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802119:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802120:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802129:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802135:	83 ec 0c             	sub    $0xc,%esp
  802138:	ff 75 f4             	pushl  -0xc(%ebp)
  80213b:	e8 43 ef ff ff       	call   801083 <fd2num>
  802140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802143:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802145:	83 c4 04             	add    $0x4,%esp
  802148:	ff 75 f0             	pushl  -0x10(%ebp)
  80214b:	e8 33 ef ff ff       	call   801083 <fd2num>
  802150:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802153:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	ba 00 00 00 00       	mov    $0x0,%edx
  80215e:	eb 30                	jmp    802190 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802160:	83 ec 08             	sub    $0x8,%esp
  802163:	56                   	push   %esi
  802164:	6a 00                	push   $0x0
  802166:	e8 7a ea ff ff       	call   800be5 <sys_page_unmap>
  80216b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80216e:	83 ec 08             	sub    $0x8,%esp
  802171:	ff 75 f0             	pushl  -0x10(%ebp)
  802174:	6a 00                	push   $0x0
  802176:	e8 6a ea ff ff       	call   800be5 <sys_page_unmap>
  80217b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80217e:	83 ec 08             	sub    $0x8,%esp
  802181:	ff 75 f4             	pushl  -0xc(%ebp)
  802184:	6a 00                	push   $0x0
  802186:	e8 5a ea ff ff       	call   800be5 <sys_page_unmap>
  80218b:	83 c4 10             	add    $0x10,%esp
  80218e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802190:	89 d0                	mov    %edx,%eax
  802192:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	50                   	push   %eax
  8021a3:	ff 75 08             	pushl  0x8(%ebp)
  8021a6:	e8 4e ef ff ff       	call   8010f9 <fd_lookup>
  8021ab:	83 c4 10             	add    $0x10,%esp
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	78 18                	js     8021ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b2:	83 ec 0c             	sub    $0xc,%esp
  8021b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b8:	e8 d6 ee ff ff       	call   801093 <fd2data>
	return _pipeisclosed(fd, p);
  8021bd:	89 c2                	mov    %eax,%edx
  8021bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c2:	e8 21 fd ff ff       	call   801ee8 <_pipeisclosed>
  8021c7:	83 c4 10             	add    $0x10,%esp
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021dc:	68 9b 2d 80 00       	push   $0x802d9b
  8021e1:	ff 75 0c             	pushl  0xc(%ebp)
  8021e4:	e8 74 e5 ff ff       	call   80075d <strcpy>
	return 0;
}
  8021e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	57                   	push   %edi
  8021f4:	56                   	push   %esi
  8021f5:	53                   	push   %ebx
  8021f6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021fc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802201:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802207:	eb 2d                	jmp    802236 <devcons_write+0x46>
		m = n - tot;
  802209:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80220c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80220e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802211:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802216:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802219:	83 ec 04             	sub    $0x4,%esp
  80221c:	53                   	push   %ebx
  80221d:	03 45 0c             	add    0xc(%ebp),%eax
  802220:	50                   	push   %eax
  802221:	57                   	push   %edi
  802222:	e8 c8 e6 ff ff       	call   8008ef <memmove>
		sys_cputs(buf, m);
  802227:	83 c4 08             	add    $0x8,%esp
  80222a:	53                   	push   %ebx
  80222b:	57                   	push   %edi
  80222c:	e8 73 e8 ff ff       	call   800aa4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802231:	01 de                	add    %ebx,%esi
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	89 f0                	mov    %esi,%eax
  802238:	3b 75 10             	cmp    0x10(%ebp),%esi
  80223b:	72 cc                	jb     802209 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80223d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802240:	5b                   	pop    %ebx
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    

00802245 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 08             	sub    $0x8,%esp
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802250:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802254:	74 2a                	je     802280 <devcons_read+0x3b>
  802256:	eb 05                	jmp    80225d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802258:	e8 e4 e8 ff ff       	call   800b41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80225d:	e8 60 e8 ff ff       	call   800ac2 <sys_cgetc>
  802262:	85 c0                	test   %eax,%eax
  802264:	74 f2                	je     802258 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802266:	85 c0                	test   %eax,%eax
  802268:	78 16                	js     802280 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80226a:	83 f8 04             	cmp    $0x4,%eax
  80226d:	74 0c                	je     80227b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80226f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802272:	88 02                	mov    %al,(%edx)
	return 1;
  802274:	b8 01 00 00 00       	mov    $0x1,%eax
  802279:	eb 05                	jmp    802280 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80227b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802280:	c9                   	leave  
  802281:	c3                   	ret    

00802282 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802288:	8b 45 08             	mov    0x8(%ebp),%eax
  80228b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80228e:	6a 01                	push   $0x1
  802290:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802293:	50                   	push   %eax
  802294:	e8 0b e8 ff ff       	call   800aa4 <sys_cputs>
}
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <getchar>:

int
getchar(void)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022a4:	6a 01                	push   $0x1
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	50                   	push   %eax
  8022aa:	6a 00                	push   $0x0
  8022ac:	e8 ae f0 ff ff       	call   80135f <read>
	if (r < 0)
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	78 0f                	js     8022c7 <getchar+0x29>
		return r;
	if (r < 1)
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	7e 06                	jle    8022c2 <getchar+0x24>
		return -E_EOF;
	return c;
  8022bc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022c0:	eb 05                	jmp    8022c7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022c2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d2:	50                   	push   %eax
  8022d3:	ff 75 08             	pushl  0x8(%ebp)
  8022d6:	e8 1e ee ff ff       	call   8010f9 <fd_lookup>
  8022db:	83 c4 10             	add    $0x10,%esp
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	78 11                	js     8022f3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022eb:	39 10                	cmp    %edx,(%eax)
  8022ed:	0f 94 c0             	sete   %al
  8022f0:	0f b6 c0             	movzbl %al,%eax
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <opencons>:

int
opencons(void)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fe:	50                   	push   %eax
  8022ff:	e8 a6 ed ff ff       	call   8010aa <fd_alloc>
  802304:	83 c4 10             	add    $0x10,%esp
		return r;
  802307:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802309:	85 c0                	test   %eax,%eax
  80230b:	78 3e                	js     80234b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80230d:	83 ec 04             	sub    $0x4,%esp
  802310:	68 07 04 00 00       	push   $0x407
  802315:	ff 75 f4             	pushl  -0xc(%ebp)
  802318:	6a 00                	push   $0x0
  80231a:	e8 41 e8 ff ff       	call   800b60 <sys_page_alloc>
  80231f:	83 c4 10             	add    $0x10,%esp
		return r;
  802322:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802324:	85 c0                	test   %eax,%eax
  802326:	78 23                	js     80234b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802328:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80232e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802331:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802336:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80233d:	83 ec 0c             	sub    $0xc,%esp
  802340:	50                   	push   %eax
  802341:	e8 3d ed ff ff       	call   801083 <fd2num>
  802346:	89 c2                	mov    %eax,%edx
  802348:	83 c4 10             	add    $0x10,%esp
}
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	c9                   	leave  
  80234e:	c3                   	ret    

0080234f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802355:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80235c:	75 2a                	jne    802388 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80235e:	83 ec 04             	sub    $0x4,%esp
  802361:	6a 07                	push   $0x7
  802363:	68 00 f0 bf ee       	push   $0xeebff000
  802368:	6a 00                	push   $0x0
  80236a:	e8 f1 e7 ff ff       	call   800b60 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	85 c0                	test   %eax,%eax
  802374:	79 12                	jns    802388 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802376:	50                   	push   %eax
  802377:	68 a7 2d 80 00       	push   $0x802da7
  80237c:	6a 23                	push   $0x23
  80237e:	68 ab 2d 80 00       	push   $0x802dab
  802383:	e8 77 dd ff ff       	call   8000ff <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802388:	8b 45 08             	mov    0x8(%ebp),%eax
  80238b:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802390:	83 ec 08             	sub    $0x8,%esp
  802393:	68 ba 23 80 00       	push   $0x8023ba
  802398:	6a 00                	push   $0x0
  80239a:	e8 0c e9 ff ff       	call   800cab <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80239f:	83 c4 10             	add    $0x10,%esp
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	79 12                	jns    8023b8 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8023a6:	50                   	push   %eax
  8023a7:	68 a7 2d 80 00       	push   $0x802da7
  8023ac:	6a 2c                	push   $0x2c
  8023ae:	68 ab 2d 80 00       	push   $0x802dab
  8023b3:	e8 47 dd ff ff       	call   8000ff <_panic>
	}
}
  8023b8:	c9                   	leave  
  8023b9:	c3                   	ret    

008023ba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023ba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023bb:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023c0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023c2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8023c5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8023c9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8023ce:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8023d2:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8023d4:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8023d7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8023d8:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8023db:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8023dc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023dd:	c3                   	ret    

008023de <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023de:	55                   	push   %ebp
  8023df:	89 e5                	mov    %esp,%ebp
  8023e1:	56                   	push   %esi
  8023e2:	53                   	push   %ebx
  8023e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8023e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	75 12                	jne    802402 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8023f0:	83 ec 0c             	sub    $0xc,%esp
  8023f3:	68 00 00 c0 ee       	push   $0xeec00000
  8023f8:	e8 13 e9 ff ff       	call   800d10 <sys_ipc_recv>
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	eb 0c                	jmp    80240e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802402:	83 ec 0c             	sub    $0xc,%esp
  802405:	50                   	push   %eax
  802406:	e8 05 e9 ff ff       	call   800d10 <sys_ipc_recv>
  80240b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80240e:	85 f6                	test   %esi,%esi
  802410:	0f 95 c1             	setne  %cl
  802413:	85 db                	test   %ebx,%ebx
  802415:	0f 95 c2             	setne  %dl
  802418:	84 d1                	test   %dl,%cl
  80241a:	74 09                	je     802425 <ipc_recv+0x47>
  80241c:	89 c2                	mov    %eax,%edx
  80241e:	c1 ea 1f             	shr    $0x1f,%edx
  802421:	84 d2                	test   %dl,%dl
  802423:	75 2a                	jne    80244f <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802425:	85 f6                	test   %esi,%esi
  802427:	74 0d                	je     802436 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802429:	a1 04 40 80 00       	mov    0x804004,%eax
  80242e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802434:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802436:	85 db                	test   %ebx,%ebx
  802438:	74 0d                	je     802447 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80243a:	a1 04 40 80 00       	mov    0x804004,%eax
  80243f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802445:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802447:	a1 04 40 80 00       	mov    0x804004,%eax
  80244c:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  80244f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802452:	5b                   	pop    %ebx
  802453:	5e                   	pop    %esi
  802454:	5d                   	pop    %ebp
  802455:	c3                   	ret    

00802456 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	57                   	push   %edi
  80245a:	56                   	push   %esi
  80245b:	53                   	push   %ebx
  80245c:	83 ec 0c             	sub    $0xc,%esp
  80245f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802462:	8b 75 0c             	mov    0xc(%ebp),%esi
  802465:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802468:	85 db                	test   %ebx,%ebx
  80246a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80246f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802472:	ff 75 14             	pushl  0x14(%ebp)
  802475:	53                   	push   %ebx
  802476:	56                   	push   %esi
  802477:	57                   	push   %edi
  802478:	e8 70 e8 ff ff       	call   800ced <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80247d:	89 c2                	mov    %eax,%edx
  80247f:	c1 ea 1f             	shr    $0x1f,%edx
  802482:	83 c4 10             	add    $0x10,%esp
  802485:	84 d2                	test   %dl,%dl
  802487:	74 17                	je     8024a0 <ipc_send+0x4a>
  802489:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80248c:	74 12                	je     8024a0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80248e:	50                   	push   %eax
  80248f:	68 b9 2d 80 00       	push   $0x802db9
  802494:	6a 47                	push   $0x47
  802496:	68 c7 2d 80 00       	push   $0x802dc7
  80249b:	e8 5f dc ff ff       	call   8000ff <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8024a0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024a3:	75 07                	jne    8024ac <ipc_send+0x56>
			sys_yield();
  8024a5:	e8 97 e6 ff ff       	call   800b41 <sys_yield>
  8024aa:	eb c6                	jmp    802472 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	75 c2                	jne    802472 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8024b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    

008024b8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
  8024bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024be:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024c3:	89 c2                	mov    %eax,%edx
  8024c5:	c1 e2 07             	shl    $0x7,%edx
  8024c8:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8024cf:	8b 52 5c             	mov    0x5c(%edx),%edx
  8024d2:	39 ca                	cmp    %ecx,%edx
  8024d4:	75 11                	jne    8024e7 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8024d6:	89 c2                	mov    %eax,%edx
  8024d8:	c1 e2 07             	shl    $0x7,%edx
  8024db:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8024e2:	8b 40 54             	mov    0x54(%eax),%eax
  8024e5:	eb 0f                	jmp    8024f6 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024e7:	83 c0 01             	add    $0x1,%eax
  8024ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024ef:	75 d2                	jne    8024c3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    

008024f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024fe:	89 d0                	mov    %edx,%eax
  802500:	c1 e8 16             	shr    $0x16,%eax
  802503:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80250a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80250f:	f6 c1 01             	test   $0x1,%cl
  802512:	74 1d                	je     802531 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802514:	c1 ea 0c             	shr    $0xc,%edx
  802517:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80251e:	f6 c2 01             	test   $0x1,%dl
  802521:	74 0e                	je     802531 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802523:	c1 ea 0c             	shr    $0xc,%edx
  802526:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80252d:	ef 
  80252e:	0f b7 c0             	movzwl %ax,%eax
}
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
  802533:	66 90                	xchg   %ax,%ax
  802535:	66 90                	xchg   %ax,%ax
  802537:	66 90                	xchg   %ax,%ax
  802539:	66 90                	xchg   %ax,%ax
  80253b:	66 90                	xchg   %ax,%ax
  80253d:	66 90                	xchg   %ax,%ax
  80253f:	90                   	nop

00802540 <__udivdi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80254b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80254f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 f6                	test   %esi,%esi
  802559:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80255d:	89 ca                	mov    %ecx,%edx
  80255f:	89 f8                	mov    %edi,%eax
  802561:	75 3d                	jne    8025a0 <__udivdi3+0x60>
  802563:	39 cf                	cmp    %ecx,%edi
  802565:	0f 87 c5 00 00 00    	ja     802630 <__udivdi3+0xf0>
  80256b:	85 ff                	test   %edi,%edi
  80256d:	89 fd                	mov    %edi,%ebp
  80256f:	75 0b                	jne    80257c <__udivdi3+0x3c>
  802571:	b8 01 00 00 00       	mov    $0x1,%eax
  802576:	31 d2                	xor    %edx,%edx
  802578:	f7 f7                	div    %edi
  80257a:	89 c5                	mov    %eax,%ebp
  80257c:	89 c8                	mov    %ecx,%eax
  80257e:	31 d2                	xor    %edx,%edx
  802580:	f7 f5                	div    %ebp
  802582:	89 c1                	mov    %eax,%ecx
  802584:	89 d8                	mov    %ebx,%eax
  802586:	89 cf                	mov    %ecx,%edi
  802588:	f7 f5                	div    %ebp
  80258a:	89 c3                	mov    %eax,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	39 ce                	cmp    %ecx,%esi
  8025a2:	77 74                	ja     802618 <__udivdi3+0xd8>
  8025a4:	0f bd fe             	bsr    %esi,%edi
  8025a7:	83 f7 1f             	xor    $0x1f,%edi
  8025aa:	0f 84 98 00 00 00    	je     802648 <__udivdi3+0x108>
  8025b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	89 c5                	mov    %eax,%ebp
  8025b9:	29 fb                	sub    %edi,%ebx
  8025bb:	d3 e6                	shl    %cl,%esi
  8025bd:	89 d9                	mov    %ebx,%ecx
  8025bf:	d3 ed                	shr    %cl,%ebp
  8025c1:	89 f9                	mov    %edi,%ecx
  8025c3:	d3 e0                	shl    %cl,%eax
  8025c5:	09 ee                	or     %ebp,%esi
  8025c7:	89 d9                	mov    %ebx,%ecx
  8025c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025cd:	89 d5                	mov    %edx,%ebp
  8025cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025d3:	d3 ed                	shr    %cl,%ebp
  8025d5:	89 f9                	mov    %edi,%ecx
  8025d7:	d3 e2                	shl    %cl,%edx
  8025d9:	89 d9                	mov    %ebx,%ecx
  8025db:	d3 e8                	shr    %cl,%eax
  8025dd:	09 c2                	or     %eax,%edx
  8025df:	89 d0                	mov    %edx,%eax
  8025e1:	89 ea                	mov    %ebp,%edx
  8025e3:	f7 f6                	div    %esi
  8025e5:	89 d5                	mov    %edx,%ebp
  8025e7:	89 c3                	mov    %eax,%ebx
  8025e9:	f7 64 24 0c          	mull   0xc(%esp)
  8025ed:	39 d5                	cmp    %edx,%ebp
  8025ef:	72 10                	jb     802601 <__udivdi3+0xc1>
  8025f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	d3 e6                	shl    %cl,%esi
  8025f9:	39 c6                	cmp    %eax,%esi
  8025fb:	73 07                	jae    802604 <__udivdi3+0xc4>
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	75 03                	jne    802604 <__udivdi3+0xc4>
  802601:	83 eb 01             	sub    $0x1,%ebx
  802604:	31 ff                	xor    %edi,%edi
  802606:	89 d8                	mov    %ebx,%eax
  802608:	89 fa                	mov    %edi,%edx
  80260a:	83 c4 1c             	add    $0x1c,%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5f                   	pop    %edi
  802610:	5d                   	pop    %ebp
  802611:	c3                   	ret    
  802612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802618:	31 ff                	xor    %edi,%edi
  80261a:	31 db                	xor    %ebx,%ebx
  80261c:	89 d8                	mov    %ebx,%eax
  80261e:	89 fa                	mov    %edi,%edx
  802620:	83 c4 1c             	add    $0x1c,%esp
  802623:	5b                   	pop    %ebx
  802624:	5e                   	pop    %esi
  802625:	5f                   	pop    %edi
  802626:	5d                   	pop    %ebp
  802627:	c3                   	ret    
  802628:	90                   	nop
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	89 d8                	mov    %ebx,%eax
  802632:	f7 f7                	div    %edi
  802634:	31 ff                	xor    %edi,%edi
  802636:	89 c3                	mov    %eax,%ebx
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	89 fa                	mov    %edi,%edx
  80263c:	83 c4 1c             	add    $0x1c,%esp
  80263f:	5b                   	pop    %ebx
  802640:	5e                   	pop    %esi
  802641:	5f                   	pop    %edi
  802642:	5d                   	pop    %ebp
  802643:	c3                   	ret    
  802644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802648:	39 ce                	cmp    %ecx,%esi
  80264a:	72 0c                	jb     802658 <__udivdi3+0x118>
  80264c:	31 db                	xor    %ebx,%ebx
  80264e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802652:	0f 87 34 ff ff ff    	ja     80258c <__udivdi3+0x4c>
  802658:	bb 01 00 00 00       	mov    $0x1,%ebx
  80265d:	e9 2a ff ff ff       	jmp    80258c <__udivdi3+0x4c>
  802662:	66 90                	xchg   %ax,%ax
  802664:	66 90                	xchg   %ax,%ax
  802666:	66 90                	xchg   %ax,%ax
  802668:	66 90                	xchg   %ax,%ax
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <__umoddi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	53                   	push   %ebx
  802674:	83 ec 1c             	sub    $0x1c,%esp
  802677:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80267b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80267f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802687:	85 d2                	test   %edx,%edx
  802689:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80268d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802691:	89 f3                	mov    %esi,%ebx
  802693:	89 3c 24             	mov    %edi,(%esp)
  802696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80269a:	75 1c                	jne    8026b8 <__umoddi3+0x48>
  80269c:	39 f7                	cmp    %esi,%edi
  80269e:	76 50                	jbe    8026f0 <__umoddi3+0x80>
  8026a0:	89 c8                	mov    %ecx,%eax
  8026a2:	89 f2                	mov    %esi,%edx
  8026a4:	f7 f7                	div    %edi
  8026a6:	89 d0                	mov    %edx,%eax
  8026a8:	31 d2                	xor    %edx,%edx
  8026aa:	83 c4 1c             	add    $0x1c,%esp
  8026ad:	5b                   	pop    %ebx
  8026ae:	5e                   	pop    %esi
  8026af:	5f                   	pop    %edi
  8026b0:	5d                   	pop    %ebp
  8026b1:	c3                   	ret    
  8026b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026b8:	39 f2                	cmp    %esi,%edx
  8026ba:	89 d0                	mov    %edx,%eax
  8026bc:	77 52                	ja     802710 <__umoddi3+0xa0>
  8026be:	0f bd ea             	bsr    %edx,%ebp
  8026c1:	83 f5 1f             	xor    $0x1f,%ebp
  8026c4:	75 5a                	jne    802720 <__umoddi3+0xb0>
  8026c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ca:	0f 82 e0 00 00 00    	jb     8027b0 <__umoddi3+0x140>
  8026d0:	39 0c 24             	cmp    %ecx,(%esp)
  8026d3:	0f 86 d7 00 00 00    	jbe    8027b0 <__umoddi3+0x140>
  8026d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026e1:	83 c4 1c             	add    $0x1c,%esp
  8026e4:	5b                   	pop    %ebx
  8026e5:	5e                   	pop    %esi
  8026e6:	5f                   	pop    %edi
  8026e7:	5d                   	pop    %ebp
  8026e8:	c3                   	ret    
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	85 ff                	test   %edi,%edi
  8026f2:	89 fd                	mov    %edi,%ebp
  8026f4:	75 0b                	jne    802701 <__umoddi3+0x91>
  8026f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026fb:	31 d2                	xor    %edx,%edx
  8026fd:	f7 f7                	div    %edi
  8026ff:	89 c5                	mov    %eax,%ebp
  802701:	89 f0                	mov    %esi,%eax
  802703:	31 d2                	xor    %edx,%edx
  802705:	f7 f5                	div    %ebp
  802707:	89 c8                	mov    %ecx,%eax
  802709:	f7 f5                	div    %ebp
  80270b:	89 d0                	mov    %edx,%eax
  80270d:	eb 99                	jmp    8026a8 <__umoddi3+0x38>
  80270f:	90                   	nop
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	83 c4 1c             	add    $0x1c,%esp
  802717:	5b                   	pop    %ebx
  802718:	5e                   	pop    %esi
  802719:	5f                   	pop    %edi
  80271a:	5d                   	pop    %ebp
  80271b:	c3                   	ret    
  80271c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802720:	8b 34 24             	mov    (%esp),%esi
  802723:	bf 20 00 00 00       	mov    $0x20,%edi
  802728:	89 e9                	mov    %ebp,%ecx
  80272a:	29 ef                	sub    %ebp,%edi
  80272c:	d3 e0                	shl    %cl,%eax
  80272e:	89 f9                	mov    %edi,%ecx
  802730:	89 f2                	mov    %esi,%edx
  802732:	d3 ea                	shr    %cl,%edx
  802734:	89 e9                	mov    %ebp,%ecx
  802736:	09 c2                	or     %eax,%edx
  802738:	89 d8                	mov    %ebx,%eax
  80273a:	89 14 24             	mov    %edx,(%esp)
  80273d:	89 f2                	mov    %esi,%edx
  80273f:	d3 e2                	shl    %cl,%edx
  802741:	89 f9                	mov    %edi,%ecx
  802743:	89 54 24 04          	mov    %edx,0x4(%esp)
  802747:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80274b:	d3 e8                	shr    %cl,%eax
  80274d:	89 e9                	mov    %ebp,%ecx
  80274f:	89 c6                	mov    %eax,%esi
  802751:	d3 e3                	shl    %cl,%ebx
  802753:	89 f9                	mov    %edi,%ecx
  802755:	89 d0                	mov    %edx,%eax
  802757:	d3 e8                	shr    %cl,%eax
  802759:	89 e9                	mov    %ebp,%ecx
  80275b:	09 d8                	or     %ebx,%eax
  80275d:	89 d3                	mov    %edx,%ebx
  80275f:	89 f2                	mov    %esi,%edx
  802761:	f7 34 24             	divl   (%esp)
  802764:	89 d6                	mov    %edx,%esi
  802766:	d3 e3                	shl    %cl,%ebx
  802768:	f7 64 24 04          	mull   0x4(%esp)
  80276c:	39 d6                	cmp    %edx,%esi
  80276e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802772:	89 d1                	mov    %edx,%ecx
  802774:	89 c3                	mov    %eax,%ebx
  802776:	72 08                	jb     802780 <__umoddi3+0x110>
  802778:	75 11                	jne    80278b <__umoddi3+0x11b>
  80277a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80277e:	73 0b                	jae    80278b <__umoddi3+0x11b>
  802780:	2b 44 24 04          	sub    0x4(%esp),%eax
  802784:	1b 14 24             	sbb    (%esp),%edx
  802787:	89 d1                	mov    %edx,%ecx
  802789:	89 c3                	mov    %eax,%ebx
  80278b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80278f:	29 da                	sub    %ebx,%edx
  802791:	19 ce                	sbb    %ecx,%esi
  802793:	89 f9                	mov    %edi,%ecx
  802795:	89 f0                	mov    %esi,%eax
  802797:	d3 e0                	shl    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	d3 ea                	shr    %cl,%edx
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	d3 ee                	shr    %cl,%esi
  8027a1:	09 d0                	or     %edx,%eax
  8027a3:	89 f2                	mov    %esi,%edx
  8027a5:	83 c4 1c             	add    $0x1c,%esp
  8027a8:	5b                   	pop    %ebx
  8027a9:	5e                   	pop    %esi
  8027aa:	5f                   	pop    %edi
  8027ab:	5d                   	pop    %ebp
  8027ac:	c3                   	ret    
  8027ad:	8d 76 00             	lea    0x0(%esi),%esi
  8027b0:	29 f9                	sub    %edi,%ecx
  8027b2:	19 d6                	sbb    %edx,%esi
  8027b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027bc:	e9 18 ff ff ff       	jmp    8026d9 <__umoddi3+0x69>
