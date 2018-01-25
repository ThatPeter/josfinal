
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
  80003b:	e8 c2 0a 00 00       	call   800b02 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 88 	cmpl   $0xeec00088,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 05 10 00 00       	call   801063 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 20 22 80 00       	push   $0x802220
  80006a:	e8 49 01 00 00       	call   8001b8 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 dc 00 c0 ee       	mov    0xeec000dc,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 31 22 80 00       	push   $0x802231
  800083:	e8 30 01 00 00       	call   8001b8 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 dc 00 c0 ee       	mov    0xeec000dc,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 3f 10 00 00       	call   8010db <ipc_send>
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
  8000ac:	e8 51 0a 00 00       	call   800b02 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	89 c2                	mov    %eax,%edx
  8000b8:	c1 e2 07             	shl    $0x7,%edx
  8000bb:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000c2:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 db                	test   %ebx,%ebx
  8000c9:	7e 07                	jle    8000d2 <libmain+0x31>
		binaryname = argv[0];
  8000cb:	8b 06                	mov    (%esi),%eax
  8000cd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	e8 57 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 2a 00 00 00       	call   80010b <exit>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000f1:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000f6:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000f8:	e8 05 0a 00 00       	call   800b02 <sys_getenvid>
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	e8 4b 0c 00 00       	call   800d51 <sys_thread_free>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800111:	e8 32 12 00 00       	call   801348 <close_all>
	sys_env_destroy(0);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	6a 00                	push   $0x0
  80011b:	e8 a1 09 00 00       	call   800ac1 <sys_env_destroy>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	53                   	push   %ebx
  800129:	83 ec 04             	sub    $0x4,%esp
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012f:	8b 13                	mov    (%ebx),%edx
  800131:	8d 42 01             	lea    0x1(%edx),%eax
  800134:	89 03                	mov    %eax,(%ebx)
  800136:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800139:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800142:	75 1a                	jne    80015e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	68 ff 00 00 00       	push   $0xff
  80014c:	8d 43 08             	lea    0x8(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	e8 2f 09 00 00       	call   800a84 <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800177:	00 00 00 
	b.cnt = 0;
  80017a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800184:	ff 75 0c             	pushl  0xc(%ebp)
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	68 25 01 80 00       	push   $0x800125
  800196:	e8 54 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019b:	83 c4 08             	add    $0x8,%esp
  80019e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 d4 08 00 00       	call   800a84 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	50                   	push   %eax
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	e8 9d ff ff ff       	call   800167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
  8001d5:	89 c7                	mov    %eax,%edi
  8001d7:	89 d6                	mov    %edx,%esi
  8001d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f3:	39 d3                	cmp    %edx,%ebx
  8001f5:	72 05                	jb     8001fc <printnum+0x30>
  8001f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fa:	77 45                	ja     800241 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 18             	pushl  0x18(%ebp)
  800202:	8b 45 14             	mov    0x14(%ebp),%eax
  800205:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800208:	53                   	push   %ebx
  800209:	ff 75 10             	pushl  0x10(%ebp)
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800212:	ff 75 e0             	pushl  -0x20(%ebp)
  800215:	ff 75 dc             	pushl  -0x24(%ebp)
  800218:	ff 75 d8             	pushl  -0x28(%ebp)
  80021b:	e8 60 1d 00 00       	call   801f80 <__udivdi3>
  800220:	83 c4 18             	add    $0x18,%esp
  800223:	52                   	push   %edx
  800224:	50                   	push   %eax
  800225:	89 f2                	mov    %esi,%edx
  800227:	89 f8                	mov    %edi,%eax
  800229:	e8 9e ff ff ff       	call   8001cc <printnum>
  80022e:	83 c4 20             	add    $0x20,%esp
  800231:	eb 18                	jmp    80024b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	ff d7                	call   *%edi
  80023c:	83 c4 10             	add    $0x10,%esp
  80023f:	eb 03                	jmp    800244 <printnum+0x78>
  800241:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	85 db                	test   %ebx,%ebx
  800249:	7f e8                	jg     800233 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 4d 1e 00 00       	call   8020b0 <__umoddi3>
  800263:	83 c4 14             	add    $0x14,%esp
  800266:	0f be 80 52 22 80 00 	movsbl 0x802252(%eax),%eax
  80026d:	50                   	push   %eax
  80026e:	ff d7                	call   *%edi
}
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027e:	83 fa 01             	cmp    $0x1,%edx
  800281:	7e 0e                	jle    800291 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 08             	lea    0x8(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	8b 52 04             	mov    0x4(%edx),%edx
  80028f:	eb 22                	jmp    8002b3 <getuint+0x38>
	else if (lflag)
  800291:	85 d2                	test   %edx,%edx
  800293:	74 10                	je     8002a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a3:	eb 0e                	jmp    8002b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 0a                	jae    8002d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ce:	88 02                	mov    %al,(%edx)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
	va_end(ap);
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 2c             	sub    $0x2c,%esp
  8002f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800301:	eb 12                	jmp    800315 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800303:	85 c0                	test   %eax,%eax
  800305:	0f 84 89 03 00 00    	je     800694 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	53                   	push   %ebx
  80030f:	50                   	push   %eax
  800310:	ff d6                	call   *%esi
  800312:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800315:	83 c7 01             	add    $0x1,%edi
  800318:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031c:	83 f8 25             	cmp    $0x25,%eax
  80031f:	75 e2                	jne    800303 <vprintfmt+0x14>
  800321:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800325:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800333:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80033a:	ba 00 00 00 00       	mov    $0x0,%edx
  80033f:	eb 07                	jmp    800348 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800344:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 07             	movzbl (%edi),%eax
  800351:	0f b6 c8             	movzbl %al,%ecx
  800354:	83 e8 23             	sub    $0x23,%eax
  800357:	3c 55                	cmp    $0x55,%al
  800359:	0f 87 1a 03 00 00    	ja     800679 <vprintfmt+0x38a>
  80035f:	0f b6 c0             	movzbl %al,%eax
  800362:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800370:	eb d6                	jmp    800348 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	b8 00 00 00 00       	mov    $0x0,%eax
  80037a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800380:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800384:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800387:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80038a:	83 fa 09             	cmp    $0x9,%edx
  80038d:	77 39                	ja     8003c8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800392:	eb e9                	jmp    80037d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 48 04             	lea    0x4(%eax),%ecx
  80039a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a5:	eb 27                	jmp    8003ce <vprintfmt+0xdf>
  8003a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b1:	0f 49 c8             	cmovns %eax,%ecx
  8003b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ba:	eb 8c                	jmp    800348 <vprintfmt+0x59>
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c6:	eb 80                	jmp    800348 <vprintfmt+0x59>
  8003c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003cb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d2:	0f 89 70 ff ff ff    	jns    800348 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e5:	e9 5e ff ff ff       	jmp    800348 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f0:	e9 53 ff ff ff       	jmp    800348 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	53                   	push   %ebx
  800402:	ff 30                	pushl  (%eax)
  800404:	ff d6                	call   *%esi
			break;
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040c:	e9 04 ff ff ff       	jmp    800315 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	99                   	cltd   
  80041d:	31 d0                	xor    %edx,%eax
  80041f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800421:	83 f8 0f             	cmp    $0xf,%eax
  800424:	7f 0b                	jg     800431 <vprintfmt+0x142>
  800426:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80042d:	85 d2                	test   %edx,%edx
  80042f:	75 18                	jne    800449 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800431:	50                   	push   %eax
  800432:	68 6a 22 80 00       	push   $0x80226a
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 94 fe ff ff       	call   8002d2 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800444:	e9 cc fe ff ff       	jmp    800315 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800449:	52                   	push   %edx
  80044a:	68 c5 26 80 00       	push   $0x8026c5
  80044f:	53                   	push   %ebx
  800450:	56                   	push   %esi
  800451:	e8 7c fe ff ff       	call   8002d2 <printfmt>
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045c:	e9 b4 fe ff ff       	jmp    800315 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046c:	85 ff                	test   %edi,%edi
  80046e:	b8 63 22 80 00       	mov    $0x802263,%eax
  800473:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	0f 8e 94 00 00 00    	jle    800514 <vprintfmt+0x225>
  800480:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800484:	0f 84 98 00 00 00    	je     800522 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 d0             	pushl  -0x30(%ebp)
  800490:	57                   	push   %edi
  800491:	e8 86 02 00 00       	call   80071c <strnlen>
  800496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800499:	29 c1                	sub    %eax,%ecx
  80049b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	eb 0f                	jmp    8004be <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	53                   	push   %ebx
  8004b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	83 ef 01             	sub    $0x1,%edi
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	85 ff                	test   %edi,%edi
  8004c0:	7f ed                	jg     8004af <vprintfmt+0x1c0>
  8004c2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	0f 49 c1             	cmovns %ecx,%eax
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dd:	89 cb                	mov    %ecx,%ebx
  8004df:	eb 4d                	jmp    80052e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e5:	74 1b                	je     800502 <vprintfmt+0x213>
  8004e7:	0f be c0             	movsbl %al,%eax
  8004ea:	83 e8 20             	sub    $0x20,%eax
  8004ed:	83 f8 5e             	cmp    $0x5e,%eax
  8004f0:	76 10                	jbe    800502 <vprintfmt+0x213>
					putch('?', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	6a 3f                	push   $0x3f
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb 0d                	jmp    80050f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	52                   	push   %edx
  800509:	ff 55 08             	call   *0x8(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 eb 01             	sub    $0x1,%ebx
  800512:	eb 1a                	jmp    80052e <vprintfmt+0x23f>
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800520:	eb 0c                	jmp    80052e <vprintfmt+0x23f>
  800522:	89 75 08             	mov    %esi,0x8(%ebp)
  800525:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	0f be d0             	movsbl %al,%edx
  800538:	85 d2                	test   %edx,%edx
  80053a:	74 23                	je     80055f <vprintfmt+0x270>
  80053c:	85 f6                	test   %esi,%esi
  80053e:	78 a1                	js     8004e1 <vprintfmt+0x1f2>
  800540:	83 ee 01             	sub    $0x1,%esi
  800543:	79 9c                	jns    8004e1 <vprintfmt+0x1f2>
  800545:	89 df                	mov    %ebx,%edi
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	eb 18                	jmp    800567 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 20                	push   $0x20
  800555:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 08                	jmp    800567 <vprintfmt+0x278>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	85 ff                	test   %edi,%edi
  800569:	7f e4                	jg     80054f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	e9 a2 fd ff ff       	jmp    800315 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800573:	83 fa 01             	cmp    $0x1,%edx
  800576:	7e 16                	jle    80058e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 08             	lea    0x8(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	8b 50 04             	mov    0x4(%eax),%edx
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	eb 32                	jmp    8005c0 <vprintfmt+0x2d1>
	else if (lflag)
  80058e:	85 d2                	test   %edx,%edx
  800590:	74 18                	je     8005aa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 c1                	mov    %eax,%ecx
  8005a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a8:	eb 16                	jmp    8005c0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	89 c1                	mov    %eax,%ecx
  8005ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cf:	79 74                	jns    800645 <vprintfmt+0x356>
				putch('-', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 2d                	push   $0x2d
  8005d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005df:	f7 d8                	neg    %eax
  8005e1:	83 d2 00             	adc    $0x0,%edx
  8005e4:	f7 da                	neg    %edx
  8005e6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ee:	eb 55                	jmp    800645 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f3:	e8 83 fc ff ff       	call   80027b <getuint>
			base = 10;
  8005f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fd:	eb 46                	jmp    800645 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 74 fc ff ff       	call   80027b <getuint>
			base = 8;
  800607:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060c:	eb 37                	jmp    800645 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 30                	push   $0x30
  800614:	ff d6                	call   *%esi
			putch('x', putdat);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 78                	push   $0x78
  80061c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800631:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800636:	eb 0d                	jmp    800645 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 3b fc ff ff       	call   80027b <getuint>
			base = 16;
  800640:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800645:	83 ec 0c             	sub    $0xc,%esp
  800648:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064c:	57                   	push   %edi
  80064d:	ff 75 e0             	pushl  -0x20(%ebp)
  800650:	51                   	push   %ecx
  800651:	52                   	push   %edx
  800652:	50                   	push   %eax
  800653:	89 da                	mov    %ebx,%edx
  800655:	89 f0                	mov    %esi,%eax
  800657:	e8 70 fb ff ff       	call   8001cc <printnum>
			break;
  80065c:	83 c4 20             	add    $0x20,%esp
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800662:	e9 ae fc ff ff       	jmp    800315 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	51                   	push   %ecx
  80066c:	ff d6                	call   *%esi
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800674:	e9 9c fc ff ff       	jmp    800315 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 25                	push   $0x25
  80067f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb 03                	jmp    800689 <vprintfmt+0x39a>
  800686:	83 ef 01             	sub    $0x1,%edi
  800689:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068d:	75 f7                	jne    800686 <vprintfmt+0x397>
  80068f:	e9 81 fc ff ff       	jmp    800315 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800694:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800697:	5b                   	pop    %ebx
  800698:	5e                   	pop    %esi
  800699:	5f                   	pop    %edi
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
  8006a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	74 26                	je     8006e3 <vsnprintf+0x47>
  8006bd:	85 d2                	test   %edx,%edx
  8006bf:	7e 22                	jle    8006e3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c1:	ff 75 14             	pushl  0x14(%ebp)
  8006c4:	ff 75 10             	pushl  0x10(%ebp)
  8006c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ca:	50                   	push   %eax
  8006cb:	68 b5 02 80 00       	push   $0x8002b5
  8006d0:	e8 1a fc ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 05                	jmp    8006e8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f3:	50                   	push   %eax
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	ff 75 08             	pushl  0x8(%ebp)
  8006fd:	e8 9a ff ff ff       	call   80069c <vsnprintf>
	va_end(ap);

	return rc;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	eb 03                	jmp    800714 <strlen+0x10>
		n++;
  800711:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800714:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800718:	75 f7                	jne    800711 <strlen+0xd>
		n++;
	return n;
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	eb 03                	jmp    80072f <strnlen+0x13>
		n++;
  80072c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	39 c2                	cmp    %eax,%edx
  800731:	74 08                	je     80073b <strnlen+0x1f>
  800733:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800737:	75 f3                	jne    80072c <strnlen+0x10>
  800739:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800747:	89 c2                	mov    %eax,%edx
  800749:	83 c2 01             	add    $0x1,%edx
  80074c:	83 c1 01             	add    $0x1,%ecx
  80074f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800753:	88 5a ff             	mov    %bl,-0x1(%edx)
  800756:	84 db                	test   %bl,%bl
  800758:	75 ef                	jne    800749 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075a:	5b                   	pop    %ebx
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800764:	53                   	push   %ebx
  800765:	e8 9a ff ff ff       	call   800704 <strlen>
  80076a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	01 d8                	add    %ebx,%eax
  800772:	50                   	push   %eax
  800773:	e8 c5 ff ff ff       	call   80073d <strcpy>
	return dst;
}
  800778:	89 d8                	mov    %ebx,%eax
  80077a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078a:	89 f3                	mov    %esi,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078f:	89 f2                	mov    %esi,%edx
  800791:	eb 0f                	jmp    8007a2 <strncpy+0x23>
		*dst++ = *src;
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	0f b6 01             	movzbl (%ecx),%eax
  800799:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079c:	80 39 01             	cmpb   $0x1,(%ecx)
  80079f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a2:	39 da                	cmp    %ebx,%edx
  8007a4:	75 ed                	jne    800793 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	74 21                	je     8007e1 <strlcpy+0x35>
  8007c0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	eb 09                	jmp    8007d1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c8:	83 c2 01             	add    $0x1,%edx
  8007cb:	83 c1 01             	add    $0x1,%ecx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d1:	39 c2                	cmp    %eax,%edx
  8007d3:	74 09                	je     8007de <strlcpy+0x32>
  8007d5:	0f b6 19             	movzbl (%ecx),%ebx
  8007d8:	84 db                	test   %bl,%bl
  8007da:	75 ec                	jne    8007c8 <strlcpy+0x1c>
  8007dc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007de:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e1:	29 f0                	sub    %esi,%eax
}
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f0:	eb 06                	jmp    8007f8 <strcmp+0x11>
		p++, q++;
  8007f2:	83 c1 01             	add    $0x1,%ecx
  8007f5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	84 c0                	test   %al,%al
  8007fd:	74 04                	je     800803 <strcmp+0x1c>
  8007ff:	3a 02                	cmp    (%edx),%al
  800801:	74 ef                	je     8007f2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 c0             	movzbl %al,%eax
  800806:	0f b6 12             	movzbl (%edx),%edx
  800809:	29 d0                	sub    %edx,%eax
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
  800817:	89 c3                	mov    %eax,%ebx
  800819:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081c:	eb 06                	jmp    800824 <strncmp+0x17>
		n--, p++, q++;
  80081e:	83 c0 01             	add    $0x1,%eax
  800821:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800824:	39 d8                	cmp    %ebx,%eax
  800826:	74 15                	je     80083d <strncmp+0x30>
  800828:	0f b6 08             	movzbl (%eax),%ecx
  80082b:	84 c9                	test   %cl,%cl
  80082d:	74 04                	je     800833 <strncmp+0x26>
  80082f:	3a 0a                	cmp    (%edx),%cl
  800831:	74 eb                	je     80081e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 00             	movzbl (%eax),%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
  80083b:	eb 05                	jmp    800842 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084f:	eb 07                	jmp    800858 <strchr+0x13>
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 0f                	je     800864 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	0f b6 10             	movzbl (%eax),%edx
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800870:	eb 03                	jmp    800875 <strfind+0xf>
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 04                	je     800880 <strfind+0x1a>
  80087c:	84 d2                	test   %dl,%dl
  80087e:	75 f2                	jne    800872 <strfind+0xc>
			break;
	return (char *) s;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 36                	je     8008c8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800892:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800898:	75 28                	jne    8008c2 <memset+0x40>
  80089a:	f6 c1 03             	test   $0x3,%cl
  80089d:	75 23                	jne    8008c2 <memset+0x40>
		c &= 0xFF;
  80089f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a3:	89 d3                	mov    %edx,%ebx
  8008a5:	c1 e3 08             	shl    $0x8,%ebx
  8008a8:	89 d6                	mov    %edx,%esi
  8008aa:	c1 e6 18             	shl    $0x18,%esi
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	c1 e0 10             	shl    $0x10,%eax
  8008b2:	09 f0                	or     %esi,%eax
  8008b4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b6:	89 d8                	mov    %ebx,%eax
  8008b8:	09 d0                	or     %edx,%eax
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
  8008bd:	fc                   	cld    
  8008be:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c0:	eb 06                	jmp    8008c8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	fc                   	cld    
  8008c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dd:	39 c6                	cmp    %eax,%esi
  8008df:	73 35                	jae    800916 <memmove+0x47>
  8008e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	73 2e                	jae    800916 <memmove+0x47>
		s += n;
		d += n;
  8008e8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	09 fe                	or     %edi,%esi
  8008ef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f5:	75 13                	jne    80090a <memmove+0x3b>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 0e                	jne    80090a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fc:	83 ef 04             	sub    $0x4,%edi
  8008ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fd                   	std    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 09                	jmp    800913 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090a:	83 ef 01             	sub    $0x1,%edi
  80090d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800910:	fd                   	std    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800913:	fc                   	cld    
  800914:	eb 1d                	jmp    800933 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800916:	89 f2                	mov    %esi,%edx
  800918:	09 c2                	or     %eax,%edx
  80091a:	f6 c2 03             	test   $0x3,%dl
  80091d:	75 0f                	jne    80092e <memmove+0x5f>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 0a                	jne    80092e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092c:	eb 05                	jmp    800933 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093a:	ff 75 10             	pushl  0x10(%ebp)
  80093d:	ff 75 0c             	pushl  0xc(%ebp)
  800940:	ff 75 08             	pushl  0x8(%ebp)
  800943:	e8 87 ff ff ff       	call   8008cf <memmove>
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
  800955:	89 c6                	mov    %eax,%esi
  800957:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095a:	eb 1a                	jmp    800976 <memcmp+0x2c>
		if (*s1 != *s2)
  80095c:	0f b6 08             	movzbl (%eax),%ecx
  80095f:	0f b6 1a             	movzbl (%edx),%ebx
  800962:	38 d9                	cmp    %bl,%cl
  800964:	74 0a                	je     800970 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800966:	0f b6 c1             	movzbl %cl,%eax
  800969:	0f b6 db             	movzbl %bl,%ebx
  80096c:	29 d8                	sub    %ebx,%eax
  80096e:	eb 0f                	jmp    80097f <memcmp+0x35>
		s1++, s2++;
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	39 f0                	cmp    %esi,%eax
  800978:	75 e2                	jne    80095c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098a:	89 c1                	mov    %eax,%ecx
  80098c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800993:	eb 0a                	jmp    80099f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	39 da                	cmp    %ebx,%edx
  80099a:	74 07                	je     8009a3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	39 c8                	cmp    %ecx,%eax
  8009a1:	72 f2                	jb     800995 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b2:	eb 03                	jmp    8009b7 <strtol+0x11>
		s++;
  8009b4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b7:	0f b6 01             	movzbl (%ecx),%eax
  8009ba:	3c 20                	cmp    $0x20,%al
  8009bc:	74 f6                	je     8009b4 <strtol+0xe>
  8009be:	3c 09                	cmp    $0x9,%al
  8009c0:	74 f2                	je     8009b4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c2:	3c 2b                	cmp    $0x2b,%al
  8009c4:	75 0a                	jne    8009d0 <strtol+0x2a>
		s++;
  8009c6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ce:	eb 11                	jmp    8009e1 <strtol+0x3b>
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d5:	3c 2d                	cmp    $0x2d,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x3b>
		s++, neg = 1;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e7:	75 15                	jne    8009fe <strtol+0x58>
  8009e9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ec:	75 10                	jne    8009fe <strtol+0x58>
  8009ee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f2:	75 7c                	jne    800a70 <strtol+0xca>
		s += 2, base = 16;
  8009f4:	83 c1 02             	add    $0x2,%ecx
  8009f7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fc:	eb 16                	jmp    800a14 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fe:	85 db                	test   %ebx,%ebx
  800a00:	75 12                	jne    800a14 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	75 08                	jne    800a14 <strtol+0x6e>
		s++, base = 8;
  800a0c:	83 c1 01             	add    $0x1,%ecx
  800a0f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
  800a19:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1c:	0f b6 11             	movzbl (%ecx),%edx
  800a1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 09             	cmp    $0x9,%bl
  800a27:	77 08                	ja     800a31 <strtol+0x8b>
			dig = *s - '0';
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 30             	sub    $0x30,%edx
  800a2f:	eb 22                	jmp    800a53 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	80 fb 19             	cmp    $0x19,%bl
  800a39:	77 08                	ja     800a43 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3b:	0f be d2             	movsbl %dl,%edx
  800a3e:	83 ea 57             	sub    $0x57,%edx
  800a41:	eb 10                	jmp    800a53 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	80 fb 19             	cmp    $0x19,%bl
  800a4b:	77 16                	ja     800a63 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a56:	7d 0b                	jge    800a63 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a61:	eb b9                	jmp    800a1c <strtol+0x76>

	if (endptr)
  800a63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a67:	74 0d                	je     800a76 <strtol+0xd0>
		*endptr = (char *) s;
  800a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6c:	89 0e                	mov    %ecx,(%esi)
  800a6e:	eb 06                	jmp    800a76 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	74 98                	je     800a0c <strtol+0x66>
  800a74:	eb 9e                	jmp    800a14 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a76:	89 c2                	mov    %eax,%edx
  800a78:	f7 da                	neg    %edx
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	0f 45 c2             	cmovne %edx,%eax
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	89 c7                	mov    %eax,%edi
  800a99:	89 c6                	mov    %eax,%esi
  800a9b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aad:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab2:	89 d1                	mov    %edx,%ecx
  800ab4:	89 d3                	mov    %edx,%ebx
  800ab6:	89 d7                	mov    %edx,%edi
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	89 cb                	mov    %ecx,%ebx
  800ad9:	89 cf                	mov    %ecx,%edi
  800adb:	89 ce                	mov    %ecx,%esi
  800add:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	7e 17                	jle    800afa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae3:	83 ec 0c             	sub    $0xc,%esp
  800ae6:	50                   	push   %eax
  800ae7:	6a 03                	push   $0x3
  800ae9:	68 5f 25 80 00       	push   $0x80255f
  800aee:	6a 23                	push   $0x23
  800af0:	68 7c 25 80 00       	push   $0x80257c
  800af5:	e8 6d 13 00 00       	call   801e67 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_yield>:

void
sys_yield(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b31:	89 d1                	mov    %edx,%ecx
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	be 00 00 00 00       	mov    $0x0,%esi
  800b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5c:	89 f7                	mov    %esi,%edi
  800b5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 04                	push   $0x4
  800b6a:	68 5f 25 80 00       	push   $0x80255f
  800b6f:	6a 23                	push   $0x23
  800b71:	68 7c 25 80 00       	push   $0x80257c
  800b76:	e8 ec 12 00 00       	call   801e67 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9d:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 05                	push   $0x5
  800bac:	68 5f 25 80 00       	push   $0x80255f
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 7c 25 80 00       	push   $0x80257c
  800bb8:	e8 aa 12 00 00       	call   801e67 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	89 df                	mov    %ebx,%edi
  800be0:	89 de                	mov    %ebx,%esi
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 06                	push   $0x6
  800bee:	68 5f 25 80 00       	push   $0x80255f
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 7c 25 80 00       	push   $0x80257c
  800bfa:	e8 68 12 00 00       	call   801e67 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 17                	jle    800c41 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 08                	push   $0x8
  800c30:	68 5f 25 80 00       	push   $0x80255f
  800c35:	6a 23                	push   $0x23
  800c37:	68 7c 25 80 00       	push   $0x80257c
  800c3c:	e8 26 12 00 00       	call   801e67 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 17                	jle    800c83 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 09                	push   $0x9
  800c72:	68 5f 25 80 00       	push   $0x80255f
  800c77:	6a 23                	push   $0x23
  800c79:	68 7c 25 80 00       	push   $0x80257c
  800c7e:	e8 e4 11 00 00       	call   801e67 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 17                	jle    800cc5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 0a                	push   $0xa
  800cb4:	68 5f 25 80 00       	push   $0x80255f
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 7c 25 80 00       	push   $0x80257c
  800cc0:	e8 a2 11 00 00       	call   801e67 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
  800cd8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfe:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 cb                	mov    %ecx,%ebx
  800d08:	89 cf                	mov    %ecx,%edi
  800d0a:	89 ce                	mov    %ecx,%esi
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 17                	jle    800d29 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 0d                	push   $0xd
  800d18:	68 5f 25 80 00       	push   $0x80255f
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 7c 25 80 00       	push   $0x80257c
  800d24:	e8 3e 11 00 00       	call   801e67 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 cb                	mov    %ecx,%ebx
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	89 ce                	mov    %ecx,%esi
  800d4a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
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
  800d5c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 cb                	mov    %ecx,%ebx
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	89 ce                	mov    %ecx,%esi
  800d6a:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	53                   	push   %ebx
  800d75:	83 ec 04             	sub    $0x4,%esp
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d7d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d81:	74 11                	je     800d94 <pgfault+0x23>
  800d83:	89 d8                	mov    %ebx,%eax
  800d85:	c1 e8 0c             	shr    $0xc,%eax
  800d88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d8f:	f6 c4 08             	test   $0x8,%ah
  800d92:	75 14                	jne    800da8 <pgfault+0x37>
		panic("faulting access");
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	68 8a 25 80 00       	push   $0x80258a
  800d9c:	6a 1e                	push   $0x1e
  800d9e:	68 9a 25 80 00       	push   $0x80259a
  800da3:	e8 bf 10 00 00       	call   801e67 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	6a 07                	push   $0x7
  800dad:	68 00 f0 7f 00       	push   $0x7ff000
  800db2:	6a 00                	push   $0x0
  800db4:	e8 87 fd ff ff       	call   800b40 <sys_page_alloc>
	if (r < 0) {
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	79 12                	jns    800dd2 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dc0:	50                   	push   %eax
  800dc1:	68 a5 25 80 00       	push   $0x8025a5
  800dc6:	6a 2c                	push   $0x2c
  800dc8:	68 9a 25 80 00       	push   $0x80259a
  800dcd:	e8 95 10 00 00       	call   801e67 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dd2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	68 00 10 00 00       	push   $0x1000
  800de0:	53                   	push   %ebx
  800de1:	68 00 f0 7f 00       	push   $0x7ff000
  800de6:	e8 4c fb ff ff       	call   800937 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800deb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df2:	53                   	push   %ebx
  800df3:	6a 00                	push   $0x0
  800df5:	68 00 f0 7f 00       	push   $0x7ff000
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 82 fd ff ff       	call   800b83 <sys_page_map>
	if (r < 0) {
  800e01:	83 c4 20             	add    $0x20,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	79 12                	jns    800e1a <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e08:	50                   	push   %eax
  800e09:	68 a5 25 80 00       	push   $0x8025a5
  800e0e:	6a 33                	push   $0x33
  800e10:	68 9a 25 80 00       	push   $0x80259a
  800e15:	e8 4d 10 00 00       	call   801e67 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	68 00 f0 7f 00       	push   $0x7ff000
  800e22:	6a 00                	push   $0x0
  800e24:	e8 9c fd ff ff       	call   800bc5 <sys_page_unmap>
	if (r < 0) {
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	79 12                	jns    800e42 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e30:	50                   	push   %eax
  800e31:	68 a5 25 80 00       	push   $0x8025a5
  800e36:	6a 37                	push   $0x37
  800e38:	68 9a 25 80 00       	push   $0x80259a
  800e3d:	e8 25 10 00 00       	call   801e67 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e45:	c9                   	leave  
  800e46:	c3                   	ret    

00800e47 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e50:	68 71 0d 80 00       	push   $0x800d71
  800e55:	e8 53 10 00 00       	call   801ead <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e5a:	b8 07 00 00 00       	mov    $0x7,%eax
  800e5f:	cd 30                	int    $0x30
  800e61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 17                	jns    800e82 <fork+0x3b>
		panic("fork fault %e");
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	68 be 25 80 00       	push   $0x8025be
  800e73:	68 84 00 00 00       	push   $0x84
  800e78:	68 9a 25 80 00       	push   $0x80259a
  800e7d:	e8 e5 0f 00 00       	call   801e67 <_panic>
  800e82:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e84:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e88:	75 25                	jne    800eaf <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e8a:	e8 73 fc ff ff       	call   800b02 <sys_getenvid>
  800e8f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 e2 07             	shl    $0x7,%edx
  800e99:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800ea0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	e9 61 01 00 00       	jmp    801010 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	6a 07                	push   $0x7
  800eb4:	68 00 f0 bf ee       	push   $0xeebff000
  800eb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ebc:	e8 7f fc ff ff       	call   800b40 <sys_page_alloc>
  800ec1:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec9:	89 d8                	mov    %ebx,%eax
  800ecb:	c1 e8 16             	shr    $0x16,%eax
  800ece:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed5:	a8 01                	test   $0x1,%al
  800ed7:	0f 84 fc 00 00 00    	je     800fd9 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800edd:	89 d8                	mov    %ebx,%eax
  800edf:	c1 e8 0c             	shr    $0xc,%eax
  800ee2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	0f 84 e7 00 00 00    	je     800fd9 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ef2:	89 c6                	mov    %eax,%esi
  800ef4:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ef7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efe:	f6 c6 04             	test   $0x4,%dh
  800f01:	74 39                	je     800f3c <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f03:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f12:	50                   	push   %eax
  800f13:	56                   	push   %esi
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	6a 00                	push   $0x0
  800f18:	e8 66 fc ff ff       	call   800b83 <sys_page_map>
		if (r < 0) {
  800f1d:	83 c4 20             	add    $0x20,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	0f 89 b1 00 00 00    	jns    800fd9 <fork+0x192>
		    	panic("sys page map fault %e");
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	68 cc 25 80 00       	push   $0x8025cc
  800f30:	6a 54                	push   $0x54
  800f32:	68 9a 25 80 00       	push   $0x80259a
  800f37:	e8 2b 0f 00 00       	call   801e67 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f3c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f43:	f6 c2 02             	test   $0x2,%dl
  800f46:	75 0c                	jne    800f54 <fork+0x10d>
  800f48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4f:	f6 c4 08             	test   $0x8,%ah
  800f52:	74 5b                	je     800faf <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	68 05 08 00 00       	push   $0x805
  800f5c:	56                   	push   %esi
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 1d fc ff ff       	call   800b83 <sys_page_map>
		if (r < 0) {
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	79 14                	jns    800f81 <fork+0x13a>
		    	panic("sys page map fault %e");
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	68 cc 25 80 00       	push   $0x8025cc
  800f75:	6a 5b                	push   $0x5b
  800f77:	68 9a 25 80 00       	push   $0x80259a
  800f7c:	e8 e6 0e 00 00       	call   801e67 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	68 05 08 00 00       	push   $0x805
  800f89:	56                   	push   %esi
  800f8a:	6a 00                	push   $0x0
  800f8c:	56                   	push   %esi
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 ef fb ff ff       	call   800b83 <sys_page_map>
		if (r < 0) {
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	79 3e                	jns    800fd9 <fork+0x192>
		    	panic("sys page map fault %e");
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	68 cc 25 80 00       	push   $0x8025cc
  800fa3:	6a 5f                	push   $0x5f
  800fa5:	68 9a 25 80 00       	push   $0x80259a
  800faa:	e8 b8 0e 00 00       	call   801e67 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	6a 05                	push   $0x5
  800fb4:	56                   	push   %esi
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 c5 fb ff ff       	call   800b83 <sys_page_map>
		if (r < 0) {
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	79 14                	jns    800fd9 <fork+0x192>
		    	panic("sys page map fault %e");
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	68 cc 25 80 00       	push   $0x8025cc
  800fcd:	6a 64                	push   $0x64
  800fcf:	68 9a 25 80 00       	push   $0x80259a
  800fd4:	e8 8e 0e 00 00       	call   801e67 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fdf:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fe5:	0f 85 de fe ff ff    	jne    800ec9 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800feb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ff0:	8b 40 70             	mov    0x70(%eax),%eax
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	50                   	push   %eax
  800ff7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ffa:	57                   	push   %edi
  800ffb:	e8 8b fc ff ff       	call   800c8b <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801000:	83 c4 08             	add    $0x8,%esp
  801003:	6a 02                	push   $0x2
  801005:	57                   	push   %edi
  801006:	e8 fc fb ff ff       	call   800c07 <sys_env_set_status>
	
	return envid;
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sfork>:

envid_t
sfork(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80102a:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801030:	83 ec 08             	sub    $0x8,%esp
  801033:	53                   	push   %ebx
  801034:	68 e4 25 80 00       	push   $0x8025e4
  801039:	e8 7a f1 ff ff       	call   8001b8 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80103e:	c7 04 24 eb 00 80 00 	movl   $0x8000eb,(%esp)
  801045:	e8 e7 fc ff ff       	call   800d31 <sys_thread_create>
  80104a:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	53                   	push   %ebx
  801050:	68 e4 25 80 00       	push   $0x8025e4
  801055:	e8 5e f1 ff ff       	call   8001b8 <cprintf>
	return id;
	//return 0;
}
  80105a:	89 f0                	mov    %esi,%eax
  80105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	8b 75 08             	mov    0x8(%ebp),%esi
  80106b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801071:	85 c0                	test   %eax,%eax
  801073:	75 12                	jne    801087 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	68 00 00 c0 ee       	push   $0xeec00000
  80107d:	e8 6e fc ff ff       	call   800cf0 <sys_ipc_recv>
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	eb 0c                	jmp    801093 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	50                   	push   %eax
  80108b:	e8 60 fc ff ff       	call   800cf0 <sys_ipc_recv>
  801090:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801093:	85 f6                	test   %esi,%esi
  801095:	0f 95 c1             	setne  %cl
  801098:	85 db                	test   %ebx,%ebx
  80109a:	0f 95 c2             	setne  %dl
  80109d:	84 d1                	test   %dl,%cl
  80109f:	74 09                	je     8010aa <ipc_recv+0x47>
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 1f             	shr    $0x1f,%edx
  8010a6:	84 d2                	test   %dl,%dl
  8010a8:	75 2a                	jne    8010d4 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010aa:	85 f6                	test   %esi,%esi
  8010ac:	74 0d                	je     8010bb <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8010ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8010b9:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8010bb:	85 db                	test   %ebx,%ebx
  8010bd:	74 0d                	je     8010cc <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8010bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c4:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8010ca:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d1:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  8010d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8010ed:	85 db                	test   %ebx,%ebx
  8010ef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010f4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8010f7:	ff 75 14             	pushl  0x14(%ebp)
  8010fa:	53                   	push   %ebx
  8010fb:	56                   	push   %esi
  8010fc:	57                   	push   %edi
  8010fd:	e8 cb fb ff ff       	call   800ccd <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801102:	89 c2                	mov    %eax,%edx
  801104:	c1 ea 1f             	shr    $0x1f,%edx
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	84 d2                	test   %dl,%dl
  80110c:	74 17                	je     801125 <ipc_send+0x4a>
  80110e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801111:	74 12                	je     801125 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801113:	50                   	push   %eax
  801114:	68 07 26 80 00       	push   $0x802607
  801119:	6a 47                	push   $0x47
  80111b:	68 15 26 80 00       	push   $0x802615
  801120:	e8 42 0d 00 00       	call   801e67 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801125:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801128:	75 07                	jne    801131 <ipc_send+0x56>
			sys_yield();
  80112a:	e8 f2 f9 ff ff       	call   800b21 <sys_yield>
  80112f:	eb c6                	jmp    8010f7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801131:	85 c0                	test   %eax,%eax
  801133:	75 c2                	jne    8010f7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801148:	89 c2                	mov    %eax,%edx
  80114a:	c1 e2 07             	shl    $0x7,%edx
  80114d:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801154:	8b 52 5c             	mov    0x5c(%edx),%edx
  801157:	39 ca                	cmp    %ecx,%edx
  801159:	75 11                	jne    80116c <ipc_find_env+0x2f>
			return envs[i].env_id;
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 e2 07             	shl    $0x7,%edx
  801160:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801167:	8b 40 54             	mov    0x54(%eax),%eax
  80116a:	eb 0f                	jmp    80117b <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80116c:	83 c0 01             	add    $0x1,%eax
  80116f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801174:	75 d2                	jne    801148 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
}
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
  801198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	c1 ea 16             	shr    $0x16,%edx
  8011b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 11                	je     8011d1 <fd_alloc+0x2d>
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 0c             	shr    $0xc,%edx
  8011c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	75 09                	jne    8011da <fd_alloc+0x36>
			*fd_store = fd;
  8011d1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d8:	eb 17                	jmp    8011f1 <fd_alloc+0x4d>
  8011da:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011df:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e4:	75 c9                	jne    8011af <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 f8 1f             	cmp    $0x1f,%eax
  8011fc:	77 36                	ja     801234 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
  801201:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 24                	je     80123b <fd_lookup+0x48>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 1a                	je     801242 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 02                	mov    %eax,(%edx)
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 13                	jmp    801247 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb 0c                	jmp    801247 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb 05                	jmp    801247 <fd_lookup+0x54>
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801252:	ba 9c 26 80 00       	mov    $0x80269c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801257:	eb 13                	jmp    80126c <dev_lookup+0x23>
  801259:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125c:	39 08                	cmp    %ecx,(%eax)
  80125e:	75 0c                	jne    80126c <dev_lookup+0x23>
			*dev = devtab[i];
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	89 01                	mov    %eax,(%ecx)
			return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	eb 2e                	jmp    80129a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126c:	8b 02                	mov    (%edx),%eax
  80126e:	85 c0                	test   %eax,%eax
  801270:	75 e7                	jne    801259 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801272:	a1 04 40 80 00       	mov    0x804004,%eax
  801277:	8b 40 54             	mov    0x54(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	51                   	push   %ecx
  80127e:	50                   	push   %eax
  80127f:	68 20 26 80 00       	push   $0x802620
  801284:	e8 2f ef ff ff       	call   8001b8 <cprintf>
	*dev = 0;
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 10             	sub    $0x10,%esp
  8012a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b4:	c1 e8 0c             	shr    $0xc,%eax
  8012b7:	50                   	push   %eax
  8012b8:	e8 36 ff ff ff       	call   8011f3 <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 05                	js     8012c9 <fd_close+0x2d>
	    || fd != fd2)
  8012c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c7:	74 0c                	je     8012d5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c9:	84 db                	test   %bl,%bl
  8012cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d0:	0f 44 c2             	cmove  %edx,%eax
  8012d3:	eb 41                	jmp    801316 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	ff 36                	pushl  (%esi)
  8012de:	e8 66 ff ff ff       	call   801249 <dev_lookup>
  8012e3:	89 c3                	mov    %eax,%ebx
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 1a                	js     801306 <fd_close+0x6a>
		if (dev->dev_close)
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	74 0b                	je     801306 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	ff d0                	call   *%eax
  801301:	89 c3                	mov    %eax,%ebx
  801303:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	56                   	push   %esi
  80130a:	6a 00                	push   $0x0
  80130c:	e8 b4 f8 ff ff       	call   800bc5 <sys_page_unmap>
	return r;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	89 d8                	mov    %ebx,%eax
}
  801316:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 c4 fe ff ff       	call   8011f3 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 10                	js     801346 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	6a 01                	push   $0x1
  80133b:	ff 75 f4             	pushl  -0xc(%ebp)
  80133e:	e8 59 ff ff ff       	call   80129c <fd_close>
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <close_all>:

void
close_all(void)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	53                   	push   %ebx
  801358:	e8 c0 ff ff ff       	call   80131d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135d:	83 c3 01             	add    $0x1,%ebx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	83 fb 20             	cmp    $0x20,%ebx
  801366:	75 ec                	jne    801354 <close_all+0xc>
		close(i);
}
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	57                   	push   %edi
  801371:	56                   	push   %esi
  801372:	53                   	push   %ebx
  801373:	83 ec 2c             	sub    $0x2c,%esp
  801376:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 6e fe ff ff       	call   8011f3 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	0f 88 c1 00 00 00    	js     801451 <dup+0xe4>
		return r;
	close(newfdnum);
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	56                   	push   %esi
  801394:	e8 84 ff ff ff       	call   80131d <close>

	newfd = INDEX2FD(newfdnum);
  801399:	89 f3                	mov    %esi,%ebx
  80139b:	c1 e3 0c             	shl    $0xc,%ebx
  80139e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a4:	83 c4 04             	add    $0x4,%esp
  8013a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013aa:	e8 de fd ff ff       	call   80118d <fd2data>
  8013af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 d4 fd ff ff       	call   80118d <fd2data>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	c1 e8 16             	shr    $0x16,%eax
  8013c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cb:	a8 01                	test   $0x1,%al
  8013cd:	74 37                	je     801406 <dup+0x99>
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	c1 e8 0c             	shr    $0xc,%eax
  8013d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013db:	f6 c2 01             	test   $0x1,%dl
  8013de:	74 26                	je     801406 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f3:	6a 00                	push   $0x0
  8013f5:	57                   	push   %edi
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 86 f7 ff ff       	call   800b83 <sys_page_map>
  8013fd:	89 c7                	mov    %eax,%edi
  8013ff:	83 c4 20             	add    $0x20,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 2e                	js     801434 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801406:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801409:	89 d0                	mov    %edx,%eax
  80140b:	c1 e8 0c             	shr    $0xc,%eax
  80140e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	25 07 0e 00 00       	and    $0xe07,%eax
  80141d:	50                   	push   %eax
  80141e:	53                   	push   %ebx
  80141f:	6a 00                	push   $0x0
  801421:	52                   	push   %edx
  801422:	6a 00                	push   $0x0
  801424:	e8 5a f7 ff ff       	call   800b83 <sys_page_map>
  801429:	89 c7                	mov    %eax,%edi
  80142b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801430:	85 ff                	test   %edi,%edi
  801432:	79 1d                	jns    801451 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	e8 86 f7 ff ff       	call   800bc5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	ff 75 d4             	pushl  -0x2c(%ebp)
  801445:	6a 00                	push   $0x0
  801447:	e8 79 f7 ff ff       	call   800bc5 <sys_page_unmap>
	return r;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	89 f8                	mov    %edi,%eax
}
  801451:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5f                   	pop    %edi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 14             	sub    $0x14,%esp
  801460:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	53                   	push   %ebx
  801468:	e8 86 fd ff ff       	call   8011f3 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	89 c2                	mov    %eax,%edx
  801472:	85 c0                	test   %eax,%eax
  801474:	78 6d                	js     8014e3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	ff 30                	pushl  (%eax)
  801482:	e8 c2 fd ff ff       	call   801249 <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 4c                	js     8014da <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801491:	8b 42 08             	mov    0x8(%edx),%eax
  801494:	83 e0 03             	and    $0x3,%eax
  801497:	83 f8 01             	cmp    $0x1,%eax
  80149a:	75 21                	jne    8014bd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149c:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a1:	8b 40 54             	mov    0x54(%eax),%eax
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	50                   	push   %eax
  8014a9:	68 61 26 80 00       	push   $0x802661
  8014ae:	e8 05 ed ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bb:	eb 26                	jmp    8014e3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	8b 40 08             	mov    0x8(%eax),%eax
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	74 17                	je     8014de <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014c7:	83 ec 04             	sub    $0x4,%esp
  8014ca:	ff 75 10             	pushl  0x10(%ebp)
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	52                   	push   %edx
  8014d1:	ff d0                	call   *%eax
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 09                	jmp    8014e3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	eb 05                	jmp    8014e3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014e3:	89 d0                	mov    %edx,%eax
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fe:	eb 21                	jmp    801521 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	89 f0                	mov    %esi,%eax
  801505:	29 d8                	sub    %ebx,%eax
  801507:	50                   	push   %eax
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	03 45 0c             	add    0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	57                   	push   %edi
  80150f:	e8 45 ff ff ff       	call   801459 <read>
		if (m < 0)
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 10                	js     80152b <readn+0x41>
			return m;
		if (m == 0)
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 0a                	je     801529 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151f:	01 c3                	add    %eax,%ebx
  801521:	39 f3                	cmp    %esi,%ebx
  801523:	72 db                	jb     801500 <readn+0x16>
  801525:	89 d8                	mov    %ebx,%eax
  801527:	eb 02                	jmp    80152b <readn+0x41>
  801529:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	53                   	push   %ebx
  801542:	e8 ac fc ff ff       	call   8011f3 <fd_lookup>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	89 c2                	mov    %eax,%edx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 68                	js     8015b8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	ff 30                	pushl  (%eax)
  80155c:	e8 e8 fc ff ff       	call   801249 <dev_lookup>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 47                	js     8015af <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156f:	75 21                	jne    801592 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801571:	a1 04 40 80 00       	mov    0x804004,%eax
  801576:	8b 40 54             	mov    0x54(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	53                   	push   %ebx
  80157d:	50                   	push   %eax
  80157e:	68 7d 26 80 00       	push   $0x80267d
  801583:	e8 30 ec ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801590:	eb 26                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801592:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801595:	8b 52 0c             	mov    0xc(%edx),%edx
  801598:	85 d2                	test   %edx,%edx
  80159a:	74 17                	je     8015b3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	50                   	push   %eax
  8015a6:	ff d2                	call   *%edx
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 09                	jmp    8015b8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	eb 05                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 22 fc ff ff       	call   8011f3 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 0e                	js     8015e6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015de:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 14             	sub    $0x14,%esp
  8015ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	53                   	push   %ebx
  8015f7:	e8 f7 fb ff ff       	call   8011f3 <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 65                	js     80166a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 33 fc ff ff       	call   801249 <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 44                	js     801661 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801624:	75 21                	jne    801647 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801626:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162b:	8b 40 54             	mov    0x54(%eax),%eax
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	53                   	push   %ebx
  801632:	50                   	push   %eax
  801633:	68 40 26 80 00       	push   $0x802640
  801638:	e8 7b eb ff ff       	call   8001b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801645:	eb 23                	jmp    80166a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	8b 52 18             	mov    0x18(%edx),%edx
  80164d:	85 d2                	test   %edx,%edx
  80164f:	74 14                	je     801665 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	ff d2                	call   *%edx
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	ff 75 08             	pushl  0x8(%ebp)
  801682:	e8 6c fb ff ff       	call   8011f3 <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 58                	js     8016e8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 a8 fb ff ff       	call   801249 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 37                	js     8016df <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016af:	74 32                	je     8016e3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bb:	00 00 00 
	stat->st_isdir = 0;
  8016be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c5:	00 00 00 
	stat->st_dev = dev;
  8016c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d5:	ff 50 14             	call   *0x14(%eax)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb 09                	jmp    8016e8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	eb 05                	jmp    8016e8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e8:	89 d0                	mov    %edx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	6a 00                	push   $0x0
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 e3 01 00 00       	call   8018e4 <open>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 1b                	js     801725 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	ff 75 0c             	pushl  0xc(%ebp)
  801710:	50                   	push   %eax
  801711:	e8 5b ff ff ff       	call   801671 <fstat>
  801716:	89 c6                	mov    %eax,%esi
	close(fd);
  801718:	89 1c 24             	mov    %ebx,(%esp)
  80171b:	e8 fd fb ff ff       	call   80131d <close>
	return r;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	89 f0                	mov    %esi,%eax
}
  801725:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	89 c6                	mov    %eax,%esi
  801733:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801735:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173c:	75 12                	jne    801750 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	6a 01                	push   $0x1
  801743:	e8 f5 f9 ff ff       	call   80113d <ipc_find_env>
  801748:	a3 00 40 80 00       	mov    %eax,0x804000
  80174d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801750:	6a 07                	push   $0x7
  801752:	68 00 50 80 00       	push   $0x805000
  801757:	56                   	push   %esi
  801758:	ff 35 00 40 80 00    	pushl  0x804000
  80175e:	e8 78 f9 ff ff       	call   8010db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801763:	83 c4 0c             	add    $0xc,%esp
  801766:	6a 00                	push   $0x0
  801768:	53                   	push   %ebx
  801769:	6a 00                	push   $0x0
  80176b:	e8 f3 f8 ff ff       	call   801063 <ipc_recv>
}
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 02 00 00 00       	mov    $0x2,%eax
  80179a:	e8 8d ff ff ff       	call   80172c <fsipc>
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bc:	e8 6b ff ff ff       	call   80172c <fsipc>
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e2:	e8 45 ff ff ff       	call   80172c <fsipc>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 2c                	js     801817 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	53                   	push   %ebx
  8017f4:	e8 44 ef ff ff       	call   80073d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801804:	a1 84 50 80 00       	mov    0x805084,%eax
  801809:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801825:	8b 55 08             	mov    0x8(%ebp),%edx
  801828:	8b 52 0c             	mov    0xc(%edx),%edx
  80182b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801831:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801836:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183b:	0f 47 c2             	cmova  %edx,%eax
  80183e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801843:	50                   	push   %eax
  801844:	ff 75 0c             	pushl  0xc(%ebp)
  801847:	68 08 50 80 00       	push   $0x805008
  80184c:	e8 7e f0 ff ff       	call   8008cf <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 04 00 00 00       	mov    $0x4,%eax
  80185b:	e8 cc fe ff ff       	call   80172c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801875:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 03 00 00 00       	mov    $0x3,%eax
  801885:	e8 a2 fe ff ff       	call   80172c <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 4b                	js     8018db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801890:	39 c6                	cmp    %eax,%esi
  801892:	73 16                	jae    8018aa <devfile_read+0x48>
  801894:	68 ac 26 80 00       	push   $0x8026ac
  801899:	68 b3 26 80 00       	push   $0x8026b3
  80189e:	6a 7c                	push   $0x7c
  8018a0:	68 c8 26 80 00       	push   $0x8026c8
  8018a5:	e8 bd 05 00 00       	call   801e67 <_panic>
	assert(r <= PGSIZE);
  8018aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018af:	7e 16                	jle    8018c7 <devfile_read+0x65>
  8018b1:	68 d3 26 80 00       	push   $0x8026d3
  8018b6:	68 b3 26 80 00       	push   $0x8026b3
  8018bb:	6a 7d                	push   $0x7d
  8018bd:	68 c8 26 80 00       	push   $0x8026c8
  8018c2:	e8 a0 05 00 00       	call   801e67 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	50                   	push   %eax
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	e8 f7 ef ff ff       	call   8008cf <memmove>
	return r;
  8018d8:	83 c4 10             	add    $0x10,%esp
}
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 20             	sub    $0x20,%esp
  8018eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ee:	53                   	push   %ebx
  8018ef:	e8 10 ee ff ff       	call   800704 <strlen>
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fc:	7f 67                	jg     801965 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801904:	50                   	push   %eax
  801905:	e8 9a f8 ff ff       	call   8011a4 <fd_alloc>
  80190a:	83 c4 10             	add    $0x10,%esp
		return r;
  80190d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 57                	js     80196a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	53                   	push   %ebx
  801917:	68 00 50 80 00       	push   $0x805000
  80191c:	e8 1c ee ff ff       	call   80073d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801929:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192c:	b8 01 00 00 00       	mov    $0x1,%eax
  801931:	e8 f6 fd ff ff       	call   80172c <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	79 14                	jns    801953 <open+0x6f>
		fd_close(fd, 0);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	6a 00                	push   $0x0
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	e8 50 f9 ff ff       	call   80129c <fd_close>
		return r;
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	89 da                	mov    %ebx,%edx
  801951:	eb 17                	jmp    80196a <open+0x86>
	}

	return fd2num(fd);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	e8 1f f8 ff ff       	call   80117d <fd2num>
  80195e:	89 c2                	mov    %eax,%edx
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb 05                	jmp    80196a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801965:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196a:	89 d0                	mov    %edx,%eax
  80196c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 08 00 00 00       	mov    $0x8,%eax
  801981:	e8 a6 fd ff ff       	call   80172c <fsipc>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	ff 75 08             	pushl  0x8(%ebp)
  801996:	e8 f2 f7 ff ff       	call   80118d <fd2data>
  80199b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199d:	83 c4 08             	add    $0x8,%esp
  8019a0:	68 df 26 80 00       	push   $0x8026df
  8019a5:	53                   	push   %ebx
  8019a6:	e8 92 ed ff ff       	call   80073d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ab:	8b 46 04             	mov    0x4(%esi),%eax
  8019ae:	2b 06                	sub    (%esi),%eax
  8019b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bd:	00 00 00 
	stat->st_dev = &devpipe;
  8019c0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c7:	30 80 00 
	return 0;
}
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e0:	53                   	push   %ebx
  8019e1:	6a 00                	push   $0x0
  8019e3:	e8 dd f1 ff ff       	call   800bc5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e8:	89 1c 24             	mov    %ebx,(%esp)
  8019eb:	e8 9d f7 ff ff       	call   80118d <fd2data>
  8019f0:	83 c4 08             	add    $0x8,%esp
  8019f3:	50                   	push   %eax
  8019f4:	6a 00                	push   $0x0
  8019f6:	e8 ca f1 ff ff       	call   800bc5 <sys_page_unmap>
}
  8019fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	57                   	push   %edi
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 1c             	sub    $0x1c,%esp
  801a09:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a0e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a13:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1c:	e8 1b 05 00 00       	call   801f3c <pageref>
  801a21:	89 c3                	mov    %eax,%ebx
  801a23:	89 3c 24             	mov    %edi,(%esp)
  801a26:	e8 11 05 00 00       	call   801f3c <pageref>
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	39 c3                	cmp    %eax,%ebx
  801a30:	0f 94 c1             	sete   %cl
  801a33:	0f b6 c9             	movzbl %cl,%ecx
  801a36:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a39:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a3f:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801a42:	39 ce                	cmp    %ecx,%esi
  801a44:	74 1b                	je     801a61 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a46:	39 c3                	cmp    %eax,%ebx
  801a48:	75 c4                	jne    801a0e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4a:	8b 42 64             	mov    0x64(%edx),%eax
  801a4d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a50:	50                   	push   %eax
  801a51:	56                   	push   %esi
  801a52:	68 e6 26 80 00       	push   $0x8026e6
  801a57:	e8 5c e7 ff ff       	call   8001b8 <cprintf>
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	eb ad                	jmp    801a0e <_pipeisclosed+0xe>
	}
}
  801a61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 28             	sub    $0x28,%esp
  801a75:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a78:	56                   	push   %esi
  801a79:	e8 0f f7 ff ff       	call   80118d <fd2data>
  801a7e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	bf 00 00 00 00       	mov    $0x0,%edi
  801a88:	eb 4b                	jmp    801ad5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a8a:	89 da                	mov    %ebx,%edx
  801a8c:	89 f0                	mov    %esi,%eax
  801a8e:	e8 6d ff ff ff       	call   801a00 <_pipeisclosed>
  801a93:	85 c0                	test   %eax,%eax
  801a95:	75 48                	jne    801adf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a97:	e8 85 f0 ff ff       	call   800b21 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9f:	8b 0b                	mov    (%ebx),%ecx
  801aa1:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa4:	39 d0                	cmp    %edx,%eax
  801aa6:	73 e2                	jae    801a8a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aaf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	c1 fa 1f             	sar    $0x1f,%edx
  801ab7:	89 d1                	mov    %edx,%ecx
  801ab9:	c1 e9 1b             	shr    $0x1b,%ecx
  801abc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801abf:	83 e2 1f             	and    $0x1f,%edx
  801ac2:	29 ca                	sub    %ecx,%edx
  801ac4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ac8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801acc:	83 c0 01             	add    $0x1,%eax
  801acf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad2:	83 c7 01             	add    $0x1,%edi
  801ad5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad8:	75 c2                	jne    801a9c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ada:	8b 45 10             	mov    0x10(%ebp),%eax
  801add:	eb 05                	jmp    801ae4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5f                   	pop    %edi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	57                   	push   %edi
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	83 ec 18             	sub    $0x18,%esp
  801af5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801af8:	57                   	push   %edi
  801af9:	e8 8f f6 ff ff       	call   80118d <fd2data>
  801afe:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b08:	eb 3d                	jmp    801b47 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b0a:	85 db                	test   %ebx,%ebx
  801b0c:	74 04                	je     801b12 <devpipe_read+0x26>
				return i;
  801b0e:	89 d8                	mov    %ebx,%eax
  801b10:	eb 44                	jmp    801b56 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b12:	89 f2                	mov    %esi,%edx
  801b14:	89 f8                	mov    %edi,%eax
  801b16:	e8 e5 fe ff ff       	call   801a00 <_pipeisclosed>
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	75 32                	jne    801b51 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b1f:	e8 fd ef ff ff       	call   800b21 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b24:	8b 06                	mov    (%esi),%eax
  801b26:	3b 46 04             	cmp    0x4(%esi),%eax
  801b29:	74 df                	je     801b0a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b2b:	99                   	cltd   
  801b2c:	c1 ea 1b             	shr    $0x1b,%edx
  801b2f:	01 d0                	add    %edx,%eax
  801b31:	83 e0 1f             	and    $0x1f,%eax
  801b34:	29 d0                	sub    %edx,%eax
  801b36:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b41:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b44:	83 c3 01             	add    $0x1,%ebx
  801b47:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b4a:	75 d8                	jne    801b24 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4f:	eb 05                	jmp    801b56 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
  801b63:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b69:	50                   	push   %eax
  801b6a:	e8 35 f6 ff ff       	call   8011a4 <fd_alloc>
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	89 c2                	mov    %eax,%edx
  801b74:	85 c0                	test   %eax,%eax
  801b76:	0f 88 2c 01 00 00    	js     801ca8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	68 07 04 00 00       	push   $0x407
  801b84:	ff 75 f4             	pushl  -0xc(%ebp)
  801b87:	6a 00                	push   $0x0
  801b89:	e8 b2 ef ff ff       	call   800b40 <sys_page_alloc>
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 0d 01 00 00    	js     801ca8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 fd f5 ff ff       	call   8011a4 <fd_alloc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 e2 00 00 00    	js     801c96 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	68 07 04 00 00       	push   $0x407
  801bbc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 7a ef ff ff       	call   800b40 <sys_page_alloc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	0f 88 c3 00 00 00    	js     801c96 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd9:	e8 af f5 ff ff       	call   80118d <fd2data>
  801bde:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 c4 0c             	add    $0xc,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	50                   	push   %eax
  801be9:	6a 00                	push   $0x0
  801beb:	e8 50 ef ff ff       	call   800b40 <sys_page_alloc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 89 00 00 00    	js     801c86 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	ff 75 f0             	pushl  -0x10(%ebp)
  801c03:	e8 85 f5 ff ff       	call   80118d <fd2data>
  801c08:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c0f:	50                   	push   %eax
  801c10:	6a 00                	push   $0x0
  801c12:	56                   	push   %esi
  801c13:	6a 00                	push   $0x0
  801c15:	e8 69 ef ff ff       	call   800b83 <sys_page_map>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	83 c4 20             	add    $0x20,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 55                	js     801c78 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c38:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c41:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c46:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 f4             	pushl  -0xc(%ebp)
  801c53:	e8 25 f5 ff ff       	call   80117d <fd2num>
  801c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5d:	83 c4 04             	add    $0x4,%esp
  801c60:	ff 75 f0             	pushl  -0x10(%ebp)
  801c63:	e8 15 f5 ff ff       	call   80117d <fd2num>
  801c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	ba 00 00 00 00       	mov    $0x0,%edx
  801c76:	eb 30                	jmp    801ca8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	56                   	push   %esi
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 42 ef ff ff       	call   800bc5 <sys_page_unmap>
  801c83:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c86:	83 ec 08             	sub    $0x8,%esp
  801c89:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 32 ef ff ff       	call   800bc5 <sys_page_unmap>
  801c93:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 22 ef ff ff       	call   800bc5 <sys_page_unmap>
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ca8:	89 d0                	mov    %edx,%eax
  801caa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cba:	50                   	push   %eax
  801cbb:	ff 75 08             	pushl  0x8(%ebp)
  801cbe:	e8 30 f5 ff ff       	call   8011f3 <fd_lookup>
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 18                	js     801ce2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd0:	e8 b8 f4 ff ff       	call   80118d <fd2data>
	return _pipeisclosed(fd, p);
  801cd5:	89 c2                	mov    %eax,%edx
  801cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cda:	e8 21 fd ff ff       	call   801a00 <_pipeisclosed>
  801cdf:	83 c4 10             	add    $0x10,%esp
}
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf4:	68 fe 26 80 00       	push   $0x8026fe
  801cf9:	ff 75 0c             	pushl  0xc(%ebp)
  801cfc:	e8 3c ea ff ff       	call   80073d <strcpy>
	return 0;
}
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	57                   	push   %edi
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d14:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d19:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1f:	eb 2d                	jmp    801d4e <devcons_write+0x46>
		m = n - tot;
  801d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d24:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d26:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d29:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d2e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	53                   	push   %ebx
  801d35:	03 45 0c             	add    0xc(%ebp),%eax
  801d38:	50                   	push   %eax
  801d39:	57                   	push   %edi
  801d3a:	e8 90 eb ff ff       	call   8008cf <memmove>
		sys_cputs(buf, m);
  801d3f:	83 c4 08             	add    $0x8,%esp
  801d42:	53                   	push   %ebx
  801d43:	57                   	push   %edi
  801d44:	e8 3b ed ff ff       	call   800a84 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d49:	01 de                	add    %ebx,%esi
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	89 f0                	mov    %esi,%eax
  801d50:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d53:	72 cc                	jb     801d21 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 08             	sub    $0x8,%esp
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6c:	74 2a                	je     801d98 <devcons_read+0x3b>
  801d6e:	eb 05                	jmp    801d75 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d70:	e8 ac ed ff ff       	call   800b21 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d75:	e8 28 ed ff ff       	call   800aa2 <sys_cgetc>
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	74 f2                	je     801d70 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 16                	js     801d98 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d82:	83 f8 04             	cmp    $0x4,%eax
  801d85:	74 0c                	je     801d93 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8a:	88 02                	mov    %al,(%edx)
	return 1;
  801d8c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d91:	eb 05                	jmp    801d98 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da0:	8b 45 08             	mov    0x8(%ebp),%eax
  801da3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da6:	6a 01                	push   $0x1
  801da8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dab:	50                   	push   %eax
  801dac:	e8 d3 ec ff ff       	call   800a84 <sys_cputs>
}
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <getchar>:

int
getchar(void)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbc:	6a 01                	push   $0x1
  801dbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc1:	50                   	push   %eax
  801dc2:	6a 00                	push   $0x0
  801dc4:	e8 90 f6 ff ff       	call   801459 <read>
	if (r < 0)
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	78 0f                	js     801ddf <getchar+0x29>
		return r;
	if (r < 1)
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	7e 06                	jle    801dda <getchar+0x24>
		return -E_EOF;
	return c;
  801dd4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dd8:	eb 05                	jmp    801ddf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dda:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    

00801de1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dea:	50                   	push   %eax
  801deb:	ff 75 08             	pushl  0x8(%ebp)
  801dee:	e8 00 f4 ff ff       	call   8011f3 <fd_lookup>
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 11                	js     801e0b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e03:	39 10                	cmp    %edx,(%eax)
  801e05:	0f 94 c0             	sete   %al
  801e08:	0f b6 c0             	movzbl %al,%eax
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <opencons>:

int
opencons(void)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	e8 88 f3 ff ff       	call   8011a4 <fd_alloc>
  801e1c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 3e                	js     801e63 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e25:	83 ec 04             	sub    $0x4,%esp
  801e28:	68 07 04 00 00       	push   $0x407
  801e2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e30:	6a 00                	push   $0x0
  801e32:	e8 09 ed ff ff       	call   800b40 <sys_page_alloc>
  801e37:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 23                	js     801e63 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e40:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e49:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e55:	83 ec 0c             	sub    $0xc,%esp
  801e58:	50                   	push   %eax
  801e59:	e8 1f f3 ff ff       	call   80117d <fd2num>
  801e5e:	89 c2                	mov    %eax,%edx
  801e60:	83 c4 10             	add    $0x10,%esp
}
  801e63:	89 d0                	mov    %edx,%eax
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e6f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e75:	e8 88 ec ff ff       	call   800b02 <sys_getenvid>
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	ff 75 0c             	pushl  0xc(%ebp)
  801e80:	ff 75 08             	pushl  0x8(%ebp)
  801e83:	56                   	push   %esi
  801e84:	50                   	push   %eax
  801e85:	68 0c 27 80 00       	push   $0x80270c
  801e8a:	e8 29 e3 ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e8f:	83 c4 18             	add    $0x18,%esp
  801e92:	53                   	push   %ebx
  801e93:	ff 75 10             	pushl  0x10(%ebp)
  801e96:	e8 cc e2 ff ff       	call   800167 <vcprintf>
	cprintf("\n");
  801e9b:	c7 04 24 f7 26 80 00 	movl   $0x8026f7,(%esp)
  801ea2:	e8 11 e3 ff ff       	call   8001b8 <cprintf>
  801ea7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eaa:	cc                   	int3   
  801eab:	eb fd                	jmp    801eaa <_panic+0x43>

00801ead <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eba:	75 2a                	jne    801ee6 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ebc:	83 ec 04             	sub    $0x4,%esp
  801ebf:	6a 07                	push   $0x7
  801ec1:	68 00 f0 bf ee       	push   $0xeebff000
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 73 ec ff ff       	call   800b40 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	79 12                	jns    801ee6 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ed4:	50                   	push   %eax
  801ed5:	68 30 27 80 00       	push   $0x802730
  801eda:	6a 23                	push   $0x23
  801edc:	68 34 27 80 00       	push   $0x802734
  801ee1:	e8 81 ff ff ff       	call   801e67 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801eee:	83 ec 08             	sub    $0x8,%esp
  801ef1:	68 18 1f 80 00       	push   $0x801f18
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 8e ed ff ff       	call   800c8b <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	85 c0                	test   %eax,%eax
  801f02:	79 12                	jns    801f16 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f04:	50                   	push   %eax
  801f05:	68 30 27 80 00       	push   $0x802730
  801f0a:	6a 2c                	push   $0x2c
  801f0c:	68 34 27 80 00       	push   $0x802734
  801f11:	e8 51 ff ff ff       	call   801e67 <_panic>
	}
}
  801f16:	c9                   	leave  
  801f17:	c3                   	ret    

00801f18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f18:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f19:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f1e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f20:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f23:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f27:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f2c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f30:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f32:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f35:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f36:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f39:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f3a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f3b:	c3                   	ret    

00801f3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f42:	89 d0                	mov    %edx,%eax
  801f44:	c1 e8 16             	shr    $0x16,%eax
  801f47:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f53:	f6 c1 01             	test   $0x1,%cl
  801f56:	74 1d                	je     801f75 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f58:	c1 ea 0c             	shr    $0xc,%edx
  801f5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f62:	f6 c2 01             	test   $0x1,%dl
  801f65:	74 0e                	je     801f75 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f67:	c1 ea 0c             	shr    $0xc,%edx
  801f6a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f71:	ef 
  801f72:	0f b7 c0             	movzwl %ax,%eax
}
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    
  801f77:	66 90                	xchg   %ax,%ax
  801f79:	66 90                	xchg   %ax,%ax
  801f7b:	66 90                	xchg   %ax,%ax
  801f7d:	66 90                	xchg   %ax,%ax
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
