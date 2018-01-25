
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 20 22 80 00       	push   $0x802220
  80003f:	e8 88 01 00 00       	call   8001cc <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 12 0e 00 00       	call   800e5b <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 98 22 80 00       	push   $0x802298
  800058:	e8 6f 01 00 00       	call   8001cc <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 48 22 80 00       	push   $0x802248
  80006c:	e8 5b 01 00 00       	call   8001cc <cprintf>
	sys_yield();
  800071:	e8 bf 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  800076:	e8 ba 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  80007b:	e8 b5 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  800080:	e8 b0 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  800085:	e8 ab 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  80008a:	e8 a6 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  80008f:	e8 a1 0a 00 00       	call   800b35 <sys_yield>
	sys_yield();
  800094:	e8 9c 0a 00 00       	call   800b35 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
  8000a0:	e8 27 01 00 00       	call   8001cc <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 28 0a 00 00       	call   800ad5 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 51 0a 00 00       	call   800b16 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	89 c2                	mov    %eax,%edx
  8000cc:	c1 e2 07             	shl    $0x7,%edx
  8000cf:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000d6:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	85 db                	test   %ebx,%ebx
  8000dd:	7e 07                	jle    8000e6 <libmain+0x31>
		binaryname = argv[0];
  8000df:	8b 06                	mov    (%esi),%eax
  8000e1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	e8 43 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f0:	e8 2a 00 00 00       	call   80011f <exit>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800105:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80010a:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80010c:	e8 05 0a 00 00       	call   800b16 <sys_getenvid>
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	e8 4b 0c 00 00       	call   800d65 <sys_thread_free>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800125:	e8 18 11 00 00       	call   801242 <close_all>
	sys_env_destroy(0);
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	6a 00                	push   $0x0
  80012f:	e8 a1 09 00 00       	call   800ad5 <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 2f 09 00 00       	call   800a98 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 54 01 00 00       	call   800303 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 d4 08 00 00       	call   800a98 <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800201:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800204:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800207:	39 d3                	cmp    %edx,%ebx
  800209:	72 05                	jb     800210 <printnum+0x30>
  80020b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020e:	77 45                	ja     800255 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021c:	53                   	push   %ebx
  80021d:	ff 75 10             	pushl  0x10(%ebp)
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 5c 1d 00 00       	call   801f90 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9e ff ff ff       	call   8001e0 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 18                	jmp    80025f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	eb 03                	jmp    800258 <printnum+0x78>
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	7f e8                	jg     800247 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	83 ec 04             	sub    $0x4,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 49 1e 00 00       	call   8020c0 <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff d7                	call   *%edi
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800292:	83 fa 01             	cmp    $0x1,%edx
  800295:	7e 0e                	jle    8002a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
  8002a3:	eb 22                	jmp    8002c7 <getuint+0x38>
	else if (lflag)
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	74 10                	je     8002b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	eb 0e                	jmp    8002c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	50                   	push   %eax
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	e8 05 00 00 00       	call   800303 <vprintfmt>
	va_end(ap);
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 2c             	sub    $0x2c,%esp
  80030c:	8b 75 08             	mov    0x8(%ebp),%esi
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800312:	8b 7d 10             	mov    0x10(%ebp),%edi
  800315:	eb 12                	jmp    800329 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800317:	85 c0                	test   %eax,%eax
  800319:	0f 84 89 03 00 00    	je     8006a8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	53                   	push   %ebx
  800323:	50                   	push   %eax
  800324:	ff d6                	call   *%esi
  800326:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	83 c7 01             	add    $0x1,%edi
  80032c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	75 e2                	jne    800317 <vprintfmt+0x14>
  800335:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	eb 07                	jmp    80035c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800358:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8d 47 01             	lea    0x1(%edi),%eax
  80035f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800362:	0f b6 07             	movzbl (%edi),%eax
  800365:	0f b6 c8             	movzbl %al,%ecx
  800368:	83 e8 23             	sub    $0x23,%eax
  80036b:	3c 55                	cmp    $0x55,%al
  80036d:	0f 87 1a 03 00 00    	ja     80068d <vprintfmt+0x38a>
  800373:	0f b6 c0             	movzbl %al,%eax
  800376:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800380:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800384:	eb d6                	jmp    80035c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80039e:	83 fa 09             	cmp    $0x9,%edx
  8003a1:	77 39                	ja     8003dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 27                	jmp    8003e2 <vprintfmt+0xdf>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	0f 49 c8             	cmovns %eax,%ecx
  8003c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 8c                	jmp    80035c <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	eb 80                	jmp    80035c <vprintfmt+0x59>
  8003dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e6:	0f 89 70 ff ff ff    	jns    80035c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f9:	e9 5e ff ff ff       	jmp    80035c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800404:	e9 53 ff ff ff       	jmp    80035c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 04 ff ff ff       	jmp    800329 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x142>
  80043a:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 18                	jne    80045d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 d8 22 80 00       	push   $0x8022d8
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 94 fe ff ff       	call   8002e6 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800458:	e9 cc fe ff ff       	jmp    800329 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 0d 27 80 00       	push   $0x80270d
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 7c fe ff ff       	call   8002e6 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	e9 b4 fe ff ff       	jmp    800329 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800480:	85 ff                	test   %edi,%edi
  800482:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
  800487:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048e:	0f 8e 94 00 00 00    	jle    800528 <vprintfmt+0x225>
  800494:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800498:	0f 84 98 00 00 00    	je     800536 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a4:	57                   	push   %edi
  8004a5:	e8 86 02 00 00       	call   800730 <strnlen>
  8004aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ad:	29 c1                	sub    %eax,%ecx
  8004af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	eb 0f                	jmp    8004d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f ed                	jg     8004c3 <vprintfmt+0x1c0>
  8004d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004dc:	85 c9                	test   %ecx,%ecx
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	0f 49 c1             	cmovns %ecx,%eax
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	89 cb                	mov    %ecx,%ebx
  8004f3:	eb 4d                	jmp    800542 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	74 1b                	je     800516 <vprintfmt+0x213>
  8004fb:	0f be c0             	movsbl %al,%eax
  8004fe:	83 e8 20             	sub    $0x20,%eax
  800501:	83 f8 5e             	cmp    $0x5e,%eax
  800504:	76 10                	jbe    800516 <vprintfmt+0x213>
					putch('?', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff 55 08             	call   *0x8(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	eb 0d                	jmp    800523 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	52                   	push   %edx
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	eb 1a                	jmp    800542 <vprintfmt+0x23f>
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800531:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800534:	eb 0c                	jmp    800542 <vprintfmt+0x23f>
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800542:	83 c7 01             	add    $0x1,%edi
  800545:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800549:	0f be d0             	movsbl %al,%edx
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 23                	je     800573 <vprintfmt+0x270>
  800550:	85 f6                	test   %esi,%esi
  800552:	78 a1                	js     8004f5 <vprintfmt+0x1f2>
  800554:	83 ee 01             	sub    $0x1,%esi
  800557:	79 9c                	jns    8004f5 <vprintfmt+0x1f2>
  800559:	89 df                	mov    %ebx,%edi
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	eb 18                	jmp    80057b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 20                	push   $0x20
  800569:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056b:	83 ef 01             	sub    $0x1,%edi
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 08                	jmp    80057b <vprintfmt+0x278>
  800573:	89 df                	mov    %ebx,%edi
  800575:	8b 75 08             	mov    0x8(%ebp),%esi
  800578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057b:	85 ff                	test   %edi,%edi
  80057d:	7f e4                	jg     800563 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 a2 fd ff ff       	jmp    800329 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800587:	83 fa 01             	cmp    $0x1,%edx
  80058a:	7e 16                	jle    8005a2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 08             	lea    0x8(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 50 04             	mov    0x4(%eax),%edx
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a0:	eb 32                	jmp    8005d4 <vprintfmt+0x2d1>
	else if (lflag)
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	74 18                	je     8005be <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bc:	eb 16                	jmp    8005d4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e3:	79 74                	jns    800659 <vprintfmt+0x356>
				putch('-', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 2d                	push   $0x2d
  8005eb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f3:	f7 d8                	neg    %eax
  8005f5:	83 d2 00             	adc    $0x0,%edx
  8005f8:	f7 da                	neg    %edx
  8005fa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800602:	eb 55                	jmp    800659 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
  800607:	e8 83 fc ff ff       	call   80028f <getuint>
			base = 10;
  80060c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800611:	eb 46                	jmp    800659 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 74 fc ff ff       	call   80028f <getuint>
			base = 8;
  80061b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800620:	eb 37                	jmp    800659 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 30                	push   $0x30
  800628:	ff d6                	call   *%esi
			putch('x', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 78                	push   $0x78
  800630:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800642:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800645:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064a:	eb 0d                	jmp    800659 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 3b fc ff ff       	call   80028f <getuint>
			base = 16;
  800654:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800659:	83 ec 0c             	sub    $0xc,%esp
  80065c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800660:	57                   	push   %edi
  800661:	ff 75 e0             	pushl  -0x20(%ebp)
  800664:	51                   	push   %ecx
  800665:	52                   	push   %edx
  800666:	50                   	push   %eax
  800667:	89 da                	mov    %ebx,%edx
  800669:	89 f0                	mov    %esi,%eax
  80066b:	e8 70 fb ff ff       	call   8001e0 <printnum>
			break;
  800670:	83 c4 20             	add    $0x20,%esp
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800676:	e9 ae fc ff ff       	jmp    800329 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	51                   	push   %ecx
  800680:	ff d6                	call   *%esi
			break;
  800682:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800688:	e9 9c fc ff ff       	jmp    800329 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 25                	push   $0x25
  800693:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb 03                	jmp    80069d <vprintfmt+0x39a>
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a1:	75 f7                	jne    80069a <vprintfmt+0x397>
  8006a3:	e9 81 fc ff ff       	jmp    800329 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ab:	5b                   	pop    %ebx
  8006ac:	5e                   	pop    %esi
  8006ad:	5f                   	pop    %edi
  8006ae:	5d                   	pop    %ebp
  8006af:	c3                   	ret    

008006b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 18             	sub    $0x18,%esp
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 26                	je     8006f7 <vsnprintf+0x47>
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	7e 22                	jle    8006f7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d5:	ff 75 14             	pushl  0x14(%ebp)
  8006d8:	ff 75 10             	pushl  0x10(%ebp)
  8006db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006de:	50                   	push   %eax
  8006df:	68 c9 02 80 00       	push   $0x8002c9
  8006e4:	e8 1a fc ff ff       	call   800303 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	eb 05                	jmp    8006fc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800707:	50                   	push   %eax
  800708:	ff 75 10             	pushl  0x10(%ebp)
  80070b:	ff 75 0c             	pushl  0xc(%ebp)
  80070e:	ff 75 08             	pushl  0x8(%ebp)
  800711:	e8 9a ff ff ff       	call   8006b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	eb 03                	jmp    800728 <strlen+0x10>
		n++;
  800725:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800728:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072c:	75 f7                	jne    800725 <strlen+0xd>
		n++;
	return n;
}
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800736:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
  80073e:	eb 03                	jmp    800743 <strnlen+0x13>
		n++;
  800740:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	39 c2                	cmp    %eax,%edx
  800745:	74 08                	je     80074f <strnlen+0x1f>
  800747:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074b:	75 f3                	jne    800740 <strnlen+0x10>
  80074d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	53                   	push   %ebx
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	83 c2 01             	add    $0x1,%edx
  800760:	83 c1 01             	add    $0x1,%ecx
  800763:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800767:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076a:	84 db                	test   %bl,%bl
  80076c:	75 ef                	jne    80075d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076e:	5b                   	pop    %ebx
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	53                   	push   %ebx
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800778:	53                   	push   %ebx
  800779:	e8 9a ff ff ff       	call   800718 <strlen>
  80077e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800781:	ff 75 0c             	pushl  0xc(%ebp)
  800784:	01 d8                	add    %ebx,%eax
  800786:	50                   	push   %eax
  800787:	e8 c5 ff ff ff       	call   800751 <strcpy>
	return dst;
}
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	8b 75 08             	mov    0x8(%ebp),%esi
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079e:	89 f3                	mov    %esi,%ebx
  8007a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 0f                	jmp    8007b6 <strncpy+0x23>
		*dst++ = *src;
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	0f b6 01             	movzbl (%ecx),%eax
  8007ad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b6:	39 da                	cmp    %ebx,%edx
  8007b8:	75 ed                	jne    8007a7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 21                	je     8007f5 <strlcpy+0x35>
  8007d4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d8:	89 f2                	mov    %esi,%edx
  8007da:	eb 09                	jmp    8007e5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007dc:	83 c2 01             	add    $0x1,%edx
  8007df:	83 c1 01             	add    $0x1,%ecx
  8007e2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e5:	39 c2                	cmp    %eax,%edx
  8007e7:	74 09                	je     8007f2 <strlcpy+0x32>
  8007e9:	0f b6 19             	movzbl (%ecx),%ebx
  8007ec:	84 db                	test   %bl,%bl
  8007ee:	75 ec                	jne    8007dc <strlcpy+0x1c>
  8007f0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f5:	29 f0                	sub    %esi,%eax
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800804:	eb 06                	jmp    80080c <strcmp+0x11>
		p++, q++;
  800806:	83 c1 01             	add    $0x1,%ecx
  800809:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080c:	0f b6 01             	movzbl (%ecx),%eax
  80080f:	84 c0                	test   %al,%al
  800811:	74 04                	je     800817 <strcmp+0x1c>
  800813:	3a 02                	cmp    (%edx),%al
  800815:	74 ef                	je     800806 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 c0             	movzbl %al,%eax
  80081a:	0f b6 12             	movzbl (%edx),%edx
  80081d:	29 d0                	sub    %edx,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082b:	89 c3                	mov    %eax,%ebx
  80082d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800830:	eb 06                	jmp    800838 <strncmp+0x17>
		n--, p++, q++;
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800838:	39 d8                	cmp    %ebx,%eax
  80083a:	74 15                	je     800851 <strncmp+0x30>
  80083c:	0f b6 08             	movzbl (%eax),%ecx
  80083f:	84 c9                	test   %cl,%cl
  800841:	74 04                	je     800847 <strncmp+0x26>
  800843:	3a 0a                	cmp    (%edx),%cl
  800845:	74 eb                	je     800832 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800847:	0f b6 00             	movzbl (%eax),%eax
  80084a:	0f b6 12             	movzbl (%edx),%edx
  80084d:	29 d0                	sub    %edx,%eax
  80084f:	eb 05                	jmp    800856 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800856:	5b                   	pop    %ebx
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800863:	eb 07                	jmp    80086c <strchr+0x13>
		if (*s == c)
  800865:	38 ca                	cmp    %cl,%dl
  800867:	74 0f                	je     800878 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	0f b6 10             	movzbl (%eax),%edx
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f2                	jne    800865 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	eb 03                	jmp    800889 <strfind+0xf>
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088c:	38 ca                	cmp    %cl,%dl
  80088e:	74 04                	je     800894 <strfind+0x1a>
  800890:	84 d2                	test   %dl,%dl
  800892:	75 f2                	jne    800886 <strfind+0xc>
			break;
	return (char *) s;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	57                   	push   %edi
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a2:	85 c9                	test   %ecx,%ecx
  8008a4:	74 36                	je     8008dc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ac:	75 28                	jne    8008d6 <memset+0x40>
  8008ae:	f6 c1 03             	test   $0x3,%cl
  8008b1:	75 23                	jne    8008d6 <memset+0x40>
		c &= 0xFF;
  8008b3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b7:	89 d3                	mov    %edx,%ebx
  8008b9:	c1 e3 08             	shl    $0x8,%ebx
  8008bc:	89 d6                	mov    %edx,%esi
  8008be:	c1 e6 18             	shl    $0x18,%esi
  8008c1:	89 d0                	mov    %edx,%eax
  8008c3:	c1 e0 10             	shl    $0x10,%eax
  8008c6:	09 f0                	or     %esi,%eax
  8008c8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	09 d0                	or     %edx,%eax
  8008ce:	c1 e9 02             	shr    $0x2,%ecx
  8008d1:	fc                   	cld    
  8008d2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d4:	eb 06                	jmp    8008dc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d9:	fc                   	cld    
  8008da:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008dc:	89 f8                	mov    %edi,%eax
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5f                   	pop    %edi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	57                   	push   %edi
  8008e7:	56                   	push   %esi
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f1:	39 c6                	cmp    %eax,%esi
  8008f3:	73 35                	jae    80092a <memmove+0x47>
  8008f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f8:	39 d0                	cmp    %edx,%eax
  8008fa:	73 2e                	jae    80092a <memmove+0x47>
		s += n;
		d += n;
  8008fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	09 fe                	or     %edi,%esi
  800903:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800909:	75 13                	jne    80091e <memmove+0x3b>
  80090b:	f6 c1 03             	test   $0x3,%cl
  80090e:	75 0e                	jne    80091e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800910:	83 ef 04             	sub    $0x4,%edi
  800913:	8d 72 fc             	lea    -0x4(%edx),%esi
  800916:	c1 e9 02             	shr    $0x2,%ecx
  800919:	fd                   	std    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 09                	jmp    800927 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091e:	83 ef 01             	sub    $0x1,%edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 1d                	jmp    800947 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	09 c2                	or     %eax,%edx
  80092e:	f6 c2 03             	test   $0x3,%dl
  800931:	75 0f                	jne    800942 <memmove+0x5f>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0a                	jne    800942 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	89 c7                	mov    %eax,%edi
  80093d:	fc                   	cld    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 05                	jmp    800947 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80094e:	ff 75 10             	pushl  0x10(%ebp)
  800951:	ff 75 0c             	pushl  0xc(%ebp)
  800954:	ff 75 08             	pushl  0x8(%ebp)
  800957:	e8 87 ff ff ff       	call   8008e3 <memmove>
}
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 55 0c             	mov    0xc(%ebp),%edx
  800969:	89 c6                	mov    %eax,%esi
  80096b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	eb 1a                	jmp    80098a <memcmp+0x2c>
		if (*s1 != *s2)
  800970:	0f b6 08             	movzbl (%eax),%ecx
  800973:	0f b6 1a             	movzbl (%edx),%ebx
  800976:	38 d9                	cmp    %bl,%cl
  800978:	74 0a                	je     800984 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097a:	0f b6 c1             	movzbl %cl,%eax
  80097d:	0f b6 db             	movzbl %bl,%ebx
  800980:	29 d8                	sub    %ebx,%eax
  800982:	eb 0f                	jmp    800993 <memcmp+0x35>
		s1++, s2++;
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	39 f0                	cmp    %esi,%eax
  80098c:	75 e2                	jne    800970 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80099e:	89 c1                	mov    %eax,%ecx
  8009a0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a7:	eb 0a                	jmp    8009b3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	0f b6 10             	movzbl (%eax),%edx
  8009ac:	39 da                	cmp    %ebx,%edx
  8009ae:	74 07                	je     8009b7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	39 c8                	cmp    %ecx,%eax
  8009b5:	72 f2                	jb     8009a9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	57                   	push   %edi
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c6:	eb 03                	jmp    8009cb <strtol+0x11>
		s++;
  8009c8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	0f b6 01             	movzbl (%ecx),%eax
  8009ce:	3c 20                	cmp    $0x20,%al
  8009d0:	74 f6                	je     8009c8 <strtol+0xe>
  8009d2:	3c 09                	cmp    $0x9,%al
  8009d4:	74 f2                	je     8009c8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d6:	3c 2b                	cmp    $0x2b,%al
  8009d8:	75 0a                	jne    8009e4 <strtol+0x2a>
		s++;
  8009da:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e2:	eb 11                	jmp    8009f5 <strtol+0x3b>
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 08                	jne    8009f5 <strtol+0x3b>
		s++, neg = 1;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fb:	75 15                	jne    800a12 <strtol+0x58>
  8009fd:	80 39 30             	cmpb   $0x30,(%ecx)
  800a00:	75 10                	jne    800a12 <strtol+0x58>
  800a02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a06:	75 7c                	jne    800a84 <strtol+0xca>
		s += 2, base = 16;
  800a08:	83 c1 02             	add    $0x2,%ecx
  800a0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a10:	eb 16                	jmp    800a28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a12:	85 db                	test   %ebx,%ebx
  800a14:	75 12                	jne    800a28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1e:	75 08                	jne    800a28 <strtol+0x6e>
		s++, base = 8;
  800a20:	83 c1 01             	add    $0x1,%ecx
  800a23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a30:	0f b6 11             	movzbl (%ecx),%edx
  800a33:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 09             	cmp    $0x9,%bl
  800a3b:	77 08                	ja     800a45 <strtol+0x8b>
			dig = *s - '0';
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 30             	sub    $0x30,%edx
  800a43:	eb 22                	jmp    800a67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a45:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 19             	cmp    $0x19,%bl
  800a4d:	77 08                	ja     800a57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a4f:	0f be d2             	movsbl %dl,%edx
  800a52:	83 ea 57             	sub    $0x57,%edx
  800a55:	eb 10                	jmp    800a67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a57:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 19             	cmp    $0x19,%bl
  800a5f:	77 16                	ja     800a77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a61:	0f be d2             	movsbl %dl,%edx
  800a64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a67:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6a:	7d 0b                	jge    800a77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a75:	eb b9                	jmp    800a30 <strtol+0x76>

	if (endptr)
  800a77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7b:	74 0d                	je     800a8a <strtol+0xd0>
		*endptr = (char *) s;
  800a7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a80:	89 0e                	mov    %ecx,(%esi)
  800a82:	eb 06                	jmp    800a8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	74 98                	je     800a20 <strtol+0x66>
  800a88:	eb 9e                	jmp    800a28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	f7 da                	neg    %edx
  800a8e:	85 ff                	test   %edi,%edi
  800a90:	0f 45 c2             	cmovne %edx,%eax
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	89 c6                	mov    %eax,%esi
  800aaf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac6:	89 d1                	mov    %edx,%ecx
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	89 d7                	mov    %edx,%edi
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	89 cb                	mov    %ecx,%ebx
  800aed:	89 cf                	mov    %ecx,%edi
  800aef:	89 ce                	mov    %ecx,%esi
  800af1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 17                	jle    800b0e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	50                   	push   %eax
  800afb:	6a 03                	push   $0x3
  800afd:	68 bf 25 80 00       	push   $0x8025bf
  800b02:	6a 23                	push   $0x23
  800b04:	68 dc 25 80 00       	push   $0x8025dc
  800b09:	e8 53 12 00 00       	call   801d61 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 02 00 00 00       	mov    $0x2,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_yield>:

void
sys_yield(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b45:	89 d1                	mov    %edx,%ecx
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	89 d7                	mov    %edx,%edi
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	be 00 00 00 00       	mov    $0x0,%esi
  800b62:	b8 04 00 00 00       	mov    $0x4,%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b70:	89 f7                	mov    %esi,%edi
  800b72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	7e 17                	jle    800b8f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	50                   	push   %eax
  800b7c:	6a 04                	push   $0x4
  800b7e:	68 bf 25 80 00       	push   $0x8025bf
  800b83:	6a 23                	push   $0x23
  800b85:	68 dc 25 80 00       	push   $0x8025dc
  800b8a:	e8 d2 11 00 00       	call   801d61 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	7e 17                	jle    800bd1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 05                	push   $0x5
  800bc0:	68 bf 25 80 00       	push   $0x8025bf
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 dc 25 80 00       	push   $0x8025dc
  800bcc:	e8 90 11 00 00       	call   801d61 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	89 df                	mov    %ebx,%edi
  800bf4:	89 de                	mov    %ebx,%esi
  800bf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7e 17                	jle    800c13 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 06                	push   $0x6
  800c02:	68 bf 25 80 00       	push   $0x8025bf
  800c07:	6a 23                	push   $0x23
  800c09:	68 dc 25 80 00       	push   $0x8025dc
  800c0e:	e8 4e 11 00 00       	call   801d61 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c29:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 df                	mov    %ebx,%edi
  800c36:	89 de                	mov    %ebx,%esi
  800c38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 17                	jle    800c55 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 08                	push   $0x8
  800c44:	68 bf 25 80 00       	push   $0x8025bf
  800c49:	6a 23                	push   $0x23
  800c4b:	68 dc 25 80 00       	push   $0x8025dc
  800c50:	e8 0c 11 00 00       	call   801d61 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	89 df                	mov    %ebx,%edi
  800c78:	89 de                	mov    %ebx,%esi
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 17                	jle    800c97 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 09                	push   $0x9
  800c86:	68 bf 25 80 00       	push   $0x8025bf
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 dc 25 80 00       	push   $0x8025dc
  800c92:	e8 ca 10 00 00       	call   801d61 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cad:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	89 df                	mov    %ebx,%edi
  800cba:	89 de                	mov    %ebx,%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 17                	jle    800cd9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 0a                	push   $0xa
  800cc8:	68 bf 25 80 00       	push   $0x8025bf
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 dc 25 80 00       	push   $0x8025dc
  800cd4:	e8 88 10 00 00       	call   801d61 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	be 00 00 00 00       	mov    $0x0,%esi
  800cec:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d12:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 cb                	mov    %ecx,%ebx
  800d1c:	89 cf                	mov    %ecx,%edi
  800d1e:	89 ce                	mov    %ecx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 0d                	push   $0xd
  800d2c:	68 bf 25 80 00       	push   $0x8025bf
  800d31:	6a 23                	push   $0x23
  800d33:	68 dc 25 80 00       	push   $0x8025dc
  800d38:	e8 24 10 00 00       	call   801d61 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d50:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 cb                	mov    %ecx,%ebx
  800d5a:	89 cf                	mov    %ecx,%edi
  800d5c:	89 ce                	mov    %ecx,%esi
  800d5e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d70:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 cb                	mov    %ecx,%ebx
  800d7a:	89 cf                	mov    %ecx,%edi
  800d7c:	89 ce                	mov    %ecx,%esi
  800d7e:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	53                   	push   %ebx
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d8f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d91:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d95:	74 11                	je     800da8 <pgfault+0x23>
  800d97:	89 d8                	mov    %ebx,%eax
  800d99:	c1 e8 0c             	shr    $0xc,%eax
  800d9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800da3:	f6 c4 08             	test   $0x8,%ah
  800da6:	75 14                	jne    800dbc <pgfault+0x37>
		panic("faulting access");
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	68 ea 25 80 00       	push   $0x8025ea
  800db0:	6a 1e                	push   $0x1e
  800db2:	68 fa 25 80 00       	push   $0x8025fa
  800db7:	e8 a5 0f 00 00       	call   801d61 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dbc:	83 ec 04             	sub    $0x4,%esp
  800dbf:	6a 07                	push   $0x7
  800dc1:	68 00 f0 7f 00       	push   $0x7ff000
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 87 fd ff ff       	call   800b54 <sys_page_alloc>
	if (r < 0) {
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 12                	jns    800de6 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dd4:	50                   	push   %eax
  800dd5:	68 05 26 80 00       	push   $0x802605
  800dda:	6a 2c                	push   $0x2c
  800ddc:	68 fa 25 80 00       	push   $0x8025fa
  800de1:	e8 7b 0f 00 00       	call   801d61 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800de6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	68 00 10 00 00       	push   $0x1000
  800df4:	53                   	push   %ebx
  800df5:	68 00 f0 7f 00       	push   $0x7ff000
  800dfa:	e8 4c fb ff ff       	call   80094b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800dff:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e06:	53                   	push   %ebx
  800e07:	6a 00                	push   $0x0
  800e09:	68 00 f0 7f 00       	push   $0x7ff000
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 82 fd ff ff       	call   800b97 <sys_page_map>
	if (r < 0) {
  800e15:	83 c4 20             	add    $0x20,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	79 12                	jns    800e2e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e1c:	50                   	push   %eax
  800e1d:	68 05 26 80 00       	push   $0x802605
  800e22:	6a 33                	push   $0x33
  800e24:	68 fa 25 80 00       	push   $0x8025fa
  800e29:	e8 33 0f 00 00       	call   801d61 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	68 00 f0 7f 00       	push   $0x7ff000
  800e36:	6a 00                	push   $0x0
  800e38:	e8 9c fd ff ff       	call   800bd9 <sys_page_unmap>
	if (r < 0) {
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	79 12                	jns    800e56 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e44:	50                   	push   %eax
  800e45:	68 05 26 80 00       	push   $0x802605
  800e4a:	6a 37                	push   $0x37
  800e4c:	68 fa 25 80 00       	push   $0x8025fa
  800e51:	e8 0b 0f 00 00       	call   801d61 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e64:	68 85 0d 80 00       	push   $0x800d85
  800e69:	e8 39 0f 00 00       	call   801da7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e6e:	b8 07 00 00 00       	mov    $0x7,%eax
  800e73:	cd 30                	int    $0x30
  800e75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	79 17                	jns    800e96 <fork+0x3b>
		panic("fork fault %e");
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	68 1e 26 80 00       	push   $0x80261e
  800e87:	68 84 00 00 00       	push   $0x84
  800e8c:	68 fa 25 80 00       	push   $0x8025fa
  800e91:	e8 cb 0e 00 00       	call   801d61 <_panic>
  800e96:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e98:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e9c:	75 25                	jne    800ec3 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e9e:	e8 73 fc ff ff       	call   800b16 <sys_getenvid>
  800ea3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 e2 07             	shl    $0x7,%edx
  800ead:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800eb4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	e9 61 01 00 00       	jmp    801024 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	6a 07                	push   $0x7
  800ec8:	68 00 f0 bf ee       	push   $0xeebff000
  800ecd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ed0:	e8 7f fc ff ff       	call   800b54 <sys_page_alloc>
  800ed5:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ed8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800edd:	89 d8                	mov    %ebx,%eax
  800edf:	c1 e8 16             	shr    $0x16,%eax
  800ee2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee9:	a8 01                	test   $0x1,%al
  800eeb:	0f 84 fc 00 00 00    	je     800fed <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ef1:	89 d8                	mov    %ebx,%eax
  800ef3:	c1 e8 0c             	shr    $0xc,%eax
  800ef6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800efd:	f6 c2 01             	test   $0x1,%dl
  800f00:	0f 84 e7 00 00 00    	je     800fed <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f06:	89 c6                	mov    %eax,%esi
  800f08:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f0b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f12:	f6 c6 04             	test   $0x4,%dh
  800f15:	74 39                	je     800f50 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	25 07 0e 00 00       	and    $0xe07,%eax
  800f26:	50                   	push   %eax
  800f27:	56                   	push   %esi
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 66 fc ff ff       	call   800b97 <sys_page_map>
		if (r < 0) {
  800f31:	83 c4 20             	add    $0x20,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	0f 89 b1 00 00 00    	jns    800fed <fork+0x192>
		    	panic("sys page map fault %e");
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	68 2c 26 80 00       	push   $0x80262c
  800f44:	6a 54                	push   $0x54
  800f46:	68 fa 25 80 00       	push   $0x8025fa
  800f4b:	e8 11 0e 00 00       	call   801d61 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f57:	f6 c2 02             	test   $0x2,%dl
  800f5a:	75 0c                	jne    800f68 <fork+0x10d>
  800f5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f63:	f6 c4 08             	test   $0x8,%ah
  800f66:	74 5b                	je     800fc3 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	68 05 08 00 00       	push   $0x805
  800f70:	56                   	push   %esi
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	6a 00                	push   $0x0
  800f75:	e8 1d fc ff ff       	call   800b97 <sys_page_map>
		if (r < 0) {
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 14                	jns    800f95 <fork+0x13a>
		    	panic("sys page map fault %e");
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	68 2c 26 80 00       	push   $0x80262c
  800f89:	6a 5b                	push   $0x5b
  800f8b:	68 fa 25 80 00       	push   $0x8025fa
  800f90:	e8 cc 0d 00 00       	call   801d61 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	68 05 08 00 00       	push   $0x805
  800f9d:	56                   	push   %esi
  800f9e:	6a 00                	push   $0x0
  800fa0:	56                   	push   %esi
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 ef fb ff ff       	call   800b97 <sys_page_map>
		if (r < 0) {
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	79 3e                	jns    800fed <fork+0x192>
		    	panic("sys page map fault %e");
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	68 2c 26 80 00       	push   $0x80262c
  800fb7:	6a 5f                	push   $0x5f
  800fb9:	68 fa 25 80 00       	push   $0x8025fa
  800fbe:	e8 9e 0d 00 00       	call   801d61 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	6a 05                	push   $0x5
  800fc8:	56                   	push   %esi
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 c5 fb ff ff       	call   800b97 <sys_page_map>
		if (r < 0) {
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 14                	jns    800fed <fork+0x192>
		    	panic("sys page map fault %e");
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 2c 26 80 00       	push   $0x80262c
  800fe1:	6a 64                	push   $0x64
  800fe3:	68 fa 25 80 00       	push   $0x8025fa
  800fe8:	e8 74 0d 00 00       	call   801d61 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff3:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800ff9:	0f 85 de fe ff ff    	jne    800edd <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fff:	a1 04 40 80 00       	mov    0x804004,%eax
  801004:	8b 40 70             	mov    0x70(%eax),%eax
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	50                   	push   %eax
  80100b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80100e:	57                   	push   %edi
  80100f:	e8 8b fc ff ff       	call   800c9f <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	6a 02                	push   $0x2
  801019:	57                   	push   %edi
  80101a:	e8 fc fb ff ff       	call   800c1b <sys_env_set_status>
	
	return envid;
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sfork>:

envid_t
sfork(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80102f:	b8 00 00 00 00       	mov    $0x0,%eax
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80103e:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	53                   	push   %ebx
  801048:	68 44 26 80 00       	push   $0x802644
  80104d:	e8 7a f1 ff ff       	call   8001cc <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801052:	c7 04 24 ff 00 80 00 	movl   $0x8000ff,(%esp)
  801059:	e8 e7 fc ff ff       	call   800d45 <sys_thread_create>
  80105e:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	53                   	push   %ebx
  801064:	68 44 26 80 00       	push   $0x802644
  801069:	e8 5e f1 ff ff       	call   8001cc <cprintf>
	return id;
	//return 0;
}
  80106e:	89 f0                	mov    %esi,%eax
  801070:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	05 00 00 00 30       	add    $0x30000000,%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	05 00 00 00 30       	add    $0x30000000,%eax
  801092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801097:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 11                	je     8010cb <fd_alloc+0x2d>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	75 09                	jne    8010d4 <fd_alloc+0x36>
			*fd_store = fd;
  8010cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	eb 17                	jmp    8010eb <fd_alloc+0x4d>
  8010d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010de:	75 c9                	jne    8010a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f3:	83 f8 1f             	cmp    $0x1f,%eax
  8010f6:	77 36                	ja     80112e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f8:	c1 e0 0c             	shl    $0xc,%eax
  8010fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801100:	89 c2                	mov    %eax,%edx
  801102:	c1 ea 16             	shr    $0x16,%edx
  801105:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110c:	f6 c2 01             	test   $0x1,%dl
  80110f:	74 24                	je     801135 <fd_lookup+0x48>
  801111:	89 c2                	mov    %eax,%edx
  801113:	c1 ea 0c             	shr    $0xc,%edx
  801116:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111d:	f6 c2 01             	test   $0x1,%dl
  801120:	74 1a                	je     80113c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801122:	8b 55 0c             	mov    0xc(%ebp),%edx
  801125:	89 02                	mov    %eax,(%edx)
	return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 13                	jmp    801141 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801133:	eb 0c                	jmp    801141 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801135:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113a:	eb 05                	jmp    801141 <fd_lookup+0x54>
  80113c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114c:	ba e4 26 80 00       	mov    $0x8026e4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801151:	eb 13                	jmp    801166 <dev_lookup+0x23>
  801153:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801156:	39 08                	cmp    %ecx,(%eax)
  801158:	75 0c                	jne    801166 <dev_lookup+0x23>
			*dev = devtab[i];
  80115a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 2e                	jmp    801194 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801166:	8b 02                	mov    (%edx),%eax
  801168:	85 c0                	test   %eax,%eax
  80116a:	75 e7                	jne    801153 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116c:	a1 04 40 80 00       	mov    0x804004,%eax
  801171:	8b 40 54             	mov    0x54(%eax),%eax
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	51                   	push   %ecx
  801178:	50                   	push   %eax
  801179:	68 68 26 80 00       	push   $0x802668
  80117e:	e8 49 f0 ff ff       	call   8001cc <cprintf>
	*dev = 0;
  801183:	8b 45 0c             	mov    0xc(%ebp),%eax
  801186:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 10             	sub    $0x10,%esp
  80119e:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a7:	50                   	push   %eax
  8011a8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ae:	c1 e8 0c             	shr    $0xc,%eax
  8011b1:	50                   	push   %eax
  8011b2:	e8 36 ff ff ff       	call   8010ed <fd_lookup>
  8011b7:	83 c4 08             	add    $0x8,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 05                	js     8011c3 <fd_close+0x2d>
	    || fd != fd2)
  8011be:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c1:	74 0c                	je     8011cf <fd_close+0x39>
		return (must_exist ? r : 0);
  8011c3:	84 db                	test   %bl,%bl
  8011c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ca:	0f 44 c2             	cmove  %edx,%eax
  8011cd:	eb 41                	jmp    801210 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	ff 36                	pushl  (%esi)
  8011d8:	e8 66 ff ff ff       	call   801143 <dev_lookup>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 1a                	js     801200 <fd_close+0x6a>
		if (dev->dev_close)
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 0b                	je     801200 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	56                   	push   %esi
  8011f9:	ff d0                	call   *%eax
  8011fb:	89 c3                	mov    %eax,%ebx
  8011fd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	56                   	push   %esi
  801204:	6a 00                	push   $0x0
  801206:	e8 ce f9 ff ff       	call   800bd9 <sys_page_unmap>
	return r;
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	89 d8                	mov    %ebx,%eax
}
  801210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	ff 75 08             	pushl  0x8(%ebp)
  801224:	e8 c4 fe ff ff       	call   8010ed <fd_lookup>
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 10                	js     801240 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	6a 01                	push   $0x1
  801235:	ff 75 f4             	pushl  -0xc(%ebp)
  801238:	e8 59 ff ff ff       	call   801196 <fd_close>
  80123d:	83 c4 10             	add    $0x10,%esp
}
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <close_all>:

void
close_all(void)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801249:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	53                   	push   %ebx
  801252:	e8 c0 ff ff ff       	call   801217 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801257:	83 c3 01             	add    $0x1,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	83 fb 20             	cmp    $0x20,%ebx
  801260:	75 ec                	jne    80124e <close_all+0xc>
		close(i);
}
  801262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	57                   	push   %edi
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 2c             	sub    $0x2c,%esp
  801270:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801273:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	ff 75 08             	pushl  0x8(%ebp)
  80127a:	e8 6e fe ff ff       	call   8010ed <fd_lookup>
  80127f:	83 c4 08             	add    $0x8,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 88 c1 00 00 00    	js     80134b <dup+0xe4>
		return r;
	close(newfdnum);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	56                   	push   %esi
  80128e:	e8 84 ff ff ff       	call   801217 <close>

	newfd = INDEX2FD(newfdnum);
  801293:	89 f3                	mov    %esi,%ebx
  801295:	c1 e3 0c             	shl    $0xc,%ebx
  801298:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80129e:	83 c4 04             	add    $0x4,%esp
  8012a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a4:	e8 de fd ff ff       	call   801087 <fd2data>
  8012a9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ab:	89 1c 24             	mov    %ebx,(%esp)
  8012ae:	e8 d4 fd ff ff       	call   801087 <fd2data>
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	c1 e8 16             	shr    $0x16,%eax
  8012be:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c5:	a8 01                	test   $0x1,%al
  8012c7:	74 37                	je     801300 <dup+0x99>
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	c1 e8 0c             	shr    $0xc,%eax
  8012ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 26                	je     801300 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e9:	50                   	push   %eax
  8012ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ed:	6a 00                	push   $0x0
  8012ef:	57                   	push   %edi
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 a0 f8 ff ff       	call   800b97 <sys_page_map>
  8012f7:	89 c7                	mov    %eax,%edi
  8012f9:	83 c4 20             	add    $0x20,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 2e                	js     80132e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801300:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801303:	89 d0                	mov    %edx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	25 07 0e 00 00       	and    $0xe07,%eax
  801317:	50                   	push   %eax
  801318:	53                   	push   %ebx
  801319:	6a 00                	push   $0x0
  80131b:	52                   	push   %edx
  80131c:	6a 00                	push   $0x0
  80131e:	e8 74 f8 ff ff       	call   800b97 <sys_page_map>
  801323:	89 c7                	mov    %eax,%edi
  801325:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801328:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132a:	85 ff                	test   %edi,%edi
  80132c:	79 1d                	jns    80134b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	53                   	push   %ebx
  801332:	6a 00                	push   $0x0
  801334:	e8 a0 f8 ff ff       	call   800bd9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801339:	83 c4 08             	add    $0x8,%esp
  80133c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80133f:	6a 00                	push   $0x0
  801341:	e8 93 f8 ff ff       	call   800bd9 <sys_page_unmap>
	return r;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	89 f8                	mov    %edi,%eax
}
  80134b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 14             	sub    $0x14,%esp
  80135a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	53                   	push   %ebx
  801362:	e8 86 fd ff ff       	call   8010ed <fd_lookup>
  801367:	83 c4 08             	add    $0x8,%esp
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 6d                	js     8013dd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137a:	ff 30                	pushl  (%eax)
  80137c:	e8 c2 fd ff ff       	call   801143 <dev_lookup>
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 4c                	js     8013d4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801388:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138b:	8b 42 08             	mov    0x8(%edx),%eax
  80138e:	83 e0 03             	and    $0x3,%eax
  801391:	83 f8 01             	cmp    $0x1,%eax
  801394:	75 21                	jne    8013b7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801396:	a1 04 40 80 00       	mov    0x804004,%eax
  80139b:	8b 40 54             	mov    0x54(%eax),%eax
  80139e:	83 ec 04             	sub    $0x4,%esp
  8013a1:	53                   	push   %ebx
  8013a2:	50                   	push   %eax
  8013a3:	68 a9 26 80 00       	push   $0x8026a9
  8013a8:	e8 1f ee ff ff       	call   8001cc <cprintf>
		return -E_INVAL;
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b5:	eb 26                	jmp    8013dd <read+0x8a>
	}
	if (!dev->dev_read)
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	8b 40 08             	mov    0x8(%eax),%eax
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	74 17                	je     8013d8 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	ff 75 10             	pushl  0x10(%ebp)
  8013c7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ca:	52                   	push   %edx
  8013cb:	ff d0                	call   *%eax
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	eb 09                	jmp    8013dd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d4:	89 c2                	mov    %eax,%edx
  8013d6:	eb 05                	jmp    8013dd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013dd:	89 d0                	mov    %edx,%eax
  8013df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	57                   	push   %edi
  8013e8:	56                   	push   %esi
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f8:	eb 21                	jmp    80141b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fa:	83 ec 04             	sub    $0x4,%esp
  8013fd:	89 f0                	mov    %esi,%eax
  8013ff:	29 d8                	sub    %ebx,%eax
  801401:	50                   	push   %eax
  801402:	89 d8                	mov    %ebx,%eax
  801404:	03 45 0c             	add    0xc(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	57                   	push   %edi
  801409:	e8 45 ff ff ff       	call   801353 <read>
		if (m < 0)
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 10                	js     801425 <readn+0x41>
			return m;
		if (m == 0)
  801415:	85 c0                	test   %eax,%eax
  801417:	74 0a                	je     801423 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801419:	01 c3                	add    %eax,%ebx
  80141b:	39 f3                	cmp    %esi,%ebx
  80141d:	72 db                	jb     8013fa <readn+0x16>
  80141f:	89 d8                	mov    %ebx,%eax
  801421:	eb 02                	jmp    801425 <readn+0x41>
  801423:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801425:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5f                   	pop    %edi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    

0080142d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	53                   	push   %ebx
  801431:	83 ec 14             	sub    $0x14,%esp
  801434:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801437:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	53                   	push   %ebx
  80143c:	e8 ac fc ff ff       	call   8010ed <fd_lookup>
  801441:	83 c4 08             	add    $0x8,%esp
  801444:	89 c2                	mov    %eax,%edx
  801446:	85 c0                	test   %eax,%eax
  801448:	78 68                	js     8014b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801454:	ff 30                	pushl  (%eax)
  801456:	e8 e8 fc ff ff       	call   801143 <dev_lookup>
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 47                	js     8014a9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801469:	75 21                	jne    80148c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80146b:	a1 04 40 80 00       	mov    0x804004,%eax
  801470:	8b 40 54             	mov    0x54(%eax),%eax
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	53                   	push   %ebx
  801477:	50                   	push   %eax
  801478:	68 c5 26 80 00       	push   $0x8026c5
  80147d:	e8 4a ed ff ff       	call   8001cc <cprintf>
		return -E_INVAL;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148a:	eb 26                	jmp    8014b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148f:	8b 52 0c             	mov    0xc(%edx),%edx
  801492:	85 d2                	test   %edx,%edx
  801494:	74 17                	je     8014ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	ff 75 10             	pushl  0x10(%ebp)
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	50                   	push   %eax
  8014a0:	ff d2                	call   *%edx
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	eb 09                	jmp    8014b2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	eb 05                	jmp    8014b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b2:	89 d0                	mov    %edx,%eax
  8014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	ff 75 08             	pushl  0x8(%ebp)
  8014c6:	e8 22 fc ff ff       	call   8010ed <fd_lookup>
  8014cb:	83 c4 08             	add    $0x8,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 0e                	js     8014e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 14             	sub    $0x14,%esp
  8014e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	53                   	push   %ebx
  8014f1:	e8 f7 fb ff ff       	call   8010ed <fd_lookup>
  8014f6:	83 c4 08             	add    $0x8,%esp
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 65                	js     801564 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	ff 30                	pushl  (%eax)
  80150b:	e8 33 fc ff ff       	call   801143 <dev_lookup>
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 44                	js     80155b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151e:	75 21                	jne    801541 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801520:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801525:	8b 40 54             	mov    0x54(%eax),%eax
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	53                   	push   %ebx
  80152c:	50                   	push   %eax
  80152d:	68 88 26 80 00       	push   $0x802688
  801532:	e8 95 ec ff ff       	call   8001cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153f:	eb 23                	jmp    801564 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801541:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801544:	8b 52 18             	mov    0x18(%edx),%edx
  801547:	85 d2                	test   %edx,%edx
  801549:	74 14                	je     80155f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	50                   	push   %eax
  801552:	ff d2                	call   *%edx
  801554:	89 c2                	mov    %eax,%edx
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	eb 09                	jmp    801564 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	eb 05                	jmp    801564 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801564:	89 d0                	mov    %edx,%eax
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 14             	sub    $0x14,%esp
  801572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801575:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	ff 75 08             	pushl  0x8(%ebp)
  80157c:	e8 6c fb ff ff       	call   8010ed <fd_lookup>
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	89 c2                	mov    %eax,%edx
  801586:	85 c0                	test   %eax,%eax
  801588:	78 58                	js     8015e2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	ff 30                	pushl  (%eax)
  801596:	e8 a8 fb ff ff       	call   801143 <dev_lookup>
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 37                	js     8015d9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a9:	74 32                	je     8015dd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b5:	00 00 00 
	stat->st_isdir = 0;
  8015b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015bf:	00 00 00 
	stat->st_dev = dev;
  8015c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	53                   	push   %ebx
  8015cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8015cf:	ff 50 14             	call   *0x14(%eax)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	eb 09                	jmp    8015e2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	eb 05                	jmp    8015e2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e2:	89 d0                	mov    %edx,%eax
  8015e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ee:	83 ec 08             	sub    $0x8,%esp
  8015f1:	6a 00                	push   $0x0
  8015f3:	ff 75 08             	pushl  0x8(%ebp)
  8015f6:	e8 e3 01 00 00       	call   8017de <open>
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 1b                	js     80161f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	ff 75 0c             	pushl  0xc(%ebp)
  80160a:	50                   	push   %eax
  80160b:	e8 5b ff ff ff       	call   80156b <fstat>
  801610:	89 c6                	mov    %eax,%esi
	close(fd);
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 fd fb ff ff       	call   801217 <close>
	return r;
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	89 f0                	mov    %esi,%eax
}
  80161f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
  80162b:	89 c6                	mov    %eax,%esi
  80162d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801636:	75 12                	jne    80164a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	6a 01                	push   $0x1
  80163d:	e8 ce 08 00 00       	call   801f10 <ipc_find_env>
  801642:	a3 00 40 80 00       	mov    %eax,0x804000
  801647:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164a:	6a 07                	push   $0x7
  80164c:	68 00 50 80 00       	push   $0x805000
  801651:	56                   	push   %esi
  801652:	ff 35 00 40 80 00    	pushl  0x804000
  801658:	e8 51 08 00 00       	call   801eae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165d:	83 c4 0c             	add    $0xc,%esp
  801660:	6a 00                	push   $0x0
  801662:	53                   	push   %ebx
  801663:	6a 00                	push   $0x0
  801665:	e8 cc 07 00 00       	call   801e36 <ipc_recv>
}
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 40 0c             	mov    0xc(%eax),%eax
  80167d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801682:	8b 45 0c             	mov    0xc(%ebp),%eax
  801685:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 02 00 00 00       	mov    $0x2,%eax
  801694:	e8 8d ff ff ff       	call   801626 <fsipc>
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b6:	e8 6b ff ff ff       	call   801626 <fsipc>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 04             	sub    $0x4,%esp
  8016c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8016dc:	e8 45 ff ff ff       	call   801626 <fsipc>
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 2c                	js     801711 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	68 00 50 80 00       	push   $0x805000
  8016ed:	53                   	push   %ebx
  8016ee:	e8 5e f0 ff ff       	call   800751 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801703:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 0c             	sub    $0xc,%esp
  80171c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171f:	8b 55 08             	mov    0x8(%ebp),%edx
  801722:	8b 52 0c             	mov    0xc(%edx),%edx
  801725:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80172b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801730:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801735:	0f 47 c2             	cmova  %edx,%eax
  801738:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80173d:	50                   	push   %eax
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	68 08 50 80 00       	push   $0x805008
  801746:	e8 98 f1 ff ff       	call   8008e3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 04 00 00 00       	mov    $0x4,%eax
  801755:	e8 cc fe ff ff       	call   801626 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80176f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
  80177a:	b8 03 00 00 00       	mov    $0x3,%eax
  80177f:	e8 a2 fe ff ff       	call   801626 <fsipc>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	85 c0                	test   %eax,%eax
  801788:	78 4b                	js     8017d5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80178a:	39 c6                	cmp    %eax,%esi
  80178c:	73 16                	jae    8017a4 <devfile_read+0x48>
  80178e:	68 f4 26 80 00       	push   $0x8026f4
  801793:	68 fb 26 80 00       	push   $0x8026fb
  801798:	6a 7c                	push   $0x7c
  80179a:	68 10 27 80 00       	push   $0x802710
  80179f:	e8 bd 05 00 00       	call   801d61 <_panic>
	assert(r <= PGSIZE);
  8017a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a9:	7e 16                	jle    8017c1 <devfile_read+0x65>
  8017ab:	68 1b 27 80 00       	push   $0x80271b
  8017b0:	68 fb 26 80 00       	push   $0x8026fb
  8017b5:	6a 7d                	push   $0x7d
  8017b7:	68 10 27 80 00       	push   $0x802710
  8017bc:	e8 a0 05 00 00       	call   801d61 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	50                   	push   %eax
  8017c5:	68 00 50 80 00       	push   $0x805000
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	e8 11 f1 ff ff       	call   8008e3 <memmove>
	return r;
  8017d2:	83 c4 10             	add    $0x10,%esp
}
  8017d5:	89 d8                	mov    %ebx,%eax
  8017d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017da:	5b                   	pop    %ebx
  8017db:	5e                   	pop    %esi
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 20             	sub    $0x20,%esp
  8017e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017e8:	53                   	push   %ebx
  8017e9:	e8 2a ef ff ff       	call   800718 <strlen>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f6:	7f 67                	jg     80185f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fe:	50                   	push   %eax
  8017ff:	e8 9a f8 ff ff       	call   80109e <fd_alloc>
  801804:	83 c4 10             	add    $0x10,%esp
		return r;
  801807:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 57                	js     801864 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	53                   	push   %ebx
  801811:	68 00 50 80 00       	push   $0x805000
  801816:	e8 36 ef ff ff       	call   800751 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801823:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801826:	b8 01 00 00 00       	mov    $0x1,%eax
  80182b:	e8 f6 fd ff ff       	call   801626 <fsipc>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	79 14                	jns    80184d <open+0x6f>
		fd_close(fd, 0);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	6a 00                	push   $0x0
  80183e:	ff 75 f4             	pushl  -0xc(%ebp)
  801841:	e8 50 f9 ff ff       	call   801196 <fd_close>
		return r;
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	89 da                	mov    %ebx,%edx
  80184b:	eb 17                	jmp    801864 <open+0x86>
	}

	return fd2num(fd);
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	ff 75 f4             	pushl  -0xc(%ebp)
  801853:	e8 1f f8 ff ff       	call   801077 <fd2num>
  801858:	89 c2                	mov    %eax,%edx
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	eb 05                	jmp    801864 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80185f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801864:	89 d0                	mov    %edx,%eax
  801866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	b8 08 00 00 00       	mov    $0x8,%eax
  80187b:	e8 a6 fd ff ff       	call   801626 <fsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80188a:	83 ec 0c             	sub    $0xc,%esp
  80188d:	ff 75 08             	pushl  0x8(%ebp)
  801890:	e8 f2 f7 ff ff       	call   801087 <fd2data>
  801895:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801897:	83 c4 08             	add    $0x8,%esp
  80189a:	68 27 27 80 00       	push   $0x802727
  80189f:	53                   	push   %ebx
  8018a0:	e8 ac ee ff ff       	call   800751 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018a5:	8b 46 04             	mov    0x4(%esi),%eax
  8018a8:	2b 06                	sub    (%esi),%eax
  8018aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b7:	00 00 00 
	stat->st_dev = &devpipe;
  8018ba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c1:	30 80 00 
	return 0;
}
  8018c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 0c             	sub    $0xc,%esp
  8018d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018da:	53                   	push   %ebx
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 f7 f2 ff ff       	call   800bd9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e2:	89 1c 24             	mov    %ebx,(%esp)
  8018e5:	e8 9d f7 ff ff       	call   801087 <fd2data>
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	50                   	push   %eax
  8018ee:	6a 00                	push   $0x0
  8018f0:	e8 e4 f2 ff ff       	call   800bd9 <sys_page_unmap>
}
  8018f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	57                   	push   %edi
  8018fe:	56                   	push   %esi
  8018ff:	53                   	push   %ebx
  801900:	83 ec 1c             	sub    $0x1c,%esp
  801903:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801906:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801908:	a1 04 40 80 00       	mov    0x804004,%eax
  80190d:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	ff 75 e0             	pushl  -0x20(%ebp)
  801916:	e8 35 06 00 00       	call   801f50 <pageref>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	89 3c 24             	mov    %edi,(%esp)
  801920:	e8 2b 06 00 00       	call   801f50 <pageref>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	39 c3                	cmp    %eax,%ebx
  80192a:	0f 94 c1             	sete   %cl
  80192d:	0f b6 c9             	movzbl %cl,%ecx
  801930:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801933:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801939:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  80193c:	39 ce                	cmp    %ecx,%esi
  80193e:	74 1b                	je     80195b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801940:	39 c3                	cmp    %eax,%ebx
  801942:	75 c4                	jne    801908 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801944:	8b 42 64             	mov    0x64(%edx),%eax
  801947:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194a:	50                   	push   %eax
  80194b:	56                   	push   %esi
  80194c:	68 2e 27 80 00       	push   $0x80272e
  801951:	e8 76 e8 ff ff       	call   8001cc <cprintf>
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	eb ad                	jmp    801908 <_pipeisclosed+0xe>
	}
}
  80195b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	57                   	push   %edi
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	83 ec 28             	sub    $0x28,%esp
  80196f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801972:	56                   	push   %esi
  801973:	e8 0f f7 ff ff       	call   801087 <fd2data>
  801978:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	bf 00 00 00 00       	mov    $0x0,%edi
  801982:	eb 4b                	jmp    8019cf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801984:	89 da                	mov    %ebx,%edx
  801986:	89 f0                	mov    %esi,%eax
  801988:	e8 6d ff ff ff       	call   8018fa <_pipeisclosed>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	75 48                	jne    8019d9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801991:	e8 9f f1 ff ff       	call   800b35 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801996:	8b 43 04             	mov    0x4(%ebx),%eax
  801999:	8b 0b                	mov    (%ebx),%ecx
  80199b:	8d 51 20             	lea    0x20(%ecx),%edx
  80199e:	39 d0                	cmp    %edx,%eax
  8019a0:	73 e2                	jae    801984 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019a9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	c1 fa 1f             	sar    $0x1f,%edx
  8019b1:	89 d1                	mov    %edx,%ecx
  8019b3:	c1 e9 1b             	shr    $0x1b,%ecx
  8019b6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019b9:	83 e2 1f             	and    $0x1f,%edx
  8019bc:	29 ca                	sub    %ecx,%edx
  8019be:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019c6:	83 c0 01             	add    $0x1,%eax
  8019c9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cc:	83 c7 01             	add    $0x1,%edi
  8019cf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019d2:	75 c2                	jne    801996 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d7:	eb 05                	jmp    8019de <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	57                   	push   %edi
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 18             	sub    $0x18,%esp
  8019ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019f2:	57                   	push   %edi
  8019f3:	e8 8f f6 ff ff       	call   801087 <fd2data>
  8019f8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a02:	eb 3d                	jmp    801a41 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a04:	85 db                	test   %ebx,%ebx
  801a06:	74 04                	je     801a0c <devpipe_read+0x26>
				return i;
  801a08:	89 d8                	mov    %ebx,%eax
  801a0a:	eb 44                	jmp    801a50 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a0c:	89 f2                	mov    %esi,%edx
  801a0e:	89 f8                	mov    %edi,%eax
  801a10:	e8 e5 fe ff ff       	call   8018fa <_pipeisclosed>
  801a15:	85 c0                	test   %eax,%eax
  801a17:	75 32                	jne    801a4b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a19:	e8 17 f1 ff ff       	call   800b35 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a1e:	8b 06                	mov    (%esi),%eax
  801a20:	3b 46 04             	cmp    0x4(%esi),%eax
  801a23:	74 df                	je     801a04 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a25:	99                   	cltd   
  801a26:	c1 ea 1b             	shr    $0x1b,%edx
  801a29:	01 d0                	add    %edx,%eax
  801a2b:	83 e0 1f             	and    $0x1f,%eax
  801a2e:	29 d0                	sub    %edx,%eax
  801a30:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a38:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a3b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3e:	83 c3 01             	add    $0x1,%ebx
  801a41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a44:	75 d8                	jne    801a1e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a46:	8b 45 10             	mov    0x10(%ebp),%eax
  801a49:	eb 05                	jmp    801a50 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a63:	50                   	push   %eax
  801a64:	e8 35 f6 ff ff       	call   80109e <fd_alloc>
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	0f 88 2c 01 00 00    	js     801ba2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a76:	83 ec 04             	sub    $0x4,%esp
  801a79:	68 07 04 00 00       	push   $0x407
  801a7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a81:	6a 00                	push   $0x0
  801a83:	e8 cc f0 ff ff       	call   800b54 <sys_page_alloc>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	0f 88 0d 01 00 00    	js     801ba2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	e8 fd f5 ff ff       	call   80109e <fd_alloc>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	0f 88 e2 00 00 00    	js     801b90 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aae:	83 ec 04             	sub    $0x4,%esp
  801ab1:	68 07 04 00 00       	push   $0x407
  801ab6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 94 f0 ff ff       	call   800b54 <sys_page_alloc>
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	0f 88 c3 00 00 00    	js     801b90 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad3:	e8 af f5 ff ff       	call   801087 <fd2data>
  801ad8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ada:	83 c4 0c             	add    $0xc,%esp
  801add:	68 07 04 00 00       	push   $0x407
  801ae2:	50                   	push   %eax
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 6a f0 ff ff       	call   800b54 <sys_page_alloc>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	0f 88 89 00 00 00    	js     801b80 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	ff 75 f0             	pushl  -0x10(%ebp)
  801afd:	e8 85 f5 ff ff       	call   801087 <fd2data>
  801b02:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b09:	50                   	push   %eax
  801b0a:	6a 00                	push   $0x0
  801b0c:	56                   	push   %esi
  801b0d:	6a 00                	push   $0x0
  801b0f:	e8 83 f0 ff ff       	call   800b97 <sys_page_map>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	83 c4 20             	add    $0x20,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 55                	js     801b72 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4d:	e8 25 f5 ff ff       	call   801077 <fd2num>
  801b52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b55:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b57:	83 c4 04             	add    $0x4,%esp
  801b5a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5d:	e8 15 f5 ff ff       	call   801077 <fd2num>
  801b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b65:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b70:	eb 30                	jmp    801ba2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	56                   	push   %esi
  801b76:	6a 00                	push   $0x0
  801b78:	e8 5c f0 ff ff       	call   800bd9 <sys_page_unmap>
  801b7d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b80:	83 ec 08             	sub    $0x8,%esp
  801b83:	ff 75 f0             	pushl  -0x10(%ebp)
  801b86:	6a 00                	push   $0x0
  801b88:	e8 4c f0 ff ff       	call   800bd9 <sys_page_unmap>
  801b8d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b90:	83 ec 08             	sub    $0x8,%esp
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	6a 00                	push   $0x0
  801b98:	e8 3c f0 ff ff       	call   800bd9 <sys_page_unmap>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ba2:	89 d0                	mov    %edx,%eax
  801ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	ff 75 08             	pushl  0x8(%ebp)
  801bb8:	e8 30 f5 ff ff       	call   8010ed <fd_lookup>
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 18                	js     801bdc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bca:	e8 b8 f4 ff ff       	call   801087 <fd2data>
	return _pipeisclosed(fd, p);
  801bcf:	89 c2                	mov    %eax,%edx
  801bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd4:	e8 21 fd ff ff       	call   8018fa <_pipeisclosed>
  801bd9:	83 c4 10             	add    $0x10,%esp
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bee:	68 46 27 80 00       	push   $0x802746
  801bf3:	ff 75 0c             	pushl  0xc(%ebp)
  801bf6:	e8 56 eb ff ff       	call   800751 <strcpy>
	return 0;
}
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	57                   	push   %edi
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c0e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c13:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c19:	eb 2d                	jmp    801c48 <devcons_write+0x46>
		m = n - tot;
  801c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c1e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c20:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c23:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c28:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c2b:	83 ec 04             	sub    $0x4,%esp
  801c2e:	53                   	push   %ebx
  801c2f:	03 45 0c             	add    0xc(%ebp),%eax
  801c32:	50                   	push   %eax
  801c33:	57                   	push   %edi
  801c34:	e8 aa ec ff ff       	call   8008e3 <memmove>
		sys_cputs(buf, m);
  801c39:	83 c4 08             	add    $0x8,%esp
  801c3c:	53                   	push   %ebx
  801c3d:	57                   	push   %edi
  801c3e:	e8 55 ee ff ff       	call   800a98 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c43:	01 de                	add    %ebx,%esi
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c4d:	72 cc                	jb     801c1b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 08             	sub    $0x8,%esp
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c66:	74 2a                	je     801c92 <devcons_read+0x3b>
  801c68:	eb 05                	jmp    801c6f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c6a:	e8 c6 ee ff ff       	call   800b35 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c6f:	e8 42 ee ff ff       	call   800ab6 <sys_cgetc>
  801c74:	85 c0                	test   %eax,%eax
  801c76:	74 f2                	je     801c6a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 16                	js     801c92 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c7c:	83 f8 04             	cmp    $0x4,%eax
  801c7f:	74 0c                	je     801c8d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c84:	88 02                	mov    %al,(%edx)
	return 1;
  801c86:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8b:	eb 05                	jmp    801c92 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ca0:	6a 01                	push   $0x1
  801ca2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca5:	50                   	push   %eax
  801ca6:	e8 ed ed ff ff       	call   800a98 <sys_cputs>
}
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <getchar>:

int
getchar(void)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cb6:	6a 01                	push   $0x1
  801cb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 90 f6 ff ff       	call   801353 <read>
	if (r < 0)
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 0f                	js     801cd9 <getchar+0x29>
		return r;
	if (r < 1)
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	7e 06                	jle    801cd4 <getchar+0x24>
		return -E_EOF;
	return c;
  801cce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cd2:	eb 05                	jmp    801cd9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cd4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce4:	50                   	push   %eax
  801ce5:	ff 75 08             	pushl  0x8(%ebp)
  801ce8:	e8 00 f4 ff ff       	call   8010ed <fd_lookup>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 11                	js     801d05 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cfd:	39 10                	cmp    %edx,(%eax)
  801cff:	0f 94 c0             	sete   %al
  801d02:	0f b6 c0             	movzbl %al,%eax
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <opencons>:

int
opencons(void)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	e8 88 f3 ff ff       	call   80109e <fd_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
		return r;
  801d19:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 3e                	js     801d5d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 23 ee ff ff       	call   800b54 <sys_page_alloc>
  801d31:	83 c4 10             	add    $0x10,%esp
		return r;
  801d34:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 23                	js     801d5d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d3a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d43:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	50                   	push   %eax
  801d53:	e8 1f f3 ff ff       	call   801077 <fd2num>
  801d58:	89 c2                	mov    %eax,%edx
  801d5a:	83 c4 10             	add    $0x10,%esp
}
  801d5d:	89 d0                	mov    %edx,%eax
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d66:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d69:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d6f:	e8 a2 ed ff ff       	call   800b16 <sys_getenvid>
  801d74:	83 ec 0c             	sub    $0xc,%esp
  801d77:	ff 75 0c             	pushl  0xc(%ebp)
  801d7a:	ff 75 08             	pushl  0x8(%ebp)
  801d7d:	56                   	push   %esi
  801d7e:	50                   	push   %eax
  801d7f:	68 54 27 80 00       	push   $0x802754
  801d84:	e8 43 e4 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d89:	83 c4 18             	add    $0x18,%esp
  801d8c:	53                   	push   %ebx
  801d8d:	ff 75 10             	pushl  0x10(%ebp)
  801d90:	e8 e6 e3 ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  801d95:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  801d9c:	e8 2b e4 ff ff       	call   8001cc <cprintf>
  801da1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801da4:	cc                   	int3   
  801da5:	eb fd                	jmp    801da4 <_panic+0x43>

00801da7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dad:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801db4:	75 2a                	jne    801de0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801db6:	83 ec 04             	sub    $0x4,%esp
  801db9:	6a 07                	push   $0x7
  801dbb:	68 00 f0 bf ee       	push   $0xeebff000
  801dc0:	6a 00                	push   $0x0
  801dc2:	e8 8d ed ff ff       	call   800b54 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	79 12                	jns    801de0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dce:	50                   	push   %eax
  801dcf:	68 78 27 80 00       	push   $0x802778
  801dd4:	6a 23                	push   $0x23
  801dd6:	68 7c 27 80 00       	push   $0x80277c
  801ddb:	e8 81 ff ff ff       	call   801d61 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	68 12 1e 80 00       	push   $0x801e12
  801df0:	6a 00                	push   $0x0
  801df2:	e8 a8 ee ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	79 12                	jns    801e10 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dfe:	50                   	push   %eax
  801dff:	68 78 27 80 00       	push   $0x802778
  801e04:	6a 2c                	push   $0x2c
  801e06:	68 7c 27 80 00       	push   $0x80277c
  801e0b:	e8 51 ff ff ff       	call   801d61 <_panic>
	}
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e12:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e13:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e18:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e1a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e1d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e21:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e26:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e2a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e2c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e2f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e30:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e33:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e34:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e35:	c3                   	ret    

00801e36 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
  801e3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e44:	85 c0                	test   %eax,%eax
  801e46:	75 12                	jne    801e5a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	68 00 00 c0 ee       	push   $0xeec00000
  801e50:	e8 af ee ff ff       	call   800d04 <sys_ipc_recv>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	eb 0c                	jmp    801e66 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	50                   	push   %eax
  801e5e:	e8 a1 ee ff ff       	call   800d04 <sys_ipc_recv>
  801e63:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e66:	85 f6                	test   %esi,%esi
  801e68:	0f 95 c1             	setne  %cl
  801e6b:	85 db                	test   %ebx,%ebx
  801e6d:	0f 95 c2             	setne  %dl
  801e70:	84 d1                	test   %dl,%cl
  801e72:	74 09                	je     801e7d <ipc_recv+0x47>
  801e74:	89 c2                	mov    %eax,%edx
  801e76:	c1 ea 1f             	shr    $0x1f,%edx
  801e79:	84 d2                	test   %dl,%dl
  801e7b:	75 2a                	jne    801ea7 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e7d:	85 f6                	test   %esi,%esi
  801e7f:	74 0d                	je     801e8e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e81:	a1 04 40 80 00       	mov    0x804004,%eax
  801e86:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e8c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e8e:	85 db                	test   %ebx,%ebx
  801e90:	74 0d                	je     801e9f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e92:	a1 04 40 80 00       	mov    0x804004,%eax
  801e97:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e9d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea4:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ea7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ec0:	85 db                	test   %ebx,%ebx
  801ec2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ec7:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eca:	ff 75 14             	pushl  0x14(%ebp)
  801ecd:	53                   	push   %ebx
  801ece:	56                   	push   %esi
  801ecf:	57                   	push   %edi
  801ed0:	e8 0c ee ff ff       	call   800ce1 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ed5:	89 c2                	mov    %eax,%edx
  801ed7:	c1 ea 1f             	shr    $0x1f,%edx
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	84 d2                	test   %dl,%dl
  801edf:	74 17                	je     801ef8 <ipc_send+0x4a>
  801ee1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee4:	74 12                	je     801ef8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ee6:	50                   	push   %eax
  801ee7:	68 8a 27 80 00       	push   $0x80278a
  801eec:	6a 47                	push   $0x47
  801eee:	68 98 27 80 00       	push   $0x802798
  801ef3:	e8 69 fe ff ff       	call   801d61 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ef8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efb:	75 07                	jne    801f04 <ipc_send+0x56>
			sys_yield();
  801efd:	e8 33 ec ff ff       	call   800b35 <sys_yield>
  801f02:	eb c6                	jmp    801eca <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f04:	85 c0                	test   %eax,%eax
  801f06:	75 c2                	jne    801eca <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0b:	5b                   	pop    %ebx
  801f0c:	5e                   	pop    %esi
  801f0d:	5f                   	pop    %edi
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

00801f10 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f16:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f1b:	89 c2                	mov    %eax,%edx
  801f1d:	c1 e2 07             	shl    $0x7,%edx
  801f20:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f27:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f2a:	39 ca                	cmp    %ecx,%edx
  801f2c:	75 11                	jne    801f3f <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	c1 e2 07             	shl    $0x7,%edx
  801f33:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f3a:	8b 40 54             	mov    0x54(%eax),%eax
  801f3d:	eb 0f                	jmp    801f4e <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3f:	83 c0 01             	add    $0x1,%eax
  801f42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f47:	75 d2                	jne    801f1b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f56:	89 d0                	mov    %edx,%eax
  801f58:	c1 e8 16             	shr    $0x16,%eax
  801f5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f67:	f6 c1 01             	test   $0x1,%cl
  801f6a:	74 1d                	je     801f89 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6c:	c1 ea 0c             	shr    $0xc,%edx
  801f6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f76:	f6 c2 01             	test   $0x1,%dl
  801f79:	74 0e                	je     801f89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7b:	c1 ea 0c             	shr    $0xc,%edx
  801f7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f85:	ef 
  801f86:	0f b7 c0             	movzwl %ax,%eax
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
