
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
  80003a:	68 80 22 80 00       	push   $0x802280
  80003f:	e8 87 01 00 00       	call   8001cb <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 31 0e 00 00       	call   800e7a <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 f8 22 80 00       	push   $0x8022f8
  800058:	e8 6e 01 00 00       	call   8001cb <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 a8 22 80 00       	push   $0x8022a8
  80006c:	e8 5a 01 00 00       	call   8001cb <cprintf>
	sys_yield();
  800071:	e8 be 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  800076:	e8 b9 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  80007b:	e8 b4 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  800080:	e8 af 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  800085:	e8 aa 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  80008a:	e8 a5 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  80008f:	e8 a0 0a 00 00       	call   800b34 <sys_yield>
	sys_yield();
  800094:	e8 9b 0a 00 00       	call   800b34 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 d0 22 80 00 	movl   $0x8022d0,(%esp)
  8000a0:	e8 26 01 00 00       	call   8001cb <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 27 0a 00 00       	call   800ad4 <sys_env_destroy>
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
  8000c0:	e8 50 0a 00 00       	call   800b15 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000da:	85 db                	test   %ebx,%ebx
  8000dc:	7e 07                	jle    8000e5 <libmain+0x30>
		binaryname = argv[0];
  8000de:	8b 06                	mov    (%esi),%eax
  8000e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	e8 44 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 2a 00 00 00       	call   80011e <exit>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800104:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800109:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80010b:	e8 05 0a 00 00       	call   800b15 <sys_getenvid>
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	50                   	push   %eax
  800114:	e8 4b 0c 00 00       	call   800d64 <sys_thread_free>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800124:	e8 63 11 00 00       	call   80128c <close_all>
	sys_env_destroy(0);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	6a 00                	push   $0x0
  80012e:	e8 a1 09 00 00       	call   800ad4 <sys_env_destroy>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	53                   	push   %ebx
  80013c:	83 ec 04             	sub    $0x4,%esp
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800142:	8b 13                	mov    (%ebx),%edx
  800144:	8d 42 01             	lea    0x1(%edx),%eax
  800147:	89 03                	mov    %eax,(%ebx)
  800149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800150:	3d ff 00 00 00       	cmp    $0xff,%eax
  800155:	75 1a                	jne    800171 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	68 ff 00 00 00       	push   $0xff
  80015f:	8d 43 08             	lea    0x8(%ebx),%eax
  800162:	50                   	push   %eax
  800163:	e8 2f 09 00 00       	call   800a97 <sys_cputs>
		b->idx = 0;
  800168:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800171:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800183:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018a:	00 00 00 
	b.cnt = 0;
  80018d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800194:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800197:	ff 75 0c             	pushl  0xc(%ebp)
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	68 38 01 80 00       	push   $0x800138
  8001a9:	e8 54 01 00 00       	call   800302 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ae:	83 c4 08             	add    $0x8,%esp
  8001b1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 d4 08 00 00       	call   800a97 <sys_cputs>

	return b.cnt;
}
  8001c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d4:	50                   	push   %eax
  8001d5:	ff 75 08             	pushl  0x8(%ebp)
  8001d8:	e8 9d ff ff ff       	call   80017a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 1c             	sub    $0x1c,%esp
  8001e8:	89 c7                	mov    %eax,%edi
  8001ea:	89 d6                	mov    %edx,%esi
  8001ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800200:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800203:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800206:	39 d3                	cmp    %edx,%ebx
  800208:	72 05                	jb     80020f <printnum+0x30>
  80020a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020d:	77 45                	ja     800254 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	ff 75 18             	pushl  0x18(%ebp)
  800215:	8b 45 14             	mov    0x14(%ebp),%eax
  800218:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021b:	53                   	push   %ebx
  80021c:	ff 75 10             	pushl  0x10(%ebp)
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	ff 75 e4             	pushl  -0x1c(%ebp)
  800225:	ff 75 e0             	pushl  -0x20(%ebp)
  800228:	ff 75 dc             	pushl  -0x24(%ebp)
  80022b:	ff 75 d8             	pushl  -0x28(%ebp)
  80022e:	e8 bd 1d 00 00       	call   801ff0 <__udivdi3>
  800233:	83 c4 18             	add    $0x18,%esp
  800236:	52                   	push   %edx
  800237:	50                   	push   %eax
  800238:	89 f2                	mov    %esi,%edx
  80023a:	89 f8                	mov    %edi,%eax
  80023c:	e8 9e ff ff ff       	call   8001df <printnum>
  800241:	83 c4 20             	add    $0x20,%esp
  800244:	eb 18                	jmp    80025e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	56                   	push   %esi
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	ff d7                	call   *%edi
  80024f:	83 c4 10             	add    $0x10,%esp
  800252:	eb 03                	jmp    800257 <printnum+0x78>
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7f e8                	jg     800246 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	56                   	push   %esi
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	ff 75 e4             	pushl  -0x1c(%ebp)
  800268:	ff 75 e0             	pushl  -0x20(%ebp)
  80026b:	ff 75 dc             	pushl  -0x24(%ebp)
  80026e:	ff 75 d8             	pushl  -0x28(%ebp)
  800271:	e8 aa 1e 00 00       	call   802120 <__umoddi3>
  800276:	83 c4 14             	add    $0x14,%esp
  800279:	0f be 80 20 23 80 00 	movsbl 0x802320(%eax),%eax
  800280:	50                   	push   %eax
  800281:	ff d7                	call   *%edi
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800291:	83 fa 01             	cmp    $0x1,%edx
  800294:	7e 0e                	jle    8002a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	8b 52 04             	mov    0x4(%edx),%edx
  8002a2:	eb 22                	jmp    8002c6 <getuint+0x38>
	else if (lflag)
  8002a4:	85 d2                	test   %edx,%edx
  8002a6:	74 10                	je     8002b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b6:	eb 0e                	jmp    8002c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d7:	73 0a                	jae    8002e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	88 02                	mov    %al,(%edx)
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ee:	50                   	push   %eax
  8002ef:	ff 75 10             	pushl  0x10(%ebp)
  8002f2:	ff 75 0c             	pushl  0xc(%ebp)
  8002f5:	ff 75 08             	pushl  0x8(%ebp)
  8002f8:	e8 05 00 00 00       	call   800302 <vprintfmt>
	va_end(ap);
}
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
  80030b:	8b 75 08             	mov    0x8(%ebp),%esi
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 7d 10             	mov    0x10(%ebp),%edi
  800314:	eb 12                	jmp    800328 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800316:	85 c0                	test   %eax,%eax
  800318:	0f 84 89 03 00 00    	je     8006a7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80031e:	83 ec 08             	sub    $0x8,%esp
  800321:	53                   	push   %ebx
  800322:	50                   	push   %eax
  800323:	ff d6                	call   *%esi
  800325:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800328:	83 c7 01             	add    $0x1,%edi
  80032b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032f:	83 f8 25             	cmp    $0x25,%eax
  800332:	75 e2                	jne    800316 <vprintfmt+0x14>
  800334:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800338:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800346:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 07                	jmp    80035b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800357:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8d 47 01             	lea    0x1(%edi),%eax
  80035e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800361:	0f b6 07             	movzbl (%edi),%eax
  800364:	0f b6 c8             	movzbl %al,%ecx
  800367:	83 e8 23             	sub    $0x23,%eax
  80036a:	3c 55                	cmp    $0x55,%al
  80036c:	0f 87 1a 03 00 00    	ja     80068c <vprintfmt+0x38a>
  800372:	0f b6 c0             	movzbl %al,%eax
  800375:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800383:	eb d6                	jmp    80035b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800388:	b8 00 00 00 00       	mov    $0x0,%eax
  80038d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800390:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800393:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800397:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80039d:	83 fa 09             	cmp    $0x9,%edx
  8003a0:	77 39                	ja     8003db <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a5:	eb e9                	jmp    800390 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b8:	eb 27                	jmp    8003e1 <vprintfmt+0xdf>
  8003ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c4:	0f 49 c8             	cmovns %eax,%ecx
  8003c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cd:	eb 8c                	jmp    80035b <vprintfmt+0x59>
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d9:	eb 80                	jmp    80035b <vprintfmt+0x59>
  8003db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003de:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e5:	0f 89 70 ff ff ff    	jns    80035b <vprintfmt+0x59>
				width = precision, precision = -1;
  8003eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f8:	e9 5e ff ff ff       	jmp    80035b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	e9 53 ff ff ff       	jmp    80035b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	ff 30                	pushl  (%eax)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041f:	e9 04 ff ff ff       	jmp    800328 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	99                   	cltd   
  800430:	31 d0                	xor    %edx,%eax
  800432:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800434:	83 f8 0f             	cmp    $0xf,%eax
  800437:	7f 0b                	jg     800444 <vprintfmt+0x142>
  800439:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  800440:	85 d2                	test   %edx,%edx
  800442:	75 18                	jne    80045c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800444:	50                   	push   %eax
  800445:	68 38 23 80 00       	push   $0x802338
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 94 fe ff ff       	call   8002e5 <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800457:	e9 cc fe ff ff       	jmp    800328 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045c:	52                   	push   %edx
  80045d:	68 6d 27 80 00       	push   $0x80276d
  800462:	53                   	push   %ebx
  800463:	56                   	push   %esi
  800464:	e8 7c fe ff ff       	call   8002e5 <printfmt>
  800469:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	e9 b4 fe ff ff       	jmp    800328 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80047f:	85 ff                	test   %edi,%edi
  800481:	b8 31 23 80 00       	mov    $0x802331,%eax
  800486:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800489:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048d:	0f 8e 94 00 00 00    	jle    800527 <vprintfmt+0x225>
  800493:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800497:	0f 84 98 00 00 00    	je     800535 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a3:	57                   	push   %edi
  8004a4:	e8 86 02 00 00       	call   80072f <strnlen>
  8004a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ac:	29 c1                	sub    %eax,%ecx
  8004ae:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004be:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	eb 0f                	jmp    8004d1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	83 ef 01             	sub    $0x1,%edi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	7f ed                	jg     8004c2 <vprintfmt+0x1c0>
  8004d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004db:	85 c9                	test   %ecx,%ecx
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	0f 49 c1             	cmovns %ecx,%eax
  8004e5:	29 c1                	sub    %eax,%ecx
  8004e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f0:	89 cb                	mov    %ecx,%ebx
  8004f2:	eb 4d                	jmp    800541 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f8:	74 1b                	je     800515 <vprintfmt+0x213>
  8004fa:	0f be c0             	movsbl %al,%eax
  8004fd:	83 e8 20             	sub    $0x20,%eax
  800500:	83 f8 5e             	cmp    $0x5e,%eax
  800503:	76 10                	jbe    800515 <vprintfmt+0x213>
					putch('?', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	6a 3f                	push   $0x3f
  80050d:	ff 55 08             	call   *0x8(%ebp)
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb 0d                	jmp    800522 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	ff 75 0c             	pushl  0xc(%ebp)
  80051b:	52                   	push   %edx
  80051c:	ff 55 08             	call   *0x8(%ebp)
  80051f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800522:	83 eb 01             	sub    $0x1,%ebx
  800525:	eb 1a                	jmp    800541 <vprintfmt+0x23f>
  800527:	89 75 08             	mov    %esi,0x8(%ebp)
  80052a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800530:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800533:	eb 0c                	jmp    800541 <vprintfmt+0x23f>
  800535:	89 75 08             	mov    %esi,0x8(%ebp)
  800538:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800541:	83 c7 01             	add    $0x1,%edi
  800544:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800548:	0f be d0             	movsbl %al,%edx
  80054b:	85 d2                	test   %edx,%edx
  80054d:	74 23                	je     800572 <vprintfmt+0x270>
  80054f:	85 f6                	test   %esi,%esi
  800551:	78 a1                	js     8004f4 <vprintfmt+0x1f2>
  800553:	83 ee 01             	sub    $0x1,%esi
  800556:	79 9c                	jns    8004f4 <vprintfmt+0x1f2>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	eb 18                	jmp    80057a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	6a 20                	push   $0x20
  800568:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056a:	83 ef 01             	sub    $0x1,%edi
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 08                	jmp    80057a <vprintfmt+0x278>
  800572:	89 df                	mov    %ebx,%edi
  800574:	8b 75 08             	mov    0x8(%ebp),%esi
  800577:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057a:	85 ff                	test   %edi,%edi
  80057c:	7f e4                	jg     800562 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800581:	e9 a2 fd ff ff       	jmp    800328 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800586:	83 fa 01             	cmp    $0x1,%edx
  800589:	7e 16                	jle    8005a1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 08             	lea    0x8(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 50 04             	mov    0x4(%eax),%edx
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059f:	eb 32                	jmp    8005d3 <vprintfmt+0x2d1>
	else if (lflag)
  8005a1:	85 d2                	test   %edx,%edx
  8005a3:	74 18                	je     8005bd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 c1                	mov    %eax,%ecx
  8005b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bb:	eb 16                	jmp    8005d3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 c1                	mov    %eax,%ecx
  8005cd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005de:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e2:	79 74                	jns    800658 <vprintfmt+0x356>
				putch('-', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 2d                	push   $0x2d
  8005ea:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f2:	f7 d8                	neg    %eax
  8005f4:	83 d2 00             	adc    $0x0,%edx
  8005f7:	f7 da                	neg    %edx
  8005f9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800601:	eb 55                	jmp    800658 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 83 fc ff ff       	call   80028e <getuint>
			base = 10;
  80060b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800610:	eb 46                	jmp    800658 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 74 fc ff ff       	call   80028e <getuint>
			base = 8;
  80061a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80061f:	eb 37                	jmp    800658 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 30                	push   $0x30
  800627:	ff d6                	call   *%esi
			putch('x', putdat);
  800629:	83 c4 08             	add    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 78                	push   $0x78
  80062f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800641:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800644:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800649:	eb 0d                	jmp    800658 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 3b fc ff ff       	call   80028e <getuint>
			base = 16;
  800653:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800658:	83 ec 0c             	sub    $0xc,%esp
  80065b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065f:	57                   	push   %edi
  800660:	ff 75 e0             	pushl  -0x20(%ebp)
  800663:	51                   	push   %ecx
  800664:	52                   	push   %edx
  800665:	50                   	push   %eax
  800666:	89 da                	mov    %ebx,%edx
  800668:	89 f0                	mov    %esi,%eax
  80066a:	e8 70 fb ff ff       	call   8001df <printnum>
			break;
  80066f:	83 c4 20             	add    $0x20,%esp
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800675:	e9 ae fc ff ff       	jmp    800328 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	51                   	push   %ecx
  80067f:	ff d6                	call   *%esi
			break;
  800681:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800687:	e9 9c fc ff ff       	jmp    800328 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 25                	push   $0x25
  800692:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	eb 03                	jmp    80069c <vprintfmt+0x39a>
  800699:	83 ef 01             	sub    $0x1,%edi
  80069c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a0:	75 f7                	jne    800699 <vprintfmt+0x397>
  8006a2:	e9 81 fc ff ff       	jmp    800328 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	83 ec 18             	sub    $0x18,%esp
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	74 26                	je     8006f6 <vsnprintf+0x47>
  8006d0:	85 d2                	test   %edx,%edx
  8006d2:	7e 22                	jle    8006f6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d4:	ff 75 14             	pushl  0x14(%ebp)
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006dd:	50                   	push   %eax
  8006de:	68 c8 02 80 00       	push   $0x8002c8
  8006e3:	e8 1a fc ff ff       	call   800302 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb 05                	jmp    8006fb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	50                   	push   %eax
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	ff 75 08             	pushl  0x8(%ebp)
  800710:	e8 9a ff ff ff       	call   8006af <vsnprintf>
	va_end(ap);

	return rc;
}
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	eb 03                	jmp    800727 <strlen+0x10>
		n++;
  800724:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800727:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072b:	75 f7                	jne    800724 <strlen+0xd>
		n++;
	return n;
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800735:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800738:	ba 00 00 00 00       	mov    $0x0,%edx
  80073d:	eb 03                	jmp    800742 <strnlen+0x13>
		n++;
  80073f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800742:	39 c2                	cmp    %eax,%edx
  800744:	74 08                	je     80074e <strnlen+0x1f>
  800746:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074a:	75 f3                	jne    80073f <strnlen+0x10>
  80074c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075a:	89 c2                	mov    %eax,%edx
  80075c:	83 c2 01             	add    $0x1,%edx
  80075f:	83 c1 01             	add    $0x1,%ecx
  800762:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800766:	88 5a ff             	mov    %bl,-0x1(%edx)
  800769:	84 db                	test   %bl,%bl
  80076b:	75 ef                	jne    80075c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076d:	5b                   	pop    %ebx
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800777:	53                   	push   %ebx
  800778:	e8 9a ff ff ff       	call   800717 <strlen>
  80077d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	01 d8                	add    %ebx,%eax
  800785:	50                   	push   %eax
  800786:	e8 c5 ff ff ff       	call   800750 <strcpy>
	return dst;
}
  80078b:	89 d8                	mov    %ebx,%eax
  80078d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	56                   	push   %esi
  800796:	53                   	push   %ebx
  800797:	8b 75 08             	mov    0x8(%ebp),%esi
  80079a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079d:	89 f3                	mov    %esi,%ebx
  80079f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a2:	89 f2                	mov    %esi,%edx
  8007a4:	eb 0f                	jmp    8007b5 <strncpy+0x23>
		*dst++ = *src;
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	0f b6 01             	movzbl (%ecx),%eax
  8007ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007af:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b5:	39 da                	cmp    %ebx,%edx
  8007b7:	75 ed                	jne    8007a6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b9:	89 f0                	mov    %esi,%eax
  8007bb:	5b                   	pop    %ebx
  8007bc:	5e                   	pop    %esi
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8007cd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	74 21                	je     8007f4 <strlcpy+0x35>
  8007d3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d7:	89 f2                	mov    %esi,%edx
  8007d9:	eb 09                	jmp    8007e4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	83 c1 01             	add    $0x1,%ecx
  8007e1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 09                	je     8007f1 <strlcpy+0x32>
  8007e8:	0f b6 19             	movzbl (%ecx),%ebx
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	75 ec                	jne    8007db <strlcpy+0x1c>
  8007ef:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f4:	29 f0                	sub    %esi,%eax
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800803:	eb 06                	jmp    80080b <strcmp+0x11>
		p++, q++;
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080b:	0f b6 01             	movzbl (%ecx),%eax
  80080e:	84 c0                	test   %al,%al
  800810:	74 04                	je     800816 <strcmp+0x1c>
  800812:	3a 02                	cmp    (%edx),%al
  800814:	74 ef                	je     800805 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800816:	0f b6 c0             	movzbl %al,%eax
  800819:	0f b6 12             	movzbl (%edx),%edx
  80081c:	29 d0                	sub    %edx,%eax
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082a:	89 c3                	mov    %eax,%ebx
  80082c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082f:	eb 06                	jmp    800837 <strncmp+0x17>
		n--, p++, q++;
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800837:	39 d8                	cmp    %ebx,%eax
  800839:	74 15                	je     800850 <strncmp+0x30>
  80083b:	0f b6 08             	movzbl (%eax),%ecx
  80083e:	84 c9                	test   %cl,%cl
  800840:	74 04                	je     800846 <strncmp+0x26>
  800842:	3a 0a                	cmp    (%edx),%cl
  800844:	74 eb                	je     800831 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 00             	movzbl (%eax),%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
  80084e:	eb 05                	jmp    800855 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800855:	5b                   	pop    %ebx
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800862:	eb 07                	jmp    80086b <strchr+0x13>
		if (*s == c)
  800864:	38 ca                	cmp    %cl,%dl
  800866:	74 0f                	je     800877 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	0f b6 10             	movzbl (%eax),%edx
  80086e:	84 d2                	test   %dl,%dl
  800870:	75 f2                	jne    800864 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800883:	eb 03                	jmp    800888 <strfind+0xf>
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088b:	38 ca                	cmp    %cl,%dl
  80088d:	74 04                	je     800893 <strfind+0x1a>
  80088f:	84 d2                	test   %dl,%dl
  800891:	75 f2                	jne    800885 <strfind+0xc>
			break;
	return (char *) s;
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	57                   	push   %edi
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a1:	85 c9                	test   %ecx,%ecx
  8008a3:	74 36                	je     8008db <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 28                	jne    8008d5 <memset+0x40>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 23                	jne    8008d5 <memset+0x40>
		c &= 0xFF;
  8008b2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b6:	89 d3                	mov    %edx,%ebx
  8008b8:	c1 e3 08             	shl    $0x8,%ebx
  8008bb:	89 d6                	mov    %edx,%esi
  8008bd:	c1 e6 18             	shl    $0x18,%esi
  8008c0:	89 d0                	mov    %edx,%eax
  8008c2:	c1 e0 10             	shl    $0x10,%eax
  8008c5:	09 f0                	or     %esi,%eax
  8008c7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008c9:	89 d8                	mov    %ebx,%eax
  8008cb:	09 d0                	or     %edx,%eax
  8008cd:	c1 e9 02             	shr    $0x2,%ecx
  8008d0:	fc                   	cld    
  8008d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d3:	eb 06                	jmp    8008db <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	fc                   	cld    
  8008d9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008db:	89 f8                	mov    %edi,%eax
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5f                   	pop    %edi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f0:	39 c6                	cmp    %eax,%esi
  8008f2:	73 35                	jae    800929 <memmove+0x47>
  8008f4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f7:	39 d0                	cmp    %edx,%eax
  8008f9:	73 2e                	jae    800929 <memmove+0x47>
		s += n;
		d += n;
  8008fb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	09 fe                	or     %edi,%esi
  800902:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800908:	75 13                	jne    80091d <memmove+0x3b>
  80090a:	f6 c1 03             	test   $0x3,%cl
  80090d:	75 0e                	jne    80091d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80090f:	83 ef 04             	sub    $0x4,%edi
  800912:	8d 72 fc             	lea    -0x4(%edx),%esi
  800915:	c1 e9 02             	shr    $0x2,%ecx
  800918:	fd                   	std    
  800919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091b:	eb 09                	jmp    800926 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091d:	83 ef 01             	sub    $0x1,%edi
  800920:	8d 72 ff             	lea    -0x1(%edx),%esi
  800923:	fd                   	std    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800926:	fc                   	cld    
  800927:	eb 1d                	jmp    800946 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800929:	89 f2                	mov    %esi,%edx
  80092b:	09 c2                	or     %eax,%edx
  80092d:	f6 c2 03             	test   $0x3,%dl
  800930:	75 0f                	jne    800941 <memmove+0x5f>
  800932:	f6 c1 03             	test   $0x3,%cl
  800935:	75 0a                	jne    800941 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800937:	c1 e9 02             	shr    $0x2,%ecx
  80093a:	89 c7                	mov    %eax,%edi
  80093c:	fc                   	cld    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 05                	jmp    800946 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80094d:	ff 75 10             	pushl  0x10(%ebp)
  800950:	ff 75 0c             	pushl  0xc(%ebp)
  800953:	ff 75 08             	pushl  0x8(%ebp)
  800956:	e8 87 ff ff ff       	call   8008e2 <memmove>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
  800968:	89 c6                	mov    %eax,%esi
  80096a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096d:	eb 1a                	jmp    800989 <memcmp+0x2c>
		if (*s1 != *s2)
  80096f:	0f b6 08             	movzbl (%eax),%ecx
  800972:	0f b6 1a             	movzbl (%edx),%ebx
  800975:	38 d9                	cmp    %bl,%cl
  800977:	74 0a                	je     800983 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800979:	0f b6 c1             	movzbl %cl,%eax
  80097c:	0f b6 db             	movzbl %bl,%ebx
  80097f:	29 d8                	sub    %ebx,%eax
  800981:	eb 0f                	jmp    800992 <memcmp+0x35>
		s1++, s2++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800989:	39 f0                	cmp    %esi,%eax
  80098b:	75 e2                	jne    80096f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a6:	eb 0a                	jmp    8009b2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a8:	0f b6 10             	movzbl (%eax),%edx
  8009ab:	39 da                	cmp    %ebx,%edx
  8009ad:	74 07                	je     8009b6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009af:	83 c0 01             	add    $0x1,%eax
  8009b2:	39 c8                	cmp    %ecx,%eax
  8009b4:	72 f2                	jb     8009a8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c5:	eb 03                	jmp    8009ca <strtol+0x11>
		s++;
  8009c7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ca:	0f b6 01             	movzbl (%ecx),%eax
  8009cd:	3c 20                	cmp    $0x20,%al
  8009cf:	74 f6                	je     8009c7 <strtol+0xe>
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	74 f2                	je     8009c7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d5:	3c 2b                	cmp    $0x2b,%al
  8009d7:	75 0a                	jne    8009e3 <strtol+0x2a>
		s++;
  8009d9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e1:	eb 11                	jmp    8009f4 <strtol+0x3b>
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e8:	3c 2d                	cmp    $0x2d,%al
  8009ea:	75 08                	jne    8009f4 <strtol+0x3b>
		s++, neg = 1;
  8009ec:	83 c1 01             	add    $0x1,%ecx
  8009ef:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fa:	75 15                	jne    800a11 <strtol+0x58>
  8009fc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ff:	75 10                	jne    800a11 <strtol+0x58>
  800a01:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a05:	75 7c                	jne    800a83 <strtol+0xca>
		s += 2, base = 16;
  800a07:	83 c1 02             	add    $0x2,%ecx
  800a0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0f:	eb 16                	jmp    800a27 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a11:	85 db                	test   %ebx,%ebx
  800a13:	75 12                	jne    800a27 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a15:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1d:	75 08                	jne    800a27 <strtol+0x6e>
		s++, base = 8;
  800a1f:	83 c1 01             	add    $0x1,%ecx
  800a22:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2f:	0f b6 11             	movzbl (%ecx),%edx
  800a32:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a35:	89 f3                	mov    %esi,%ebx
  800a37:	80 fb 09             	cmp    $0x9,%bl
  800a3a:	77 08                	ja     800a44 <strtol+0x8b>
			dig = *s - '0';
  800a3c:	0f be d2             	movsbl %dl,%edx
  800a3f:	83 ea 30             	sub    $0x30,%edx
  800a42:	eb 22                	jmp    800a66 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a44:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a47:	89 f3                	mov    %esi,%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a4e:	0f be d2             	movsbl %dl,%edx
  800a51:	83 ea 57             	sub    $0x57,%edx
  800a54:	eb 10                	jmp    800a66 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a56:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a59:	89 f3                	mov    %esi,%ebx
  800a5b:	80 fb 19             	cmp    $0x19,%bl
  800a5e:	77 16                	ja     800a76 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a60:	0f be d2             	movsbl %dl,%edx
  800a63:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a66:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a69:	7d 0b                	jge    800a76 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a6b:	83 c1 01             	add    $0x1,%ecx
  800a6e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a72:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a74:	eb b9                	jmp    800a2f <strtol+0x76>

	if (endptr)
  800a76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7a:	74 0d                	je     800a89 <strtol+0xd0>
		*endptr = (char *) s;
  800a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7f:	89 0e                	mov    %ecx,(%esi)
  800a81:	eb 06                	jmp    800a89 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a83:	85 db                	test   %ebx,%ebx
  800a85:	74 98                	je     800a1f <strtol+0x66>
  800a87:	eb 9e                	jmp    800a27 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a89:	89 c2                	mov    %eax,%edx
  800a8b:	f7 da                	neg    %edx
  800a8d:	85 ff                	test   %edi,%edi
  800a8f:	0f 45 c2             	cmovne %edx,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac5:	89 d1                	mov    %edx,%ecx
  800ac7:	89 d3                	mov    %edx,%ebx
  800ac9:	89 d7                	mov    %edx,%edi
  800acb:	89 d6                	mov    %edx,%esi
  800acd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aea:	89 cb                	mov    %ecx,%ebx
  800aec:	89 cf                	mov    %ecx,%edi
  800aee:	89 ce                	mov    %ecx,%esi
  800af0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af2:	85 c0                	test   %eax,%eax
  800af4:	7e 17                	jle    800b0d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	50                   	push   %eax
  800afa:	6a 03                	push   $0x3
  800afc:	68 1f 26 80 00       	push   $0x80261f
  800b01:	6a 23                	push   $0x23
  800b03:	68 3c 26 80 00       	push   $0x80263c
  800b08:	e8 b0 12 00 00       	call   801dbd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b20:	b8 02 00 00 00       	mov    $0x2,%eax
  800b25:	89 d1                	mov    %edx,%ecx
  800b27:	89 d3                	mov    %edx,%ebx
  800b29:	89 d7                	mov    %edx,%edi
  800b2b:	89 d6                	mov    %edx,%esi
  800b2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_yield>:

void
sys_yield(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	be 00 00 00 00       	mov    $0x0,%esi
  800b61:	b8 04 00 00 00       	mov    $0x4,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	89 f7                	mov    %esi,%edi
  800b71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7e 17                	jle    800b8e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	50                   	push   %eax
  800b7b:	6a 04                	push   $0x4
  800b7d:	68 1f 26 80 00       	push   $0x80261f
  800b82:	6a 23                	push   $0x23
  800b84:	68 3c 26 80 00       	push   $0x80263c
  800b89:	e8 2f 12 00 00       	call   801dbd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb0:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7e 17                	jle    800bd0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 05                	push   $0x5
  800bbf:	68 1f 26 80 00       	push   $0x80261f
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 3c 26 80 00       	push   $0x80263c
  800bcb:	e8 ed 11 00 00       	call   801dbd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	b8 06 00 00 00       	mov    $0x6,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 06                	push   $0x6
  800c01:	68 1f 26 80 00       	push   $0x80261f
  800c06:	6a 23                	push   $0x23
  800c08:	68 3c 26 80 00       	push   $0x80263c
  800c0d:	e8 ab 11 00 00       	call   801dbd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	89 de                	mov    %ebx,%esi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 08                	push   $0x8
  800c43:	68 1f 26 80 00       	push   $0x80261f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 3c 26 80 00       	push   $0x80263c
  800c4f:	e8 69 11 00 00       	call   801dbd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 09                	push   $0x9
  800c85:	68 1f 26 80 00       	push   $0x80261f
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 3c 26 80 00       	push   $0x80263c
  800c91:	e8 27 11 00 00       	call   801dbd <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cac:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 df                	mov    %ebx,%edi
  800cb9:	89 de                	mov    %ebx,%esi
  800cbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 0a                	push   $0xa
  800cc7:	68 1f 26 80 00       	push   $0x80261f
  800ccc:	6a 23                	push   $0x23
  800cce:	68 3c 26 80 00       	push   $0x80263c
  800cd3:	e8 e5 10 00 00       	call   801dbd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	be 00 00 00 00       	mov    $0x0,%esi
  800ceb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 cb                	mov    %ecx,%ebx
  800d1b:	89 cf                	mov    %ecx,%edi
  800d1d:	89 ce                	mov    %ecx,%esi
  800d1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7e 17                	jle    800d3c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 0d                	push   $0xd
  800d2b:	68 1f 26 80 00       	push   $0x80261f
  800d30:	6a 23                	push   $0x23
  800d32:	68 3c 26 80 00       	push   $0x80263c
  800d37:	e8 81 10 00 00       	call   801dbd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	89 cb                	mov    %ecx,%ebx
  800d59:	89 cf                	mov    %ecx,%edi
  800d5b:	89 ce                	mov    %ecx,%esi
  800d5d:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 cb                	mov    %ecx,%ebx
  800d79:	89 cf                	mov    %ecx,%edi
  800d7b:	89 ce                	mov    %ecx,%esi
  800d7d:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8f:	b8 10 00 00 00       	mov    $0x10,%eax
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 cb                	mov    %ecx,%ebx
  800d99:	89 cf                	mov    %ecx,%edi
  800d9b:	89 ce                	mov    %ecx,%esi
  800d9d:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	53                   	push   %ebx
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dae:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800db0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800db4:	74 11                	je     800dc7 <pgfault+0x23>
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	c1 e8 0c             	shr    $0xc,%eax
  800dbb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc2:	f6 c4 08             	test   $0x8,%ah
  800dc5:	75 14                	jne    800ddb <pgfault+0x37>
		panic("faulting access");
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	68 4a 26 80 00       	push   $0x80264a
  800dcf:	6a 1e                	push   $0x1e
  800dd1:	68 5a 26 80 00       	push   $0x80265a
  800dd6:	e8 e2 0f 00 00       	call   801dbd <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	6a 07                	push   $0x7
  800de0:	68 00 f0 7f 00       	push   $0x7ff000
  800de5:	6a 00                	push   $0x0
  800de7:	e8 67 fd ff ff       	call   800b53 <sys_page_alloc>
	if (r < 0) {
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 12                	jns    800e05 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800df3:	50                   	push   %eax
  800df4:	68 65 26 80 00       	push   $0x802665
  800df9:	6a 2c                	push   $0x2c
  800dfb:	68 5a 26 80 00       	push   $0x80265a
  800e00:	e8 b8 0f 00 00       	call   801dbd <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e05:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	68 00 10 00 00       	push   $0x1000
  800e13:	53                   	push   %ebx
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	e8 2c fb ff ff       	call   80094a <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e1e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e25:	53                   	push   %ebx
  800e26:	6a 00                	push   $0x0
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 62 fd ff ff       	call   800b96 <sys_page_map>
	if (r < 0) {
  800e34:	83 c4 20             	add    $0x20,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	79 12                	jns    800e4d <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e3b:	50                   	push   %eax
  800e3c:	68 65 26 80 00       	push   $0x802665
  800e41:	6a 33                	push   $0x33
  800e43:	68 5a 26 80 00       	push   $0x80265a
  800e48:	e8 70 0f 00 00       	call   801dbd <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	68 00 f0 7f 00       	push   $0x7ff000
  800e55:	6a 00                	push   $0x0
  800e57:	e8 7c fd ff ff       	call   800bd8 <sys_page_unmap>
	if (r < 0) {
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 12                	jns    800e75 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e63:	50                   	push   %eax
  800e64:	68 65 26 80 00       	push   $0x802665
  800e69:	6a 37                	push   $0x37
  800e6b:	68 5a 26 80 00       	push   $0x80265a
  800e70:	e8 48 0f 00 00       	call   801dbd <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    

00800e7a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e83:	68 a4 0d 80 00       	push   $0x800da4
  800e88:	e8 76 0f 00 00       	call   801e03 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e8d:	b8 07 00 00 00       	mov    $0x7,%eax
  800e92:	cd 30                	int    $0x30
  800e94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 17                	jns    800eb5 <fork+0x3b>
		panic("fork fault %e");
  800e9e:	83 ec 04             	sub    $0x4,%esp
  800ea1:	68 7e 26 80 00       	push   $0x80267e
  800ea6:	68 84 00 00 00       	push   $0x84
  800eab:	68 5a 26 80 00       	push   $0x80265a
  800eb0:	e8 08 0f 00 00       	call   801dbd <_panic>
  800eb5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800eb7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ebb:	75 24                	jne    800ee1 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ebd:	e8 53 fc ff ff       	call   800b15 <sys_getenvid>
  800ec2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ec7:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800ecd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ed2:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  800edc:	e9 64 01 00 00       	jmp    801045 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	6a 07                	push   $0x7
  800ee6:	68 00 f0 bf ee       	push   $0xeebff000
  800eeb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eee:	e8 60 fc ff ff       	call   800b53 <sys_page_alloc>
  800ef3:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	c1 e8 16             	shr    $0x16,%eax
  800f00:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f07:	a8 01                	test   $0x1,%al
  800f09:	0f 84 fc 00 00 00    	je     80100b <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f0f:	89 d8                	mov    %ebx,%eax
  800f11:	c1 e8 0c             	shr    $0xc,%eax
  800f14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f1b:	f6 c2 01             	test   $0x1,%dl
  800f1e:	0f 84 e7 00 00 00    	je     80100b <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f24:	89 c6                	mov    %eax,%esi
  800f26:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f29:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f30:	f6 c6 04             	test   $0x4,%dh
  800f33:	74 39                	je     800f6e <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3c:	83 ec 0c             	sub    $0xc,%esp
  800f3f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f44:	50                   	push   %eax
  800f45:	56                   	push   %esi
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 47 fc ff ff       	call   800b96 <sys_page_map>
		if (r < 0) {
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	0f 89 b1 00 00 00    	jns    80100b <fork+0x191>
		    	panic("sys page map fault %e");
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 8c 26 80 00       	push   $0x80268c
  800f62:	6a 54                	push   $0x54
  800f64:	68 5a 26 80 00       	push   $0x80265a
  800f69:	e8 4f 0e 00 00       	call   801dbd <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f6e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f75:	f6 c2 02             	test   $0x2,%dl
  800f78:	75 0c                	jne    800f86 <fork+0x10c>
  800f7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f81:	f6 c4 08             	test   $0x8,%ah
  800f84:	74 5b                	je     800fe1 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	68 05 08 00 00       	push   $0x805
  800f8e:	56                   	push   %esi
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	6a 00                	push   $0x0
  800f93:	e8 fe fb ff ff       	call   800b96 <sys_page_map>
		if (r < 0) {
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	79 14                	jns    800fb3 <fork+0x139>
		    	panic("sys page map fault %e");
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	68 8c 26 80 00       	push   $0x80268c
  800fa7:	6a 5b                	push   $0x5b
  800fa9:	68 5a 26 80 00       	push   $0x80265a
  800fae:	e8 0a 0e 00 00       	call   801dbd <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	68 05 08 00 00       	push   $0x805
  800fbb:	56                   	push   %esi
  800fbc:	6a 00                	push   $0x0
  800fbe:	56                   	push   %esi
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 d0 fb ff ff       	call   800b96 <sys_page_map>
		if (r < 0) {
  800fc6:	83 c4 20             	add    $0x20,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	79 3e                	jns    80100b <fork+0x191>
		    	panic("sys page map fault %e");
  800fcd:	83 ec 04             	sub    $0x4,%esp
  800fd0:	68 8c 26 80 00       	push   $0x80268c
  800fd5:	6a 5f                	push   $0x5f
  800fd7:	68 5a 26 80 00       	push   $0x80265a
  800fdc:	e8 dc 0d 00 00       	call   801dbd <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	6a 05                	push   $0x5
  800fe6:	56                   	push   %esi
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 a6 fb ff ff       	call   800b96 <sys_page_map>
		if (r < 0) {
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 14                	jns    80100b <fork+0x191>
		    	panic("sys page map fault %e");
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 8c 26 80 00       	push   $0x80268c
  800fff:	6a 64                	push   $0x64
  801001:	68 5a 26 80 00       	push   $0x80265a
  801006:	e8 b2 0d 00 00       	call   801dbd <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80100b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801011:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801017:	0f 85 de fe ff ff    	jne    800efb <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80101d:	a1 04 40 80 00       	mov    0x804004,%eax
  801022:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  801028:	83 ec 08             	sub    $0x8,%esp
  80102b:	50                   	push   %eax
  80102c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80102f:	57                   	push   %edi
  801030:	e8 69 fc ff ff       	call   800c9e <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801035:	83 c4 08             	add    $0x8,%esp
  801038:	6a 02                	push   $0x2
  80103a:	57                   	push   %edi
  80103b:	e8 da fb ff ff       	call   800c1a <sys_env_set_status>
	
	return envid;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sfork>:

envid_t
sfork(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80105f:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	53                   	push   %ebx
  801069:	68 a4 26 80 00       	push   $0x8026a4
  80106e:	e8 58 f1 ff ff       	call   8001cb <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801073:	c7 04 24 fe 00 80 00 	movl   $0x8000fe,(%esp)
  80107a:	e8 c5 fc ff ff       	call   800d44 <sys_thread_create>
  80107f:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801081:	83 c4 08             	add    $0x8,%esp
  801084:	53                   	push   %ebx
  801085:	68 a4 26 80 00       	push   $0x8026a4
  80108a:	e8 3c f1 ff ff       	call   8001cb <cprintf>
	return id;
}
  80108f:	89 f0                	mov    %esi,%eax
  801091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80109e:	ff 75 08             	pushl  0x8(%ebp)
  8010a1:	e8 be fc ff ff       	call   800d64 <sys_thread_free>
}
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8010b1:	ff 75 08             	pushl  0x8(%ebp)
  8010b4:	e8 cb fc ff ff       	call   800d84 <sys_thread_join>
}
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c9:	c1 e8 0c             	shr    $0xc,%eax
}
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010de:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010eb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	c1 ea 16             	shr    $0x16,%edx
  8010f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010fc:	f6 c2 01             	test   $0x1,%dl
  8010ff:	74 11                	je     801112 <fd_alloc+0x2d>
  801101:	89 c2                	mov    %eax,%edx
  801103:	c1 ea 0c             	shr    $0xc,%edx
  801106:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80110d:	f6 c2 01             	test   $0x1,%dl
  801110:	75 09                	jne    80111b <fd_alloc+0x36>
			*fd_store = fd;
  801112:	89 01                	mov    %eax,(%ecx)
			return 0;
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
  801119:	eb 17                	jmp    801132 <fd_alloc+0x4d>
  80111b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801120:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801125:	75 c9                	jne    8010f0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801127:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80112d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80113a:	83 f8 1f             	cmp    $0x1f,%eax
  80113d:	77 36                	ja     801175 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80113f:	c1 e0 0c             	shl    $0xc,%eax
  801142:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801147:	89 c2                	mov    %eax,%edx
  801149:	c1 ea 16             	shr    $0x16,%edx
  80114c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801153:	f6 c2 01             	test   $0x1,%dl
  801156:	74 24                	je     80117c <fd_lookup+0x48>
  801158:	89 c2                	mov    %eax,%edx
  80115a:	c1 ea 0c             	shr    $0xc,%edx
  80115d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801164:	f6 c2 01             	test   $0x1,%dl
  801167:	74 1a                	je     801183 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801169:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116c:	89 02                	mov    %eax,(%edx)
	return 0;
  80116e:	b8 00 00 00 00       	mov    $0x0,%eax
  801173:	eb 13                	jmp    801188 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801175:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117a:	eb 0c                	jmp    801188 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80117c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801181:	eb 05                	jmp    801188 <fd_lookup+0x54>
  801183:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801193:	ba 44 27 80 00       	mov    $0x802744,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801198:	eb 13                	jmp    8011ad <dev_lookup+0x23>
  80119a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80119d:	39 08                	cmp    %ecx,(%eax)
  80119f:	75 0c                	jne    8011ad <dev_lookup+0x23>
			*dev = devtab[i];
  8011a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ab:	eb 31                	jmp    8011de <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ad:	8b 02                	mov    (%edx),%eax
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	75 e7                	jne    80119a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8011be:	83 ec 04             	sub    $0x4,%esp
  8011c1:	51                   	push   %ecx
  8011c2:	50                   	push   %eax
  8011c3:	68 c8 26 80 00       	push   $0x8026c8
  8011c8:	e8 fe ef ff ff       	call   8001cb <cprintf>
	*dev = 0;
  8011cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 10             	sub    $0x10,%esp
  8011e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011f8:	c1 e8 0c             	shr    $0xc,%eax
  8011fb:	50                   	push   %eax
  8011fc:	e8 33 ff ff ff       	call   801134 <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 05                	js     80120d <fd_close+0x2d>
	    || fd != fd2)
  801208:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80120b:	74 0c                	je     801219 <fd_close+0x39>
		return (must_exist ? r : 0);
  80120d:	84 db                	test   %bl,%bl
  80120f:	ba 00 00 00 00       	mov    $0x0,%edx
  801214:	0f 44 c2             	cmove  %edx,%eax
  801217:	eb 41                	jmp    80125a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 36                	pushl  (%esi)
  801222:	e8 63 ff ff ff       	call   80118a <dev_lookup>
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 1a                	js     80124a <fd_close+0x6a>
		if (dev->dev_close)
  801230:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801233:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80123b:	85 c0                	test   %eax,%eax
  80123d:	74 0b                	je     80124a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	56                   	push   %esi
  801243:	ff d0                	call   *%eax
  801245:	89 c3                	mov    %eax,%ebx
  801247:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	56                   	push   %esi
  80124e:	6a 00                	push   $0x0
  801250:	e8 83 f9 ff ff       	call   800bd8 <sys_page_unmap>
	return r;
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	89 d8                	mov    %ebx,%eax
}
  80125a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	ff 75 08             	pushl  0x8(%ebp)
  80126e:	e8 c1 fe ff ff       	call   801134 <fd_lookup>
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 10                	js     80128a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	6a 01                	push   $0x1
  80127f:	ff 75 f4             	pushl  -0xc(%ebp)
  801282:	e8 59 ff ff ff       	call   8011e0 <fd_close>
  801287:	83 c4 10             	add    $0x10,%esp
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <close_all>:

void
close_all(void)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	53                   	push   %ebx
  801290:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	53                   	push   %ebx
  80129c:	e8 c0 ff ff ff       	call   801261 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a1:	83 c3 01             	add    $0x1,%ebx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	83 fb 20             	cmp    $0x20,%ebx
  8012aa:	75 ec                	jne    801298 <close_all+0xc>
		close(i);
}
  8012ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    

008012b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	57                   	push   %edi
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 2c             	sub    $0x2c,%esp
  8012ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 75 08             	pushl  0x8(%ebp)
  8012c4:	e8 6b fe ff ff       	call   801134 <fd_lookup>
  8012c9:	83 c4 08             	add    $0x8,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	0f 88 c1 00 00 00    	js     801395 <dup+0xe4>
		return r;
	close(newfdnum);
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	56                   	push   %esi
  8012d8:	e8 84 ff ff ff       	call   801261 <close>

	newfd = INDEX2FD(newfdnum);
  8012dd:	89 f3                	mov    %esi,%ebx
  8012df:	c1 e3 0c             	shl    $0xc,%ebx
  8012e2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012e8:	83 c4 04             	add    $0x4,%esp
  8012eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ee:	e8 db fd ff ff       	call   8010ce <fd2data>
  8012f3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012f5:	89 1c 24             	mov    %ebx,(%esp)
  8012f8:	e8 d1 fd ff ff       	call   8010ce <fd2data>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801303:	89 f8                	mov    %edi,%eax
  801305:	c1 e8 16             	shr    $0x16,%eax
  801308:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130f:	a8 01                	test   $0x1,%al
  801311:	74 37                	je     80134a <dup+0x99>
  801313:	89 f8                	mov    %edi,%eax
  801315:	c1 e8 0c             	shr    $0xc,%eax
  801318:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131f:	f6 c2 01             	test   $0x1,%dl
  801322:	74 26                	je     80134a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801324:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	25 07 0e 00 00       	and    $0xe07,%eax
  801333:	50                   	push   %eax
  801334:	ff 75 d4             	pushl  -0x2c(%ebp)
  801337:	6a 00                	push   $0x0
  801339:	57                   	push   %edi
  80133a:	6a 00                	push   $0x0
  80133c:	e8 55 f8 ff ff       	call   800b96 <sys_page_map>
  801341:	89 c7                	mov    %eax,%edi
  801343:	83 c4 20             	add    $0x20,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 2e                	js     801378 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80134d:	89 d0                	mov    %edx,%eax
  80134f:	c1 e8 0c             	shr    $0xc,%eax
  801352:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	25 07 0e 00 00       	and    $0xe07,%eax
  801361:	50                   	push   %eax
  801362:	53                   	push   %ebx
  801363:	6a 00                	push   $0x0
  801365:	52                   	push   %edx
  801366:	6a 00                	push   $0x0
  801368:	e8 29 f8 ff ff       	call   800b96 <sys_page_map>
  80136d:	89 c7                	mov    %eax,%edi
  80136f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801372:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801374:	85 ff                	test   %edi,%edi
  801376:	79 1d                	jns    801395 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	53                   	push   %ebx
  80137c:	6a 00                	push   $0x0
  80137e:	e8 55 f8 ff ff       	call   800bd8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801383:	83 c4 08             	add    $0x8,%esp
  801386:	ff 75 d4             	pushl  -0x2c(%ebp)
  801389:	6a 00                	push   $0x0
  80138b:	e8 48 f8 ff ff       	call   800bd8 <sys_page_unmap>
	return r;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	89 f8                	mov    %edi,%eax
}
  801395:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 14             	sub    $0x14,%esp
  8013a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	53                   	push   %ebx
  8013ac:	e8 83 fd ff ff       	call   801134 <fd_lookup>
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 70                	js     80142a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c4:	ff 30                	pushl  (%eax)
  8013c6:	e8 bf fd ff ff       	call   80118a <dev_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 4f                	js     801421 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d5:	8b 42 08             	mov    0x8(%edx),%eax
  8013d8:	83 e0 03             	and    $0x3,%eax
  8013db:	83 f8 01             	cmp    $0x1,%eax
  8013de:	75 24                	jne    801404 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	50                   	push   %eax
  8013f0:	68 09 27 80 00       	push   $0x802709
  8013f5:	e8 d1 ed ff ff       	call   8001cb <cprintf>
		return -E_INVAL;
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801402:	eb 26                	jmp    80142a <read+0x8d>
	}
	if (!dev->dev_read)
  801404:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801407:	8b 40 08             	mov    0x8(%eax),%eax
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 17                	je     801425 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	ff 75 10             	pushl  0x10(%ebp)
  801414:	ff 75 0c             	pushl  0xc(%ebp)
  801417:	52                   	push   %edx
  801418:	ff d0                	call   *%eax
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	eb 09                	jmp    80142a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801421:	89 c2                	mov    %eax,%edx
  801423:	eb 05                	jmp    80142a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801425:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80142a:	89 d0                	mov    %edx,%eax
  80142c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
  801445:	eb 21                	jmp    801468 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	89 f0                	mov    %esi,%eax
  80144c:	29 d8                	sub    %ebx,%eax
  80144e:	50                   	push   %eax
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	03 45 0c             	add    0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	57                   	push   %edi
  801456:	e8 42 ff ff ff       	call   80139d <read>
		if (m < 0)
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 10                	js     801472 <readn+0x41>
			return m;
		if (m == 0)
  801462:	85 c0                	test   %eax,%eax
  801464:	74 0a                	je     801470 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801466:	01 c3                	add    %eax,%ebx
  801468:	39 f3                	cmp    %esi,%ebx
  80146a:	72 db                	jb     801447 <readn+0x16>
  80146c:	89 d8                	mov    %ebx,%eax
  80146e:	eb 02                	jmp    801472 <readn+0x41>
  801470:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801472:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5f                   	pop    %edi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 14             	sub    $0x14,%esp
  801481:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801484:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	53                   	push   %ebx
  801489:	e8 a6 fc ff ff       	call   801134 <fd_lookup>
  80148e:	83 c4 08             	add    $0x8,%esp
  801491:	89 c2                	mov    %eax,%edx
  801493:	85 c0                	test   %eax,%eax
  801495:	78 6b                	js     801502 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a1:	ff 30                	pushl  (%eax)
  8014a3:	e8 e2 fc ff ff       	call   80118a <dev_lookup>
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 4a                	js     8014f9 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b6:	75 24                	jne    8014dc <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	53                   	push   %ebx
  8014c7:	50                   	push   %eax
  8014c8:	68 25 27 80 00       	push   $0x802725
  8014cd:	e8 f9 ec ff ff       	call   8001cb <cprintf>
		return -E_INVAL;
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014da:	eb 26                	jmp    801502 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014df:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e2:	85 d2                	test   %edx,%edx
  8014e4:	74 17                	je     8014fd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	ff 75 10             	pushl  0x10(%ebp)
  8014ec:	ff 75 0c             	pushl  0xc(%ebp)
  8014ef:	50                   	push   %eax
  8014f0:	ff d2                	call   *%edx
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	eb 09                	jmp    801502 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	eb 05                	jmp    801502 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801502:	89 d0                	mov    %edx,%eax
  801504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <seek>:

int
seek(int fdnum, off_t offset)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	ff 75 08             	pushl  0x8(%ebp)
  801516:	e8 19 fc ff ff       	call   801134 <fd_lookup>
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 0e                	js     801530 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801522:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801525:	8b 55 0c             	mov    0xc(%ebp),%edx
  801528:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	53                   	push   %ebx
  801536:	83 ec 14             	sub    $0x14,%esp
  801539:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	53                   	push   %ebx
  801541:	e8 ee fb ff ff       	call   801134 <fd_lookup>
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	89 c2                	mov    %eax,%edx
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 68                	js     8015b7 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	ff 30                	pushl  (%eax)
  80155b:	e8 2a fc ff ff       	call   80118a <dev_lookup>
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 47                	js     8015ae <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156e:	75 24                	jne    801594 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801570:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801575:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	53                   	push   %ebx
  80157f:	50                   	push   %eax
  801580:	68 e8 26 80 00       	push   $0x8026e8
  801585:	e8 41 ec ff ff       	call   8001cb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801592:	eb 23                	jmp    8015b7 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801597:	8b 52 18             	mov    0x18(%edx),%edx
  80159a:	85 d2                	test   %edx,%edx
  80159c:	74 14                	je     8015b2 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	50                   	push   %eax
  8015a5:	ff d2                	call   *%edx
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	eb 09                	jmp    8015b7 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	eb 05                	jmp    8015b7 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b7:	89 d0                	mov    %edx,%eax
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 60 fb ff ff       	call   801134 <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 58                	js     801635 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e7:	ff 30                	pushl  (%eax)
  8015e9:	e8 9c fb ff ff       	call   80118a <dev_lookup>
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 37                	js     80162c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fc:	74 32                	je     801630 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801601:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801608:	00 00 00 
	stat->st_isdir = 0;
  80160b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801612:	00 00 00 
	stat->st_dev = dev;
  801615:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	53                   	push   %ebx
  80161f:	ff 75 f0             	pushl  -0x10(%ebp)
  801622:	ff 50 14             	call   *0x14(%eax)
  801625:	89 c2                	mov    %eax,%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 09                	jmp    801635 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	eb 05                	jmp    801635 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801630:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	6a 00                	push   $0x0
  801646:	ff 75 08             	pushl  0x8(%ebp)
  801649:	e8 e3 01 00 00       	call   801831 <open>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 1b                	js     801672 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	50                   	push   %eax
  80165e:	e8 5b ff ff ff       	call   8015be <fstat>
  801663:	89 c6                	mov    %eax,%esi
	close(fd);
  801665:	89 1c 24             	mov    %ebx,(%esp)
  801668:	e8 f4 fb ff ff       	call   801261 <close>
	return r;
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	89 f0                	mov    %esi,%eax
}
  801672:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	56                   	push   %esi
  80167d:	53                   	push   %ebx
  80167e:	89 c6                	mov    %eax,%esi
  801680:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801682:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801689:	75 12                	jne    80169d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	6a 01                	push   $0x1
  801690:	e8 da 08 00 00       	call   801f6f <ipc_find_env>
  801695:	a3 00 40 80 00       	mov    %eax,0x804000
  80169a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80169d:	6a 07                	push   $0x7
  80169f:	68 00 50 80 00       	push   $0x805000
  8016a4:	56                   	push   %esi
  8016a5:	ff 35 00 40 80 00    	pushl  0x804000
  8016ab:	e8 5d 08 00 00       	call   801f0d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b0:	83 c4 0c             	add    $0xc,%esp
  8016b3:	6a 00                	push   $0x0
  8016b5:	53                   	push   %ebx
  8016b6:	6a 00                	push   $0x0
  8016b8:	e8 d5 07 00 00       	call   801e92 <ipc_recv>
}
  8016bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e7:	e8 8d ff ff ff       	call   801679 <fsipc>
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 06 00 00 00       	mov    $0x6,%eax
  801709:	e8 6b ff ff ff       	call   801679 <fsipc>
}
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	53                   	push   %ebx
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	8b 40 0c             	mov    0xc(%eax),%eax
  801720:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	b8 05 00 00 00       	mov    $0x5,%eax
  80172f:	e8 45 ff ff ff       	call   801679 <fsipc>
  801734:	85 c0                	test   %eax,%eax
  801736:	78 2c                	js     801764 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	68 00 50 80 00       	push   $0x805000
  801740:	53                   	push   %ebx
  801741:	e8 0a f0 ff ff       	call   800750 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801746:	a1 80 50 80 00       	mov    0x805080,%eax
  80174b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801751:	a1 84 50 80 00       	mov    0x805084,%eax
  801756:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801772:	8b 55 08             	mov    0x8(%ebp),%edx
  801775:	8b 52 0c             	mov    0xc(%edx),%edx
  801778:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80177e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801783:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801788:	0f 47 c2             	cmova  %edx,%eax
  80178b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801790:	50                   	push   %eax
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	68 08 50 80 00       	push   $0x805008
  801799:	e8 44 f1 ff ff       	call   8008e2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80179e:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a8:	e8 cc fe ff ff       	call   801679 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    

008017af <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	56                   	push   %esi
  8017b3:	53                   	push   %ebx
  8017b4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017c2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d2:	e8 a2 fe ff ff       	call   801679 <fsipc>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 4b                	js     801828 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017dd:	39 c6                	cmp    %eax,%esi
  8017df:	73 16                	jae    8017f7 <devfile_read+0x48>
  8017e1:	68 54 27 80 00       	push   $0x802754
  8017e6:	68 5b 27 80 00       	push   $0x80275b
  8017eb:	6a 7c                	push   $0x7c
  8017ed:	68 70 27 80 00       	push   $0x802770
  8017f2:	e8 c6 05 00 00       	call   801dbd <_panic>
	assert(r <= PGSIZE);
  8017f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017fc:	7e 16                	jle    801814 <devfile_read+0x65>
  8017fe:	68 7b 27 80 00       	push   $0x80277b
  801803:	68 5b 27 80 00       	push   $0x80275b
  801808:	6a 7d                	push   $0x7d
  80180a:	68 70 27 80 00       	push   $0x802770
  80180f:	e8 a9 05 00 00       	call   801dbd <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	50                   	push   %eax
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	e8 bd f0 ff ff       	call   8008e2 <memmove>
	return r;
  801825:	83 c4 10             	add    $0x10,%esp
}
  801828:	89 d8                	mov    %ebx,%eax
  80182a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 20             	sub    $0x20,%esp
  801838:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183b:	53                   	push   %ebx
  80183c:	e8 d6 ee ff ff       	call   800717 <strlen>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801849:	7f 67                	jg     8018b2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184b:	83 ec 0c             	sub    $0xc,%esp
  80184e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801851:	50                   	push   %eax
  801852:	e8 8e f8 ff ff       	call   8010e5 <fd_alloc>
  801857:	83 c4 10             	add    $0x10,%esp
		return r;
  80185a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 57                	js     8018b7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	53                   	push   %ebx
  801864:	68 00 50 80 00       	push   $0x805000
  801869:	e8 e2 ee ff ff       	call   800750 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80186e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801871:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801879:	b8 01 00 00 00       	mov    $0x1,%eax
  80187e:	e8 f6 fd ff ff       	call   801679 <fsipc>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	79 14                	jns    8018a0 <open+0x6f>
		fd_close(fd, 0);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	6a 00                	push   $0x0
  801891:	ff 75 f4             	pushl  -0xc(%ebp)
  801894:	e8 47 f9 ff ff       	call   8011e0 <fd_close>
		return r;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	89 da                	mov    %ebx,%edx
  80189e:	eb 17                	jmp    8018b7 <open+0x86>
	}

	return fd2num(fd);
  8018a0:	83 ec 0c             	sub    $0xc,%esp
  8018a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a6:	e8 13 f8 ff ff       	call   8010be <fd2num>
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	eb 05                	jmp    8018b7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b7:	89 d0                	mov    %edx,%eax
  8018b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c9:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ce:	e8 a6 fd ff ff       	call   801679 <fsipc>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 08             	pushl  0x8(%ebp)
  8018e3:	e8 e6 f7 ff ff       	call   8010ce <fd2data>
  8018e8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	68 87 27 80 00       	push   $0x802787
  8018f2:	53                   	push   %ebx
  8018f3:	e8 58 ee ff ff       	call   800750 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f8:	8b 46 04             	mov    0x4(%esi),%eax
  8018fb:	2b 06                	sub    (%esi),%eax
  8018fd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801903:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190a:	00 00 00 
	stat->st_dev = &devpipe;
  80190d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801914:	30 80 00 
	return 0;
}
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
  80191c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80192d:	53                   	push   %ebx
  80192e:	6a 00                	push   $0x0
  801930:	e8 a3 f2 ff ff       	call   800bd8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801935:	89 1c 24             	mov    %ebx,(%esp)
  801938:	e8 91 f7 ff ff       	call   8010ce <fd2data>
  80193d:	83 c4 08             	add    $0x8,%esp
  801940:	50                   	push   %eax
  801941:	6a 00                	push   $0x0
  801943:	e8 90 f2 ff ff       	call   800bd8 <sys_page_unmap>
}
  801948:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	57                   	push   %edi
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	83 ec 1c             	sub    $0x1c,%esp
  801956:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801959:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80195b:	a1 04 40 80 00       	mov    0x804004,%eax
  801960:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801966:	83 ec 0c             	sub    $0xc,%esp
  801969:	ff 75 e0             	pushl  -0x20(%ebp)
  80196c:	e8 43 06 00 00       	call   801fb4 <pageref>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	89 3c 24             	mov    %edi,(%esp)
  801976:	e8 39 06 00 00       	call   801fb4 <pageref>
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	39 c3                	cmp    %eax,%ebx
  801980:	0f 94 c1             	sete   %cl
  801983:	0f b6 c9             	movzbl %cl,%ecx
  801986:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801989:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80198f:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801995:	39 ce                	cmp    %ecx,%esi
  801997:	74 1e                	je     8019b7 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801999:	39 c3                	cmp    %eax,%ebx
  80199b:	75 be                	jne    80195b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80199d:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8019a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a6:	50                   	push   %eax
  8019a7:	56                   	push   %esi
  8019a8:	68 8e 27 80 00       	push   $0x80278e
  8019ad:	e8 19 e8 ff ff       	call   8001cb <cprintf>
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	eb a4                	jmp    80195b <_pipeisclosed+0xe>
	}
}
  8019b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5f                   	pop    %edi
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	57                   	push   %edi
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 28             	sub    $0x28,%esp
  8019cb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019ce:	56                   	push   %esi
  8019cf:	e8 fa f6 ff ff       	call   8010ce <fd2data>
  8019d4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8019de:	eb 4b                	jmp    801a2b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019e0:	89 da                	mov    %ebx,%edx
  8019e2:	89 f0                	mov    %esi,%eax
  8019e4:	e8 64 ff ff ff       	call   80194d <_pipeisclosed>
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	75 48                	jne    801a35 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019ed:	e8 42 f1 ff ff       	call   800b34 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f5:	8b 0b                	mov    (%ebx),%ecx
  8019f7:	8d 51 20             	lea    0x20(%ecx),%edx
  8019fa:	39 d0                	cmp    %edx,%eax
  8019fc:	73 e2                	jae    8019e0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a01:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a05:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	c1 fa 1f             	sar    $0x1f,%edx
  801a0d:	89 d1                	mov    %edx,%ecx
  801a0f:	c1 e9 1b             	shr    $0x1b,%ecx
  801a12:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a15:	83 e2 1f             	and    $0x1f,%edx
  801a18:	29 ca                	sub    %ecx,%edx
  801a1a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a1e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a22:	83 c0 01             	add    $0x1,%eax
  801a25:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a28:	83 c7 01             	add    $0x1,%edi
  801a2b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a2e:	75 c2                	jne    8019f2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a30:	8b 45 10             	mov    0x10(%ebp),%eax
  801a33:	eb 05                	jmp    801a3a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a35:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5f                   	pop    %edi
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	57                   	push   %edi
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	83 ec 18             	sub    $0x18,%esp
  801a4b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a4e:	57                   	push   %edi
  801a4f:	e8 7a f6 ff ff       	call   8010ce <fd2data>
  801a54:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a5e:	eb 3d                	jmp    801a9d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a60:	85 db                	test   %ebx,%ebx
  801a62:	74 04                	je     801a68 <devpipe_read+0x26>
				return i;
  801a64:	89 d8                	mov    %ebx,%eax
  801a66:	eb 44                	jmp    801aac <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a68:	89 f2                	mov    %esi,%edx
  801a6a:	89 f8                	mov    %edi,%eax
  801a6c:	e8 dc fe ff ff       	call   80194d <_pipeisclosed>
  801a71:	85 c0                	test   %eax,%eax
  801a73:	75 32                	jne    801aa7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a75:	e8 ba f0 ff ff       	call   800b34 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a7a:	8b 06                	mov    (%esi),%eax
  801a7c:	3b 46 04             	cmp    0x4(%esi),%eax
  801a7f:	74 df                	je     801a60 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a81:	99                   	cltd   
  801a82:	c1 ea 1b             	shr    $0x1b,%edx
  801a85:	01 d0                	add    %edx,%eax
  801a87:	83 e0 1f             	and    $0x1f,%eax
  801a8a:	29 d0                	sub    %edx,%eax
  801a8c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a94:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a97:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9a:	83 c3 01             	add    $0x1,%ebx
  801a9d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aa0:	75 d8                	jne    801a7a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa5:	eb 05                	jmp    801aac <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5f                   	pop    %edi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801abc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abf:	50                   	push   %eax
  801ac0:	e8 20 f6 ff ff       	call   8010e5 <fd_alloc>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	89 c2                	mov    %eax,%edx
  801aca:	85 c0                	test   %eax,%eax
  801acc:	0f 88 2c 01 00 00    	js     801bfe <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad2:	83 ec 04             	sub    $0x4,%esp
  801ad5:	68 07 04 00 00       	push   $0x407
  801ada:	ff 75 f4             	pushl  -0xc(%ebp)
  801add:	6a 00                	push   $0x0
  801adf:	e8 6f f0 ff ff       	call   800b53 <sys_page_alloc>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	89 c2                	mov    %eax,%edx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	0f 88 0d 01 00 00    	js     801bfe <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af7:	50                   	push   %eax
  801af8:	e8 e8 f5 ff ff       	call   8010e5 <fd_alloc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	0f 88 e2 00 00 00    	js     801bec <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	68 07 04 00 00       	push   $0x407
  801b12:	ff 75 f0             	pushl  -0x10(%ebp)
  801b15:	6a 00                	push   $0x0
  801b17:	e8 37 f0 ff ff       	call   800b53 <sys_page_alloc>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	0f 88 c3 00 00 00    	js     801bec <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2f:	e8 9a f5 ff ff       	call   8010ce <fd2data>
  801b34:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b36:	83 c4 0c             	add    $0xc,%esp
  801b39:	68 07 04 00 00       	push   $0x407
  801b3e:	50                   	push   %eax
  801b3f:	6a 00                	push   $0x0
  801b41:	e8 0d f0 ff ff       	call   800b53 <sys_page_alloc>
  801b46:	89 c3                	mov    %eax,%ebx
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	0f 88 89 00 00 00    	js     801bdc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	ff 75 f0             	pushl  -0x10(%ebp)
  801b59:	e8 70 f5 ff ff       	call   8010ce <fd2data>
  801b5e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b65:	50                   	push   %eax
  801b66:	6a 00                	push   $0x0
  801b68:	56                   	push   %esi
  801b69:	6a 00                	push   $0x0
  801b6b:	e8 26 f0 ff ff       	call   800b96 <sys_page_map>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	83 c4 20             	add    $0x20,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 55                	js     801bce <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b79:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b87:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b8e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b97:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba9:	e8 10 f5 ff ff       	call   8010be <fd2num>
  801bae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bb3:	83 c4 04             	add    $0x4,%esp
  801bb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb9:	e8 00 f5 ff ff       	call   8010be <fd2num>
  801bbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcc:	eb 30                	jmp    801bfe <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	56                   	push   %esi
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 ff ef ff ff       	call   800bd8 <sys_page_unmap>
  801bd9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	ff 75 f0             	pushl  -0x10(%ebp)
  801be2:	6a 00                	push   $0x0
  801be4:	e8 ef ef ff ff       	call   800bd8 <sys_page_unmap>
  801be9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bec:	83 ec 08             	sub    $0x8,%esp
  801bef:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf2:	6a 00                	push   $0x0
  801bf4:	e8 df ef ff ff       	call   800bd8 <sys_page_unmap>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bfe:	89 d0                	mov    %edx,%eax
  801c00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c10:	50                   	push   %eax
  801c11:	ff 75 08             	pushl  0x8(%ebp)
  801c14:	e8 1b f5 ff ff       	call   801134 <fd_lookup>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 18                	js     801c38 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c20:	83 ec 0c             	sub    $0xc,%esp
  801c23:	ff 75 f4             	pushl  -0xc(%ebp)
  801c26:	e8 a3 f4 ff ff       	call   8010ce <fd2data>
	return _pipeisclosed(fd, p);
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c30:	e8 18 fd ff ff       	call   80194d <_pipeisclosed>
  801c35:	83 c4 10             	add    $0x10,%esp
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c4a:	68 a6 27 80 00       	push   $0x8027a6
  801c4f:	ff 75 0c             	pushl  0xc(%ebp)
  801c52:	e8 f9 ea ff ff       	call   800750 <strcpy>
	return 0;
}
  801c57:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c75:	eb 2d                	jmp    801ca4 <devcons_write+0x46>
		m = n - tot;
  801c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c7a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c7c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c7f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c84:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c87:	83 ec 04             	sub    $0x4,%esp
  801c8a:	53                   	push   %ebx
  801c8b:	03 45 0c             	add    0xc(%ebp),%eax
  801c8e:	50                   	push   %eax
  801c8f:	57                   	push   %edi
  801c90:	e8 4d ec ff ff       	call   8008e2 <memmove>
		sys_cputs(buf, m);
  801c95:	83 c4 08             	add    $0x8,%esp
  801c98:	53                   	push   %ebx
  801c99:	57                   	push   %edi
  801c9a:	e8 f8 ed ff ff       	call   800a97 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9f:	01 de                	add    %ebx,%esi
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	89 f0                	mov    %esi,%eax
  801ca6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca9:	72 cc                	jb     801c77 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cae:	5b                   	pop    %ebx
  801caf:	5e                   	pop    %esi
  801cb0:	5f                   	pop    %edi
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 08             	sub    $0x8,%esp
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cc2:	74 2a                	je     801cee <devcons_read+0x3b>
  801cc4:	eb 05                	jmp    801ccb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc6:	e8 69 ee ff ff       	call   800b34 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ccb:	e8 e5 ed ff ff       	call   800ab5 <sys_cgetc>
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	74 f2                	je     801cc6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 16                	js     801cee <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd8:	83 f8 04             	cmp    $0x4,%eax
  801cdb:	74 0c                	je     801ce9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce0:	88 02                	mov    %al,(%edx)
	return 1;
  801ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce7:	eb 05                	jmp    801cee <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cfc:	6a 01                	push   $0x1
  801cfe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d01:	50                   	push   %eax
  801d02:	e8 90 ed ff ff       	call   800a97 <sys_cputs>
}
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <getchar>:

int
getchar(void)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d12:	6a 01                	push   $0x1
  801d14:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	6a 00                	push   $0x0
  801d1a:	e8 7e f6 ff ff       	call   80139d <read>
	if (r < 0)
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 0f                	js     801d35 <getchar+0x29>
		return r;
	if (r < 1)
  801d26:	85 c0                	test   %eax,%eax
  801d28:	7e 06                	jle    801d30 <getchar+0x24>
		return -E_EOF;
	return c;
  801d2a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d2e:	eb 05                	jmp    801d35 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d30:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d40:	50                   	push   %eax
  801d41:	ff 75 08             	pushl  0x8(%ebp)
  801d44:	e8 eb f3 ff ff       	call   801134 <fd_lookup>
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 11                	js     801d61 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d53:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d59:	39 10                	cmp    %edx,(%eax)
  801d5b:	0f 94 c0             	sete   %al
  801d5e:	0f b6 c0             	movzbl %al,%eax
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <opencons>:

int
opencons(void)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6c:	50                   	push   %eax
  801d6d:	e8 73 f3 ff ff       	call   8010e5 <fd_alloc>
  801d72:	83 c4 10             	add    $0x10,%esp
		return r;
  801d75:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 3e                	js     801db9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	68 07 04 00 00       	push   $0x407
  801d83:	ff 75 f4             	pushl  -0xc(%ebp)
  801d86:	6a 00                	push   $0x0
  801d88:	e8 c6 ed ff ff       	call   800b53 <sys_page_alloc>
  801d8d:	83 c4 10             	add    $0x10,%esp
		return r;
  801d90:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 23                	js     801db9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d96:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dab:	83 ec 0c             	sub    $0xc,%esp
  801dae:	50                   	push   %eax
  801daf:	e8 0a f3 ff ff       	call   8010be <fd2num>
  801db4:	89 c2                	mov    %eax,%edx
  801db6:	83 c4 10             	add    $0x10,%esp
}
  801db9:	89 d0                	mov    %edx,%eax
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	56                   	push   %esi
  801dc1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dc2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dc5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dcb:	e8 45 ed ff ff       	call   800b15 <sys_getenvid>
  801dd0:	83 ec 0c             	sub    $0xc,%esp
  801dd3:	ff 75 0c             	pushl  0xc(%ebp)
  801dd6:	ff 75 08             	pushl  0x8(%ebp)
  801dd9:	56                   	push   %esi
  801dda:	50                   	push   %eax
  801ddb:	68 b4 27 80 00       	push   $0x8027b4
  801de0:	e8 e6 e3 ff ff       	call   8001cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de5:	83 c4 18             	add    $0x18,%esp
  801de8:	53                   	push   %ebx
  801de9:	ff 75 10             	pushl  0x10(%ebp)
  801dec:	e8 89 e3 ff ff       	call   80017a <vcprintf>
	cprintf("\n");
  801df1:	c7 04 24 14 23 80 00 	movl   $0x802314,(%esp)
  801df8:	e8 ce e3 ff ff       	call   8001cb <cprintf>
  801dfd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e00:	cc                   	int3   
  801e01:	eb fd                	jmp    801e00 <_panic+0x43>

00801e03 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e09:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e10:	75 2a                	jne    801e3c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e12:	83 ec 04             	sub    $0x4,%esp
  801e15:	6a 07                	push   $0x7
  801e17:	68 00 f0 bf ee       	push   $0xeebff000
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 30 ed ff ff       	call   800b53 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	85 c0                	test   %eax,%eax
  801e28:	79 12                	jns    801e3c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e2a:	50                   	push   %eax
  801e2b:	68 d8 27 80 00       	push   $0x8027d8
  801e30:	6a 23                	push   $0x23
  801e32:	68 dc 27 80 00       	push   $0x8027dc
  801e37:	e8 81 ff ff ff       	call   801dbd <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	68 6e 1e 80 00       	push   $0x801e6e
  801e4c:	6a 00                	push   $0x0
  801e4e:	e8 4b ee ff ff       	call   800c9e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	85 c0                	test   %eax,%eax
  801e58:	79 12                	jns    801e6c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e5a:	50                   	push   %eax
  801e5b:	68 d8 27 80 00       	push   $0x8027d8
  801e60:	6a 2c                	push   $0x2c
  801e62:	68 dc 27 80 00       	push   $0x8027dc
  801e67:	e8 51 ff ff ff       	call   801dbd <_panic>
	}
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e6e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e6f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e74:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e76:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e79:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e7d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e82:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e86:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e88:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e8b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e8c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e8f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e90:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e91:	c3                   	ret    

00801e92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	75 12                	jne    801eb6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ea4:	83 ec 0c             	sub    $0xc,%esp
  801ea7:	68 00 00 c0 ee       	push   $0xeec00000
  801eac:	e8 52 ee ff ff       	call   800d03 <sys_ipc_recv>
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	eb 0c                	jmp    801ec2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	50                   	push   %eax
  801eba:	e8 44 ee ff ff       	call   800d03 <sys_ipc_recv>
  801ebf:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ec2:	85 f6                	test   %esi,%esi
  801ec4:	0f 95 c1             	setne  %cl
  801ec7:	85 db                	test   %ebx,%ebx
  801ec9:	0f 95 c2             	setne  %dl
  801ecc:	84 d1                	test   %dl,%cl
  801ece:	74 09                	je     801ed9 <ipc_recv+0x47>
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	c1 ea 1f             	shr    $0x1f,%edx
  801ed5:	84 d2                	test   %dl,%dl
  801ed7:	75 2d                	jne    801f06 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ed9:	85 f6                	test   %esi,%esi
  801edb:	74 0d                	je     801eea <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801edd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee2:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801ee8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801eea:	85 db                	test   %ebx,%ebx
  801eec:	74 0d                	je     801efb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801eee:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef3:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801ef9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801efb:	a1 04 40 80 00       	mov    0x804004,%eax
  801f00:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801f06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	57                   	push   %edi
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f1f:	85 db                	test   %ebx,%ebx
  801f21:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f26:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f29:	ff 75 14             	pushl  0x14(%ebp)
  801f2c:	53                   	push   %ebx
  801f2d:	56                   	push   %esi
  801f2e:	57                   	push   %edi
  801f2f:	e8 ac ed ff ff       	call   800ce0 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f34:	89 c2                	mov    %eax,%edx
  801f36:	c1 ea 1f             	shr    $0x1f,%edx
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	84 d2                	test   %dl,%dl
  801f3e:	74 17                	je     801f57 <ipc_send+0x4a>
  801f40:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f43:	74 12                	je     801f57 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f45:	50                   	push   %eax
  801f46:	68 ea 27 80 00       	push   $0x8027ea
  801f4b:	6a 47                	push   $0x47
  801f4d:	68 f8 27 80 00       	push   $0x8027f8
  801f52:	e8 66 fe ff ff       	call   801dbd <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5a:	75 07                	jne    801f63 <ipc_send+0x56>
			sys_yield();
  801f5c:	e8 d3 eb ff ff       	call   800b34 <sys_yield>
  801f61:	eb c6                	jmp    801f29 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f63:	85 c0                	test   %eax,%eax
  801f65:	75 c2                	jne    801f29 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7a:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f80:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f86:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f8c:	39 ca                	cmp    %ecx,%edx
  801f8e:	75 13                	jne    801fa3 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f90:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801fa1:	eb 0f                	jmp    801fb2 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa3:	83 c0 01             	add    $0x1,%eax
  801fa6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fab:	75 cd                	jne    801f7a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    

00801fb4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fba:	89 d0                	mov    %edx,%eax
  801fbc:	c1 e8 16             	shr    $0x16,%eax
  801fbf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcb:	f6 c1 01             	test   $0x1,%cl
  801fce:	74 1d                	je     801fed <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fd0:	c1 ea 0c             	shr    $0xc,%edx
  801fd3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fda:	f6 c2 01             	test   $0x1,%dl
  801fdd:	74 0e                	je     801fed <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdf:	c1 ea 0c             	shr    $0xc,%edx
  801fe2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe9:	ef 
  801fea:	0f b7 c0             	movzwl %ax,%eax
}
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
