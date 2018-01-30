
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
  800045:	68 c0 24 80 00       	push   $0x8024c0
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
  800095:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80009b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a0:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000ef:	e8 54 14 00 00       	call   801548 <close_all>
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
  8001f9:	e8 22 20 00 00       	call   802220 <__udivdi3>
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
  80023c:	e8 0f 21 00 00       	call   802350 <__umoddi3>
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	0f be 80 e6 24 80 00 	movsbl 0x8024e6(%eax),%eax
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
  800340:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
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
  800404:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  80040b:	85 d2                	test   %edx,%edx
  80040d:	75 18                	jne    800427 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040f:	50                   	push   %eax
  800410:	68 fe 24 80 00       	push   $0x8024fe
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
  800428:	68 1d 2a 80 00       	push   $0x802a1d
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
  80044c:	b8 f7 24 80 00       	mov    $0x8024f7,%eax
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
  800ac7:	68 df 27 80 00       	push   $0x8027df
  800acc:	6a 23                	push   $0x23
  800ace:	68 fc 27 80 00       	push   $0x8027fc
  800ad3:	e8 a1 15 00 00       	call   802079 <_panic>

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
  800b48:	68 df 27 80 00       	push   $0x8027df
  800b4d:	6a 23                	push   $0x23
  800b4f:	68 fc 27 80 00       	push   $0x8027fc
  800b54:	e8 20 15 00 00       	call   802079 <_panic>

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
  800b8a:	68 df 27 80 00       	push   $0x8027df
  800b8f:	6a 23                	push   $0x23
  800b91:	68 fc 27 80 00       	push   $0x8027fc
  800b96:	e8 de 14 00 00       	call   802079 <_panic>

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
  800bcc:	68 df 27 80 00       	push   $0x8027df
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 fc 27 80 00       	push   $0x8027fc
  800bd8:	e8 9c 14 00 00       	call   802079 <_panic>

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
  800c0e:	68 df 27 80 00       	push   $0x8027df
  800c13:	6a 23                	push   $0x23
  800c15:	68 fc 27 80 00       	push   $0x8027fc
  800c1a:	e8 5a 14 00 00       	call   802079 <_panic>

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
  800c50:	68 df 27 80 00       	push   $0x8027df
  800c55:	6a 23                	push   $0x23
  800c57:	68 fc 27 80 00       	push   $0x8027fc
  800c5c:	e8 18 14 00 00       	call   802079 <_panic>
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
  800c92:	68 df 27 80 00       	push   $0x8027df
  800c97:	6a 23                	push   $0x23
  800c99:	68 fc 27 80 00       	push   $0x8027fc
  800c9e:	e8 d6 13 00 00       	call   802079 <_panic>

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
  800cf6:	68 df 27 80 00       	push   $0x8027df
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 fc 27 80 00       	push   $0x8027fc
  800d02:	e8 72 13 00 00       	call   802079 <_panic>

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
  800d97:	68 e6 28 80 00       	push   $0x8028e6
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 0a 28 80 00       	push   $0x80280a
  800da3:	e8 d1 12 00 00       	call   802079 <_panic>
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
  800dc7:	68 e6 28 80 00       	push   $0x8028e6
  800dcc:	6a 2c                	push   $0x2c
  800dce:	68 0a 28 80 00       	push   $0x80280a
  800dd3:	e8 a1 12 00 00       	call   802079 <_panic>
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
  800e24:	68 18 28 80 00       	push   $0x802818
  800e29:	6a 1f                	push   $0x1f
  800e2b:	68 28 28 80 00       	push   $0x802828
  800e30:	e8 44 12 00 00       	call   802079 <_panic>
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
  800e4e:	68 33 28 80 00       	push   $0x802833
  800e53:	6a 2d                	push   $0x2d
  800e55:	68 28 28 80 00       	push   $0x802828
  800e5a:	e8 1a 12 00 00       	call   802079 <_panic>
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
  800e96:	68 33 28 80 00       	push   $0x802833
  800e9b:	6a 34                	push   $0x34
  800e9d:	68 28 28 80 00       	push   $0x802828
  800ea2:	e8 d2 11 00 00       	call   802079 <_panic>
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
  800ebe:	68 33 28 80 00       	push   $0x802833
  800ec3:	6a 38                	push   $0x38
  800ec5:	68 28 28 80 00       	push   $0x802828
  800eca:	e8 aa 11 00 00       	call   802079 <_panic>
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
  800efb:	68 4c 28 80 00       	push   $0x80284c
  800f00:	68 85 00 00 00       	push   $0x85
  800f05:	68 28 28 80 00       	push   $0x802828
  800f0a:	e8 6a 11 00 00       	call   802079 <_panic>
  800f0f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f11:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f15:	75 24                	jne    800f3b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f17:	e8 c4 fb ff ff       	call   800ae0 <sys_getenvid>
  800f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f21:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800fb7:	68 5a 28 80 00       	push   $0x80285a
  800fbc:	6a 55                	push   $0x55
  800fbe:	68 28 28 80 00       	push   $0x802828
  800fc3:	e8 b1 10 00 00       	call   802079 <_panic>
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
  800ffc:	68 5a 28 80 00       	push   $0x80285a
  801001:	6a 5c                	push   $0x5c
  801003:	68 28 28 80 00       	push   $0x802828
  801008:	e8 6c 10 00 00       	call   802079 <_panic>
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
  80102a:	68 5a 28 80 00       	push   $0x80285a
  80102f:	6a 60                	push   $0x60
  801031:	68 28 28 80 00       	push   $0x802828
  801036:	e8 3e 10 00 00       	call   802079 <_panic>
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
  801054:	68 5a 28 80 00       	push   $0x80285a
  801059:	6a 65                	push   $0x65
  80105b:	68 28 28 80 00       	push   $0x802828
  801060:	e8 14 10 00 00       	call   802079 <_panic>
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
  80107c:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010b9:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	53                   	push   %ebx
  8010c3:	68 ec 28 80 00       	push   $0x8028ec
  8010c8:	e8 c9 f0 ff ff       	call   800196 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010cd:	c7 04 24 c9 00 80 00 	movl   $0x8000c9,(%esp)
  8010d4:	e8 36 fc ff ff       	call   800d0f <sys_thread_create>
  8010d9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010db:	83 c4 08             	add    $0x8,%esp
  8010de:	53                   	push   %ebx
  8010df:	68 ec 28 80 00       	push   $0x8028ec
  8010e4:	e8 ad f0 ff ff       	call   800196 <cprintf>
	return id;
}
  8010e9:	89 f0                	mov    %esi,%eax
  8010eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8010f8:	ff 75 08             	pushl  0x8(%ebp)
  8010fb:	e8 2f fc ff ff       	call   800d2f <sys_thread_free>
}
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80110b:	ff 75 08             	pushl  0x8(%ebp)
  80110e:	e8 3c fc ff ff       	call   800d4f <sys_thread_join>
}
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	8b 75 08             	mov    0x8(%ebp),%esi
  801120:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	6a 07                	push   $0x7
  801128:	6a 00                	push   $0x0
  80112a:	56                   	push   %esi
  80112b:	e8 ee f9 ff ff       	call   800b1e <sys_page_alloc>
	if (r < 0) {
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	79 15                	jns    80114c <queue_append+0x34>
		panic("%e\n", r);
  801137:	50                   	push   %eax
  801138:	68 e6 28 80 00       	push   $0x8028e6
  80113d:	68 c4 00 00 00       	push   $0xc4
  801142:	68 28 28 80 00       	push   $0x802828
  801147:	e8 2d 0f 00 00       	call   802079 <_panic>
	}	
	wt->envid = envid;
  80114c:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801152:	83 ec 04             	sub    $0x4,%esp
  801155:	ff 33                	pushl  (%ebx)
  801157:	56                   	push   %esi
  801158:	68 10 29 80 00       	push   $0x802910
  80115d:	e8 34 f0 ff ff       	call   800196 <cprintf>
	if (queue->first == NULL) {
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	83 3b 00             	cmpl   $0x0,(%ebx)
  801168:	75 29                	jne    801193 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80116a:	83 ec 0c             	sub    $0xc,%esp
  80116d:	68 70 28 80 00       	push   $0x802870
  801172:	e8 1f f0 ff ff       	call   800196 <cprintf>
		queue->first = wt;
  801177:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80117d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801184:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80118b:	00 00 00 
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	eb 2b                	jmp    8011be <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	68 8a 28 80 00       	push   $0x80288a
  80119b:	e8 f6 ef ff ff       	call   800196 <cprintf>
		queue->last->next = wt;
  8011a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011aa:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011b1:	00 00 00 
		queue->last = wt;
  8011b4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011bb:	83 c4 10             	add    $0x10,%esp
	}
}
  8011be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011cf:	8b 02                	mov    (%edx),%eax
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	75 17                	jne    8011ec <queue_pop+0x27>
		panic("queue empty!\n");
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	68 a8 28 80 00       	push   $0x8028a8
  8011dd:	68 d8 00 00 00       	push   $0xd8
  8011e2:	68 28 28 80 00       	push   $0x802828
  8011e7:	e8 8d 0e 00 00       	call   802079 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8011ef:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8011f1:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	53                   	push   %ebx
  8011f7:	68 b6 28 80 00       	push   $0x8028b6
  8011fc:	e8 95 ef ff ff       	call   800196 <cprintf>
	return envid;
}
  801201:	89 d8                	mov    %ebx,%eax
  801203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	53                   	push   %ebx
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801212:	b8 01 00 00 00       	mov    $0x1,%eax
  801217:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80121a:	85 c0                	test   %eax,%eax
  80121c:	74 5a                	je     801278 <mutex_lock+0x70>
  80121e:	8b 43 04             	mov    0x4(%ebx),%eax
  801221:	83 38 00             	cmpl   $0x0,(%eax)
  801224:	75 52                	jne    801278 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	68 38 29 80 00       	push   $0x802938
  80122e:	e8 63 ef ff ff       	call   800196 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801233:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801236:	e8 a5 f8 ff ff       	call   800ae0 <sys_getenvid>
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	53                   	push   %ebx
  80123f:	50                   	push   %eax
  801240:	e8 d3 fe ff ff       	call   801118 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801245:	e8 96 f8 ff ff       	call   800ae0 <sys_getenvid>
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	6a 04                	push   $0x4
  80124f:	50                   	push   %eax
  801250:	e8 90 f9 ff ff       	call   800be5 <sys_env_set_status>
		if (r < 0) {
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	79 15                	jns    801271 <mutex_lock+0x69>
			panic("%e\n", r);
  80125c:	50                   	push   %eax
  80125d:	68 e6 28 80 00       	push   $0x8028e6
  801262:	68 eb 00 00 00       	push   $0xeb
  801267:	68 28 28 80 00       	push   $0x802828
  80126c:	e8 08 0e 00 00       	call   802079 <_panic>
		}
		sys_yield();
  801271:	e8 89 f8 ff ff       	call   800aff <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801276:	eb 18                	jmp    801290 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801278:	83 ec 0c             	sub    $0xc,%esp
  80127b:	68 58 29 80 00       	push   $0x802958
  801280:	e8 11 ef ff ff       	call   800196 <cprintf>
	mtx->owner = sys_getenvid();}
  801285:	e8 56 f8 ff ff       	call   800ae0 <sys_getenvid>
  80128a:	89 43 08             	mov    %eax,0x8(%ebx)
  80128d:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	53                   	push   %ebx
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012a7:	8b 43 04             	mov    0x4(%ebx),%eax
  8012aa:	83 38 00             	cmpl   $0x0,(%eax)
  8012ad:	74 33                	je     8012e2 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012af:	83 ec 0c             	sub    $0xc,%esp
  8012b2:	50                   	push   %eax
  8012b3:	e8 0d ff ff ff       	call   8011c5 <queue_pop>
  8012b8:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	6a 02                	push   $0x2
  8012c0:	50                   	push   %eax
  8012c1:	e8 1f f9 ff ff       	call   800be5 <sys_env_set_status>
		if (r < 0) {
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	79 15                	jns    8012e2 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012cd:	50                   	push   %eax
  8012ce:	68 e6 28 80 00       	push   $0x8028e6
  8012d3:	68 00 01 00 00       	push   $0x100
  8012d8:	68 28 28 80 00       	push   $0x802828
  8012dd:	e8 97 0d 00 00       	call   802079 <_panic>
		}
	}

	asm volatile("pause");
  8012e2:	f3 90                	pause  
	//sys_yield();
}
  8012e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012f3:	e8 e8 f7 ff ff       	call   800ae0 <sys_getenvid>
  8012f8:	83 ec 04             	sub    $0x4,%esp
  8012fb:	6a 07                	push   $0x7
  8012fd:	53                   	push   %ebx
  8012fe:	50                   	push   %eax
  8012ff:	e8 1a f8 ff ff       	call   800b1e <sys_page_alloc>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	79 15                	jns    801320 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80130b:	50                   	push   %eax
  80130c:	68 d1 28 80 00       	push   $0x8028d1
  801311:	68 0d 01 00 00       	push   $0x10d
  801316:	68 28 28 80 00       	push   $0x802828
  80131b:	e8 59 0d 00 00       	call   802079 <_panic>
	}	
	mtx->locked = 0;
  801320:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801326:	8b 43 04             	mov    0x4(%ebx),%eax
  801329:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80132f:	8b 43 04             	mov    0x4(%ebx),%eax
  801332:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801339:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80134b:	e8 90 f7 ff ff       	call   800ae0 <sys_getenvid>
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	50                   	push   %eax
  801357:	e8 47 f8 ff ff       	call   800ba3 <sys_page_unmap>
	if (r < 0) {
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	79 15                	jns    801378 <mutex_destroy+0x33>
		panic("%e\n", r);
  801363:	50                   	push   %eax
  801364:	68 e6 28 80 00       	push   $0x8028e6
  801369:	68 1a 01 00 00       	push   $0x11a
  80136e:	68 28 28 80 00       	push   $0x802828
  801373:	e8 01 0d 00 00       	call   802079 <_panic>
	}
}
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80137d:	8b 45 08             	mov    0x8(%ebp),%eax
  801380:	05 00 00 00 30       	add    $0x30000000,%eax
  801385:	c1 e8 0c             	shr    $0xc,%eax
}
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80138d:	8b 45 08             	mov    0x8(%ebp),%eax
  801390:	05 00 00 00 30       	add    $0x30000000,%eax
  801395:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80139a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	c1 ea 16             	shr    $0x16,%edx
  8013b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b8:	f6 c2 01             	test   $0x1,%dl
  8013bb:	74 11                	je     8013ce <fd_alloc+0x2d>
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	c1 ea 0c             	shr    $0xc,%edx
  8013c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c9:	f6 c2 01             	test   $0x1,%dl
  8013cc:	75 09                	jne    8013d7 <fd_alloc+0x36>
			*fd_store = fd;
  8013ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	eb 17                	jmp    8013ee <fd_alloc+0x4d>
  8013d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e1:	75 c9                	jne    8013ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013f6:	83 f8 1f             	cmp    $0x1f,%eax
  8013f9:	77 36                	ja     801431 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013fb:	c1 e0 0c             	shl    $0xc,%eax
  8013fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801403:	89 c2                	mov    %eax,%edx
  801405:	c1 ea 16             	shr    $0x16,%edx
  801408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80140f:	f6 c2 01             	test   $0x1,%dl
  801412:	74 24                	je     801438 <fd_lookup+0x48>
  801414:	89 c2                	mov    %eax,%edx
  801416:	c1 ea 0c             	shr    $0xc,%edx
  801419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801420:	f6 c2 01             	test   $0x1,%dl
  801423:	74 1a                	je     80143f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801425:	8b 55 0c             	mov    0xc(%ebp),%edx
  801428:	89 02                	mov    %eax,(%edx)
	return 0;
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
  80142f:	eb 13                	jmp    801444 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801436:	eb 0c                	jmp    801444 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143d:	eb 05                	jmp    801444 <fd_lookup+0x54>
  80143f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144f:	ba f4 29 80 00       	mov    $0x8029f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801454:	eb 13                	jmp    801469 <dev_lookup+0x23>
  801456:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801459:	39 08                	cmp    %ecx,(%eax)
  80145b:	75 0c                	jne    801469 <dev_lookup+0x23>
			*dev = devtab[i];
  80145d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801460:	89 01                	mov    %eax,(%ecx)
			return 0;
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	eb 31                	jmp    80149a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801469:	8b 02                	mov    (%edx),%eax
  80146b:	85 c0                	test   %eax,%eax
  80146d:	75 e7                	jne    801456 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80146f:	a1 04 40 80 00       	mov    0x804004,%eax
  801474:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	51                   	push   %ecx
  80147e:	50                   	push   %eax
  80147f:	68 78 29 80 00       	push   $0x802978
  801484:	e8 0d ed ff ff       	call   800196 <cprintf>
	*dev = 0;
  801489:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 10             	sub    $0x10,%esp
  8014a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014b4:	c1 e8 0c             	shr    $0xc,%eax
  8014b7:	50                   	push   %eax
  8014b8:	e8 33 ff ff ff       	call   8013f0 <fd_lookup>
  8014bd:	83 c4 08             	add    $0x8,%esp
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 05                	js     8014c9 <fd_close+0x2d>
	    || fd != fd2)
  8014c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c7:	74 0c                	je     8014d5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014c9:	84 db                	test   %bl,%bl
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	0f 44 c2             	cmove  %edx,%eax
  8014d3:	eb 41                	jmp    801516 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	ff 36                	pushl  (%esi)
  8014de:	e8 63 ff ff ff       	call   801446 <dev_lookup>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 1a                	js     801506 <fd_close+0x6a>
		if (dev->dev_close)
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	74 0b                	je     801506 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	56                   	push   %esi
  8014ff:	ff d0                	call   *%eax
  801501:	89 c3                	mov    %eax,%ebx
  801503:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	56                   	push   %esi
  80150a:	6a 00                	push   $0x0
  80150c:	e8 92 f6 ff ff       	call   800ba3 <sys_page_unmap>
	return r;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	89 d8                	mov    %ebx,%eax
}
  801516:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801519:	5b                   	pop    %ebx
  80151a:	5e                   	pop    %esi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	ff 75 08             	pushl  0x8(%ebp)
  80152a:	e8 c1 fe ff ff       	call   8013f0 <fd_lookup>
  80152f:	83 c4 08             	add    $0x8,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 10                	js     801546 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	6a 01                	push   $0x1
  80153b:	ff 75 f4             	pushl  -0xc(%ebp)
  80153e:	e8 59 ff ff ff       	call   80149c <fd_close>
  801543:	83 c4 10             	add    $0x10,%esp
}
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <close_all>:

void
close_all(void)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80154f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	53                   	push   %ebx
  801558:	e8 c0 ff ff ff       	call   80151d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80155d:	83 c3 01             	add    $0x1,%ebx
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	83 fb 20             	cmp    $0x20,%ebx
  801566:	75 ec                	jne    801554 <close_all+0xc>
		close(i);
}
  801568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	57                   	push   %edi
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
  801573:	83 ec 2c             	sub    $0x2c,%esp
  801576:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801579:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	ff 75 08             	pushl  0x8(%ebp)
  801580:	e8 6b fe ff ff       	call   8013f0 <fd_lookup>
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	0f 88 c1 00 00 00    	js     801651 <dup+0xe4>
		return r;
	close(newfdnum);
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	56                   	push   %esi
  801594:	e8 84 ff ff ff       	call   80151d <close>

	newfd = INDEX2FD(newfdnum);
  801599:	89 f3                	mov    %esi,%ebx
  80159b:	c1 e3 0c             	shl    $0xc,%ebx
  80159e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015a4:	83 c4 04             	add    $0x4,%esp
  8015a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015aa:	e8 db fd ff ff       	call   80138a <fd2data>
  8015af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015b1:	89 1c 24             	mov    %ebx,(%esp)
  8015b4:	e8 d1 fd ff ff       	call   80138a <fd2data>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015bf:	89 f8                	mov    %edi,%eax
  8015c1:	c1 e8 16             	shr    $0x16,%eax
  8015c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015cb:	a8 01                	test   $0x1,%al
  8015cd:	74 37                	je     801606 <dup+0x99>
  8015cf:	89 f8                	mov    %edi,%eax
  8015d1:	c1 e8 0c             	shr    $0xc,%eax
  8015d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015db:	f6 c2 01             	test   $0x1,%dl
  8015de:	74 26                	je     801606 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ef:	50                   	push   %eax
  8015f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f3:	6a 00                	push   $0x0
  8015f5:	57                   	push   %edi
  8015f6:	6a 00                	push   $0x0
  8015f8:	e8 64 f5 ff ff       	call   800b61 <sys_page_map>
  8015fd:	89 c7                	mov    %eax,%edi
  8015ff:	83 c4 20             	add    $0x20,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 2e                	js     801634 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801606:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801609:	89 d0                	mov    %edx,%eax
  80160b:	c1 e8 0c             	shr    $0xc,%eax
  80160e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	25 07 0e 00 00       	and    $0xe07,%eax
  80161d:	50                   	push   %eax
  80161e:	53                   	push   %ebx
  80161f:	6a 00                	push   $0x0
  801621:	52                   	push   %edx
  801622:	6a 00                	push   $0x0
  801624:	e8 38 f5 ff ff       	call   800b61 <sys_page_map>
  801629:	89 c7                	mov    %eax,%edi
  80162b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80162e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801630:	85 ff                	test   %edi,%edi
  801632:	79 1d                	jns    801651 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	53                   	push   %ebx
  801638:	6a 00                	push   $0x0
  80163a:	e8 64 f5 ff ff       	call   800ba3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	ff 75 d4             	pushl  -0x2c(%ebp)
  801645:	6a 00                	push   $0x0
  801647:	e8 57 f5 ff ff       	call   800ba3 <sys_page_unmap>
	return r;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	89 f8                	mov    %edi,%eax
}
  801651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801654:	5b                   	pop    %ebx
  801655:	5e                   	pop    %esi
  801656:	5f                   	pop    %edi
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	53                   	push   %ebx
  80165d:	83 ec 14             	sub    $0x14,%esp
  801660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801663:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	53                   	push   %ebx
  801668:	e8 83 fd ff ff       	call   8013f0 <fd_lookup>
  80166d:	83 c4 08             	add    $0x8,%esp
  801670:	89 c2                	mov    %eax,%edx
  801672:	85 c0                	test   %eax,%eax
  801674:	78 70                	js     8016e6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	ff 30                	pushl  (%eax)
  801682:	e8 bf fd ff ff       	call   801446 <dev_lookup>
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 4f                	js     8016dd <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80168e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801691:	8b 42 08             	mov    0x8(%edx),%eax
  801694:	83 e0 03             	and    $0x3,%eax
  801697:	83 f8 01             	cmp    $0x1,%eax
  80169a:	75 24                	jne    8016c0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80169c:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	53                   	push   %ebx
  8016ab:	50                   	push   %eax
  8016ac:	68 b9 29 80 00       	push   $0x8029b9
  8016b1:	e8 e0 ea ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016be:	eb 26                	jmp    8016e6 <read+0x8d>
	}
	if (!dev->dev_read)
  8016c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c3:	8b 40 08             	mov    0x8(%eax),%eax
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	74 17                	je     8016e1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016ca:	83 ec 04             	sub    $0x4,%esp
  8016cd:	ff 75 10             	pushl  0x10(%ebp)
  8016d0:	ff 75 0c             	pushl  0xc(%ebp)
  8016d3:	52                   	push   %edx
  8016d4:	ff d0                	call   *%eax
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	eb 09                	jmp    8016e6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	eb 05                	jmp    8016e6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016e6:	89 d0                	mov    %edx,%eax
  8016e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	57                   	push   %edi
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 0c             	sub    $0xc,%esp
  8016f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801701:	eb 21                	jmp    801724 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801703:	83 ec 04             	sub    $0x4,%esp
  801706:	89 f0                	mov    %esi,%eax
  801708:	29 d8                	sub    %ebx,%eax
  80170a:	50                   	push   %eax
  80170b:	89 d8                	mov    %ebx,%eax
  80170d:	03 45 0c             	add    0xc(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	57                   	push   %edi
  801712:	e8 42 ff ff ff       	call   801659 <read>
		if (m < 0)
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 10                	js     80172e <readn+0x41>
			return m;
		if (m == 0)
  80171e:	85 c0                	test   %eax,%eax
  801720:	74 0a                	je     80172c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801722:	01 c3                	add    %eax,%ebx
  801724:	39 f3                	cmp    %esi,%ebx
  801726:	72 db                	jb     801703 <readn+0x16>
  801728:	89 d8                	mov    %ebx,%eax
  80172a:	eb 02                	jmp    80172e <readn+0x41>
  80172c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	53                   	push   %ebx
  80173a:	83 ec 14             	sub    $0x14,%esp
  80173d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801740:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801743:	50                   	push   %eax
  801744:	53                   	push   %ebx
  801745:	e8 a6 fc ff ff       	call   8013f0 <fd_lookup>
  80174a:	83 c4 08             	add    $0x8,%esp
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 6b                	js     8017be <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	ff 30                	pushl  (%eax)
  80175f:	e8 e2 fc ff ff       	call   801446 <dev_lookup>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 4a                	js     8017b5 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801772:	75 24                	jne    801798 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801774:	a1 04 40 80 00       	mov    0x804004,%eax
  801779:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	53                   	push   %ebx
  801783:	50                   	push   %eax
  801784:	68 d5 29 80 00       	push   $0x8029d5
  801789:	e8 08 ea ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801796:	eb 26                	jmp    8017be <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801798:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179b:	8b 52 0c             	mov    0xc(%edx),%edx
  80179e:	85 d2                	test   %edx,%edx
  8017a0:	74 17                	je     8017b9 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	ff 75 10             	pushl  0x10(%ebp)
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	50                   	push   %eax
  8017ac:	ff d2                	call   *%edx
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	eb 09                	jmp    8017be <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	eb 05                	jmp    8017be <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017be:	89 d0                	mov    %edx,%eax
  8017c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ce:	50                   	push   %eax
  8017cf:	ff 75 08             	pushl  0x8(%ebp)
  8017d2:	e8 19 fc ff ff       	call   8013f0 <fd_lookup>
  8017d7:	83 c4 08             	add    $0x8,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 0e                	js     8017ec <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 14             	sub    $0x14,%esp
  8017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fb:	50                   	push   %eax
  8017fc:	53                   	push   %ebx
  8017fd:	e8 ee fb ff ff       	call   8013f0 <fd_lookup>
  801802:	83 c4 08             	add    $0x8,%esp
  801805:	89 c2                	mov    %eax,%edx
  801807:	85 c0                	test   %eax,%eax
  801809:	78 68                	js     801873 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	ff 30                	pushl  (%eax)
  801817:	e8 2a fc ff ff       	call   801446 <dev_lookup>
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 47                	js     80186a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801823:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801826:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80182a:	75 24                	jne    801850 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80182c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801831:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	53                   	push   %ebx
  80183b:	50                   	push   %eax
  80183c:	68 98 29 80 00       	push   $0x802998
  801841:	e8 50 e9 ff ff       	call   800196 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80184e:	eb 23                	jmp    801873 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801853:	8b 52 18             	mov    0x18(%edx),%edx
  801856:	85 d2                	test   %edx,%edx
  801858:	74 14                	je     80186e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	ff 75 0c             	pushl  0xc(%ebp)
  801860:	50                   	push   %eax
  801861:	ff d2                	call   *%edx
  801863:	89 c2                	mov    %eax,%edx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	eb 09                	jmp    801873 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	eb 05                	jmp    801873 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80186e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801873:	89 d0                	mov    %edx,%eax
  801875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	53                   	push   %ebx
  80187e:	83 ec 14             	sub    $0x14,%esp
  801881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801884:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801887:	50                   	push   %eax
  801888:	ff 75 08             	pushl  0x8(%ebp)
  80188b:	e8 60 fb ff ff       	call   8013f0 <fd_lookup>
  801890:	83 c4 08             	add    $0x8,%esp
  801893:	89 c2                	mov    %eax,%edx
  801895:	85 c0                	test   %eax,%eax
  801897:	78 58                	js     8018f1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801899:	83 ec 08             	sub    $0x8,%esp
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a3:	ff 30                	pushl  (%eax)
  8018a5:	e8 9c fb ff ff       	call   801446 <dev_lookup>
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 37                	js     8018e8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b8:	74 32                	je     8018ec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018c4:	00 00 00 
	stat->st_isdir = 0;
  8018c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ce:	00 00 00 
	stat->st_dev = dev;
  8018d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	53                   	push   %ebx
  8018db:	ff 75 f0             	pushl  -0x10(%ebp)
  8018de:	ff 50 14             	call   *0x14(%eax)
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	eb 09                	jmp    8018f1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e8:	89 c2                	mov    %eax,%edx
  8018ea:	eb 05                	jmp    8018f1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018f1:	89 d0                	mov    %edx,%eax
  8018f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	6a 00                	push   $0x0
  801902:	ff 75 08             	pushl  0x8(%ebp)
  801905:	e8 e3 01 00 00       	call   801aed <open>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 1b                	js     80192e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	50                   	push   %eax
  80191a:	e8 5b ff ff ff       	call   80187a <fstat>
  80191f:	89 c6                	mov    %eax,%esi
	close(fd);
  801921:	89 1c 24             	mov    %ebx,(%esp)
  801924:	e8 f4 fb ff ff       	call   80151d <close>
	return r;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	89 f0                	mov    %esi,%eax
}
  80192e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	89 c6                	mov    %eax,%esi
  80193c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80193e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801945:	75 12                	jne    801959 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801947:	83 ec 0c             	sub    $0xc,%esp
  80194a:	6a 01                	push   $0x1
  80194c:	e8 4b 08 00 00       	call   80219c <ipc_find_env>
  801951:	a3 00 40 80 00       	mov    %eax,0x804000
  801956:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801959:	6a 07                	push   $0x7
  80195b:	68 00 50 80 00       	push   $0x805000
  801960:	56                   	push   %esi
  801961:	ff 35 00 40 80 00    	pushl  0x804000
  801967:	e8 ce 07 00 00       	call   80213a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80196c:	83 c4 0c             	add    $0xc,%esp
  80196f:	6a 00                	push   $0x0
  801971:	53                   	push   %ebx
  801972:	6a 00                	push   $0x0
  801974:	e8 46 07 00 00       	call   8020bf <ipc_recv>
}
  801979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 40 0c             	mov    0xc(%eax),%eax
  80198c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801991:	8b 45 0c             	mov    0xc(%ebp),%eax
  801994:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801999:	ba 00 00 00 00       	mov    $0x0,%edx
  80199e:	b8 02 00 00 00       	mov    $0x2,%eax
  8019a3:	e8 8d ff ff ff       	call   801935 <fsipc>
}
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8019c5:	e8 6b ff ff ff       	call   801935 <fsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8019eb:	e8 45 ff ff ff       	call   801935 <fsipc>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 2c                	js     801a20 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019f4:	83 ec 08             	sub    $0x8,%esp
  8019f7:	68 00 50 80 00       	push   $0x805000
  8019fc:	53                   	push   %ebx
  8019fd:	e8 19 ed ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a02:	a1 80 50 80 00       	mov    0x805080,%eax
  801a07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a0d:	a1 84 50 80 00       	mov    0x805084,%eax
  801a12:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a2e:	8b 55 08             	mov    0x8(%ebp),%edx
  801a31:	8b 52 0c             	mov    0xc(%edx),%edx
  801a34:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a3a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a3f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a44:	0f 47 c2             	cmova  %edx,%eax
  801a47:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a4c:	50                   	push   %eax
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	68 08 50 80 00       	push   $0x805008
  801a55:	e8 53 ee ff ff       	call   8008ad <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5f:	b8 04 00 00 00       	mov    $0x4,%eax
  801a64:	e8 cc fe ff ff       	call   801935 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	8b 40 0c             	mov    0xc(%eax),%eax
  801a79:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a7e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a84:	ba 00 00 00 00       	mov    $0x0,%edx
  801a89:	b8 03 00 00 00       	mov    $0x3,%eax
  801a8e:	e8 a2 fe ff ff       	call   801935 <fsipc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 4b                	js     801ae4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a99:	39 c6                	cmp    %eax,%esi
  801a9b:	73 16                	jae    801ab3 <devfile_read+0x48>
  801a9d:	68 04 2a 80 00       	push   $0x802a04
  801aa2:	68 0b 2a 80 00       	push   $0x802a0b
  801aa7:	6a 7c                	push   $0x7c
  801aa9:	68 20 2a 80 00       	push   $0x802a20
  801aae:	e8 c6 05 00 00       	call   802079 <_panic>
	assert(r <= PGSIZE);
  801ab3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ab8:	7e 16                	jle    801ad0 <devfile_read+0x65>
  801aba:	68 2b 2a 80 00       	push   $0x802a2b
  801abf:	68 0b 2a 80 00       	push   $0x802a0b
  801ac4:	6a 7d                	push   $0x7d
  801ac6:	68 20 2a 80 00       	push   $0x802a20
  801acb:	e8 a9 05 00 00       	call   802079 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ad0:	83 ec 04             	sub    $0x4,%esp
  801ad3:	50                   	push   %eax
  801ad4:	68 00 50 80 00       	push   $0x805000
  801ad9:	ff 75 0c             	pushl  0xc(%ebp)
  801adc:	e8 cc ed ff ff       	call   8008ad <memmove>
	return r;
  801ae1:	83 c4 10             	add    $0x10,%esp
}
  801ae4:	89 d8                	mov    %ebx,%eax
  801ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	53                   	push   %ebx
  801af1:	83 ec 20             	sub    $0x20,%esp
  801af4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801af7:	53                   	push   %ebx
  801af8:	e8 e5 eb ff ff       	call   8006e2 <strlen>
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b05:	7f 67                	jg     801b6e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	e8 8e f8 ff ff       	call   8013a1 <fd_alloc>
  801b13:	83 c4 10             	add    $0x10,%esp
		return r;
  801b16:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 57                	js     801b73 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	53                   	push   %ebx
  801b20:	68 00 50 80 00       	push   $0x805000
  801b25:	e8 f1 eb ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b35:	b8 01 00 00 00       	mov    $0x1,%eax
  801b3a:	e8 f6 fd ff ff       	call   801935 <fsipc>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	79 14                	jns    801b5c <open+0x6f>
		fd_close(fd, 0);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	6a 00                	push   $0x0
  801b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b50:	e8 47 f9 ff ff       	call   80149c <fd_close>
		return r;
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	89 da                	mov    %ebx,%edx
  801b5a:	eb 17                	jmp    801b73 <open+0x86>
	}

	return fd2num(fd);
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b62:	e8 13 f8 ff ff       	call   80137a <fd2num>
  801b67:	89 c2                	mov    %eax,%edx
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	eb 05                	jmp    801b73 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b6e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b73:	89 d0                	mov    %edx,%eax
  801b75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b80:	ba 00 00 00 00       	mov    $0x0,%edx
  801b85:	b8 08 00 00 00       	mov    $0x8,%eax
  801b8a:	e8 a6 fd ff ff       	call   801935 <fsipc>
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 08             	pushl  0x8(%ebp)
  801b9f:	e8 e6 f7 ff ff       	call   80138a <fd2data>
  801ba4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ba6:	83 c4 08             	add    $0x8,%esp
  801ba9:	68 37 2a 80 00       	push   $0x802a37
  801bae:	53                   	push   %ebx
  801baf:	e8 67 eb ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb4:	8b 46 04             	mov    0x4(%esi),%eax
  801bb7:	2b 06                	sub    (%esi),%eax
  801bb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bc6:	00 00 00 
	stat->st_dev = &devpipe;
  801bc9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bd0:	30 80 00 
	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be9:	53                   	push   %ebx
  801bea:	6a 00                	push   $0x0
  801bec:	e8 b2 ef ff ff       	call   800ba3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf1:	89 1c 24             	mov    %ebx,(%esp)
  801bf4:	e8 91 f7 ff ff       	call   80138a <fd2data>
  801bf9:	83 c4 08             	add    $0x8,%esp
  801bfc:	50                   	push   %eax
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 9f ef ff ff       	call   800ba3 <sys_page_unmap>
}
  801c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	57                   	push   %edi
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 1c             	sub    $0x1c,%esp
  801c12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c15:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c17:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1c:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	ff 75 e0             	pushl  -0x20(%ebp)
  801c28:	e8 b4 05 00 00       	call   8021e1 <pageref>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	89 3c 24             	mov    %edi,(%esp)
  801c32:	e8 aa 05 00 00       	call   8021e1 <pageref>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	39 c3                	cmp    %eax,%ebx
  801c3c:	0f 94 c1             	sete   %cl
  801c3f:	0f b6 c9             	movzbl %cl,%ecx
  801c42:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c45:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c4b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c51:	39 ce                	cmp    %ecx,%esi
  801c53:	74 1e                	je     801c73 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c55:	39 c3                	cmp    %eax,%ebx
  801c57:	75 be                	jne    801c17 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c59:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c62:	50                   	push   %eax
  801c63:	56                   	push   %esi
  801c64:	68 3e 2a 80 00       	push   $0x802a3e
  801c69:	e8 28 e5 ff ff       	call   800196 <cprintf>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	eb a4                	jmp    801c17 <_pipeisclosed+0xe>
	}
}
  801c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 28             	sub    $0x28,%esp
  801c87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c8a:	56                   	push   %esi
  801c8b:	e8 fa f6 ff ff       	call   80138a <fd2data>
  801c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	bf 00 00 00 00       	mov    $0x0,%edi
  801c9a:	eb 4b                	jmp    801ce7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c9c:	89 da                	mov    %ebx,%edx
  801c9e:	89 f0                	mov    %esi,%eax
  801ca0:	e8 64 ff ff ff       	call   801c09 <_pipeisclosed>
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	75 48                	jne    801cf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca9:	e8 51 ee ff ff       	call   800aff <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cae:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb1:	8b 0b                	mov    (%ebx),%ecx
  801cb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb6:	39 d0                	cmp    %edx,%eax
  801cb8:	73 e2                	jae    801c9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	c1 fa 1f             	sar    $0x1f,%edx
  801cc9:	89 d1                	mov    %edx,%ecx
  801ccb:	c1 e9 1b             	shr    $0x1b,%ecx
  801cce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cd1:	83 e2 1f             	and    $0x1f,%edx
  801cd4:	29 ca                	sub    %ecx,%edx
  801cd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cde:	83 c0 01             	add    $0x1,%eax
  801ce1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce4:	83 c7 01             	add    $0x1,%edi
  801ce7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cea:	75 c2                	jne    801cae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cec:	8b 45 10             	mov    0x10(%ebp),%eax
  801cef:	eb 05                	jmp    801cf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 18             	sub    $0x18,%esp
  801d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d0a:	57                   	push   %edi
  801d0b:	e8 7a f6 ff ff       	call   80138a <fd2data>
  801d10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d1a:	eb 3d                	jmp    801d59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d1c:	85 db                	test   %ebx,%ebx
  801d1e:	74 04                	je     801d24 <devpipe_read+0x26>
				return i;
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	eb 44                	jmp    801d68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	89 f8                	mov    %edi,%eax
  801d28:	e8 dc fe ff ff       	call   801c09 <_pipeisclosed>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	75 32                	jne    801d63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d31:	e8 c9 ed ff ff       	call   800aff <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d36:	8b 06                	mov    (%esi),%eax
  801d38:	3b 46 04             	cmp    0x4(%esi),%eax
  801d3b:	74 df                	je     801d1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3d:	99                   	cltd   
  801d3e:	c1 ea 1b             	shr    $0x1b,%edx
  801d41:	01 d0                	add    %edx,%eax
  801d43:	83 e0 1f             	and    $0x1f,%eax
  801d46:	29 d0                	sub    %edx,%eax
  801d48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d56:	83 c3 01             	add    $0x1,%ebx
  801d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d5c:	75 d8                	jne    801d36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d61:	eb 05                	jmp    801d68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6b:	5b                   	pop    %ebx
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	56                   	push   %esi
  801d74:	53                   	push   %ebx
  801d75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7b:	50                   	push   %eax
  801d7c:	e8 20 f6 ff ff       	call   8013a1 <fd_alloc>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	89 c2                	mov    %eax,%edx
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 2c 01 00 00    	js     801eba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	68 07 04 00 00       	push   $0x407
  801d96:	ff 75 f4             	pushl  -0xc(%ebp)
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 7e ed ff ff       	call   800b1e <sys_page_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 0d 01 00 00    	js     801eba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	e8 e8 f5 ff ff       	call   8013a1 <fd_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 e2 00 00 00    	js     801ea8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	68 07 04 00 00       	push   $0x407
  801dce:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 46 ed ff ff       	call   800b1e <sys_page_alloc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 c3 00 00 00    	js     801ea8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	e8 9a f5 ff ff       	call   80138a <fd2data>
  801df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df2:	83 c4 0c             	add    $0xc,%esp
  801df5:	68 07 04 00 00       	push   $0x407
  801dfa:	50                   	push   %eax
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 1c ed ff ff       	call   800b1e <sys_page_alloc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	0f 88 89 00 00 00    	js     801e98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0f:	83 ec 0c             	sub    $0xc,%esp
  801e12:	ff 75 f0             	pushl  -0x10(%ebp)
  801e15:	e8 70 f5 ff ff       	call   80138a <fd2data>
  801e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e21:	50                   	push   %eax
  801e22:	6a 00                	push   $0x0
  801e24:	56                   	push   %esi
  801e25:	6a 00                	push   $0x0
  801e27:	e8 35 ed ff ff       	call   800b61 <sys_page_map>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	83 c4 20             	add    $0x20,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 55                	js     801e8a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	ff 75 f4             	pushl  -0xc(%ebp)
  801e65:	e8 10 f5 ff ff       	call   80137a <fd2num>
  801e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e6f:	83 c4 04             	add    $0x4,%esp
  801e72:	ff 75 f0             	pushl  -0x10(%ebp)
  801e75:	e8 00 f5 ff ff       	call   80137a <fd2num>
  801e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	ba 00 00 00 00       	mov    $0x0,%edx
  801e88:	eb 30                	jmp    801eba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e8a:	83 ec 08             	sub    $0x8,%esp
  801e8d:	56                   	push   %esi
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 0e ed ff ff       	call   800ba3 <sys_page_unmap>
  801e95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 fe ec ff ff       	call   800ba3 <sys_page_unmap>
  801ea5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	ff 75 f4             	pushl  -0xc(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 ee ec ff ff       	call   800ba3 <sys_page_unmap>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eba:	89 d0                	mov    %edx,%eax
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	ff 75 08             	pushl  0x8(%ebp)
  801ed0:	e8 1b f5 ff ff       	call   8013f0 <fd_lookup>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 18                	js     801ef4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801edc:	83 ec 0c             	sub    $0xc,%esp
  801edf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee2:	e8 a3 f4 ff ff       	call   80138a <fd2data>
	return _pipeisclosed(fd, p);
  801ee7:	89 c2                	mov    %eax,%edx
  801ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eec:	e8 18 fd ff ff       	call   801c09 <_pipeisclosed>
  801ef1:	83 c4 10             	add    $0x10,%esp
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f06:	68 56 2a 80 00       	push   $0x802a56
  801f0b:	ff 75 0c             	pushl  0xc(%ebp)
  801f0e:	e8 08 e8 ff ff       	call   80071b <strcpy>
	return 0;
}
  801f13:	b8 00 00 00 00       	mov    $0x0,%eax
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f31:	eb 2d                	jmp    801f60 <devcons_write+0x46>
		m = n - tot;
  801f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	53                   	push   %ebx
  801f47:	03 45 0c             	add    0xc(%ebp),%eax
  801f4a:	50                   	push   %eax
  801f4b:	57                   	push   %edi
  801f4c:	e8 5c e9 ff ff       	call   8008ad <memmove>
		sys_cputs(buf, m);
  801f51:	83 c4 08             	add    $0x8,%esp
  801f54:	53                   	push   %ebx
  801f55:	57                   	push   %edi
  801f56:	e8 07 eb ff ff       	call   800a62 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5b:	01 de                	add    %ebx,%esi
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	89 f0                	mov    %esi,%eax
  801f62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f65:	72 cc                	jb     801f33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 08             	sub    $0x8,%esp
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f7e:	74 2a                	je     801faa <devcons_read+0x3b>
  801f80:	eb 05                	jmp    801f87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f82:	e8 78 eb ff ff       	call   800aff <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f87:	e8 f4 ea ff ff       	call   800a80 <sys_cgetc>
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	74 f2                	je     801f82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 16                	js     801faa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f94:	83 f8 04             	cmp    $0x4,%eax
  801f97:	74 0c                	je     801fa5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f9c:	88 02                	mov    %al,(%edx)
	return 1;
  801f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa3:	eb 05                	jmp    801faa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb8:	6a 01                	push   $0x1
  801fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 9f ea ff ff       	call   800a62 <sys_cputs>
}
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <getchar>:

int
getchar(void)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fce:	6a 01                	push   $0x1
  801fd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd3:	50                   	push   %eax
  801fd4:	6a 00                	push   $0x0
  801fd6:	e8 7e f6 ff ff       	call   801659 <read>
	if (r < 0)
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	78 0f                	js     801ff1 <getchar+0x29>
		return r;
	if (r < 1)
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	7e 06                	jle    801fec <getchar+0x24>
		return -E_EOF;
	return c;
  801fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fea:	eb 05                	jmp    801ff1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	ff 75 08             	pushl  0x8(%ebp)
  802000:	e8 eb f3 ff ff       	call   8013f0 <fd_lookup>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 11                	js     80201d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802015:	39 10                	cmp    %edx,(%eax)
  802017:	0f 94 c0             	sete   %al
  80201a:	0f b6 c0             	movzbl %al,%eax
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <opencons>:

int
opencons(void)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802028:	50                   	push   %eax
  802029:	e8 73 f3 ff ff       	call   8013a1 <fd_alloc>
  80202e:	83 c4 10             	add    $0x10,%esp
		return r;
  802031:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802033:	85 c0                	test   %eax,%eax
  802035:	78 3e                	js     802075 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802037:	83 ec 04             	sub    $0x4,%esp
  80203a:	68 07 04 00 00       	push   $0x407
  80203f:	ff 75 f4             	pushl  -0xc(%ebp)
  802042:	6a 00                	push   $0x0
  802044:	e8 d5 ea ff ff       	call   800b1e <sys_page_alloc>
  802049:	83 c4 10             	add    $0x10,%esp
		return r;
  80204c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 23                	js     802075 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802060:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	50                   	push   %eax
  80206b:	e8 0a f3 ff ff       	call   80137a <fd2num>
  802070:	89 c2                	mov    %eax,%edx
  802072:	83 c4 10             	add    $0x10,%esp
}
  802075:	89 d0                	mov    %edx,%eax
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80207e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802081:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802087:	e8 54 ea ff ff       	call   800ae0 <sys_getenvid>
  80208c:	83 ec 0c             	sub    $0xc,%esp
  80208f:	ff 75 0c             	pushl  0xc(%ebp)
  802092:	ff 75 08             	pushl  0x8(%ebp)
  802095:	56                   	push   %esi
  802096:	50                   	push   %eax
  802097:	68 64 2a 80 00       	push   $0x802a64
  80209c:	e8 f5 e0 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020a1:	83 c4 18             	add    $0x18,%esp
  8020a4:	53                   	push   %ebx
  8020a5:	ff 75 10             	pushl  0x10(%ebp)
  8020a8:	e8 98 e0 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  8020ad:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  8020b4:	e8 dd e0 ff ff       	call   800196 <cprintf>
  8020b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020bc:	cc                   	int3   
  8020bd:	eb fd                	jmp    8020bc <_panic+0x43>

008020bf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	75 12                	jne    8020e3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	68 00 00 c0 ee       	push   $0xeec00000
  8020d9:	e8 f0 eb ff ff       	call   800cce <sys_ipc_recv>
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	eb 0c                	jmp    8020ef <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	50                   	push   %eax
  8020e7:	e8 e2 eb ff ff       	call   800cce <sys_ipc_recv>
  8020ec:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020ef:	85 f6                	test   %esi,%esi
  8020f1:	0f 95 c1             	setne  %cl
  8020f4:	85 db                	test   %ebx,%ebx
  8020f6:	0f 95 c2             	setne  %dl
  8020f9:	84 d1                	test   %dl,%cl
  8020fb:	74 09                	je     802106 <ipc_recv+0x47>
  8020fd:	89 c2                	mov    %eax,%edx
  8020ff:	c1 ea 1f             	shr    $0x1f,%edx
  802102:	84 d2                	test   %dl,%dl
  802104:	75 2d                	jne    802133 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802106:	85 f6                	test   %esi,%esi
  802108:	74 0d                	je     802117 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80210a:	a1 04 40 80 00       	mov    0x804004,%eax
  80210f:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802115:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802117:	85 db                	test   %ebx,%ebx
  802119:	74 0d                	je     802128 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80211b:	a1 04 40 80 00       	mov    0x804004,%eax
  802120:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802126:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802128:	a1 04 40 80 00       	mov    0x804004,%eax
  80212d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802136:	5b                   	pop    %ebx
  802137:	5e                   	pop    %esi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    

0080213a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	57                   	push   %edi
  80213e:	56                   	push   %esi
  80213f:	53                   	push   %ebx
  802140:	83 ec 0c             	sub    $0xc,%esp
  802143:	8b 7d 08             	mov    0x8(%ebp),%edi
  802146:	8b 75 0c             	mov    0xc(%ebp),%esi
  802149:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80214c:	85 db                	test   %ebx,%ebx
  80214e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802153:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802156:	ff 75 14             	pushl  0x14(%ebp)
  802159:	53                   	push   %ebx
  80215a:	56                   	push   %esi
  80215b:	57                   	push   %edi
  80215c:	e8 4a eb ff ff       	call   800cab <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802161:	89 c2                	mov    %eax,%edx
  802163:	c1 ea 1f             	shr    $0x1f,%edx
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	84 d2                	test   %dl,%dl
  80216b:	74 17                	je     802184 <ipc_send+0x4a>
  80216d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802170:	74 12                	je     802184 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802172:	50                   	push   %eax
  802173:	68 88 2a 80 00       	push   $0x802a88
  802178:	6a 47                	push   $0x47
  80217a:	68 96 2a 80 00       	push   $0x802a96
  80217f:	e8 f5 fe ff ff       	call   802079 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802184:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802187:	75 07                	jne    802190 <ipc_send+0x56>
			sys_yield();
  802189:	e8 71 e9 ff ff       	call   800aff <sys_yield>
  80218e:	eb c6                	jmp    802156 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802190:	85 c0                	test   %eax,%eax
  802192:	75 c2                	jne    802156 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021a7:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8021ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b3:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8021b9:	39 ca                	cmp    %ecx,%edx
  8021bb:	75 13                	jne    8021d0 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021bd:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021c8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021ce:	eb 0f                	jmp    8021df <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021d0:	83 c0 01             	add    $0x1,%eax
  8021d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d8:	75 cd                	jne    8021a7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e7:	89 d0                	mov    %edx,%eax
  8021e9:	c1 e8 16             	shr    $0x16,%eax
  8021ec:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f8:	f6 c1 01             	test   $0x1,%cl
  8021fb:	74 1d                	je     80221a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fd:	c1 ea 0c             	shr    $0xc,%edx
  802200:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802207:	f6 c2 01             	test   $0x1,%dl
  80220a:	74 0e                	je     80221a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220c:	c1 ea 0c             	shr    $0xc,%edx
  80220f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802216:	ef 
  802217:	0f b7 c0             	movzwl %ax,%eax
}
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80222b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80222f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 f6                	test   %esi,%esi
  802239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223d:	89 ca                	mov    %ecx,%edx
  80223f:	89 f8                	mov    %edi,%eax
  802241:	75 3d                	jne    802280 <__udivdi3+0x60>
  802243:	39 cf                	cmp    %ecx,%edi
  802245:	0f 87 c5 00 00 00    	ja     802310 <__udivdi3+0xf0>
  80224b:	85 ff                	test   %edi,%edi
  80224d:	89 fd                	mov    %edi,%ebp
  80224f:	75 0b                	jne    80225c <__udivdi3+0x3c>
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	31 d2                	xor    %edx,%edx
  802258:	f7 f7                	div    %edi
  80225a:	89 c5                	mov    %eax,%ebp
  80225c:	89 c8                	mov    %ecx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	f7 f5                	div    %ebp
  802262:	89 c1                	mov    %eax,%ecx
  802264:	89 d8                	mov    %ebx,%eax
  802266:	89 cf                	mov    %ecx,%edi
  802268:	f7 f5                	div    %ebp
  80226a:	89 c3                	mov    %eax,%ebx
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
  802280:	39 ce                	cmp    %ecx,%esi
  802282:	77 74                	ja     8022f8 <__udivdi3+0xd8>
  802284:	0f bd fe             	bsr    %esi,%edi
  802287:	83 f7 1f             	xor    $0x1f,%edi
  80228a:	0f 84 98 00 00 00    	je     802328 <__udivdi3+0x108>
  802290:	bb 20 00 00 00       	mov    $0x20,%ebx
  802295:	89 f9                	mov    %edi,%ecx
  802297:	89 c5                	mov    %eax,%ebp
  802299:	29 fb                	sub    %edi,%ebx
  80229b:	d3 e6                	shl    %cl,%esi
  80229d:	89 d9                	mov    %ebx,%ecx
  80229f:	d3 ed                	shr    %cl,%ebp
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	09 ee                	or     %ebp,%esi
  8022a7:	89 d9                	mov    %ebx,%ecx
  8022a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ad:	89 d5                	mov    %edx,%ebp
  8022af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b3:	d3 ed                	shr    %cl,%ebp
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e2                	shl    %cl,%edx
  8022b9:	89 d9                	mov    %ebx,%ecx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	09 c2                	or     %eax,%edx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	89 ea                	mov    %ebp,%edx
  8022c3:	f7 f6                	div    %esi
  8022c5:	89 d5                	mov    %edx,%ebp
  8022c7:	89 c3                	mov    %eax,%ebx
  8022c9:	f7 64 24 0c          	mull   0xc(%esp)
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	72 10                	jb     8022e1 <__udivdi3+0xc1>
  8022d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e6                	shl    %cl,%esi
  8022d9:	39 c6                	cmp    %eax,%esi
  8022db:	73 07                	jae    8022e4 <__udivdi3+0xc4>
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	75 03                	jne    8022e4 <__udivdi3+0xc4>
  8022e1:	83 eb 01             	sub    $0x1,%ebx
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 d8                	mov    %ebx,%eax
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 ff                	xor    %edi,%edi
  8022fa:	31 db                	xor    %ebx,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d8                	mov    %ebx,%eax
  802312:	f7 f7                	div    %edi
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 c3                	mov    %eax,%ebx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 fa                	mov    %edi,%edx
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	39 ce                	cmp    %ecx,%esi
  80232a:	72 0c                	jb     802338 <__udivdi3+0x118>
  80232c:	31 db                	xor    %ebx,%ebx
  80232e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802332:	0f 87 34 ff ff ff    	ja     80226c <__udivdi3+0x4c>
  802338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80233d:	e9 2a ff ff ff       	jmp    80226c <__udivdi3+0x4c>
  802342:	66 90                	xchg   %ax,%ax
  802344:	66 90                	xchg   %ax,%ax
  802346:	66 90                	xchg   %ax,%ax
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__umoddi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80235f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 d2                	test   %edx,%edx
  802369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 f3                	mov    %esi,%ebx
  802373:	89 3c 24             	mov    %edi,(%esp)
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	75 1c                	jne    802398 <__umoddi3+0x48>
  80237c:	39 f7                	cmp    %esi,%edi
  80237e:	76 50                	jbe    8023d0 <__umoddi3+0x80>
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	f7 f7                	div    %edi
  802386:	89 d0                	mov    %edx,%eax
  802388:	31 d2                	xor    %edx,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	39 f2                	cmp    %esi,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	77 52                	ja     8023f0 <__umoddi3+0xa0>
  80239e:	0f bd ea             	bsr    %edx,%ebp
  8023a1:	83 f5 1f             	xor    $0x1f,%ebp
  8023a4:	75 5a                	jne    802400 <__umoddi3+0xb0>
  8023a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023aa:	0f 82 e0 00 00 00    	jb     802490 <__umoddi3+0x140>
  8023b0:	39 0c 24             	cmp    %ecx,(%esp)
  8023b3:	0f 86 d7 00 00 00    	jbe    802490 <__umoddi3+0x140>
  8023b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	85 ff                	test   %edi,%edi
  8023d2:	89 fd                	mov    %edi,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x91>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f7                	div    %edi
  8023df:	89 c5                	mov    %eax,%ebp
  8023e1:	89 f0                	mov    %esi,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f5                	div    %ebp
  8023e7:	89 c8                	mov    %ecx,%eax
  8023e9:	f7 f5                	div    %ebp
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	eb 99                	jmp    802388 <__umoddi3+0x38>
  8023ef:	90                   	nop
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	83 c4 1c             	add    $0x1c,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	8b 34 24             	mov    (%esp),%esi
  802403:	bf 20 00 00 00       	mov    $0x20,%edi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	29 ef                	sub    %ebp,%edi
  80240c:	d3 e0                	shl    %cl,%eax
  80240e:	89 f9                	mov    %edi,%ecx
  802410:	89 f2                	mov    %esi,%edx
  802412:	d3 ea                	shr    %cl,%edx
  802414:	89 e9                	mov    %ebp,%ecx
  802416:	09 c2                	or     %eax,%edx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 14 24             	mov    %edx,(%esp)
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	d3 e2                	shl    %cl,%edx
  802421:	89 f9                	mov    %edi,%ecx
  802423:	89 54 24 04          	mov    %edx,0x4(%esp)
  802427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	89 c6                	mov    %eax,%esi
  802431:	d3 e3                	shl    %cl,%ebx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 d0                	mov    %edx,%eax
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	09 d8                	or     %ebx,%eax
  80243d:	89 d3                	mov    %edx,%ebx
  80243f:	89 f2                	mov    %esi,%edx
  802441:	f7 34 24             	divl   (%esp)
  802444:	89 d6                	mov    %edx,%esi
  802446:	d3 e3                	shl    %cl,%ebx
  802448:	f7 64 24 04          	mull   0x4(%esp)
  80244c:	39 d6                	cmp    %edx,%esi
  80244e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802452:	89 d1                	mov    %edx,%ecx
  802454:	89 c3                	mov    %eax,%ebx
  802456:	72 08                	jb     802460 <__umoddi3+0x110>
  802458:	75 11                	jne    80246b <__umoddi3+0x11b>
  80245a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80245e:	73 0b                	jae    80246b <__umoddi3+0x11b>
  802460:	2b 44 24 04          	sub    0x4(%esp),%eax
  802464:	1b 14 24             	sbb    (%esp),%edx
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 c3                	mov    %eax,%ebx
  80246b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80246f:	29 da                	sub    %ebx,%edx
  802471:	19 ce                	sbb    %ecx,%esi
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e0                	shl    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	d3 ee                	shr    %cl,%esi
  802481:	09 d0                	or     %edx,%eax
  802483:	89 f2                	mov    %esi,%edx
  802485:	83 c4 1c             	add    $0x1c,%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	29 f9                	sub    %edi,%ecx
  802492:	19 d6                	sbb    %edx,%esi
  802494:	89 74 24 04          	mov    %esi,0x4(%esp)
  802498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80249c:	e9 18 ff ff ff       	jmp    8023b9 <__umoddi3+0x69>
