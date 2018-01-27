
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
  800042:	81 3d 04 40 80 00 b0 	cmpl   $0xeec000b0,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 06 10 00 00       	call   801064 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 20 22 80 00       	push   $0x802220
  80006a:	e8 48 01 00 00       	call   8001b7 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 2c 01 c0 ee       	mov    0xeec0012c,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 31 22 80 00       	push   $0x802231
  800083:	e8 2f 01 00 00       	call   8001b7 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 2c 01 c0 ee       	mov    0xeec0012c,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 43 10 00 00       	call   8010df <ipc_send>
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
  8000b6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  800110:	e8 39 12 00 00       	call   80134e <close_all>
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
  80021a:	e8 71 1d 00 00       	call   801f90 <__udivdi3>
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
  80025d:	e8 5e 1e 00 00       	call   8020c0 <__umoddi3>
  800262:	83 c4 14             	add    $0x14,%esp
  800265:	0f be 80 52 22 80 00 	movsbl 0x802252(%eax),%eax
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
  800361:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
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
  800425:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 18                	jne    800448 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 6a 22 80 00       	push   $0x80226a
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
  800449:	68 c5 26 80 00       	push   $0x8026c5
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
  80046d:	b8 63 22 80 00       	mov    $0x802263,%eax
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
  800ae8:	68 5f 25 80 00       	push   $0x80255f
  800aed:	6a 23                	push   $0x23
  800aef:	68 7c 25 80 00       	push   $0x80257c
  800af4:	e8 7d 13 00 00       	call   801e76 <_panic>

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
  800b69:	68 5f 25 80 00       	push   $0x80255f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 7c 25 80 00       	push   $0x80257c
  800b75:	e8 fc 12 00 00       	call   801e76 <_panic>

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
  800bab:	68 5f 25 80 00       	push   $0x80255f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 7c 25 80 00       	push   $0x80257c
  800bb7:	e8 ba 12 00 00       	call   801e76 <_panic>

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
  800bed:	68 5f 25 80 00       	push   $0x80255f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 7c 25 80 00       	push   $0x80257c
  800bf9:	e8 78 12 00 00       	call   801e76 <_panic>

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
  800c2f:	68 5f 25 80 00       	push   $0x80255f
  800c34:	6a 23                	push   $0x23
  800c36:	68 7c 25 80 00       	push   $0x80257c
  800c3b:	e8 36 12 00 00       	call   801e76 <_panic>

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
  800c71:	68 5f 25 80 00       	push   $0x80255f
  800c76:	6a 23                	push   $0x23
  800c78:	68 7c 25 80 00       	push   $0x80257c
  800c7d:	e8 f4 11 00 00       	call   801e76 <_panic>
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
  800cb3:	68 5f 25 80 00       	push   $0x80255f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 7c 25 80 00       	push   $0x80257c
  800cbf:	e8 b2 11 00 00       	call   801e76 <_panic>

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
  800d17:	68 5f 25 80 00       	push   $0x80255f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 7c 25 80 00       	push   $0x80257c
  800d23:	e8 4e 11 00 00       	call   801e76 <_panic>

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

00800d70 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	53                   	push   %ebx
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d7c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d80:	74 11                	je     800d93 <pgfault+0x23>
  800d82:	89 d8                	mov    %ebx,%eax
  800d84:	c1 e8 0c             	shr    $0xc,%eax
  800d87:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d8e:	f6 c4 08             	test   $0x8,%ah
  800d91:	75 14                	jne    800da7 <pgfault+0x37>
		panic("faulting access");
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	68 8a 25 80 00       	push   $0x80258a
  800d9b:	6a 1e                	push   $0x1e
  800d9d:	68 9a 25 80 00       	push   $0x80259a
  800da2:	e8 cf 10 00 00       	call   801e76 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800da7:	83 ec 04             	sub    $0x4,%esp
  800daa:	6a 07                	push   $0x7
  800dac:	68 00 f0 7f 00       	push   $0x7ff000
  800db1:	6a 00                	push   $0x0
  800db3:	e8 87 fd ff ff       	call   800b3f <sys_page_alloc>
	if (r < 0) {
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	79 12                	jns    800dd1 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dbf:	50                   	push   %eax
  800dc0:	68 a5 25 80 00       	push   $0x8025a5
  800dc5:	6a 2c                	push   $0x2c
  800dc7:	68 9a 25 80 00       	push   $0x80259a
  800dcc:	e8 a5 10 00 00       	call   801e76 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dd1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	68 00 10 00 00       	push   $0x1000
  800ddf:	53                   	push   %ebx
  800de0:	68 00 f0 7f 00       	push   $0x7ff000
  800de5:	e8 4c fb ff ff       	call   800936 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800dea:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df1:	53                   	push   %ebx
  800df2:	6a 00                	push   $0x0
  800df4:	68 00 f0 7f 00       	push   $0x7ff000
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 82 fd ff ff       	call   800b82 <sys_page_map>
	if (r < 0) {
  800e00:	83 c4 20             	add    $0x20,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 12                	jns    800e19 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e07:	50                   	push   %eax
  800e08:	68 a5 25 80 00       	push   $0x8025a5
  800e0d:	6a 33                	push   $0x33
  800e0f:	68 9a 25 80 00       	push   $0x80259a
  800e14:	e8 5d 10 00 00       	call   801e76 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e19:	83 ec 08             	sub    $0x8,%esp
  800e1c:	68 00 f0 7f 00       	push   $0x7ff000
  800e21:	6a 00                	push   $0x0
  800e23:	e8 9c fd ff ff       	call   800bc4 <sys_page_unmap>
	if (r < 0) {
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	79 12                	jns    800e41 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e2f:	50                   	push   %eax
  800e30:	68 a5 25 80 00       	push   $0x8025a5
  800e35:	6a 37                	push   $0x37
  800e37:	68 9a 25 80 00       	push   $0x80259a
  800e3c:	e8 35 10 00 00       	call   801e76 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e4f:	68 70 0d 80 00       	push   $0x800d70
  800e54:	e8 63 10 00 00       	call   801ebc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e59:	b8 07 00 00 00       	mov    $0x7,%eax
  800e5e:	cd 30                	int    $0x30
  800e60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	79 17                	jns    800e81 <fork+0x3b>
		panic("fork fault %e");
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	68 be 25 80 00       	push   $0x8025be
  800e72:	68 84 00 00 00       	push   $0x84
  800e77:	68 9a 25 80 00       	push   $0x80259a
  800e7c:	e8 f5 0f 00 00       	call   801e76 <_panic>
  800e81:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e83:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e87:	75 24                	jne    800ead <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e89:	e8 73 fc ff ff       	call   800b01 <sys_getenvid>
  800e8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e93:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800e99:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e9e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea8:	e9 64 01 00 00       	jmp    801011 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	6a 07                	push   $0x7
  800eb2:	68 00 f0 bf ee       	push   $0xeebff000
  800eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eba:	e8 80 fc ff ff       	call   800b3f <sys_page_alloc>
  800ebf:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	c1 e8 16             	shr    $0x16,%eax
  800ecc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed3:	a8 01                	test   $0x1,%al
  800ed5:	0f 84 fc 00 00 00    	je     800fd7 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	c1 e8 0c             	shr    $0xc,%eax
  800ee0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	0f 84 e7 00 00 00    	je     800fd7 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ef0:	89 c6                	mov    %eax,%esi
  800ef2:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ef5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efc:	f6 c6 04             	test   $0x4,%dh
  800eff:	74 39                	je     800f3a <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f10:	50                   	push   %eax
  800f11:	56                   	push   %esi
  800f12:	57                   	push   %edi
  800f13:	56                   	push   %esi
  800f14:	6a 00                	push   $0x0
  800f16:	e8 67 fc ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800f1b:	83 c4 20             	add    $0x20,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	0f 89 b1 00 00 00    	jns    800fd7 <fork+0x191>
		    	panic("sys page map fault %e");
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	68 cc 25 80 00       	push   $0x8025cc
  800f2e:	6a 54                	push   $0x54
  800f30:	68 9a 25 80 00       	push   $0x80259a
  800f35:	e8 3c 0f 00 00       	call   801e76 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f3a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f41:	f6 c2 02             	test   $0x2,%dl
  800f44:	75 0c                	jne    800f52 <fork+0x10c>
  800f46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4d:	f6 c4 08             	test   $0x8,%ah
  800f50:	74 5b                	je     800fad <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	68 05 08 00 00       	push   $0x805
  800f5a:	56                   	push   %esi
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 1e fc ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800f64:	83 c4 20             	add    $0x20,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 14                	jns    800f7f <fork+0x139>
		    	panic("sys page map fault %e");
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	68 cc 25 80 00       	push   $0x8025cc
  800f73:	6a 5b                	push   $0x5b
  800f75:	68 9a 25 80 00       	push   $0x80259a
  800f7a:	e8 f7 0e 00 00       	call   801e76 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	68 05 08 00 00       	push   $0x805
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	56                   	push   %esi
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 f0 fb ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 3e                	jns    800fd7 <fork+0x191>
		    	panic("sys page map fault %e");
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 cc 25 80 00       	push   $0x8025cc
  800fa1:	6a 5f                	push   $0x5f
  800fa3:	68 9a 25 80 00       	push   $0x80259a
  800fa8:	e8 c9 0e 00 00       	call   801e76 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	6a 05                	push   $0x5
  800fb2:	56                   	push   %esi
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 c6 fb ff ff       	call   800b82 <sys_page_map>
		if (r < 0) {
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	79 14                	jns    800fd7 <fork+0x191>
		    	panic("sys page map fault %e");
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	68 cc 25 80 00       	push   $0x8025cc
  800fcb:	6a 64                	push   $0x64
  800fcd:	68 9a 25 80 00       	push   $0x80259a
  800fd2:	e8 9f 0e 00 00       	call   801e76 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fdd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fe3:	0f 85 de fe ff ff    	jne    800ec7 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fe9:	a1 04 40 80 00       	mov    0x804004,%eax
  800fee:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800ff4:	83 ec 08             	sub    $0x8,%esp
  800ff7:	50                   	push   %eax
  800ff8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ffb:	57                   	push   %edi
  800ffc:	e8 89 fc ff ff       	call   800c8a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	6a 02                	push   $0x2
  801006:	57                   	push   %edi
  801007:	e8 fa fb ff ff       	call   800c06 <sys_env_set_status>
	
	return envid;
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sfork>:

envid_t
sfork(void)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80102b:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	53                   	push   %ebx
  801035:	68 e4 25 80 00       	push   $0x8025e4
  80103a:	e8 78 f1 ff ff       	call   8001b7 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80103f:	c7 04 24 ea 00 80 00 	movl   $0x8000ea,(%esp)
  801046:	e8 e5 fc ff ff       	call   800d30 <sys_thread_create>
  80104b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	53                   	push   %ebx
  801051:	68 e4 25 80 00       	push   $0x8025e4
  801056:	e8 5c f1 ff ff       	call   8001b7 <cprintf>
	return id;
}
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801060:	5b                   	pop    %ebx
  801061:	5e                   	pop    %esi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	8b 75 08             	mov    0x8(%ebp),%esi
  80106c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801072:	85 c0                	test   %eax,%eax
  801074:	75 12                	jne    801088 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	68 00 00 c0 ee       	push   $0xeec00000
  80107e:	e8 6c fc ff ff       	call   800cef <sys_ipc_recv>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb 0c                	jmp    801094 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	50                   	push   %eax
  80108c:	e8 5e fc ff ff       	call   800cef <sys_ipc_recv>
  801091:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801094:	85 f6                	test   %esi,%esi
  801096:	0f 95 c1             	setne  %cl
  801099:	85 db                	test   %ebx,%ebx
  80109b:	0f 95 c2             	setne  %dl
  80109e:	84 d1                	test   %dl,%cl
  8010a0:	74 09                	je     8010ab <ipc_recv+0x47>
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	c1 ea 1f             	shr    $0x1f,%edx
  8010a7:	84 d2                	test   %dl,%dl
  8010a9:	75 2d                	jne    8010d8 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010ab:	85 f6                	test   %esi,%esi
  8010ad:	74 0d                	je     8010bc <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8010af:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  8010ba:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8010bc:	85 db                	test   %ebx,%ebx
  8010be:	74 0d                	je     8010cd <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8010c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  8010cb:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  8010d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8010f1:	85 db                	test   %ebx,%ebx
  8010f3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010f8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8010fb:	ff 75 14             	pushl  0x14(%ebp)
  8010fe:	53                   	push   %ebx
  8010ff:	56                   	push   %esi
  801100:	57                   	push   %edi
  801101:	e8 c6 fb ff ff       	call   800ccc <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801106:	89 c2                	mov    %eax,%edx
  801108:	c1 ea 1f             	shr    $0x1f,%edx
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	84 d2                	test   %dl,%dl
  801110:	74 17                	je     801129 <ipc_send+0x4a>
  801112:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801115:	74 12                	je     801129 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801117:	50                   	push   %eax
  801118:	68 07 26 80 00       	push   $0x802607
  80111d:	6a 47                	push   $0x47
  80111f:	68 15 26 80 00       	push   $0x802615
  801124:	e8 4d 0d 00 00       	call   801e76 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801129:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80112c:	75 07                	jne    801135 <ipc_send+0x56>
			sys_yield();
  80112e:	e8 ed f9 ff ff       	call   800b20 <sys_yield>
  801133:	eb c6                	jmp    8010fb <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801135:	85 c0                	test   %eax,%eax
  801137:	75 c2                	jne    8010fb <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801147:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80114c:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801152:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801158:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80115e:	39 ca                	cmp    %ecx,%edx
  801160:	75 10                	jne    801172 <ipc_find_env+0x31>
			return envs[i].env_id;
  801162:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801168:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80116d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801170:	eb 0f                	jmp    801181 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801172:	83 c0 01             	add    $0x1,%eax
  801175:	3d 00 04 00 00       	cmp    $0x400,%eax
  80117a:	75 d0                	jne    80114c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80117c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	05 00 00 00 30       	add    $0x30000000,%eax
  80118e:	c1 e8 0c             	shr    $0xc,%eax
}
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	05 00 00 00 30       	add    $0x30000000,%eax
  80119e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011a3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 16             	shr    $0x16,%edx
  8011ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	74 11                	je     8011d7 <fd_alloc+0x2d>
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	c1 ea 0c             	shr    $0xc,%edx
  8011cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	75 09                	jne    8011e0 <fd_alloc+0x36>
			*fd_store = fd;
  8011d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011de:	eb 17                	jmp    8011f7 <fd_alloc+0x4d>
  8011e0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ea:	75 c9                	jne    8011b5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ec:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011f2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ff:	83 f8 1f             	cmp    $0x1f,%eax
  801202:	77 36                	ja     80123a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801204:	c1 e0 0c             	shl    $0xc,%eax
  801207:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	c1 ea 16             	shr    $0x16,%edx
  801211:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 24                	je     801241 <fd_lookup+0x48>
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 0c             	shr    $0xc,%edx
  801222:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	74 1a                	je     801248 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801231:	89 02                	mov    %eax,(%edx)
	return 0;
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	eb 13                	jmp    80124d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123f:	eb 0c                	jmp    80124d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801246:	eb 05                	jmp    80124d <fd_lookup+0x54>
  801248:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801258:	ba 9c 26 80 00       	mov    $0x80269c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80125d:	eb 13                	jmp    801272 <dev_lookup+0x23>
  80125f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801262:	39 08                	cmp    %ecx,(%eax)
  801264:	75 0c                	jne    801272 <dev_lookup+0x23>
			*dev = devtab[i];
  801266:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801269:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	eb 2e                	jmp    8012a0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801272:	8b 02                	mov    (%edx),%eax
  801274:	85 c0                	test   %eax,%eax
  801276:	75 e7                	jne    80125f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801278:	a1 04 40 80 00       	mov    0x804004,%eax
  80127d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801280:	83 ec 04             	sub    $0x4,%esp
  801283:	51                   	push   %ecx
  801284:	50                   	push   %eax
  801285:	68 20 26 80 00       	push   $0x802620
  80128a:	e8 28 ef ff ff       	call   8001b7 <cprintf>
	*dev = 0;
  80128f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801292:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 10             	sub    $0x10,%esp
  8012aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ba:	c1 e8 0c             	shr    $0xc,%eax
  8012bd:	50                   	push   %eax
  8012be:	e8 36 ff ff ff       	call   8011f9 <fd_lookup>
  8012c3:	83 c4 08             	add    $0x8,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 05                	js     8012cf <fd_close+0x2d>
	    || fd != fd2)
  8012ca:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012cd:	74 0c                	je     8012db <fd_close+0x39>
		return (must_exist ? r : 0);
  8012cf:	84 db                	test   %bl,%bl
  8012d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d6:	0f 44 c2             	cmove  %edx,%eax
  8012d9:	eb 41                	jmp    80131c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 36                	pushl  (%esi)
  8012e4:	e8 66 ff ff ff       	call   80124f <dev_lookup>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 1a                	js     80130c <fd_close+0x6a>
		if (dev->dev_close)
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	74 0b                	je     80130c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	56                   	push   %esi
  801305:	ff d0                	call   *%eax
  801307:	89 c3                	mov    %eax,%ebx
  801309:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	56                   	push   %esi
  801310:	6a 00                	push   $0x0
  801312:	e8 ad f8 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	89 d8                	mov    %ebx,%eax
}
  80131c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	pushl  0x8(%ebp)
  801330:	e8 c4 fe ff ff       	call   8011f9 <fd_lookup>
  801335:	83 c4 08             	add    $0x8,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 10                	js     80134c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	6a 01                	push   $0x1
  801341:	ff 75 f4             	pushl  -0xc(%ebp)
  801344:	e8 59 ff ff ff       	call   8012a2 <fd_close>
  801349:	83 c4 10             	add    $0x10,%esp
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <close_all>:

void
close_all(void)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	53                   	push   %ebx
  801352:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801355:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	53                   	push   %ebx
  80135e:	e8 c0 ff ff ff       	call   801323 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801363:	83 c3 01             	add    $0x1,%ebx
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	83 fb 20             	cmp    $0x20,%ebx
  80136c:	75 ec                	jne    80135a <close_all+0xc>
		close(i);
}
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	57                   	push   %edi
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 2c             	sub    $0x2c,%esp
  80137c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	ff 75 08             	pushl  0x8(%ebp)
  801386:	e8 6e fe ff ff       	call   8011f9 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	0f 88 c1 00 00 00    	js     801457 <dup+0xe4>
		return r;
	close(newfdnum);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	56                   	push   %esi
  80139a:	e8 84 ff ff ff       	call   801323 <close>

	newfd = INDEX2FD(newfdnum);
  80139f:	89 f3                	mov    %esi,%ebx
  8013a1:	c1 e3 0c             	shl    $0xc,%ebx
  8013a4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013aa:	83 c4 04             	add    $0x4,%esp
  8013ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013b0:	e8 de fd ff ff       	call   801193 <fd2data>
  8013b5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b7:	89 1c 24             	mov    %ebx,(%esp)
  8013ba:	e8 d4 fd ff ff       	call   801193 <fd2data>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c5:	89 f8                	mov    %edi,%eax
  8013c7:	c1 e8 16             	shr    $0x16,%eax
  8013ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d1:	a8 01                	test   $0x1,%al
  8013d3:	74 37                	je     80140c <dup+0x99>
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	c1 e8 0c             	shr    $0xc,%eax
  8013da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e1:	f6 c2 01             	test   $0x1,%dl
  8013e4:	74 26                	je     80140c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f9:	6a 00                	push   $0x0
  8013fb:	57                   	push   %edi
  8013fc:	6a 00                	push   $0x0
  8013fe:	e8 7f f7 ff ff       	call   800b82 <sys_page_map>
  801403:	89 c7                	mov    %eax,%edi
  801405:	83 c4 20             	add    $0x20,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 2e                	js     80143a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80140f:	89 d0                	mov    %edx,%eax
  801411:	c1 e8 0c             	shr    $0xc,%eax
  801414:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141b:	83 ec 0c             	sub    $0xc,%esp
  80141e:	25 07 0e 00 00       	and    $0xe07,%eax
  801423:	50                   	push   %eax
  801424:	53                   	push   %ebx
  801425:	6a 00                	push   $0x0
  801427:	52                   	push   %edx
  801428:	6a 00                	push   $0x0
  80142a:	e8 53 f7 ff ff       	call   800b82 <sys_page_map>
  80142f:	89 c7                	mov    %eax,%edi
  801431:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801434:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801436:	85 ff                	test   %edi,%edi
  801438:	79 1d                	jns    801457 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	53                   	push   %ebx
  80143e:	6a 00                	push   $0x0
  801440:	e8 7f f7 ff ff       	call   800bc4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144b:	6a 00                	push   $0x0
  80144d:	e8 72 f7 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	89 f8                	mov    %edi,%eax
}
  801457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	53                   	push   %ebx
  801463:	83 ec 14             	sub    $0x14,%esp
  801466:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801469:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	53                   	push   %ebx
  80146e:	e8 86 fd ff ff       	call   8011f9 <fd_lookup>
  801473:	83 c4 08             	add    $0x8,%esp
  801476:	89 c2                	mov    %eax,%edx
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 6d                	js     8014e9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	ff 30                	pushl  (%eax)
  801488:	e8 c2 fd ff ff       	call   80124f <dev_lookup>
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 4c                	js     8014e0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801494:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801497:	8b 42 08             	mov    0x8(%edx),%eax
  80149a:	83 e0 03             	and    $0x3,%eax
  80149d:	83 f8 01             	cmp    $0x1,%eax
  8014a0:	75 21                	jne    8014c3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a7:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	50                   	push   %eax
  8014af:	68 61 26 80 00       	push   $0x802661
  8014b4:	e8 fe ec ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c1:	eb 26                	jmp    8014e9 <read+0x8a>
	}
	if (!dev->dev_read)
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c6:	8b 40 08             	mov    0x8(%eax),%eax
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	74 17                	je     8014e4 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	ff 75 10             	pushl  0x10(%ebp)
  8014d3:	ff 75 0c             	pushl  0xc(%ebp)
  8014d6:	52                   	push   %edx
  8014d7:	ff d0                	call   *%eax
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb 09                	jmp    8014e9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	eb 05                	jmp    8014e9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014e9:	89 d0                	mov    %edx,%eax
  8014eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	57                   	push   %edi
  8014f4:	56                   	push   %esi
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801504:	eb 21                	jmp    801527 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801506:	83 ec 04             	sub    $0x4,%esp
  801509:	89 f0                	mov    %esi,%eax
  80150b:	29 d8                	sub    %ebx,%eax
  80150d:	50                   	push   %eax
  80150e:	89 d8                	mov    %ebx,%eax
  801510:	03 45 0c             	add    0xc(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	57                   	push   %edi
  801515:	e8 45 ff ff ff       	call   80145f <read>
		if (m < 0)
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 10                	js     801531 <readn+0x41>
			return m;
		if (m == 0)
  801521:	85 c0                	test   %eax,%eax
  801523:	74 0a                	je     80152f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801525:	01 c3                	add    %eax,%ebx
  801527:	39 f3                	cmp    %esi,%ebx
  801529:	72 db                	jb     801506 <readn+0x16>
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	eb 02                	jmp    801531 <readn+0x41>
  80152f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	53                   	push   %ebx
  80153d:	83 ec 14             	sub    $0x14,%esp
  801540:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801543:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	53                   	push   %ebx
  801548:	e8 ac fc ff ff       	call   8011f9 <fd_lookup>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	89 c2                	mov    %eax,%edx
  801552:	85 c0                	test   %eax,%eax
  801554:	78 68                	js     8015be <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	ff 30                	pushl  (%eax)
  801562:	e8 e8 fc ff ff       	call   80124f <dev_lookup>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 47                	js     8015b5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801575:	75 21                	jne    801598 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801577:	a1 04 40 80 00       	mov    0x804004,%eax
  80157c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	50                   	push   %eax
  801584:	68 7d 26 80 00       	push   $0x80267d
  801589:	e8 29 ec ff ff       	call   8001b7 <cprintf>
		return -E_INVAL;
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801596:	eb 26                	jmp    8015be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801598:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159b:	8b 52 0c             	mov    0xc(%edx),%edx
  80159e:	85 d2                	test   %edx,%edx
  8015a0:	74 17                	je     8015b9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	ff d2                	call   *%edx
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 09                	jmp    8015be <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	eb 05                	jmp    8015be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	ff 75 08             	pushl  0x8(%ebp)
  8015d2:	e8 22 fc ff ff       	call   8011f9 <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 0e                	js     8015ec <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 14             	sub    $0x14,%esp
  8015f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	53                   	push   %ebx
  8015fd:	e8 f7 fb ff ff       	call   8011f9 <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	89 c2                	mov    %eax,%edx
  801607:	85 c0                	test   %eax,%eax
  801609:	78 65                	js     801670 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 33 fc ff ff       	call   80124f <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 44                	js     801667 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162a:	75 21                	jne    80164d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80162c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801631:	8b 40 7c             	mov    0x7c(%eax),%eax
  801634:	83 ec 04             	sub    $0x4,%esp
  801637:	53                   	push   %ebx
  801638:	50                   	push   %eax
  801639:	68 40 26 80 00       	push   $0x802640
  80163e:	e8 74 eb ff ff       	call   8001b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164b:	eb 23                	jmp    801670 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	8b 52 18             	mov    0x18(%edx),%edx
  801653:	85 d2                	test   %edx,%edx
  801655:	74 14                	je     80166b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	50                   	push   %eax
  80165e:	ff d2                	call   *%edx
  801660:	89 c2                	mov    %eax,%edx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 09                	jmp    801670 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801667:	89 c2                	mov    %eax,%edx
  801669:	eb 05                	jmp    801670 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80166b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801670:	89 d0                	mov    %edx,%eax
  801672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 14             	sub    $0x14,%esp
  80167e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 6c fb ff ff       	call   8011f9 <fd_lookup>
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	89 c2                	mov    %eax,%edx
  801692:	85 c0                	test   %eax,%eax
  801694:	78 58                	js     8016ee <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a0:	ff 30                	pushl  (%eax)
  8016a2:	e8 a8 fb ff ff       	call   80124f <dev_lookup>
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 37                	js     8016e5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b5:	74 32                	je     8016e9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c1:	00 00 00 
	stat->st_isdir = 0;
  8016c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016cb:	00 00 00 
	stat->st_dev = dev;
  8016ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8016db:	ff 50 14             	call   *0x14(%eax)
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	eb 09                	jmp    8016ee <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	eb 05                	jmp    8016ee <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ee:	89 d0                	mov    %edx,%eax
  8016f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	6a 00                	push   $0x0
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 e3 01 00 00       	call   8018ea <open>
  801707:	89 c3                	mov    %eax,%ebx
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 1b                	js     80172b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	50                   	push   %eax
  801717:	e8 5b ff ff ff       	call   801677 <fstat>
  80171c:	89 c6                	mov    %eax,%esi
	close(fd);
  80171e:	89 1c 24             	mov    %ebx,(%esp)
  801721:	e8 fd fb ff ff       	call   801323 <close>
	return r;
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	89 f0                	mov    %esi,%eax
}
  80172b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	89 c6                	mov    %eax,%esi
  801739:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80173b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801742:	75 12                	jne    801756 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	6a 01                	push   $0x1
  801749:	e8 f3 f9 ff ff       	call   801141 <ipc_find_env>
  80174e:	a3 00 40 80 00       	mov    %eax,0x804000
  801753:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801756:	6a 07                	push   $0x7
  801758:	68 00 50 80 00       	push   $0x805000
  80175d:	56                   	push   %esi
  80175e:	ff 35 00 40 80 00    	pushl  0x804000
  801764:	e8 76 f9 ff ff       	call   8010df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801769:	83 c4 0c             	add    $0xc,%esp
  80176c:	6a 00                	push   $0x0
  80176e:	53                   	push   %ebx
  80176f:	6a 00                	push   $0x0
  801771:	e8 ee f8 ff ff       	call   801064 <ipc_recv>
}
  801776:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	8b 40 0c             	mov    0xc(%eax),%eax
  801789:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80178e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801791:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a0:	e8 8d ff ff ff       	call   801732 <fsipc>
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c2:	e8 6b ff ff ff       	call   801732 <fsipc>
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e8:	e8 45 ff ff ff       	call   801732 <fsipc>
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 2c                	js     80181d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	68 00 50 80 00       	push   $0x805000
  8017f9:	53                   	push   %ebx
  8017fa:	e8 3d ef ff ff       	call   80073c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ff:	a1 80 50 80 00       	mov    0x805080,%eax
  801804:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80180a:	a1 84 50 80 00       	mov    0x805084,%eax
  80180f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80182b:	8b 55 08             	mov    0x8(%ebp),%edx
  80182e:	8b 52 0c             	mov    0xc(%edx),%edx
  801831:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801837:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80183c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801841:	0f 47 c2             	cmova  %edx,%eax
  801844:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801849:	50                   	push   %eax
  80184a:	ff 75 0c             	pushl  0xc(%ebp)
  80184d:	68 08 50 80 00       	push   $0x805008
  801852:	e8 77 f0 ff ff       	call   8008ce <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 04 00 00 00       	mov    $0x4,%eax
  801861:	e8 cc fe ff ff       	call   801732 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 40 0c             	mov    0xc(%eax),%eax
  801876:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 03 00 00 00       	mov    $0x3,%eax
  80188b:	e8 a2 fe ff ff       	call   801732 <fsipc>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	85 c0                	test   %eax,%eax
  801894:	78 4b                	js     8018e1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801896:	39 c6                	cmp    %eax,%esi
  801898:	73 16                	jae    8018b0 <devfile_read+0x48>
  80189a:	68 ac 26 80 00       	push   $0x8026ac
  80189f:	68 b3 26 80 00       	push   $0x8026b3
  8018a4:	6a 7c                	push   $0x7c
  8018a6:	68 c8 26 80 00       	push   $0x8026c8
  8018ab:	e8 c6 05 00 00       	call   801e76 <_panic>
	assert(r <= PGSIZE);
  8018b0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b5:	7e 16                	jle    8018cd <devfile_read+0x65>
  8018b7:	68 d3 26 80 00       	push   $0x8026d3
  8018bc:	68 b3 26 80 00       	push   $0x8026b3
  8018c1:	6a 7d                	push   $0x7d
  8018c3:	68 c8 26 80 00       	push   $0x8026c8
  8018c8:	e8 a9 05 00 00       	call   801e76 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	50                   	push   %eax
  8018d1:	68 00 50 80 00       	push   $0x805000
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	e8 f0 ef ff ff       	call   8008ce <memmove>
	return r;
  8018de:	83 c4 10             	add    $0x10,%esp
}
  8018e1:	89 d8                	mov    %ebx,%eax
  8018e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 20             	sub    $0x20,%esp
  8018f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f4:	53                   	push   %ebx
  8018f5:	e8 09 ee ff ff       	call   800703 <strlen>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801902:	7f 67                	jg     80196b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	e8 9a f8 ff ff       	call   8011aa <fd_alloc>
  801910:	83 c4 10             	add    $0x10,%esp
		return r;
  801913:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801915:	85 c0                	test   %eax,%eax
  801917:	78 57                	js     801970 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	53                   	push   %ebx
  80191d:	68 00 50 80 00       	push   $0x805000
  801922:	e8 15 ee ff ff       	call   80073c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801932:	b8 01 00 00 00       	mov    $0x1,%eax
  801937:	e8 f6 fd ff ff       	call   801732 <fsipc>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	79 14                	jns    801959 <open+0x6f>
		fd_close(fd, 0);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	6a 00                	push   $0x0
  80194a:	ff 75 f4             	pushl  -0xc(%ebp)
  80194d:	e8 50 f9 ff ff       	call   8012a2 <fd_close>
		return r;
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	89 da                	mov    %ebx,%edx
  801957:	eb 17                	jmp    801970 <open+0x86>
	}

	return fd2num(fd);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	ff 75 f4             	pushl  -0xc(%ebp)
  80195f:	e8 1f f8 ff ff       	call   801183 <fd2num>
  801964:	89 c2                	mov    %eax,%edx
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	eb 05                	jmp    801970 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801970:	89 d0                	mov    %edx,%eax
  801972:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197d:	ba 00 00 00 00       	mov    $0x0,%edx
  801982:	b8 08 00 00 00       	mov    $0x8,%eax
  801987:	e8 a6 fd ff ff       	call   801732 <fsipc>
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	ff 75 08             	pushl  0x8(%ebp)
  80199c:	e8 f2 f7 ff ff       	call   801193 <fd2data>
  8019a1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a3:	83 c4 08             	add    $0x8,%esp
  8019a6:	68 df 26 80 00       	push   $0x8026df
  8019ab:	53                   	push   %ebx
  8019ac:	e8 8b ed ff ff       	call   80073c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b1:	8b 46 04             	mov    0x4(%esi),%eax
  8019b4:	2b 06                	sub    (%esi),%eax
  8019b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c3:	00 00 00 
	stat->st_dev = &devpipe;
  8019c6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019cd:	30 80 00 
	return 0;
}
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e6:	53                   	push   %ebx
  8019e7:	6a 00                	push   $0x0
  8019e9:	e8 d6 f1 ff ff       	call   800bc4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ee:	89 1c 24             	mov    %ebx,(%esp)
  8019f1:	e8 9d f7 ff ff       	call   801193 <fd2data>
  8019f6:	83 c4 08             	add    $0x8,%esp
  8019f9:	50                   	push   %eax
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 c3 f1 ff ff       	call   800bc4 <sys_page_unmap>
}
  801a01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	57                   	push   %edi
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 1c             	sub    $0x1c,%esp
  801a0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a12:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a14:	a1 04 40 80 00       	mov    0x804004,%eax
  801a19:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	ff 75 e0             	pushl  -0x20(%ebp)
  801a25:	e8 21 05 00 00       	call   801f4b <pageref>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	89 3c 24             	mov    %edi,(%esp)
  801a2f:	e8 17 05 00 00       	call   801f4b <pageref>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	39 c3                	cmp    %eax,%ebx
  801a39:	0f 94 c1             	sete   %cl
  801a3c:	0f b6 c9             	movzbl %cl,%ecx
  801a3f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a42:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a48:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801a4e:	39 ce                	cmp    %ecx,%esi
  801a50:	74 1e                	je     801a70 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801a52:	39 c3                	cmp    %eax,%ebx
  801a54:	75 be                	jne    801a14 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a56:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801a5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5f:	50                   	push   %eax
  801a60:	56                   	push   %esi
  801a61:	68 e6 26 80 00       	push   $0x8026e6
  801a66:	e8 4c e7 ff ff       	call   8001b7 <cprintf>
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	eb a4                	jmp    801a14 <_pipeisclosed+0xe>
	}
}
  801a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	57                   	push   %edi
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 28             	sub    $0x28,%esp
  801a84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a87:	56                   	push   %esi
  801a88:	e8 06 f7 ff ff       	call   801193 <fd2data>
  801a8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	bf 00 00 00 00       	mov    $0x0,%edi
  801a97:	eb 4b                	jmp    801ae4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a99:	89 da                	mov    %ebx,%edx
  801a9b:	89 f0                	mov    %esi,%eax
  801a9d:	e8 64 ff ff ff       	call   801a06 <_pipeisclosed>
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	75 48                	jne    801aee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa6:	e8 75 f0 ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aab:	8b 43 04             	mov    0x4(%ebx),%eax
  801aae:	8b 0b                	mov    (%ebx),%ecx
  801ab0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab3:	39 d0                	cmp    %edx,%eax
  801ab5:	73 e2                	jae    801a99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801abe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	c1 fa 1f             	sar    $0x1f,%edx
  801ac6:	89 d1                	mov    %edx,%ecx
  801ac8:	c1 e9 1b             	shr    $0x1b,%ecx
  801acb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ace:	83 e2 1f             	and    $0x1f,%edx
  801ad1:	29 ca                	sub    %ecx,%edx
  801ad3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801adb:	83 c0 01             	add    $0x1,%eax
  801ade:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae1:	83 c7 01             	add    $0x1,%edi
  801ae4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae7:	75 c2                	jne    801aab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aec:	eb 05                	jmp    801af3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 18             	sub    $0x18,%esp
  801b04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b07:	57                   	push   %edi
  801b08:	e8 86 f6 ff ff       	call   801193 <fd2data>
  801b0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b17:	eb 3d                	jmp    801b56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b19:	85 db                	test   %ebx,%ebx
  801b1b:	74 04                	je     801b21 <devpipe_read+0x26>
				return i;
  801b1d:	89 d8                	mov    %ebx,%eax
  801b1f:	eb 44                	jmp    801b65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b21:	89 f2                	mov    %esi,%edx
  801b23:	89 f8                	mov    %edi,%eax
  801b25:	e8 dc fe ff ff       	call   801a06 <_pipeisclosed>
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	75 32                	jne    801b60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2e:	e8 ed ef ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b33:	8b 06                	mov    (%esi),%eax
  801b35:	3b 46 04             	cmp    0x4(%esi),%eax
  801b38:	74 df                	je     801b19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3a:	99                   	cltd   
  801b3b:	c1 ea 1b             	shr    $0x1b,%edx
  801b3e:	01 d0                	add    %edx,%eax
  801b40:	83 e0 1f             	and    $0x1f,%eax
  801b43:	29 d0                	sub    %edx,%eax
  801b45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b53:	83 c3 01             	add    $0x1,%ebx
  801b56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b59:	75 d8                	jne    801b33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5e:	eb 05                	jmp    801b65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5f                   	pop    %edi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 2c f6 ff ff       	call   8011aa <fd_alloc>
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	89 c2                	mov    %eax,%edx
  801b83:	85 c0                	test   %eax,%eax
  801b85:	0f 88 2c 01 00 00    	js     801cb7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8b:	83 ec 04             	sub    $0x4,%esp
  801b8e:	68 07 04 00 00       	push   $0x407
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	6a 00                	push   $0x0
  801b98:	e8 a2 ef ff ff       	call   800b3f <sys_page_alloc>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	89 c2                	mov    %eax,%edx
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	0f 88 0d 01 00 00    	js     801cb7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb0:	50                   	push   %eax
  801bb1:	e8 f4 f5 ff ff       	call   8011aa <fd_alloc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 88 e2 00 00 00    	js     801ca5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc3:	83 ec 04             	sub    $0x4,%esp
  801bc6:	68 07 04 00 00       	push   $0x407
  801bcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 6a ef ff ff       	call   800b3f <sys_page_alloc>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	0f 88 c3 00 00 00    	js     801ca5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f4             	pushl  -0xc(%ebp)
  801be8:	e8 a6 f5 ff ff       	call   801193 <fd2data>
  801bed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 c4 0c             	add    $0xc,%esp
  801bf2:	68 07 04 00 00       	push   $0x407
  801bf7:	50                   	push   %eax
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 40 ef ff ff       	call   800b3f <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 89 00 00 00    	js     801c95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c12:	e8 7c f5 ff ff       	call   801193 <fd2data>
  801c17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1e:	50                   	push   %eax
  801c1f:	6a 00                	push   $0x0
  801c21:	56                   	push   %esi
  801c22:	6a 00                	push   $0x0
  801c24:	e8 59 ef ff ff       	call   800b82 <sys_page_map>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 20             	add    $0x20,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 55                	js     801c87 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c62:	e8 1c f5 ff ff       	call   801183 <fd2num>
  801c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c6c:	83 c4 04             	add    $0x4,%esp
  801c6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c72:	e8 0c f5 ff ff       	call   801183 <fd2num>
  801c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	ba 00 00 00 00       	mov    $0x0,%edx
  801c85:	eb 30                	jmp    801cb7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	56                   	push   %esi
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 32 ef ff ff       	call   800bc4 <sys_page_unmap>
  801c92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 22 ef ff ff       	call   800bc4 <sys_page_unmap>
  801ca2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca5:	83 ec 08             	sub    $0x8,%esp
  801ca8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cab:	6a 00                	push   $0x0
  801cad:	e8 12 ef ff ff       	call   800bc4 <sys_page_unmap>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb7:	89 d0                	mov    %edx,%eax
  801cb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbc:	5b                   	pop    %ebx
  801cbd:	5e                   	pop    %esi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc9:	50                   	push   %eax
  801cca:	ff 75 08             	pushl  0x8(%ebp)
  801ccd:	e8 27 f5 ff ff       	call   8011f9 <fd_lookup>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 18                	js     801cf1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdf:	e8 af f4 ff ff       	call   801193 <fd2data>
	return _pipeisclosed(fd, p);
  801ce4:	89 c2                	mov    %eax,%edx
  801ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce9:	e8 18 fd ff ff       	call   801a06 <_pipeisclosed>
  801cee:	83 c4 10             	add    $0x10,%esp
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d03:	68 fe 26 80 00       	push   $0x8026fe
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	e8 2c ea ff ff       	call   80073c <strcpy>
	return 0;
}
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	57                   	push   %edi
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2e:	eb 2d                	jmp    801d5d <devcons_write+0x46>
		m = n - tot;
  801d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d33:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d35:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d38:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d3d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d40:	83 ec 04             	sub    $0x4,%esp
  801d43:	53                   	push   %ebx
  801d44:	03 45 0c             	add    0xc(%ebp),%eax
  801d47:	50                   	push   %eax
  801d48:	57                   	push   %edi
  801d49:	e8 80 eb ff ff       	call   8008ce <memmove>
		sys_cputs(buf, m);
  801d4e:	83 c4 08             	add    $0x8,%esp
  801d51:	53                   	push   %ebx
  801d52:	57                   	push   %edi
  801d53:	e8 2b ed ff ff       	call   800a83 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d58:	01 de                	add    %ebx,%esi
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	89 f0                	mov    %esi,%eax
  801d5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d62:	72 cc                	jb     801d30 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7b:	74 2a                	je     801da7 <devcons_read+0x3b>
  801d7d:	eb 05                	jmp    801d84 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d7f:	e8 9c ed ff ff       	call   800b20 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d84:	e8 18 ed ff ff       	call   800aa1 <sys_cgetc>
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	74 f2                	je     801d7f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 16                	js     801da7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d91:	83 f8 04             	cmp    $0x4,%eax
  801d94:	74 0c                	je     801da2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d96:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d99:	88 02                	mov    %al,(%edx)
	return 1;
  801d9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801da0:	eb 05                	jmp    801da7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801daf:	8b 45 08             	mov    0x8(%ebp),%eax
  801db2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db5:	6a 01                	push   $0x1
  801db7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dba:	50                   	push   %eax
  801dbb:	e8 c3 ec ff ff       	call   800a83 <sys_cputs>
}
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <getchar>:

int
getchar(void)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dcb:	6a 01                	push   $0x1
  801dcd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd0:	50                   	push   %eax
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 87 f6 ff ff       	call   80145f <read>
	if (r < 0)
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 0f                	js     801dee <getchar+0x29>
		return r;
	if (r < 1)
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	7e 06                	jle    801de9 <getchar+0x24>
		return -E_EOF;
	return c;
  801de3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de7:	eb 05                	jmp    801dee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df9:	50                   	push   %eax
  801dfa:	ff 75 08             	pushl  0x8(%ebp)
  801dfd:	e8 f7 f3 ff ff       	call   8011f9 <fd_lookup>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 11                	js     801e1a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e12:	39 10                	cmp    %edx,(%eax)
  801e14:	0f 94 c0             	sete   %al
  801e17:	0f b6 c0             	movzbl %al,%eax
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <opencons>:

int
opencons(void)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	e8 7f f3 ff ff       	call   8011aa <fd_alloc>
  801e2b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 3e                	js     801e72 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	68 07 04 00 00       	push   $0x407
  801e3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3f:	6a 00                	push   $0x0
  801e41:	e8 f9 ec ff ff       	call   800b3f <sys_page_alloc>
  801e46:	83 c4 10             	add    $0x10,%esp
		return r;
  801e49:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 23                	js     801e72 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e4f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e58:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	50                   	push   %eax
  801e68:	e8 16 f3 ff ff       	call   801183 <fd2num>
  801e6d:	89 c2                	mov    %eax,%edx
  801e6f:	83 c4 10             	add    $0x10,%esp
}
  801e72:	89 d0                	mov    %edx,%eax
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	56                   	push   %esi
  801e7a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e7b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e7e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e84:	e8 78 ec ff ff       	call   800b01 <sys_getenvid>
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	ff 75 0c             	pushl  0xc(%ebp)
  801e8f:	ff 75 08             	pushl  0x8(%ebp)
  801e92:	56                   	push   %esi
  801e93:	50                   	push   %eax
  801e94:	68 0c 27 80 00       	push   $0x80270c
  801e99:	e8 19 e3 ff ff       	call   8001b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e9e:	83 c4 18             	add    $0x18,%esp
  801ea1:	53                   	push   %ebx
  801ea2:	ff 75 10             	pushl  0x10(%ebp)
  801ea5:	e8 bc e2 ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  801eaa:	c7 04 24 f7 26 80 00 	movl   $0x8026f7,(%esp)
  801eb1:	e8 01 e3 ff ff       	call   8001b7 <cprintf>
  801eb6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eb9:	cc                   	int3   
  801eba:	eb fd                	jmp    801eb9 <_panic+0x43>

00801ebc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ec2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ec9:	75 2a                	jne    801ef5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	6a 07                	push   $0x7
  801ed0:	68 00 f0 bf ee       	push   $0xeebff000
  801ed5:	6a 00                	push   $0x0
  801ed7:	e8 63 ec ff ff       	call   800b3f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	79 12                	jns    801ef5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ee3:	50                   	push   %eax
  801ee4:	68 30 27 80 00       	push   $0x802730
  801ee9:	6a 23                	push   $0x23
  801eeb:	68 34 27 80 00       	push   $0x802734
  801ef0:	e8 81 ff ff ff       	call   801e76 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	68 27 1f 80 00       	push   $0x801f27
  801f05:	6a 00                	push   $0x0
  801f07:	e8 7e ed ff ff       	call   800c8a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	79 12                	jns    801f25 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f13:	50                   	push   %eax
  801f14:	68 30 27 80 00       	push   $0x802730
  801f19:	6a 2c                	push   $0x2c
  801f1b:	68 34 27 80 00       	push   $0x802734
  801f20:	e8 51 ff ff ff       	call   801e76 <_panic>
	}
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f27:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f28:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f2d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f2f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f32:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f36:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f3b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f3f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f41:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f44:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f45:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f48:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f49:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f4a:	c3                   	ret    

00801f4b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f51:	89 d0                	mov    %edx,%eax
  801f53:	c1 e8 16             	shr    $0x16,%eax
  801f56:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f62:	f6 c1 01             	test   $0x1,%cl
  801f65:	74 1d                	je     801f84 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f67:	c1 ea 0c             	shr    $0xc,%edx
  801f6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f71:	f6 c2 01             	test   $0x1,%dl
  801f74:	74 0e                	je     801f84 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f76:	c1 ea 0c             	shr    $0xc,%edx
  801f79:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f80:	ef 
  801f81:	0f b7 c0             	movzwl %ax,%eax
}
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

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
