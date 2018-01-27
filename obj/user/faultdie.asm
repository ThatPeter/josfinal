
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
  800045:	68 00 22 80 00       	push   $0x802200
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
  80006c:	e8 de 0c 00 00       	call   800d4f <set_pgfault_handler>
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
  800095:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000ef:	e8 a9 11 00 00       	call   80129d <close_all>
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
  8001f9:	e8 72 1d 00 00       	call   801f70 <__udivdi3>
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
  80023c:	e8 5f 1e 00 00       	call   8020a0 <__umoddi3>
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	0f be 80 26 22 80 00 	movsbl 0x802226(%eax),%eax
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
  800340:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
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
  800404:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80040b:	85 d2                	test   %edx,%edx
  80040d:	75 18                	jne    800427 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040f:	50                   	push   %eax
  800410:	68 3e 22 80 00       	push   $0x80223e
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
  800428:	68 7d 26 80 00       	push   $0x80267d
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
  80044c:	b8 37 22 80 00       	mov    $0x802237,%eax
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
  800ac7:	68 1f 25 80 00       	push   $0x80251f
  800acc:	6a 23                	push   $0x23
  800ace:	68 3c 25 80 00       	push   $0x80253c
  800ad3:	e8 ed 12 00 00       	call   801dc5 <_panic>

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
  800b48:	68 1f 25 80 00       	push   $0x80251f
  800b4d:	6a 23                	push   $0x23
  800b4f:	68 3c 25 80 00       	push   $0x80253c
  800b54:	e8 6c 12 00 00       	call   801dc5 <_panic>

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
  800b8a:	68 1f 25 80 00       	push   $0x80251f
  800b8f:	6a 23                	push   $0x23
  800b91:	68 3c 25 80 00       	push   $0x80253c
  800b96:	e8 2a 12 00 00       	call   801dc5 <_panic>

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
  800bcc:	68 1f 25 80 00       	push   $0x80251f
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 3c 25 80 00       	push   $0x80253c
  800bd8:	e8 e8 11 00 00       	call   801dc5 <_panic>

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
  800c0e:	68 1f 25 80 00       	push   $0x80251f
  800c13:	6a 23                	push   $0x23
  800c15:	68 3c 25 80 00       	push   $0x80253c
  800c1a:	e8 a6 11 00 00       	call   801dc5 <_panic>

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
  800c50:	68 1f 25 80 00       	push   $0x80251f
  800c55:	6a 23                	push   $0x23
  800c57:	68 3c 25 80 00       	push   $0x80253c
  800c5c:	e8 64 11 00 00       	call   801dc5 <_panic>
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
  800c92:	68 1f 25 80 00       	push   $0x80251f
  800c97:	6a 23                	push   $0x23
  800c99:	68 3c 25 80 00       	push   $0x80253c
  800c9e:	e8 22 11 00 00       	call   801dc5 <_panic>

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
  800cf6:	68 1f 25 80 00       	push   $0x80251f
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 3c 25 80 00       	push   $0x80253c
  800d02:	e8 be 10 00 00       	call   801dc5 <_panic>

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

00800d4f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d55:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d5c:	75 2a                	jne    800d88 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800d5e:	83 ec 04             	sub    $0x4,%esp
  800d61:	6a 07                	push   $0x7
  800d63:	68 00 f0 bf ee       	push   $0xeebff000
  800d68:	6a 00                	push   $0x0
  800d6a:	e8 af fd ff ff       	call   800b1e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800d6f:	83 c4 10             	add    $0x10,%esp
  800d72:	85 c0                	test   %eax,%eax
  800d74:	79 12                	jns    800d88 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800d76:	50                   	push   %eax
  800d77:	68 4a 25 80 00       	push   $0x80254a
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 4e 25 80 00       	push   $0x80254e
  800d83:	e8 3d 10 00 00       	call   801dc5 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800d90:	83 ec 08             	sub    $0x8,%esp
  800d93:	68 ba 0d 80 00       	push   $0x800dba
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 ca fe ff ff       	call   800c69 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	79 12                	jns    800db8 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800da6:	50                   	push   %eax
  800da7:	68 4a 25 80 00       	push   $0x80254a
  800dac:	6a 2c                	push   $0x2c
  800dae:	68 4e 25 80 00       	push   $0x80254e
  800db3:	e8 0d 10 00 00       	call   801dc5 <_panic>
	}
}
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dbb:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dc0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dc2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800dc5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800dc9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800dce:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800dd2:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800dd4:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800dd7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800dd8:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800ddb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800ddc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ddd:	c3                   	ret    

00800dde <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	53                   	push   %ebx
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dea:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dee:	74 11                	je     800e01 <pgfault+0x23>
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	c1 e8 0c             	shr    $0xc,%eax
  800df5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfc:	f6 c4 08             	test   $0x8,%ah
  800dff:	75 14                	jne    800e15 <pgfault+0x37>
		panic("faulting access");
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	68 5c 25 80 00       	push   $0x80255c
  800e09:	6a 1e                	push   $0x1e
  800e0b:	68 6c 25 80 00       	push   $0x80256c
  800e10:	e8 b0 0f 00 00       	call   801dc5 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	6a 07                	push   $0x7
  800e1a:	68 00 f0 7f 00       	push   $0x7ff000
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 f8 fc ff ff       	call   800b1e <sys_page_alloc>
	if (r < 0) {
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	79 12                	jns    800e3f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e2d:	50                   	push   %eax
  800e2e:	68 77 25 80 00       	push   $0x802577
  800e33:	6a 2c                	push   $0x2c
  800e35:	68 6c 25 80 00       	push   $0x80256c
  800e3a:	e8 86 0f 00 00       	call   801dc5 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	68 00 10 00 00       	push   $0x1000
  800e4d:	53                   	push   %ebx
  800e4e:	68 00 f0 7f 00       	push   $0x7ff000
  800e53:	e8 bd fa ff ff       	call   800915 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e58:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5f:	53                   	push   %ebx
  800e60:	6a 00                	push   $0x0
  800e62:	68 00 f0 7f 00       	push   $0x7ff000
  800e67:	6a 00                	push   $0x0
  800e69:	e8 f3 fc ff ff       	call   800b61 <sys_page_map>
	if (r < 0) {
  800e6e:	83 c4 20             	add    $0x20,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	79 12                	jns    800e87 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e75:	50                   	push   %eax
  800e76:	68 77 25 80 00       	push   $0x802577
  800e7b:	6a 33                	push   $0x33
  800e7d:	68 6c 25 80 00       	push   $0x80256c
  800e82:	e8 3e 0f 00 00       	call   801dc5 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e87:	83 ec 08             	sub    $0x8,%esp
  800e8a:	68 00 f0 7f 00       	push   $0x7ff000
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 0d fd ff ff       	call   800ba3 <sys_page_unmap>
	if (r < 0) {
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	79 12                	jns    800eaf <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e9d:	50                   	push   %eax
  800e9e:	68 77 25 80 00       	push   $0x802577
  800ea3:	6a 37                	push   $0x37
  800ea5:	68 6c 25 80 00       	push   $0x80256c
  800eaa:	e8 16 0f 00 00       	call   801dc5 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800eaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ebd:	68 de 0d 80 00       	push   $0x800dde
  800ec2:	e8 88 fe ff ff       	call   800d4f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec7:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecc:	cd 30                	int    $0x30
  800ece:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	79 17                	jns    800eef <fork+0x3b>
		panic("fork fault %e");
  800ed8:	83 ec 04             	sub    $0x4,%esp
  800edb:	68 90 25 80 00       	push   $0x802590
  800ee0:	68 84 00 00 00       	push   $0x84
  800ee5:	68 6c 25 80 00       	push   $0x80256c
  800eea:	e8 d6 0e 00 00       	call   801dc5 <_panic>
  800eef:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ef1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef5:	75 24                	jne    800f1b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef7:	e8 e4 fb ff ff       	call   800ae0 <sys_getenvid>
  800efc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f01:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f07:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f0c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
  800f16:	e9 64 01 00 00       	jmp    80107f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f1b:	83 ec 04             	sub    $0x4,%esp
  800f1e:	6a 07                	push   $0x7
  800f20:	68 00 f0 bf ee       	push   $0xeebff000
  800f25:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f28:	e8 f1 fb ff ff       	call   800b1e <sys_page_alloc>
  800f2d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f35:	89 d8                	mov    %ebx,%eax
  800f37:	c1 e8 16             	shr    $0x16,%eax
  800f3a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f41:	a8 01                	test   $0x1,%al
  800f43:	0f 84 fc 00 00 00    	je     801045 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	c1 e8 0c             	shr    $0xc,%eax
  800f4e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	0f 84 e7 00 00 00    	je     801045 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f5e:	89 c6                	mov    %eax,%esi
  800f60:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f63:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6a:	f6 c6 04             	test   $0x4,%dh
  800f6d:	74 39                	je     800fa8 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f6f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f76:	83 ec 0c             	sub    $0xc,%esp
  800f79:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7e:	50                   	push   %eax
  800f7f:	56                   	push   %esi
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 d8 fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	0f 89 b1 00 00 00    	jns    801045 <fork+0x191>
		    	panic("sys page map fault %e");
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	68 9e 25 80 00       	push   $0x80259e
  800f9c:	6a 54                	push   $0x54
  800f9e:	68 6c 25 80 00       	push   $0x80256c
  800fa3:	e8 1d 0e 00 00       	call   801dc5 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fa8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800faf:	f6 c2 02             	test   $0x2,%dl
  800fb2:	75 0c                	jne    800fc0 <fork+0x10c>
  800fb4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbb:	f6 c4 08             	test   $0x8,%ah
  800fbe:	74 5b                	je     80101b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	68 05 08 00 00       	push   $0x805
  800fc8:	56                   	push   %esi
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 8f fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 14                	jns    800fed <fork+0x139>
		    	panic("sys page map fault %e");
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 9e 25 80 00       	push   $0x80259e
  800fe1:	6a 5b                	push   $0x5b
  800fe3:	68 6c 25 80 00       	push   $0x80256c
  800fe8:	e8 d8 0d 00 00       	call   801dc5 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	68 05 08 00 00       	push   $0x805
  800ff5:	56                   	push   %esi
  800ff6:	6a 00                	push   $0x0
  800ff8:	56                   	push   %esi
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 61 fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 3e                	jns    801045 <fork+0x191>
		    	panic("sys page map fault %e");
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	68 9e 25 80 00       	push   $0x80259e
  80100f:	6a 5f                	push   $0x5f
  801011:	68 6c 25 80 00       	push   $0x80256c
  801016:	e8 aa 0d 00 00       	call   801dc5 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	6a 05                	push   $0x5
  801020:	56                   	push   %esi
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	e8 37 fb ff ff       	call   800b61 <sys_page_map>
		if (r < 0) {
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 14                	jns    801045 <fork+0x191>
		    	panic("sys page map fault %e");
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	68 9e 25 80 00       	push   $0x80259e
  801039:	6a 64                	push   $0x64
  80103b:	68 6c 25 80 00       	push   $0x80256c
  801040:	e8 80 0d 00 00       	call   801dc5 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801045:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80104b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801051:	0f 85 de fe ff ff    	jne    800f35 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801057:	a1 04 40 80 00       	mov    0x804004,%eax
  80105c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801062:	83 ec 08             	sub    $0x8,%esp
  801065:	50                   	push   %eax
  801066:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801069:	57                   	push   %edi
  80106a:	e8 fa fb ff ff       	call   800c69 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	6a 02                	push   $0x2
  801074:	57                   	push   %edi
  801075:	e8 6b fb ff ff       	call   800be5 <sys_env_set_status>
	
	return envid;
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <sfork>:

envid_t
sfork(void)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80108a:	b8 00 00 00 00       	mov    $0x0,%eax
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801099:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	53                   	push   %ebx
  8010a3:	68 b4 25 80 00       	push   $0x8025b4
  8010a8:	e8 e9 f0 ff ff       	call   800196 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010ad:	c7 04 24 c9 00 80 00 	movl   $0x8000c9,(%esp)
  8010b4:	e8 56 fc ff ff       	call   800d0f <sys_thread_create>
  8010b9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	53                   	push   %ebx
  8010bf:	68 b4 25 80 00       	push   $0x8025b4
  8010c4:	e8 cd f0 ff ff       	call   800196 <cprintf>
	return id;
}
  8010c9:	89 f0                	mov    %esi,%eax
  8010cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dd:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801104:	89 c2                	mov    %eax,%edx
  801106:	c1 ea 16             	shr    $0x16,%edx
  801109:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801110:	f6 c2 01             	test   $0x1,%dl
  801113:	74 11                	je     801126 <fd_alloc+0x2d>
  801115:	89 c2                	mov    %eax,%edx
  801117:	c1 ea 0c             	shr    $0xc,%edx
  80111a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801121:	f6 c2 01             	test   $0x1,%dl
  801124:	75 09                	jne    80112f <fd_alloc+0x36>
			*fd_store = fd;
  801126:	89 01                	mov    %eax,(%ecx)
			return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 17                	jmp    801146 <fd_alloc+0x4d>
  80112f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801134:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801139:	75 c9                	jne    801104 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801141:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114e:	83 f8 1f             	cmp    $0x1f,%eax
  801151:	77 36                	ja     801189 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801153:	c1 e0 0c             	shl    $0xc,%eax
  801156:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 ea 16             	shr    $0x16,%edx
  801160:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801167:	f6 c2 01             	test   $0x1,%dl
  80116a:	74 24                	je     801190 <fd_lookup+0x48>
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	c1 ea 0c             	shr    $0xc,%edx
  801171:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801178:	f6 c2 01             	test   $0x1,%dl
  80117b:	74 1a                	je     801197 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801180:	89 02                	mov    %eax,(%edx)
	return 0;
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	eb 13                	jmp    80119c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118e:	eb 0c                	jmp    80119c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801195:	eb 05                	jmp    80119c <fd_lookup+0x54>
  801197:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a7:	ba 54 26 80 00       	mov    $0x802654,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ac:	eb 13                	jmp    8011c1 <dev_lookup+0x23>
  8011ae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b1:	39 08                	cmp    %ecx,(%eax)
  8011b3:	75 0c                	jne    8011c1 <dev_lookup+0x23>
			*dev = devtab[i];
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bf:	eb 2e                	jmp    8011ef <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	75 e7                	jne    8011ae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cc:	8b 40 7c             	mov    0x7c(%eax),%eax
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	51                   	push   %ecx
  8011d3:	50                   	push   %eax
  8011d4:	68 d8 25 80 00       	push   $0x8025d8
  8011d9:	e8 b8 ef ff ff       	call   800196 <cprintf>
	*dev = 0;
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 10             	sub    $0x10,%esp
  8011f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801209:	c1 e8 0c             	shr    $0xc,%eax
  80120c:	50                   	push   %eax
  80120d:	e8 36 ff ff ff       	call   801148 <fd_lookup>
  801212:	83 c4 08             	add    $0x8,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 05                	js     80121e <fd_close+0x2d>
	    || fd != fd2)
  801219:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121c:	74 0c                	je     80122a <fd_close+0x39>
		return (must_exist ? r : 0);
  80121e:	84 db                	test   %bl,%bl
  801220:	ba 00 00 00 00       	mov    $0x0,%edx
  801225:	0f 44 c2             	cmove  %edx,%eax
  801228:	eb 41                	jmp    80126b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 36                	pushl  (%esi)
  801233:	e8 66 ff ff ff       	call   80119e <dev_lookup>
  801238:	89 c3                	mov    %eax,%ebx
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 1a                	js     80125b <fd_close+0x6a>
		if (dev->dev_close)
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801247:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	74 0b                	je     80125b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801250:	83 ec 0c             	sub    $0xc,%esp
  801253:	56                   	push   %esi
  801254:	ff d0                	call   *%eax
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	56                   	push   %esi
  80125f:	6a 00                	push   $0x0
  801261:	e8 3d f9 ff ff       	call   800ba3 <sys_page_unmap>
	return r;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	89 d8                	mov    %ebx,%eax
}
  80126b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 c4 fe ff ff       	call   801148 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 10                	js     80129b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	6a 01                	push   $0x1
  801290:	ff 75 f4             	pushl  -0xc(%ebp)
  801293:	e8 59 ff ff ff       	call   8011f1 <fd_close>
  801298:	83 c4 10             	add    $0x10,%esp
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <close_all>:

void
close_all(void)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	e8 c0 ff ff ff       	call   801272 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b2:	83 c3 01             	add    $0x1,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	83 fb 20             	cmp    $0x20,%ebx
  8012bb:	75 ec                	jne    8012a9 <close_all+0xc>
		close(i);
}
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 2c             	sub    $0x2c,%esp
  8012cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	ff 75 08             	pushl  0x8(%ebp)
  8012d5:	e8 6e fe ff ff       	call   801148 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	0f 88 c1 00 00 00    	js     8013a6 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	56                   	push   %esi
  8012e9:	e8 84 ff ff ff       	call   801272 <close>

	newfd = INDEX2FD(newfdnum);
  8012ee:	89 f3                	mov    %esi,%ebx
  8012f0:	c1 e3 0c             	shl    $0xc,%ebx
  8012f3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f9:	83 c4 04             	add    $0x4,%esp
  8012fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ff:	e8 de fd ff ff       	call   8010e2 <fd2data>
  801304:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801306:	89 1c 24             	mov    %ebx,(%esp)
  801309:	e8 d4 fd ff ff       	call   8010e2 <fd2data>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801314:	89 f8                	mov    %edi,%eax
  801316:	c1 e8 16             	shr    $0x16,%eax
  801319:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801320:	a8 01                	test   $0x1,%al
  801322:	74 37                	je     80135b <dup+0x99>
  801324:	89 f8                	mov    %edi,%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
  801329:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801330:	f6 c2 01             	test   $0x1,%dl
  801333:	74 26                	je     80135b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	25 07 0e 00 00       	and    $0xe07,%eax
  801344:	50                   	push   %eax
  801345:	ff 75 d4             	pushl  -0x2c(%ebp)
  801348:	6a 00                	push   $0x0
  80134a:	57                   	push   %edi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 0f f8 ff ff       	call   800b61 <sys_page_map>
  801352:	89 c7                	mov    %eax,%edi
  801354:	83 c4 20             	add    $0x20,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 2e                	js     801389 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135e:	89 d0                	mov    %edx,%eax
  801360:	c1 e8 0c             	shr    $0xc,%eax
  801363:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	25 07 0e 00 00       	and    $0xe07,%eax
  801372:	50                   	push   %eax
  801373:	53                   	push   %ebx
  801374:	6a 00                	push   $0x0
  801376:	52                   	push   %edx
  801377:	6a 00                	push   $0x0
  801379:	e8 e3 f7 ff ff       	call   800b61 <sys_page_map>
  80137e:	89 c7                	mov    %eax,%edi
  801380:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801383:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801385:	85 ff                	test   %edi,%edi
  801387:	79 1d                	jns    8013a6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	53                   	push   %ebx
  80138d:	6a 00                	push   $0x0
  80138f:	e8 0f f8 ff ff       	call   800ba3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139a:	6a 00                	push   $0x0
  80139c:	e8 02 f8 ff ff       	call   800ba3 <sys_page_unmap>
	return r;
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	89 f8                	mov    %edi,%eax
}
  8013a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a9:	5b                   	pop    %ebx
  8013aa:	5e                   	pop    %esi
  8013ab:	5f                   	pop    %edi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 14             	sub    $0x14,%esp
  8013b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	53                   	push   %ebx
  8013bd:	e8 86 fd ff ff       	call   801148 <fd_lookup>
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 6d                	js     801438 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	ff 30                	pushl  (%eax)
  8013d7:	e8 c2 fd ff ff       	call   80119e <dev_lookup>
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 4c                	js     80142f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e6:	8b 42 08             	mov    0x8(%edx),%eax
  8013e9:	83 e0 03             	and    $0x3,%eax
  8013ec:	83 f8 01             	cmp    $0x1,%eax
  8013ef:	75 21                	jne    801412 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f6:	8b 40 7c             	mov    0x7c(%eax),%eax
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	53                   	push   %ebx
  8013fd:	50                   	push   %eax
  8013fe:	68 19 26 80 00       	push   $0x802619
  801403:	e8 8e ed ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801410:	eb 26                	jmp    801438 <read+0x8a>
	}
	if (!dev->dev_read)
  801412:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801415:	8b 40 08             	mov    0x8(%eax),%eax
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 17                	je     801433 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	ff 75 10             	pushl  0x10(%ebp)
  801422:	ff 75 0c             	pushl  0xc(%ebp)
  801425:	52                   	push   %edx
  801426:	ff d0                	call   *%eax
  801428:	89 c2                	mov    %eax,%edx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb 09                	jmp    801438 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	89 c2                	mov    %eax,%edx
  801431:	eb 05                	jmp    801438 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801433:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801438:	89 d0                	mov    %edx,%eax
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801453:	eb 21                	jmp    801476 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	89 f0                	mov    %esi,%eax
  80145a:	29 d8                	sub    %ebx,%eax
  80145c:	50                   	push   %eax
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	03 45 0c             	add    0xc(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	57                   	push   %edi
  801464:	e8 45 ff ff ff       	call   8013ae <read>
		if (m < 0)
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 10                	js     801480 <readn+0x41>
			return m;
		if (m == 0)
  801470:	85 c0                	test   %eax,%eax
  801472:	74 0a                	je     80147e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	01 c3                	add    %eax,%ebx
  801476:	39 f3                	cmp    %esi,%ebx
  801478:	72 db                	jb     801455 <readn+0x16>
  80147a:	89 d8                	mov    %ebx,%eax
  80147c:	eb 02                	jmp    801480 <readn+0x41>
  80147e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	53                   	push   %ebx
  801497:	e8 ac fc ff ff       	call   801148 <fd_lookup>
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 68                	js     80150d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	ff 30                	pushl  (%eax)
  8014b1:	e8 e8 fc ff ff       	call   80119e <dev_lookup>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 47                	js     801504 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c4:	75 21                	jne    8014e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014cb:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014ce:	83 ec 04             	sub    $0x4,%esp
  8014d1:	53                   	push   %ebx
  8014d2:	50                   	push   %eax
  8014d3:	68 35 26 80 00       	push   $0x802635
  8014d8:	e8 b9 ec ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e5:	eb 26                	jmp    80150d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ed:	85 d2                	test   %edx,%edx
  8014ef:	74 17                	je     801508 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f1:	83 ec 04             	sub    $0x4,%esp
  8014f4:	ff 75 10             	pushl  0x10(%ebp)
  8014f7:	ff 75 0c             	pushl  0xc(%ebp)
  8014fa:	50                   	push   %eax
  8014fb:	ff d2                	call   *%edx
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	eb 09                	jmp    80150d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801504:	89 c2                	mov    %eax,%edx
  801506:	eb 05                	jmp    80150d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801508:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150d:	89 d0                	mov    %edx,%eax
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <seek>:

int
seek(int fdnum, off_t offset)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	ff 75 08             	pushl  0x8(%ebp)
  801521:	e8 22 fc ff ff       	call   801148 <fd_lookup>
  801526:	83 c4 08             	add    $0x8,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 0e                	js     80153b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801530:	8b 55 0c             	mov    0xc(%ebp),%edx
  801533:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 14             	sub    $0x14,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	53                   	push   %ebx
  80154c:	e8 f7 fb ff ff       	call   801148 <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	89 c2                	mov    %eax,%edx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 65                	js     8015bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 33 fc ff ff       	call   80119e <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 44                	js     8015b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801579:	75 21                	jne    80159c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801580:	8b 40 7c             	mov    0x7c(%eax),%eax
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	50                   	push   %eax
  801588:	68 f8 25 80 00       	push   $0x8025f8
  80158d:	e8 04 ec ff ff       	call   800196 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159a:	eb 23                	jmp    8015bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	8b 52 18             	mov    0x18(%edx),%edx
  8015a2:	85 d2                	test   %edx,%edx
  8015a4:	74 14                	je     8015ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	50                   	push   %eax
  8015ad:	ff d2                	call   *%edx
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb 09                	jmp    8015bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	eb 05                	jmp    8015bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 14             	sub    $0x14,%esp
  8015cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	ff 75 08             	pushl  0x8(%ebp)
  8015d7:	e8 6c fb ff ff       	call   801148 <fd_lookup>
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 58                	js     80163d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ef:	ff 30                	pushl  (%eax)
  8015f1:	e8 a8 fb ff ff       	call   80119e <dev_lookup>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 37                	js     801634 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801604:	74 32                	je     801638 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801606:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801609:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801610:	00 00 00 
	stat->st_isdir = 0;
  801613:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161a:	00 00 00 
	stat->st_dev = dev;
  80161d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	ff 75 f0             	pushl  -0x10(%ebp)
  80162a:	ff 50 14             	call   *0x14(%eax)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 09                	jmp    80163d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	89 c2                	mov    %eax,%edx
  801636:	eb 05                	jmp    80163d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801638:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163d:	89 d0                	mov    %edx,%eax
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	6a 00                	push   $0x0
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 e3 01 00 00       	call   801839 <open>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1b                	js     80167a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	50                   	push   %eax
  801666:	e8 5b ff ff ff       	call   8015c6 <fstat>
  80166b:	89 c6                	mov    %eax,%esi
	close(fd);
  80166d:	89 1c 24             	mov    %ebx,(%esp)
  801670:	e8 fd fb ff ff       	call   801272 <close>
	return r;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	89 f0                	mov    %esi,%eax
}
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	89 c6                	mov    %eax,%esi
  801688:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80168a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801691:	75 12                	jne    8016a5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	6a 01                	push   $0x1
  801698:	e8 4b 08 00 00       	call   801ee8 <ipc_find_env>
  80169d:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a5:	6a 07                	push   $0x7
  8016a7:	68 00 50 80 00       	push   $0x805000
  8016ac:	56                   	push   %esi
  8016ad:	ff 35 00 40 80 00    	pushl  0x804000
  8016b3:	e8 ce 07 00 00       	call   801e86 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b8:	83 c4 0c             	add    $0xc,%esp
  8016bb:	6a 00                	push   $0x0
  8016bd:	53                   	push   %ebx
  8016be:	6a 00                	push   $0x0
  8016c0:	e8 46 07 00 00       	call   801e0b <ipc_recv>
}
  8016c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ef:	e8 8d ff ff ff       	call   801681 <fsipc>
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801707:	ba 00 00 00 00       	mov    $0x0,%edx
  80170c:	b8 06 00 00 00       	mov    $0x6,%eax
  801711:	e8 6b ff ff ff       	call   801681 <fsipc>
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 05 00 00 00       	mov    $0x5,%eax
  801737:	e8 45 ff ff ff       	call   801681 <fsipc>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 2c                	js     80176c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	68 00 50 80 00       	push   $0x805000
  801748:	53                   	push   %ebx
  801749:	e8 cd ef ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174e:	a1 80 50 80 00       	mov    0x805080,%eax
  801753:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801759:	a1 84 50 80 00       	mov    0x805084,%eax
  80175e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80177a:	8b 55 08             	mov    0x8(%ebp),%edx
  80177d:	8b 52 0c             	mov    0xc(%edx),%edx
  801780:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801786:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80178b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801790:	0f 47 c2             	cmova  %edx,%eax
  801793:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801798:	50                   	push   %eax
  801799:	ff 75 0c             	pushl  0xc(%ebp)
  80179c:	68 08 50 80 00       	push   $0x805008
  8017a1:	e8 07 f1 ff ff       	call   8008ad <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8017b0:	e8 cc fe ff ff       	call   801681 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ca:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 03 00 00 00       	mov    $0x3,%eax
  8017da:	e8 a2 fe ff ff       	call   801681 <fsipc>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 4b                	js     801830 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e5:	39 c6                	cmp    %eax,%esi
  8017e7:	73 16                	jae    8017ff <devfile_read+0x48>
  8017e9:	68 64 26 80 00       	push   $0x802664
  8017ee:	68 6b 26 80 00       	push   $0x80266b
  8017f3:	6a 7c                	push   $0x7c
  8017f5:	68 80 26 80 00       	push   $0x802680
  8017fa:	e8 c6 05 00 00       	call   801dc5 <_panic>
	assert(r <= PGSIZE);
  8017ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801804:	7e 16                	jle    80181c <devfile_read+0x65>
  801806:	68 8b 26 80 00       	push   $0x80268b
  80180b:	68 6b 26 80 00       	push   $0x80266b
  801810:	6a 7d                	push   $0x7d
  801812:	68 80 26 80 00       	push   $0x802680
  801817:	e8 a9 05 00 00       	call   801dc5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	50                   	push   %eax
  801820:	68 00 50 80 00       	push   $0x805000
  801825:	ff 75 0c             	pushl  0xc(%ebp)
  801828:	e8 80 f0 ff ff       	call   8008ad <memmove>
	return r;
  80182d:	83 c4 10             	add    $0x10,%esp
}
  801830:	89 d8                	mov    %ebx,%eax
  801832:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801835:	5b                   	pop    %ebx
  801836:	5e                   	pop    %esi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	53                   	push   %ebx
  80183d:	83 ec 20             	sub    $0x20,%esp
  801840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801843:	53                   	push   %ebx
  801844:	e8 99 ee ff ff       	call   8006e2 <strlen>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801851:	7f 67                	jg     8018ba <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	e8 9a f8 ff ff       	call   8010f9 <fd_alloc>
  80185f:	83 c4 10             	add    $0x10,%esp
		return r;
  801862:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801864:	85 c0                	test   %eax,%eax
  801866:	78 57                	js     8018bf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	53                   	push   %ebx
  80186c:	68 00 50 80 00       	push   $0x805000
  801871:	e8 a5 ee ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801876:	8b 45 0c             	mov    0xc(%ebp),%eax
  801879:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801881:	b8 01 00 00 00       	mov    $0x1,%eax
  801886:	e8 f6 fd ff ff       	call   801681 <fsipc>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	79 14                	jns    8018a8 <open+0x6f>
		fd_close(fd, 0);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	6a 00                	push   $0x0
  801899:	ff 75 f4             	pushl  -0xc(%ebp)
  80189c:	e8 50 f9 ff ff       	call   8011f1 <fd_close>
		return r;
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	89 da                	mov    %ebx,%edx
  8018a6:	eb 17                	jmp    8018bf <open+0x86>
	}

	return fd2num(fd);
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 1f f8 ff ff       	call   8010d2 <fd2num>
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 05                	jmp    8018bf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ba:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018bf:	89 d0                	mov    %edx,%eax
  8018c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d6:	e8 a6 fd ff ff       	call   801681 <fsipc>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	ff 75 08             	pushl  0x8(%ebp)
  8018eb:	e8 f2 f7 ff ff       	call   8010e2 <fd2data>
  8018f0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018f2:	83 c4 08             	add    $0x8,%esp
  8018f5:	68 97 26 80 00       	push   $0x802697
  8018fa:	53                   	push   %ebx
  8018fb:	e8 1b ee ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801900:	8b 46 04             	mov    0x4(%esi),%eax
  801903:	2b 06                	sub    (%esi),%eax
  801905:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80190b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801912:	00 00 00 
	stat->st_dev = &devpipe;
  801915:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80191c:	30 80 00 
	return 0;
}
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
  801924:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	53                   	push   %ebx
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801935:	53                   	push   %ebx
  801936:	6a 00                	push   $0x0
  801938:	e8 66 f2 ff ff       	call   800ba3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80193d:	89 1c 24             	mov    %ebx,(%esp)
  801940:	e8 9d f7 ff ff       	call   8010e2 <fd2data>
  801945:	83 c4 08             	add    $0x8,%esp
  801948:	50                   	push   %eax
  801949:	6a 00                	push   $0x0
  80194b:	e8 53 f2 ff ff       	call   800ba3 <sys_page_unmap>
}
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	83 ec 1c             	sub    $0x1c,%esp
  80195e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801961:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801963:	a1 04 40 80 00       	mov    0x804004,%eax
  801968:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	ff 75 e0             	pushl  -0x20(%ebp)
  801974:	e8 b1 05 00 00       	call   801f2a <pageref>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	89 3c 24             	mov    %edi,(%esp)
  80197e:	e8 a7 05 00 00       	call   801f2a <pageref>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	39 c3                	cmp    %eax,%ebx
  801988:	0f 94 c1             	sete   %cl
  80198b:	0f b6 c9             	movzbl %cl,%ecx
  80198e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801991:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801997:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  80199d:	39 ce                	cmp    %ecx,%esi
  80199f:	74 1e                	je     8019bf <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8019a1:	39 c3                	cmp    %eax,%ebx
  8019a3:	75 be                	jne    801963 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019a5:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  8019ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019ae:	50                   	push   %eax
  8019af:	56                   	push   %esi
  8019b0:	68 9e 26 80 00       	push   $0x80269e
  8019b5:	e8 dc e7 ff ff       	call   800196 <cprintf>
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	eb a4                	jmp    801963 <_pipeisclosed+0xe>
	}
}
  8019bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5f                   	pop    %edi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	57                   	push   %edi
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 28             	sub    $0x28,%esp
  8019d3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019d6:	56                   	push   %esi
  8019d7:	e8 06 f7 ff ff       	call   8010e2 <fd2data>
  8019dc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e6:	eb 4b                	jmp    801a33 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019e8:	89 da                	mov    %ebx,%edx
  8019ea:	89 f0                	mov    %esi,%eax
  8019ec:	e8 64 ff ff ff       	call   801955 <_pipeisclosed>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	75 48                	jne    801a3d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019f5:	e8 05 f1 ff ff       	call   800aff <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8019fd:	8b 0b                	mov    (%ebx),%ecx
  8019ff:	8d 51 20             	lea    0x20(%ecx),%edx
  801a02:	39 d0                	cmp    %edx,%eax
  801a04:	73 e2                	jae    8019e8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a09:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a0d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	c1 fa 1f             	sar    $0x1f,%edx
  801a15:	89 d1                	mov    %edx,%ecx
  801a17:	c1 e9 1b             	shr    $0x1b,%ecx
  801a1a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a1d:	83 e2 1f             	and    $0x1f,%edx
  801a20:	29 ca                	sub    %ecx,%edx
  801a22:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a26:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a2a:	83 c0 01             	add    $0x1,%eax
  801a2d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a30:	83 c7 01             	add    $0x1,%edi
  801a33:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a36:	75 c2                	jne    8019fa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a38:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3b:	eb 05                	jmp    801a42 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5f                   	pop    %edi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	57                   	push   %edi
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 18             	sub    $0x18,%esp
  801a53:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a56:	57                   	push   %edi
  801a57:	e8 86 f6 ff ff       	call   8010e2 <fd2data>
  801a5c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a66:	eb 3d                	jmp    801aa5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	74 04                	je     801a70 <devpipe_read+0x26>
				return i;
  801a6c:	89 d8                	mov    %ebx,%eax
  801a6e:	eb 44                	jmp    801ab4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a70:	89 f2                	mov    %esi,%edx
  801a72:	89 f8                	mov    %edi,%eax
  801a74:	e8 dc fe ff ff       	call   801955 <_pipeisclosed>
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	75 32                	jne    801aaf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a7d:	e8 7d f0 ff ff       	call   800aff <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a82:	8b 06                	mov    (%esi),%eax
  801a84:	3b 46 04             	cmp    0x4(%esi),%eax
  801a87:	74 df                	je     801a68 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a89:	99                   	cltd   
  801a8a:	c1 ea 1b             	shr    $0x1b,%edx
  801a8d:	01 d0                	add    %edx,%eax
  801a8f:	83 e0 1f             	and    $0x1f,%eax
  801a92:	29 d0                	sub    %edx,%eax
  801a94:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a9f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa2:	83 c3 01             	add    $0x1,%ebx
  801aa5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aa8:	75 d8                	jne    801a82 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  801aad:	eb 05                	jmp    801ab4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ac4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac7:	50                   	push   %eax
  801ac8:	e8 2c f6 ff ff       	call   8010f9 <fd_alloc>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	89 c2                	mov    %eax,%edx
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	0f 88 2c 01 00 00    	js     801c06 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	68 07 04 00 00       	push   $0x407
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 32 f0 ff ff       	call   800b1e <sys_page_alloc>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	85 c0                	test   %eax,%eax
  801af3:	0f 88 0d 01 00 00    	js     801c06 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aff:	50                   	push   %eax
  801b00:	e8 f4 f5 ff ff       	call   8010f9 <fd_alloc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	0f 88 e2 00 00 00    	js     801bf4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	68 07 04 00 00       	push   $0x407
  801b1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 fa ef ff ff       	call   800b1e <sys_page_alloc>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	0f 88 c3 00 00 00    	js     801bf4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	ff 75 f4             	pushl  -0xc(%ebp)
  801b37:	e8 a6 f5 ff ff       	call   8010e2 <fd2data>
  801b3c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3e:	83 c4 0c             	add    $0xc,%esp
  801b41:	68 07 04 00 00       	push   $0x407
  801b46:	50                   	push   %eax
  801b47:	6a 00                	push   $0x0
  801b49:	e8 d0 ef ff ff       	call   800b1e <sys_page_alloc>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	0f 88 89 00 00 00    	js     801be4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b61:	e8 7c f5 ff ff       	call   8010e2 <fd2data>
  801b66:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b6d:	50                   	push   %eax
  801b6e:	6a 00                	push   $0x0
  801b70:	56                   	push   %esi
  801b71:	6a 00                	push   $0x0
  801b73:	e8 e9 ef ff ff       	call   800b61 <sys_page_map>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	83 c4 20             	add    $0x20,%esp
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	78 55                	js     801bd6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b81:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b96:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb1:	e8 1c f5 ff ff       	call   8010d2 <fd2num>
  801bb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bbb:	83 c4 04             	add    $0x4,%esp
  801bbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc1:	e8 0c f5 ff ff       	call   8010d2 <fd2num>
  801bc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc9:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	eb 30                	jmp    801c06 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bd6:	83 ec 08             	sub    $0x8,%esp
  801bd9:	56                   	push   %esi
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 c2 ef ff ff       	call   800ba3 <sys_page_unmap>
  801be1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bea:	6a 00                	push   $0x0
  801bec:	e8 b2 ef ff ff       	call   800ba3 <sys_page_unmap>
  801bf1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bf4:	83 ec 08             	sub    $0x8,%esp
  801bf7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 a2 ef ff ff       	call   800ba3 <sys_page_unmap>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c06:	89 d0                	mov    %edx,%eax
  801c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c18:	50                   	push   %eax
  801c19:	ff 75 08             	pushl  0x8(%ebp)
  801c1c:	e8 27 f5 ff ff       	call   801148 <fd_lookup>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 18                	js     801c40 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2e:	e8 af f4 ff ff       	call   8010e2 <fd2data>
	return _pipeisclosed(fd, p);
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	e8 18 fd ff ff       	call   801955 <_pipeisclosed>
  801c3d:	83 c4 10             	add    $0x10,%esp
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c52:	68 b6 26 80 00       	push   $0x8026b6
  801c57:	ff 75 0c             	pushl  0xc(%ebp)
  801c5a:	e8 bc ea ff ff       	call   80071b <strcpy>
	return 0;
}
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	57                   	push   %edi
  801c6a:	56                   	push   %esi
  801c6b:	53                   	push   %ebx
  801c6c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c72:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c77:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c7d:	eb 2d                	jmp    801cac <devcons_write+0x46>
		m = n - tot;
  801c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c82:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c84:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c87:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c8c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c8f:	83 ec 04             	sub    $0x4,%esp
  801c92:	53                   	push   %ebx
  801c93:	03 45 0c             	add    0xc(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	57                   	push   %edi
  801c98:	e8 10 ec ff ff       	call   8008ad <memmove>
		sys_cputs(buf, m);
  801c9d:	83 c4 08             	add    $0x8,%esp
  801ca0:	53                   	push   %ebx
  801ca1:	57                   	push   %edi
  801ca2:	e8 bb ed ff ff       	call   800a62 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca7:	01 de                	add    %ebx,%esi
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	89 f0                	mov    %esi,%eax
  801cae:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb1:	72 cc                	jb     801c7f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5f                   	pop    %edi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cca:	74 2a                	je     801cf6 <devcons_read+0x3b>
  801ccc:	eb 05                	jmp    801cd3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cce:	e8 2c ee ff ff       	call   800aff <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cd3:	e8 a8 ed ff ff       	call   800a80 <sys_cgetc>
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	74 f2                	je     801cce <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	78 16                	js     801cf6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce0:	83 f8 04             	cmp    $0x4,%eax
  801ce3:	74 0c                	je     801cf1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce8:	88 02                	mov    %al,(%edx)
	return 1;
  801cea:	b8 01 00 00 00       	mov    $0x1,%eax
  801cef:	eb 05                	jmp    801cf6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801d01:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d04:	6a 01                	push   $0x1
  801d06:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d09:	50                   	push   %eax
  801d0a:	e8 53 ed ff ff       	call   800a62 <sys_cputs>
}
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <getchar>:

int
getchar(void)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d1a:	6a 01                	push   $0x1
  801d1c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d1f:	50                   	push   %eax
  801d20:	6a 00                	push   $0x0
  801d22:	e8 87 f6 ff ff       	call   8013ae <read>
	if (r < 0)
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 0f                	js     801d3d <getchar+0x29>
		return r;
	if (r < 1)
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	7e 06                	jle    801d38 <getchar+0x24>
		return -E_EOF;
	return c;
  801d32:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d36:	eb 05                	jmp    801d3d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d38:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	ff 75 08             	pushl  0x8(%ebp)
  801d4c:	e8 f7 f3 ff ff       	call   801148 <fd_lookup>
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 11                	js     801d69 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d61:	39 10                	cmp    %edx,(%eax)
  801d63:	0f 94 c0             	sete   %al
  801d66:	0f b6 c0             	movzbl %al,%eax
}
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <opencons>:

int
opencons(void)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	e8 7f f3 ff ff       	call   8010f9 <fd_alloc>
  801d7a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d7d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 3e                	js     801dc1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d83:	83 ec 04             	sub    $0x4,%esp
  801d86:	68 07 04 00 00       	push   $0x407
  801d8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 89 ed ff ff       	call   800b1e <sys_page_alloc>
  801d95:	83 c4 10             	add    $0x10,%esp
		return r;
  801d98:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 23                	js     801dc1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d9e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dac:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	50                   	push   %eax
  801db7:	e8 16 f3 ff ff       	call   8010d2 <fd2num>
  801dbc:	89 c2                	mov    %eax,%edx
  801dbe:	83 c4 10             	add    $0x10,%esp
}
  801dc1:	89 d0                	mov    %edx,%eax
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dcd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dd3:	e8 08 ed ff ff       	call   800ae0 <sys_getenvid>
  801dd8:	83 ec 0c             	sub    $0xc,%esp
  801ddb:	ff 75 0c             	pushl  0xc(%ebp)
  801dde:	ff 75 08             	pushl  0x8(%ebp)
  801de1:	56                   	push   %esi
  801de2:	50                   	push   %eax
  801de3:	68 c4 26 80 00       	push   $0x8026c4
  801de8:	e8 a9 e3 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ded:	83 c4 18             	add    $0x18,%esp
  801df0:	53                   	push   %ebx
  801df1:	ff 75 10             	pushl  0x10(%ebp)
  801df4:	e8 4c e3 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  801df9:	c7 04 24 af 26 80 00 	movl   $0x8026af,(%esp)
  801e00:	e8 91 e3 ff ff       	call   800196 <cprintf>
  801e05:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e08:	cc                   	int3   
  801e09:	eb fd                	jmp    801e08 <_panic+0x43>

00801e0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	8b 75 08             	mov    0x8(%ebp),%esi
  801e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	75 12                	jne    801e2f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e1d:	83 ec 0c             	sub    $0xc,%esp
  801e20:	68 00 00 c0 ee       	push   $0xeec00000
  801e25:	e8 a4 ee ff ff       	call   800cce <sys_ipc_recv>
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	eb 0c                	jmp    801e3b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e2f:	83 ec 0c             	sub    $0xc,%esp
  801e32:	50                   	push   %eax
  801e33:	e8 96 ee ff ff       	call   800cce <sys_ipc_recv>
  801e38:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e3b:	85 f6                	test   %esi,%esi
  801e3d:	0f 95 c1             	setne  %cl
  801e40:	85 db                	test   %ebx,%ebx
  801e42:	0f 95 c2             	setne  %dl
  801e45:	84 d1                	test   %dl,%cl
  801e47:	74 09                	je     801e52 <ipc_recv+0x47>
  801e49:	89 c2                	mov    %eax,%edx
  801e4b:	c1 ea 1f             	shr    $0x1f,%edx
  801e4e:	84 d2                	test   %dl,%dl
  801e50:	75 2d                	jne    801e7f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e52:	85 f6                	test   %esi,%esi
  801e54:	74 0d                	je     801e63 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e56:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e61:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e63:	85 db                	test   %ebx,%ebx
  801e65:	74 0d                	je     801e74 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e67:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e72:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e74:	a1 04 40 80 00       	mov    0x804004,%eax
  801e79:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	57                   	push   %edi
  801e8a:	56                   	push   %esi
  801e8b:	53                   	push   %ebx
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e92:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e98:	85 db                	test   %ebx,%ebx
  801e9a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e9f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ea2:	ff 75 14             	pushl  0x14(%ebp)
  801ea5:	53                   	push   %ebx
  801ea6:	56                   	push   %esi
  801ea7:	57                   	push   %edi
  801ea8:	e8 fe ed ff ff       	call   800cab <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ead:	89 c2                	mov    %eax,%edx
  801eaf:	c1 ea 1f             	shr    $0x1f,%edx
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	84 d2                	test   %dl,%dl
  801eb7:	74 17                	je     801ed0 <ipc_send+0x4a>
  801eb9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ebc:	74 12                	je     801ed0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ebe:	50                   	push   %eax
  801ebf:	68 e8 26 80 00       	push   $0x8026e8
  801ec4:	6a 47                	push   $0x47
  801ec6:	68 f6 26 80 00       	push   $0x8026f6
  801ecb:	e8 f5 fe ff ff       	call   801dc5 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ed0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed3:	75 07                	jne    801edc <ipc_send+0x56>
			sys_yield();
  801ed5:	e8 25 ec ff ff       	call   800aff <sys_yield>
  801eda:	eb c6                	jmp    801ea2 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801edc:	85 c0                	test   %eax,%eax
  801ede:	75 c2                	jne    801ea2 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ee0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5f                   	pop    %edi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ef3:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ef9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eff:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f05:	39 ca                	cmp    %ecx,%edx
  801f07:	75 10                	jne    801f19 <ipc_find_env+0x31>
			return envs[i].env_id;
  801f09:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f0f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f14:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f17:	eb 0f                	jmp    801f28 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f19:	83 c0 01             	add    $0x1,%eax
  801f1c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f21:	75 d0                	jne    801ef3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f30:	89 d0                	mov    %edx,%eax
  801f32:	c1 e8 16             	shr    $0x16,%eax
  801f35:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f41:	f6 c1 01             	test   $0x1,%cl
  801f44:	74 1d                	je     801f63 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f46:	c1 ea 0c             	shr    $0xc,%edx
  801f49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f50:	f6 c2 01             	test   $0x1,%dl
  801f53:	74 0e                	je     801f63 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f55:	c1 ea 0c             	shr    $0xc,%edx
  801f58:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f5f:	ef 
  801f60:	0f b7 c0             	movzwl %ax,%eax
}
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    
  801f65:	66 90                	xchg   %ax,%ax
  801f67:	66 90                	xchg   %ax,%ax
  801f69:	66 90                	xchg   %ax,%ax
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

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
