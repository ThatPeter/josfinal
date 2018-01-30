
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 40 24 80 00       	push   $0x802440
  80004a:	e8 47 01 00 00       	call   800196 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 8c 0a 00 00       	call   800ae0 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 43 0a 00 00       	call   800a9f <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 fe 0c 00 00       	call   800d6f <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 50 0a 00 00       	call   800ae0 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80009b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a0:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 db                	test   %ebx,%ebx
  8000a7:	7e 07                	jle    8000b0 <libmain+0x30>
		binaryname = argv[0];
  8000a9:	8b 06                	mov    (%esi),%eax
  8000ab:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b0:	83 ec 08             	sub    $0x8,%esp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	e8 a7 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000ba:	e8 2a 00 00 00       	call   8000e9 <exit>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000cf:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  8000d4:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000d6:	e8 05 0a 00 00       	call   800ae0 <sys_getenvid>
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	50                   	push   %eax
  8000df:	e8 4b 0c 00 00       	call   800d2f <sys_thread_free>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ef:	e8 d2 13 00 00       	call   8014c6 <close_all>
	sys_env_destroy(0);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	6a 00                	push   $0x0
  8000f9:	e8 a1 09 00 00       	call   800a9f <sys_env_destroy>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	53                   	push   %ebx
  800107:	83 ec 04             	sub    $0x4,%esp
  80010a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010d:	8b 13                	mov    (%ebx),%edx
  80010f:	8d 42 01             	lea    0x1(%edx),%eax
  800112:	89 03                	mov    %eax,(%ebx)
  800114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800117:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800120:	75 1a                	jne    80013c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	68 ff 00 00 00       	push   $0xff
  80012a:	8d 43 08             	lea    0x8(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 2f 09 00 00       	call   800a62 <sys_cputs>
		b->idx = 0;
  800133:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800139:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800155:	00 00 00 
	b.cnt = 0;
  800158:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	68 03 01 80 00       	push   $0x800103
  800174:	e8 54 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 d4 08 00 00       	call   800a62 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	50                   	push   %eax
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	e8 9d ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 1c             	sub    $0x1c,%esp
  8001b3:	89 c7                	mov    %eax,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d1:	39 d3                	cmp    %edx,%ebx
  8001d3:	72 05                	jb     8001da <printnum+0x30>
  8001d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d8:	77 45                	ja     80021f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	ff 75 10             	pushl  0x10(%ebp)
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 a2 1f 00 00       	call   8021a0 <__udivdi3>
  8001fe:	83 c4 18             	add    $0x18,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	89 f2                	mov    %esi,%edx
  800205:	89 f8                	mov    %edi,%eax
  800207:	e8 9e ff ff ff       	call   8001aa <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 18                	jmp    800229 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	ff 75 18             	pushl  0x18(%ebp)
  800218:	ff d7                	call   *%edi
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	eb 03                	jmp    800222 <printnum+0x78>
  80021f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 eb 01             	sub    $0x1,%ebx
  800225:	85 db                	test   %ebx,%ebx
  800227:	7f e8                	jg     800211 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	56                   	push   %esi
  80022d:	83 ec 04             	sub    $0x4,%esp
  800230:	ff 75 e4             	pushl  -0x1c(%ebp)
  800233:	ff 75 e0             	pushl  -0x20(%ebp)
  800236:	ff 75 dc             	pushl  -0x24(%ebp)
  800239:	ff 75 d8             	pushl  -0x28(%ebp)
  80023c:	e8 8f 20 00 00       	call   8022d0 <__umoddi3>
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	0f be 80 66 24 80 00 	movsbl 0x802466(%eax),%eax
  80024b:	50                   	push   %eax
  80024c:	ff d7                	call   *%edi
}
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800254:	5b                   	pop    %ebx
  800255:	5e                   	pop    %esi
  800256:	5f                   	pop    %edi
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025c:	83 fa 01             	cmp    $0x1,%edx
  80025f:	7e 0e                	jle    80026f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 08             	lea    0x8(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	8b 52 04             	mov    0x4(%edx),%edx
  80026d:	eb 22                	jmp    800291 <getuint+0x38>
	else if (lflag)
  80026f:	85 d2                	test   %edx,%edx
  800271:	74 10                	je     800283 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 04             	lea    0x4(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	ba 00 00 00 00       	mov    $0x0,%edx
  800281:	eb 0e                	jmp    800291 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 04             	lea    0x4(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800299:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 0a                	jae    8002ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	88 02                	mov    %al,(%edx)
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b9:	50                   	push   %eax
  8002ba:	ff 75 10             	pushl  0x10(%ebp)
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	e8 05 00 00 00       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 2c             	sub    $0x2c,%esp
  8002d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002df:	eb 12                	jmp    8002f3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	0f 84 89 03 00 00    	je     800672 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	53                   	push   %ebx
  8002ed:	50                   	push   %eax
  8002ee:	ff d6                	call   *%esi
  8002f0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f3:	83 c7 01             	add    $0x1,%edi
  8002f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fa:	83 f8 25             	cmp    $0x25,%eax
  8002fd:	75 e2                	jne    8002e1 <vprintfmt+0x14>
  8002ff:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800303:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800311:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	eb 07                	jmp    800326 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800322:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8d 47 01             	lea    0x1(%edi),%eax
  800329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032c:	0f b6 07             	movzbl (%edi),%eax
  80032f:	0f b6 c8             	movzbl %al,%ecx
  800332:	83 e8 23             	sub    $0x23,%eax
  800335:	3c 55                	cmp    $0x55,%al
  800337:	0f 87 1a 03 00 00    	ja     800657 <vprintfmt+0x38a>
  80033d:	0f b6 c0             	movzbl %al,%eax
  800340:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034e:	eb d6                	jmp    800326 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	b8 00 00 00 00       	mov    $0x0,%eax
  800358:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800362:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800365:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800368:	83 fa 09             	cmp    $0x9,%edx
  80036b:	77 39                	ja     8003a6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800370:	eb e9                	jmp    80035b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 48 04             	lea    0x4(%eax),%ecx
  800378:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037b:	8b 00                	mov    (%eax),%eax
  80037d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800383:	eb 27                	jmp    8003ac <vprintfmt+0xdf>
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	85 c0                	test   %eax,%eax
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	0f 49 c8             	cmovns %eax,%ecx
  800392:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	eb 8c                	jmp    800326 <vprintfmt+0x59>
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a4:	eb 80                	jmp    800326 <vprintfmt+0x59>
  8003a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b0:	0f 89 70 ff ff ff    	jns    800326 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c3:	e9 5e ff ff ff       	jmp    800326 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ce:	e9 53 ff ff ff       	jmp    800326 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 50 04             	lea    0x4(%eax),%edx
  8003d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dc:	83 ec 08             	sub    $0x8,%esp
  8003df:	53                   	push   %ebx
  8003e0:	ff 30                	pushl  (%eax)
  8003e2:	ff d6                	call   *%esi
			break;
  8003e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ea:	e9 04 ff ff ff       	jmp    8002f3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	99                   	cltd   
  8003fb:	31 d0                	xor    %edx,%eax
  8003fd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 0f             	cmp    $0xf,%eax
  800402:	7f 0b                	jg     80040f <vprintfmt+0x142>
  800404:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80040b:	85 d2                	test   %edx,%edx
  80040d:	75 18                	jne    800427 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040f:	50                   	push   %eax
  800410:	68 7e 24 80 00       	push   $0x80247e
  800415:	53                   	push   %ebx
  800416:	56                   	push   %esi
  800417:	e8 94 fe ff ff       	call   8002b0 <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800422:	e9 cc fe ff ff       	jmp    8002f3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800427:	52                   	push   %edx
  800428:	68 c9 28 80 00       	push   $0x8028c9
  80042d:	53                   	push   %ebx
  80042e:	56                   	push   %esi
  80042f:	e8 7c fe ff ff       	call   8002b0 <printfmt>
  800434:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043a:	e9 b4 fe ff ff       	jmp    8002f3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044a:	85 ff                	test   %edi,%edi
  80044c:	b8 77 24 80 00       	mov    $0x802477,%eax
  800451:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	0f 8e 94 00 00 00    	jle    8004f2 <vprintfmt+0x225>
  80045e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800462:	0f 84 98 00 00 00    	je     800500 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 d0             	pushl  -0x30(%ebp)
  80046e:	57                   	push   %edi
  80046f:	e8 86 02 00 00       	call   8006fa <strnlen>
  800474:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800477:	29 c1                	sub    %eax,%ecx
  800479:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800489:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0f                	jmp    80049c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	53                   	push   %ebx
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	83 ef 01             	sub    $0x1,%edi
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 ff                	test   %edi,%edi
  80049e:	7f ed                	jg     80048d <vprintfmt+0x1c0>
  8004a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a6:	85 c9                	test   %ecx,%ecx
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	0f 49 c1             	cmovns %ecx,%eax
  8004b0:	29 c1                	sub    %eax,%ecx
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bb:	89 cb                	mov    %ecx,%ebx
  8004bd:	eb 4d                	jmp    80050c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c3:	74 1b                	je     8004e0 <vprintfmt+0x213>
  8004c5:	0f be c0             	movsbl %al,%eax
  8004c8:	83 e8 20             	sub    $0x20,%eax
  8004cb:	83 f8 5e             	cmp    $0x5e,%eax
  8004ce:	76 10                	jbe    8004e0 <vprintfmt+0x213>
					putch('?', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	6a 3f                	push   $0x3f
  8004d8:	ff 55 08             	call   *0x8(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb 0d                	jmp    8004ed <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	52                   	push   %edx
  8004e7:	ff 55 08             	call   *0x8(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 eb 01             	sub    $0x1,%ebx
  8004f0:	eb 1a                	jmp    80050c <vprintfmt+0x23f>
  8004f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fe:	eb 0c                	jmp    80050c <vprintfmt+0x23f>
  800500:	89 75 08             	mov    %esi,0x8(%ebp)
  800503:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800506:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800509:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050c:	83 c7 01             	add    $0x1,%edi
  80050f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800513:	0f be d0             	movsbl %al,%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	74 23                	je     80053d <vprintfmt+0x270>
  80051a:	85 f6                	test   %esi,%esi
  80051c:	78 a1                	js     8004bf <vprintfmt+0x1f2>
  80051e:	83 ee 01             	sub    $0x1,%esi
  800521:	79 9c                	jns    8004bf <vprintfmt+0x1f2>
  800523:	89 df                	mov    %ebx,%edi
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052b:	eb 18                	jmp    800545 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 08                	jmp    800545 <vprintfmt+0x278>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	85 ff                	test   %edi,%edi
  800547:	7f e4                	jg     80052d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054c:	e9 a2 fd ff ff       	jmp    8002f3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800551:	83 fa 01             	cmp    $0x1,%edx
  800554:	7e 16                	jle    80056c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 08             	lea    0x8(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 50 04             	mov    0x4(%eax),%edx
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056a:	eb 32                	jmp    80059e <vprintfmt+0x2d1>
	else if (lflag)
  80056c:	85 d2                	test   %edx,%edx
  80056e:	74 18                	je     800588 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 c1                	mov    %eax,%ecx
  800580:	c1 f9 1f             	sar    $0x1f,%ecx
  800583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800586:	eb 16                	jmp    80059e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	89 c1                	mov    %eax,%ecx
  800598:	c1 f9 1f             	sar    $0x1f,%ecx
  80059b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ad:	79 74                	jns    800623 <vprintfmt+0x356>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bd:	f7 d8                	neg    %eax
  8005bf:	83 d2 00             	adc    $0x0,%edx
  8005c2:	f7 da                	neg    %edx
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cc:	eb 55                	jmp    800623 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 83 fc ff ff       	call   800259 <getuint>
			base = 10;
  8005d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005db:	eb 46                	jmp    800623 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e0:	e8 74 fc ff ff       	call   800259 <getuint>
			base = 8;
  8005e5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ea:	eb 37                	jmp    800623 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 30                	push   $0x30
  8005f2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f4:	83 c4 08             	add    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 78                	push   $0x78
  8005fa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800614:	eb 0d                	jmp    800623 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 3b fc ff ff       	call   800259 <getuint>
			base = 16;
  80061e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800623:	83 ec 0c             	sub    $0xc,%esp
  800626:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062a:	57                   	push   %edi
  80062b:	ff 75 e0             	pushl  -0x20(%ebp)
  80062e:	51                   	push   %ecx
  80062f:	52                   	push   %edx
  800630:	50                   	push   %eax
  800631:	89 da                	mov    %ebx,%edx
  800633:	89 f0                	mov    %esi,%eax
  800635:	e8 70 fb ff ff       	call   8001aa <printnum>
			break;
  80063a:	83 c4 20             	add    $0x20,%esp
  80063d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800640:	e9 ae fc ff ff       	jmp    8002f3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	51                   	push   %ecx
  80064a:	ff d6                	call   *%esi
			break;
  80064c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800652:	e9 9c fc ff ff       	jmp    8002f3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 25                	push   $0x25
  80065d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	eb 03                	jmp    800667 <vprintfmt+0x39a>
  800664:	83 ef 01             	sub    $0x1,%edi
  800667:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066b:	75 f7                	jne    800664 <vprintfmt+0x397>
  80066d:	e9 81 fc ff ff       	jmp    8002f3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800675:	5b                   	pop    %ebx
  800676:	5e                   	pop    %esi
  800677:	5f                   	pop    %edi
  800678:	5d                   	pop    %ebp
  800679:	c3                   	ret    

0080067a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 18             	sub    $0x18,%esp
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800686:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800689:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800697:	85 c0                	test   %eax,%eax
  800699:	74 26                	je     8006c1 <vsnprintf+0x47>
  80069b:	85 d2                	test   %edx,%edx
  80069d:	7e 22                	jle    8006c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069f:	ff 75 14             	pushl  0x14(%ebp)
  8006a2:	ff 75 10             	pushl  0x10(%ebp)
  8006a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 93 02 80 00       	push   $0x800293
  8006ae:	e8 1a fc ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 05                	jmp    8006c6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d1:	50                   	push   %eax
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	ff 75 08             	pushl  0x8(%ebp)
  8006db:	e8 9a ff ff ff       	call   80067a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	eb 03                	jmp    8006f2 <strlen+0x10>
		n++;
  8006ef:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f6:	75 f7                	jne    8006ef <strlen+0xd>
		n++;
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	ba 00 00 00 00       	mov    $0x0,%edx
  800708:	eb 03                	jmp    80070d <strnlen+0x13>
		n++;
  80070a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	39 c2                	cmp    %eax,%edx
  80070f:	74 08                	je     800719 <strnlen+0x1f>
  800711:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800715:	75 f3                	jne    80070a <strnlen+0x10>
  800717:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800725:	89 c2                	mov    %eax,%edx
  800727:	83 c2 01             	add    $0x1,%edx
  80072a:	83 c1 01             	add    $0x1,%ecx
  80072d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800731:	88 5a ff             	mov    %bl,-0x1(%edx)
  800734:	84 db                	test   %bl,%bl
  800736:	75 ef                	jne    800727 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800738:	5b                   	pop    %ebx
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	53                   	push   %ebx
  800743:	e8 9a ff ff ff       	call   8006e2 <strlen>
  800748:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	01 d8                	add    %ebx,%eax
  800750:	50                   	push   %eax
  800751:	e8 c5 ff ff ff       	call   80071b <strcpy>
	return dst;
}
  800756:	89 d8                	mov    %ebx,%eax
  800758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	56                   	push   %esi
  800761:	53                   	push   %ebx
  800762:	8b 75 08             	mov    0x8(%ebp),%esi
  800765:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800768:	89 f3                	mov    %esi,%ebx
  80076a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076d:	89 f2                	mov    %esi,%edx
  80076f:	eb 0f                	jmp    800780 <strncpy+0x23>
		*dst++ = *src;
  800771:	83 c2 01             	add    $0x1,%edx
  800774:	0f b6 01             	movzbl (%ecx),%eax
  800777:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077a:	80 39 01             	cmpb   $0x1,(%ecx)
  80077d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800780:	39 da                	cmp    %ebx,%edx
  800782:	75 ed                	jne    800771 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800784:	89 f0                	mov    %esi,%eax
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800795:	8b 55 10             	mov    0x10(%ebp),%edx
  800798:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079a:	85 d2                	test   %edx,%edx
  80079c:	74 21                	je     8007bf <strlcpy+0x35>
  80079e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a2:	89 f2                	mov    %esi,%edx
  8007a4:	eb 09                	jmp    8007af <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007af:	39 c2                	cmp    %eax,%edx
  8007b1:	74 09                	je     8007bc <strlcpy+0x32>
  8007b3:	0f b6 19             	movzbl (%ecx),%ebx
  8007b6:	84 db                	test   %bl,%bl
  8007b8:	75 ec                	jne    8007a6 <strlcpy+0x1c>
  8007ba:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bf:	29 f0                	sub    %esi,%eax
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ce:	eb 06                	jmp    8007d6 <strcmp+0x11>
		p++, q++;
  8007d0:	83 c1 01             	add    $0x1,%ecx
  8007d3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d6:	0f b6 01             	movzbl (%ecx),%eax
  8007d9:	84 c0                	test   %al,%al
  8007db:	74 04                	je     8007e1 <strcmp+0x1c>
  8007dd:	3a 02                	cmp    (%edx),%al
  8007df:	74 ef                	je     8007d0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e1:	0f b6 c0             	movzbl %al,%eax
  8007e4:	0f b6 12             	movzbl (%edx),%edx
  8007e7:	29 d0                	sub    %edx,%eax
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 c3                	mov    %eax,%ebx
  8007f7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fa:	eb 06                	jmp    800802 <strncmp+0x17>
		n--, p++, q++;
  8007fc:	83 c0 01             	add    $0x1,%eax
  8007ff:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800802:	39 d8                	cmp    %ebx,%eax
  800804:	74 15                	je     80081b <strncmp+0x30>
  800806:	0f b6 08             	movzbl (%eax),%ecx
  800809:	84 c9                	test   %cl,%cl
  80080b:	74 04                	je     800811 <strncmp+0x26>
  80080d:	3a 0a                	cmp    (%edx),%cl
  80080f:	74 eb                	je     8007fc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800811:	0f b6 00             	movzbl (%eax),%eax
  800814:	0f b6 12             	movzbl (%edx),%edx
  800817:	29 d0                	sub    %edx,%eax
  800819:	eb 05                	jmp    800820 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082d:	eb 07                	jmp    800836 <strchr+0x13>
		if (*s == c)
  80082f:	38 ca                	cmp    %cl,%dl
  800831:	74 0f                	je     800842 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800833:	83 c0 01             	add    $0x1,%eax
  800836:	0f b6 10             	movzbl (%eax),%edx
  800839:	84 d2                	test   %dl,%dl
  80083b:	75 f2                	jne    80082f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084e:	eb 03                	jmp    800853 <strfind+0xf>
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800856:	38 ca                	cmp    %cl,%dl
  800858:	74 04                	je     80085e <strfind+0x1a>
  80085a:	84 d2                	test   %dl,%dl
  80085c:	75 f2                	jne    800850 <strfind+0xc>
			break;
	return (char *) s;
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	57                   	push   %edi
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 7d 08             	mov    0x8(%ebp),%edi
  800869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 36                	je     8008a6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800870:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800876:	75 28                	jne    8008a0 <memset+0x40>
  800878:	f6 c1 03             	test   $0x3,%cl
  80087b:	75 23                	jne    8008a0 <memset+0x40>
		c &= 0xFF;
  80087d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800881:	89 d3                	mov    %edx,%ebx
  800883:	c1 e3 08             	shl    $0x8,%ebx
  800886:	89 d6                	mov    %edx,%esi
  800888:	c1 e6 18             	shl    $0x18,%esi
  80088b:	89 d0                	mov    %edx,%eax
  80088d:	c1 e0 10             	shl    $0x10,%eax
  800890:	09 f0                	or     %esi,%eax
  800892:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800894:	89 d8                	mov    %ebx,%eax
  800896:	09 d0                	or     %edx,%eax
  800898:	c1 e9 02             	shr    $0x2,%ecx
  80089b:	fc                   	cld    
  80089c:	f3 ab                	rep stos %eax,%es:(%edi)
  80089e:	eb 06                	jmp    8008a6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	fc                   	cld    
  8008a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a6:	89 f8                	mov    %edi,%eax
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5f                   	pop    %edi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	57                   	push   %edi
  8008b1:	56                   	push   %esi
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bb:	39 c6                	cmp    %eax,%esi
  8008bd:	73 35                	jae    8008f4 <memmove+0x47>
  8008bf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c2:	39 d0                	cmp    %edx,%eax
  8008c4:	73 2e                	jae    8008f4 <memmove+0x47>
		s += n;
		d += n;
  8008c6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c9:	89 d6                	mov    %edx,%esi
  8008cb:	09 fe                	or     %edi,%esi
  8008cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d3:	75 13                	jne    8008e8 <memmove+0x3b>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 0e                	jne    8008e8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008da:	83 ef 04             	sub    $0x4,%edi
  8008dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e0:	c1 e9 02             	shr    $0x2,%ecx
  8008e3:	fd                   	std    
  8008e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e6:	eb 09                	jmp    8008f1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e8:	83 ef 01             	sub    $0x1,%edi
  8008eb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ee:	fd                   	std    
  8008ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f1:	fc                   	cld    
  8008f2:	eb 1d                	jmp    800911 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	09 c2                	or     %eax,%edx
  8008f8:	f6 c2 03             	test   $0x3,%dl
  8008fb:	75 0f                	jne    80090c <memmove+0x5f>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0a                	jne    80090c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	89 c7                	mov    %eax,%edi
  800907:	fc                   	cld    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 05                	jmp    800911 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090c:	89 c7                	mov    %eax,%edi
  80090e:	fc                   	cld    
  80090f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800918:	ff 75 10             	pushl  0x10(%ebp)
  80091b:	ff 75 0c             	pushl  0xc(%ebp)
  80091e:	ff 75 08             	pushl  0x8(%ebp)
  800921:	e8 87 ff ff ff       	call   8008ad <memmove>
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	89 c6                	mov    %eax,%esi
  800935:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800938:	eb 1a                	jmp    800954 <memcmp+0x2c>
		if (*s1 != *s2)
  80093a:	0f b6 08             	movzbl (%eax),%ecx
  80093d:	0f b6 1a             	movzbl (%edx),%ebx
  800940:	38 d9                	cmp    %bl,%cl
  800942:	74 0a                	je     80094e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800944:	0f b6 c1             	movzbl %cl,%eax
  800947:	0f b6 db             	movzbl %bl,%ebx
  80094a:	29 d8                	sub    %ebx,%eax
  80094c:	eb 0f                	jmp    80095d <memcmp+0x35>
		s1++, s2++;
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800954:	39 f0                	cmp    %esi,%eax
  800956:	75 e2                	jne    80093a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800968:	89 c1                	mov    %eax,%ecx
  80096a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	eb 0a                	jmp    80097d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800973:	0f b6 10             	movzbl (%eax),%edx
  800976:	39 da                	cmp    %ebx,%edx
  800978:	74 07                	je     800981 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	39 c8                	cmp    %ecx,%eax
  80097f:	72 f2                	jb     800973 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800981:	5b                   	pop    %ebx
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800990:	eb 03                	jmp    800995 <strtol+0x11>
		s++;
  800992:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800995:	0f b6 01             	movzbl (%ecx),%eax
  800998:	3c 20                	cmp    $0x20,%al
  80099a:	74 f6                	je     800992 <strtol+0xe>
  80099c:	3c 09                	cmp    $0x9,%al
  80099e:	74 f2                	je     800992 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a0:	3c 2b                	cmp    $0x2b,%al
  8009a2:	75 0a                	jne    8009ae <strtol+0x2a>
		s++;
  8009a4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ac:	eb 11                	jmp    8009bf <strtol+0x3b>
  8009ae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b3:	3c 2d                	cmp    $0x2d,%al
  8009b5:	75 08                	jne    8009bf <strtol+0x3b>
		s++, neg = 1;
  8009b7:	83 c1 01             	add    $0x1,%ecx
  8009ba:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c5:	75 15                	jne    8009dc <strtol+0x58>
  8009c7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ca:	75 10                	jne    8009dc <strtol+0x58>
  8009cc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d0:	75 7c                	jne    800a4e <strtol+0xca>
		s += 2, base = 16;
  8009d2:	83 c1 02             	add    $0x2,%ecx
  8009d5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009da:	eb 16                	jmp    8009f2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009dc:	85 db                	test   %ebx,%ebx
  8009de:	75 12                	jne    8009f2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 08                	jne    8009f2 <strtol+0x6e>
		s++, base = 8;
  8009ea:	83 c1 01             	add    $0x1,%ecx
  8009ed:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fa:	0f b6 11             	movzbl (%ecx),%edx
  8009fd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a00:	89 f3                	mov    %esi,%ebx
  800a02:	80 fb 09             	cmp    $0x9,%bl
  800a05:	77 08                	ja     800a0f <strtol+0x8b>
			dig = *s - '0';
  800a07:	0f be d2             	movsbl %dl,%edx
  800a0a:	83 ea 30             	sub    $0x30,%edx
  800a0d:	eb 22                	jmp    800a31 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	80 fb 19             	cmp    $0x19,%bl
  800a17:	77 08                	ja     800a21 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a19:	0f be d2             	movsbl %dl,%edx
  800a1c:	83 ea 57             	sub    $0x57,%edx
  800a1f:	eb 10                	jmp    800a31 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 19             	cmp    $0x19,%bl
  800a29:	77 16                	ja     800a41 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2b:	0f be d2             	movsbl %dl,%edx
  800a2e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a34:	7d 0b                	jge    800a41 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a36:	83 c1 01             	add    $0x1,%ecx
  800a39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3f:	eb b9                	jmp    8009fa <strtol+0x76>

	if (endptr)
  800a41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a45:	74 0d                	je     800a54 <strtol+0xd0>
		*endptr = (char *) s;
  800a47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4a:	89 0e                	mov    %ecx,(%esi)
  800a4c:	eb 06                	jmp    800a54 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4e:	85 db                	test   %ebx,%ebx
  800a50:	74 98                	je     8009ea <strtol+0x66>
  800a52:	eb 9e                	jmp    8009f2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	f7 da                	neg    %edx
  800a58:	85 ff                	test   %edi,%edi
  800a5a:	0f 45 c2             	cmovne %edx,%eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	89 c3                	mov    %eax,%ebx
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	89 c6                	mov    %eax,%esi
  800a79:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800a90:	89 d1                	mov    %edx,%ecx
  800a92:	89 d3                	mov    %edx,%ebx
  800a94:	89 d7                	mov    %edx,%edi
  800a96:	89 d6                	mov    %edx,%esi
  800a98:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aad:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	89 cb                	mov    %ecx,%ebx
  800ab7:	89 cf                	mov    %ecx,%edi
  800ab9:	89 ce                	mov    %ecx,%esi
  800abb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abd:	85 c0                	test   %eax,%eax
  800abf:	7e 17                	jle    800ad8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac1:	83 ec 0c             	sub    $0xc,%esp
  800ac4:	50                   	push   %eax
  800ac5:	6a 03                	push   $0x3
  800ac7:	68 5f 27 80 00       	push   $0x80275f
  800acc:	6a 23                	push   $0x23
  800ace:	68 7c 27 80 00       	push   $0x80277c
  800ad3:	e8 1f 15 00 00       	call   801ff7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	b8 02 00 00 00       	mov    $0x2,%eax
  800af0:	89 d1                	mov    %edx,%ecx
  800af2:	89 d3                	mov    %edx,%ebx
  800af4:	89 d7                	mov    %edx,%edi
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_yield>:

void
sys_yield(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	be 00 00 00 00       	mov    $0x0,%esi
  800b2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3a:	89 f7                	mov    %esi,%edi
  800b3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	7e 17                	jle    800b59 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	50                   	push   %eax
  800b46:	6a 04                	push   $0x4
  800b48:	68 5f 27 80 00       	push   $0x80275f
  800b4d:	6a 23                	push   $0x23
  800b4f:	68 7c 27 80 00       	push   $0x80277c
  800b54:	e8 9e 14 00 00       	call   801ff7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7e 17                	jle    800b9b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	50                   	push   %eax
  800b88:	6a 05                	push   $0x5
  800b8a:	68 5f 27 80 00       	push   $0x80275f
  800b8f:	6a 23                	push   $0x23
  800b91:	68 7c 27 80 00       	push   $0x80277c
  800b96:	e8 5c 14 00 00       	call   801ff7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800bac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	89 df                	mov    %ebx,%edi
  800bbe:	89 de                	mov    %ebx,%esi
  800bc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7e 17                	jle    800bdd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 06                	push   $0x6
  800bcc:	68 5f 27 80 00       	push   $0x80275f
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 7c 27 80 00       	push   $0x80277c
  800bd8:	e8 1a 14 00 00       	call   801ff7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800bf3:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c06:	7e 17                	jle    800c1f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	50                   	push   %eax
  800c0c:	6a 08                	push   $0x8
  800c0e:	68 5f 27 80 00       	push   $0x80275f
  800c13:	6a 23                	push   $0x23
  800c15:	68 7c 27 80 00       	push   $0x80277c
  800c1a:	e8 d8 13 00 00       	call   801ff7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c35:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800c48:	7e 17                	jle    800c61 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 09                	push   $0x9
  800c50:	68 5f 27 80 00       	push   $0x80275f
  800c55:	6a 23                	push   $0x23
  800c57:	68 7c 27 80 00       	push   $0x80277c
  800c5c:	e8 96 13 00 00       	call   801ff7 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c77:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c8a:	7e 17                	jle    800ca3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 0a                	push   $0xa
  800c92:	68 5f 27 80 00       	push   $0x80275f
  800c97:	6a 23                	push   $0x23
  800c99:	68 7c 27 80 00       	push   $0x80277c
  800c9e:	e8 54 13 00 00       	call   801ff7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 cb                	mov    %ecx,%ebx
  800ce6:	89 cf                	mov    %ecx,%edi
  800ce8:	89 ce                	mov    %ecx,%esi
  800cea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 17                	jle    800d07 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	50                   	push   %eax
  800cf4:	6a 0d                	push   $0xd
  800cf6:	68 5f 27 80 00       	push   $0x80275f
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 7c 27 80 00       	push   $0x80277c
  800d02:	e8 f0 12 00 00       	call   801ff7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5a:	b8 10 00 00 00       	mov    $0x10,%eax
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 cb                	mov    %ecx,%ebx
  800d64:	89 cf                	mov    %ecx,%edi
  800d66:	89 ce                	mov    %ecx,%esi
  800d68:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d75:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d7c:	75 2a                	jne    800da8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	6a 07                	push   $0x7
  800d83:	68 00 f0 bf ee       	push   $0xeebff000
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 8f fd ff ff       	call   800b1e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	79 12                	jns    800da8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800d96:	50                   	push   %eax
  800d97:	68 20 28 80 00       	push   $0x802820
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 8a 27 80 00       	push   $0x80278a
  800da3:	e8 4f 12 00 00       	call   801ff7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800db0:	83 ec 08             	sub    $0x8,%esp
  800db3:	68 da 0d 80 00       	push   $0x800dda
  800db8:	6a 00                	push   $0x0
  800dba:	e8 aa fe ff ff       	call   800c69 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	79 12                	jns    800dd8 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800dc6:	50                   	push   %eax
  800dc7:	68 20 28 80 00       	push   $0x802820
  800dcc:	6a 2c                	push   $0x2c
  800dce:	68 8a 27 80 00       	push   $0x80278a
  800dd3:	e8 1f 12 00 00       	call   801ff7 <_panic>
	}
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dda:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ddb:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800de0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800de5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800de9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800dee:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800df2:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800df4:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800df7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800df8:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800dfb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800dfc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dfd:	c3                   	ret    

00800dfe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	53                   	push   %ebx
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e08:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e0a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0e:	74 11                	je     800e21 <pgfault+0x23>
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	c1 e8 0c             	shr    $0xc,%eax
  800e15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1c:	f6 c4 08             	test   $0x8,%ah
  800e1f:	75 14                	jne    800e35 <pgfault+0x37>
		panic("faulting access");
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	68 98 27 80 00       	push   $0x802798
  800e29:	6a 1f                	push   $0x1f
  800e2b:	68 a8 27 80 00       	push   $0x8027a8
  800e30:	e8 c2 11 00 00       	call   801ff7 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e35:	83 ec 04             	sub    $0x4,%esp
  800e38:	6a 07                	push   $0x7
  800e3a:	68 00 f0 7f 00       	push   $0x7ff000
  800e3f:	6a 00                	push   $0x0
  800e41:	e8 d8 fc ff ff       	call   800b1e <sys_page_alloc>
	if (r < 0) {
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	79 12                	jns    800e5f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e4d:	50                   	push   %eax
  800e4e:	68 b3 27 80 00       	push   $0x8027b3
  800e53:	6a 2d                	push   $0x2d
  800e55:	68 a8 27 80 00       	push   $0x8027a8
  800e5a:	e8 98 11 00 00       	call   801ff7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e5f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	68 00 10 00 00       	push   $0x1000
  800e6d:	53                   	push   %ebx
  800e6e:	68 00 f0 7f 00       	push   $0x7ff000
  800e73:	e8 9d fa ff ff       	call   800915 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e78:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7f:	53                   	push   %ebx
  800e80:	6a 00                	push   $0x0
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	6a 00                	push   $0x0
  800e89:	e8 d3 fc ff ff       	call   800b61 <sys_page_map>
	if (r < 0) {
  800e8e:	83 c4 20             	add    $0x20,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	79 12                	jns    800ea7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e95:	50                   	push   %eax
  800e96:	68 b3 27 80 00       	push   $0x8027b3
  800e9b:	6a 34                	push   $0x34
  800e9d:	68 a8 27 80 00       	push   $0x8027a8
  800ea2:	e8 50 11 00 00       	call   801ff7 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	68 00 f0 7f 00       	push   $0x7ff000
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 ed fc ff ff       	call   800ba3 <sys_page_unmap>
	if (r < 0) {
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	79 12                	jns    800ecf <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ebd:	50                   	push   %eax
  800ebe:	68 b3 27 80 00       	push   $0x8027b3
  800ec3:	6a 38                	push   $0x38
  800ec5:	68 a8 27 80 00       	push   $0x8027a8
  800eca:	e8 28 11 00 00       	call   801ff7 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ecf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800edd:	68 fe 0d 80 00       	push   $0x800dfe
  800ee2:	e8 88 fe ff ff       	call   800d6f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee7:	b8 07 00 00 00       	mov    $0x7,%eax
  800eec:	cd 30                	int    $0x30
  800eee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	79 17                	jns    800f0f <fork+0x3b>
		panic("fork fault %e");
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	68 cc 27 80 00       	push   $0x8027cc
  800f00:	68 85 00 00 00       	push   $0x85
  800f05:	68 a8 27 80 00       	push   $0x8027a8
  800f0a:	e8 e8 10 00 00       	call   801ff7 <_panic>
  800f0f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f11:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f15:	75 24                	jne    800f3b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f17:	e8 c4 fb ff ff       	call   800ae0 <sys_getenvid>
  800f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f21:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800f27:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f2c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	e9 64 01 00 00       	jmp    80109f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	6a 07                	push   $0x7
  800f40:	68 00 f0 bf ee       	push   $0xeebff000
  800f45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f48:	e8 d1 fb ff ff       	call   800b1e <sys_page_alloc>
  800f4d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f55:	89 d8                	mov    %ebx,%eax
  800f57:	c1 e8 16             	shr    $0x16,%eax
  800f5a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f61:	a8 01                	test   $0x1,%al
  800f63:	0f 84 fc 00 00 00    	je     801065 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	c1 e8 0c             	shr    $0xc,%eax
  800f6e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	0f 84 e7 00 00 00    	je     801065 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f7e:	89 c6                	mov    %eax,%esi
  800f80:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f83:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8a:	f6 c6 04             	test   $0x4,%dh
  800f8d:	74 39                	je     800fc8 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9e:	50                   	push   %eax
  800f9f:	56                   	push   %esi
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	6a 00                	push   $0x0
  800fa4:	e8 b8 fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	0f 89 b1 00 00 00    	jns    801065 <fork+0x191>
		    	panic("sys page map fault %e");
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 da 27 80 00       	push   $0x8027da
  800fbc:	6a 55                	push   $0x55
  800fbe:	68 a8 27 80 00       	push   $0x8027a8
  800fc3:	e8 2f 10 00 00       	call   801ff7 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fc8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcf:	f6 c2 02             	test   $0x2,%dl
  800fd2:	75 0c                	jne    800fe0 <fork+0x10c>
  800fd4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdb:	f6 c4 08             	test   $0x8,%ah
  800fde:	74 5b                	je     80103b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	68 05 08 00 00       	push   $0x805
  800fe8:	56                   	push   %esi
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	6a 00                	push   $0x0
  800fed:	e8 6f fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 14                	jns    80100d <fork+0x139>
		    	panic("sys page map fault %e");
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	68 da 27 80 00       	push   $0x8027da
  801001:	6a 5c                	push   $0x5c
  801003:	68 a8 27 80 00       	push   $0x8027a8
  801008:	e8 ea 0f 00 00       	call   801ff7 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	68 05 08 00 00       	push   $0x805
  801015:	56                   	push   %esi
  801016:	6a 00                	push   $0x0
  801018:	56                   	push   %esi
  801019:	6a 00                	push   $0x0
  80101b:	e8 41 fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  801020:	83 c4 20             	add    $0x20,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	79 3e                	jns    801065 <fork+0x191>
		    	panic("sys page map fault %e");
  801027:	83 ec 04             	sub    $0x4,%esp
  80102a:	68 da 27 80 00       	push   $0x8027da
  80102f:	6a 60                	push   $0x60
  801031:	68 a8 27 80 00       	push   $0x8027a8
  801036:	e8 bc 0f 00 00       	call   801ff7 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	6a 05                	push   $0x5
  801040:	56                   	push   %esi
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	6a 00                	push   $0x0
  801045:	e8 17 fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  80104a:	83 c4 20             	add    $0x20,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	79 14                	jns    801065 <fork+0x191>
		    	panic("sys page map fault %e");
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	68 da 27 80 00       	push   $0x8027da
  801059:	6a 65                	push   $0x65
  80105b:	68 a8 27 80 00       	push   $0x8027a8
  801060:	e8 92 0f 00 00       	call   801ff7 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801065:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80106b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801071:	0f 85 de fe ff ff    	jne    800f55 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801077:	a1 04 40 80 00       	mov    0x804004,%eax
  80107c:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	50                   	push   %eax
  801086:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801089:	57                   	push   %edi
  80108a:	e8 da fb ff ff       	call   800c69 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80108f:	83 c4 08             	add    $0x8,%esp
  801092:	6a 02                	push   $0x2
  801094:	57                   	push   %edi
  801095:	e8 4b fb ff ff       	call   800be5 <sys_env_set_status>
	
	return envid;
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80109f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5e                   	pop    %esi
  8010a4:	5f                   	pop    %edi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <sfork>:

envid_t
sfork(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	a3 0c 40 80 00       	mov    %eax,0x80400c
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010bf:	68 c9 00 80 00       	push   $0x8000c9
  8010c4:	e8 46 fc ff ff       	call   800d0f <sys_thread_create>

	return id;
}
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010d1:	ff 75 08             	pushl  0x8(%ebp)
  8010d4:	e8 56 fc ff ff       	call   800d2f <sys_thread_free>
}
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010e4:	ff 75 08             	pushl  0x8(%ebp)
  8010e7:	e8 63 fc ff ff       	call   800d4f <sys_thread_join>
}
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	6a 07                	push   $0x7
  801101:	6a 00                	push   $0x0
  801103:	56                   	push   %esi
  801104:	e8 15 fa ff ff       	call   800b1e <sys_page_alloc>
	if (r < 0) {
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	79 15                	jns    801125 <queue_append+0x34>
		panic("%e\n", r);
  801110:	50                   	push   %eax
  801111:	68 20 28 80 00       	push   $0x802820
  801116:	68 d5 00 00 00       	push   $0xd5
  80111b:	68 a8 27 80 00       	push   $0x8027a8
  801120:	e8 d2 0e 00 00       	call   801ff7 <_panic>
	}	

	wt->envid = envid;
  801125:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80112b:	83 3b 00             	cmpl   $0x0,(%ebx)
  80112e:	75 13                	jne    801143 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801130:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801137:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80113e:	00 00 00 
  801141:	eb 1b                	jmp    80115e <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801143:	8b 43 04             	mov    0x4(%ebx),%eax
  801146:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80114d:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801154:	00 00 00 
		queue->last = wt;
  801157:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80115e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80116e:	8b 02                	mov    (%edx),%eax
  801170:	85 c0                	test   %eax,%eax
  801172:	75 17                	jne    80118b <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	68 f0 27 80 00       	push   $0x8027f0
  80117c:	68 ec 00 00 00       	push   $0xec
  801181:	68 a8 27 80 00       	push   $0x8027a8
  801186:	e8 6c 0e 00 00       	call   801ff7 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80118b:	8b 48 04             	mov    0x4(%eax),%ecx
  80118e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801190:	8b 00                	mov    (%eax),%eax
}
  801192:	c9                   	leave  
  801193:	c3                   	ret    

00801194 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	53                   	push   %ebx
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80119e:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a3:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	74 45                	je     8011ef <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8011aa:	e8 31 f9 ff ff       	call   800ae0 <sys_getenvid>
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	83 c3 04             	add    $0x4,%ebx
  8011b5:	53                   	push   %ebx
  8011b6:	50                   	push   %eax
  8011b7:	e8 35 ff ff ff       	call   8010f1 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011bc:	e8 1f f9 ff ff       	call   800ae0 <sys_getenvid>
  8011c1:	83 c4 08             	add    $0x8,%esp
  8011c4:	6a 04                	push   $0x4
  8011c6:	50                   	push   %eax
  8011c7:	e8 19 fa ff ff       	call   800be5 <sys_env_set_status>

		if (r < 0) {
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	79 15                	jns    8011e8 <mutex_lock+0x54>
			panic("%e\n", r);
  8011d3:	50                   	push   %eax
  8011d4:	68 20 28 80 00       	push   $0x802820
  8011d9:	68 02 01 00 00       	push   $0x102
  8011de:	68 a8 27 80 00       	push   $0x8027a8
  8011e3:	e8 0f 0e 00 00       	call   801ff7 <_panic>
		}
		sys_yield();
  8011e8:	e8 12 f9 ff ff       	call   800aff <sys_yield>
  8011ed:	eb 08                	jmp    8011f7 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8011ef:	e8 ec f8 ff ff       	call   800ae0 <sys_getenvid>
  8011f4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8011f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	53                   	push   %ebx
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801206:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80120a:	74 36                	je     801242 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	8d 43 04             	lea    0x4(%ebx),%eax
  801212:	50                   	push   %eax
  801213:	e8 4d ff ff ff       	call   801165 <queue_pop>
  801218:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	6a 02                	push   $0x2
  801220:	50                   	push   %eax
  801221:	e8 bf f9 ff ff       	call   800be5 <sys_env_set_status>
		if (r < 0) {
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	79 1d                	jns    80124a <mutex_unlock+0x4e>
			panic("%e\n", r);
  80122d:	50                   	push   %eax
  80122e:	68 20 28 80 00       	push   $0x802820
  801233:	68 16 01 00 00       	push   $0x116
  801238:	68 a8 27 80 00       	push   $0x8027a8
  80123d:	e8 b5 0d 00 00       	call   801ff7 <_panic>
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
  801247:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80124a:	e8 b0 f8 ff ff       	call   800aff <sys_yield>
}
  80124f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	53                   	push   %ebx
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80125e:	e8 7d f8 ff ff       	call   800ae0 <sys_getenvid>
  801263:	83 ec 04             	sub    $0x4,%esp
  801266:	6a 07                	push   $0x7
  801268:	53                   	push   %ebx
  801269:	50                   	push   %eax
  80126a:	e8 af f8 ff ff       	call   800b1e <sys_page_alloc>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	79 15                	jns    80128b <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801276:	50                   	push   %eax
  801277:	68 0b 28 80 00       	push   $0x80280b
  80127c:	68 23 01 00 00       	push   $0x123
  801281:	68 a8 27 80 00       	push   $0x8027a8
  801286:	e8 6c 0d 00 00       	call   801ff7 <_panic>
	}	
	mtx->locked = 0;
  80128b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801291:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801298:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80129f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8012a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
  8012b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012b3:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012b6:	eb 20                	jmp    8012d8 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012b8:	83 ec 0c             	sub    $0xc,%esp
  8012bb:	56                   	push   %esi
  8012bc:	e8 a4 fe ff ff       	call   801165 <queue_pop>
  8012c1:	83 c4 08             	add    $0x8,%esp
  8012c4:	6a 02                	push   $0x2
  8012c6:	50                   	push   %eax
  8012c7:	e8 19 f9 ff ff       	call   800be5 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8012cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8012cf:	8b 40 04             	mov    0x4(%eax),%eax
  8012d2:	89 43 04             	mov    %eax,0x4(%ebx)
  8012d5:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012d8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012dc:	75 da                	jne    8012b8 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	68 00 10 00 00       	push   $0x1000
  8012e6:	6a 00                	push   $0x0
  8012e8:	53                   	push   %ebx
  8012e9:	e8 72 f5 ff ff       	call   800860 <memset>
	mtx = NULL;
}
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801303:	c1 e8 0c             	shr    $0xc,%eax
}
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
  80130e:	05 00 00 00 30       	add    $0x30000000,%eax
  801313:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801318:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801325:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	c1 ea 16             	shr    $0x16,%edx
  80132f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801336:	f6 c2 01             	test   $0x1,%dl
  801339:	74 11                	je     80134c <fd_alloc+0x2d>
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	c1 ea 0c             	shr    $0xc,%edx
  801340:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801347:	f6 c2 01             	test   $0x1,%dl
  80134a:	75 09                	jne    801355 <fd_alloc+0x36>
			*fd_store = fd;
  80134c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80134e:	b8 00 00 00 00       	mov    $0x0,%eax
  801353:	eb 17                	jmp    80136c <fd_alloc+0x4d>
  801355:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80135a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80135f:	75 c9                	jne    80132a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801361:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801367:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    

0080136e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801374:	83 f8 1f             	cmp    $0x1f,%eax
  801377:	77 36                	ja     8013af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801379:	c1 e0 0c             	shl    $0xc,%eax
  80137c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801381:	89 c2                	mov    %eax,%edx
  801383:	c1 ea 16             	shr    $0x16,%edx
  801386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 24                	je     8013b6 <fd_lookup+0x48>
  801392:	89 c2                	mov    %eax,%edx
  801394:	c1 ea 0c             	shr    $0xc,%edx
  801397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80139e:	f6 c2 01             	test   $0x1,%dl
  8013a1:	74 1a                	je     8013bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8013a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ad:	eb 13                	jmp    8013c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b4:	eb 0c                	jmp    8013c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bb:	eb 05                	jmp    8013c2 <fd_lookup+0x54>
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cd:	ba a0 28 80 00       	mov    $0x8028a0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013d2:	eb 13                	jmp    8013e7 <dev_lookup+0x23>
  8013d4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013d7:	39 08                	cmp    %ecx,(%eax)
  8013d9:	75 0c                	jne    8013e7 <dev_lookup+0x23>
			*dev = devtab[i];
  8013db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e5:	eb 31                	jmp    801418 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013e7:	8b 02                	mov    (%edx),%eax
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	75 e7                	jne    8013d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	51                   	push   %ecx
  8013fc:	50                   	push   %eax
  8013fd:	68 24 28 80 00       	push   $0x802824
  801402:	e8 8f ed ff ff       	call   800196 <cprintf>
	*dev = 0;
  801407:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
  80141f:	83 ec 10             	sub    $0x10,%esp
  801422:	8b 75 08             	mov    0x8(%ebp),%esi
  801425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801428:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801432:	c1 e8 0c             	shr    $0xc,%eax
  801435:	50                   	push   %eax
  801436:	e8 33 ff ff ff       	call   80136e <fd_lookup>
  80143b:	83 c4 08             	add    $0x8,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 05                	js     801447 <fd_close+0x2d>
	    || fd != fd2)
  801442:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801445:	74 0c                	je     801453 <fd_close+0x39>
		return (must_exist ? r : 0);
  801447:	84 db                	test   %bl,%bl
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	0f 44 c2             	cmove  %edx,%eax
  801451:	eb 41                	jmp    801494 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	ff 36                	pushl  (%esi)
  80145c:	e8 63 ff ff ff       	call   8013c4 <dev_lookup>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 1a                	js     801484 <fd_close+0x6a>
		if (dev->dev_close)
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801470:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801475:	85 c0                	test   %eax,%eax
  801477:	74 0b                	je     801484 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	56                   	push   %esi
  80147d:	ff d0                	call   *%eax
  80147f:	89 c3                	mov    %eax,%ebx
  801481:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	56                   	push   %esi
  801488:	6a 00                	push   $0x0
  80148a:	e8 14 f7 ff ff       	call   800ba3 <sys_page_unmap>
	return r;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	89 d8                	mov    %ebx,%eax
}
  801494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	ff 75 08             	pushl  0x8(%ebp)
  8014a8:	e8 c1 fe ff ff       	call   80136e <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 10                	js     8014c4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	6a 01                	push   $0x1
  8014b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bc:	e8 59 ff ff ff       	call   80141a <fd_close>
  8014c1:	83 c4 10             	add    $0x10,%esp
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <close_all>:

void
close_all(void)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	53                   	push   %ebx
  8014d6:	e8 c0 ff ff ff       	call   80149b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014db:	83 c3 01             	add    $0x1,%ebx
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	83 fb 20             	cmp    $0x20,%ebx
  8014e4:	75 ec                	jne    8014d2 <close_all+0xc>
		close(i);
}
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 2c             	sub    $0x2c,%esp
  8014f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014fa:	50                   	push   %eax
  8014fb:	ff 75 08             	pushl  0x8(%ebp)
  8014fe:	e8 6b fe ff ff       	call   80136e <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	0f 88 c1 00 00 00    	js     8015cf <dup+0xe4>
		return r;
	close(newfdnum);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	56                   	push   %esi
  801512:	e8 84 ff ff ff       	call   80149b <close>

	newfd = INDEX2FD(newfdnum);
  801517:	89 f3                	mov    %esi,%ebx
  801519:	c1 e3 0c             	shl    $0xc,%ebx
  80151c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801522:	83 c4 04             	add    $0x4,%esp
  801525:	ff 75 e4             	pushl  -0x1c(%ebp)
  801528:	e8 db fd ff ff       	call   801308 <fd2data>
  80152d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80152f:	89 1c 24             	mov    %ebx,(%esp)
  801532:	e8 d1 fd ff ff       	call   801308 <fd2data>
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80153d:	89 f8                	mov    %edi,%eax
  80153f:	c1 e8 16             	shr    $0x16,%eax
  801542:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801549:	a8 01                	test   $0x1,%al
  80154b:	74 37                	je     801584 <dup+0x99>
  80154d:	89 f8                	mov    %edi,%eax
  80154f:	c1 e8 0c             	shr    $0xc,%eax
  801552:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801559:	f6 c2 01             	test   $0x1,%dl
  80155c:	74 26                	je     801584 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80155e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	25 07 0e 00 00       	and    $0xe07,%eax
  80156d:	50                   	push   %eax
  80156e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801571:	6a 00                	push   $0x0
  801573:	57                   	push   %edi
  801574:	6a 00                	push   $0x0
  801576:	e8 e6 f5 ff ff       	call   800b61 <sys_page_map>
  80157b:	89 c7                	mov    %eax,%edi
  80157d:	83 c4 20             	add    $0x20,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 2e                	js     8015b2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801584:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801587:	89 d0                	mov    %edx,%eax
  801589:	c1 e8 0c             	shr    $0xc,%eax
  80158c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	25 07 0e 00 00       	and    $0xe07,%eax
  80159b:	50                   	push   %eax
  80159c:	53                   	push   %ebx
  80159d:	6a 00                	push   $0x0
  80159f:	52                   	push   %edx
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 ba f5 ff ff       	call   800b61 <sys_page_map>
  8015a7:	89 c7                	mov    %eax,%edi
  8015a9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015ac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ae:	85 ff                	test   %edi,%edi
  8015b0:	79 1d                	jns    8015cf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	6a 00                	push   $0x0
  8015b8:	e8 e6 f5 ff ff       	call   800ba3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015c3:	6a 00                	push   $0x0
  8015c5:	e8 d9 f5 ff ff       	call   800ba3 <sys_page_unmap>
	return r;
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	89 f8                	mov    %edi,%eax
}
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	53                   	push   %ebx
  8015db:	83 ec 14             	sub    $0x14,%esp
  8015de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	53                   	push   %ebx
  8015e6:	e8 83 fd ff ff       	call   80136e <fd_lookup>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 70                	js     801664 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	ff 30                	pushl  (%eax)
  801600:	e8 bf fd ff ff       	call   8013c4 <dev_lookup>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 4f                	js     80165b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80160c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80160f:	8b 42 08             	mov    0x8(%edx),%eax
  801612:	83 e0 03             	and    $0x3,%eax
  801615:	83 f8 01             	cmp    $0x1,%eax
  801618:	75 24                	jne    80163e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80161a:	a1 04 40 80 00       	mov    0x804004,%eax
  80161f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	53                   	push   %ebx
  801629:	50                   	push   %eax
  80162a:	68 65 28 80 00       	push   $0x802865
  80162f:	e8 62 eb ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163c:	eb 26                	jmp    801664 <read+0x8d>
	}
	if (!dev->dev_read)
  80163e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801641:	8b 40 08             	mov    0x8(%eax),%eax
  801644:	85 c0                	test   %eax,%eax
  801646:	74 17                	je     80165f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801648:	83 ec 04             	sub    $0x4,%esp
  80164b:	ff 75 10             	pushl  0x10(%ebp)
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	52                   	push   %edx
  801652:	ff d0                	call   *%eax
  801654:	89 c2                	mov    %eax,%edx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 09                	jmp    801664 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	eb 05                	jmp    801664 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80165f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801664:	89 d0                	mov    %edx,%eax
  801666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	57                   	push   %edi
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	8b 7d 08             	mov    0x8(%ebp),%edi
  801677:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167f:	eb 21                	jmp    8016a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801681:	83 ec 04             	sub    $0x4,%esp
  801684:	89 f0                	mov    %esi,%eax
  801686:	29 d8                	sub    %ebx,%eax
  801688:	50                   	push   %eax
  801689:	89 d8                	mov    %ebx,%eax
  80168b:	03 45 0c             	add    0xc(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	57                   	push   %edi
  801690:	e8 42 ff ff ff       	call   8015d7 <read>
		if (m < 0)
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 10                	js     8016ac <readn+0x41>
			return m;
		if (m == 0)
  80169c:	85 c0                	test   %eax,%eax
  80169e:	74 0a                	je     8016aa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a0:	01 c3                	add    %eax,%ebx
  8016a2:	39 f3                	cmp    %esi,%ebx
  8016a4:	72 db                	jb     801681 <readn+0x16>
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	eb 02                	jmp    8016ac <readn+0x41>
  8016aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 14             	sub    $0x14,%esp
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	53                   	push   %ebx
  8016c3:	e8 a6 fc ff ff       	call   80136e <fd_lookup>
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 6b                	js     80173c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016db:	ff 30                	pushl  (%eax)
  8016dd:	e8 e2 fc ff ff       	call   8013c4 <dev_lookup>
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 4a                	js     801733 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f0:	75 24                	jne    801716 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016fd:	83 ec 04             	sub    $0x4,%esp
  801700:	53                   	push   %ebx
  801701:	50                   	push   %eax
  801702:	68 81 28 80 00       	push   $0x802881
  801707:	e8 8a ea ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801714:	eb 26                	jmp    80173c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801716:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801719:	8b 52 0c             	mov    0xc(%edx),%edx
  80171c:	85 d2                	test   %edx,%edx
  80171e:	74 17                	je     801737 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801720:	83 ec 04             	sub    $0x4,%esp
  801723:	ff 75 10             	pushl  0x10(%ebp)
  801726:	ff 75 0c             	pushl  0xc(%ebp)
  801729:	50                   	push   %eax
  80172a:	ff d2                	call   *%edx
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	eb 09                	jmp    80173c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801733:	89 c2                	mov    %eax,%edx
  801735:	eb 05                	jmp    80173c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801737:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80173c:	89 d0                	mov    %edx,%eax
  80173e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <seek>:

int
seek(int fdnum, off_t offset)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801749:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	ff 75 08             	pushl  0x8(%ebp)
  801750:	e8 19 fc ff ff       	call   80136e <fd_lookup>
  801755:	83 c4 08             	add    $0x8,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 0e                	js     80176a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80175c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80175f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801762:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 14             	sub    $0x14,%esp
  801773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801776:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	53                   	push   %ebx
  80177b:	e8 ee fb ff ff       	call   80136e <fd_lookup>
  801780:	83 c4 08             	add    $0x8,%esp
  801783:	89 c2                	mov    %eax,%edx
  801785:	85 c0                	test   %eax,%eax
  801787:	78 68                	js     8017f1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178f:	50                   	push   %eax
  801790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801793:	ff 30                	pushl  (%eax)
  801795:	e8 2a fc ff ff       	call   8013c4 <dev_lookup>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 47                	js     8017e8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a8:	75 24                	jne    8017ce <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017aa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017af:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	53                   	push   %ebx
  8017b9:	50                   	push   %eax
  8017ba:	68 44 28 80 00       	push   $0x802844
  8017bf:	e8 d2 e9 ff ff       	call   800196 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017cc:	eb 23                	jmp    8017f1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d1:	8b 52 18             	mov    0x18(%edx),%edx
  8017d4:	85 d2                	test   %edx,%edx
  8017d6:	74 14                	je     8017ec <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	ff 75 0c             	pushl  0xc(%ebp)
  8017de:	50                   	push   %eax
  8017df:	ff d2                	call   *%edx
  8017e1:	89 c2                	mov    %eax,%edx
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	eb 09                	jmp    8017f1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	eb 05                	jmp    8017f1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017f1:	89 d0                	mov    %edx,%eax
  8017f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 14             	sub    $0x14,%esp
  8017ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801802:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	ff 75 08             	pushl  0x8(%ebp)
  801809:	e8 60 fb ff ff       	call   80136e <fd_lookup>
  80180e:	83 c4 08             	add    $0x8,%esp
  801811:	89 c2                	mov    %eax,%edx
  801813:	85 c0                	test   %eax,%eax
  801815:	78 58                	js     80186f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	ff 30                	pushl  (%eax)
  801823:	e8 9c fb ff ff       	call   8013c4 <dev_lookup>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 37                	js     801866 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801836:	74 32                	je     80186a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801838:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801842:	00 00 00 
	stat->st_isdir = 0;
  801845:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184c:	00 00 00 
	stat->st_dev = dev;
  80184f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	53                   	push   %ebx
  801859:	ff 75 f0             	pushl  -0x10(%ebp)
  80185c:	ff 50 14             	call   *0x14(%eax)
  80185f:	89 c2                	mov    %eax,%edx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	eb 09                	jmp    80186f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801866:	89 c2                	mov    %eax,%edx
  801868:	eb 05                	jmp    80186f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80186a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80186f:	89 d0                	mov    %edx,%eax
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	56                   	push   %esi
  80187a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	6a 00                	push   $0x0
  801880:	ff 75 08             	pushl  0x8(%ebp)
  801883:	e8 e3 01 00 00       	call   801a6b <open>
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 1b                	js     8018ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	50                   	push   %eax
  801898:	e8 5b ff ff ff       	call   8017f8 <fstat>
  80189d:	89 c6                	mov    %eax,%esi
	close(fd);
  80189f:	89 1c 24             	mov    %ebx,(%esp)
  8018a2:	e8 f4 fb ff ff       	call   80149b <close>
	return r;
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	89 f0                	mov    %esi,%eax
}
  8018ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	89 c6                	mov    %eax,%esi
  8018ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018bc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018c3:	75 12                	jne    8018d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	6a 01                	push   $0x1
  8018ca:	e8 4b 08 00 00       	call   80211a <ipc_find_env>
  8018cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8018d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d7:	6a 07                	push   $0x7
  8018d9:	68 00 50 80 00       	push   $0x805000
  8018de:	56                   	push   %esi
  8018df:	ff 35 00 40 80 00    	pushl  0x804000
  8018e5:	e8 ce 07 00 00       	call   8020b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ea:	83 c4 0c             	add    $0xc,%esp
  8018ed:	6a 00                	push   $0x0
  8018ef:	53                   	push   %ebx
  8018f0:	6a 00                	push   $0x0
  8018f2:	e8 46 07 00 00       	call   80203d <ipc_recv>
}
  8018f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	8b 40 0c             	mov    0xc(%eax),%eax
  80190a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80190f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801912:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801917:	ba 00 00 00 00       	mov    $0x0,%edx
  80191c:	b8 02 00 00 00       	mov    $0x2,%eax
  801921:	e8 8d ff ff ff       	call   8018b3 <fsipc>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 06 00 00 00       	mov    $0x6,%eax
  801943:	e8 6b ff ff ff       	call   8018b3 <fsipc>
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	8b 40 0c             	mov    0xc(%eax),%eax
  80195a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 05 00 00 00       	mov    $0x5,%eax
  801969:	e8 45 ff ff ff       	call   8018b3 <fsipc>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 2c                	js     80199e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	68 00 50 80 00       	push   $0x805000
  80197a:	53                   	push   %ebx
  80197b:	e8 9b ed ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801980:	a1 80 50 80 00       	mov    0x805080,%eax
  801985:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80198b:	a1 84 50 80 00       	mov    0x805084,%eax
  801990:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80199e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8019af:	8b 52 0c             	mov    0xc(%edx),%edx
  8019b2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019b8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019bd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019c2:	0f 47 c2             	cmova  %edx,%eax
  8019c5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019ca:	50                   	push   %eax
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	68 08 50 80 00       	push   $0x805008
  8019d3:	e8 d5 ee ff ff       	call   8008ad <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dd:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e2:	e8 cc fe ff ff       	call   8018b3 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019fc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a02:	ba 00 00 00 00       	mov    $0x0,%edx
  801a07:	b8 03 00 00 00       	mov    $0x3,%eax
  801a0c:	e8 a2 fe ff ff       	call   8018b3 <fsipc>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 4b                	js     801a62 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a17:	39 c6                	cmp    %eax,%esi
  801a19:	73 16                	jae    801a31 <devfile_read+0x48>
  801a1b:	68 b0 28 80 00       	push   $0x8028b0
  801a20:	68 b7 28 80 00       	push   $0x8028b7
  801a25:	6a 7c                	push   $0x7c
  801a27:	68 cc 28 80 00       	push   $0x8028cc
  801a2c:	e8 c6 05 00 00       	call   801ff7 <_panic>
	assert(r <= PGSIZE);
  801a31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a36:	7e 16                	jle    801a4e <devfile_read+0x65>
  801a38:	68 d7 28 80 00       	push   $0x8028d7
  801a3d:	68 b7 28 80 00       	push   $0x8028b7
  801a42:	6a 7d                	push   $0x7d
  801a44:	68 cc 28 80 00       	push   $0x8028cc
  801a49:	e8 a9 05 00 00       	call   801ff7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	50                   	push   %eax
  801a52:	68 00 50 80 00       	push   $0x805000
  801a57:	ff 75 0c             	pushl  0xc(%ebp)
  801a5a:	e8 4e ee ff ff       	call   8008ad <memmove>
	return r;
  801a5f:	83 c4 10             	add    $0x10,%esp
}
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 20             	sub    $0x20,%esp
  801a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a75:	53                   	push   %ebx
  801a76:	e8 67 ec ff ff       	call   8006e2 <strlen>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a83:	7f 67                	jg     801aec <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8b:	50                   	push   %eax
  801a8c:	e8 8e f8 ff ff       	call   80131f <fd_alloc>
  801a91:	83 c4 10             	add    $0x10,%esp
		return r;
  801a94:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 57                	js     801af1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a9a:	83 ec 08             	sub    $0x8,%esp
  801a9d:	53                   	push   %ebx
  801a9e:	68 00 50 80 00       	push   $0x805000
  801aa3:	e8 73 ec ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aab:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ab0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab8:	e8 f6 fd ff ff       	call   8018b3 <fsipc>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	79 14                	jns    801ada <open+0x6f>
		fd_close(fd, 0);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	6a 00                	push   $0x0
  801acb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ace:	e8 47 f9 ff ff       	call   80141a <fd_close>
		return r;
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	89 da                	mov    %ebx,%edx
  801ad8:	eb 17                	jmp    801af1 <open+0x86>
	}

	return fd2num(fd);
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae0:	e8 13 f8 ff ff       	call   8012f8 <fd2num>
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	eb 05                	jmp    801af1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aec:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801af1:	89 d0                	mov    %edx,%eax
  801af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801afe:	ba 00 00 00 00       	mov    $0x0,%edx
  801b03:	b8 08 00 00 00       	mov    $0x8,%eax
  801b08:	e8 a6 fd ff ff       	call   8018b3 <fsipc>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	ff 75 08             	pushl  0x8(%ebp)
  801b1d:	e8 e6 f7 ff ff       	call   801308 <fd2data>
  801b22:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b24:	83 c4 08             	add    $0x8,%esp
  801b27:	68 e3 28 80 00       	push   $0x8028e3
  801b2c:	53                   	push   %ebx
  801b2d:	e8 e9 eb ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b32:	8b 46 04             	mov    0x4(%esi),%eax
  801b35:	2b 06                	sub    (%esi),%eax
  801b37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b44:	00 00 00 
	stat->st_dev = &devpipe;
  801b47:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b4e:	30 80 00 
	return 0;
}
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	53                   	push   %ebx
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b67:	53                   	push   %ebx
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 34 f0 ff ff       	call   800ba3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b6f:	89 1c 24             	mov    %ebx,(%esp)
  801b72:	e8 91 f7 ff ff       	call   801308 <fd2data>
  801b77:	83 c4 08             	add    $0x8,%esp
  801b7a:	50                   	push   %eax
  801b7b:	6a 00                	push   $0x0
  801b7d:	e8 21 f0 ff ff       	call   800ba3 <sys_page_unmap>
}
  801b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 1c             	sub    $0x1c,%esp
  801b90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b93:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b95:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9a:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ba6:	e8 b4 05 00 00       	call   80215f <pageref>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	89 3c 24             	mov    %edi,(%esp)
  801bb0:	e8 aa 05 00 00       	call   80215f <pageref>
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	39 c3                	cmp    %eax,%ebx
  801bba:	0f 94 c1             	sete   %cl
  801bbd:	0f b6 c9             	movzbl %cl,%ecx
  801bc0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bc3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bc9:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801bcf:	39 ce                	cmp    %ecx,%esi
  801bd1:	74 1e                	je     801bf1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801bd3:	39 c3                	cmp    %eax,%ebx
  801bd5:	75 be                	jne    801b95 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bd7:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801bdd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be0:	50                   	push   %eax
  801be1:	56                   	push   %esi
  801be2:	68 ea 28 80 00       	push   $0x8028ea
  801be7:	e8 aa e5 ff ff       	call   800196 <cprintf>
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	eb a4                	jmp    801b95 <_pipeisclosed+0xe>
	}
}
  801bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5f                   	pop    %edi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 28             	sub    $0x28,%esp
  801c05:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c08:	56                   	push   %esi
  801c09:	e8 fa f6 ff ff       	call   801308 <fd2data>
  801c0e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	bf 00 00 00 00       	mov    $0x0,%edi
  801c18:	eb 4b                	jmp    801c65 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c1a:	89 da                	mov    %ebx,%edx
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	e8 64 ff ff ff       	call   801b87 <_pipeisclosed>
  801c23:	85 c0                	test   %eax,%eax
  801c25:	75 48                	jne    801c6f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c27:	e8 d3 ee ff ff       	call   800aff <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c2f:	8b 0b                	mov    (%ebx),%ecx
  801c31:	8d 51 20             	lea    0x20(%ecx),%edx
  801c34:	39 d0                	cmp    %edx,%eax
  801c36:	73 e2                	jae    801c1a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c3f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c42:	89 c2                	mov    %eax,%edx
  801c44:	c1 fa 1f             	sar    $0x1f,%edx
  801c47:	89 d1                	mov    %edx,%ecx
  801c49:	c1 e9 1b             	shr    $0x1b,%ecx
  801c4c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c4f:	83 e2 1f             	and    $0x1f,%edx
  801c52:	29 ca                	sub    %ecx,%edx
  801c54:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c58:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c5c:	83 c0 01             	add    $0x1,%eax
  801c5f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c62:	83 c7 01             	add    $0x1,%edi
  801c65:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c68:	75 c2                	jne    801c2c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c6d:	eb 05                	jmp    801c74 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5f                   	pop    %edi
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    

00801c7c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	57                   	push   %edi
  801c80:	56                   	push   %esi
  801c81:	53                   	push   %ebx
  801c82:	83 ec 18             	sub    $0x18,%esp
  801c85:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c88:	57                   	push   %edi
  801c89:	e8 7a f6 ff ff       	call   801308 <fd2data>
  801c8e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c98:	eb 3d                	jmp    801cd7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c9a:	85 db                	test   %ebx,%ebx
  801c9c:	74 04                	je     801ca2 <devpipe_read+0x26>
				return i;
  801c9e:	89 d8                	mov    %ebx,%eax
  801ca0:	eb 44                	jmp    801ce6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	89 f8                	mov    %edi,%eax
  801ca6:	e8 dc fe ff ff       	call   801b87 <_pipeisclosed>
  801cab:	85 c0                	test   %eax,%eax
  801cad:	75 32                	jne    801ce1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801caf:	e8 4b ee ff ff       	call   800aff <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cb4:	8b 06                	mov    (%esi),%eax
  801cb6:	3b 46 04             	cmp    0x4(%esi),%eax
  801cb9:	74 df                	je     801c9a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cbb:	99                   	cltd   
  801cbc:	c1 ea 1b             	shr    $0x1b,%edx
  801cbf:	01 d0                	add    %edx,%eax
  801cc1:	83 e0 1f             	and    $0x1f,%eax
  801cc4:	29 d0                	sub    %edx,%eax
  801cc6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cd1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd4:	83 c3 01             	add    $0x1,%ebx
  801cd7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cda:	75 d8                	jne    801cb4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801cdf:	eb 05                	jmp    801ce6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5f                   	pop    %edi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	56                   	push   %esi
  801cf2:	53                   	push   %ebx
  801cf3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf9:	50                   	push   %eax
  801cfa:	e8 20 f6 ff ff       	call   80131f <fd_alloc>
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 88 2c 01 00 00    	js     801e38 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0c:	83 ec 04             	sub    $0x4,%esp
  801d0f:	68 07 04 00 00       	push   $0x407
  801d14:	ff 75 f4             	pushl  -0xc(%ebp)
  801d17:	6a 00                	push   $0x0
  801d19:	e8 00 ee ff ff       	call   800b1e <sys_page_alloc>
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	89 c2                	mov    %eax,%edx
  801d23:	85 c0                	test   %eax,%eax
  801d25:	0f 88 0d 01 00 00    	js     801e38 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d2b:	83 ec 0c             	sub    $0xc,%esp
  801d2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d31:	50                   	push   %eax
  801d32:	e8 e8 f5 ff ff       	call   80131f <fd_alloc>
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	0f 88 e2 00 00 00    	js     801e26 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d44:	83 ec 04             	sub    $0x4,%esp
  801d47:	68 07 04 00 00       	push   $0x407
  801d4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 c8 ed ff ff       	call   800b1e <sys_page_alloc>
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	0f 88 c3 00 00 00    	js     801e26 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff 75 f4             	pushl  -0xc(%ebp)
  801d69:	e8 9a f5 ff ff       	call   801308 <fd2data>
  801d6e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d70:	83 c4 0c             	add    $0xc,%esp
  801d73:	68 07 04 00 00       	push   $0x407
  801d78:	50                   	push   %eax
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 9e ed ff ff       	call   800b1e <sys_page_alloc>
  801d80:	89 c3                	mov    %eax,%ebx
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	85 c0                	test   %eax,%eax
  801d87:	0f 88 89 00 00 00    	js     801e16 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	ff 75 f0             	pushl  -0x10(%ebp)
  801d93:	e8 70 f5 ff ff       	call   801308 <fd2data>
  801d98:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d9f:	50                   	push   %eax
  801da0:	6a 00                	push   $0x0
  801da2:	56                   	push   %esi
  801da3:	6a 00                	push   $0x0
  801da5:	e8 b7 ed ff ff       	call   800b61 <sys_page_map>
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	83 c4 20             	add    $0x20,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 55                	js     801e08 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801db3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	ff 75 f4             	pushl  -0xc(%ebp)
  801de3:	e8 10 f5 ff ff       	call   8012f8 <fd2num>
  801de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801deb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ded:	83 c4 04             	add    $0x4,%esp
  801df0:	ff 75 f0             	pushl  -0x10(%ebp)
  801df3:	e8 00 f5 ff ff       	call   8012f8 <fd2num>
  801df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	ba 00 00 00 00       	mov    $0x0,%edx
  801e06:	eb 30                	jmp    801e38 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	56                   	push   %esi
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 90 ed ff ff       	call   800ba3 <sys_page_unmap>
  801e13:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 80 ed ff ff       	call   800ba3 <sys_page_unmap>
  801e23:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 70 ed ff ff       	call   800ba3 <sys_page_unmap>
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e38:	89 d0                	mov    %edx,%eax
  801e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4a:	50                   	push   %eax
  801e4b:	ff 75 08             	pushl  0x8(%ebp)
  801e4e:	e8 1b f5 ff ff       	call   80136e <fd_lookup>
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 18                	js     801e72 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e60:	e8 a3 f4 ff ff       	call   801308 <fd2data>
	return _pipeisclosed(fd, p);
  801e65:	89 c2                	mov    %eax,%edx
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	e8 18 fd ff ff       	call   801b87 <_pipeisclosed>
  801e6f:	83 c4 10             	add    $0x10,%esp
}
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e84:	68 02 29 80 00       	push   $0x802902
  801e89:	ff 75 0c             	pushl  0xc(%ebp)
  801e8c:	e8 8a e8 ff ff       	call   80071b <strcpy>
	return 0;
}
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	57                   	push   %edi
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eaf:	eb 2d                	jmp    801ede <devcons_write+0x46>
		m = n - tot;
  801eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eb4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801eb6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eb9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ebe:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec1:	83 ec 04             	sub    $0x4,%esp
  801ec4:	53                   	push   %ebx
  801ec5:	03 45 0c             	add    0xc(%ebp),%eax
  801ec8:	50                   	push   %eax
  801ec9:	57                   	push   %edi
  801eca:	e8 de e9 ff ff       	call   8008ad <memmove>
		sys_cputs(buf, m);
  801ecf:	83 c4 08             	add    $0x8,%esp
  801ed2:	53                   	push   %ebx
  801ed3:	57                   	push   %edi
  801ed4:	e8 89 eb ff ff       	call   800a62 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed9:	01 de                	add    %ebx,%esi
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	89 f0                	mov    %esi,%eax
  801ee0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee3:	72 cc                	jb     801eb1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 08             	sub    $0x8,%esp
  801ef3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ef8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801efc:	74 2a                	je     801f28 <devcons_read+0x3b>
  801efe:	eb 05                	jmp    801f05 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f00:	e8 fa eb ff ff       	call   800aff <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f05:	e8 76 eb ff ff       	call   800a80 <sys_cgetc>
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	74 f2                	je     801f00 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 16                	js     801f28 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f12:	83 f8 04             	cmp    $0x4,%eax
  801f15:	74 0c                	je     801f23 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1a:	88 02                	mov    %al,(%edx)
	return 1;
  801f1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f21:	eb 05                	jmp    801f28 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f30:	8b 45 08             	mov    0x8(%ebp),%eax
  801f33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f36:	6a 01                	push   $0x1
  801f38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	e8 21 eb ff ff       	call   800a62 <sys_cputs>
}
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <getchar>:

int
getchar(void)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f4c:	6a 01                	push   $0x1
  801f4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	6a 00                	push   $0x0
  801f54:	e8 7e f6 ff ff       	call   8015d7 <read>
	if (r < 0)
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 0f                	js     801f6f <getchar+0x29>
		return r;
	if (r < 1)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	7e 06                	jle    801f6a <getchar+0x24>
		return -E_EOF;
	return c;
  801f64:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f68:	eb 05                	jmp    801f6f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f6a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	ff 75 08             	pushl  0x8(%ebp)
  801f7e:	e8 eb f3 ff ff       	call   80136e <fd_lookup>
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 11                	js     801f9b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f93:	39 10                	cmp    %edx,(%eax)
  801f95:	0f 94 c0             	sete   %al
  801f98:	0f b6 c0             	movzbl %al,%eax
}
  801f9b:	c9                   	leave  
  801f9c:	c3                   	ret    

00801f9d <opencons>:

int
opencons(void)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa6:	50                   	push   %eax
  801fa7:	e8 73 f3 ff ff       	call   80131f <fd_alloc>
  801fac:	83 c4 10             	add    $0x10,%esp
		return r;
  801faf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	78 3e                	js     801ff3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	68 07 04 00 00       	push   $0x407
  801fbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc0:	6a 00                	push   $0x0
  801fc2:	e8 57 eb ff ff       	call   800b1e <sys_page_alloc>
  801fc7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 23                	js     801ff3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fd0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fde:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	50                   	push   %eax
  801fe9:	e8 0a f3 ff ff       	call   8012f8 <fd2num>
  801fee:	89 c2                	mov    %eax,%edx
  801ff0:	83 c4 10             	add    $0x10,%esp
}
  801ff3:	89 d0                	mov    %edx,%eax
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	56                   	push   %esi
  801ffb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ffc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802005:	e8 d6 ea ff ff       	call   800ae0 <sys_getenvid>
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	ff 75 0c             	pushl  0xc(%ebp)
  802010:	ff 75 08             	pushl  0x8(%ebp)
  802013:	56                   	push   %esi
  802014:	50                   	push   %eax
  802015:	68 10 29 80 00       	push   $0x802910
  80201a:	e8 77 e1 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80201f:	83 c4 18             	add    $0x18,%esp
  802022:	53                   	push   %ebx
  802023:	ff 75 10             	pushl  0x10(%ebp)
  802026:	e8 1a e1 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  80202b:	c7 04 24 09 28 80 00 	movl   $0x802809,(%esp)
  802032:	e8 5f e1 ff ff       	call   800196 <cprintf>
  802037:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80203a:	cc                   	int3   
  80203b:	eb fd                	jmp    80203a <_panic+0x43>

0080203d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	8b 75 08             	mov    0x8(%ebp),%esi
  802045:	8b 45 0c             	mov    0xc(%ebp),%eax
  802048:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80204b:	85 c0                	test   %eax,%eax
  80204d:	75 12                	jne    802061 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	68 00 00 c0 ee       	push   $0xeec00000
  802057:	e8 72 ec ff ff       	call   800cce <sys_ipc_recv>
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	eb 0c                	jmp    80206d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802061:	83 ec 0c             	sub    $0xc,%esp
  802064:	50                   	push   %eax
  802065:	e8 64 ec ff ff       	call   800cce <sys_ipc_recv>
  80206a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80206d:	85 f6                	test   %esi,%esi
  80206f:	0f 95 c1             	setne  %cl
  802072:	85 db                	test   %ebx,%ebx
  802074:	0f 95 c2             	setne  %dl
  802077:	84 d1                	test   %dl,%cl
  802079:	74 09                	je     802084 <ipc_recv+0x47>
  80207b:	89 c2                	mov    %eax,%edx
  80207d:	c1 ea 1f             	shr    $0x1f,%edx
  802080:	84 d2                	test   %dl,%dl
  802082:	75 2d                	jne    8020b1 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802084:	85 f6                	test   %esi,%esi
  802086:	74 0d                	je     802095 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802088:	a1 04 40 80 00       	mov    0x804004,%eax
  80208d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802093:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802095:	85 db                	test   %ebx,%ebx
  802097:	74 0d                	je     8020a6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802099:	a1 04 40 80 00       	mov    0x804004,%eax
  80209e:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020a4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ab:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8020b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020ca:	85 db                	test   %ebx,%ebx
  8020cc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020d1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020d4:	ff 75 14             	pushl  0x14(%ebp)
  8020d7:	53                   	push   %ebx
  8020d8:	56                   	push   %esi
  8020d9:	57                   	push   %edi
  8020da:	e8 cc eb ff ff       	call   800cab <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020df:	89 c2                	mov    %eax,%edx
  8020e1:	c1 ea 1f             	shr    $0x1f,%edx
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	84 d2                	test   %dl,%dl
  8020e9:	74 17                	je     802102 <ipc_send+0x4a>
  8020eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ee:	74 12                	je     802102 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020f0:	50                   	push   %eax
  8020f1:	68 34 29 80 00       	push   $0x802934
  8020f6:	6a 47                	push   $0x47
  8020f8:	68 42 29 80 00       	push   $0x802942
  8020fd:	e8 f5 fe ff ff       	call   801ff7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802102:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802105:	75 07                	jne    80210e <ipc_send+0x56>
			sys_yield();
  802107:	e8 f3 e9 ff ff       	call   800aff <sys_yield>
  80210c:	eb c6                	jmp    8020d4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80210e:	85 c0                	test   %eax,%eax
  802110:	75 c2                	jne    8020d4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802115:	5b                   	pop    %ebx
  802116:	5e                   	pop    %esi
  802117:	5f                   	pop    %edi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802125:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80212b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802131:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802137:	39 ca                	cmp    %ecx,%edx
  802139:	75 13                	jne    80214e <ipc_find_env+0x34>
			return envs[i].env_id;
  80213b:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802141:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802146:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80214c:	eb 0f                	jmp    80215d <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80214e:	83 c0 01             	add    $0x1,%eax
  802151:	3d 00 04 00 00       	cmp    $0x400,%eax
  802156:	75 cd                	jne    802125 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802158:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802165:	89 d0                	mov    %edx,%eax
  802167:	c1 e8 16             	shr    $0x16,%eax
  80216a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802171:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802176:	f6 c1 01             	test   $0x1,%cl
  802179:	74 1d                	je     802198 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80217b:	c1 ea 0c             	shr    $0xc,%edx
  80217e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802185:	f6 c2 01             	test   $0x1,%dl
  802188:	74 0e                	je     802198 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80218a:	c1 ea 0c             	shr    $0xc,%edx
  80218d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802194:	ef 
  802195:	0f b7 c0             	movzwl %ax,%eax
}
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	89 ca                	mov    %ecx,%edx
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	75 3d                	jne    802200 <__udivdi3+0x60>
  8021c3:	39 cf                	cmp    %ecx,%edi
  8021c5:	0f 87 c5 00 00 00    	ja     802290 <__udivdi3+0xf0>
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	89 fd                	mov    %edi,%ebp
  8021cf:	75 0b                	jne    8021dc <__udivdi3+0x3c>
  8021d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d6:	31 d2                	xor    %edx,%edx
  8021d8:	f7 f7                	div    %edi
  8021da:	89 c5                	mov    %eax,%ebp
  8021dc:	89 c8                	mov    %ecx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f5                	div    %ebp
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	89 cf                	mov    %ecx,%edi
  8021e8:	f7 f5                	div    %ebp
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 ce                	cmp    %ecx,%esi
  802202:	77 74                	ja     802278 <__udivdi3+0xd8>
  802204:	0f bd fe             	bsr    %esi,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0x108>
  802210:	bb 20 00 00 00       	mov    $0x20,%ebx
  802215:	89 f9                	mov    %edi,%ecx
  802217:	89 c5                	mov    %eax,%ebp
  802219:	29 fb                	sub    %edi,%ebx
  80221b:	d3 e6                	shl    %cl,%esi
  80221d:	89 d9                	mov    %ebx,%ecx
  80221f:	d3 ed                	shr    %cl,%ebp
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e0                	shl    %cl,%eax
  802225:	09 ee                	or     %ebp,%esi
  802227:	89 d9                	mov    %ebx,%ecx
  802229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222d:	89 d5                	mov    %edx,%ebp
  80222f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802233:	d3 ed                	shr    %cl,%ebp
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e2                	shl    %cl,%edx
  802239:	89 d9                	mov    %ebx,%ecx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	09 c2                	or     %eax,%edx
  80223f:	89 d0                	mov    %edx,%eax
  802241:	89 ea                	mov    %ebp,%edx
  802243:	f7 f6                	div    %esi
  802245:	89 d5                	mov    %edx,%ebp
  802247:	89 c3                	mov    %eax,%ebx
  802249:	f7 64 24 0c          	mull   0xc(%esp)
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	72 10                	jb     802261 <__udivdi3+0xc1>
  802251:	8b 74 24 08          	mov    0x8(%esp),%esi
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e6                	shl    %cl,%esi
  802259:	39 c6                	cmp    %eax,%esi
  80225b:	73 07                	jae    802264 <__udivdi3+0xc4>
  80225d:	39 d5                	cmp    %edx,%ebp
  80225f:	75 03                	jne    802264 <__udivdi3+0xc4>
  802261:	83 eb 01             	sub    $0x1,%ebx
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 d8                	mov    %ebx,%eax
  802268:	89 fa                	mov    %edi,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	31 ff                	xor    %edi,%edi
  80227a:	31 db                	xor    %ebx,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d8                	mov    %ebx,%eax
  802292:	f7 f7                	div    %edi
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 c3                	mov    %eax,%ebx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 fa                	mov    %edi,%edx
  80229c:	83 c4 1c             	add    $0x1c,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5f                   	pop    %edi
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 ce                	cmp    %ecx,%esi
  8022aa:	72 0c                	jb     8022b8 <__udivdi3+0x118>
  8022ac:	31 db                	xor    %ebx,%ebx
  8022ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022b2:	0f 87 34 ff ff ff    	ja     8021ec <__udivdi3+0x4c>
  8022b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022bd:	e9 2a ff ff ff       	jmp    8021ec <__udivdi3+0x4c>
  8022c2:	66 90                	xchg   %ax,%ax
  8022c4:	66 90                	xchg   %ax,%ax
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 d2                	test   %edx,%edx
  8022e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 f3                	mov    %esi,%ebx
  8022f3:	89 3c 24             	mov    %edi,(%esp)
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	75 1c                	jne    802318 <__umoddi3+0x48>
  8022fc:	39 f7                	cmp    %esi,%edi
  8022fe:	76 50                	jbe    802350 <__umoddi3+0x80>
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	f7 f7                	div    %edi
  802306:	89 d0                	mov    %edx,%eax
  802308:	31 d2                	xor    %edx,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	77 52                	ja     802370 <__umoddi3+0xa0>
  80231e:	0f bd ea             	bsr    %edx,%ebp
  802321:	83 f5 1f             	xor    $0x1f,%ebp
  802324:	75 5a                	jne    802380 <__umoddi3+0xb0>
  802326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80232a:	0f 82 e0 00 00 00    	jb     802410 <__umoddi3+0x140>
  802330:	39 0c 24             	cmp    %ecx,(%esp)
  802333:	0f 86 d7 00 00 00    	jbe    802410 <__umoddi3+0x140>
  802339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80233d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802341:	83 c4 1c             	add    $0x1c,%esp
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	85 ff                	test   %edi,%edi
  802352:	89 fd                	mov    %edi,%ebp
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f7                	div    %edi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	89 f0                	mov    %esi,%eax
  802363:	31 d2                	xor    %edx,%edx
  802365:	f7 f5                	div    %ebp
  802367:	89 c8                	mov    %ecx,%eax
  802369:	f7 f5                	div    %ebp
  80236b:	89 d0                	mov    %edx,%eax
  80236d:	eb 99                	jmp    802308 <__umoddi3+0x38>
  80236f:	90                   	nop
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	83 c4 1c             	add    $0x1c,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5f                   	pop    %edi
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	8b 34 24             	mov    (%esp),%esi
  802383:	bf 20 00 00 00       	mov    $0x20,%edi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	29 ef                	sub    %ebp,%edi
  80238c:	d3 e0                	shl    %cl,%eax
  80238e:	89 f9                	mov    %edi,%ecx
  802390:	89 f2                	mov    %esi,%edx
  802392:	d3 ea                	shr    %cl,%edx
  802394:	89 e9                	mov    %ebp,%ecx
  802396:	09 c2                	or     %eax,%edx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 14 24             	mov    %edx,(%esp)
  80239d:	89 f2                	mov    %esi,%edx
  80239f:	d3 e2                	shl    %cl,%edx
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	d3 e3                	shl    %cl,%ebx
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	09 d8                	or     %ebx,%eax
  8023bd:	89 d3                	mov    %edx,%ebx
  8023bf:	89 f2                	mov    %esi,%edx
  8023c1:	f7 34 24             	divl   (%esp)
  8023c4:	89 d6                	mov    %edx,%esi
  8023c6:	d3 e3                	shl    %cl,%ebx
  8023c8:	f7 64 24 04          	mull   0x4(%esp)
  8023cc:	39 d6                	cmp    %edx,%esi
  8023ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	89 c3                	mov    %eax,%ebx
  8023d6:	72 08                	jb     8023e0 <__umoddi3+0x110>
  8023d8:	75 11                	jne    8023eb <__umoddi3+0x11b>
  8023da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023de:	73 0b                	jae    8023eb <__umoddi3+0x11b>
  8023e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023e4:	1b 14 24             	sbb    (%esp),%edx
  8023e7:	89 d1                	mov    %edx,%ecx
  8023e9:	89 c3                	mov    %eax,%ebx
  8023eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023ef:	29 da                	sub    %ebx,%edx
  8023f1:	19 ce                	sbb    %ecx,%esi
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	d3 e0                	shl    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	d3 ea                	shr    %cl,%edx
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	d3 ee                	shr    %cl,%esi
  802401:	09 d0                	or     %edx,%eax
  802403:	89 f2                	mov    %esi,%edx
  802405:	83 c4 1c             	add    $0x1c,%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	29 f9                	sub    %edi,%ecx
  802412:	19 d6                	sbb    %edx,%esi
  802414:	89 74 24 04          	mov    %esi,0x4(%esp)
  802418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241c:	e9 18 ff ff ff       	jmp    802339 <__umoddi3+0x69>
