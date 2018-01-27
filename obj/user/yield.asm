
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
  80003f:	8b 40 7c             	mov    0x7c(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 22 80 00       	push   $0x802220
  800048:	e8 63 01 00 00       	call   8001b0 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 bf 0a 00 00       	call   800b19 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 7c             	mov    0x7c(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 22 80 00       	push   $0x802240
  80006c:	e8 3f 01 00 00       	call   8001b0 <cprintf>
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
  800081:	8b 40 7c             	mov    0x7c(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 22 80 00       	push   $0x80226c
  80008d:	e8 1e 01 00 00       	call   8001b0 <cprintf>
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
  8000a5:	e8 50 0a 00 00       	call   800afa <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8000b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ba:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bf:	85 db                	test   %ebx,%ebx
  8000c1:	7e 07                	jle    8000ca <libmain+0x30>
		binaryname = argv[0];
  8000c3:	8b 06                	mov    (%esi),%eax
  8000c5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ca:	83 ec 08             	sub    $0x8,%esp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	e8 5f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 2a 00 00 00       	call   800103 <exit>
}
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000e9:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000ee:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000f0:	e8 05 0a 00 00       	call   800afa <sys_getenvid>
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	e8 4b 0c 00 00       	call   800d49 <sys_thread_free>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800109:	e8 1a 11 00 00       	call   801228 <close_all>
	sys_env_destroy(0);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	6a 00                	push   $0x0
  800113:	e8 a1 09 00 00       	call   800ab9 <sys_env_destroy>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	53                   	push   %ebx
  800121:	83 ec 04             	sub    $0x4,%esp
  800124:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800127:	8b 13                	mov    (%ebx),%edx
  800129:	8d 42 01             	lea    0x1(%edx),%eax
  80012c:	89 03                	mov    %eax,(%ebx)
  80012e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800131:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800135:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013a:	75 1a                	jne    800156 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013c:	83 ec 08             	sub    $0x8,%esp
  80013f:	68 ff 00 00 00       	push   $0xff
  800144:	8d 43 08             	lea    0x8(%ebx),%eax
  800147:	50                   	push   %eax
  800148:	e8 2f 09 00 00       	call   800a7c <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800153:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800156:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	ff 75 0c             	pushl  0xc(%ebp)
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	68 1d 01 80 00       	push   $0x80011d
  80018e:	e8 54 01 00 00       	call   8002e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800193:	83 c4 08             	add    $0x8,%esp
  800196:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 d4 08 00 00       	call   800a7c <sys_cputs>

	return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	50                   	push   %eax
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	e8 9d ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 1c             	sub    $0x1c,%esp
  8001cd:	89 c7                	mov    %eax,%edi
  8001cf:	89 d6                	mov    %edx,%esi
  8001d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001da:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001eb:	39 d3                	cmp    %edx,%ebx
  8001ed:	72 05                	jb     8001f4 <printnum+0x30>
  8001ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f2:	77 45                	ja     800239 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f4:	83 ec 0c             	sub    $0xc,%esp
  8001f7:	ff 75 18             	pushl  0x18(%ebp)
  8001fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800200:	53                   	push   %ebx
  800201:	ff 75 10             	pushl  0x10(%ebp)
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020a:	ff 75 e0             	pushl  -0x20(%ebp)
  80020d:	ff 75 dc             	pushl  -0x24(%ebp)
  800210:	ff 75 d8             	pushl  -0x28(%ebp)
  800213:	e8 68 1d 00 00       	call   801f80 <__udivdi3>
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	52                   	push   %edx
  80021c:	50                   	push   %eax
  80021d:	89 f2                	mov    %esi,%edx
  80021f:	89 f8                	mov    %edi,%eax
  800221:	e8 9e ff ff ff       	call   8001c4 <printnum>
  800226:	83 c4 20             	add    $0x20,%esp
  800229:	eb 18                	jmp    800243 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022b:	83 ec 08             	sub    $0x8,%esp
  80022e:	56                   	push   %esi
  80022f:	ff 75 18             	pushl  0x18(%ebp)
  800232:	ff d7                	call   *%edi
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	eb 03                	jmp    80023c <printnum+0x78>
  800239:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023c:	83 eb 01             	sub    $0x1,%ebx
  80023f:	85 db                	test   %ebx,%ebx
  800241:	7f e8                	jg     80022b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	56                   	push   %esi
  800247:	83 ec 04             	sub    $0x4,%esp
  80024a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024d:	ff 75 e0             	pushl  -0x20(%ebp)
  800250:	ff 75 dc             	pushl  -0x24(%ebp)
  800253:	ff 75 d8             	pushl  -0x28(%ebp)
  800256:	e8 55 1e 00 00       	call   8020b0 <__umoddi3>
  80025b:	83 c4 14             	add    $0x14,%esp
  80025e:	0f be 80 95 22 80 00 	movsbl 0x802295(%eax),%eax
  800265:	50                   	push   %eax
  800266:	ff d7                	call   *%edi
}
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800276:	83 fa 01             	cmp    $0x1,%edx
  800279:	7e 0e                	jle    800289 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800280:	89 08                	mov    %ecx,(%eax)
  800282:	8b 02                	mov    (%edx),%eax
  800284:	8b 52 04             	mov    0x4(%edx),%edx
  800287:	eb 22                	jmp    8002ab <getuint+0x38>
	else if (lflag)
  800289:	85 d2                	test   %edx,%edx
  80028b:	74 10                	je     80029d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
  80029b:	eb 0e                	jmp    8002ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	88 02                	mov    %al,(%edx)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 10             	pushl  0x10(%ebp)
  8002d7:	ff 75 0c             	pushl  0xc(%ebp)
  8002da:	ff 75 08             	pushl  0x8(%ebp)
  8002dd:	e8 05 00 00 00       	call   8002e7 <vprintfmt>
	va_end(ap);
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 2c             	sub    $0x2c,%esp
  8002f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f9:	eb 12                	jmp    80030d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fb:	85 c0                	test   %eax,%eax
  8002fd:	0f 84 89 03 00 00    	je     80068c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	53                   	push   %ebx
  800307:	50                   	push   %eax
  800308:	ff d6                	call   *%esi
  80030a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030d:	83 c7 01             	add    $0x1,%edi
  800310:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800314:	83 f8 25             	cmp    $0x25,%eax
  800317:	75 e2                	jne    8002fb <vprintfmt+0x14>
  800319:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800324:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
  800337:	eb 07                	jmp    800340 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8d 47 01             	lea    0x1(%edi),%eax
  800343:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800346:	0f b6 07             	movzbl (%edi),%eax
  800349:	0f b6 c8             	movzbl %al,%ecx
  80034c:	83 e8 23             	sub    $0x23,%eax
  80034f:	3c 55                	cmp    $0x55,%al
  800351:	0f 87 1a 03 00 00    	ja     800671 <vprintfmt+0x38a>
  800357:	0f b6 c0             	movzbl %al,%eax
  80035a:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800364:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800368:	eb d6                	jmp    800340 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	b8 00 00 00 00       	mov    $0x0,%eax
  800372:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800375:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800378:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800382:	83 fa 09             	cmp    $0x9,%edx
  800385:	77 39                	ja     8003c0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800387:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038a:	eb e9                	jmp    800375 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 48 04             	lea    0x4(%eax),%ecx
  800392:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800395:	8b 00                	mov    (%eax),%eax
  800397:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039d:	eb 27                	jmp    8003c6 <vprintfmt+0xdf>
  80039f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a2:	85 c0                	test   %eax,%eax
  8003a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a9:	0f 49 c8             	cmovns %eax,%ecx
  8003ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b2:	eb 8c                	jmp    800340 <vprintfmt+0x59>
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003be:	eb 80                	jmp    800340 <vprintfmt+0x59>
  8003c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ca:	0f 89 70 ff ff ff    	jns    800340 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003dd:	e9 5e ff ff ff       	jmp    800340 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e8:	e9 53 ff ff ff       	jmp    800340 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	53                   	push   %ebx
  8003fa:	ff 30                	pushl  (%eax)
  8003fc:	ff d6                	call   *%esi
			break;
  8003fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800404:	e9 04 ff ff ff       	jmp    80030d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	99                   	cltd   
  800415:	31 d0                	xor    %edx,%eax
  800417:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800419:	83 f8 0f             	cmp    $0xf,%eax
  80041c:	7f 0b                	jg     800429 <vprintfmt+0x142>
  80041e:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	75 18                	jne    800441 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800429:	50                   	push   %eax
  80042a:	68 ad 22 80 00       	push   $0x8022ad
  80042f:	53                   	push   %ebx
  800430:	56                   	push   %esi
  800431:	e8 94 fe ff ff       	call   8002ca <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043c:	e9 cc fe ff ff       	jmp    80030d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 ed 26 80 00       	push   $0x8026ed
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 7c fe ff ff       	call   8002ca <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800454:	e9 b4 fe ff ff       	jmp    80030d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800464:	85 ff                	test   %edi,%edi
  800466:	b8 a6 22 80 00       	mov    $0x8022a6,%eax
  80046b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	0f 8e 94 00 00 00    	jle    80050c <vprintfmt+0x225>
  800478:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047c:	0f 84 98 00 00 00    	je     80051a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	ff 75 d0             	pushl  -0x30(%ebp)
  800488:	57                   	push   %edi
  800489:	e8 86 02 00 00       	call   800714 <strnlen>
  80048e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800491:	29 c1                	sub    %eax,%ecx
  800493:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800499:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	eb 0f                	jmp    8004b6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	53                   	push   %ebx
  8004ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	83 ef 01             	sub    $0x1,%edi
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 ff                	test   %edi,%edi
  8004b8:	7f ed                	jg     8004a7 <vprintfmt+0x1c0>
  8004ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c0:	85 c9                	test   %ecx,%ecx
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	0f 49 c1             	cmovns %ecx,%eax
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d5:	89 cb                	mov    %ecx,%ebx
  8004d7:	eb 4d                	jmp    800526 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dd:	74 1b                	je     8004fa <vprintfmt+0x213>
  8004df:	0f be c0             	movsbl %al,%eax
  8004e2:	83 e8 20             	sub    $0x20,%eax
  8004e5:	83 f8 5e             	cmp    $0x5e,%eax
  8004e8:	76 10                	jbe    8004fa <vprintfmt+0x213>
					putch('?', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	6a 3f                	push   $0x3f
  8004f2:	ff 55 08             	call   *0x8(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 0d                	jmp    800507 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	52                   	push   %edx
  800501:	ff 55 08             	call   *0x8(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800507:	83 eb 01             	sub    $0x1,%ebx
  80050a:	eb 1a                	jmp    800526 <vprintfmt+0x23f>
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800518:	eb 0c                	jmp    800526 <vprintfmt+0x23f>
  80051a:	89 75 08             	mov    %esi,0x8(%ebp)
  80051d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800520:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800523:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800526:	83 c7 01             	add    $0x1,%edi
  800529:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052d:	0f be d0             	movsbl %al,%edx
  800530:	85 d2                	test   %edx,%edx
  800532:	74 23                	je     800557 <vprintfmt+0x270>
  800534:	85 f6                	test   %esi,%esi
  800536:	78 a1                	js     8004d9 <vprintfmt+0x1f2>
  800538:	83 ee 01             	sub    $0x1,%esi
  80053b:	79 9c                	jns    8004d9 <vprintfmt+0x1f2>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	eb 18                	jmp    80055f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	53                   	push   %ebx
  80054b:	6a 20                	push   $0x20
  80054d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054f:	83 ef 01             	sub    $0x1,%edi
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	eb 08                	jmp    80055f <vprintfmt+0x278>
  800557:	89 df                	mov    %ebx,%edi
  800559:	8b 75 08             	mov    0x8(%ebp),%esi
  80055c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055f:	85 ff                	test   %edi,%edi
  800561:	7f e4                	jg     800547 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800566:	e9 a2 fd ff ff       	jmp    80030d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056b:	83 fa 01             	cmp    $0x1,%edx
  80056e:	7e 16                	jle    800586 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 08             	lea    0x8(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 50 04             	mov    0x4(%eax),%edx
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	eb 32                	jmp    8005b8 <vprintfmt+0x2d1>
	else if (lflag)
  800586:	85 d2                	test   %edx,%edx
  800588:	74 18                	je     8005a2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800598:	89 c1                	mov    %eax,%ecx
  80059a:	c1 f9 1f             	sar    $0x1f,%ecx
  80059d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a0:	eb 16                	jmp    8005b8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 c1                	mov    %eax,%ecx
  8005b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c7:	79 74                	jns    80063d <vprintfmt+0x356>
				putch('-', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 2d                	push   $0x2d
  8005cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d7:	f7 d8                	neg    %eax
  8005d9:	83 d2 00             	adc    $0x0,%edx
  8005dc:	f7 da                	neg    %edx
  8005de:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e6:	eb 55                	jmp    80063d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	e8 83 fc ff ff       	call   800273 <getuint>
			base = 10;
  8005f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f5:	eb 46                	jmp    80063d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 74 fc ff ff       	call   800273 <getuint>
			base = 8;
  8005ff:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800604:	eb 37                	jmp    80063d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 30                	push   $0x30
  80060c:	ff d6                	call   *%esi
			putch('x', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 78                	push   $0x78
  800614:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800626:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800629:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062e:	eb 0d                	jmp    80063d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 3b fc ff ff       	call   800273 <getuint>
			base = 16;
  800638:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800644:	57                   	push   %edi
  800645:	ff 75 e0             	pushl  -0x20(%ebp)
  800648:	51                   	push   %ecx
  800649:	52                   	push   %edx
  80064a:	50                   	push   %eax
  80064b:	89 da                	mov    %ebx,%edx
  80064d:	89 f0                	mov    %esi,%eax
  80064f:	e8 70 fb ff ff       	call   8001c4 <printnum>
			break;
  800654:	83 c4 20             	add    $0x20,%esp
  800657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065a:	e9 ae fc ff ff       	jmp    80030d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	51                   	push   %ecx
  800664:	ff d6                	call   *%esi
			break;
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066c:	e9 9c fc ff ff       	jmp    80030d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 25                	push   $0x25
  800677:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 03                	jmp    800681 <vprintfmt+0x39a>
  80067e:	83 ef 01             	sub    $0x1,%edi
  800681:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800685:	75 f7                	jne    80067e <vprintfmt+0x397>
  800687:	e9 81 fc ff ff       	jmp    80030d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068f:	5b                   	pop    %ebx
  800690:	5e                   	pop    %esi
  800691:	5f                   	pop    %edi
  800692:	5d                   	pop    %ebp
  800693:	c3                   	ret    

00800694 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 18             	sub    $0x18,%esp
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	74 26                	je     8006db <vsnprintf+0x47>
  8006b5:	85 d2                	test   %edx,%edx
  8006b7:	7e 22                	jle    8006db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b9:	ff 75 14             	pushl  0x14(%ebp)
  8006bc:	ff 75 10             	pushl  0x10(%ebp)
  8006bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	68 ad 02 80 00       	push   $0x8002ad
  8006c8:	e8 1a fc ff ff       	call   8002e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 05                	jmp    8006e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006eb:	50                   	push   %eax
  8006ec:	ff 75 10             	pushl  0x10(%ebp)
  8006ef:	ff 75 0c             	pushl  0xc(%ebp)
  8006f2:	ff 75 08             	pushl  0x8(%ebp)
  8006f5:	e8 9a ff ff ff       	call   800694 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	eb 03                	jmp    80070c <strlen+0x10>
		n++;
  800709:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800710:	75 f7                	jne    800709 <strlen+0xd>
		n++;
	return n;
}
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	eb 03                	jmp    800727 <strnlen+0x13>
		n++;
  800724:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	39 c2                	cmp    %eax,%edx
  800729:	74 08                	je     800733 <strnlen+0x1f>
  80072b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80072f:	75 f3                	jne    800724 <strnlen+0x10>
  800731:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	53                   	push   %ebx
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073f:	89 c2                	mov    %eax,%edx
  800741:	83 c2 01             	add    $0x1,%edx
  800744:	83 c1 01             	add    $0x1,%ecx
  800747:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074e:	84 db                	test   %bl,%bl
  800750:	75 ef                	jne    800741 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800752:	5b                   	pop    %ebx
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	53                   	push   %ebx
  800759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075c:	53                   	push   %ebx
  80075d:	e8 9a ff ff ff       	call   8006fc <strlen>
  800762:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	01 d8                	add    %ebx,%eax
  80076a:	50                   	push   %eax
  80076b:	e8 c5 ff ff ff       	call   800735 <strcpy>
	return dst;
}
  800770:	89 d8                	mov    %ebx,%eax
  800772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800782:	89 f3                	mov    %esi,%ebx
  800784:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	89 f2                	mov    %esi,%edx
  800789:	eb 0f                	jmp    80079a <strncpy+0x23>
		*dst++ = *src;
  80078b:	83 c2 01             	add    $0x1,%edx
  80078e:	0f b6 01             	movzbl (%ecx),%eax
  800791:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800794:	80 39 01             	cmpb   $0x1,(%ecx)
  800797:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079a:	39 da                	cmp    %ebx,%edx
  80079c:	75 ed                	jne    80078b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007af:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	74 21                	je     8007d9 <strlcpy+0x35>
  8007b8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bc:	89 f2                	mov    %esi,%edx
  8007be:	eb 09                	jmp    8007c9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c0:	83 c2 01             	add    $0x1,%edx
  8007c3:	83 c1 01             	add    $0x1,%ecx
  8007c6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c9:	39 c2                	cmp    %eax,%edx
  8007cb:	74 09                	je     8007d6 <strlcpy+0x32>
  8007cd:	0f b6 19             	movzbl (%ecx),%ebx
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ec                	jne    8007c0 <strlcpy+0x1c>
  8007d4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d9:	29 f0                	sub    %esi,%eax
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e8:	eb 06                	jmp    8007f0 <strcmp+0x11>
		p++, q++;
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	84 c0                	test   %al,%al
  8007f5:	74 04                	je     8007fb <strcmp+0x1c>
  8007f7:	3a 02                	cmp    (%edx),%al
  8007f9:	74 ef                	je     8007ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fb:	0f b6 c0             	movzbl %al,%eax
  8007fe:	0f b6 12             	movzbl (%edx),%edx
  800801:	29 d0                	sub    %edx,%eax
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080f:	89 c3                	mov    %eax,%ebx
  800811:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800814:	eb 06                	jmp    80081c <strncmp+0x17>
		n--, p++, q++;
  800816:	83 c0 01             	add    $0x1,%eax
  800819:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081c:	39 d8                	cmp    %ebx,%eax
  80081e:	74 15                	je     800835 <strncmp+0x30>
  800820:	0f b6 08             	movzbl (%eax),%ecx
  800823:	84 c9                	test   %cl,%cl
  800825:	74 04                	je     80082b <strncmp+0x26>
  800827:	3a 0a                	cmp    (%edx),%cl
  800829:	74 eb                	je     800816 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f b6 12             	movzbl (%edx),%edx
  800831:	29 d0                	sub    %edx,%eax
  800833:	eb 05                	jmp    80083a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800847:	eb 07                	jmp    800850 <strchr+0x13>
		if (*s == c)
  800849:	38 ca                	cmp    %cl,%dl
  80084b:	74 0f                	je     80085c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
  800853:	84 d2                	test   %dl,%dl
  800855:	75 f2                	jne    800849 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800868:	eb 03                	jmp    80086d <strfind+0xf>
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 04                	je     800878 <strfind+0x1a>
  800874:	84 d2                	test   %dl,%dl
  800876:	75 f2                	jne    80086a <strfind+0xc>
			break;
	return (char *) s;
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	57                   	push   %edi
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 7d 08             	mov    0x8(%ebp),%edi
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800886:	85 c9                	test   %ecx,%ecx
  800888:	74 36                	je     8008c0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800890:	75 28                	jne    8008ba <memset+0x40>
  800892:	f6 c1 03             	test   $0x3,%cl
  800895:	75 23                	jne    8008ba <memset+0x40>
		c &= 0xFF;
  800897:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089b:	89 d3                	mov    %edx,%ebx
  80089d:	c1 e3 08             	shl    $0x8,%ebx
  8008a0:	89 d6                	mov    %edx,%esi
  8008a2:	c1 e6 18             	shl    $0x18,%esi
  8008a5:	89 d0                	mov    %edx,%eax
  8008a7:	c1 e0 10             	shl    $0x10,%eax
  8008aa:	09 f0                	or     %esi,%eax
  8008ac:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ae:	89 d8                	mov    %ebx,%eax
  8008b0:	09 d0                	or     %edx,%eax
  8008b2:	c1 e9 02             	shr    $0x2,%ecx
  8008b5:	fc                   	cld    
  8008b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b8:	eb 06                	jmp    8008c0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bd:	fc                   	cld    
  8008be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c0:	89 f8                	mov    %edi,%eax
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d5:	39 c6                	cmp    %eax,%esi
  8008d7:	73 35                	jae    80090e <memmove+0x47>
  8008d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dc:	39 d0                	cmp    %edx,%eax
  8008de:	73 2e                	jae    80090e <memmove+0x47>
		s += n;
		d += n;
  8008e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e3:	89 d6                	mov    %edx,%esi
  8008e5:	09 fe                	or     %edi,%esi
  8008e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ed:	75 13                	jne    800902 <memmove+0x3b>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 0e                	jne    800902 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f4:	83 ef 04             	sub    $0x4,%edi
  8008f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
  8008fd:	fd                   	std    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 09                	jmp    80090b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800902:	83 ef 01             	sub    $0x1,%edi
  800905:	8d 72 ff             	lea    -0x1(%edx),%esi
  800908:	fd                   	std    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090b:	fc                   	cld    
  80090c:	eb 1d                	jmp    80092b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090e:	89 f2                	mov    %esi,%edx
  800910:	09 c2                	or     %eax,%edx
  800912:	f6 c2 03             	test   $0x3,%dl
  800915:	75 0f                	jne    800926 <memmove+0x5f>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 0a                	jne    800926 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091c:	c1 e9 02             	shr    $0x2,%ecx
  80091f:	89 c7                	mov    %eax,%edi
  800921:	fc                   	cld    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 05                	jmp    80092b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800932:	ff 75 10             	pushl  0x10(%ebp)
  800935:	ff 75 0c             	pushl  0xc(%ebp)
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 87 ff ff ff       	call   8008c7 <memmove>
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	89 c6                	mov    %eax,%esi
  80094f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	eb 1a                	jmp    80096e <memcmp+0x2c>
		if (*s1 != *s2)
  800954:	0f b6 08             	movzbl (%eax),%ecx
  800957:	0f b6 1a             	movzbl (%edx),%ebx
  80095a:	38 d9                	cmp    %bl,%cl
  80095c:	74 0a                	je     800968 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095e:	0f b6 c1             	movzbl %cl,%eax
  800961:	0f b6 db             	movzbl %bl,%ebx
  800964:	29 d8                	sub    %ebx,%eax
  800966:	eb 0f                	jmp    800977 <memcmp+0x35>
		s1++, s2++;
  800968:	83 c0 01             	add    $0x1,%eax
  80096b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	39 f0                	cmp    %esi,%eax
  800970:	75 e2                	jne    800954 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800982:	89 c1                	mov    %eax,%ecx
  800984:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800987:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098b:	eb 0a                	jmp    800997 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	39 da                	cmp    %ebx,%edx
  800992:	74 07                	je     80099b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800994:	83 c0 01             	add    $0x1,%eax
  800997:	39 c8                	cmp    %ecx,%eax
  800999:	72 f2                	jb     80098d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099b:	5b                   	pop    %ebx
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009aa:	eb 03                	jmp    8009af <strtol+0x11>
		s++;
  8009ac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009af:	0f b6 01             	movzbl (%ecx),%eax
  8009b2:	3c 20                	cmp    $0x20,%al
  8009b4:	74 f6                	je     8009ac <strtol+0xe>
  8009b6:	3c 09                	cmp    $0x9,%al
  8009b8:	74 f2                	je     8009ac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ba:	3c 2b                	cmp    $0x2b,%al
  8009bc:	75 0a                	jne    8009c8 <strtol+0x2a>
		s++;
  8009be:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c6:	eb 11                	jmp    8009d9 <strtol+0x3b>
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cd:	3c 2d                	cmp    $0x2d,%al
  8009cf:	75 08                	jne    8009d9 <strtol+0x3b>
		s++, neg = 1;
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009df:	75 15                	jne    8009f6 <strtol+0x58>
  8009e1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e4:	75 10                	jne    8009f6 <strtol+0x58>
  8009e6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ea:	75 7c                	jne    800a68 <strtol+0xca>
		s += 2, base = 16;
  8009ec:	83 c1 02             	add    $0x2,%ecx
  8009ef:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f4:	eb 16                	jmp    800a0c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f6:	85 db                	test   %ebx,%ebx
  8009f8:	75 12                	jne    800a0c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ff:	80 39 30             	cmpb   $0x30,(%ecx)
  800a02:	75 08                	jne    800a0c <strtol+0x6e>
		s++, base = 8;
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a14:	0f b6 11             	movzbl (%ecx),%edx
  800a17:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	80 fb 09             	cmp    $0x9,%bl
  800a1f:	77 08                	ja     800a29 <strtol+0x8b>
			dig = *s - '0';
  800a21:	0f be d2             	movsbl %dl,%edx
  800a24:	83 ea 30             	sub    $0x30,%edx
  800a27:	eb 22                	jmp    800a4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2c:	89 f3                	mov    %esi,%ebx
  800a2e:	80 fb 19             	cmp    $0x19,%bl
  800a31:	77 08                	ja     800a3b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a33:	0f be d2             	movsbl %dl,%edx
  800a36:	83 ea 57             	sub    $0x57,%edx
  800a39:	eb 10                	jmp    800a4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	80 fb 19             	cmp    $0x19,%bl
  800a43:	77 16                	ja     800a5b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a45:	0f be d2             	movsbl %dl,%edx
  800a48:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4e:	7d 0b                	jge    800a5b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a59:	eb b9                	jmp    800a14 <strtol+0x76>

	if (endptr)
  800a5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5f:	74 0d                	je     800a6e <strtol+0xd0>
		*endptr = (char *) s;
  800a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a64:	89 0e                	mov    %ecx,(%esi)
  800a66:	eb 06                	jmp    800a6e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a68:	85 db                	test   %ebx,%ebx
  800a6a:	74 98                	je     800a04 <strtol+0x66>
  800a6c:	eb 9e                	jmp    800a0c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6e:	89 c2                	mov    %eax,%edx
  800a70:	f7 da                	neg    %edx
  800a72:	85 ff                	test   %edi,%edi
  800a74:	0f 45 c2             	cmovne %edx,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	89 c7                	mov    %eax,%edi
  800a91:	89 c6                	mov    %eax,%esi
  800a93:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aaa:	89 d1                	mov    %edx,%ecx
  800aac:	89 d3                	mov    %edx,%ebx
  800aae:	89 d7                	mov    %edx,%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac7:	b8 03 00 00 00       	mov    $0x3,%eax
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 cb                	mov    %ecx,%ebx
  800ad1:	89 cf                	mov    %ecx,%edi
  800ad3:	89 ce                	mov    %ecx,%esi
  800ad5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	7e 17                	jle    800af2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	50                   	push   %eax
  800adf:	6a 03                	push   $0x3
  800ae1:	68 9f 25 80 00       	push   $0x80259f
  800ae6:	6a 23                	push   $0x23
  800ae8:	68 bc 25 80 00       	push   $0x8025bc
  800aed:	e8 5e 12 00 00       	call   801d50 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_yield>:

void
sys_yield(void)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b29:	89 d1                	mov    %edx,%ecx
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	89 d7                	mov    %edx,%edi
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	be 00 00 00 00       	mov    $0x0,%esi
  800b46:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b54:	89 f7                	mov    %esi,%edi
  800b56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 04                	push   $0x4
  800b62:	68 9f 25 80 00       	push   $0x80259f
  800b67:	6a 23                	push   $0x23
  800b69:	68 bc 25 80 00       	push   $0x8025bc
  800b6e:	e8 dd 11 00 00       	call   801d50 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	b8 05 00 00 00       	mov    $0x5,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b95:	8b 75 18             	mov    0x18(%ebp),%esi
  800b98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 05                	push   $0x5
  800ba4:	68 9f 25 80 00       	push   $0x80259f
  800ba9:	6a 23                	push   $0x23
  800bab:	68 bc 25 80 00       	push   $0x8025bc
  800bb0:	e8 9b 11 00 00       	call   801d50 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcb:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	89 df                	mov    %ebx,%edi
  800bd8:	89 de                	mov    %ebx,%esi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 06                	push   $0x6
  800be6:	68 9f 25 80 00       	push   $0x80259f
  800beb:	6a 23                	push   $0x23
  800bed:	68 bc 25 80 00       	push   $0x8025bc
  800bf2:	e8 59 11 00 00       	call   801d50 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 08                	push   $0x8
  800c28:	68 9f 25 80 00       	push   $0x80259f
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 bc 25 80 00       	push   $0x8025bc
  800c34:	e8 17 11 00 00       	call   801d50 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 09                	push   $0x9
  800c6a:	68 9f 25 80 00       	push   $0x80259f
  800c6f:	6a 23                	push   $0x23
  800c71:	68 bc 25 80 00       	push   $0x8025bc
  800c76:	e8 d5 10 00 00       	call   801d50 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 0a                	push   $0xa
  800cac:	68 9f 25 80 00       	push   $0x80259f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 bc 25 80 00       	push   $0x8025bc
  800cb8:	e8 93 10 00 00       	call   801d50 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 cb                	mov    %ecx,%ebx
  800d00:	89 cf                	mov    %ecx,%edi
  800d02:	89 ce                	mov    %ecx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 0d                	push   $0xd
  800d10:	68 9f 25 80 00       	push   $0x80259f
  800d15:	6a 23                	push   $0x23
  800d17:	68 bc 25 80 00       	push   $0x8025bc
  800d1c:	e8 2f 10 00 00       	call   801d50 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d54:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 cb                	mov    %ecx,%ebx
  800d5e:	89 cf                	mov    %ecx,%edi
  800d60:	89 ce                	mov    %ecx,%esi
  800d62:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d73:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d75:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d79:	74 11                	je     800d8c <pgfault+0x23>
  800d7b:	89 d8                	mov    %ebx,%eax
  800d7d:	c1 e8 0c             	shr    $0xc,%eax
  800d80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d87:	f6 c4 08             	test   $0x8,%ah
  800d8a:	75 14                	jne    800da0 <pgfault+0x37>
		panic("faulting access");
  800d8c:	83 ec 04             	sub    $0x4,%esp
  800d8f:	68 ca 25 80 00       	push   $0x8025ca
  800d94:	6a 1e                	push   $0x1e
  800d96:	68 da 25 80 00       	push   $0x8025da
  800d9b:	e8 b0 0f 00 00       	call   801d50 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	6a 07                	push   $0x7
  800da5:	68 00 f0 7f 00       	push   $0x7ff000
  800daa:	6a 00                	push   $0x0
  800dac:	e8 87 fd ff ff       	call   800b38 <sys_page_alloc>
	if (r < 0) {
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	79 12                	jns    800dca <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800db8:	50                   	push   %eax
  800db9:	68 e5 25 80 00       	push   $0x8025e5
  800dbe:	6a 2c                	push   $0x2c
  800dc0:	68 da 25 80 00       	push   $0x8025da
  800dc5:	e8 86 0f 00 00       	call   801d50 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	68 00 10 00 00       	push   $0x1000
  800dd8:	53                   	push   %ebx
  800dd9:	68 00 f0 7f 00       	push   $0x7ff000
  800dde:	e8 4c fb ff ff       	call   80092f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800de3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dea:	53                   	push   %ebx
  800deb:	6a 00                	push   $0x0
  800ded:	68 00 f0 7f 00       	push   $0x7ff000
  800df2:	6a 00                	push   $0x0
  800df4:	e8 82 fd ff ff       	call   800b7b <sys_page_map>
	if (r < 0) {
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	79 12                	jns    800e12 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e00:	50                   	push   %eax
  800e01:	68 e5 25 80 00       	push   $0x8025e5
  800e06:	6a 33                	push   $0x33
  800e08:	68 da 25 80 00       	push   $0x8025da
  800e0d:	e8 3e 0f 00 00       	call   801d50 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 9c fd ff ff       	call   800bbd <sys_page_unmap>
	if (r < 0) {
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	79 12                	jns    800e3a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e28:	50                   	push   %eax
  800e29:	68 e5 25 80 00       	push   $0x8025e5
  800e2e:	6a 37                	push   $0x37
  800e30:	68 da 25 80 00       	push   $0x8025da
  800e35:	e8 16 0f 00 00       	call   801d50 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e48:	68 69 0d 80 00       	push   $0x800d69
  800e4d:	e8 44 0f 00 00       	call   801d96 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e52:	b8 07 00 00 00       	mov    $0x7,%eax
  800e57:	cd 30                	int    $0x30
  800e59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 17                	jns    800e7a <fork+0x3b>
		panic("fork fault %e");
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 fe 25 80 00       	push   $0x8025fe
  800e6b:	68 84 00 00 00       	push   $0x84
  800e70:	68 da 25 80 00       	push   $0x8025da
  800e75:	e8 d6 0e 00 00       	call   801d50 <_panic>
  800e7a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e80:	75 24                	jne    800ea6 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e82:	e8 73 fc ff ff       	call   800afa <sys_getenvid>
  800e87:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800e92:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e97:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea1:	e9 64 01 00 00       	jmp    80100a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ea6:	83 ec 04             	sub    $0x4,%esp
  800ea9:	6a 07                	push   $0x7
  800eab:	68 00 f0 bf ee       	push   $0xeebff000
  800eb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eb3:	e8 80 fc ff ff       	call   800b38 <sys_page_alloc>
  800eb8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	c1 e8 16             	shr    $0x16,%eax
  800ec5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ecc:	a8 01                	test   $0x1,%al
  800ece:	0f 84 fc 00 00 00    	je     800fd0 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	c1 e8 0c             	shr    $0xc,%eax
  800ed9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee0:	f6 c2 01             	test   $0x1,%dl
  800ee3:	0f 84 e7 00 00 00    	je     800fd0 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ee9:	89 c6                	mov    %eax,%esi
  800eeb:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef5:	f6 c6 04             	test   $0x4,%dh
  800ef8:	74 39                	je     800f33 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800efa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	25 07 0e 00 00       	and    $0xe07,%eax
  800f09:	50                   	push   %eax
  800f0a:	56                   	push   %esi
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 67 fc ff ff       	call   800b7b <sys_page_map>
		if (r < 0) {
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	0f 89 b1 00 00 00    	jns    800fd0 <fork+0x191>
		    	panic("sys page map fault %e");
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	68 0c 26 80 00       	push   $0x80260c
  800f27:	6a 54                	push   $0x54
  800f29:	68 da 25 80 00       	push   $0x8025da
  800f2e:	e8 1d 0e 00 00       	call   801d50 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3a:	f6 c2 02             	test   $0x2,%dl
  800f3d:	75 0c                	jne    800f4b <fork+0x10c>
  800f3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f46:	f6 c4 08             	test   $0x8,%ah
  800f49:	74 5b                	je     800fa6 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	68 05 08 00 00       	push   $0x805
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	6a 00                	push   $0x0
  800f58:	e8 1e fc ff ff       	call   800b7b <sys_page_map>
		if (r < 0) {
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 14                	jns    800f78 <fork+0x139>
		    	panic("sys page map fault %e");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 0c 26 80 00       	push   $0x80260c
  800f6c:	6a 5b                	push   $0x5b
  800f6e:	68 da 25 80 00       	push   $0x8025da
  800f73:	e8 d8 0d 00 00       	call   801d50 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	68 05 08 00 00       	push   $0x805
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	56                   	push   %esi
  800f84:	6a 00                	push   $0x0
  800f86:	e8 f0 fb ff ff       	call   800b7b <sys_page_map>
		if (r < 0) {
  800f8b:	83 c4 20             	add    $0x20,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	79 3e                	jns    800fd0 <fork+0x191>
		    	panic("sys page map fault %e");
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 0c 26 80 00       	push   $0x80260c
  800f9a:	6a 5f                	push   $0x5f
  800f9c:	68 da 25 80 00       	push   $0x8025da
  800fa1:	e8 aa 0d 00 00       	call   801d50 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	6a 05                	push   $0x5
  800fab:	56                   	push   %esi
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 c6 fb ff ff       	call   800b7b <sys_page_map>
		if (r < 0) {
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 14                	jns    800fd0 <fork+0x191>
		    	panic("sys page map fault %e");
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	68 0c 26 80 00       	push   $0x80260c
  800fc4:	6a 64                	push   $0x64
  800fc6:	68 da 25 80 00       	push   $0x8025da
  800fcb:	e8 80 0d 00 00       	call   801d50 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fdc:	0f 85 de fe ff ff    	jne    800ec0 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fe2:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe7:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	50                   	push   %eax
  800ff1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff4:	57                   	push   %edi
  800ff5:	e8 89 fc ff ff       	call   800c83 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	6a 02                	push   $0x2
  800fff:	57                   	push   %edi
  801000:	e8 fa fb ff ff       	call   800bff <sys_env_set_status>
	
	return envid;
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <sfork>:

envid_t
sfork(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801015:	b8 00 00 00 00       	mov    $0x0,%eax
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801024:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	53                   	push   %ebx
  80102e:	68 24 26 80 00       	push   $0x802624
  801033:	e8 78 f1 ff ff       	call   8001b0 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801038:	c7 04 24 e3 00 80 00 	movl   $0x8000e3,(%esp)
  80103f:	e8 e5 fc ff ff       	call   800d29 <sys_thread_create>
  801044:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801046:	83 c4 08             	add    $0x8,%esp
  801049:	53                   	push   %ebx
  80104a:	68 24 26 80 00       	push   $0x802624
  80104f:	e8 5c f1 ff ff       	call   8001b0 <cprintf>
	return id;
}
  801054:	89 f0                	mov    %esi,%eax
  801056:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801059:	5b                   	pop    %ebx
  80105a:	5e                   	pop    %esi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801060:	8b 45 08             	mov    0x8(%ebp),%eax
  801063:	05 00 00 00 30       	add    $0x30000000,%eax
  801068:	c1 e8 0c             	shr    $0xc,%eax
}
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801070:	8b 45 08             	mov    0x8(%ebp),%eax
  801073:	05 00 00 00 30       	add    $0x30000000,%eax
  801078:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80107d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108f:	89 c2                	mov    %eax,%edx
  801091:	c1 ea 16             	shr    $0x16,%edx
  801094:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109b:	f6 c2 01             	test   $0x1,%dl
  80109e:	74 11                	je     8010b1 <fd_alloc+0x2d>
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	c1 ea 0c             	shr    $0xc,%edx
  8010a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ac:	f6 c2 01             	test   $0x1,%dl
  8010af:	75 09                	jne    8010ba <fd_alloc+0x36>
			*fd_store = fd;
  8010b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b8:	eb 17                	jmp    8010d1 <fd_alloc+0x4d>
  8010ba:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010bf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c4:	75 c9                	jne    80108f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010cc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d9:	83 f8 1f             	cmp    $0x1f,%eax
  8010dc:	77 36                	ja     801114 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010de:	c1 e0 0c             	shl    $0xc,%eax
  8010e1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	c1 ea 16             	shr    $0x16,%edx
  8010eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f2:	f6 c2 01             	test   $0x1,%dl
  8010f5:	74 24                	je     80111b <fd_lookup+0x48>
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	c1 ea 0c             	shr    $0xc,%edx
  8010fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801103:	f6 c2 01             	test   $0x1,%dl
  801106:	74 1a                	je     801122 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801108:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110b:	89 02                	mov    %eax,(%edx)
	return 0;
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
  801112:	eb 13                	jmp    801127 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801114:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801119:	eb 0c                	jmp    801127 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80111b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801120:	eb 05                	jmp    801127 <fd_lookup+0x54>
  801122:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801132:	ba c4 26 80 00       	mov    $0x8026c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801137:	eb 13                	jmp    80114c <dev_lookup+0x23>
  801139:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80113c:	39 08                	cmp    %ecx,(%eax)
  80113e:	75 0c                	jne    80114c <dev_lookup+0x23>
			*dev = devtab[i];
  801140:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801143:	89 01                	mov    %eax,(%ecx)
			return 0;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	eb 2e                	jmp    80117a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80114c:	8b 02                	mov    (%edx),%eax
  80114e:	85 c0                	test   %eax,%eax
  801150:	75 e7                	jne    801139 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801152:	a1 04 40 80 00       	mov    0x804004,%eax
  801157:	8b 40 7c             	mov    0x7c(%eax),%eax
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	51                   	push   %ecx
  80115e:	50                   	push   %eax
  80115f:	68 48 26 80 00       	push   $0x802648
  801164:	e8 47 f0 ff ff       	call   8001b0 <cprintf>
	*dev = 0;
  801169:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 10             	sub    $0x10,%esp
  801184:	8b 75 08             	mov    0x8(%ebp),%esi
  801187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801194:	c1 e8 0c             	shr    $0xc,%eax
  801197:	50                   	push   %eax
  801198:	e8 36 ff ff ff       	call   8010d3 <fd_lookup>
  80119d:	83 c4 08             	add    $0x8,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 05                	js     8011a9 <fd_close+0x2d>
	    || fd != fd2)
  8011a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a7:	74 0c                	je     8011b5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a9:	84 db                	test   %bl,%bl
  8011ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b0:	0f 44 c2             	cmove  %edx,%eax
  8011b3:	eb 41                	jmp    8011f6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff 36                	pushl  (%esi)
  8011be:	e8 66 ff ff ff       	call   801129 <dev_lookup>
  8011c3:	89 c3                	mov    %eax,%ebx
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 1a                	js     8011e6 <fd_close+0x6a>
		if (dev->dev_close)
  8011cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	74 0b                	je     8011e6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	56                   	push   %esi
  8011df:	ff d0                	call   *%eax
  8011e1:	89 c3                	mov    %eax,%ebx
  8011e3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	56                   	push   %esi
  8011ea:	6a 00                	push   $0x0
  8011ec:	e8 cc f9 ff ff       	call   800bbd <sys_page_unmap>
	return r;
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	89 d8                	mov    %ebx,%eax
}
  8011f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	ff 75 08             	pushl  0x8(%ebp)
  80120a:	e8 c4 fe ff ff       	call   8010d3 <fd_lookup>
  80120f:	83 c4 08             	add    $0x8,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 10                	js     801226 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	6a 01                	push   $0x1
  80121b:	ff 75 f4             	pushl  -0xc(%ebp)
  80121e:	e8 59 ff ff ff       	call   80117c <fd_close>
  801223:	83 c4 10             	add    $0x10,%esp
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <close_all>:

void
close_all(void)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	53                   	push   %ebx
  801238:	e8 c0 ff ff ff       	call   8011fd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123d:	83 c3 01             	add    $0x1,%ebx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	83 fb 20             	cmp    $0x20,%ebx
  801246:	75 ec                	jne    801234 <close_all+0xc>
		close(i);
}
  801248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	57                   	push   %edi
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 2c             	sub    $0x2c,%esp
  801256:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801259:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 6e fe ff ff       	call   8010d3 <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	0f 88 c1 00 00 00    	js     801331 <dup+0xe4>
		return r;
	close(newfdnum);
  801270:	83 ec 0c             	sub    $0xc,%esp
  801273:	56                   	push   %esi
  801274:	e8 84 ff ff ff       	call   8011fd <close>

	newfd = INDEX2FD(newfdnum);
  801279:	89 f3                	mov    %esi,%ebx
  80127b:	c1 e3 0c             	shl    $0xc,%ebx
  80127e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801284:	83 c4 04             	add    $0x4,%esp
  801287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80128a:	e8 de fd ff ff       	call   80106d <fd2data>
  80128f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801291:	89 1c 24             	mov    %ebx,(%esp)
  801294:	e8 d4 fd ff ff       	call   80106d <fd2data>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	c1 e8 16             	shr    $0x16,%eax
  8012a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ab:	a8 01                	test   $0x1,%al
  8012ad:	74 37                	je     8012e6 <dup+0x99>
  8012af:	89 f8                	mov    %edi,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	74 26                	je     8012e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d3:	6a 00                	push   $0x0
  8012d5:	57                   	push   %edi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 9e f8 ff ff       	call   800b7b <sys_page_map>
  8012dd:	89 c7                	mov    %eax,%edi
  8012df:	83 c4 20             	add    $0x20,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 2e                	js     801314 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	c1 e8 0c             	shr    $0xc,%eax
  8012ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fd:	50                   	push   %eax
  8012fe:	53                   	push   %ebx
  8012ff:	6a 00                	push   $0x0
  801301:	52                   	push   %edx
  801302:	6a 00                	push   $0x0
  801304:	e8 72 f8 ff ff       	call   800b7b <sys_page_map>
  801309:	89 c7                	mov    %eax,%edi
  80130b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801310:	85 ff                	test   %edi,%edi
  801312:	79 1d                	jns    801331 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	53                   	push   %ebx
  801318:	6a 00                	push   $0x0
  80131a:	e8 9e f8 ff ff       	call   800bbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	ff 75 d4             	pushl  -0x2c(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 91 f8 ff ff       	call   800bbd <sys_page_unmap>
	return r;
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	89 f8                	mov    %edi,%eax
}
  801331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	53                   	push   %ebx
  80133d:	83 ec 14             	sub    $0x14,%esp
  801340:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801343:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	53                   	push   %ebx
  801348:	e8 86 fd ff ff       	call   8010d3 <fd_lookup>
  80134d:	83 c4 08             	add    $0x8,%esp
  801350:	89 c2                	mov    %eax,%edx
  801352:	85 c0                	test   %eax,%eax
  801354:	78 6d                	js     8013c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801360:	ff 30                	pushl  (%eax)
  801362:	e8 c2 fd ff ff       	call   801129 <dev_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 4c                	js     8013ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801371:	8b 42 08             	mov    0x8(%edx),%eax
  801374:	83 e0 03             	and    $0x3,%eax
  801377:	83 f8 01             	cmp    $0x1,%eax
  80137a:	75 21                	jne    80139d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137c:	a1 04 40 80 00       	mov    0x804004,%eax
  801381:	8b 40 7c             	mov    0x7c(%eax),%eax
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	53                   	push   %ebx
  801388:	50                   	push   %eax
  801389:	68 89 26 80 00       	push   $0x802689
  80138e:	e8 1d ee ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139b:	eb 26                	jmp    8013c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a0:	8b 40 08             	mov    0x8(%eax),%eax
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 17                	je     8013be <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	ff 75 10             	pushl  0x10(%ebp)
  8013ad:	ff 75 0c             	pushl  0xc(%ebp)
  8013b0:	52                   	push   %edx
  8013b1:	ff d0                	call   *%eax
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	eb 09                	jmp    8013c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	eb 05                	jmp    8013c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013c3:	89 d0                	mov    %edx,%eax
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013de:	eb 21                	jmp    801401 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	29 d8                	sub    %ebx,%eax
  8013e7:	50                   	push   %eax
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	03 45 0c             	add    0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	57                   	push   %edi
  8013ef:	e8 45 ff ff ff       	call   801339 <read>
		if (m < 0)
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 10                	js     80140b <readn+0x41>
			return m;
		if (m == 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 0a                	je     801409 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ff:	01 c3                	add    %eax,%ebx
  801401:	39 f3                	cmp    %esi,%ebx
  801403:	72 db                	jb     8013e0 <readn+0x16>
  801405:	89 d8                	mov    %ebx,%eax
  801407:	eb 02                	jmp    80140b <readn+0x41>
  801409:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80140b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    

00801413 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	83 ec 14             	sub    $0x14,%esp
  80141a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	53                   	push   %ebx
  801422:	e8 ac fc ff ff       	call   8010d3 <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 68                	js     801498 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	ff 30                	pushl  (%eax)
  80143c:	e8 e8 fc ff ff       	call   801129 <dev_lookup>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 47                	js     80148f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144f:	75 21                	jne    801472 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801451:	a1 04 40 80 00       	mov    0x804004,%eax
  801456:	8b 40 7c             	mov    0x7c(%eax),%eax
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	53                   	push   %ebx
  80145d:	50                   	push   %eax
  80145e:	68 a5 26 80 00       	push   $0x8026a5
  801463:	e8 48 ed ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801470:	eb 26                	jmp    801498 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801472:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801475:	8b 52 0c             	mov    0xc(%edx),%edx
  801478:	85 d2                	test   %edx,%edx
  80147a:	74 17                	je     801493 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	ff 75 10             	pushl  0x10(%ebp)
  801482:	ff 75 0c             	pushl  0xc(%ebp)
  801485:	50                   	push   %eax
  801486:	ff d2                	call   *%edx
  801488:	89 c2                	mov    %eax,%edx
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	eb 09                	jmp    801498 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148f:	89 c2                	mov    %eax,%edx
  801491:	eb 05                	jmp    801498 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801493:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801498:	89 d0                	mov    %edx,%eax
  80149a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <seek>:

int
seek(int fdnum, off_t offset)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	ff 75 08             	pushl  0x8(%ebp)
  8014ac:	e8 22 fc ff ff       	call   8010d3 <fd_lookup>
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 0e                	js     8014c6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014be:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 14             	sub    $0x14,%esp
  8014cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	53                   	push   %ebx
  8014d7:	e8 f7 fb ff ff       	call   8010d3 <fd_lookup>
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 65                	js     80154a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	ff 30                	pushl  (%eax)
  8014f1:	e8 33 fc ff ff       	call   801129 <dev_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 44                	js     801541 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801504:	75 21                	jne    801527 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801506:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80150b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	50                   	push   %eax
  801513:	68 68 26 80 00       	push   $0x802668
  801518:	e8 93 ec ff ff       	call   8001b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801525:	eb 23                	jmp    80154a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801527:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152a:	8b 52 18             	mov    0x18(%edx),%edx
  80152d:	85 d2                	test   %edx,%edx
  80152f:	74 14                	je     801545 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	ff 75 0c             	pushl  0xc(%ebp)
  801537:	50                   	push   %eax
  801538:	ff d2                	call   *%edx
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	eb 09                	jmp    80154a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801541:	89 c2                	mov    %eax,%edx
  801543:	eb 05                	jmp    80154a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801545:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80154a:	89 d0                	mov    %edx,%eax
  80154c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 14             	sub    $0x14,%esp
  801558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	ff 75 08             	pushl  0x8(%ebp)
  801562:	e8 6c fb ff ff       	call   8010d3 <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 58                	js     8015c8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	ff 30                	pushl  (%eax)
  80157c:	e8 a8 fb ff ff       	call   801129 <dev_lookup>
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 37                	js     8015bf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801588:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158f:	74 32                	je     8015c3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801591:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801594:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80159b:	00 00 00 
	stat->st_isdir = 0;
  80159e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a5:	00 00 00 
	stat->st_dev = dev;
  8015a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	53                   	push   %ebx
  8015b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b5:	ff 50 14             	call   *0x14(%eax)
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	eb 09                	jmp    8015c8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	eb 05                	jmp    8015c8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c8:	89 d0                	mov    %edx,%eax
  8015ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	6a 00                	push   $0x0
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 e3 01 00 00       	call   8017c4 <open>
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 1b                	js     801605 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	50                   	push   %eax
  8015f1:	e8 5b ff ff ff       	call   801551 <fstat>
  8015f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f8:	89 1c 24             	mov    %ebx,(%esp)
  8015fb:	e8 fd fb ff ff       	call   8011fd <close>
	return r;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	89 f0                	mov    %esi,%eax
}
  801605:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	89 c6                	mov    %eax,%esi
  801613:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801615:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80161c:	75 12                	jne    801630 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	6a 01                	push   $0x1
  801623:	e8 da 08 00 00       	call   801f02 <ipc_find_env>
  801628:	a3 00 40 80 00       	mov    %eax,0x804000
  80162d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801630:	6a 07                	push   $0x7
  801632:	68 00 50 80 00       	push   $0x805000
  801637:	56                   	push   %esi
  801638:	ff 35 00 40 80 00    	pushl  0x804000
  80163e:	e8 5d 08 00 00       	call   801ea0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801643:	83 c4 0c             	add    $0xc,%esp
  801646:	6a 00                	push   $0x0
  801648:	53                   	push   %ebx
  801649:	6a 00                	push   $0x0
  80164b:	e8 d5 07 00 00       	call   801e25 <ipc_recv>
}
  801650:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80165d:	8b 45 08             	mov    0x8(%ebp),%eax
  801660:	8b 40 0c             	mov    0xc(%eax),%eax
  801663:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	b8 02 00 00 00       	mov    $0x2,%eax
  80167a:	e8 8d ff ff ff       	call   80160c <fsipc>
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	8b 40 0c             	mov    0xc(%eax),%eax
  80168d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	b8 06 00 00 00       	mov    $0x6,%eax
  80169c:	e8 6b ff ff ff       	call   80160c <fsipc>
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c2:	e8 45 ff ff ff       	call   80160c <fsipc>
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 2c                	js     8016f7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	68 00 50 80 00       	push   $0x805000
  8016d3:	53                   	push   %ebx
  8016d4:	e8 5c f0 ff ff       	call   800735 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8016de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801705:	8b 55 08             	mov    0x8(%ebp),%edx
  801708:	8b 52 0c             	mov    0xc(%edx),%edx
  80170b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801711:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801716:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80171b:	0f 47 c2             	cmova  %edx,%eax
  80171e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801723:	50                   	push   %eax
  801724:	ff 75 0c             	pushl  0xc(%ebp)
  801727:	68 08 50 80 00       	push   $0x805008
  80172c:	e8 96 f1 ff ff       	call   8008c7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801731:	ba 00 00 00 00       	mov    $0x0,%edx
  801736:	b8 04 00 00 00       	mov    $0x4,%eax
  80173b:	e8 cc fe ff ff       	call   80160c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80174a:	8b 45 08             	mov    0x8(%ebp),%eax
  80174d:	8b 40 0c             	mov    0xc(%eax),%eax
  801750:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801755:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80175b:	ba 00 00 00 00       	mov    $0x0,%edx
  801760:	b8 03 00 00 00       	mov    $0x3,%eax
  801765:	e8 a2 fe ff ff       	call   80160c <fsipc>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 4b                	js     8017bb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801770:	39 c6                	cmp    %eax,%esi
  801772:	73 16                	jae    80178a <devfile_read+0x48>
  801774:	68 d4 26 80 00       	push   $0x8026d4
  801779:	68 db 26 80 00       	push   $0x8026db
  80177e:	6a 7c                	push   $0x7c
  801780:	68 f0 26 80 00       	push   $0x8026f0
  801785:	e8 c6 05 00 00       	call   801d50 <_panic>
	assert(r <= PGSIZE);
  80178a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178f:	7e 16                	jle    8017a7 <devfile_read+0x65>
  801791:	68 fb 26 80 00       	push   $0x8026fb
  801796:	68 db 26 80 00       	push   $0x8026db
  80179b:	6a 7d                	push   $0x7d
  80179d:	68 f0 26 80 00       	push   $0x8026f0
  8017a2:	e8 a9 05 00 00       	call   801d50 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	50                   	push   %eax
  8017ab:	68 00 50 80 00       	push   $0x805000
  8017b0:	ff 75 0c             	pushl  0xc(%ebp)
  8017b3:	e8 0f f1 ff ff       	call   8008c7 <memmove>
	return r;
  8017b8:	83 c4 10             	add    $0x10,%esp
}
  8017bb:	89 d8                	mov    %ebx,%eax
  8017bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 20             	sub    $0x20,%esp
  8017cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ce:	53                   	push   %ebx
  8017cf:	e8 28 ef ff ff       	call   8006fc <strlen>
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017dc:	7f 67                	jg     801845 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e4:	50                   	push   %eax
  8017e5:	e8 9a f8 ff ff       	call   801084 <fd_alloc>
  8017ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ed:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 57                	js     80184a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	53                   	push   %ebx
  8017f7:	68 00 50 80 00       	push   $0x805000
  8017fc:	e8 34 ef ff ff       	call   800735 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801809:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180c:	b8 01 00 00 00       	mov    $0x1,%eax
  801811:	e8 f6 fd ff ff       	call   80160c <fsipc>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	79 14                	jns    801833 <open+0x6f>
		fd_close(fd, 0);
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	6a 00                	push   $0x0
  801824:	ff 75 f4             	pushl  -0xc(%ebp)
  801827:	e8 50 f9 ff ff       	call   80117c <fd_close>
		return r;
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	89 da                	mov    %ebx,%edx
  801831:	eb 17                	jmp    80184a <open+0x86>
	}

	return fd2num(fd);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	ff 75 f4             	pushl  -0xc(%ebp)
  801839:	e8 1f f8 ff ff       	call   80105d <fd2num>
  80183e:	89 c2                	mov    %eax,%edx
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb 05                	jmp    80184a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801845:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80184a:	89 d0                	mov    %edx,%eax
  80184c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 08 00 00 00       	mov    $0x8,%eax
  801861:	e8 a6 fd ff ff       	call   80160c <fsipc>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 f2 f7 ff ff       	call   80106d <fd2data>
  80187b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	68 07 27 80 00       	push   $0x802707
  801885:	53                   	push   %ebx
  801886:	e8 aa ee ff ff       	call   800735 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80188b:	8b 46 04             	mov    0x4(%esi),%eax
  80188e:	2b 06                	sub    (%esi),%eax
  801890:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801896:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189d:	00 00 00 
	stat->st_dev = &devpipe;
  8018a0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a7:	30 80 00 
	return 0;
}
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018c0:	53                   	push   %ebx
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 f5 f2 ff ff       	call   800bbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018c8:	89 1c 24             	mov    %ebx,(%esp)
  8018cb:	e8 9d f7 ff ff       	call   80106d <fd2data>
  8018d0:	83 c4 08             	add    $0x8,%esp
  8018d3:	50                   	push   %eax
  8018d4:	6a 00                	push   $0x0
  8018d6:	e8 e2 f2 ff ff       	call   800bbd <sys_page_unmap>
}
  8018db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	57                   	push   %edi
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 1c             	sub    $0x1c,%esp
  8018e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ec:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f3:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018f9:	83 ec 0c             	sub    $0xc,%esp
  8018fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ff:	e8 40 06 00 00       	call   801f44 <pageref>
  801904:	89 c3                	mov    %eax,%ebx
  801906:	89 3c 24             	mov    %edi,(%esp)
  801909:	e8 36 06 00 00       	call   801f44 <pageref>
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	39 c3                	cmp    %eax,%ebx
  801913:	0f 94 c1             	sete   %cl
  801916:	0f b6 c9             	movzbl %cl,%ecx
  801919:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80191c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801922:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801928:	39 ce                	cmp    %ecx,%esi
  80192a:	74 1e                	je     80194a <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80192c:	39 c3                	cmp    %eax,%ebx
  80192e:	75 be                	jne    8018ee <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801930:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801936:	ff 75 e4             	pushl  -0x1c(%ebp)
  801939:	50                   	push   %eax
  80193a:	56                   	push   %esi
  80193b:	68 0e 27 80 00       	push   $0x80270e
  801940:	e8 6b e8 ff ff       	call   8001b0 <cprintf>
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	eb a4                	jmp    8018ee <_pipeisclosed+0xe>
	}
}
  80194a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80194d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5f                   	pop    %edi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	83 ec 28             	sub    $0x28,%esp
  80195e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801961:	56                   	push   %esi
  801962:	e8 06 f7 ff ff       	call   80106d <fd2data>
  801967:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	bf 00 00 00 00       	mov    $0x0,%edi
  801971:	eb 4b                	jmp    8019be <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801973:	89 da                	mov    %ebx,%edx
  801975:	89 f0                	mov    %esi,%eax
  801977:	e8 64 ff ff ff       	call   8018e0 <_pipeisclosed>
  80197c:	85 c0                	test   %eax,%eax
  80197e:	75 48                	jne    8019c8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801980:	e8 94 f1 ff ff       	call   800b19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801985:	8b 43 04             	mov    0x4(%ebx),%eax
  801988:	8b 0b                	mov    (%ebx),%ecx
  80198a:	8d 51 20             	lea    0x20(%ecx),%edx
  80198d:	39 d0                	cmp    %edx,%eax
  80198f:	73 e2                	jae    801973 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801991:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801994:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801998:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	c1 fa 1f             	sar    $0x1f,%edx
  8019a0:	89 d1                	mov    %edx,%ecx
  8019a2:	c1 e9 1b             	shr    $0x1b,%ecx
  8019a5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019a8:	83 e2 1f             	and    $0x1f,%edx
  8019ab:	29 ca                	sub    %ecx,%edx
  8019ad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019b5:	83 c0 01             	add    $0x1,%eax
  8019b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019bb:	83 c7 01             	add    $0x1,%edi
  8019be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019c1:	75 c2                	jne    801985 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c6:	eb 05                	jmp    8019cd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	57                   	push   %edi
  8019d9:	56                   	push   %esi
  8019da:	53                   	push   %ebx
  8019db:	83 ec 18             	sub    $0x18,%esp
  8019de:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019e1:	57                   	push   %edi
  8019e2:	e8 86 f6 ff ff       	call   80106d <fd2data>
  8019e7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019f1:	eb 3d                	jmp    801a30 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019f3:	85 db                	test   %ebx,%ebx
  8019f5:	74 04                	je     8019fb <devpipe_read+0x26>
				return i;
  8019f7:	89 d8                	mov    %ebx,%eax
  8019f9:	eb 44                	jmp    801a3f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019fb:	89 f2                	mov    %esi,%edx
  8019fd:	89 f8                	mov    %edi,%eax
  8019ff:	e8 dc fe ff ff       	call   8018e0 <_pipeisclosed>
  801a04:	85 c0                	test   %eax,%eax
  801a06:	75 32                	jne    801a3a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a08:	e8 0c f1 ff ff       	call   800b19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a0d:	8b 06                	mov    (%esi),%eax
  801a0f:	3b 46 04             	cmp    0x4(%esi),%eax
  801a12:	74 df                	je     8019f3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a14:	99                   	cltd   
  801a15:	c1 ea 1b             	shr    $0x1b,%edx
  801a18:	01 d0                	add    %edx,%eax
  801a1a:	83 e0 1f             	and    $0x1f,%eax
  801a1d:	29 d0                	sub    %edx,%eax
  801a1f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a27:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a2a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2d:	83 c3 01             	add    $0x1,%ebx
  801a30:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a33:	75 d8                	jne    801a0d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a35:	8b 45 10             	mov    0x10(%ebp),%eax
  801a38:	eb 05                	jmp    801a3f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	5f                   	pop    %edi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a52:	50                   	push   %eax
  801a53:	e8 2c f6 ff ff       	call   801084 <fd_alloc>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	0f 88 2c 01 00 00    	js     801b91 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a65:	83 ec 04             	sub    $0x4,%esp
  801a68:	68 07 04 00 00       	push   $0x407
  801a6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a70:	6a 00                	push   $0x0
  801a72:	e8 c1 f0 ff ff       	call   800b38 <sys_page_alloc>
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	89 c2                	mov    %eax,%edx
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	0f 88 0d 01 00 00    	js     801b91 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8a:	50                   	push   %eax
  801a8b:	e8 f4 f5 ff ff       	call   801084 <fd_alloc>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	0f 88 e2 00 00 00    	js     801b7f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	68 07 04 00 00       	push   $0x407
  801aa5:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 89 f0 ff ff       	call   800b38 <sys_page_alloc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 c3 00 00 00    	js     801b7f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac2:	e8 a6 f5 ff ff       	call   80106d <fd2data>
  801ac7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac9:	83 c4 0c             	add    $0xc,%esp
  801acc:	68 07 04 00 00       	push   $0x407
  801ad1:	50                   	push   %eax
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 5f f0 ff ff       	call   800b38 <sys_page_alloc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	0f 88 89 00 00 00    	js     801b6f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	ff 75 f0             	pushl  -0x10(%ebp)
  801aec:	e8 7c f5 ff ff       	call   80106d <fd2data>
  801af1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801af8:	50                   	push   %eax
  801af9:	6a 00                	push   $0x0
  801afb:	56                   	push   %esi
  801afc:	6a 00                	push   $0x0
  801afe:	e8 78 f0 ff ff       	call   800b7b <sys_page_map>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	83 c4 20             	add    $0x20,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	78 55                	js     801b61 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3c:	e8 1c f5 ff ff       	call   80105d <fd2num>
  801b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b46:	83 c4 04             	add    $0x4,%esp
  801b49:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4c:	e8 0c f5 ff ff       	call   80105d <fd2num>
  801b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b54:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5f:	eb 30                	jmp    801b91 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b61:	83 ec 08             	sub    $0x8,%esp
  801b64:	56                   	push   %esi
  801b65:	6a 00                	push   $0x0
  801b67:	e8 51 f0 ff ff       	call   800bbd <sys_page_unmap>
  801b6c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b6f:	83 ec 08             	sub    $0x8,%esp
  801b72:	ff 75 f0             	pushl  -0x10(%ebp)
  801b75:	6a 00                	push   $0x0
  801b77:	e8 41 f0 ff ff       	call   800bbd <sys_page_unmap>
  801b7c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b7f:	83 ec 08             	sub    $0x8,%esp
  801b82:	ff 75 f4             	pushl  -0xc(%ebp)
  801b85:	6a 00                	push   $0x0
  801b87:	e8 31 f0 ff ff       	call   800bbd <sys_page_unmap>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b91:	89 d0                	mov    %edx,%eax
  801b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	ff 75 08             	pushl  0x8(%ebp)
  801ba7:	e8 27 f5 ff ff       	call   8010d3 <fd_lookup>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	78 18                	js     801bcb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb9:	e8 af f4 ff ff       	call   80106d <fd2data>
	return _pipeisclosed(fd, p);
  801bbe:	89 c2                	mov    %eax,%edx
  801bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc3:	e8 18 fd ff ff       	call   8018e0 <_pipeisclosed>
  801bc8:	83 c4 10             	add    $0x10,%esp
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bdd:	68 26 27 80 00       	push   $0x802726
  801be2:	ff 75 0c             	pushl  0xc(%ebp)
  801be5:	e8 4b eb ff ff       	call   800735 <strcpy>
	return 0;
}
  801bea:	b8 00 00 00 00       	mov    $0x0,%eax
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bfd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c02:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c08:	eb 2d                	jmp    801c37 <devcons_write+0x46>
		m = n - tot;
  801c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c0d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c0f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c12:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c17:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c1a:	83 ec 04             	sub    $0x4,%esp
  801c1d:	53                   	push   %ebx
  801c1e:	03 45 0c             	add    0xc(%ebp),%eax
  801c21:	50                   	push   %eax
  801c22:	57                   	push   %edi
  801c23:	e8 9f ec ff ff       	call   8008c7 <memmove>
		sys_cputs(buf, m);
  801c28:	83 c4 08             	add    $0x8,%esp
  801c2b:	53                   	push   %ebx
  801c2c:	57                   	push   %edi
  801c2d:	e8 4a ee ff ff       	call   800a7c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c32:	01 de                	add    %ebx,%esi
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	89 f0                	mov    %esi,%eax
  801c39:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c3c:	72 cc                	jb     801c0a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c55:	74 2a                	je     801c81 <devcons_read+0x3b>
  801c57:	eb 05                	jmp    801c5e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c59:	e8 bb ee ff ff       	call   800b19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c5e:	e8 37 ee ff ff       	call   800a9a <sys_cgetc>
  801c63:	85 c0                	test   %eax,%eax
  801c65:	74 f2                	je     801c59 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c67:	85 c0                	test   %eax,%eax
  801c69:	78 16                	js     801c81 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c6b:	83 f8 04             	cmp    $0x4,%eax
  801c6e:	74 0c                	je     801c7c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c70:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c73:	88 02                	mov    %al,(%edx)
	return 1;
  801c75:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7a:	eb 05                	jmp    801c81 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c8f:	6a 01                	push   $0x1
  801c91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	e8 e2 ed ff ff       	call   800a7c <sys_cputs>
}
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <getchar>:

int
getchar(void)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ca5:	6a 01                	push   $0x1
  801ca7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801caa:	50                   	push   %eax
  801cab:	6a 00                	push   $0x0
  801cad:	e8 87 f6 ff ff       	call   801339 <read>
	if (r < 0)
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 0f                	js     801cc8 <getchar+0x29>
		return r;
	if (r < 1)
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	7e 06                	jle    801cc3 <getchar+0x24>
		return -E_EOF;
	return c;
  801cbd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cc1:	eb 05                	jmp    801cc8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cc3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd3:	50                   	push   %eax
  801cd4:	ff 75 08             	pushl  0x8(%ebp)
  801cd7:	e8 f7 f3 ff ff       	call   8010d3 <fd_lookup>
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 11                	js     801cf4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cec:	39 10                	cmp    %edx,(%eax)
  801cee:	0f 94 c0             	sete   %al
  801cf1:	0f b6 c0             	movzbl %al,%eax
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <opencons>:

int
opencons(void)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	e8 7f f3 ff ff       	call   801084 <fd_alloc>
  801d05:	83 c4 10             	add    $0x10,%esp
		return r;
  801d08:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 3e                	js     801d4c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	68 07 04 00 00       	push   $0x407
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 18 ee ff ff       	call   800b38 <sys_page_alloc>
  801d20:	83 c4 10             	add    $0x10,%esp
		return r;
  801d23:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 23                	js     801d4c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	50                   	push   %eax
  801d42:	e8 16 f3 ff ff       	call   80105d <fd2num>
  801d47:	89 c2                	mov    %eax,%edx
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d55:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d58:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d5e:	e8 97 ed ff ff       	call   800afa <sys_getenvid>
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	ff 75 08             	pushl  0x8(%ebp)
  801d6c:	56                   	push   %esi
  801d6d:	50                   	push   %eax
  801d6e:	68 34 27 80 00       	push   $0x802734
  801d73:	e8 38 e4 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d78:	83 c4 18             	add    $0x18,%esp
  801d7b:	53                   	push   %ebx
  801d7c:	ff 75 10             	pushl  0x10(%ebp)
  801d7f:	e8 db e3 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  801d84:	c7 04 24 1f 27 80 00 	movl   $0x80271f,(%esp)
  801d8b:	e8 20 e4 ff ff       	call   8001b0 <cprintf>
  801d90:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d93:	cc                   	int3   
  801d94:	eb fd                	jmp    801d93 <_panic+0x43>

00801d96 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d9c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da3:	75 2a                	jne    801dcf <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801da5:	83 ec 04             	sub    $0x4,%esp
  801da8:	6a 07                	push   $0x7
  801daa:	68 00 f0 bf ee       	push   $0xeebff000
  801daf:	6a 00                	push   $0x0
  801db1:	e8 82 ed ff ff       	call   800b38 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	79 12                	jns    801dcf <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dbd:	50                   	push   %eax
  801dbe:	68 58 27 80 00       	push   $0x802758
  801dc3:	6a 23                	push   $0x23
  801dc5:	68 5c 27 80 00       	push   $0x80275c
  801dca:	e8 81 ff ff ff       	call   801d50 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	68 01 1e 80 00       	push   $0x801e01
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 9d ee ff ff       	call   800c83 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	79 12                	jns    801dff <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ded:	50                   	push   %eax
  801dee:	68 58 27 80 00       	push   $0x802758
  801df3:	6a 2c                	push   $0x2c
  801df5:	68 5c 27 80 00       	push   $0x80275c
  801dfa:	e8 51 ff ff ff       	call   801d50 <_panic>
	}
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    

00801e01 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e01:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e02:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e07:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e09:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e0c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e10:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e15:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e19:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e1b:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e1e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e1f:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e22:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e23:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e24:	c3                   	ret    

00801e25 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	56                   	push   %esi
  801e29:	53                   	push   %ebx
  801e2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e33:	85 c0                	test   %eax,%eax
  801e35:	75 12                	jne    801e49 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e37:	83 ec 0c             	sub    $0xc,%esp
  801e3a:	68 00 00 c0 ee       	push   $0xeec00000
  801e3f:	e8 a4 ee ff ff       	call   800ce8 <sys_ipc_recv>
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	eb 0c                	jmp    801e55 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e49:	83 ec 0c             	sub    $0xc,%esp
  801e4c:	50                   	push   %eax
  801e4d:	e8 96 ee ff ff       	call   800ce8 <sys_ipc_recv>
  801e52:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e55:	85 f6                	test   %esi,%esi
  801e57:	0f 95 c1             	setne  %cl
  801e5a:	85 db                	test   %ebx,%ebx
  801e5c:	0f 95 c2             	setne  %dl
  801e5f:	84 d1                	test   %dl,%cl
  801e61:	74 09                	je     801e6c <ipc_recv+0x47>
  801e63:	89 c2                	mov    %eax,%edx
  801e65:	c1 ea 1f             	shr    $0x1f,%edx
  801e68:	84 d2                	test   %dl,%dl
  801e6a:	75 2d                	jne    801e99 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e6c:	85 f6                	test   %esi,%esi
  801e6e:	74 0d                	je     801e7d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e70:	a1 04 40 80 00       	mov    0x804004,%eax
  801e75:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e7b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e7d:	85 db                	test   %ebx,%ebx
  801e7f:	74 0d                	je     801e8e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e81:	a1 04 40 80 00       	mov    0x804004,%eax
  801e86:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e8c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e93:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5d                   	pop    %ebp
  801e9f:	c3                   	ret    

00801ea0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	57                   	push   %edi
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eb2:	85 db                	test   %ebx,%ebx
  801eb4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eb9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ebc:	ff 75 14             	pushl  0x14(%ebp)
  801ebf:	53                   	push   %ebx
  801ec0:	56                   	push   %esi
  801ec1:	57                   	push   %edi
  801ec2:	e8 fe ed ff ff       	call   800cc5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ec7:	89 c2                	mov    %eax,%edx
  801ec9:	c1 ea 1f             	shr    $0x1f,%edx
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	84 d2                	test   %dl,%dl
  801ed1:	74 17                	je     801eea <ipc_send+0x4a>
  801ed3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed6:	74 12                	je     801eea <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ed8:	50                   	push   %eax
  801ed9:	68 6a 27 80 00       	push   $0x80276a
  801ede:	6a 47                	push   $0x47
  801ee0:	68 78 27 80 00       	push   $0x802778
  801ee5:	e8 66 fe ff ff       	call   801d50 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801eea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eed:	75 07                	jne    801ef6 <ipc_send+0x56>
			sys_yield();
  801eef:	e8 25 ec ff ff       	call   800b19 <sys_yield>
  801ef4:	eb c6                	jmp    801ebc <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	75 c2                	jne    801ebc <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5f                   	pop    %edi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f0d:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f13:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f19:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f1f:	39 ca                	cmp    %ecx,%edx
  801f21:	75 10                	jne    801f33 <ipc_find_env+0x31>
			return envs[i].env_id;
  801f23:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f29:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f2e:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f31:	eb 0f                	jmp    801f42 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f33:	83 c0 01             	add    $0x1,%eax
  801f36:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3b:	75 d0                	jne    801f0d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4a:	89 d0                	mov    %edx,%eax
  801f4c:	c1 e8 16             	shr    $0x16,%eax
  801f4f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5b:	f6 c1 01             	test   $0x1,%cl
  801f5e:	74 1d                	je     801f7d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f60:	c1 ea 0c             	shr    $0xc,%edx
  801f63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f6a:	f6 c2 01             	test   $0x1,%dl
  801f6d:	74 0e                	je     801f7d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f6f:	c1 ea 0c             	shr    $0xc,%edx
  801f72:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f79:	ef 
  801f7a:	0f b7 c0             	movzwl %ax,%eax
}
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
