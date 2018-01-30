
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 c1 0a 00 00       	call   800b01 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 d4 	cmpl   $0xeec000d4,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 2c 12 00 00       	call   80128a <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 60 24 80 00       	push   $0x802460
  80006a:	e8 48 01 00 00       	call   8001b7 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 74 01 c0 ee       	mov    0xeec00174,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 71 24 80 00       	push   $0x802471
  800083:	e8 2f 01 00 00       	call   8001b7 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 74 01 c0 ee       	mov    0xeec00174,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 69 12 00 00       	call   801305 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 50 0a 00 00       	call   800b01 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c6:	85 db                	test   %ebx,%ebx
  8000c8:	7e 07                	jle    8000d1 <libmain+0x30>
		binaryname = argv[0];
  8000ca:	8b 06                	mov    (%esi),%eax
  8000cc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	e8 58 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000db:	e8 2a 00 00 00       	call   80010a <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000f0:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000f5:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000f7:	e8 05 0a 00 00       	call   800b01 <sys_getenvid>
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	e8 4b 0c 00 00       	call   800d50 <sys_thread_free>
}
  800105:	83 c4 10             	add    $0x10,%esp
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800110:	e8 65 14 00 00       	call   80157a <close_all>
	sys_env_destroy(0);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	6a 00                	push   $0x0
  80011a:	e8 a1 09 00 00       	call   800ac0 <sys_env_destroy>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012e:	8b 13                	mov    (%ebx),%edx
  800130:	8d 42 01             	lea    0x1(%edx),%eax
  800133:	89 03                	mov    %eax,(%ebx)
  800135:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800138:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800141:	75 1a                	jne    80015d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800143:	83 ec 08             	sub    $0x8,%esp
  800146:	68 ff 00 00 00       	push   $0xff
  80014b:	8d 43 08             	lea    0x8(%ebx),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 2f 09 00 00       	call   800a83 <sys_cputs>
		b->idx = 0;
  800154:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800176:	00 00 00 
	b.cnt = 0;
  800179:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800180:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800183:	ff 75 0c             	pushl  0xc(%ebp)
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018f:	50                   	push   %eax
  800190:	68 24 01 80 00       	push   $0x800124
  800195:	e8 54 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019a:	83 c4 08             	add    $0x8,%esp
  80019d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a9:	50                   	push   %eax
  8001aa:	e8 d4 08 00 00       	call   800a83 <sys_cputs>

	return b.cnt;
}
  8001af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c0:	50                   	push   %eax
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	e8 9d ff ff ff       	call   800166 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	57                   	push   %edi
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 1c             	sub    $0x1c,%esp
  8001d4:	89 c7                	mov    %eax,%edi
  8001d6:	89 d6                	mov    %edx,%esi
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ef:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f2:	39 d3                	cmp    %edx,%ebx
  8001f4:	72 05                	jb     8001fb <printnum+0x30>
  8001f6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f9:	77 45                	ja     800240 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fb:	83 ec 0c             	sub    $0xc,%esp
  8001fe:	ff 75 18             	pushl  0x18(%ebp)
  800201:	8b 45 14             	mov    0x14(%ebp),%eax
  800204:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800207:	53                   	push   %ebx
  800208:	ff 75 10             	pushl  0x10(%ebp)
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800211:	ff 75 e0             	pushl  -0x20(%ebp)
  800214:	ff 75 dc             	pushl  -0x24(%ebp)
  800217:	ff 75 d8             	pushl  -0x28(%ebp)
  80021a:	e8 a1 1f 00 00       	call   8021c0 <__udivdi3>
  80021f:	83 c4 18             	add    $0x18,%esp
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	89 f2                	mov    %esi,%edx
  800226:	89 f8                	mov    %edi,%eax
  800228:	e8 9e ff ff ff       	call   8001cb <printnum>
  80022d:	83 c4 20             	add    $0x20,%esp
  800230:	eb 18                	jmp    80024a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800232:	83 ec 08             	sub    $0x8,%esp
  800235:	56                   	push   %esi
  800236:	ff 75 18             	pushl  0x18(%ebp)
  800239:	ff d7                	call   *%edi
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	eb 03                	jmp    800243 <printnum+0x78>
  800240:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800243:	83 eb 01             	sub    $0x1,%ebx
  800246:	85 db                	test   %ebx,%ebx
  800248:	7f e8                	jg     800232 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	83 ec 04             	sub    $0x4,%esp
  800251:	ff 75 e4             	pushl  -0x1c(%ebp)
  800254:	ff 75 e0             	pushl  -0x20(%ebp)
  800257:	ff 75 dc             	pushl  -0x24(%ebp)
  80025a:	ff 75 d8             	pushl  -0x28(%ebp)
  80025d:	e8 8e 20 00 00       	call   8022f0 <__umoddi3>
  800262:	83 c4 14             	add    $0x14,%esp
  800265:	0f be 80 92 24 80 00 	movsbl 0x802492(%eax),%eax
  80026c:	50                   	push   %eax
  80026d:	ff d7                	call   *%edi
}
  80026f:	83 c4 10             	add    $0x10,%esp
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027d:	83 fa 01             	cmp    $0x1,%edx
  800280:	7e 0e                	jle    800290 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 08             	lea    0x8(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	8b 52 04             	mov    0x4(%edx),%edx
  80028e:	eb 22                	jmp    8002b2 <getuint+0x38>
	else if (lflag)
  800290:	85 d2                	test   %edx,%edx
  800292:	74 10                	je     8002a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a2:	eb 0e                	jmp    8002b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	eb 12                	jmp    800314 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800302:	85 c0                	test   %eax,%eax
  800304:	0f 84 89 03 00 00    	je     800693 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	53                   	push   %ebx
  80030e:	50                   	push   %eax
  80030f:	ff d6                	call   *%esi
  800311:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	83 c7 01             	add    $0x1,%edi
  800317:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031b:	83 f8 25             	cmp    $0x25,%eax
  80031e:	75 e2                	jne    800302 <vprintfmt+0x14>
  800320:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800324:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800332:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	eb 07                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8d 47 01             	lea    0x1(%edi),%eax
  80034a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034d:	0f b6 07             	movzbl (%edi),%eax
  800350:	0f b6 c8             	movzbl %al,%ecx
  800353:	83 e8 23             	sub    $0x23,%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 1a 03 00 00    	ja     800678 <vprintfmt+0x38a>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036f:	eb d6                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800383:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800386:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800389:	83 fa 09             	cmp    $0x9,%edx
  80038c:	77 39                	ja     8003c7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800391:	eb e9                	jmp    80037c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 48 04             	lea    0x4(%eax),%ecx
  800399:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80039c:	8b 00                	mov    (%eax),%eax
  80039e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 27                	jmp    8003cd <vprintfmt+0xdf>
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b0:	0f 49 c8             	cmovns %eax,%ecx
  8003b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	eb 8c                	jmp    800347 <vprintfmt+0x59>
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c5:	eb 80                	jmp    800347 <vprintfmt+0x59>
  8003c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d1:	0f 89 70 ff ff ff    	jns    800347 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e4:	e9 5e ff ff ff       	jmp    800347 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ef:	e9 53 ff ff ff       	jmp    800347 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040b:	e9 04 ff ff ff       	jmp    800314 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 0f             	cmp    $0xf,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x142>
  800425:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 18                	jne    800448 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 aa 24 80 00       	push   $0x8024aa
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 94 fe ff ff       	call   8002d1 <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800443:	e9 cc fe ff ff       	jmp    800314 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800448:	52                   	push   %edx
  800449:	68 15 29 80 00       	push   $0x802915
  80044e:	53                   	push   %ebx
  80044f:	56                   	push   %esi
  800450:	e8 7c fe ff ff       	call   8002d1 <printfmt>
  800455:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045b:	e9 b4 fe ff ff       	jmp    800314 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046b:	85 ff                	test   %edi,%edi
  80046d:	b8 a3 24 80 00       	mov    $0x8024a3,%eax
  800472:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800475:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800479:	0f 8e 94 00 00 00    	jle    800513 <vprintfmt+0x225>
  80047f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800483:	0f 84 98 00 00 00    	je     800521 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	ff 75 d0             	pushl  -0x30(%ebp)
  80048f:	57                   	push   %edi
  800490:	e8 86 02 00 00       	call   80071b <strnlen>
  800495:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800498:	29 c1                	sub    %eax,%ecx
  80049a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004aa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	eb 0f                	jmp    8004bd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	83 ef 01             	sub    $0x1,%edi
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	7f ed                	jg     8004ae <vprintfmt+0x1c0>
  8004c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c7:	85 c9                	test   %ecx,%ecx
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ce:	0f 49 c1             	cmovns %ecx,%eax
  8004d1:	29 c1                	sub    %eax,%ecx
  8004d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dc:	89 cb                	mov    %ecx,%ebx
  8004de:	eb 4d                	jmp    80052d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e4:	74 1b                	je     800501 <vprintfmt+0x213>
  8004e6:	0f be c0             	movsbl %al,%eax
  8004e9:	83 e8 20             	sub    $0x20,%eax
  8004ec:	83 f8 5e             	cmp    $0x5e,%eax
  8004ef:	76 10                	jbe    800501 <vprintfmt+0x213>
					putch('?', putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	eb 0d                	jmp    80050e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	52                   	push   %edx
  800508:	ff 55 08             	call   *0x8(%ebp)
  80050b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	83 eb 01             	sub    $0x1,%ebx
  800511:	eb 1a                	jmp    80052d <vprintfmt+0x23f>
  800513:	89 75 08             	mov    %esi,0x8(%ebp)
  800516:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051f:	eb 0c                	jmp    80052d <vprintfmt+0x23f>
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052d:	83 c7 01             	add    $0x1,%edi
  800530:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800534:	0f be d0             	movsbl %al,%edx
  800537:	85 d2                	test   %edx,%edx
  800539:	74 23                	je     80055e <vprintfmt+0x270>
  80053b:	85 f6                	test   %esi,%esi
  80053d:	78 a1                	js     8004e0 <vprintfmt+0x1f2>
  80053f:	83 ee 01             	sub    $0x1,%esi
  800542:	79 9c                	jns    8004e0 <vprintfmt+0x1f2>
  800544:	89 df                	mov    %ebx,%edi
  800546:	8b 75 08             	mov    0x8(%ebp),%esi
  800549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	6a 20                	push   $0x20
  800554:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800556:	83 ef 01             	sub    $0x1,%edi
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x278>
  80055e:	89 df                	mov    %ebx,%edi
  800560:	8b 75 08             	mov    0x8(%ebp),%esi
  800563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800566:	85 ff                	test   %edi,%edi
  800568:	7f e4                	jg     80054e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056d:	e9 a2 fd ff ff       	jmp    800314 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800572:	83 fa 01             	cmp    $0x1,%edx
  800575:	7e 16                	jle    80058d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 08             	lea    0x8(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 50 04             	mov    0x4(%eax),%edx
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058b:	eb 32                	jmp    8005bf <vprintfmt+0x2d1>
	else if (lflag)
  80058d:	85 d2                	test   %edx,%edx
  80058f:	74 18                	je     8005a9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 c1                	mov    %eax,%ecx
  8005a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a7:	eb 16                	jmp    8005bf <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	89 c1                	mov    %eax,%ecx
  8005b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ce:	79 74                	jns    800644 <vprintfmt+0x356>
				putch('-', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 2d                	push   $0x2d
  8005d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005de:	f7 d8                	neg    %eax
  8005e0:	83 d2 00             	adc    $0x0,%edx
  8005e3:	f7 da                	neg    %edx
  8005e5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ed:	eb 55                	jmp    800644 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 83 fc ff ff       	call   80027a <getuint>
			base = 10;
  8005f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fc:	eb 46                	jmp    800644 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 74 fc ff ff       	call   80027a <getuint>
			base = 8;
  800606:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060b:	eb 37                	jmp    800644 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 30                	push   $0x30
  800613:	ff d6                	call   *%esi
			putch('x', putdat);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 78                	push   $0x78
  80061b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800630:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800635:	eb 0d                	jmp    800644 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 3b fc ff ff       	call   80027a <getuint>
			base = 16;
  80063f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800644:	83 ec 0c             	sub    $0xc,%esp
  800647:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064b:	57                   	push   %edi
  80064c:	ff 75 e0             	pushl  -0x20(%ebp)
  80064f:	51                   	push   %ecx
  800650:	52                   	push   %edx
  800651:	50                   	push   %eax
  800652:	89 da                	mov    %ebx,%edx
  800654:	89 f0                	mov    %esi,%eax
  800656:	e8 70 fb ff ff       	call   8001cb <printnum>
			break;
  80065b:	83 c4 20             	add    $0x20,%esp
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800661:	e9 ae fc ff ff       	jmp    800314 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	51                   	push   %ecx
  80066b:	ff d6                	call   *%esi
			break;
  80066d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800673:	e9 9c fc ff ff       	jmp    800314 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 25                	push   $0x25
  80067e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	eb 03                	jmp    800688 <vprintfmt+0x39a>
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068c:	75 f7                	jne    800685 <vprintfmt+0x397>
  80068e:	e9 81 fc ff ff       	jmp    800314 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800696:	5b                   	pop    %ebx
  800697:	5e                   	pop    %esi
  800698:	5f                   	pop    %edi
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 18             	sub    $0x18,%esp
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 26                	je     8006e2 <vsnprintf+0x47>
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	7e 22                	jle    8006e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c0:	ff 75 14             	pushl  0x14(%ebp)
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c9:	50                   	push   %eax
  8006ca:	68 b4 02 80 00       	push   $0x8002b4
  8006cf:	e8 1a fc ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 05                	jmp    8006e7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f2:	50                   	push   %eax
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	ff 75 08             	pushl  0x8(%ebp)
  8006fc:	e8 9a ff ff ff       	call   80069b <vsnprintf>
	va_end(ap);

	return rc;
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	b8 00 00 00 00       	mov    $0x0,%eax
  80070e:	eb 03                	jmp    800713 <strlen+0x10>
		n++;
  800710:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800713:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800717:	75 f7                	jne    800710 <strlen+0xd>
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
  800729:	eb 03                	jmp    80072e <strnlen+0x13>
		n++;
  80072b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072e:	39 c2                	cmp    %eax,%edx
  800730:	74 08                	je     80073a <strnlen+0x1f>
  800732:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800736:	75 f3                	jne    80072b <strnlen+0x10>
  800738:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800746:	89 c2                	mov    %eax,%edx
  800748:	83 c2 01             	add    $0x1,%edx
  80074b:	83 c1 01             	add    $0x1,%ecx
  80074e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800752:	88 5a ff             	mov    %bl,-0x1(%edx)
  800755:	84 db                	test   %bl,%bl
  800757:	75 ef                	jne    800748 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800759:	5b                   	pop    %ebx
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800763:	53                   	push   %ebx
  800764:	e8 9a ff ff ff       	call   800703 <strlen>
  800769:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	01 d8                	add    %ebx,%eax
  800771:	50                   	push   %eax
  800772:	e8 c5 ff ff ff       	call   80073c <strcpy>
	return dst;
}
  800777:	89 d8                	mov    %ebx,%eax
  800779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	56                   	push   %esi
  800782:	53                   	push   %ebx
  800783:	8b 75 08             	mov    0x8(%ebp),%esi
  800786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800789:	89 f3                	mov    %esi,%ebx
  80078b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078e:	89 f2                	mov    %esi,%edx
  800790:	eb 0f                	jmp    8007a1 <strncpy+0x23>
		*dst++ = *src;
  800792:	83 c2 01             	add    $0x1,%edx
  800795:	0f b6 01             	movzbl (%ecx),%eax
  800798:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079b:	80 39 01             	cmpb   $0x1,(%ecx)
  80079e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a1:	39 da                	cmp    %ebx,%edx
  8007a3:	75 ed                	jne    800792 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a5:	89 f0                	mov    %esi,%eax
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 21                	je     8007e0 <strlcpy+0x35>
  8007bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c3:	89 f2                	mov    %esi,%edx
  8007c5:	eb 09                	jmp    8007d0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d0:	39 c2                	cmp    %eax,%edx
  8007d2:	74 09                	je     8007dd <strlcpy+0x32>
  8007d4:	0f b6 19             	movzbl (%ecx),%ebx
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ec                	jne    8007c7 <strlcpy+0x1c>
  8007db:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e0:	29 f0                	sub    %esi,%eax
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ef:	eb 06                	jmp    8007f7 <strcmp+0x11>
		p++, q++;
  8007f1:	83 c1 01             	add    $0x1,%ecx
  8007f4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f7:	0f b6 01             	movzbl (%ecx),%eax
  8007fa:	84 c0                	test   %al,%al
  8007fc:	74 04                	je     800802 <strcmp+0x1c>
  8007fe:	3a 02                	cmp    (%edx),%al
  800800:	74 ef                	je     8007f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800802:	0f b6 c0             	movzbl %al,%eax
  800805:	0f b6 12             	movzbl (%edx),%edx
  800808:	29 d0                	sub    %edx,%eax
}
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	89 c3                	mov    %eax,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081b:	eb 06                	jmp    800823 <strncmp+0x17>
		n--, p++, q++;
  80081d:	83 c0 01             	add    $0x1,%eax
  800820:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800823:	39 d8                	cmp    %ebx,%eax
  800825:	74 15                	je     80083c <strncmp+0x30>
  800827:	0f b6 08             	movzbl (%eax),%ecx
  80082a:	84 c9                	test   %cl,%cl
  80082c:	74 04                	je     800832 <strncmp+0x26>
  80082e:	3a 0a                	cmp    (%edx),%cl
  800830:	74 eb                	je     80081d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	0f b6 12             	movzbl (%edx),%edx
  800838:	29 d0                	sub    %edx,%eax
  80083a:	eb 05                	jmp    800841 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084e:	eb 07                	jmp    800857 <strchr+0x13>
		if (*s == c)
  800850:	38 ca                	cmp    %cl,%dl
  800852:	74 0f                	je     800863 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	0f b6 10             	movzbl (%eax),%edx
  80085a:	84 d2                	test   %dl,%dl
  80085c:	75 f2                	jne    800850 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086f:	eb 03                	jmp    800874 <strfind+0xf>
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800877:	38 ca                	cmp    %cl,%dl
  800879:	74 04                	je     80087f <strfind+0x1a>
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f2                	jne    800871 <strfind+0xc>
			break;
	return (char *) s;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	74 36                	je     8008c7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 28                	jne    8008c1 <memset+0x40>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	75 23                	jne    8008c1 <memset+0x40>
		c &= 0xFF;
  80089e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a2:	89 d3                	mov    %edx,%ebx
  8008a4:	c1 e3 08             	shl    $0x8,%ebx
  8008a7:	89 d6                	mov    %edx,%esi
  8008a9:	c1 e6 18             	shl    $0x18,%esi
  8008ac:	89 d0                	mov    %edx,%eax
  8008ae:	c1 e0 10             	shl    $0x10,%eax
  8008b1:	09 f0                	or     %esi,%eax
  8008b3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b5:	89 d8                	mov    %ebx,%eax
  8008b7:	09 d0                	or     %edx,%eax
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
  8008bc:	fc                   	cld    
  8008bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bf:	eb 06                	jmp    8008c7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	fc                   	cld    
  8008c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c7:	89 f8                	mov    %edi,%eax
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dc:	39 c6                	cmp    %eax,%esi
  8008de:	73 35                	jae    800915 <memmove+0x47>
  8008e0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	73 2e                	jae    800915 <memmove+0x47>
		s += n;
		d += n;
  8008e7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 d6                	mov    %edx,%esi
  8008ec:	09 fe                	or     %edi,%esi
  8008ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f4:	75 13                	jne    800909 <memmove+0x3b>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 0e                	jne    800909 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fb:	83 ef 04             	sub    $0x4,%edi
  8008fe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800901:	c1 e9 02             	shr    $0x2,%ecx
  800904:	fd                   	std    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 09                	jmp    800912 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800909:	83 ef 01             	sub    $0x1,%edi
  80090c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090f:	fd                   	std    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800912:	fc                   	cld    
  800913:	eb 1d                	jmp    800932 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	89 f2                	mov    %esi,%edx
  800917:	09 c2                	or     %eax,%edx
  800919:	f6 c2 03             	test   $0x3,%dl
  80091c:	75 0f                	jne    80092d <memmove+0x5f>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 0a                	jne    80092d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800923:	c1 e9 02             	shr    $0x2,%ecx
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 05                	jmp    800932 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 87 ff ff ff       	call   8008ce <memmove>
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 c6                	mov    %eax,%esi
  800956:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800959:	eb 1a                	jmp    800975 <memcmp+0x2c>
		if (*s1 != *s2)
  80095b:	0f b6 08             	movzbl (%eax),%ecx
  80095e:	0f b6 1a             	movzbl (%edx),%ebx
  800961:	38 d9                	cmp    %bl,%cl
  800963:	74 0a                	je     80096f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800965:	0f b6 c1             	movzbl %cl,%eax
  800968:	0f b6 db             	movzbl %bl,%ebx
  80096b:	29 d8                	sub    %ebx,%eax
  80096d:	eb 0f                	jmp    80097e <memcmp+0x35>
		s1++, s2++;
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800975:	39 f0                	cmp    %esi,%eax
  800977:	75 e2                	jne    80095b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800989:	89 c1                	mov    %eax,%ecx
  80098b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800992:	eb 0a                	jmp    80099e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800994:	0f b6 10             	movzbl (%eax),%edx
  800997:	39 da                	cmp    %ebx,%edx
  800999:	74 07                	je     8009a2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	39 c8                	cmp    %ecx,%eax
  8009a0:	72 f2                	jb     800994 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	eb 03                	jmp    8009b6 <strtol+0x11>
		s++;
  8009b3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b6:	0f b6 01             	movzbl (%ecx),%eax
  8009b9:	3c 20                	cmp    $0x20,%al
  8009bb:	74 f6                	je     8009b3 <strtol+0xe>
  8009bd:	3c 09                	cmp    $0x9,%al
  8009bf:	74 f2                	je     8009b3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c1:	3c 2b                	cmp    $0x2b,%al
  8009c3:	75 0a                	jne    8009cf <strtol+0x2a>
		s++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cd:	eb 11                	jmp    8009e0 <strtol+0x3b>
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d4:	3c 2d                	cmp    $0x2d,%al
  8009d6:	75 08                	jne    8009e0 <strtol+0x3b>
		s++, neg = 1;
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e6:	75 15                	jne    8009fd <strtol+0x58>
  8009e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009eb:	75 10                	jne    8009fd <strtol+0x58>
  8009ed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f1:	75 7c                	jne    800a6f <strtol+0xca>
		s += 2, base = 16;
  8009f3:	83 c1 02             	add    $0x2,%ecx
  8009f6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fb:	eb 16                	jmp    800a13 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fd:	85 db                	test   %ebx,%ebx
  8009ff:	75 12                	jne    800a13 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a01:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a06:	80 39 30             	cmpb   $0x30,(%ecx)
  800a09:	75 08                	jne    800a13 <strtol+0x6e>
		s++, base = 8;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1b:	0f b6 11             	movzbl (%ecx),%edx
  800a1e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 09             	cmp    $0x9,%bl
  800a26:	77 08                	ja     800a30 <strtol+0x8b>
			dig = *s - '0';
  800a28:	0f be d2             	movsbl %dl,%edx
  800a2b:	83 ea 30             	sub    $0x30,%edx
  800a2e:	eb 22                	jmp    800a52 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 08                	ja     800a42 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3a:	0f be d2             	movsbl %dl,%edx
  800a3d:	83 ea 57             	sub    $0x57,%edx
  800a40:	eb 10                	jmp    800a52 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 16                	ja     800a62 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4c:	0f be d2             	movsbl %dl,%edx
  800a4f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a55:	7d 0b                	jge    800a62 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a60:	eb b9                	jmp    800a1b <strtol+0x76>

	if (endptr)
  800a62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a66:	74 0d                	je     800a75 <strtol+0xd0>
		*endptr = (char *) s;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	89 0e                	mov    %ecx,(%esi)
  800a6d:	eb 06                	jmp    800a75 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	74 98                	je     800a0b <strtol+0x66>
  800a73:	eb 9e                	jmp    800a13 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	f7 da                	neg    %edx
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	0f 45 c2             	cmovne %edx,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab1:	89 d1                	mov    %edx,%ecx
  800ab3:	89 d3                	mov    %edx,%ebx
  800ab5:	89 d7                	mov    %edx,%edi
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	89 cb                	mov    %ecx,%ebx
  800ad8:	89 cf                	mov    %ecx,%edi
  800ada:	89 ce                	mov    %ecx,%esi
  800adc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	7e 17                	jle    800af9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	50                   	push   %eax
  800ae6:	6a 03                	push   $0x3
  800ae8:	68 9f 27 80 00       	push   $0x80279f
  800aed:	6a 23                	push   $0x23
  800aef:	68 bc 27 80 00       	push   $0x8027bc
  800af4:	e8 b2 15 00 00       	call   8020ab <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_yield>:

void
sys_yield(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	be 00 00 00 00       	mov    $0x0,%esi
  800b4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	89 f7                	mov    %esi,%edi
  800b5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 04                	push   $0x4
  800b69:	68 9f 27 80 00       	push   $0x80279f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 bc 27 80 00       	push   $0x8027bc
  800b75:	e8 31 15 00 00       	call   8020ab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 05                	push   $0x5
  800bab:	68 9f 27 80 00       	push   $0x80279f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 bc 27 80 00       	push   $0x8027bc
  800bb7:	e8 ef 14 00 00       	call   8020ab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 df                	mov    %ebx,%edi
  800bdf:	89 de                	mov    %ebx,%esi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 06                	push   $0x6
  800bed:	68 9f 27 80 00       	push   $0x80279f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 bc 27 80 00       	push   $0x8027bc
  800bf9:	e8 ad 14 00 00       	call   8020ab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 08 00 00 00       	mov    $0x8,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 08                	push   $0x8
  800c2f:	68 9f 27 80 00       	push   $0x80279f
  800c34:	6a 23                	push   $0x23
  800c36:	68 bc 27 80 00       	push   $0x8027bc
  800c3b:	e8 6b 14 00 00       	call   8020ab <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 09                	push   $0x9
  800c71:	68 9f 27 80 00       	push   $0x80279f
  800c76:	6a 23                	push   $0x23
  800c78:	68 bc 27 80 00       	push   $0x8027bc
  800c7d:	e8 29 14 00 00       	call   8020ab <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 0a                	push   $0xa
  800cb3:	68 9f 27 80 00       	push   $0x80279f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 bc 27 80 00       	push   $0x8027bc
  800cbf:	e8 e7 13 00 00       	call   8020ab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	be 00 00 00 00       	mov    $0x0,%esi
  800cd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 cb                	mov    %ecx,%ebx
  800d07:	89 cf                	mov    %ecx,%edi
  800d09:	89 ce                	mov    %ecx,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 0d                	push   $0xd
  800d17:	68 9f 27 80 00       	push   $0x80279f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 bc 27 80 00       	push   $0x8027bc
  800d23:	e8 83 13 00 00       	call   8020ab <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 cb                	mov    %ecx,%ebx
  800d45:	89 cf                	mov    %ecx,%edi
  800d47:	89 ce                	mov    %ecx,%esi
  800d49:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 cb                	mov    %ecx,%ebx
  800d65:	89 cf                	mov    %ecx,%edi
  800d67:	89 ce                	mov    %ecx,%esi
  800d69:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7b:	b8 10 00 00 00       	mov    $0x10,%eax
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 cb                	mov    %ecx,%ebx
  800d85:	89 cf                	mov    %ecx,%edi
  800d87:	89 ce                	mov    %ecx,%esi
  800d89:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	53                   	push   %ebx
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d9a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d9c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800da0:	74 11                	je     800db3 <pgfault+0x23>
  800da2:	89 d8                	mov    %ebx,%eax
  800da4:	c1 e8 0c             	shr    $0xc,%eax
  800da7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dae:	f6 c4 08             	test   $0x8,%ah
  800db1:	75 14                	jne    800dc7 <pgfault+0x37>
		panic("faulting access");
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	68 ca 27 80 00       	push   $0x8027ca
  800dbb:	6a 1f                	push   $0x1f
  800dbd:	68 da 27 80 00       	push   $0x8027da
  800dc2:	e8 e4 12 00 00       	call   8020ab <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	6a 07                	push   $0x7
  800dcc:	68 00 f0 7f 00       	push   $0x7ff000
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 67 fd ff ff       	call   800b3f <sys_page_alloc>
	if (r < 0) {
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	79 12                	jns    800df1 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ddf:	50                   	push   %eax
  800de0:	68 e5 27 80 00       	push   $0x8027e5
  800de5:	6a 2d                	push   $0x2d
  800de7:	68 da 27 80 00       	push   $0x8027da
  800dec:	e8 ba 12 00 00       	call   8020ab <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800df1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 00 10 00 00       	push   $0x1000
  800dff:	53                   	push   %ebx
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	e8 2c fb ff ff       	call   800936 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e0a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 62 fd ff ff       	call   800b82 <sys_page_map>
	if (r < 0) {
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 12                	jns    800e39 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 e5 27 80 00       	push   $0x8027e5
  800e2d:	6a 34                	push   $0x34
  800e2f:	68 da 27 80 00       	push   $0x8027da
  800e34:	e8 72 12 00 00       	call   8020ab <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	6a 00                	push   $0x0
  800e43:	e8 7c fd ff ff       	call   800bc4 <sys_page_unmap>
	if (r < 0) {
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 12                	jns    800e61 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e4f:	50                   	push   %eax
  800e50:	68 e5 27 80 00       	push   $0x8027e5
  800e55:	6a 38                	push   $0x38
  800e57:	68 da 27 80 00       	push   $0x8027da
  800e5c:	e8 4a 12 00 00       	call   8020ab <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e6f:	68 90 0d 80 00       	push   $0x800d90
  800e74:	e8 78 12 00 00       	call   8020f1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e79:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7e:	cd 30                	int    $0x30
  800e80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	79 17                	jns    800ea1 <fork+0x3b>
		panic("fork fault %e");
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 fe 27 80 00       	push   $0x8027fe
  800e92:	68 85 00 00 00       	push   $0x85
  800e97:	68 da 27 80 00       	push   $0x8027da
  800e9c:	e8 0a 12 00 00       	call   8020ab <_panic>
  800ea1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea7:	75 24                	jne    800ecd <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea9:	e8 53 fc ff ff       	call   800b01 <sys_getenvid>
  800eae:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800eb9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebe:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	e9 64 01 00 00       	jmp    801031 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	68 00 f0 bf ee       	push   $0xeebff000
  800ed7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eda:	e8 60 fc ff ff       	call   800b3f <sys_page_alloc>
  800edf:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	c1 e8 16             	shr    $0x16,%eax
  800eec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef3:	a8 01                	test   $0x1,%al
  800ef5:	0f 84 fc 00 00 00    	je     800ff7 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	c1 e8 0c             	shr    $0xc,%eax
  800f00:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f07:	f6 c2 01             	test   $0x1,%dl
  800f0a:	0f 84 e7 00 00 00    	je     800ff7 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f10:	89 c6                	mov    %eax,%esi
  800f12:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f15:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1c:	f6 c6 04             	test   $0x4,%dh
  800f1f:	74 39                	je     800f5a <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f21:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f30:	50                   	push   %eax
  800f31:	56                   	push   %esi
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	6a 00                	push   $0x0
  800f36:	e8 47 fc ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	0f 89 b1 00 00 00    	jns    800ff7 <fork+0x191>
		    	panic("sys page map fault %e");
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 0c 28 80 00       	push   $0x80280c
  800f4e:	6a 55                	push   $0x55
  800f50:	68 da 27 80 00       	push   $0x8027da
  800f55:	e8 51 11 00 00       	call   8020ab <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f61:	f6 c2 02             	test   $0x2,%dl
  800f64:	75 0c                	jne    800f72 <fork+0x10c>
  800f66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6d:	f6 c4 08             	test   $0x8,%ah
  800f70:	74 5b                	je     800fcd <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	68 05 08 00 00       	push   $0x805
  800f7a:	56                   	push   %esi
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 fe fb ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 14                	jns    800f9f <fork+0x139>
		    	panic("sys page map fault %e");
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	68 0c 28 80 00       	push   $0x80280c
  800f93:	6a 5c                	push   $0x5c
  800f95:	68 da 27 80 00       	push   $0x8027da
  800f9a:	e8 0c 11 00 00       	call   8020ab <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	68 05 08 00 00       	push   $0x805
  800fa7:	56                   	push   %esi
  800fa8:	6a 00                	push   $0x0
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 d0 fb ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 3e                	jns    800ff7 <fork+0x191>
		    	panic("sys page map fault %e");
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 0c 28 80 00       	push   $0x80280c
  800fc1:	6a 60                	push   $0x60
  800fc3:	68 da 27 80 00       	push   $0x8027da
  800fc8:	e8 de 10 00 00       	call   8020ab <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	6a 05                	push   $0x5
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 a6 fb ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800fdc:	83 c4 20             	add    $0x20,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 14                	jns    800ff7 <fork+0x191>
		    	panic("sys page map fault %e");
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	68 0c 28 80 00       	push   $0x80280c
  800feb:	6a 65                	push   $0x65
  800fed:	68 da 27 80 00       	push   $0x8027da
  800ff2:	e8 b4 10 00 00       	call   8020ab <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801003:	0f 85 de fe ff ff    	jne    800ee7 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801009:	a1 04 40 80 00       	mov    0x804004,%eax
  80100e:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	50                   	push   %eax
  801018:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80101b:	57                   	push   %edi
  80101c:	e8 69 fc ff ff       	call   800c8a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	6a 02                	push   $0x2
  801026:	57                   	push   %edi
  801027:	e8 da fb ff ff       	call   800c06 <sys_env_set_status>
	
	return envid;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sfork>:

envid_t
sfork(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801051:	68 ea 00 80 00       	push   $0x8000ea
  801056:	e8 d5 fc ff ff       	call   800d30 <sys_thread_create>

	return id;
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801063:	ff 75 08             	pushl  0x8(%ebp)
  801066:	e8 e5 fc ff ff       	call   800d50 <sys_thread_free>
}
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801076:	ff 75 08             	pushl  0x8(%ebp)
  801079:	e8 f2 fc ff ff       	call   800d70 <sys_thread_join>
}
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	8b 75 08             	mov    0x8(%ebp),%esi
  80108b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	6a 07                	push   $0x7
  801093:	6a 00                	push   $0x0
  801095:	56                   	push   %esi
  801096:	e8 a4 fa ff ff       	call   800b3f <sys_page_alloc>
	if (r < 0) {
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 15                	jns    8010b7 <queue_append+0x34>
		panic("%e\n", r);
  8010a2:	50                   	push   %eax
  8010a3:	68 52 28 80 00       	push   $0x802852
  8010a8:	68 d5 00 00 00       	push   $0xd5
  8010ad:	68 da 27 80 00       	push   $0x8027da
  8010b2:	e8 f4 0f 00 00       	call   8020ab <_panic>
	}	

	wt->envid = envid;
  8010b7:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8010bd:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010c0:	75 13                	jne    8010d5 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8010c2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010c9:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010d0:	00 00 00 
  8010d3:	eb 1b                	jmp    8010f0 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8010d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8010d8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8010df:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010e6:	00 00 00 
		queue->last = wt;
  8010e9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8010f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801100:	8b 02                	mov    (%edx),%eax
  801102:	85 c0                	test   %eax,%eax
  801104:	75 17                	jne    80111d <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	68 22 28 80 00       	push   $0x802822
  80110e:	68 ec 00 00 00       	push   $0xec
  801113:	68 da 27 80 00       	push   $0x8027da
  801118:	e8 8e 0f 00 00       	call   8020ab <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80111d:	8b 48 04             	mov    0x4(%eax),%ecx
  801120:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801122:	8b 00                	mov    (%eax),%eax
}
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	53                   	push   %ebx
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801130:	b8 01 00 00 00       	mov    $0x1,%eax
  801135:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 45                	je     801181 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80113c:	e8 c0 f9 ff ff       	call   800b01 <sys_getenvid>
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	83 c3 04             	add    $0x4,%ebx
  801147:	53                   	push   %ebx
  801148:	50                   	push   %eax
  801149:	e8 35 ff ff ff       	call   801083 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80114e:	e8 ae f9 ff ff       	call   800b01 <sys_getenvid>
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	6a 04                	push   $0x4
  801158:	50                   	push   %eax
  801159:	e8 a8 fa ff ff       	call   800c06 <sys_env_set_status>

		if (r < 0) {
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	79 15                	jns    80117a <mutex_lock+0x54>
			panic("%e\n", r);
  801165:	50                   	push   %eax
  801166:	68 52 28 80 00       	push   $0x802852
  80116b:	68 02 01 00 00       	push   $0x102
  801170:	68 da 27 80 00       	push   $0x8027da
  801175:	e8 31 0f 00 00       	call   8020ab <_panic>
		}
		sys_yield();
  80117a:	e8 a1 f9 ff ff       	call   800b20 <sys_yield>
  80117f:	eb 08                	jmp    801189 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801181:	e8 7b f9 ff ff       	call   800b01 <sys_getenvid>
  801186:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	53                   	push   %ebx
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801198:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80119c:	74 36                	je     8011d4 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	8d 43 04             	lea    0x4(%ebx),%eax
  8011a4:	50                   	push   %eax
  8011a5:	e8 4d ff ff ff       	call   8010f7 <queue_pop>
  8011aa:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	6a 02                	push   $0x2
  8011b2:	50                   	push   %eax
  8011b3:	e8 4e fa ff ff       	call   800c06 <sys_env_set_status>
		if (r < 0) {
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	79 1d                	jns    8011dc <mutex_unlock+0x4e>
			panic("%e\n", r);
  8011bf:	50                   	push   %eax
  8011c0:	68 52 28 80 00       	push   $0x802852
  8011c5:	68 16 01 00 00       	push   $0x116
  8011ca:	68 da 27 80 00       	push   $0x8027da
  8011cf:	e8 d7 0e 00 00       	call   8020ab <_panic>
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d9:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8011dc:	e8 3f f9 ff ff       	call   800b20 <sys_yield>
}
  8011e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8011f0:	e8 0c f9 ff ff       	call   800b01 <sys_getenvid>
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	6a 07                	push   $0x7
  8011fa:	53                   	push   %ebx
  8011fb:	50                   	push   %eax
  8011fc:	e8 3e f9 ff ff       	call   800b3f <sys_page_alloc>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	79 15                	jns    80121d <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801208:	50                   	push   %eax
  801209:	68 3d 28 80 00       	push   $0x80283d
  80120e:	68 23 01 00 00       	push   $0x123
  801213:	68 da 27 80 00       	push   $0x8027da
  801218:	e8 8e 0e 00 00       	call   8020ab <_panic>
	}	
	mtx->locked = 0;
  80121d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801223:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80122a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801231:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801245:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801248:	eb 20                	jmp    80126a <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80124a:	83 ec 0c             	sub    $0xc,%esp
  80124d:	56                   	push   %esi
  80124e:	e8 a4 fe ff ff       	call   8010f7 <queue_pop>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	6a 02                	push   $0x2
  801258:	50                   	push   %eax
  801259:	e8 a8 f9 ff ff       	call   800c06 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80125e:	8b 43 04             	mov    0x4(%ebx),%eax
  801261:	8b 40 04             	mov    0x4(%eax),%eax
  801264:	89 43 04             	mov    %eax,0x4(%ebx)
  801267:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80126a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80126e:	75 da                	jne    80124a <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	68 00 10 00 00       	push   $0x1000
  801278:	6a 00                	push   $0x0
  80127a:	53                   	push   %ebx
  80127b:	e8 01 f6 ff ff       	call   800881 <memset>
	mtx = NULL;
}
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	8b 75 08             	mov    0x8(%ebp),%esi
  801292:	8b 45 0c             	mov    0xc(%ebp),%eax
  801295:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801298:	85 c0                	test   %eax,%eax
  80129a:	75 12                	jne    8012ae <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80129c:	83 ec 0c             	sub    $0xc,%esp
  80129f:	68 00 00 c0 ee       	push   $0xeec00000
  8012a4:	e8 46 fa ff ff       	call   800cef <sys_ipc_recv>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	eb 0c                	jmp    8012ba <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	50                   	push   %eax
  8012b2:	e8 38 fa ff ff       	call   800cef <sys_ipc_recv>
  8012b7:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8012ba:	85 f6                	test   %esi,%esi
  8012bc:	0f 95 c1             	setne  %cl
  8012bf:	85 db                	test   %ebx,%ebx
  8012c1:	0f 95 c2             	setne  %dl
  8012c4:	84 d1                	test   %dl,%cl
  8012c6:	74 09                	je     8012d1 <ipc_recv+0x47>
  8012c8:	89 c2                	mov    %eax,%edx
  8012ca:	c1 ea 1f             	shr    $0x1f,%edx
  8012cd:	84 d2                	test   %dl,%dl
  8012cf:	75 2d                	jne    8012fe <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8012d1:	85 f6                	test   %esi,%esi
  8012d3:	74 0d                	je     8012e2 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8012d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012da:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8012e0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8012e2:	85 db                	test   %ebx,%ebx
  8012e4:	74 0d                	je     8012f3 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8012e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8012eb:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8012f1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8012f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f8:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8012fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801311:	8b 75 0c             	mov    0xc(%ebp),%esi
  801314:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801317:	85 db                	test   %ebx,%ebx
  801319:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80131e:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801321:	ff 75 14             	pushl  0x14(%ebp)
  801324:	53                   	push   %ebx
  801325:	56                   	push   %esi
  801326:	57                   	push   %edi
  801327:	e8 a0 f9 ff ff       	call   800ccc <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	c1 ea 1f             	shr    $0x1f,%edx
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	84 d2                	test   %dl,%dl
  801336:	74 17                	je     80134f <ipc_send+0x4a>
  801338:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80133b:	74 12                	je     80134f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80133d:	50                   	push   %eax
  80133e:	68 56 28 80 00       	push   $0x802856
  801343:	6a 47                	push   $0x47
  801345:	68 64 28 80 00       	push   $0x802864
  80134a:	e8 5c 0d 00 00       	call   8020ab <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80134f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801352:	75 07                	jne    80135b <ipc_send+0x56>
			sys_yield();
  801354:	e8 c7 f7 ff ff       	call   800b20 <sys_yield>
  801359:	eb c6                	jmp    801321 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 c2                	jne    801321 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80135f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801372:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  801378:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80137e:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  801384:	39 ca                	cmp    %ecx,%edx
  801386:	75 13                	jne    80139b <ipc_find_env+0x34>
			return envs[i].env_id;
  801388:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80138e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801393:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801399:	eb 0f                	jmp    8013aa <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80139b:	83 c0 01             	add    $0x1,%eax
  80139e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013a3:	75 cd                	jne    801372 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    

008013d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	c1 ea 16             	shr    $0x16,%edx
  8013e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ea:	f6 c2 01             	test   $0x1,%dl
  8013ed:	74 11                	je     801400 <fd_alloc+0x2d>
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	c1 ea 0c             	shr    $0xc,%edx
  8013f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fb:	f6 c2 01             	test   $0x1,%dl
  8013fe:	75 09                	jne    801409 <fd_alloc+0x36>
			*fd_store = fd;
  801400:	89 01                	mov    %eax,(%ecx)
			return 0;
  801402:	b8 00 00 00 00       	mov    $0x0,%eax
  801407:	eb 17                	jmp    801420 <fd_alloc+0x4d>
  801409:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80140e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801413:	75 c9                	jne    8013de <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801415:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80141b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801428:	83 f8 1f             	cmp    $0x1f,%eax
  80142b:	77 36                	ja     801463 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80142d:	c1 e0 0c             	shl    $0xc,%eax
  801430:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801435:	89 c2                	mov    %eax,%edx
  801437:	c1 ea 16             	shr    $0x16,%edx
  80143a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801441:	f6 c2 01             	test   $0x1,%dl
  801444:	74 24                	je     80146a <fd_lookup+0x48>
  801446:	89 c2                	mov    %eax,%edx
  801448:	c1 ea 0c             	shr    $0xc,%edx
  80144b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801452:	f6 c2 01             	test   $0x1,%dl
  801455:	74 1a                	je     801471 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801457:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145a:	89 02                	mov    %eax,(%edx)
	return 0;
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
  801461:	eb 13                	jmp    801476 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801468:	eb 0c                	jmp    801476 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146f:	eb 05                	jmp    801476 <fd_lookup+0x54>
  801471:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801481:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801486:	eb 13                	jmp    80149b <dev_lookup+0x23>
  801488:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80148b:	39 08                	cmp    %ecx,(%eax)
  80148d:	75 0c                	jne    80149b <dev_lookup+0x23>
			*dev = devtab[i];
  80148f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801492:	89 01                	mov    %eax,(%ecx)
			return 0;
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
  801499:	eb 31                	jmp    8014cc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80149b:	8b 02                	mov    (%edx),%eax
  80149d:	85 c0                	test   %eax,%eax
  80149f:	75 e7                	jne    801488 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	51                   	push   %ecx
  8014b0:	50                   	push   %eax
  8014b1:	68 70 28 80 00       	push   $0x802870
  8014b6:	e8 fc ec ff ff       	call   8001b7 <cprintf>
	*dev = 0;
  8014bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 10             	sub    $0x10,%esp
  8014d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014e6:	c1 e8 0c             	shr    $0xc,%eax
  8014e9:	50                   	push   %eax
  8014ea:	e8 33 ff ff ff       	call   801422 <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 05                	js     8014fb <fd_close+0x2d>
	    || fd != fd2)
  8014f6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f9:	74 0c                	je     801507 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014fb:	84 db                	test   %bl,%bl
  8014fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801502:	0f 44 c2             	cmove  %edx,%eax
  801505:	eb 41                	jmp    801548 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	ff 36                	pushl  (%esi)
  801510:	e8 63 ff ff ff       	call   801478 <dev_lookup>
  801515:	89 c3                	mov    %eax,%ebx
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 1a                	js     801538 <fd_close+0x6a>
		if (dev->dev_close)
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801524:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801529:	85 c0                	test   %eax,%eax
  80152b:	74 0b                	je     801538 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	56                   	push   %esi
  801531:	ff d0                	call   *%eax
  801533:	89 c3                	mov    %eax,%ebx
  801535:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	56                   	push   %esi
  80153c:	6a 00                	push   $0x0
  80153e:	e8 81 f6 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	89 d8                	mov    %ebx,%eax
}
  801548:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	ff 75 08             	pushl  0x8(%ebp)
  80155c:	e8 c1 fe ff ff       	call   801422 <fd_lookup>
  801561:	83 c4 08             	add    $0x8,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 10                	js     801578 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	6a 01                	push   $0x1
  80156d:	ff 75 f4             	pushl  -0xc(%ebp)
  801570:	e8 59 ff ff ff       	call   8014ce <fd_close>
  801575:	83 c4 10             	add    $0x10,%esp
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <close_all>:

void
close_all(void)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801581:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	53                   	push   %ebx
  80158a:	e8 c0 ff ff ff       	call   80154f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80158f:	83 c3 01             	add    $0x1,%ebx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	83 fb 20             	cmp    $0x20,%ebx
  801598:	75 ec                	jne    801586 <close_all+0xc>
		close(i);
}
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	57                   	push   %edi
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 2c             	sub    $0x2c,%esp
  8015a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	ff 75 08             	pushl  0x8(%ebp)
  8015b2:	e8 6b fe ff ff       	call   801422 <fd_lookup>
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	0f 88 c1 00 00 00    	js     801683 <dup+0xe4>
		return r;
	close(newfdnum);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	56                   	push   %esi
  8015c6:	e8 84 ff ff ff       	call   80154f <close>

	newfd = INDEX2FD(newfdnum);
  8015cb:	89 f3                	mov    %esi,%ebx
  8015cd:	c1 e3 0c             	shl    $0xc,%ebx
  8015d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015d6:	83 c4 04             	add    $0x4,%esp
  8015d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015dc:	e8 db fd ff ff       	call   8013bc <fd2data>
  8015e1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015e3:	89 1c 24             	mov    %ebx,(%esp)
  8015e6:	e8 d1 fd ff ff       	call   8013bc <fd2data>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015f1:	89 f8                	mov    %edi,%eax
  8015f3:	c1 e8 16             	shr    $0x16,%eax
  8015f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015fd:	a8 01                	test   $0x1,%al
  8015ff:	74 37                	je     801638 <dup+0x99>
  801601:	89 f8                	mov    %edi,%eax
  801603:	c1 e8 0c             	shr    $0xc,%eax
  801606:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160d:	f6 c2 01             	test   $0x1,%dl
  801610:	74 26                	je     801638 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801612:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	25 07 0e 00 00       	and    $0xe07,%eax
  801621:	50                   	push   %eax
  801622:	ff 75 d4             	pushl  -0x2c(%ebp)
  801625:	6a 00                	push   $0x0
  801627:	57                   	push   %edi
  801628:	6a 00                	push   $0x0
  80162a:	e8 53 f5 ff ff       	call   800b82 <sys_page_map>
  80162f:	89 c7                	mov    %eax,%edi
  801631:	83 c4 20             	add    $0x20,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 2e                	js     801666 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801638:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80163b:	89 d0                	mov    %edx,%eax
  80163d:	c1 e8 0c             	shr    $0xc,%eax
  801640:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	25 07 0e 00 00       	and    $0xe07,%eax
  80164f:	50                   	push   %eax
  801650:	53                   	push   %ebx
  801651:	6a 00                	push   $0x0
  801653:	52                   	push   %edx
  801654:	6a 00                	push   $0x0
  801656:	e8 27 f5 ff ff       	call   800b82 <sys_page_map>
  80165b:	89 c7                	mov    %eax,%edi
  80165d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801660:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801662:	85 ff                	test   %edi,%edi
  801664:	79 1d                	jns    801683 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	53                   	push   %ebx
  80166a:	6a 00                	push   $0x0
  80166c:	e8 53 f5 ff ff       	call   800bc4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	ff 75 d4             	pushl  -0x2c(%ebp)
  801677:	6a 00                	push   $0x0
  801679:	e8 46 f5 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	89 f8                	mov    %edi,%eax
}
  801683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5f                   	pop    %edi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 14             	sub    $0x14,%esp
  801692:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801695:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	53                   	push   %ebx
  80169a:	e8 83 fd ff ff       	call   801422 <fd_lookup>
  80169f:	83 c4 08             	add    $0x8,%esp
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 70                	js     801718 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	ff 30                	pushl  (%eax)
  8016b4:	e8 bf fd ff ff       	call   801478 <dev_lookup>
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 4f                	js     80170f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c3:	8b 42 08             	mov    0x8(%edx),%eax
  8016c6:	83 e0 03             	and    $0x3,%eax
  8016c9:	83 f8 01             	cmp    $0x1,%eax
  8016cc:	75 24                	jne    8016f2 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	53                   	push   %ebx
  8016dd:	50                   	push   %eax
  8016de:	68 b1 28 80 00       	push   $0x8028b1
  8016e3:	e8 cf ea ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f0:	eb 26                	jmp    801718 <read+0x8d>
	}
	if (!dev->dev_read)
  8016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f5:	8b 40 08             	mov    0x8(%eax),%eax
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	74 17                	je     801713 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	ff 75 10             	pushl  0x10(%ebp)
  801702:	ff 75 0c             	pushl  0xc(%ebp)
  801705:	52                   	push   %edx
  801706:	ff d0                	call   *%eax
  801708:	89 c2                	mov    %eax,%edx
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	eb 09                	jmp    801718 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170f:	89 c2                	mov    %eax,%edx
  801711:	eb 05                	jmp    801718 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801713:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801718:	89 d0                	mov    %edx,%eax
  80171a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	57                   	push   %edi
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 0c             	sub    $0xc,%esp
  801728:	8b 7d 08             	mov    0x8(%ebp),%edi
  80172b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801733:	eb 21                	jmp    801756 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	89 f0                	mov    %esi,%eax
  80173a:	29 d8                	sub    %ebx,%eax
  80173c:	50                   	push   %eax
  80173d:	89 d8                	mov    %ebx,%eax
  80173f:	03 45 0c             	add    0xc(%ebp),%eax
  801742:	50                   	push   %eax
  801743:	57                   	push   %edi
  801744:	e8 42 ff ff ff       	call   80168b <read>
		if (m < 0)
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 10                	js     801760 <readn+0x41>
			return m;
		if (m == 0)
  801750:	85 c0                	test   %eax,%eax
  801752:	74 0a                	je     80175e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801754:	01 c3                	add    %eax,%ebx
  801756:	39 f3                	cmp    %esi,%ebx
  801758:	72 db                	jb     801735 <readn+0x16>
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	eb 02                	jmp    801760 <readn+0x41>
  80175e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801760:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5f                   	pop    %edi
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	53                   	push   %ebx
  80176c:	83 ec 14             	sub    $0x14,%esp
  80176f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801772:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	53                   	push   %ebx
  801777:	e8 a6 fc ff ff       	call   801422 <fd_lookup>
  80177c:	83 c4 08             	add    $0x8,%esp
  80177f:	89 c2                	mov    %eax,%edx
  801781:	85 c0                	test   %eax,%eax
  801783:	78 6b                	js     8017f0 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178b:	50                   	push   %eax
  80178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178f:	ff 30                	pushl  (%eax)
  801791:	e8 e2 fc ff ff       	call   801478 <dev_lookup>
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 4a                	js     8017e7 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a4:	75 24                	jne    8017ca <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ab:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017b1:	83 ec 04             	sub    $0x4,%esp
  8017b4:	53                   	push   %ebx
  8017b5:	50                   	push   %eax
  8017b6:	68 cd 28 80 00       	push   $0x8028cd
  8017bb:	e8 f7 e9 ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c8:	eb 26                	jmp    8017f0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d0:	85 d2                	test   %edx,%edx
  8017d2:	74 17                	je     8017eb <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	ff 75 10             	pushl  0x10(%ebp)
  8017da:	ff 75 0c             	pushl  0xc(%ebp)
  8017dd:	50                   	push   %eax
  8017de:	ff d2                	call   *%edx
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	eb 09                	jmp    8017f0 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	eb 05                	jmp    8017f0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017f0:	89 d0                	mov    %edx,%eax
  8017f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	ff 75 08             	pushl  0x8(%ebp)
  801804:	e8 19 fc ff ff       	call   801422 <fd_lookup>
  801809:	83 c4 08             	add    $0x8,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 0e                	js     80181e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801810:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801813:	8b 55 0c             	mov    0xc(%ebp),%edx
  801816:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 14             	sub    $0x14,%esp
  801827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	53                   	push   %ebx
  80182f:	e8 ee fb ff ff       	call   801422 <fd_lookup>
  801834:	83 c4 08             	add    $0x8,%esp
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 68                	js     8018a5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801847:	ff 30                	pushl  (%eax)
  801849:	e8 2a fc ff ff       	call   801478 <dev_lookup>
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	78 47                	js     80189c <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801858:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185c:	75 24                	jne    801882 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80185e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801863:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801869:	83 ec 04             	sub    $0x4,%esp
  80186c:	53                   	push   %ebx
  80186d:	50                   	push   %eax
  80186e:	68 90 28 80 00       	push   $0x802890
  801873:	e8 3f e9 ff ff       	call   8001b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801880:	eb 23                	jmp    8018a5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801882:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801885:	8b 52 18             	mov    0x18(%edx),%edx
  801888:	85 d2                	test   %edx,%edx
  80188a:	74 14                	je     8018a0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	50                   	push   %eax
  801893:	ff d2                	call   *%edx
  801895:	89 c2                	mov    %eax,%edx
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	eb 09                	jmp    8018a5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	eb 05                	jmp    8018a5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a5:	89 d0                	mov    %edx,%eax
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 14             	sub    $0x14,%esp
  8018b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	ff 75 08             	pushl  0x8(%ebp)
  8018bd:	e8 60 fb ff ff       	call   801422 <fd_lookup>
  8018c2:	83 c4 08             	add    $0x8,%esp
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 58                	js     801923 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d1:	50                   	push   %eax
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	ff 30                	pushl  (%eax)
  8018d7:	e8 9c fb ff ff       	call   801478 <dev_lookup>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 37                	js     80191a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018ea:	74 32                	je     80191e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f6:	00 00 00 
	stat->st_isdir = 0;
  8018f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801900:	00 00 00 
	stat->st_dev = dev;
  801903:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	53                   	push   %ebx
  80190d:	ff 75 f0             	pushl  -0x10(%ebp)
  801910:	ff 50 14             	call   *0x14(%eax)
  801913:	89 c2                	mov    %eax,%edx
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	eb 09                	jmp    801923 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	eb 05                	jmp    801923 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80191e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801923:	89 d0                	mov    %edx,%eax
  801925:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	56                   	push   %esi
  80192e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	6a 00                	push   $0x0
  801934:	ff 75 08             	pushl  0x8(%ebp)
  801937:	e8 e3 01 00 00       	call   801b1f <open>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	78 1b                	js     801960 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	ff 75 0c             	pushl  0xc(%ebp)
  80194b:	50                   	push   %eax
  80194c:	e8 5b ff ff ff       	call   8018ac <fstat>
  801951:	89 c6                	mov    %eax,%esi
	close(fd);
  801953:	89 1c 24             	mov    %ebx,(%esp)
  801956:	e8 f4 fb ff ff       	call   80154f <close>
	return r;
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	89 f0                	mov    %esi,%eax
}
  801960:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	89 c6                	mov    %eax,%esi
  80196e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801970:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801977:	75 12                	jne    80198b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	6a 01                	push   $0x1
  80197e:	e8 e4 f9 ff ff       	call   801367 <ipc_find_env>
  801983:	a3 00 40 80 00       	mov    %eax,0x804000
  801988:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198b:	6a 07                	push   $0x7
  80198d:	68 00 50 80 00       	push   $0x805000
  801992:	56                   	push   %esi
  801993:	ff 35 00 40 80 00    	pushl  0x804000
  801999:	e8 67 f9 ff ff       	call   801305 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80199e:	83 c4 0c             	add    $0xc,%esp
  8019a1:	6a 00                	push   $0x0
  8019a3:	53                   	push   %ebx
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 df f8 ff ff       	call   80128a <ipc_recv>
}
  8019ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ae:	5b                   	pop    %ebx
  8019af:	5e                   	pop    %esi
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    

008019b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d5:	e8 8d ff ff ff       	call   801967 <fsipc>
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f7:	e8 6b ff ff ff       	call   801967 <fsipc>
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	53                   	push   %ebx
  801a02:	83 ec 04             	sub    $0x4,%esp
  801a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a08:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a13:	ba 00 00 00 00       	mov    $0x0,%edx
  801a18:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1d:	e8 45 ff ff ff       	call   801967 <fsipc>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 2c                	js     801a52 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	68 00 50 80 00       	push   $0x805000
  801a2e:	53                   	push   %ebx
  801a2f:	e8 08 ed ff ff       	call   80073c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a34:	a1 80 50 80 00       	mov    0x805080,%eax
  801a39:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a3f:	a1 84 50 80 00       	mov    0x805084,%eax
  801a44:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a60:	8b 55 08             	mov    0x8(%ebp),%edx
  801a63:	8b 52 0c             	mov    0xc(%edx),%edx
  801a66:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a6c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a71:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a76:	0f 47 c2             	cmova  %edx,%eax
  801a79:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a7e:	50                   	push   %eax
  801a7f:	ff 75 0c             	pushl  0xc(%ebp)
  801a82:	68 08 50 80 00       	push   $0x805008
  801a87:	e8 42 ee ff ff       	call   8008ce <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a91:	b8 04 00 00 00       	mov    $0x4,%eax
  801a96:	e8 cc fe ff ff       	call   801967 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	56                   	push   %esi
  801aa1:	53                   	push   %ebx
  801aa2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	8b 40 0c             	mov    0xc(%eax),%eax
  801aab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ab0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  801abb:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac0:	e8 a2 fe ff ff       	call   801967 <fsipc>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 4b                	js     801b16 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801acb:	39 c6                	cmp    %eax,%esi
  801acd:	73 16                	jae    801ae5 <devfile_read+0x48>
  801acf:	68 fc 28 80 00       	push   $0x8028fc
  801ad4:	68 03 29 80 00       	push   $0x802903
  801ad9:	6a 7c                	push   $0x7c
  801adb:	68 18 29 80 00       	push   $0x802918
  801ae0:	e8 c6 05 00 00       	call   8020ab <_panic>
	assert(r <= PGSIZE);
  801ae5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aea:	7e 16                	jle    801b02 <devfile_read+0x65>
  801aec:	68 23 29 80 00       	push   $0x802923
  801af1:	68 03 29 80 00       	push   $0x802903
  801af6:	6a 7d                	push   $0x7d
  801af8:	68 18 29 80 00       	push   $0x802918
  801afd:	e8 a9 05 00 00       	call   8020ab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b02:	83 ec 04             	sub    $0x4,%esp
  801b05:	50                   	push   %eax
  801b06:	68 00 50 80 00       	push   $0x805000
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	e8 bb ed ff ff       	call   8008ce <memmove>
	return r;
  801b13:	83 c4 10             	add    $0x10,%esp
}
  801b16:	89 d8                	mov    %ebx,%eax
  801b18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	53                   	push   %ebx
  801b23:	83 ec 20             	sub    $0x20,%esp
  801b26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b29:	53                   	push   %ebx
  801b2a:	e8 d4 eb ff ff       	call   800703 <strlen>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b37:	7f 67                	jg     801ba0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b39:	83 ec 0c             	sub    $0xc,%esp
  801b3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3f:	50                   	push   %eax
  801b40:	e8 8e f8 ff ff       	call   8013d3 <fd_alloc>
  801b45:	83 c4 10             	add    $0x10,%esp
		return r;
  801b48:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 57                	js     801ba5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b4e:	83 ec 08             	sub    $0x8,%esp
  801b51:	53                   	push   %ebx
  801b52:	68 00 50 80 00       	push   $0x805000
  801b57:	e8 e0 eb ff ff       	call   80073c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b67:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6c:	e8 f6 fd ff ff       	call   801967 <fsipc>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	85 c0                	test   %eax,%eax
  801b78:	79 14                	jns    801b8e <open+0x6f>
		fd_close(fd, 0);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	6a 00                	push   $0x0
  801b7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b82:	e8 47 f9 ff ff       	call   8014ce <fd_close>
		return r;
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	89 da                	mov    %ebx,%edx
  801b8c:	eb 17                	jmp    801ba5 <open+0x86>
	}

	return fd2num(fd);
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	ff 75 f4             	pushl  -0xc(%ebp)
  801b94:	e8 13 f8 ff ff       	call   8013ac <fd2num>
  801b99:	89 c2                	mov    %eax,%edx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	eb 05                	jmp    801ba5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ba0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ba5:	89 d0                	mov    %edx,%eax
  801ba7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb7:	b8 08 00 00 00       	mov    $0x8,%eax
  801bbc:	e8 a6 fd ff ff       	call   801967 <fsipc>
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	ff 75 08             	pushl  0x8(%ebp)
  801bd1:	e8 e6 f7 ff ff       	call   8013bc <fd2data>
  801bd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd8:	83 c4 08             	add    $0x8,%esp
  801bdb:	68 2f 29 80 00       	push   $0x80292f
  801be0:	53                   	push   %ebx
  801be1:	e8 56 eb ff ff       	call   80073c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801be6:	8b 46 04             	mov    0x4(%esi),%eax
  801be9:	2b 06                	sub    (%esi),%eax
  801beb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bf1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf8:	00 00 00 
	stat->st_dev = &devpipe;
  801bfb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c02:	30 80 00 
	return 0;
}
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c1b:	53                   	push   %ebx
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 a1 ef ff ff       	call   800bc4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c23:	89 1c 24             	mov    %ebx,(%esp)
  801c26:	e8 91 f7 ff ff       	call   8013bc <fd2data>
  801c2b:	83 c4 08             	add    $0x8,%esp
  801c2e:	50                   	push   %eax
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 8e ef ff ff       	call   800bc4 <sys_page_unmap>
}
  801c36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 1c             	sub    $0x1c,%esp
  801c44:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c47:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c49:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4e:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c54:	83 ec 0c             	sub    $0xc,%esp
  801c57:	ff 75 e0             	pushl  -0x20(%ebp)
  801c5a:	e8 21 05 00 00       	call   802180 <pageref>
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	89 3c 24             	mov    %edi,(%esp)
  801c64:	e8 17 05 00 00       	call   802180 <pageref>
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	39 c3                	cmp    %eax,%ebx
  801c6e:	0f 94 c1             	sete   %cl
  801c71:	0f b6 c9             	movzbl %cl,%ecx
  801c74:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c77:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c7d:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801c83:	39 ce                	cmp    %ecx,%esi
  801c85:	74 1e                	je     801ca5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c87:	39 c3                	cmp    %eax,%ebx
  801c89:	75 be                	jne    801c49 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c8b:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801c91:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c94:	50                   	push   %eax
  801c95:	56                   	push   %esi
  801c96:	68 36 29 80 00       	push   $0x802936
  801c9b:	e8 17 e5 ff ff       	call   8001b7 <cprintf>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	eb a4                	jmp    801c49 <_pipeisclosed+0xe>
	}
}
  801ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5f                   	pop    %edi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	57                   	push   %edi
  801cb4:	56                   	push   %esi
  801cb5:	53                   	push   %ebx
  801cb6:	83 ec 28             	sub    $0x28,%esp
  801cb9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cbc:	56                   	push   %esi
  801cbd:	e8 fa f6 ff ff       	call   8013bc <fd2data>
  801cc2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ccc:	eb 4b                	jmp    801d19 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cce:	89 da                	mov    %ebx,%edx
  801cd0:	89 f0                	mov    %esi,%eax
  801cd2:	e8 64 ff ff ff       	call   801c3b <_pipeisclosed>
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	75 48                	jne    801d23 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cdb:	e8 40 ee ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ce0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce3:	8b 0b                	mov    (%ebx),%ecx
  801ce5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ce8:	39 d0                	cmp    %edx,%eax
  801cea:	73 e2                	jae    801cce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cf3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cf6:	89 c2                	mov    %eax,%edx
  801cf8:	c1 fa 1f             	sar    $0x1f,%edx
  801cfb:	89 d1                	mov    %edx,%ecx
  801cfd:	c1 e9 1b             	shr    $0x1b,%ecx
  801d00:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d03:	83 e2 1f             	and    $0x1f,%edx
  801d06:	29 ca                	sub    %ecx,%edx
  801d08:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d0c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d10:	83 c0 01             	add    $0x1,%eax
  801d13:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d16:	83 c7 01             	add    $0x1,%edi
  801d19:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d1c:	75 c2                	jne    801ce0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d21:	eb 05                	jmp    801d28 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	57                   	push   %edi
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	83 ec 18             	sub    $0x18,%esp
  801d39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d3c:	57                   	push   %edi
  801d3d:	e8 7a f6 ff ff       	call   8013bc <fd2data>
  801d42:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4c:	eb 3d                	jmp    801d8b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d4e:	85 db                	test   %ebx,%ebx
  801d50:	74 04                	je     801d56 <devpipe_read+0x26>
				return i;
  801d52:	89 d8                	mov    %ebx,%eax
  801d54:	eb 44                	jmp    801d9a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d56:	89 f2                	mov    %esi,%edx
  801d58:	89 f8                	mov    %edi,%eax
  801d5a:	e8 dc fe ff ff       	call   801c3b <_pipeisclosed>
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	75 32                	jne    801d95 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d63:	e8 b8 ed ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d68:	8b 06                	mov    (%esi),%eax
  801d6a:	3b 46 04             	cmp    0x4(%esi),%eax
  801d6d:	74 df                	je     801d4e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d6f:	99                   	cltd   
  801d70:	c1 ea 1b             	shr    $0x1b,%edx
  801d73:	01 d0                	add    %edx,%eax
  801d75:	83 e0 1f             	and    $0x1f,%eax
  801d78:	29 d0                	sub    %edx,%eax
  801d7a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d82:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d85:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d88:	83 c3 01             	add    $0x1,%ebx
  801d8b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d8e:	75 d8                	jne    801d68 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d90:	8b 45 10             	mov    0x10(%ebp),%eax
  801d93:	eb 05                	jmp    801d9a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    

00801da2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	56                   	push   %esi
  801da6:	53                   	push   %ebx
  801da7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	e8 20 f6 ff ff       	call   8013d3 <fd_alloc>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	85 c0                	test   %eax,%eax
  801dba:	0f 88 2c 01 00 00    	js     801eec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc0:	83 ec 04             	sub    $0x4,%esp
  801dc3:	68 07 04 00 00       	push   $0x407
  801dc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 6d ed ff ff       	call   800b3f <sys_page_alloc>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	89 c2                	mov    %eax,%edx
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	0f 88 0d 01 00 00    	js     801eec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	e8 e8 f5 ff ff       	call   8013d3 <fd_alloc>
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 88 e2 00 00 00    	js     801eda <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df8:	83 ec 04             	sub    $0x4,%esp
  801dfb:	68 07 04 00 00       	push   $0x407
  801e00:	ff 75 f0             	pushl  -0x10(%ebp)
  801e03:	6a 00                	push   $0x0
  801e05:	e8 35 ed ff ff       	call   800b3f <sys_page_alloc>
  801e0a:	89 c3                	mov    %eax,%ebx
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	0f 88 c3 00 00 00    	js     801eda <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e17:	83 ec 0c             	sub    $0xc,%esp
  801e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1d:	e8 9a f5 ff ff       	call   8013bc <fd2data>
  801e22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e24:	83 c4 0c             	add    $0xc,%esp
  801e27:	68 07 04 00 00       	push   $0x407
  801e2c:	50                   	push   %eax
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 0b ed ff ff       	call   800b3f <sys_page_alloc>
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	0f 88 89 00 00 00    	js     801eca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 f0             	pushl  -0x10(%ebp)
  801e47:	e8 70 f5 ff ff       	call   8013bc <fd2data>
  801e4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e53:	50                   	push   %eax
  801e54:	6a 00                	push   $0x0
  801e56:	56                   	push   %esi
  801e57:	6a 00                	push   $0x0
  801e59:	e8 24 ed ff ff       	call   800b82 <sys_page_map>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	83 c4 20             	add    $0x20,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 55                	js     801ebc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e7c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	ff 75 f4             	pushl  -0xc(%ebp)
  801e97:	e8 10 f5 ff ff       	call   8013ac <fd2num>
  801e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ea1:	83 c4 04             	add    $0x4,%esp
  801ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea7:	e8 00 f5 ff ff       	call   8013ac <fd2num>
  801eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eaf:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eba:	eb 30                	jmp    801eec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ebc:	83 ec 08             	sub    $0x8,%esp
  801ebf:	56                   	push   %esi
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 fd ec ff ff       	call   800bc4 <sys_page_unmap>
  801ec7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 ed ec ff ff       	call   800bc4 <sys_page_unmap>
  801ed7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801eda:	83 ec 08             	sub    $0x8,%esp
  801edd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 dd ec ff ff       	call   800bc4 <sys_page_unmap>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eec:	89 d0                	mov    %edx,%eax
  801eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef1:	5b                   	pop    %ebx
  801ef2:	5e                   	pop    %esi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	ff 75 08             	pushl  0x8(%ebp)
  801f02:	e8 1b f5 ff ff       	call   801422 <fd_lookup>
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 18                	js     801f26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	ff 75 f4             	pushl  -0xc(%ebp)
  801f14:	e8 a3 f4 ff ff       	call   8013bc <fd2data>
	return _pipeisclosed(fd, p);
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1e:	e8 18 fd ff ff       	call   801c3b <_pipeisclosed>
  801f23:	83 c4 10             	add    $0x10,%esp
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f38:	68 4e 29 80 00       	push   $0x80294e
  801f3d:	ff 75 0c             	pushl  0xc(%ebp)
  801f40:	e8 f7 e7 ff ff       	call   80073c <strcpy>
	return 0;
}
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	57                   	push   %edi
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
  801f52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f58:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f63:	eb 2d                	jmp    801f92 <devcons_write+0x46>
		m = n - tot;
  801f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f68:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f6a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f6d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f72:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f75:	83 ec 04             	sub    $0x4,%esp
  801f78:	53                   	push   %ebx
  801f79:	03 45 0c             	add    0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	57                   	push   %edi
  801f7e:	e8 4b e9 ff ff       	call   8008ce <memmove>
		sys_cputs(buf, m);
  801f83:	83 c4 08             	add    $0x8,%esp
  801f86:	53                   	push   %ebx
  801f87:	57                   	push   %edi
  801f88:	e8 f6 ea ff ff       	call   800a83 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8d:	01 de                	add    %ebx,%esi
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	89 f0                	mov    %esi,%eax
  801f94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f97:	72 cc                	jb     801f65 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 08             	sub    $0x8,%esp
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb0:	74 2a                	je     801fdc <devcons_read+0x3b>
  801fb2:	eb 05                	jmp    801fb9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fb4:	e8 67 eb ff ff       	call   800b20 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb9:	e8 e3 ea ff ff       	call   800aa1 <sys_cgetc>
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	74 f2                	je     801fb4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 16                	js     801fdc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fc6:	83 f8 04             	cmp    $0x4,%eax
  801fc9:	74 0c                	je     801fd7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fce:	88 02                	mov    %al,(%edx)
	return 1;
  801fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd5:	eb 05                	jmp    801fdc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fea:	6a 01                	push   $0x1
  801fec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fef:	50                   	push   %eax
  801ff0:	e8 8e ea ff ff       	call   800a83 <sys_cputs>
}
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <getchar>:

int
getchar(void)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802000:	6a 01                	push   $0x1
  802002:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802005:	50                   	push   %eax
  802006:	6a 00                	push   $0x0
  802008:	e8 7e f6 ff ff       	call   80168b <read>
	if (r < 0)
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	85 c0                	test   %eax,%eax
  802012:	78 0f                	js     802023 <getchar+0x29>
		return r;
	if (r < 1)
  802014:	85 c0                	test   %eax,%eax
  802016:	7e 06                	jle    80201e <getchar+0x24>
		return -E_EOF;
	return c;
  802018:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80201c:	eb 05                	jmp    802023 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80201e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80202b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202e:	50                   	push   %eax
  80202f:	ff 75 08             	pushl  0x8(%ebp)
  802032:	e8 eb f3 ff ff       	call   801422 <fd_lookup>
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 11                	js     80204f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80203e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802041:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802047:	39 10                	cmp    %edx,(%eax)
  802049:	0f 94 c0             	sete   %al
  80204c:	0f b6 c0             	movzbl %al,%eax
}
  80204f:	c9                   	leave  
  802050:	c3                   	ret    

00802051 <opencons>:

int
opencons(void)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802057:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205a:	50                   	push   %eax
  80205b:	e8 73 f3 ff ff       	call   8013d3 <fd_alloc>
  802060:	83 c4 10             	add    $0x10,%esp
		return r;
  802063:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802065:	85 c0                	test   %eax,%eax
  802067:	78 3e                	js     8020a7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802069:	83 ec 04             	sub    $0x4,%esp
  80206c:	68 07 04 00 00       	push   $0x407
  802071:	ff 75 f4             	pushl  -0xc(%ebp)
  802074:	6a 00                	push   $0x0
  802076:	e8 c4 ea ff ff       	call   800b3f <sys_page_alloc>
  80207b:	83 c4 10             	add    $0x10,%esp
		return r;
  80207e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802080:	85 c0                	test   %eax,%eax
  802082:	78 23                	js     8020a7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802084:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802092:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802099:	83 ec 0c             	sub    $0xc,%esp
  80209c:	50                   	push   %eax
  80209d:	e8 0a f3 ff ff       	call   8013ac <fd2num>
  8020a2:	89 c2                	mov    %eax,%edx
  8020a4:	83 c4 10             	add    $0x10,%esp
}
  8020a7:	89 d0                	mov    %edx,%eax
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	56                   	push   %esi
  8020af:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8020b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020b3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020b9:	e8 43 ea ff ff       	call   800b01 <sys_getenvid>
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	ff 75 0c             	pushl  0xc(%ebp)
  8020c4:	ff 75 08             	pushl  0x8(%ebp)
  8020c7:	56                   	push   %esi
  8020c8:	50                   	push   %eax
  8020c9:	68 5c 29 80 00       	push   $0x80295c
  8020ce:	e8 e4 e0 ff ff       	call   8001b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020d3:	83 c4 18             	add    $0x18,%esp
  8020d6:	53                   	push   %ebx
  8020d7:	ff 75 10             	pushl  0x10(%ebp)
  8020da:	e8 87 e0 ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  8020df:	c7 04 24 3b 28 80 00 	movl   $0x80283b,(%esp)
  8020e6:	e8 cc e0 ff ff       	call   8001b7 <cprintf>
  8020eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020ee:	cc                   	int3   
  8020ef:	eb fd                	jmp    8020ee <_panic+0x43>

008020f1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020f7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020fe:	75 2a                	jne    80212a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802100:	83 ec 04             	sub    $0x4,%esp
  802103:	6a 07                	push   $0x7
  802105:	68 00 f0 bf ee       	push   $0xeebff000
  80210a:	6a 00                	push   $0x0
  80210c:	e8 2e ea ff ff       	call   800b3f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	85 c0                	test   %eax,%eax
  802116:	79 12                	jns    80212a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802118:	50                   	push   %eax
  802119:	68 52 28 80 00       	push   $0x802852
  80211e:	6a 23                	push   $0x23
  802120:	68 80 29 80 00       	push   $0x802980
  802125:	e8 81 ff ff ff       	call   8020ab <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80212a:	8b 45 08             	mov    0x8(%ebp),%eax
  80212d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802132:	83 ec 08             	sub    $0x8,%esp
  802135:	68 5c 21 80 00       	push   $0x80215c
  80213a:	6a 00                	push   $0x0
  80213c:	e8 49 eb ff ff       	call   800c8a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	85 c0                	test   %eax,%eax
  802146:	79 12                	jns    80215a <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802148:	50                   	push   %eax
  802149:	68 52 28 80 00       	push   $0x802852
  80214e:	6a 2c                	push   $0x2c
  802150:	68 80 29 80 00       	push   $0x802980
  802155:	e8 51 ff ff ff       	call   8020ab <_panic>
	}
}
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80215c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80215d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802162:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802164:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802167:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80216b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802170:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802174:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802176:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802179:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80217a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80217d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80217e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80217f:	c3                   	ret    

00802180 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802186:	89 d0                	mov    %edx,%eax
  802188:	c1 e8 16             	shr    $0x16,%eax
  80218b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802192:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802197:	f6 c1 01             	test   $0x1,%cl
  80219a:	74 1d                	je     8021b9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80219c:	c1 ea 0c             	shr    $0xc,%edx
  80219f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021a6:	f6 c2 01             	test   $0x1,%dl
  8021a9:	74 0e                	je     8021b9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ab:	c1 ea 0c             	shr    $0xc,%edx
  8021ae:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021b5:	ef 
  8021b6:	0f b7 c0             	movzwl %ax,%eax
}
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    
  8021bb:	66 90                	xchg   %ax,%ax
  8021bd:	66 90                	xchg   %ax,%ax
  8021bf:	90                   	nop

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021dd:	89 ca                	mov    %ecx,%edx
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	75 3d                	jne    802220 <__udivdi3+0x60>
  8021e3:	39 cf                	cmp    %ecx,%edi
  8021e5:	0f 87 c5 00 00 00    	ja     8022b0 <__udivdi3+0xf0>
  8021eb:	85 ff                	test   %edi,%edi
  8021ed:	89 fd                	mov    %edi,%ebp
  8021ef:	75 0b                	jne    8021fc <__udivdi3+0x3c>
  8021f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f6:	31 d2                	xor    %edx,%edx
  8021f8:	f7 f7                	div    %edi
  8021fa:	89 c5                	mov    %eax,%ebp
  8021fc:	89 c8                	mov    %ecx,%eax
  8021fe:	31 d2                	xor    %edx,%edx
  802200:	f7 f5                	div    %ebp
  802202:	89 c1                	mov    %eax,%ecx
  802204:	89 d8                	mov    %ebx,%eax
  802206:	89 cf                	mov    %ecx,%edi
  802208:	f7 f5                	div    %ebp
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 ce                	cmp    %ecx,%esi
  802222:	77 74                	ja     802298 <__udivdi3+0xd8>
  802224:	0f bd fe             	bsr    %esi,%edi
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	0f 84 98 00 00 00    	je     8022c8 <__udivdi3+0x108>
  802230:	bb 20 00 00 00       	mov    $0x20,%ebx
  802235:	89 f9                	mov    %edi,%ecx
  802237:	89 c5                	mov    %eax,%ebp
  802239:	29 fb                	sub    %edi,%ebx
  80223b:	d3 e6                	shl    %cl,%esi
  80223d:	89 d9                	mov    %ebx,%ecx
  80223f:	d3 ed                	shr    %cl,%ebp
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e0                	shl    %cl,%eax
  802245:	09 ee                	or     %ebp,%esi
  802247:	89 d9                	mov    %ebx,%ecx
  802249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224d:	89 d5                	mov    %edx,%ebp
  80224f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802253:	d3 ed                	shr    %cl,%ebp
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e2                	shl    %cl,%edx
  802259:	89 d9                	mov    %ebx,%ecx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 d0                	mov    %edx,%eax
  802261:	89 ea                	mov    %ebp,%edx
  802263:	f7 f6                	div    %esi
  802265:	89 d5                	mov    %edx,%ebp
  802267:	89 c3                	mov    %eax,%ebx
  802269:	f7 64 24 0c          	mull   0xc(%esp)
  80226d:	39 d5                	cmp    %edx,%ebp
  80226f:	72 10                	jb     802281 <__udivdi3+0xc1>
  802271:	8b 74 24 08          	mov    0x8(%esp),%esi
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e6                	shl    %cl,%esi
  802279:	39 c6                	cmp    %eax,%esi
  80227b:	73 07                	jae    802284 <__udivdi3+0xc4>
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	75 03                	jne    802284 <__udivdi3+0xc4>
  802281:	83 eb 01             	sub    $0x1,%ebx
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 d8                	mov    %ebx,%eax
  802288:	89 fa                	mov    %edi,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	31 ff                	xor    %edi,%edi
  80229a:	31 db                	xor    %ebx,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 d8                	mov    %ebx,%eax
  8022b2:	f7 f7                	div    %edi
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 fa                	mov    %edi,%edx
  8022bc:	83 c4 1c             	add    $0x1c,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 ce                	cmp    %ecx,%esi
  8022ca:	72 0c                	jb     8022d8 <__udivdi3+0x118>
  8022cc:	31 db                	xor    %ebx,%ebx
  8022ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022d2:	0f 87 34 ff ff ff    	ja     80220c <__udivdi3+0x4c>
  8022d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022dd:	e9 2a ff ff ff       	jmp    80220c <__udivdi3+0x4c>
  8022e2:	66 90                	xchg   %ax,%ax
  8022e4:	66 90                	xchg   %ax,%ax
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 d2                	test   %edx,%edx
  802309:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f3                	mov    %esi,%ebx
  802313:	89 3c 24             	mov    %edi,(%esp)
  802316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231a:	75 1c                	jne    802338 <__umoddi3+0x48>
  80231c:	39 f7                	cmp    %esi,%edi
  80231e:	76 50                	jbe    802370 <__umoddi3+0x80>
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	f7 f7                	div    %edi
  802326:	89 d0                	mov    %edx,%eax
  802328:	31 d2                	xor    %edx,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	89 d0                	mov    %edx,%eax
  80233c:	77 52                	ja     802390 <__umoddi3+0xa0>
  80233e:	0f bd ea             	bsr    %edx,%ebp
  802341:	83 f5 1f             	xor    $0x1f,%ebp
  802344:	75 5a                	jne    8023a0 <__umoddi3+0xb0>
  802346:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80234a:	0f 82 e0 00 00 00    	jb     802430 <__umoddi3+0x140>
  802350:	39 0c 24             	cmp    %ecx,(%esp)
  802353:	0f 86 d7 00 00 00    	jbe    802430 <__umoddi3+0x140>
  802359:	8b 44 24 08          	mov    0x8(%esp),%eax
  80235d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802361:	83 c4 1c             	add    $0x1c,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	85 ff                	test   %edi,%edi
  802372:	89 fd                	mov    %edi,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	89 f0                	mov    %esi,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f5                	div    %ebp
  802387:	89 c8                	mov    %ecx,%eax
  802389:	f7 f5                	div    %ebp
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	eb 99                	jmp    802328 <__umoddi3+0x38>
  80238f:	90                   	nop
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	83 c4 1c             	add    $0x1c,%esp
  802397:	5b                   	pop    %ebx
  802398:	5e                   	pop    %esi
  802399:	5f                   	pop    %edi
  80239a:	5d                   	pop    %ebp
  80239b:	c3                   	ret    
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	8b 34 24             	mov    (%esp),%esi
  8023a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	29 ef                	sub    %ebp,%edi
  8023ac:	d3 e0                	shl    %cl,%eax
  8023ae:	89 f9                	mov    %edi,%ecx
  8023b0:	89 f2                	mov    %esi,%edx
  8023b2:	d3 ea                	shr    %cl,%edx
  8023b4:	89 e9                	mov    %ebp,%ecx
  8023b6:	09 c2                	or     %eax,%edx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 14 24             	mov    %edx,(%esp)
  8023bd:	89 f2                	mov    %esi,%edx
  8023bf:	d3 e2                	shl    %cl,%edx
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	d3 e3                	shl    %cl,%ebx
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 d0                	mov    %edx,%eax
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	09 d8                	or     %ebx,%eax
  8023dd:	89 d3                	mov    %edx,%ebx
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	f7 34 24             	divl   (%esp)
  8023e4:	89 d6                	mov    %edx,%esi
  8023e6:	d3 e3                	shl    %cl,%ebx
  8023e8:	f7 64 24 04          	mull   0x4(%esp)
  8023ec:	39 d6                	cmp    %edx,%esi
  8023ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f2:	89 d1                	mov    %edx,%ecx
  8023f4:	89 c3                	mov    %eax,%ebx
  8023f6:	72 08                	jb     802400 <__umoddi3+0x110>
  8023f8:	75 11                	jne    80240b <__umoddi3+0x11b>
  8023fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023fe:	73 0b                	jae    80240b <__umoddi3+0x11b>
  802400:	2b 44 24 04          	sub    0x4(%esp),%eax
  802404:	1b 14 24             	sbb    (%esp),%edx
  802407:	89 d1                	mov    %edx,%ecx
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80240f:	29 da                	sub    %ebx,%edx
  802411:	19 ce                	sbb    %ecx,%esi
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 f0                	mov    %esi,%eax
  802417:	d3 e0                	shl    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	d3 ea                	shr    %cl,%edx
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	d3 ee                	shr    %cl,%esi
  802421:	09 d0                	or     %edx,%eax
  802423:	89 f2                	mov    %esi,%edx
  802425:	83 c4 1c             	add    $0x1c,%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	29 f9                	sub    %edi,%ecx
  802432:	19 d6                	sbb    %edx,%esi
  802434:	89 74 24 04          	mov    %esi,0x4(%esp)
  802438:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80243c:	e9 18 ff ff ff       	jmp    802359 <__umoddi3+0x69>
