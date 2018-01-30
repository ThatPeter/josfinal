
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
  800042:	81 3d 04 40 80 00 d8 	cmpl   $0xeec000d8,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 ae 12 00 00       	call   80130c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 e0 24 80 00       	push   $0x8024e0
  80006a:	e8 48 01 00 00       	call   8001b7 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 7c 01 c0 ee       	mov    0xeec0017c,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 f1 24 80 00       	push   $0x8024f1
  800083:	e8 2f 01 00 00       	call   8001b7 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 7c 01 c0 ee       	mov    0xeec0017c,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 eb 12 00 00       	call   801387 <ipc_send>
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
  8000b6:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800110:	e8 e7 14 00 00       	call   8015fc <close_all>
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
  80021a:	e8 21 20 00 00       	call   802240 <__udivdi3>
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
  80025d:	e8 0e 21 00 00       	call   802370 <__umoddi3>
  800262:	83 c4 14             	add    $0x14,%esp
  800265:	0f be 80 12 25 80 00 	movsbl 0x802512(%eax),%eax
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
  800361:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
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
  800425:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 18                	jne    800448 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 2a 25 80 00       	push   $0x80252a
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
  800449:	68 65 2a 80 00       	push   $0x802a65
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
  80046d:	b8 23 25 80 00       	mov    $0x802523,%eax
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
  800ae8:	68 1f 28 80 00       	push   $0x80281f
  800aed:	6a 23                	push   $0x23
  800aef:	68 3c 28 80 00       	push   $0x80283c
  800af4:	e8 34 16 00 00       	call   80212d <_panic>

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
  800b69:	68 1f 28 80 00       	push   $0x80281f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 3c 28 80 00       	push   $0x80283c
  800b75:	e8 b3 15 00 00       	call   80212d <_panic>

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
  800bab:	68 1f 28 80 00       	push   $0x80281f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 3c 28 80 00       	push   $0x80283c
  800bb7:	e8 71 15 00 00       	call   80212d <_panic>

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
  800bed:	68 1f 28 80 00       	push   $0x80281f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 3c 28 80 00       	push   $0x80283c
  800bf9:	e8 2f 15 00 00       	call   80212d <_panic>

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
  800c2f:	68 1f 28 80 00       	push   $0x80281f
  800c34:	6a 23                	push   $0x23
  800c36:	68 3c 28 80 00       	push   $0x80283c
  800c3b:	e8 ed 14 00 00       	call   80212d <_panic>

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
  800c71:	68 1f 28 80 00       	push   $0x80281f
  800c76:	6a 23                	push   $0x23
  800c78:	68 3c 28 80 00       	push   $0x80283c
  800c7d:	e8 ab 14 00 00       	call   80212d <_panic>
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
  800cb3:	68 1f 28 80 00       	push   $0x80281f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 3c 28 80 00       	push   $0x80283c
  800cbf:	e8 69 14 00 00       	call   80212d <_panic>

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
  800d17:	68 1f 28 80 00       	push   $0x80281f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 3c 28 80 00       	push   $0x80283c
  800d23:	e8 05 14 00 00       	call   80212d <_panic>

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
  800db6:	68 4a 28 80 00       	push   $0x80284a
  800dbb:	6a 1f                	push   $0x1f
  800dbd:	68 5a 28 80 00       	push   $0x80285a
  800dc2:	e8 66 13 00 00       	call   80212d <_panic>
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
  800de0:	68 65 28 80 00       	push   $0x802865
  800de5:	6a 2d                	push   $0x2d
  800de7:	68 5a 28 80 00       	push   $0x80285a
  800dec:	e8 3c 13 00 00       	call   80212d <_panic>
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
  800e28:	68 65 28 80 00       	push   $0x802865
  800e2d:	6a 34                	push   $0x34
  800e2f:	68 5a 28 80 00       	push   $0x80285a
  800e34:	e8 f4 12 00 00       	call   80212d <_panic>
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
  800e50:	68 65 28 80 00       	push   $0x802865
  800e55:	6a 38                	push   $0x38
  800e57:	68 5a 28 80 00       	push   $0x80285a
  800e5c:	e8 cc 12 00 00       	call   80212d <_panic>
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
  800e74:	e8 fa 12 00 00       	call   802173 <set_pgfault_handler>
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
  800e8d:	68 7e 28 80 00       	push   $0x80287e
  800e92:	68 85 00 00 00       	push   $0x85
  800e97:	68 5a 28 80 00       	push   $0x80285a
  800e9c:	e8 8c 12 00 00       	call   80212d <_panic>
  800ea1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea7:	75 24                	jne    800ecd <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea9:	e8 53 fc ff ff       	call   800b01 <sys_getenvid>
  800eae:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f49:	68 8c 28 80 00       	push   $0x80288c
  800f4e:	6a 55                	push   $0x55
  800f50:	68 5a 28 80 00       	push   $0x80285a
  800f55:	e8 d3 11 00 00       	call   80212d <_panic>
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
  800f8e:	68 8c 28 80 00       	push   $0x80288c
  800f93:	6a 5c                	push   $0x5c
  800f95:	68 5a 28 80 00       	push   $0x80285a
  800f9a:	e8 8e 11 00 00       	call   80212d <_panic>
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
  800fbc:	68 8c 28 80 00       	push   $0x80288c
  800fc1:	6a 60                	push   $0x60
  800fc3:	68 5a 28 80 00       	push   $0x80285a
  800fc8:	e8 60 11 00 00       	call   80212d <_panic>
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
  800fe6:	68 8c 28 80 00       	push   $0x80288c
  800feb:	6a 65                	push   $0x65
  800fed:	68 5a 28 80 00       	push   $0x80285a
  800ff2:	e8 36 11 00 00       	call   80212d <_panic>
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
  80100e:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80104b:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	53                   	push   %ebx
  801055:	68 1c 29 80 00       	push   $0x80291c
  80105a:	e8 58 f1 ff ff       	call   8001b7 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80105f:	c7 04 24 ea 00 80 00 	movl   $0x8000ea,(%esp)
  801066:	e8 c5 fc ff ff       	call   800d30 <sys_thread_create>
  80106b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	53                   	push   %ebx
  801071:	68 1c 29 80 00       	push   $0x80291c
  801076:	e8 3c f1 ff ff       	call   8001b7 <cprintf>
	return id;
}
  80107b:	89 f0                	mov    %esi,%eax
  80107d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80108a:	ff 75 08             	pushl  0x8(%ebp)
  80108d:	e8 be fc ff ff       	call   800d50 <sys_thread_free>
}
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80109d:	ff 75 08             	pushl  0x8(%ebp)
  8010a0:	e8 cb fc ff ff       	call   800d70 <sys_thread_join>
}
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	56                   	push   %esi
  8010ae:	53                   	push   %ebx
  8010af:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	6a 07                	push   $0x7
  8010ba:	6a 00                	push   $0x0
  8010bc:	56                   	push   %esi
  8010bd:	e8 7d fa ff ff       	call   800b3f <sys_page_alloc>
	if (r < 0) {
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 15                	jns    8010de <queue_append+0x34>
		panic("%e\n", r);
  8010c9:	50                   	push   %eax
  8010ca:	68 18 29 80 00       	push   $0x802918
  8010cf:	68 c4 00 00 00       	push   $0xc4
  8010d4:	68 5a 28 80 00       	push   $0x80285a
  8010d9:	e8 4f 10 00 00       	call   80212d <_panic>
	}	
	wt->envid = envid;
  8010de:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	ff 33                	pushl  (%ebx)
  8010e9:	56                   	push   %esi
  8010ea:	68 40 29 80 00       	push   $0x802940
  8010ef:	e8 c3 f0 ff ff       	call   8001b7 <cprintf>
	if (queue->first == NULL) {
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010fa:	75 29                	jne    801125 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	68 a2 28 80 00       	push   $0x8028a2
  801104:	e8 ae f0 ff ff       	call   8001b7 <cprintf>
		queue->first = wt;
  801109:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80110f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801116:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80111d:	00 00 00 
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	eb 2b                	jmp    801150 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	68 bc 28 80 00       	push   $0x8028bc
  80112d:	e8 85 f0 ff ff       	call   8001b7 <cprintf>
		queue->last->next = wt;
  801132:	8b 43 04             	mov    0x4(%ebx),%eax
  801135:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80113c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801143:	00 00 00 
		queue->last = wt;
  801146:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80114d:	83 c4 10             	add    $0x10,%esp
	}
}
  801150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	53                   	push   %ebx
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801161:	8b 02                	mov    (%edx),%eax
  801163:	85 c0                	test   %eax,%eax
  801165:	75 17                	jne    80117e <queue_pop+0x27>
		panic("queue empty!\n");
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	68 da 28 80 00       	push   $0x8028da
  80116f:	68 d8 00 00 00       	push   $0xd8
  801174:	68 5a 28 80 00       	push   $0x80285a
  801179:	e8 af 0f 00 00       	call   80212d <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80117e:	8b 48 04             	mov    0x4(%eax),%ecx
  801181:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801183:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	53                   	push   %ebx
  801189:	68 e8 28 80 00       	push   $0x8028e8
  80118e:	e8 24 f0 ff ff       	call   8001b7 <cprintf>
	return envid;
}
  801193:	89 d8                	mov    %ebx,%eax
  801195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801198:	c9                   	leave  
  801199:	c3                   	ret    

0080119a <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	53                   	push   %ebx
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8011a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a9:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 5a                	je     80120a <mutex_lock+0x70>
  8011b0:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b3:	83 38 00             	cmpl   $0x0,(%eax)
  8011b6:	75 52                	jne    80120a <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8011b8:	83 ec 0c             	sub    $0xc,%esp
  8011bb:	68 68 29 80 00       	push   $0x802968
  8011c0:	e8 f2 ef ff ff       	call   8001b7 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8011c5:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8011c8:	e8 34 f9 ff ff       	call   800b01 <sys_getenvid>
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	53                   	push   %ebx
  8011d1:	50                   	push   %eax
  8011d2:	e8 d3 fe ff ff       	call   8010aa <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011d7:	e8 25 f9 ff ff       	call   800b01 <sys_getenvid>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	6a 04                	push   $0x4
  8011e1:	50                   	push   %eax
  8011e2:	e8 1f fa ff ff       	call   800c06 <sys_env_set_status>
		if (r < 0) {
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	79 15                	jns    801203 <mutex_lock+0x69>
			panic("%e\n", r);
  8011ee:	50                   	push   %eax
  8011ef:	68 18 29 80 00       	push   $0x802918
  8011f4:	68 eb 00 00 00       	push   $0xeb
  8011f9:	68 5a 28 80 00       	push   $0x80285a
  8011fe:	e8 2a 0f 00 00       	call   80212d <_panic>
		}
		sys_yield();
  801203:	e8 18 f9 ff ff       	call   800b20 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801208:	eb 18                	jmp    801222 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	68 88 29 80 00       	push   $0x802988
  801212:	e8 a0 ef ff ff       	call   8001b7 <cprintf>
	mtx->owner = sys_getenvid();}
  801217:	e8 e5 f8 ff ff       	call   800b01 <sys_getenvid>
  80121c:	89 43 08             	mov    %eax,0x8(%ebx)
  80121f:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	53                   	push   %ebx
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801239:	8b 43 04             	mov    0x4(%ebx),%eax
  80123c:	83 38 00             	cmpl   $0x0,(%eax)
  80123f:	74 33                	je     801274 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	50                   	push   %eax
  801245:	e8 0d ff ff ff       	call   801157 <queue_pop>
  80124a:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80124d:	83 c4 08             	add    $0x8,%esp
  801250:	6a 02                	push   $0x2
  801252:	50                   	push   %eax
  801253:	e8 ae f9 ff ff       	call   800c06 <sys_env_set_status>
		if (r < 0) {
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	79 15                	jns    801274 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80125f:	50                   	push   %eax
  801260:	68 18 29 80 00       	push   $0x802918
  801265:	68 00 01 00 00       	push   $0x100
  80126a:	68 5a 28 80 00       	push   $0x80285a
  80126f:	e8 b9 0e 00 00       	call   80212d <_panic>
		}
	}

	asm volatile("pause");
  801274:	f3 90                	pause  
	//sys_yield();
}
  801276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801285:	e8 77 f8 ff ff       	call   800b01 <sys_getenvid>
  80128a:	83 ec 04             	sub    $0x4,%esp
  80128d:	6a 07                	push   $0x7
  80128f:	53                   	push   %ebx
  801290:	50                   	push   %eax
  801291:	e8 a9 f8 ff ff       	call   800b3f <sys_page_alloc>
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	79 15                	jns    8012b2 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80129d:	50                   	push   %eax
  80129e:	68 03 29 80 00       	push   $0x802903
  8012a3:	68 0d 01 00 00       	push   $0x10d
  8012a8:	68 5a 28 80 00       	push   $0x80285a
  8012ad:	e8 7b 0e 00 00       	call   80212d <_panic>
	}	
	mtx->locked = 0;
  8012b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012b8:	8b 43 04             	mov    0x4(%ebx),%eax
  8012bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8012c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8012cb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8012d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    

008012d7 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8012dd:	e8 1f f8 ff ff       	call   800b01 <sys_getenvid>
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	ff 75 08             	pushl  0x8(%ebp)
  8012e8:	50                   	push   %eax
  8012e9:	e8 d6 f8 ff ff       	call   800bc4 <sys_page_unmap>
	if (r < 0) {
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	79 15                	jns    80130a <mutex_destroy+0x33>
		panic("%e\n", r);
  8012f5:	50                   	push   %eax
  8012f6:	68 18 29 80 00       	push   $0x802918
  8012fb:	68 1a 01 00 00       	push   $0x11a
  801300:	68 5a 28 80 00       	push   $0x80285a
  801305:	e8 23 0e 00 00       	call   80212d <_panic>
	}
}
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    

0080130c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	8b 75 08             	mov    0x8(%ebp),%esi
  801314:	8b 45 0c             	mov    0xc(%ebp),%eax
  801317:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80131a:	85 c0                	test   %eax,%eax
  80131c:	75 12                	jne    801330 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80131e:	83 ec 0c             	sub    $0xc,%esp
  801321:	68 00 00 c0 ee       	push   $0xeec00000
  801326:	e8 c4 f9 ff ff       	call   800cef <sys_ipc_recv>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	eb 0c                	jmp    80133c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	50                   	push   %eax
  801334:	e8 b6 f9 ff ff       	call   800cef <sys_ipc_recv>
  801339:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80133c:	85 f6                	test   %esi,%esi
  80133e:	0f 95 c1             	setne  %cl
  801341:	85 db                	test   %ebx,%ebx
  801343:	0f 95 c2             	setne  %dl
  801346:	84 d1                	test   %dl,%cl
  801348:	74 09                	je     801353 <ipc_recv+0x47>
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	c1 ea 1f             	shr    $0x1f,%edx
  80134f:	84 d2                	test   %dl,%dl
  801351:	75 2d                	jne    801380 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801353:	85 f6                	test   %esi,%esi
  801355:	74 0d                	je     801364 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801357:	a1 04 40 80 00       	mov    0x804004,%eax
  80135c:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801362:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801364:	85 db                	test   %ebx,%ebx
  801366:	74 0d                	je     801375 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801368:	a1 04 40 80 00       	mov    0x804004,%eax
  80136d:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801373:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801375:	a1 04 40 80 00       	mov    0x804004,%eax
  80137a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	8b 7d 08             	mov    0x8(%ebp),%edi
  801393:	8b 75 0c             	mov    0xc(%ebp),%esi
  801396:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801399:	85 db                	test   %ebx,%ebx
  80139b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013a0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8013a3:	ff 75 14             	pushl  0x14(%ebp)
  8013a6:	53                   	push   %ebx
  8013a7:	56                   	push   %esi
  8013a8:	57                   	push   %edi
  8013a9:	e8 1e f9 ff ff       	call   800ccc <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 ea 1f             	shr    $0x1f,%edx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	84 d2                	test   %dl,%dl
  8013b8:	74 17                	je     8013d1 <ipc_send+0x4a>
  8013ba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013bd:	74 12                	je     8013d1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8013bf:	50                   	push   %eax
  8013c0:	68 a8 29 80 00       	push   $0x8029a8
  8013c5:	6a 47                	push   $0x47
  8013c7:	68 b6 29 80 00       	push   $0x8029b6
  8013cc:	e8 5c 0d 00 00       	call   80212d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8013d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013d4:	75 07                	jne    8013dd <ipc_send+0x56>
			sys_yield();
  8013d6:	e8 45 f7 ff ff       	call   800b20 <sys_yield>
  8013db:	eb c6                	jmp    8013a3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	75 c2                	jne    8013a3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8013e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013f4:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8013fa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801400:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801406:	39 ca                	cmp    %ecx,%edx
  801408:	75 13                	jne    80141d <ipc_find_env+0x34>
			return envs[i].env_id;
  80140a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801410:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801415:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80141b:	eb 0f                	jmp    80142c <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80141d:	83 c0 01             	add    $0x1,%eax
  801420:	3d 00 04 00 00       	cmp    $0x400,%eax
  801425:	75 cd                	jne    8013f4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	05 00 00 00 30       	add    $0x30000000,%eax
  801439:	c1 e8 0c             	shr    $0xc,%eax
}
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	05 00 00 00 30       	add    $0x30000000,%eax
  801449:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80144e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801460:	89 c2                	mov    %eax,%edx
  801462:	c1 ea 16             	shr    $0x16,%edx
  801465:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146c:	f6 c2 01             	test   $0x1,%dl
  80146f:	74 11                	je     801482 <fd_alloc+0x2d>
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 0c             	shr    $0xc,%edx
  801476:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	75 09                	jne    80148b <fd_alloc+0x36>
			*fd_store = fd;
  801482:	89 01                	mov    %eax,(%ecx)
			return 0;
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
  801489:	eb 17                	jmp    8014a2 <fd_alloc+0x4d>
  80148b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801490:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801495:	75 c9                	jne    801460 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801497:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80149d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014aa:	83 f8 1f             	cmp    $0x1f,%eax
  8014ad:	77 36                	ja     8014e5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014af:	c1 e0 0c             	shl    $0xc,%eax
  8014b2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014b7:	89 c2                	mov    %eax,%edx
  8014b9:	c1 ea 16             	shr    $0x16,%edx
  8014bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014c3:	f6 c2 01             	test   $0x1,%dl
  8014c6:	74 24                	je     8014ec <fd_lookup+0x48>
  8014c8:	89 c2                	mov    %eax,%edx
  8014ca:	c1 ea 0c             	shr    $0xc,%edx
  8014cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d4:	f6 c2 01             	test   $0x1,%dl
  8014d7:	74 1a                	je     8014f3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014dc:	89 02                	mov    %eax,(%edx)
	return 0;
  8014de:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e3:	eb 13                	jmp    8014f8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ea:	eb 0c                	jmp    8014f8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f1:	eb 05                	jmp    8014f8 <fd_lookup+0x54>
  8014f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801503:	ba 3c 2a 80 00       	mov    $0x802a3c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801508:	eb 13                	jmp    80151d <dev_lookup+0x23>
  80150a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80150d:	39 08                	cmp    %ecx,(%eax)
  80150f:	75 0c                	jne    80151d <dev_lookup+0x23>
			*dev = devtab[i];
  801511:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801514:	89 01                	mov    %eax,(%ecx)
			return 0;
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
  80151b:	eb 31                	jmp    80154e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80151d:	8b 02                	mov    (%edx),%eax
  80151f:	85 c0                	test   %eax,%eax
  801521:	75 e7                	jne    80150a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801523:	a1 04 40 80 00       	mov    0x804004,%eax
  801528:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	51                   	push   %ecx
  801532:	50                   	push   %eax
  801533:	68 c0 29 80 00       	push   $0x8029c0
  801538:	e8 7a ec ff ff       	call   8001b7 <cprintf>
	*dev = 0;
  80153d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801540:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 10             	sub    $0x10,%esp
  801558:	8b 75 08             	mov    0x8(%ebp),%esi
  80155b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801568:	c1 e8 0c             	shr    $0xc,%eax
  80156b:	50                   	push   %eax
  80156c:	e8 33 ff ff ff       	call   8014a4 <fd_lookup>
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 05                	js     80157d <fd_close+0x2d>
	    || fd != fd2)
  801578:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80157b:	74 0c                	je     801589 <fd_close+0x39>
		return (must_exist ? r : 0);
  80157d:	84 db                	test   %bl,%bl
  80157f:	ba 00 00 00 00       	mov    $0x0,%edx
  801584:	0f 44 c2             	cmove  %edx,%eax
  801587:	eb 41                	jmp    8015ca <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	ff 36                	pushl  (%esi)
  801592:	e8 63 ff ff ff       	call   8014fa <dev_lookup>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 1a                	js     8015ba <fd_close+0x6a>
		if (dev->dev_close)
  8015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	74 0b                	je     8015ba <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	56                   	push   %esi
  8015b3:	ff d0                	call   *%eax
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	56                   	push   %esi
  8015be:	6a 00                	push   $0x0
  8015c0:	e8 ff f5 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	89 d8                	mov    %ebx,%eax
}
  8015ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 c1 fe ff ff       	call   8014a4 <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 10                	js     8015fa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	6a 01                	push   $0x1
  8015ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f2:	e8 59 ff ff ff       	call   801550 <fd_close>
  8015f7:	83 c4 10             	add    $0x10,%esp
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <close_all>:

void
close_all(void)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801603:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801608:	83 ec 0c             	sub    $0xc,%esp
  80160b:	53                   	push   %ebx
  80160c:	e8 c0 ff ff ff       	call   8015d1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801611:	83 c3 01             	add    $0x1,%ebx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	83 fb 20             	cmp    $0x20,%ebx
  80161a:	75 ec                	jne    801608 <close_all+0xc>
		close(i);
}
  80161c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	57                   	push   %edi
  801625:	56                   	push   %esi
  801626:	53                   	push   %ebx
  801627:	83 ec 2c             	sub    $0x2c,%esp
  80162a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80162d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	ff 75 08             	pushl  0x8(%ebp)
  801634:	e8 6b fe ff ff       	call   8014a4 <fd_lookup>
  801639:	83 c4 08             	add    $0x8,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	0f 88 c1 00 00 00    	js     801705 <dup+0xe4>
		return r;
	close(newfdnum);
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	56                   	push   %esi
  801648:	e8 84 ff ff ff       	call   8015d1 <close>

	newfd = INDEX2FD(newfdnum);
  80164d:	89 f3                	mov    %esi,%ebx
  80164f:	c1 e3 0c             	shl    $0xc,%ebx
  801652:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801658:	83 c4 04             	add    $0x4,%esp
  80165b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165e:	e8 db fd ff ff       	call   80143e <fd2data>
  801663:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801665:	89 1c 24             	mov    %ebx,(%esp)
  801668:	e8 d1 fd ff ff       	call   80143e <fd2data>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801673:	89 f8                	mov    %edi,%eax
  801675:	c1 e8 16             	shr    $0x16,%eax
  801678:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80167f:	a8 01                	test   $0x1,%al
  801681:	74 37                	je     8016ba <dup+0x99>
  801683:	89 f8                	mov    %edi,%eax
  801685:	c1 e8 0c             	shr    $0xc,%eax
  801688:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80168f:	f6 c2 01             	test   $0x1,%dl
  801692:	74 26                	je     8016ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801694:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a3:	50                   	push   %eax
  8016a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a7:	6a 00                	push   $0x0
  8016a9:	57                   	push   %edi
  8016aa:	6a 00                	push   $0x0
  8016ac:	e8 d1 f4 ff ff       	call   800b82 <sys_page_map>
  8016b1:	89 c7                	mov    %eax,%edi
  8016b3:	83 c4 20             	add    $0x20,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 2e                	js     8016e8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016bd:	89 d0                	mov    %edx,%eax
  8016bf:	c1 e8 0c             	shr    $0xc,%eax
  8016c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8016d1:	50                   	push   %eax
  8016d2:	53                   	push   %ebx
  8016d3:	6a 00                	push   $0x0
  8016d5:	52                   	push   %edx
  8016d6:	6a 00                	push   $0x0
  8016d8:	e8 a5 f4 ff ff       	call   800b82 <sys_page_map>
  8016dd:	89 c7                	mov    %eax,%edi
  8016df:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016e2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e4:	85 ff                	test   %edi,%edi
  8016e6:	79 1d                	jns    801705 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	53                   	push   %ebx
  8016ec:	6a 00                	push   $0x0
  8016ee:	e8 d1 f4 ff ff       	call   800bc4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016f3:	83 c4 08             	add    $0x8,%esp
  8016f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f9:	6a 00                	push   $0x0
  8016fb:	e8 c4 f4 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	89 f8                	mov    %edi,%eax
}
  801705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5f                   	pop    %edi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	83 ec 14             	sub    $0x14,%esp
  801714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	53                   	push   %ebx
  80171c:	e8 83 fd ff ff       	call   8014a4 <fd_lookup>
  801721:	83 c4 08             	add    $0x8,%esp
  801724:	89 c2                	mov    %eax,%edx
  801726:	85 c0                	test   %eax,%eax
  801728:	78 70                	js     80179a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801730:	50                   	push   %eax
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	ff 30                	pushl  (%eax)
  801736:	e8 bf fd ff ff       	call   8014fa <dev_lookup>
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 4f                	js     801791 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801742:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801745:	8b 42 08             	mov    0x8(%edx),%eax
  801748:	83 e0 03             	and    $0x3,%eax
  80174b:	83 f8 01             	cmp    $0x1,%eax
  80174e:	75 24                	jne    801774 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801750:	a1 04 40 80 00       	mov    0x804004,%eax
  801755:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	53                   	push   %ebx
  80175f:	50                   	push   %eax
  801760:	68 01 2a 80 00       	push   $0x802a01
  801765:	e8 4d ea ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801772:	eb 26                	jmp    80179a <read+0x8d>
	}
	if (!dev->dev_read)
  801774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801777:	8b 40 08             	mov    0x8(%eax),%eax
  80177a:	85 c0                	test   %eax,%eax
  80177c:	74 17                	je     801795 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80177e:	83 ec 04             	sub    $0x4,%esp
  801781:	ff 75 10             	pushl  0x10(%ebp)
  801784:	ff 75 0c             	pushl  0xc(%ebp)
  801787:	52                   	push   %edx
  801788:	ff d0                	call   *%eax
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	eb 09                	jmp    80179a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801791:	89 c2                	mov    %eax,%edx
  801793:	eb 05                	jmp    80179a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801795:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80179a:	89 d0                	mov    %edx,%eax
  80179c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	57                   	push   %edi
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 0c             	sub    $0xc,%esp
  8017aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b5:	eb 21                	jmp    8017d8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	89 f0                	mov    %esi,%eax
  8017bc:	29 d8                	sub    %ebx,%eax
  8017be:	50                   	push   %eax
  8017bf:	89 d8                	mov    %ebx,%eax
  8017c1:	03 45 0c             	add    0xc(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	57                   	push   %edi
  8017c6:	e8 42 ff ff ff       	call   80170d <read>
		if (m < 0)
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 10                	js     8017e2 <readn+0x41>
			return m;
		if (m == 0)
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	74 0a                	je     8017e0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d6:	01 c3                	add    %eax,%ebx
  8017d8:	39 f3                	cmp    %esi,%ebx
  8017da:	72 db                	jb     8017b7 <readn+0x16>
  8017dc:	89 d8                	mov    %ebx,%eax
  8017de:	eb 02                	jmp    8017e2 <readn+0x41>
  8017e0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 14             	sub    $0x14,%esp
  8017f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	53                   	push   %ebx
  8017f9:	e8 a6 fc ff ff       	call   8014a4 <fd_lookup>
  8017fe:	83 c4 08             	add    $0x8,%esp
  801801:	89 c2                	mov    %eax,%edx
  801803:	85 c0                	test   %eax,%eax
  801805:	78 6b                	js     801872 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	50                   	push   %eax
  80180e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801811:	ff 30                	pushl  (%eax)
  801813:	e8 e2 fc ff ff       	call   8014fa <dev_lookup>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 4a                	js     801869 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801822:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801826:	75 24                	jne    80184c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801828:	a1 04 40 80 00       	mov    0x804004,%eax
  80182d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801833:	83 ec 04             	sub    $0x4,%esp
  801836:	53                   	push   %ebx
  801837:	50                   	push   %eax
  801838:	68 1d 2a 80 00       	push   $0x802a1d
  80183d:	e8 75 e9 ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80184a:	eb 26                	jmp    801872 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80184c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184f:	8b 52 0c             	mov    0xc(%edx),%edx
  801852:	85 d2                	test   %edx,%edx
  801854:	74 17                	je     80186d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	ff 75 10             	pushl  0x10(%ebp)
  80185c:	ff 75 0c             	pushl  0xc(%ebp)
  80185f:	50                   	push   %eax
  801860:	ff d2                	call   *%edx
  801862:	89 c2                	mov    %eax,%edx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	eb 09                	jmp    801872 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801869:	89 c2                	mov    %eax,%edx
  80186b:	eb 05                	jmp    801872 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80186d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801872:	89 d0                	mov    %edx,%eax
  801874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <seek>:

int
seek(int fdnum, off_t offset)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801882:	50                   	push   %eax
  801883:	ff 75 08             	pushl  0x8(%ebp)
  801886:	e8 19 fc ff ff       	call   8014a4 <fd_lookup>
  80188b:	83 c4 08             	add    $0x8,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 0e                	js     8018a0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801892:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801895:	8b 55 0c             	mov    0xc(%ebp),%edx
  801898:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 14             	sub    $0x14,%esp
  8018a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	53                   	push   %ebx
  8018b1:	e8 ee fb ff ff       	call   8014a4 <fd_lookup>
  8018b6:	83 c4 08             	add    $0x8,%esp
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 68                	js     801927 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c9:	ff 30                	pushl  (%eax)
  8018cb:	e8 2a fc ff ff       	call   8014fa <dev_lookup>
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 47                	js     80191e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018de:	75 24                	jne    801904 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018e0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018e5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	53                   	push   %ebx
  8018ef:	50                   	push   %eax
  8018f0:	68 e0 29 80 00       	push   $0x8029e0
  8018f5:	e8 bd e8 ff ff       	call   8001b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801902:	eb 23                	jmp    801927 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801904:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801907:	8b 52 18             	mov    0x18(%edx),%edx
  80190a:	85 d2                	test   %edx,%edx
  80190c:	74 14                	je     801922 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	50                   	push   %eax
  801915:	ff d2                	call   *%edx
  801917:	89 c2                	mov    %eax,%edx
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	eb 09                	jmp    801927 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191e:	89 c2                	mov    %eax,%edx
  801920:	eb 05                	jmp    801927 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801922:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801927:	89 d0                	mov    %edx,%eax
  801929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 14             	sub    $0x14,%esp
  801935:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801938:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	ff 75 08             	pushl  0x8(%ebp)
  80193f:	e8 60 fb ff ff       	call   8014a4 <fd_lookup>
  801944:	83 c4 08             	add    $0x8,%esp
  801947:	89 c2                	mov    %eax,%edx
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 58                	js     8019a5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801953:	50                   	push   %eax
  801954:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801957:	ff 30                	pushl  (%eax)
  801959:	e8 9c fb ff ff       	call   8014fa <dev_lookup>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	78 37                	js     80199c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801965:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801968:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80196c:	74 32                	je     8019a0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80196e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801971:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801978:	00 00 00 
	stat->st_isdir = 0;
  80197b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801982:	00 00 00 
	stat->st_dev = dev;
  801985:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	53                   	push   %ebx
  80198f:	ff 75 f0             	pushl  -0x10(%ebp)
  801992:	ff 50 14             	call   *0x14(%eax)
  801995:	89 c2                	mov    %eax,%edx
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	eb 09                	jmp    8019a5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199c:	89 c2                	mov    %eax,%edx
  80199e:	eb 05                	jmp    8019a5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019a5:	89 d0                	mov    %edx,%eax
  8019a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	6a 00                	push   $0x0
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 e3 01 00 00       	call   801ba1 <open>
  8019be:	89 c3                	mov    %eax,%ebx
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 1b                	js     8019e2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	50                   	push   %eax
  8019ce:	e8 5b ff ff ff       	call   80192e <fstat>
  8019d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d5:	89 1c 24             	mov    %ebx,(%esp)
  8019d8:	e8 f4 fb ff ff       	call   8015d1 <close>
	return r;
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	89 f0                	mov    %esi,%eax
}
  8019e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	89 c6                	mov    %eax,%esi
  8019f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019f9:	75 12                	jne    801a0d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	6a 01                	push   $0x1
  801a00:	e8 e4 f9 ff ff       	call   8013e9 <ipc_find_env>
  801a05:	a3 00 40 80 00       	mov    %eax,0x804000
  801a0a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a0d:	6a 07                	push   $0x7
  801a0f:	68 00 50 80 00       	push   $0x805000
  801a14:	56                   	push   %esi
  801a15:	ff 35 00 40 80 00    	pushl  0x804000
  801a1b:	e8 67 f9 ff ff       	call   801387 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a20:	83 c4 0c             	add    $0xc,%esp
  801a23:	6a 00                	push   $0x0
  801a25:	53                   	push   %ebx
  801a26:	6a 00                	push   $0x0
  801a28:	e8 df f8 ff ff       	call   80130c <ipc_recv>
}
  801a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a40:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a52:	b8 02 00 00 00       	mov    $0x2,%eax
  801a57:	e8 8d ff ff ff       	call   8019e9 <fsipc>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a74:	b8 06 00 00 00       	mov    $0x6,%eax
  801a79:	e8 6b ff ff ff       	call   8019e9 <fsipc>
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 04             	sub    $0x4,%esp
  801a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a90:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a95:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a9f:	e8 45 ff ff ff       	call   8019e9 <fsipc>
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	78 2c                	js     801ad4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aa8:	83 ec 08             	sub    $0x8,%esp
  801aab:	68 00 50 80 00       	push   $0x805000
  801ab0:	53                   	push   %ebx
  801ab1:	e8 86 ec ff ff       	call   80073c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ab6:	a1 80 50 80 00       	mov    0x805080,%eax
  801abb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac1:	a1 84 50 80 00       	mov    0x805084,%eax
  801ac6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae5:	8b 52 0c             	mov    0xc(%edx),%edx
  801ae8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801af3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af8:	0f 47 c2             	cmova  %edx,%eax
  801afb:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b00:	50                   	push   %eax
  801b01:	ff 75 0c             	pushl  0xc(%ebp)
  801b04:	68 08 50 80 00       	push   $0x805008
  801b09:	e8 c0 ed ff ff       	call   8008ce <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b13:	b8 04 00 00 00       	mov    $0x4,%eax
  801b18:	e8 cc fe ff ff       	call   8019e9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	56                   	push   %esi
  801b23:	53                   	push   %ebx
  801b24:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b27:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b32:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b38:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  801b42:	e8 a2 fe ff ff       	call   8019e9 <fsipc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 4b                	js     801b98 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b4d:	39 c6                	cmp    %eax,%esi
  801b4f:	73 16                	jae    801b67 <devfile_read+0x48>
  801b51:	68 4c 2a 80 00       	push   $0x802a4c
  801b56:	68 53 2a 80 00       	push   $0x802a53
  801b5b:	6a 7c                	push   $0x7c
  801b5d:	68 68 2a 80 00       	push   $0x802a68
  801b62:	e8 c6 05 00 00       	call   80212d <_panic>
	assert(r <= PGSIZE);
  801b67:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b6c:	7e 16                	jle    801b84 <devfile_read+0x65>
  801b6e:	68 73 2a 80 00       	push   $0x802a73
  801b73:	68 53 2a 80 00       	push   $0x802a53
  801b78:	6a 7d                	push   $0x7d
  801b7a:	68 68 2a 80 00       	push   $0x802a68
  801b7f:	e8 a9 05 00 00       	call   80212d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	50                   	push   %eax
  801b88:	68 00 50 80 00       	push   $0x805000
  801b8d:	ff 75 0c             	pushl  0xc(%ebp)
  801b90:	e8 39 ed ff ff       	call   8008ce <memmove>
	return r;
  801b95:	83 c4 10             	add    $0x10,%esp
}
  801b98:	89 d8                	mov    %ebx,%eax
  801b9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	53                   	push   %ebx
  801ba5:	83 ec 20             	sub    $0x20,%esp
  801ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bab:	53                   	push   %ebx
  801bac:	e8 52 eb ff ff       	call   800703 <strlen>
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bb9:	7f 67                	jg     801c22 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bbb:	83 ec 0c             	sub    $0xc,%esp
  801bbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc1:	50                   	push   %eax
  801bc2:	e8 8e f8 ff ff       	call   801455 <fd_alloc>
  801bc7:	83 c4 10             	add    $0x10,%esp
		return r;
  801bca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	78 57                	js     801c27 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bd0:	83 ec 08             	sub    $0x8,%esp
  801bd3:	53                   	push   %ebx
  801bd4:	68 00 50 80 00       	push   $0x805000
  801bd9:	e8 5e eb ff ff       	call   80073c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bee:	e8 f6 fd ff ff       	call   8019e9 <fsipc>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	79 14                	jns    801c10 <open+0x6f>
		fd_close(fd, 0);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	6a 00                	push   $0x0
  801c01:	ff 75 f4             	pushl  -0xc(%ebp)
  801c04:	e8 47 f9 ff ff       	call   801550 <fd_close>
		return r;
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	89 da                	mov    %ebx,%edx
  801c0e:	eb 17                	jmp    801c27 <open+0x86>
	}

	return fd2num(fd);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 f4             	pushl  -0xc(%ebp)
  801c16:	e8 13 f8 ff ff       	call   80142e <fd2num>
  801c1b:	89 c2                	mov    %eax,%edx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	eb 05                	jmp    801c27 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c22:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c27:	89 d0                	mov    %edx,%eax
  801c29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c34:	ba 00 00 00 00       	mov    $0x0,%edx
  801c39:	b8 08 00 00 00       	mov    $0x8,%eax
  801c3e:	e8 a6 fd ff ff       	call   8019e9 <fsipc>
}
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 08             	pushl  0x8(%ebp)
  801c53:	e8 e6 f7 ff ff       	call   80143e <fd2data>
  801c58:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c5a:	83 c4 08             	add    $0x8,%esp
  801c5d:	68 7f 2a 80 00       	push   $0x802a7f
  801c62:	53                   	push   %ebx
  801c63:	e8 d4 ea ff ff       	call   80073c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c68:	8b 46 04             	mov    0x4(%esi),%eax
  801c6b:	2b 06                	sub    (%esi),%eax
  801c6d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c73:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c7a:	00 00 00 
	stat->st_dev = &devpipe;
  801c7d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c84:	30 80 00 
	return 0;
}
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	53                   	push   %ebx
  801c97:	83 ec 0c             	sub    $0xc,%esp
  801c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c9d:	53                   	push   %ebx
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 1f ef ff ff       	call   800bc4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ca5:	89 1c 24             	mov    %ebx,(%esp)
  801ca8:	e8 91 f7 ff ff       	call   80143e <fd2data>
  801cad:	83 c4 08             	add    $0x8,%esp
  801cb0:	50                   	push   %eax
  801cb1:	6a 00                	push   $0x0
  801cb3:	e8 0c ef ff ff       	call   800bc4 <sys_page_unmap>
}
  801cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	57                   	push   %edi
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	83 ec 1c             	sub    $0x1c,%esp
  801cc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cc9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ccb:	a1 04 40 80 00       	mov    0x804004,%eax
  801cd0:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cd6:	83 ec 0c             	sub    $0xc,%esp
  801cd9:	ff 75 e0             	pushl  -0x20(%ebp)
  801cdc:	e8 21 05 00 00       	call   802202 <pageref>
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	e8 17 05 00 00       	call   802202 <pageref>
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	39 c3                	cmp    %eax,%ebx
  801cf0:	0f 94 c1             	sete   %cl
  801cf3:	0f b6 c9             	movzbl %cl,%ecx
  801cf6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cf9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cff:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d05:	39 ce                	cmp    %ecx,%esi
  801d07:	74 1e                	je     801d27 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d09:	39 c3                	cmp    %eax,%ebx
  801d0b:	75 be                	jne    801ccb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d0d:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801d13:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d16:	50                   	push   %eax
  801d17:	56                   	push   %esi
  801d18:	68 86 2a 80 00       	push   $0x802a86
  801d1d:	e8 95 e4 ff ff       	call   8001b7 <cprintf>
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	eb a4                	jmp    801ccb <_pipeisclosed+0xe>
	}
}
  801d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    

00801d32 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	53                   	push   %ebx
  801d38:	83 ec 28             	sub    $0x28,%esp
  801d3b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d3e:	56                   	push   %esi
  801d3f:	e8 fa f6 ff ff       	call   80143e <fd2data>
  801d44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	bf 00 00 00 00       	mov    $0x0,%edi
  801d4e:	eb 4b                	jmp    801d9b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d50:	89 da                	mov    %ebx,%edx
  801d52:	89 f0                	mov    %esi,%eax
  801d54:	e8 64 ff ff ff       	call   801cbd <_pipeisclosed>
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	75 48                	jne    801da5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d5d:	e8 be ed ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d62:	8b 43 04             	mov    0x4(%ebx),%eax
  801d65:	8b 0b                	mov    (%ebx),%ecx
  801d67:	8d 51 20             	lea    0x20(%ecx),%edx
  801d6a:	39 d0                	cmp    %edx,%eax
  801d6c:	73 e2                	jae    801d50 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d71:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d75:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d78:	89 c2                	mov    %eax,%edx
  801d7a:	c1 fa 1f             	sar    $0x1f,%edx
  801d7d:	89 d1                	mov    %edx,%ecx
  801d7f:	c1 e9 1b             	shr    $0x1b,%ecx
  801d82:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d85:	83 e2 1f             	and    $0x1f,%edx
  801d88:	29 ca                	sub    %ecx,%edx
  801d8a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d8e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d92:	83 c0 01             	add    $0x1,%eax
  801d95:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d98:	83 c7 01             	add    $0x1,%edi
  801d9b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9e:	75 c2                	jne    801d62 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da0:	8b 45 10             	mov    0x10(%ebp),%eax
  801da3:	eb 05                	jmp    801daa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 18             	sub    $0x18,%esp
  801dbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dbe:	57                   	push   %edi
  801dbf:	e8 7a f6 ff ff       	call   80143e <fd2data>
  801dc4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dce:	eb 3d                	jmp    801e0d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd0:	85 db                	test   %ebx,%ebx
  801dd2:	74 04                	je     801dd8 <devpipe_read+0x26>
				return i;
  801dd4:	89 d8                	mov    %ebx,%eax
  801dd6:	eb 44                	jmp    801e1c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dd8:	89 f2                	mov    %esi,%edx
  801dda:	89 f8                	mov    %edi,%eax
  801ddc:	e8 dc fe ff ff       	call   801cbd <_pipeisclosed>
  801de1:	85 c0                	test   %eax,%eax
  801de3:	75 32                	jne    801e17 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801de5:	e8 36 ed ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dea:	8b 06                	mov    (%esi),%eax
  801dec:	3b 46 04             	cmp    0x4(%esi),%eax
  801def:	74 df                	je     801dd0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df1:	99                   	cltd   
  801df2:	c1 ea 1b             	shr    $0x1b,%edx
  801df5:	01 d0                	add    %edx,%eax
  801df7:	83 e0 1f             	and    $0x1f,%eax
  801dfa:	29 d0                	sub    %edx,%eax
  801dfc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e04:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e07:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0a:	83 c3 01             	add    $0x1,%ebx
  801e0d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e10:	75 d8                	jne    801dea <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e12:	8b 45 10             	mov    0x10(%ebp),%eax
  801e15:	eb 05                	jmp    801e1c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
  801e29:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2f:	50                   	push   %eax
  801e30:	e8 20 f6 ff ff       	call   801455 <fd_alloc>
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	89 c2                	mov    %eax,%edx
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	0f 88 2c 01 00 00    	js     801f6e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	68 07 04 00 00       	push   $0x407
  801e4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 eb ec ff ff       	call   800b3f <sys_page_alloc>
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	89 c2                	mov    %eax,%edx
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	0f 88 0d 01 00 00    	js     801f6e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e61:	83 ec 0c             	sub    $0xc,%esp
  801e64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e67:	50                   	push   %eax
  801e68:	e8 e8 f5 ff ff       	call   801455 <fd_alloc>
  801e6d:	89 c3                	mov    %eax,%ebx
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	85 c0                	test   %eax,%eax
  801e74:	0f 88 e2 00 00 00    	js     801f5c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7a:	83 ec 04             	sub    $0x4,%esp
  801e7d:	68 07 04 00 00       	push   $0x407
  801e82:	ff 75 f0             	pushl  -0x10(%ebp)
  801e85:	6a 00                	push   $0x0
  801e87:	e8 b3 ec ff ff       	call   800b3f <sys_page_alloc>
  801e8c:	89 c3                	mov    %eax,%ebx
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	0f 88 c3 00 00 00    	js     801f5c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9f:	e8 9a f5 ff ff       	call   80143e <fd2data>
  801ea4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea6:	83 c4 0c             	add    $0xc,%esp
  801ea9:	68 07 04 00 00       	push   $0x407
  801eae:	50                   	push   %eax
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 89 ec ff ff       	call   800b3f <sys_page_alloc>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 89 00 00 00    	js     801f4c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec9:	e8 70 f5 ff ff       	call   80143e <fd2data>
  801ece:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ed5:	50                   	push   %eax
  801ed6:	6a 00                	push   $0x0
  801ed8:	56                   	push   %esi
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 a2 ec ff ff       	call   800b82 <sys_page_map>
  801ee0:	89 c3                	mov    %eax,%ebx
  801ee2:	83 c4 20             	add    $0x20,%esp
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 55                	js     801f3e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ee9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801efe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f07:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	ff 75 f4             	pushl  -0xc(%ebp)
  801f19:	e8 10 f5 ff ff       	call   80142e <fd2num>
  801f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f21:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f23:	83 c4 04             	add    $0x4,%esp
  801f26:	ff 75 f0             	pushl  -0x10(%ebp)
  801f29:	e8 00 f5 ff ff       	call   80142e <fd2num>
  801f2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f31:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3c:	eb 30                	jmp    801f6e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	56                   	push   %esi
  801f42:	6a 00                	push   $0x0
  801f44:	e8 7b ec ff ff       	call   800bc4 <sys_page_unmap>
  801f49:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f4c:	83 ec 08             	sub    $0x8,%esp
  801f4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f52:	6a 00                	push   $0x0
  801f54:	e8 6b ec ff ff       	call   800bc4 <sys_page_unmap>
  801f59:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f5c:	83 ec 08             	sub    $0x8,%esp
  801f5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f62:	6a 00                	push   $0x0
  801f64:	e8 5b ec ff ff       	call   800bc4 <sys_page_unmap>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f6e:	89 d0                	mov    %edx,%eax
  801f70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	ff 75 08             	pushl  0x8(%ebp)
  801f84:	e8 1b f5 ff ff       	call   8014a4 <fd_lookup>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 18                	js     801fa8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	e8 a3 f4 ff ff       	call   80143e <fd2data>
	return _pipeisclosed(fd, p);
  801f9b:	89 c2                	mov    %eax,%edx
  801f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa0:	e8 18 fd ff ff       	call   801cbd <_pipeisclosed>
  801fa5:	83 c4 10             	add    $0x10,%esp
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    

00801fb4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fba:	68 9e 2a 80 00       	push   $0x802a9e
  801fbf:	ff 75 0c             	pushl  0xc(%ebp)
  801fc2:	e8 75 e7 ff ff       	call   80073c <strcpy>
	return 0;
}
  801fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fda:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fdf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe5:	eb 2d                	jmp    802014 <devcons_write+0x46>
		m = n - tot;
  801fe7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fea:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fec:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fef:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff7:	83 ec 04             	sub    $0x4,%esp
  801ffa:	53                   	push   %ebx
  801ffb:	03 45 0c             	add    0xc(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	57                   	push   %edi
  802000:	e8 c9 e8 ff ff       	call   8008ce <memmove>
		sys_cputs(buf, m);
  802005:	83 c4 08             	add    $0x8,%esp
  802008:	53                   	push   %ebx
  802009:	57                   	push   %edi
  80200a:	e8 74 ea ff ff       	call   800a83 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200f:	01 de                	add    %ebx,%esi
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	89 f0                	mov    %esi,%eax
  802016:	3b 75 10             	cmp    0x10(%ebp),%esi
  802019:	72 cc                	jb     801fe7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80201b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201e:	5b                   	pop    %ebx
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    

00802023 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	83 ec 08             	sub    $0x8,%esp
  802029:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80202e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802032:	74 2a                	je     80205e <devcons_read+0x3b>
  802034:	eb 05                	jmp    80203b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802036:	e8 e5 ea ff ff       	call   800b20 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80203b:	e8 61 ea ff ff       	call   800aa1 <sys_cgetc>
  802040:	85 c0                	test   %eax,%eax
  802042:	74 f2                	je     802036 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802044:	85 c0                	test   %eax,%eax
  802046:	78 16                	js     80205e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802048:	83 f8 04             	cmp    $0x4,%eax
  80204b:	74 0c                	je     802059 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80204d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802050:	88 02                	mov    %al,(%edx)
	return 1;
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb 05                	jmp    80205e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802059:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80206c:	6a 01                	push   $0x1
  80206e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802071:	50                   	push   %eax
  802072:	e8 0c ea ff ff       	call   800a83 <sys_cputs>
}
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	c9                   	leave  
  80207b:	c3                   	ret    

0080207c <getchar>:

int
getchar(void)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802082:	6a 01                	push   $0x1
  802084:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802087:	50                   	push   %eax
  802088:	6a 00                	push   $0x0
  80208a:	e8 7e f6 ff ff       	call   80170d <read>
	if (r < 0)
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	85 c0                	test   %eax,%eax
  802094:	78 0f                	js     8020a5 <getchar+0x29>
		return r;
	if (r < 1)
  802096:	85 c0                	test   %eax,%eax
  802098:	7e 06                	jle    8020a0 <getchar+0x24>
		return -E_EOF;
	return c;
  80209a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80209e:	eb 05                	jmp    8020a5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020a0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020a5:	c9                   	leave  
  8020a6:	c3                   	ret    

008020a7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b0:	50                   	push   %eax
  8020b1:	ff 75 08             	pushl  0x8(%ebp)
  8020b4:	e8 eb f3 ff ff       	call   8014a4 <fd_lookup>
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	78 11                	js     8020d1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c9:	39 10                	cmp    %edx,(%eax)
  8020cb:	0f 94 c0             	sete   %al
  8020ce:	0f b6 c0             	movzbl %al,%eax
}
  8020d1:	c9                   	leave  
  8020d2:	c3                   	ret    

008020d3 <opencons>:

int
opencons(void)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020dc:	50                   	push   %eax
  8020dd:	e8 73 f3 ff ff       	call   801455 <fd_alloc>
  8020e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	78 3e                	js     802129 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020eb:	83 ec 04             	sub    $0x4,%esp
  8020ee:	68 07 04 00 00       	push   $0x407
  8020f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 42 ea ff ff       	call   800b3f <sys_page_alloc>
  8020fd:	83 c4 10             	add    $0x10,%esp
		return r;
  802100:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802102:	85 c0                	test   %eax,%eax
  802104:	78 23                	js     802129 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802106:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80211b:	83 ec 0c             	sub    $0xc,%esp
  80211e:	50                   	push   %eax
  80211f:	e8 0a f3 ff ff       	call   80142e <fd2num>
  802124:	89 c2                	mov    %eax,%edx
  802126:	83 c4 10             	add    $0x10,%esp
}
  802129:	89 d0                	mov    %edx,%eax
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    

0080212d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	56                   	push   %esi
  802131:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802132:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802135:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80213b:	e8 c1 e9 ff ff       	call   800b01 <sys_getenvid>
  802140:	83 ec 0c             	sub    $0xc,%esp
  802143:	ff 75 0c             	pushl  0xc(%ebp)
  802146:	ff 75 08             	pushl  0x8(%ebp)
  802149:	56                   	push   %esi
  80214a:	50                   	push   %eax
  80214b:	68 ac 2a 80 00       	push   $0x802aac
  802150:	e8 62 e0 ff ff       	call   8001b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802155:	83 c4 18             	add    $0x18,%esp
  802158:	53                   	push   %ebx
  802159:	ff 75 10             	pushl  0x10(%ebp)
  80215c:	e8 05 e0 ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  802161:	c7 04 24 e6 28 80 00 	movl   $0x8028e6,(%esp)
  802168:	e8 4a e0 ff ff       	call   8001b7 <cprintf>
  80216d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802170:	cc                   	int3   
  802171:	eb fd                	jmp    802170 <_panic+0x43>

00802173 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802179:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802180:	75 2a                	jne    8021ac <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802182:	83 ec 04             	sub    $0x4,%esp
  802185:	6a 07                	push   $0x7
  802187:	68 00 f0 bf ee       	push   $0xeebff000
  80218c:	6a 00                	push   $0x0
  80218e:	e8 ac e9 ff ff       	call   800b3f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802193:	83 c4 10             	add    $0x10,%esp
  802196:	85 c0                	test   %eax,%eax
  802198:	79 12                	jns    8021ac <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80219a:	50                   	push   %eax
  80219b:	68 18 29 80 00       	push   $0x802918
  8021a0:	6a 23                	push   $0x23
  8021a2:	68 d0 2a 80 00       	push   $0x802ad0
  8021a7:	e8 81 ff ff ff       	call   80212d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8021af:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021b4:	83 ec 08             	sub    $0x8,%esp
  8021b7:	68 de 21 80 00       	push   $0x8021de
  8021bc:	6a 00                	push   $0x0
  8021be:	e8 c7 ea ff ff       	call   800c8a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	79 12                	jns    8021dc <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021ca:	50                   	push   %eax
  8021cb:	68 18 29 80 00       	push   $0x802918
  8021d0:	6a 2c                	push   $0x2c
  8021d2:	68 d0 2a 80 00       	push   $0x802ad0
  8021d7:	e8 51 ff ff ff       	call   80212d <_panic>
	}
}
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021de:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021df:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021e4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021e9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021ed:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021f2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021f6:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021f8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021fb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021fc:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8021ff:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802200:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802201:	c3                   	ret    

00802202 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802208:	89 d0                	mov    %edx,%eax
  80220a:	c1 e8 16             	shr    $0x16,%eax
  80220d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802214:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802219:	f6 c1 01             	test   $0x1,%cl
  80221c:	74 1d                	je     80223b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80221e:	c1 ea 0c             	shr    $0xc,%edx
  802221:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802228:	f6 c2 01             	test   $0x1,%dl
  80222b:	74 0e                	je     80223b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80222d:	c1 ea 0c             	shr    $0xc,%edx
  802230:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802237:	ef 
  802238:	0f b7 c0             	movzwl %ax,%eax
}
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	66 90                	xchg   %ax,%ax
  80223f:	90                   	nop

00802240 <__udivdi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80224b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80224f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 f6                	test   %esi,%esi
  802259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80225d:	89 ca                	mov    %ecx,%edx
  80225f:	89 f8                	mov    %edi,%eax
  802261:	75 3d                	jne    8022a0 <__udivdi3+0x60>
  802263:	39 cf                	cmp    %ecx,%edi
  802265:	0f 87 c5 00 00 00    	ja     802330 <__udivdi3+0xf0>
  80226b:	85 ff                	test   %edi,%edi
  80226d:	89 fd                	mov    %edi,%ebp
  80226f:	75 0b                	jne    80227c <__udivdi3+0x3c>
  802271:	b8 01 00 00 00       	mov    $0x1,%eax
  802276:	31 d2                	xor    %edx,%edx
  802278:	f7 f7                	div    %edi
  80227a:	89 c5                	mov    %eax,%ebp
  80227c:	89 c8                	mov    %ecx,%eax
  80227e:	31 d2                	xor    %edx,%edx
  802280:	f7 f5                	div    %ebp
  802282:	89 c1                	mov    %eax,%ecx
  802284:	89 d8                	mov    %ebx,%eax
  802286:	89 cf                	mov    %ecx,%edi
  802288:	f7 f5                	div    %ebp
  80228a:	89 c3                	mov    %eax,%ebx
  80228c:	89 d8                	mov    %ebx,%eax
  80228e:	89 fa                	mov    %edi,%edx
  802290:	83 c4 1c             	add    $0x1c,%esp
  802293:	5b                   	pop    %ebx
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
  802298:	90                   	nop
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	39 ce                	cmp    %ecx,%esi
  8022a2:	77 74                	ja     802318 <__udivdi3+0xd8>
  8022a4:	0f bd fe             	bsr    %esi,%edi
  8022a7:	83 f7 1f             	xor    $0x1f,%edi
  8022aa:	0f 84 98 00 00 00    	je     802348 <__udivdi3+0x108>
  8022b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	89 c5                	mov    %eax,%ebp
  8022b9:	29 fb                	sub    %edi,%ebx
  8022bb:	d3 e6                	shl    %cl,%esi
  8022bd:	89 d9                	mov    %ebx,%ecx
  8022bf:	d3 ed                	shr    %cl,%ebp
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	d3 e0                	shl    %cl,%eax
  8022c5:	09 ee                	or     %ebp,%esi
  8022c7:	89 d9                	mov    %ebx,%ecx
  8022c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022cd:	89 d5                	mov    %edx,%ebp
  8022cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022d3:	d3 ed                	shr    %cl,%ebp
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e2                	shl    %cl,%edx
  8022d9:	89 d9                	mov    %ebx,%ecx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	09 c2                	or     %eax,%edx
  8022df:	89 d0                	mov    %edx,%eax
  8022e1:	89 ea                	mov    %ebp,%edx
  8022e3:	f7 f6                	div    %esi
  8022e5:	89 d5                	mov    %edx,%ebp
  8022e7:	89 c3                	mov    %eax,%ebx
  8022e9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ed:	39 d5                	cmp    %edx,%ebp
  8022ef:	72 10                	jb     802301 <__udivdi3+0xc1>
  8022f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e6                	shl    %cl,%esi
  8022f9:	39 c6                	cmp    %eax,%esi
  8022fb:	73 07                	jae    802304 <__udivdi3+0xc4>
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	75 03                	jne    802304 <__udivdi3+0xc4>
  802301:	83 eb 01             	sub    $0x1,%ebx
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 d8                	mov    %ebx,%eax
  802308:	89 fa                	mov    %edi,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	31 ff                	xor    %edi,%edi
  80231a:	31 db                	xor    %ebx,%ebx
  80231c:	89 d8                	mov    %ebx,%eax
  80231e:	89 fa                	mov    %edi,%edx
  802320:	83 c4 1c             	add    $0x1c,%esp
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    
  802328:	90                   	nop
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 d8                	mov    %ebx,%eax
  802332:	f7 f7                	div    %edi
  802334:	31 ff                	xor    %edi,%edi
  802336:	89 c3                	mov    %eax,%ebx
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	89 fa                	mov    %edi,%edx
  80233c:	83 c4 1c             	add    $0x1c,%esp
  80233f:	5b                   	pop    %ebx
  802340:	5e                   	pop    %esi
  802341:	5f                   	pop    %edi
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	39 ce                	cmp    %ecx,%esi
  80234a:	72 0c                	jb     802358 <__udivdi3+0x118>
  80234c:	31 db                	xor    %ebx,%ebx
  80234e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802352:	0f 87 34 ff ff ff    	ja     80228c <__udivdi3+0x4c>
  802358:	bb 01 00 00 00       	mov    $0x1,%ebx
  80235d:	e9 2a ff ff ff       	jmp    80228c <__udivdi3+0x4c>
  802362:	66 90                	xchg   %ax,%ax
  802364:	66 90                	xchg   %ax,%ax
  802366:	66 90                	xchg   %ax,%ax
  802368:	66 90                	xchg   %ax,%ax
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__umoddi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 1c             	sub    $0x1c,%esp
  802377:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80237b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80237f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802383:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802387:	85 d2                	test   %edx,%edx
  802389:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 f3                	mov    %esi,%ebx
  802393:	89 3c 24             	mov    %edi,(%esp)
  802396:	89 74 24 04          	mov    %esi,0x4(%esp)
  80239a:	75 1c                	jne    8023b8 <__umoddi3+0x48>
  80239c:	39 f7                	cmp    %esi,%edi
  80239e:	76 50                	jbe    8023f0 <__umoddi3+0x80>
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	f7 f7                	div    %edi
  8023a6:	89 d0                	mov    %edx,%eax
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	83 c4 1c             	add    $0x1c,%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5f                   	pop    %edi
  8023b0:	5d                   	pop    %ebp
  8023b1:	c3                   	ret    
  8023b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b8:	39 f2                	cmp    %esi,%edx
  8023ba:	89 d0                	mov    %edx,%eax
  8023bc:	77 52                	ja     802410 <__umoddi3+0xa0>
  8023be:	0f bd ea             	bsr    %edx,%ebp
  8023c1:	83 f5 1f             	xor    $0x1f,%ebp
  8023c4:	75 5a                	jne    802420 <__umoddi3+0xb0>
  8023c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ca:	0f 82 e0 00 00 00    	jb     8024b0 <__umoddi3+0x140>
  8023d0:	39 0c 24             	cmp    %ecx,(%esp)
  8023d3:	0f 86 d7 00 00 00    	jbe    8024b0 <__umoddi3+0x140>
  8023d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023e1:	83 c4 1c             	add    $0x1c,%esp
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	85 ff                	test   %edi,%edi
  8023f2:	89 fd                	mov    %edi,%ebp
  8023f4:	75 0b                	jne    802401 <__umoddi3+0x91>
  8023f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f7                	div    %edi
  8023ff:	89 c5                	mov    %eax,%ebp
  802401:	89 f0                	mov    %esi,%eax
  802403:	31 d2                	xor    %edx,%edx
  802405:	f7 f5                	div    %ebp
  802407:	89 c8                	mov    %ecx,%eax
  802409:	f7 f5                	div    %ebp
  80240b:	89 d0                	mov    %edx,%eax
  80240d:	eb 99                	jmp    8023a8 <__umoddi3+0x38>
  80240f:	90                   	nop
  802410:	89 c8                	mov    %ecx,%eax
  802412:	89 f2                	mov    %esi,%edx
  802414:	83 c4 1c             	add    $0x1c,%esp
  802417:	5b                   	pop    %ebx
  802418:	5e                   	pop    %esi
  802419:	5f                   	pop    %edi
  80241a:	5d                   	pop    %ebp
  80241b:	c3                   	ret    
  80241c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802420:	8b 34 24             	mov    (%esp),%esi
  802423:	bf 20 00 00 00       	mov    $0x20,%edi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	29 ef                	sub    %ebp,%edi
  80242c:	d3 e0                	shl    %cl,%eax
  80242e:	89 f9                	mov    %edi,%ecx
  802430:	89 f2                	mov    %esi,%edx
  802432:	d3 ea                	shr    %cl,%edx
  802434:	89 e9                	mov    %ebp,%ecx
  802436:	09 c2                	or     %eax,%edx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 14 24             	mov    %edx,(%esp)
  80243d:	89 f2                	mov    %esi,%edx
  80243f:	d3 e2                	shl    %cl,%edx
  802441:	89 f9                	mov    %edi,%ecx
  802443:	89 54 24 04          	mov    %edx,0x4(%esp)
  802447:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	89 c6                	mov    %eax,%esi
  802451:	d3 e3                	shl    %cl,%ebx
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 d0                	mov    %edx,%eax
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	09 d8                	or     %ebx,%eax
  80245d:	89 d3                	mov    %edx,%ebx
  80245f:	89 f2                	mov    %esi,%edx
  802461:	f7 34 24             	divl   (%esp)
  802464:	89 d6                	mov    %edx,%esi
  802466:	d3 e3                	shl    %cl,%ebx
  802468:	f7 64 24 04          	mull   0x4(%esp)
  80246c:	39 d6                	cmp    %edx,%esi
  80246e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802472:	89 d1                	mov    %edx,%ecx
  802474:	89 c3                	mov    %eax,%ebx
  802476:	72 08                	jb     802480 <__umoddi3+0x110>
  802478:	75 11                	jne    80248b <__umoddi3+0x11b>
  80247a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80247e:	73 0b                	jae    80248b <__umoddi3+0x11b>
  802480:	2b 44 24 04          	sub    0x4(%esp),%eax
  802484:	1b 14 24             	sbb    (%esp),%edx
  802487:	89 d1                	mov    %edx,%ecx
  802489:	89 c3                	mov    %eax,%ebx
  80248b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80248f:	29 da                	sub    %ebx,%edx
  802491:	19 ce                	sbb    %ecx,%esi
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 f0                	mov    %esi,%eax
  802497:	d3 e0                	shl    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	d3 ea                	shr    %cl,%edx
  80249d:	89 e9                	mov    %ebp,%ecx
  80249f:	d3 ee                	shr    %cl,%esi
  8024a1:	09 d0                	or     %edx,%eax
  8024a3:	89 f2                	mov    %esi,%edx
  8024a5:	83 c4 1c             	add    $0x1c,%esp
  8024a8:	5b                   	pop    %ebx
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	29 f9                	sub    %edi,%ecx
  8024b2:	19 d6                	sbb    %edx,%esi
  8024b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024bc:	e9 18 ff ff ff       	jmp    8023d9 <__umoddi3+0x69>
