
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 42 0e 00 00       	call   800e83 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 cf 0a 00 00       	call   800b1e <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 80 24 80 00       	push   $0x802480
  800059:	e8 76 01 00 00       	call   8001d4 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 b6 12 00 00       	call   801322 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 28 12 00 00       	call   8012a7 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 95 0a 00 00       	call   800b1e <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 96 24 80 00       	push   $0x802496
  800091:	e8 3e 01 00 00       	call   8001d4 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 74 12 00 00       	call   801322 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 50 0a 00 00       	call   800b1e <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x30>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 3b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 2a 00 00 00       	call   800127 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80010d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800112:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800114:	e8 05 0a 00 00       	call   800b1e <sys_getenvid>
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	50                   	push   %eax
  80011d:	e8 4b 0c 00 00       	call   800d6d <sys_thread_free>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 65 14 00 00       	call   801597 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 a1 09 00 00       	call   800add <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 2f 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 54 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 d4 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 a4 1f 00 00       	call   8021e0 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 91 20 00 00       	call   802310 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 b3 24 80 00 	movsbl 0x8024b3(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
  8002ab:	eb 22                	jmp    8002cf <getuint+0x38>
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	74 10                	je     8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb 0e                	jmp    8002cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 89 03 00 00    	je     8006b0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	eb 07                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 07             	movzbl (%edi),%eax
  80036d:	0f b6 c8             	movzbl %al,%ecx
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 1a 03 00 00    	ja     800695 <vprintfmt+0x38a>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
  800396:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800399:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a6:	83 fa 09             	cmp    $0x9,%edx
  8003a9:	77 39                	ja     8003e4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ae:	eb e9                	jmp    800399 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c1:	eb 27                	jmp    8003ea <vprintfmt+0xdf>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cd:	0f 49 c8             	cmovns %eax,%ecx
  8003d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	eb 8c                	jmp    800364 <vprintfmt+0x59>
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e2:	eb 80                	jmp    800364 <vprintfmt+0x59>
  8003e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ee:	0f 89 70 ff ff ff    	jns    800364 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800401:	e9 5e ff ff ff       	jmp    800364 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800406:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040c:	e9 53 ff ff ff       	jmp    800364 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 30                	pushl  (%eax)
  800420:	ff d6                	call   *%esi
			break;
  800422:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800428:	e9 04 ff ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 0f             	cmp    $0xf,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x142>
  800442:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 cb 24 80 00       	push   $0x8024cb
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	e8 94 fe ff ff       	call   8002ee <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800460:	e9 cc fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800465:	52                   	push   %edx
  800466:	68 35 29 80 00       	push   $0x802935
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 7c fe ff ff       	call   8002ee <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800478:	e9 b4 fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800488:	85 ff                	test   %edi,%edi
  80048a:	b8 c4 24 80 00       	mov    $0x8024c4,%eax
  80048f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800492:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800496:	0f 8e 94 00 00 00    	jle    800530 <vprintfmt+0x225>
  80049c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a0:	0f 84 98 00 00 00    	je     80053e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ac:	57                   	push   %edi
  8004ad:	e8 86 02 00 00       	call   800738 <strnlen>
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0f                	jmp    8004da <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ed                	jg     8004cb <vprintfmt+0x1c0>
  8004de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	0f 49 c1             	cmovns %ecx,%eax
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	89 cb                	mov    %ecx,%ebx
  8004fb:	eb 4d                	jmp    80054a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800501:	74 1b                	je     80051e <vprintfmt+0x213>
  800503:	0f be c0             	movsbl %al,%eax
  800506:	83 e8 20             	sub    $0x20,%eax
  800509:	83 f8 5e             	cmp    $0x5e,%eax
  80050c:	76 10                	jbe    80051e <vprintfmt+0x213>
					putch('?', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	6a 3f                	push   $0x3f
  800516:	ff 55 08             	call   *0x8(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 0d                	jmp    80052b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	52                   	push   %edx
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 eb 01             	sub    $0x1,%ebx
  80052e:	eb 1a                	jmp    80054a <vprintfmt+0x23f>
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053c:	eb 0c                	jmp    80054a <vprintfmt+0x23f>
  80053e:	89 75 08             	mov    %esi,0x8(%ebp)
  800541:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800547:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054a:	83 c7 01             	add    $0x1,%edi
  80054d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800551:	0f be d0             	movsbl %al,%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	74 23                	je     80057b <vprintfmt+0x270>
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 a1                	js     8004fd <vprintfmt+0x1f2>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 9c                	jns    8004fd <vprintfmt+0x1f2>
  800561:	89 df                	mov    %ebx,%edi
  800563:	8b 75 08             	mov    0x8(%ebp),%esi
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	eb 18                	jmp    800583 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	53                   	push   %ebx
  80056f:	6a 20                	push   $0x20
  800571:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800573:	83 ef 01             	sub    $0x1,%edi
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 08                	jmp    800583 <vprintfmt+0x278>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	85 ff                	test   %edi,%edi
  800585:	7f e4                	jg     80056b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058a:	e9 a2 fd ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058f:	83 fa 01             	cmp    $0x1,%edx
  800592:	7e 16                	jle    8005aa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 08             	lea    0x8(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	eb 32                	jmp    8005dc <vprintfmt+0x2d1>
	else if (lflag)
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	74 18                	je     8005c6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 c1                	mov    %eax,%ecx
  8005be:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c4:	eb 16                	jmp    8005dc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005eb:	79 74                	jns    800661 <vprintfmt+0x356>
				putch('-', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 2d                	push   $0x2d
  8005f3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fb:	f7 d8                	neg    %eax
  8005fd:	83 d2 00             	adc    $0x0,%edx
  800600:	f7 da                	neg    %edx
  800602:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800605:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060a:	eb 55                	jmp    800661 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 83 fc ff ff       	call   800297 <getuint>
			base = 10;
  800614:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800619:	eb 46                	jmp    800661 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 74 fc ff ff       	call   800297 <getuint>
			base = 8;
  800623:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800628:	eb 37                	jmp    800661 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 30                	push   $0x30
  800630:	ff d6                	call   *%esi
			putch('x', putdat);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 78                	push   $0x78
  800638:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800652:	eb 0d                	jmp    800661 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 3b fc ff ff       	call   800297 <getuint>
			base = 16;
  80065c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	51                   	push   %ecx
  80066d:	52                   	push   %edx
  80066e:	50                   	push   %eax
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 70 fb ff ff       	call   8001e8 <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 ae fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	51                   	push   %ecx
  800688:	ff d6                	call   *%esi
			break;
  80068a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800690:	e9 9c fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 25                	push   $0x25
  80069b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 03                	jmp    8006a5 <vprintfmt+0x39a>
  8006a2:	83 ef 01             	sub    $0x1,%edi
  8006a5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a9:	75 f7                	jne    8006a2 <vprintfmt+0x397>
  8006ab:	e9 81 fc ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 18             	sub    $0x18,%esp
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 26                	je     8006ff <vsnprintf+0x47>
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	7e 22                	jle    8006ff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dd:	ff 75 14             	pushl  0x14(%ebp)
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	68 d1 02 80 00       	push   $0x8002d1
  8006ec:	e8 1a fc ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 05                	jmp    800704 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070f:	50                   	push   %eax
  800710:	ff 75 10             	pushl  0x10(%ebp)
  800713:	ff 75 0c             	pushl  0xc(%ebp)
  800716:	ff 75 08             	pushl  0x8(%ebp)
  800719:	e8 9a ff ff ff       	call   8006b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	eb 03                	jmp    800730 <strlen+0x10>
		n++;
  80072d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800734:	75 f7                	jne    80072d <strlen+0xd>
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 03                	jmp    80074b <strnlen+0x13>
		n++;
  800748:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	39 c2                	cmp    %eax,%edx
  80074d:	74 08                	je     800757 <strnlen+0x1f>
  80074f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800753:	75 f3                	jne    800748 <strnlen+0x10>
  800755:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800763:	89 c2                	mov    %eax,%edx
  800765:	83 c2 01             	add    $0x1,%edx
  800768:	83 c1 01             	add    $0x1,%ecx
  80076b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800772:	84 db                	test   %bl,%bl
  800774:	75 ef                	jne    800765 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800776:	5b                   	pop    %ebx
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800780:	53                   	push   %ebx
  800781:	e8 9a ff ff ff       	call   800720 <strlen>
  800786:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	01 d8                	add    %ebx,%eax
  80078e:	50                   	push   %eax
  80078f:	e8 c5 ff ff ff       	call   800759 <strcpy>
	return dst;
}
  800794:	89 d8                	mov    %ebx,%eax
  800796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	89 f3                	mov    %esi,%ebx
  8007a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	eb 0f                	jmp    8007be <strncpy+0x23>
		*dst++ = *src;
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	0f b6 01             	movzbl (%ecx),%eax
  8007b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007be:	39 da                	cmp    %ebx,%edx
  8007c0:	75 ed                	jne    8007af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 21                	je     8007fd <strlcpy+0x35>
  8007dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	eb 09                	jmp    8007ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 09                	je     8007fa <strlcpy+0x32>
  8007f1:	0f b6 19             	movzbl (%ecx),%ebx
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ec                	jne    8007e4 <strlcpy+0x1c>
  8007f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fd:	29 f0                	sub    %esi,%eax
}
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strcmp+0x11>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	84 c0                	test   %al,%al
  800819:	74 04                	je     80081f <strcmp+0x1c>
  80081b:	3a 02                	cmp    (%edx),%al
  80081d:	74 ef                	je     80080e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 c0             	movzbl %al,%eax
  800822:	0f b6 12             	movzbl (%edx),%edx
  800825:	29 d0                	sub    %edx,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 c3                	mov    %eax,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800838:	eb 06                	jmp    800840 <strncmp+0x17>
		n--, p++, q++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 15                	je     800859 <strncmp+0x30>
  800844:	0f b6 08             	movzbl (%eax),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	74 04                	je     80084f <strncmp+0x26>
  80084b:	3a 0a                	cmp    (%edx),%cl
  80084d:	74 eb                	je     80083a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	0f b6 12             	movzbl (%edx),%edx
  800855:	29 d0                	sub    %edx,%eax
  800857:	eb 05                	jmp    80085e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 07                	jmp    800874 <strchr+0x13>
		if (*s == c)
  80086d:	38 ca                	cmp    %cl,%dl
  80086f:	74 0f                	je     800880 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f2                	jne    80086d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088c:	eb 03                	jmp    800891 <strfind+0xf>
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 04                	je     80089c <strfind+0x1a>
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f2                	jne    80088e <strfind+0xc>
			break;
	return (char *) s;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 36                	je     8008e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b4:	75 28                	jne    8008de <memset+0x40>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 23                	jne    8008de <memset+0x40>
		c &= 0xFF;
  8008bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bf:	89 d3                	mov    %edx,%ebx
  8008c1:	c1 e3 08             	shl    $0x8,%ebx
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	c1 e6 18             	shl    $0x18,%esi
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	c1 e0 10             	shl    $0x10,%eax
  8008ce:	09 f0                	or     %esi,%eax
  8008d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	09 d0                	or     %edx,%eax
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	fc                   	cld    
  8008da:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dc:	eb 06                	jmp    8008e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	fc                   	cld    
  8008e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f9:	39 c6                	cmp    %eax,%esi
  8008fb:	73 35                	jae    800932 <memmove+0x47>
  8008fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800900:	39 d0                	cmp    %edx,%eax
  800902:	73 2e                	jae    800932 <memmove+0x47>
		s += n;
		d += n;
  800904:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800907:	89 d6                	mov    %edx,%esi
  800909:	09 fe                	or     %edi,%esi
  80090b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800911:	75 13                	jne    800926 <memmove+0x3b>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 0e                	jne    800926 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800918:	83 ef 04             	sub    $0x4,%edi
  80091b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	fd                   	std    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 09                	jmp    80092f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092c:	fd                   	std    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092f:	fc                   	cld    
  800930:	eb 1d                	jmp    80094f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800932:	89 f2                	mov    %esi,%edx
  800934:	09 c2                	or     %eax,%edx
  800936:	f6 c2 03             	test   $0x3,%dl
  800939:	75 0f                	jne    80094a <memmove+0x5f>
  80093b:	f6 c1 03             	test   $0x3,%cl
  80093e:	75 0a                	jne    80094a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	89 c7                	mov    %eax,%edi
  800945:	fc                   	cld    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 05                	jmp    80094f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800956:	ff 75 10             	pushl  0x10(%ebp)
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	ff 75 08             	pushl  0x8(%ebp)
  80095f:	e8 87 ff ff ff       	call   8008eb <memmove>
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	89 c6                	mov    %eax,%esi
  800973:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	eb 1a                	jmp    800992 <memcmp+0x2c>
		if (*s1 != *s2)
  800978:	0f b6 08             	movzbl (%eax),%ecx
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	38 d9                	cmp    %bl,%cl
  800980:	74 0a                	je     80098c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800982:	0f b6 c1             	movzbl %cl,%eax
  800985:	0f b6 db             	movzbl %bl,%ebx
  800988:	29 d8                	sub    %ebx,%eax
  80098a:	eb 0f                	jmp    80099b <memcmp+0x35>
		s1++, s2++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	39 f0                	cmp    %esi,%eax
  800994:	75 e2                	jne    800978 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a6:	89 c1                	mov    %eax,%ecx
  8009a8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009af:	eb 0a                	jmp    8009bb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	39 da                	cmp    %ebx,%edx
  8009b6:	74 07                	je     8009bf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	39 c8                	cmp    %ecx,%eax
  8009bd:	72 f2                	jb     8009b1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	eb 03                	jmp    8009d3 <strtol+0x11>
		s++;
  8009d0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	3c 20                	cmp    $0x20,%al
  8009d8:	74 f6                	je     8009d0 <strtol+0xe>
  8009da:	3c 09                	cmp    $0x9,%al
  8009dc:	74 f2                	je     8009d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009de:	3c 2b                	cmp    $0x2b,%al
  8009e0:	75 0a                	jne    8009ec <strtol+0x2a>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ea:	eb 11                	jmp    8009fd <strtol+0x3b>
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f1:	3c 2d                	cmp    $0x2d,%al
  8009f3:	75 08                	jne    8009fd <strtol+0x3b>
		s++, neg = 1;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 15                	jne    800a1a <strtol+0x58>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	75 10                	jne    800a1a <strtol+0x58>
  800a0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0e:	75 7c                	jne    800a8c <strtol+0xca>
		s += 2, base = 16;
  800a10:	83 c1 02             	add    $0x2,%ecx
  800a13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a18:	eb 16                	jmp    800a30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	75 12                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 08                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a38:	0f b6 11             	movzbl (%ecx),%edx
  800a3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	80 fb 09             	cmp    $0x9,%bl
  800a43:	77 08                	ja     800a4d <strtol+0x8b>
			dig = *s - '0';
  800a45:	0f be d2             	movsbl %dl,%edx
  800a48:	83 ea 30             	sub    $0x30,%edx
  800a4b:	eb 22                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 19             	cmp    $0x19,%bl
  800a55:	77 08                	ja     800a5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a57:	0f be d2             	movsbl %dl,%edx
  800a5a:	83 ea 57             	sub    $0x57,%edx
  800a5d:	eb 10                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 19             	cmp    $0x19,%bl
  800a67:	77 16                	ja     800a7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a72:	7d 0b                	jge    800a7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7d:	eb b9                	jmp    800a38 <strtol+0x76>

	if (endptr)
  800a7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a83:	74 0d                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	89 0e                	mov    %ecx,(%esi)
  800a8a:	eb 06                	jmp    800a92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 98                	je     800a28 <strtol+0x66>
  800a90:	eb 9e                	jmp    800a30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 03                	push   $0x3
  800b05:	68 bf 27 80 00       	push   $0x8027bf
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 dc 27 80 00       	push   $0x8027dc
  800b11:	e8 b2 15 00 00       	call   8020c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 04                	push   $0x4
  800b86:	68 bf 27 80 00       	push   $0x8027bf
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 dc 27 80 00       	push   $0x8027dc
  800b92:	e8 31 15 00 00       	call   8020c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 05                	push   $0x5
  800bc8:	68 bf 27 80 00       	push   $0x8027bf
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 dc 27 80 00       	push   $0x8027dc
  800bd4:	e8 ef 14 00 00       	call   8020c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 06                	push   $0x6
  800c0a:	68 bf 27 80 00       	push   $0x8027bf
  800c0f:	6a 23                	push   $0x23
  800c11:	68 dc 27 80 00       	push   $0x8027dc
  800c16:	e8 ad 14 00 00       	call   8020c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 08 00 00 00       	mov    $0x8,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 08                	push   $0x8
  800c4c:	68 bf 27 80 00       	push   $0x8027bf
  800c51:	6a 23                	push   $0x23
  800c53:	68 dc 27 80 00       	push   $0x8027dc
  800c58:	e8 6b 14 00 00       	call   8020c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 09 00 00 00       	mov    $0x9,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 09                	push   $0x9
  800c8e:	68 bf 27 80 00       	push   $0x8027bf
  800c93:	6a 23                	push   $0x23
  800c95:	68 dc 27 80 00       	push   $0x8027dc
  800c9a:	e8 29 14 00 00       	call   8020c8 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 0a                	push   $0xa
  800cd0:	68 bf 27 80 00       	push   $0x8027bf
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 dc 27 80 00       	push   $0x8027dc
  800cdc:	e8 e7 13 00 00       	call   8020c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0d                	push   $0xd
  800d34:	68 bf 27 80 00       	push   $0x8027bf
  800d39:	6a 23                	push   $0x23
  800d3b:	68 dc 27 80 00       	push   $0x8027dc
  800d40:	e8 83 13 00 00       	call   8020c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d58:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 cb                	mov    %ecx,%ebx
  800d62:	89 cf                	mov    %ecx,%edi
  800d64:	89 ce                	mov    %ecx,%esi
  800d66:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d78:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 cb                	mov    %ecx,%ebx
  800d82:	89 cf                	mov    %ecx,%edi
  800d84:	89 ce                	mov    %ecx,%esi
  800d86:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d98:	b8 10 00 00 00       	mov    $0x10,%eax
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 cb                	mov    %ecx,%ebx
  800da2:	89 cf                	mov    %ecx,%edi
  800da4:	89 ce                	mov    %ecx,%esi
  800da6:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	53                   	push   %ebx
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800db9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dbd:	74 11                	je     800dd0 <pgfault+0x23>
  800dbf:	89 d8                	mov    %ebx,%eax
  800dc1:	c1 e8 0c             	shr    $0xc,%eax
  800dc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcb:	f6 c4 08             	test   $0x8,%ah
  800dce:	75 14                	jne    800de4 <pgfault+0x37>
		panic("faulting access");
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	68 ea 27 80 00       	push   $0x8027ea
  800dd8:	6a 1f                	push   $0x1f
  800dda:	68 fa 27 80 00       	push   $0x8027fa
  800ddf:	e8 e4 12 00 00       	call   8020c8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	6a 07                	push   $0x7
  800de9:	68 00 f0 7f 00       	push   $0x7ff000
  800dee:	6a 00                	push   $0x0
  800df0:	e8 67 fd ff ff       	call   800b5c <sys_page_alloc>
	if (r < 0) {
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	79 12                	jns    800e0e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dfc:	50                   	push   %eax
  800dfd:	68 05 28 80 00       	push   $0x802805
  800e02:	6a 2d                	push   $0x2d
  800e04:	68 fa 27 80 00       	push   $0x8027fa
  800e09:	e8 ba 12 00 00       	call   8020c8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	68 00 10 00 00       	push   $0x1000
  800e1c:	53                   	push   %ebx
  800e1d:	68 00 f0 7f 00       	push   $0x7ff000
  800e22:	e8 2c fb ff ff       	call   800953 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e27:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e2e:	53                   	push   %ebx
  800e2f:	6a 00                	push   $0x0
  800e31:	68 00 f0 7f 00       	push   $0x7ff000
  800e36:	6a 00                	push   $0x0
  800e38:	e8 62 fd ff ff       	call   800b9f <sys_page_map>
	if (r < 0) {
  800e3d:	83 c4 20             	add    $0x20,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	79 12                	jns    800e56 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e44:	50                   	push   %eax
  800e45:	68 05 28 80 00       	push   $0x802805
  800e4a:	6a 34                	push   $0x34
  800e4c:	68 fa 27 80 00       	push   $0x8027fa
  800e51:	e8 72 12 00 00       	call   8020c8 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	68 00 f0 7f 00       	push   $0x7ff000
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 7c fd ff ff       	call   800be1 <sys_page_unmap>
	if (r < 0) {
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	79 12                	jns    800e7e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e6c:	50                   	push   %eax
  800e6d:	68 05 28 80 00       	push   $0x802805
  800e72:	6a 38                	push   $0x38
  800e74:	68 fa 27 80 00       	push   $0x8027fa
  800e79:	e8 4a 12 00 00       	call   8020c8 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e8c:	68 ad 0d 80 00       	push   $0x800dad
  800e91:	e8 78 12 00 00       	call   80210e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e96:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9b:	cd 30                	int    $0x30
  800e9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	79 17                	jns    800ebe <fork+0x3b>
		panic("fork fault %e");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 1e 28 80 00       	push   $0x80281e
  800eaf:	68 85 00 00 00       	push   $0x85
  800eb4:	68 fa 27 80 00       	push   $0x8027fa
  800eb9:	e8 0a 12 00 00       	call   8020c8 <_panic>
  800ebe:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec4:	75 24                	jne    800eea <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec6:	e8 53 fc ff ff       	call   800b1e <sys_getenvid>
  800ecb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed0:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800ed6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	e9 64 01 00 00       	jmp    80104e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	6a 07                	push   $0x7
  800eef:	68 00 f0 bf ee       	push   $0xeebff000
  800ef4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef7:	e8 60 fc ff ff       	call   800b5c <sys_page_alloc>
  800efc:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f04:	89 d8                	mov    %ebx,%eax
  800f06:	c1 e8 16             	shr    $0x16,%eax
  800f09:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f10:	a8 01                	test   $0x1,%al
  800f12:	0f 84 fc 00 00 00    	je     801014 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	c1 e8 0c             	shr    $0xc,%eax
  800f1d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	0f 84 e7 00 00 00    	je     801014 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f2d:	89 c6                	mov    %eax,%esi
  800f2f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f32:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f39:	f6 c6 04             	test   $0x4,%dh
  800f3c:	74 39                	je     800f77 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4d:	50                   	push   %eax
  800f4e:	56                   	push   %esi
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	6a 00                	push   $0x0
  800f53:	e8 47 fc ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800f58:	83 c4 20             	add    $0x20,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	0f 89 b1 00 00 00    	jns    801014 <fork+0x191>
		    	panic("sys page map fault %e");
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	68 2c 28 80 00       	push   $0x80282c
  800f6b:	6a 55                	push   $0x55
  800f6d:	68 fa 27 80 00       	push   $0x8027fa
  800f72:	e8 51 11 00 00       	call   8020c8 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f77:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7e:	f6 c2 02             	test   $0x2,%dl
  800f81:	75 0c                	jne    800f8f <fork+0x10c>
  800f83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8a:	f6 c4 08             	test   $0x8,%ah
  800f8d:	74 5b                	je     800fea <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	68 05 08 00 00       	push   $0x805
  800f97:	56                   	push   %esi
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 fe fb ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 14                	jns    800fbc <fork+0x139>
		    	panic("sys page map fault %e");
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 2c 28 80 00       	push   $0x80282c
  800fb0:	6a 5c                	push   $0x5c
  800fb2:	68 fa 27 80 00       	push   $0x8027fa
  800fb7:	e8 0c 11 00 00       	call   8020c8 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	68 05 08 00 00       	push   $0x805
  800fc4:	56                   	push   %esi
  800fc5:	6a 00                	push   $0x0
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 d0 fb ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800fcf:	83 c4 20             	add    $0x20,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 3e                	jns    801014 <fork+0x191>
		    	panic("sys page map fault %e");
  800fd6:	83 ec 04             	sub    $0x4,%esp
  800fd9:	68 2c 28 80 00       	push   $0x80282c
  800fde:	6a 60                	push   $0x60
  800fe0:	68 fa 27 80 00       	push   $0x8027fa
  800fe5:	e8 de 10 00 00       	call   8020c8 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	6a 05                	push   $0x5
  800fef:	56                   	push   %esi
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	6a 00                	push   $0x0
  800ff4:	e8 a6 fb ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800ff9:	83 c4 20             	add    $0x20,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	79 14                	jns    801014 <fork+0x191>
		    	panic("sys page map fault %e");
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	68 2c 28 80 00       	push   $0x80282c
  801008:	6a 65                	push   $0x65
  80100a:	68 fa 27 80 00       	push   $0x8027fa
  80100f:	e8 b4 10 00 00       	call   8020c8 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801014:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801020:	0f 85 de fe ff ff    	jne    800f04 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801026:	a1 04 40 80 00       	mov    0x804004,%eax
  80102b:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	50                   	push   %eax
  801035:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801038:	57                   	push   %edi
  801039:	e8 69 fc ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	6a 02                	push   $0x2
  801043:	57                   	push   %edi
  801044:	e8 da fb ff ff       	call   800c23 <sys_env_set_status>
	
	return envid;
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80104e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sfork>:

envid_t
sfork(void)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801059:	b8 00 00 00 00       	mov    $0x0,%eax
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80106e:	68 07 01 80 00       	push   $0x800107
  801073:	e8 d5 fc ff ff       	call   800d4d <sys_thread_create>

	return id;
}
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801080:	ff 75 08             	pushl  0x8(%ebp)
  801083:	e8 e5 fc ff ff       	call   800d6d <sys_thread_free>
}
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	e8 f2 fc ff ff       	call   800d8d <sys_thread_join>
}
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	6a 07                	push   $0x7
  8010b0:	6a 00                	push   $0x0
  8010b2:	56                   	push   %esi
  8010b3:	e8 a4 fa ff ff       	call   800b5c <sys_page_alloc>
	if (r < 0) {
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 15                	jns    8010d4 <queue_append+0x34>
		panic("%e\n", r);
  8010bf:	50                   	push   %eax
  8010c0:	68 72 28 80 00       	push   $0x802872
  8010c5:	68 d5 00 00 00       	push   $0xd5
  8010ca:	68 fa 27 80 00       	push   $0x8027fa
  8010cf:	e8 f4 0f 00 00       	call   8020c8 <_panic>
	}	

	wt->envid = envid;
  8010d4:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8010da:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010dd:	75 13                	jne    8010f2 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8010df:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010e6:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010ed:	00 00 00 
  8010f0:	eb 1b                	jmp    80110d <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8010f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8010f5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8010fc:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801103:	00 00 00 
		queue->last = wt;
  801106:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80110d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 08             	sub    $0x8,%esp
  80111a:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80111d:	8b 02                	mov    (%edx),%eax
  80111f:	85 c0                	test   %eax,%eax
  801121:	75 17                	jne    80113a <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	68 42 28 80 00       	push   $0x802842
  80112b:	68 ec 00 00 00       	push   $0xec
  801130:	68 fa 27 80 00       	push   $0x8027fa
  801135:	e8 8e 0f 00 00       	call   8020c8 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80113a:	8b 48 04             	mov    0x4(%eax),%ecx
  80113d:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80113f:	8b 00                	mov    (%eax),%eax
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	53                   	push   %ebx
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80114d:	b8 01 00 00 00       	mov    $0x1,%eax
  801152:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801155:	85 c0                	test   %eax,%eax
  801157:	74 45                	je     80119e <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801159:	e8 c0 f9 ff ff       	call   800b1e <sys_getenvid>
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	83 c3 04             	add    $0x4,%ebx
  801164:	53                   	push   %ebx
  801165:	50                   	push   %eax
  801166:	e8 35 ff ff ff       	call   8010a0 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80116b:	e8 ae f9 ff ff       	call   800b1e <sys_getenvid>
  801170:	83 c4 08             	add    $0x8,%esp
  801173:	6a 04                	push   $0x4
  801175:	50                   	push   %eax
  801176:	e8 a8 fa ff ff       	call   800c23 <sys_env_set_status>

		if (r < 0) {
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	79 15                	jns    801197 <mutex_lock+0x54>
			panic("%e\n", r);
  801182:	50                   	push   %eax
  801183:	68 72 28 80 00       	push   $0x802872
  801188:	68 02 01 00 00       	push   $0x102
  80118d:	68 fa 27 80 00       	push   $0x8027fa
  801192:	e8 31 0f 00 00       	call   8020c8 <_panic>
		}
		sys_yield();
  801197:	e8 a1 f9 ff ff       	call   800b3d <sys_yield>
  80119c:	eb 08                	jmp    8011a6 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  80119e:	e8 7b f9 ff ff       	call   800b1e <sys_getenvid>
  8011a3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8011a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8011b5:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8011b9:	74 36                	je     8011f1 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	8d 43 04             	lea    0x4(%ebx),%eax
  8011c1:	50                   	push   %eax
  8011c2:	e8 4d ff ff ff       	call   801114 <queue_pop>
  8011c7:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011ca:	83 c4 08             	add    $0x8,%esp
  8011cd:	6a 02                	push   $0x2
  8011cf:	50                   	push   %eax
  8011d0:	e8 4e fa ff ff       	call   800c23 <sys_env_set_status>
		if (r < 0) {
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	79 1d                	jns    8011f9 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8011dc:	50                   	push   %eax
  8011dd:	68 72 28 80 00       	push   $0x802872
  8011e2:	68 16 01 00 00       	push   $0x116
  8011e7:	68 fa 27 80 00       	push   $0x8027fa
  8011ec:	e8 d7 0e 00 00       	call   8020c8 <_panic>
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f6:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8011f9:	e8 3f f9 ff ff       	call   800b3d <sys_yield>
}
  8011fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	53                   	push   %ebx
  801207:	83 ec 04             	sub    $0x4,%esp
  80120a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80120d:	e8 0c f9 ff ff       	call   800b1e <sys_getenvid>
  801212:	83 ec 04             	sub    $0x4,%esp
  801215:	6a 07                	push   $0x7
  801217:	53                   	push   %ebx
  801218:	50                   	push   %eax
  801219:	e8 3e f9 ff ff       	call   800b5c <sys_page_alloc>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	79 15                	jns    80123a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801225:	50                   	push   %eax
  801226:	68 5d 28 80 00       	push   $0x80285d
  80122b:	68 23 01 00 00       	push   $0x123
  801230:	68 fa 27 80 00       	push   $0x8027fa
  801235:	e8 8e 0e 00 00       	call   8020c8 <_panic>
	}	
	mtx->locked = 0;
  80123a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801240:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801247:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80124e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801262:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801265:	eb 20                	jmp    801287 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	56                   	push   %esi
  80126b:	e8 a4 fe ff ff       	call   801114 <queue_pop>
  801270:	83 c4 08             	add    $0x8,%esp
  801273:	6a 02                	push   $0x2
  801275:	50                   	push   %eax
  801276:	e8 a8 f9 ff ff       	call   800c23 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80127b:	8b 43 04             	mov    0x4(%ebx),%eax
  80127e:	8b 40 04             	mov    0x4(%eax),%eax
  801281:	89 43 04             	mov    %eax,0x4(%ebx)
  801284:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801287:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80128b:	75 da                	jne    801267 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	68 00 10 00 00       	push   $0x1000
  801295:	6a 00                	push   $0x0
  801297:	53                   	push   %ebx
  801298:	e8 01 f6 ff ff       	call   80089e <memset>
	mtx = NULL;
}
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8012af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	75 12                	jne    8012cb <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	68 00 00 c0 ee       	push   $0xeec00000
  8012c1:	e8 46 fa ff ff       	call   800d0c <sys_ipc_recv>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	eb 0c                	jmp    8012d7 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	50                   	push   %eax
  8012cf:	e8 38 fa ff ff       	call   800d0c <sys_ipc_recv>
  8012d4:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8012d7:	85 f6                	test   %esi,%esi
  8012d9:	0f 95 c1             	setne  %cl
  8012dc:	85 db                	test   %ebx,%ebx
  8012de:	0f 95 c2             	setne  %dl
  8012e1:	84 d1                	test   %dl,%cl
  8012e3:	74 09                	je     8012ee <ipc_recv+0x47>
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	c1 ea 1f             	shr    $0x1f,%edx
  8012ea:	84 d2                	test   %dl,%dl
  8012ec:	75 2d                	jne    80131b <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8012ee:	85 f6                	test   %esi,%esi
  8012f0:	74 0d                	je     8012ff <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8012f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f7:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8012fd:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8012ff:	85 db                	test   %ebx,%ebx
  801301:	74 0d                	je     801310 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801303:	a1 04 40 80 00       	mov    0x804004,%eax
  801308:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80130e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801310:	a1 04 40 80 00       	mov    0x804004,%eax
  801315:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80131b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80132e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801331:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801334:	85 db                	test   %ebx,%ebx
  801336:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80133b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80133e:	ff 75 14             	pushl  0x14(%ebp)
  801341:	53                   	push   %ebx
  801342:	56                   	push   %esi
  801343:	57                   	push   %edi
  801344:	e8 a0 f9 ff ff       	call   800ce9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801349:	89 c2                	mov    %eax,%edx
  80134b:	c1 ea 1f             	shr    $0x1f,%edx
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	84 d2                	test   %dl,%dl
  801353:	74 17                	je     80136c <ipc_send+0x4a>
  801355:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801358:	74 12                	je     80136c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80135a:	50                   	push   %eax
  80135b:	68 76 28 80 00       	push   $0x802876
  801360:	6a 47                	push   $0x47
  801362:	68 84 28 80 00       	push   $0x802884
  801367:	e8 5c 0d 00 00       	call   8020c8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80136c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80136f:	75 07                	jne    801378 <ipc_send+0x56>
			sys_yield();
  801371:	e8 c7 f7 ff ff       	call   800b3d <sys_yield>
  801376:	eb c6                	jmp    80133e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801378:	85 c0                	test   %eax,%eax
  80137a:	75 c2                	jne    80133e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80137c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137f:	5b                   	pop    %ebx
  801380:	5e                   	pop    %esi
  801381:	5f                   	pop    %edi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80138f:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  801395:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80139b:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8013a1:	39 ca                	cmp    %ecx,%edx
  8013a3:	75 13                	jne    8013b8 <ipc_find_env+0x34>
			return envs[i].env_id;
  8013a5:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8013ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013b0:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013b6:	eb 0f                	jmp    8013c7 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013b8:	83 c0 01             	add    $0x1,%eax
  8013bb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013c0:	75 cd                	jne    80138f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8013d4:	c1 e8 0c             	shr    $0xc,%eax
}
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013e9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	c1 ea 16             	shr    $0x16,%edx
  801400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801407:	f6 c2 01             	test   $0x1,%dl
  80140a:	74 11                	je     80141d <fd_alloc+0x2d>
  80140c:	89 c2                	mov    %eax,%edx
  80140e:	c1 ea 0c             	shr    $0xc,%edx
  801411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801418:	f6 c2 01             	test   $0x1,%dl
  80141b:	75 09                	jne    801426 <fd_alloc+0x36>
			*fd_store = fd;
  80141d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
  801424:	eb 17                	jmp    80143d <fd_alloc+0x4d>
  801426:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80142b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801430:	75 c9                	jne    8013fb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801432:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801438:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801445:	83 f8 1f             	cmp    $0x1f,%eax
  801448:	77 36                	ja     801480 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80144a:	c1 e0 0c             	shl    $0xc,%eax
  80144d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801452:	89 c2                	mov    %eax,%edx
  801454:	c1 ea 16             	shr    $0x16,%edx
  801457:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80145e:	f6 c2 01             	test   $0x1,%dl
  801461:	74 24                	je     801487 <fd_lookup+0x48>
  801463:	89 c2                	mov    %eax,%edx
  801465:	c1 ea 0c             	shr    $0xc,%edx
  801468:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146f:	f6 c2 01             	test   $0x1,%dl
  801472:	74 1a                	je     80148e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801474:	8b 55 0c             	mov    0xc(%ebp),%edx
  801477:	89 02                	mov    %eax,(%edx)
	return 0;
  801479:	b8 00 00 00 00       	mov    $0x0,%eax
  80147e:	eb 13                	jmp    801493 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801480:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801485:	eb 0c                	jmp    801493 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148c:	eb 05                	jmp    801493 <fd_lookup+0x54>
  80148e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149e:	ba 0c 29 80 00       	mov    $0x80290c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014a3:	eb 13                	jmp    8014b8 <dev_lookup+0x23>
  8014a5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014a8:	39 08                	cmp    %ecx,(%eax)
  8014aa:	75 0c                	jne    8014b8 <dev_lookup+0x23>
			*dev = devtab[i];
  8014ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b6:	eb 31                	jmp    8014e9 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014b8:	8b 02                	mov    (%edx),%eax
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	75 e7                	jne    8014a5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014be:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	51                   	push   %ecx
  8014cd:	50                   	push   %eax
  8014ce:	68 90 28 80 00       	push   $0x802890
  8014d3:	e8 fc ec ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8014d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 10             	sub    $0x10,%esp
  8014f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
  801506:	50                   	push   %eax
  801507:	e8 33 ff ff ff       	call   80143f <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 05                	js     801518 <fd_close+0x2d>
	    || fd != fd2)
  801513:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801516:	74 0c                	je     801524 <fd_close+0x39>
		return (must_exist ? r : 0);
  801518:	84 db                	test   %bl,%bl
  80151a:	ba 00 00 00 00       	mov    $0x0,%edx
  80151f:	0f 44 c2             	cmove  %edx,%eax
  801522:	eb 41                	jmp    801565 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	ff 36                	pushl  (%esi)
  80152d:	e8 63 ff ff ff       	call   801495 <dev_lookup>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 1a                	js     801555 <fd_close+0x6a>
		if (dev->dev_close)
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801541:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801546:	85 c0                	test   %eax,%eax
  801548:	74 0b                	je     801555 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	56                   	push   %esi
  80154e:	ff d0                	call   *%eax
  801550:	89 c3                	mov    %eax,%ebx
  801552:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	56                   	push   %esi
  801559:	6a 00                	push   $0x0
  80155b:	e8 81 f6 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	89 d8                	mov    %ebx,%eax
}
  801565:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	ff 75 08             	pushl  0x8(%ebp)
  801579:	e8 c1 fe ff ff       	call   80143f <fd_lookup>
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 10                	js     801595 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	6a 01                	push   $0x1
  80158a:	ff 75 f4             	pushl  -0xc(%ebp)
  80158d:	e8 59 ff ff ff       	call   8014eb <fd_close>
  801592:	83 c4 10             	add    $0x10,%esp
}
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <close_all>:

void
close_all(void)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80159e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	e8 c0 ff ff ff       	call   80156c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ac:	83 c3 01             	add    $0x1,%ebx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	83 fb 20             	cmp    $0x20,%ebx
  8015b5:	75 ec                	jne    8015a3 <close_all+0xc>
		close(i);
}
  8015b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	57                   	push   %edi
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 2c             	sub    $0x2c,%esp
  8015c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 6b fe ff ff       	call   80143f <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	0f 88 c1 00 00 00    	js     8016a0 <dup+0xe4>
		return r;
	close(newfdnum);
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	56                   	push   %esi
  8015e3:	e8 84 ff ff ff       	call   80156c <close>

	newfd = INDEX2FD(newfdnum);
  8015e8:	89 f3                	mov    %esi,%ebx
  8015ea:	c1 e3 0c             	shl    $0xc,%ebx
  8015ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015f3:	83 c4 04             	add    $0x4,%esp
  8015f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f9:	e8 db fd ff ff       	call   8013d9 <fd2data>
  8015fe:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801600:	89 1c 24             	mov    %ebx,(%esp)
  801603:	e8 d1 fd ff ff       	call   8013d9 <fd2data>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80160e:	89 f8                	mov    %edi,%eax
  801610:	c1 e8 16             	shr    $0x16,%eax
  801613:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80161a:	a8 01                	test   $0x1,%al
  80161c:	74 37                	je     801655 <dup+0x99>
  80161e:	89 f8                	mov    %edi,%eax
  801620:	c1 e8 0c             	shr    $0xc,%eax
  801623:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80162a:	f6 c2 01             	test   $0x1,%dl
  80162d:	74 26                	je     801655 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80162f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	25 07 0e 00 00       	and    $0xe07,%eax
  80163e:	50                   	push   %eax
  80163f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801642:	6a 00                	push   $0x0
  801644:	57                   	push   %edi
  801645:	6a 00                	push   $0x0
  801647:	e8 53 f5 ff ff       	call   800b9f <sys_page_map>
  80164c:	89 c7                	mov    %eax,%edi
  80164e:	83 c4 20             	add    $0x20,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	78 2e                	js     801683 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801655:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801658:	89 d0                	mov    %edx,%eax
  80165a:	c1 e8 0c             	shr    $0xc,%eax
  80165d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801664:	83 ec 0c             	sub    $0xc,%esp
  801667:	25 07 0e 00 00       	and    $0xe07,%eax
  80166c:	50                   	push   %eax
  80166d:	53                   	push   %ebx
  80166e:	6a 00                	push   $0x0
  801670:	52                   	push   %edx
  801671:	6a 00                	push   $0x0
  801673:	e8 27 f5 ff ff       	call   800b9f <sys_page_map>
  801678:	89 c7                	mov    %eax,%edi
  80167a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80167d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80167f:	85 ff                	test   %edi,%edi
  801681:	79 1d                	jns    8016a0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	53                   	push   %ebx
  801687:	6a 00                	push   $0x0
  801689:	e8 53 f5 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80168e:	83 c4 08             	add    $0x8,%esp
  801691:	ff 75 d4             	pushl  -0x2c(%ebp)
  801694:	6a 00                	push   $0x0
  801696:	e8 46 f5 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	89 f8                	mov    %edi,%eax
}
  8016a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a3:	5b                   	pop    %ebx
  8016a4:	5e                   	pop    %esi
  8016a5:	5f                   	pop    %edi
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 14             	sub    $0x14,%esp
  8016af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b5:	50                   	push   %eax
  8016b6:	53                   	push   %ebx
  8016b7:	e8 83 fd ff ff       	call   80143f <fd_lookup>
  8016bc:	83 c4 08             	add    $0x8,%esp
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 70                	js     801735 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	ff 30                	pushl  (%eax)
  8016d1:	e8 bf fd ff ff       	call   801495 <dev_lookup>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 4f                	js     80172c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016e0:	8b 42 08             	mov    0x8(%edx),%eax
  8016e3:	83 e0 03             	and    $0x3,%eax
  8016e6:	83 f8 01             	cmp    $0x1,%eax
  8016e9:	75 24                	jne    80170f <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f0:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	53                   	push   %ebx
  8016fa:	50                   	push   %eax
  8016fb:	68 d1 28 80 00       	push   $0x8028d1
  801700:	e8 cf ea ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80170d:	eb 26                	jmp    801735 <read+0x8d>
	}
	if (!dev->dev_read)
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	8b 40 08             	mov    0x8(%eax),%eax
  801715:	85 c0                	test   %eax,%eax
  801717:	74 17                	je     801730 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801719:	83 ec 04             	sub    $0x4,%esp
  80171c:	ff 75 10             	pushl  0x10(%ebp)
  80171f:	ff 75 0c             	pushl  0xc(%ebp)
  801722:	52                   	push   %edx
  801723:	ff d0                	call   *%eax
  801725:	89 c2                	mov    %eax,%edx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	eb 09                	jmp    801735 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	eb 05                	jmp    801735 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801730:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801735:	89 d0                	mov    %edx,%eax
  801737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	57                   	push   %edi
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	8b 7d 08             	mov    0x8(%ebp),%edi
  801748:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801750:	eb 21                	jmp    801773 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801752:	83 ec 04             	sub    $0x4,%esp
  801755:	89 f0                	mov    %esi,%eax
  801757:	29 d8                	sub    %ebx,%eax
  801759:	50                   	push   %eax
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	03 45 0c             	add    0xc(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	57                   	push   %edi
  801761:	e8 42 ff ff ff       	call   8016a8 <read>
		if (m < 0)
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 10                	js     80177d <readn+0x41>
			return m;
		if (m == 0)
  80176d:	85 c0                	test   %eax,%eax
  80176f:	74 0a                	je     80177b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801771:	01 c3                	add    %eax,%ebx
  801773:	39 f3                	cmp    %esi,%ebx
  801775:	72 db                	jb     801752 <readn+0x16>
  801777:	89 d8                	mov    %ebx,%eax
  801779:	eb 02                	jmp    80177d <readn+0x41>
  80177b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80177d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5f                   	pop    %edi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	83 ec 14             	sub    $0x14,%esp
  80178c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801792:	50                   	push   %eax
  801793:	53                   	push   %ebx
  801794:	e8 a6 fc ff ff       	call   80143f <fd_lookup>
  801799:	83 c4 08             	add    $0x8,%esp
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 6b                	js     80180d <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a8:	50                   	push   %eax
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	ff 30                	pushl  (%eax)
  8017ae:	e8 e2 fc ff ff       	call   801495 <dev_lookup>
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 4a                	js     801804 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c1:	75 24                	jne    8017e7 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017ce:	83 ec 04             	sub    $0x4,%esp
  8017d1:	53                   	push   %ebx
  8017d2:	50                   	push   %eax
  8017d3:	68 ed 28 80 00       	push   $0x8028ed
  8017d8:	e8 f7 e9 ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e5:	eb 26                	jmp    80180d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ed:	85 d2                	test   %edx,%edx
  8017ef:	74 17                	je     801808 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017f1:	83 ec 04             	sub    $0x4,%esp
  8017f4:	ff 75 10             	pushl  0x10(%ebp)
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	50                   	push   %eax
  8017fb:	ff d2                	call   *%edx
  8017fd:	89 c2                	mov    %eax,%edx
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	eb 09                	jmp    80180d <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801804:	89 c2                	mov    %eax,%edx
  801806:	eb 05                	jmp    80180d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801808:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80180d:	89 d0                	mov    %edx,%eax
  80180f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <seek>:

int
seek(int fdnum, off_t offset)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	ff 75 08             	pushl  0x8(%ebp)
  801821:	e8 19 fc ff ff       	call   80143f <fd_lookup>
  801826:	83 c4 08             	add    $0x8,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 0e                	js     80183b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80182d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801830:	8b 55 0c             	mov    0xc(%ebp),%edx
  801833:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	53                   	push   %ebx
  801841:	83 ec 14             	sub    $0x14,%esp
  801844:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801847:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	53                   	push   %ebx
  80184c:	e8 ee fb ff ff       	call   80143f <fd_lookup>
  801851:	83 c4 08             	add    $0x8,%esp
  801854:	89 c2                	mov    %eax,%edx
  801856:	85 c0                	test   %eax,%eax
  801858:	78 68                	js     8018c2 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801864:	ff 30                	pushl  (%eax)
  801866:	e8 2a fc ff ff       	call   801495 <dev_lookup>
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 47                	js     8018b9 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801872:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801875:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801879:	75 24                	jne    80189f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80187b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801880:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	53                   	push   %ebx
  80188a:	50                   	push   %eax
  80188b:	68 b0 28 80 00       	push   $0x8028b0
  801890:	e8 3f e9 ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80189d:	eb 23                	jmp    8018c2 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80189f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a2:	8b 52 18             	mov    0x18(%edx),%edx
  8018a5:	85 d2                	test   %edx,%edx
  8018a7:	74 14                	je     8018bd <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	50                   	push   %eax
  8018b0:	ff d2                	call   *%edx
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	eb 09                	jmp    8018c2 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	eb 05                	jmp    8018c2 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018c2:	89 d0                	mov    %edx,%eax
  8018c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 14             	sub    $0x14,%esp
  8018d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d6:	50                   	push   %eax
  8018d7:	ff 75 08             	pushl  0x8(%ebp)
  8018da:	e8 60 fb ff ff       	call   80143f <fd_lookup>
  8018df:	83 c4 08             	add    $0x8,%esp
  8018e2:	89 c2                	mov    %eax,%edx
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 58                	js     801940 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ee:	50                   	push   %eax
  8018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f2:	ff 30                	pushl  (%eax)
  8018f4:	e8 9c fb ff ff       	call   801495 <dev_lookup>
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 37                	js     801937 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801903:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801907:	74 32                	je     80193b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801909:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80190c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801913:	00 00 00 
	stat->st_isdir = 0;
  801916:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80191d:	00 00 00 
	stat->st_dev = dev;
  801920:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	53                   	push   %ebx
  80192a:	ff 75 f0             	pushl  -0x10(%ebp)
  80192d:	ff 50 14             	call   *0x14(%eax)
  801930:	89 c2                	mov    %eax,%edx
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	eb 09                	jmp    801940 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801937:	89 c2                	mov    %eax,%edx
  801939:	eb 05                	jmp    801940 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80193b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801940:	89 d0                	mov    %edx,%eax
  801942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	6a 00                	push   $0x0
  801951:	ff 75 08             	pushl  0x8(%ebp)
  801954:	e8 e3 01 00 00       	call   801b3c <open>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 1b                	js     80197d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801962:	83 ec 08             	sub    $0x8,%esp
  801965:	ff 75 0c             	pushl  0xc(%ebp)
  801968:	50                   	push   %eax
  801969:	e8 5b ff ff ff       	call   8018c9 <fstat>
  80196e:	89 c6                	mov    %eax,%esi
	close(fd);
  801970:	89 1c 24             	mov    %ebx,(%esp)
  801973:	e8 f4 fb ff ff       	call   80156c <close>
	return r;
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	89 f0                	mov    %esi,%eax
}
  80197d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801980:	5b                   	pop    %ebx
  801981:	5e                   	pop    %esi
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	89 c6                	mov    %eax,%esi
  80198b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80198d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801994:	75 12                	jne    8019a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	6a 01                	push   $0x1
  80199b:	e8 e4 f9 ff ff       	call   801384 <ipc_find_env>
  8019a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8019a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019a8:	6a 07                	push   $0x7
  8019aa:	68 00 50 80 00       	push   $0x805000
  8019af:	56                   	push   %esi
  8019b0:	ff 35 00 40 80 00    	pushl  0x804000
  8019b6:	e8 67 f9 ff ff       	call   801322 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019bb:	83 c4 0c             	add    $0xc,%esp
  8019be:	6a 00                	push   $0x0
  8019c0:	53                   	push   %ebx
  8019c1:	6a 00                	push   $0x0
  8019c3:	e8 df f8 ff ff       	call   8012a7 <ipc_recv>
}
  8019c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5e                   	pop    %esi
  8019cd:	5d                   	pop    %ebp
  8019ce:	c3                   	ret    

008019cf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8019f2:	e8 8d ff ff ff       	call   801984 <fsipc>
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801a02:	8b 40 0c             	mov    0xc(%eax),%eax
  801a05:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a14:	e8 6b ff ff ff       	call   801984 <fsipc>
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a25:	8b 45 08             	mov    0x8(%ebp),%eax
  801a28:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
  801a35:	b8 05 00 00 00       	mov    $0x5,%eax
  801a3a:	e8 45 ff ff ff       	call   801984 <fsipc>
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 2c                	js     801a6f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	68 00 50 80 00       	push   $0x805000
  801a4b:	53                   	push   %ebx
  801a4c:	e8 08 ed ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a51:	a1 80 50 80 00       	mov    0x805080,%eax
  801a56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a5c:	a1 84 50 80 00       	mov    0x805084,%eax
  801a61:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a7d:	8b 55 08             	mov    0x8(%ebp),%edx
  801a80:	8b 52 0c             	mov    0xc(%edx),%edx
  801a83:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a89:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a8e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a93:	0f 47 c2             	cmova  %edx,%eax
  801a96:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a9b:	50                   	push   %eax
  801a9c:	ff 75 0c             	pushl  0xc(%ebp)
  801a9f:	68 08 50 80 00       	push   $0x805008
  801aa4:	e8 42 ee ff ff       	call   8008eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aae:	b8 04 00 00 00       	mov    $0x4,%eax
  801ab3:	e8 cc fe ff ff       	call   801984 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801acd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad8:	b8 03 00 00 00       	mov    $0x3,%eax
  801add:	e8 a2 fe ff ff       	call   801984 <fsipc>
  801ae2:	89 c3                	mov    %eax,%ebx
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 4b                	js     801b33 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ae8:	39 c6                	cmp    %eax,%esi
  801aea:	73 16                	jae    801b02 <devfile_read+0x48>
  801aec:	68 1c 29 80 00       	push   $0x80291c
  801af1:	68 23 29 80 00       	push   $0x802923
  801af6:	6a 7c                	push   $0x7c
  801af8:	68 38 29 80 00       	push   $0x802938
  801afd:	e8 c6 05 00 00       	call   8020c8 <_panic>
	assert(r <= PGSIZE);
  801b02:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b07:	7e 16                	jle    801b1f <devfile_read+0x65>
  801b09:	68 43 29 80 00       	push   $0x802943
  801b0e:	68 23 29 80 00       	push   $0x802923
  801b13:	6a 7d                	push   $0x7d
  801b15:	68 38 29 80 00       	push   $0x802938
  801b1a:	e8 a9 05 00 00       	call   8020c8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b1f:	83 ec 04             	sub    $0x4,%esp
  801b22:	50                   	push   %eax
  801b23:	68 00 50 80 00       	push   $0x805000
  801b28:	ff 75 0c             	pushl  0xc(%ebp)
  801b2b:	e8 bb ed ff ff       	call   8008eb <memmove>
	return r;
  801b30:	83 c4 10             	add    $0x10,%esp
}
  801b33:	89 d8                	mov    %ebx,%eax
  801b35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 20             	sub    $0x20,%esp
  801b43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b46:	53                   	push   %ebx
  801b47:	e8 d4 eb ff ff       	call   800720 <strlen>
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b54:	7f 67                	jg     801bbd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	e8 8e f8 ff ff       	call   8013f0 <fd_alloc>
  801b62:	83 c4 10             	add    $0x10,%esp
		return r;
  801b65:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 57                	js     801bc2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	53                   	push   %ebx
  801b6f:	68 00 50 80 00       	push   $0x805000
  801b74:	e8 e0 eb ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b84:	b8 01 00 00 00       	mov    $0x1,%eax
  801b89:	e8 f6 fd ff ff       	call   801984 <fsipc>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	79 14                	jns    801bab <open+0x6f>
		fd_close(fd, 0);
  801b97:	83 ec 08             	sub    $0x8,%esp
  801b9a:	6a 00                	push   $0x0
  801b9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9f:	e8 47 f9 ff ff       	call   8014eb <fd_close>
		return r;
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	89 da                	mov    %ebx,%edx
  801ba9:	eb 17                	jmp    801bc2 <open+0x86>
	}

	return fd2num(fd);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb1:	e8 13 f8 ff ff       	call   8013c9 <fd2num>
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	eb 05                	jmp    801bc2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bbd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bc2:	89 d0                	mov    %edx,%eax
  801bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	b8 08 00 00 00       	mov    $0x8,%eax
  801bd9:	e8 a6 fd ff ff       	call   801984 <fsipc>
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801be8:	83 ec 0c             	sub    $0xc,%esp
  801beb:	ff 75 08             	pushl  0x8(%ebp)
  801bee:	e8 e6 f7 ff ff       	call   8013d9 <fd2data>
  801bf3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bf5:	83 c4 08             	add    $0x8,%esp
  801bf8:	68 4f 29 80 00       	push   $0x80294f
  801bfd:	53                   	push   %ebx
  801bfe:	e8 56 eb ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c03:	8b 46 04             	mov    0x4(%esi),%eax
  801c06:	2b 06                	sub    (%esi),%eax
  801c08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c0e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c15:	00 00 00 
	stat->st_dev = &devpipe;
  801c18:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c1f:	30 80 00 
	return 0;
}
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
  801c27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	53                   	push   %ebx
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c38:	53                   	push   %ebx
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 a1 ef ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c40:	89 1c 24             	mov    %ebx,(%esp)
  801c43:	e8 91 f7 ff ff       	call   8013d9 <fd2data>
  801c48:	83 c4 08             	add    $0x8,%esp
  801c4b:	50                   	push   %eax
  801c4c:	6a 00                	push   $0x0
  801c4e:	e8 8e ef ff ff       	call   800be1 <sys_page_unmap>
}
  801c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	57                   	push   %edi
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 1c             	sub    $0x1c,%esp
  801c61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c64:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c66:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6b:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 e0             	pushl  -0x20(%ebp)
  801c77:	e8 21 05 00 00       	call   80219d <pageref>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	89 3c 24             	mov    %edi,(%esp)
  801c81:	e8 17 05 00 00       	call   80219d <pageref>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	39 c3                	cmp    %eax,%ebx
  801c8b:	0f 94 c1             	sete   %cl
  801c8e:	0f b6 c9             	movzbl %cl,%ecx
  801c91:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c94:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c9a:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801ca0:	39 ce                	cmp    %ecx,%esi
  801ca2:	74 1e                	je     801cc2 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ca4:	39 c3                	cmp    %eax,%ebx
  801ca6:	75 be                	jne    801c66 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca8:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801cae:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cb1:	50                   	push   %eax
  801cb2:	56                   	push   %esi
  801cb3:	68 56 29 80 00       	push   $0x802956
  801cb8:	e8 17 e5 ff ff       	call   8001d4 <cprintf>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	eb a4                	jmp    801c66 <_pipeisclosed+0xe>
	}
}
  801cc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5f                   	pop    %edi
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	57                   	push   %edi
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	83 ec 28             	sub    $0x28,%esp
  801cd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cd9:	56                   	push   %esi
  801cda:	e8 fa f6 ff ff       	call   8013d9 <fd2data>
  801cdf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce9:	eb 4b                	jmp    801d36 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ceb:	89 da                	mov    %ebx,%edx
  801ced:	89 f0                	mov    %esi,%eax
  801cef:	e8 64 ff ff ff       	call   801c58 <_pipeisclosed>
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	75 48                	jne    801d40 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cf8:	e8 40 ee ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cfd:	8b 43 04             	mov    0x4(%ebx),%eax
  801d00:	8b 0b                	mov    (%ebx),%ecx
  801d02:	8d 51 20             	lea    0x20(%ecx),%edx
  801d05:	39 d0                	cmp    %edx,%eax
  801d07:	73 e2                	jae    801ceb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d10:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	c1 fa 1f             	sar    $0x1f,%edx
  801d18:	89 d1                	mov    %edx,%ecx
  801d1a:	c1 e9 1b             	shr    $0x1b,%ecx
  801d1d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d20:	83 e2 1f             	and    $0x1f,%edx
  801d23:	29 ca                	sub    %ecx,%edx
  801d25:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d29:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d2d:	83 c0 01             	add    $0x1,%eax
  801d30:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d33:	83 c7 01             	add    $0x1,%edi
  801d36:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d39:	75 c2                	jne    801cfd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3e:	eb 05                	jmp    801d45 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d40:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5f                   	pop    %edi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	57                   	push   %edi
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	83 ec 18             	sub    $0x18,%esp
  801d56:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d59:	57                   	push   %edi
  801d5a:	e8 7a f6 ff ff       	call   8013d9 <fd2data>
  801d5f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d69:	eb 3d                	jmp    801da8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d6b:	85 db                	test   %ebx,%ebx
  801d6d:	74 04                	je     801d73 <devpipe_read+0x26>
				return i;
  801d6f:	89 d8                	mov    %ebx,%eax
  801d71:	eb 44                	jmp    801db7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	89 f8                	mov    %edi,%eax
  801d77:	e8 dc fe ff ff       	call   801c58 <_pipeisclosed>
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	75 32                	jne    801db2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d80:	e8 b8 ed ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d85:	8b 06                	mov    (%esi),%eax
  801d87:	3b 46 04             	cmp    0x4(%esi),%eax
  801d8a:	74 df                	je     801d6b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d8c:	99                   	cltd   
  801d8d:	c1 ea 1b             	shr    $0x1b,%edx
  801d90:	01 d0                	add    %edx,%eax
  801d92:	83 e0 1f             	and    $0x1f,%eax
  801d95:	29 d0                	sub    %edx,%eax
  801d97:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801da2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da5:	83 c3 01             	add    $0x1,%ebx
  801da8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dab:	75 d8                	jne    801d85 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dad:	8b 45 10             	mov    0x10(%ebp),%eax
  801db0:	eb 05                	jmp    801db7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	e8 20 f6 ff ff       	call   8013f0 <fd_alloc>
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	89 c2                	mov    %eax,%edx
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	0f 88 2c 01 00 00    	js     801f09 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	68 07 04 00 00       	push   $0x407
  801de5:	ff 75 f4             	pushl  -0xc(%ebp)
  801de8:	6a 00                	push   $0x0
  801dea:	e8 6d ed ff ff       	call   800b5c <sys_page_alloc>
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	89 c2                	mov    %eax,%edx
  801df4:	85 c0                	test   %eax,%eax
  801df6:	0f 88 0d 01 00 00    	js     801f09 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e02:	50                   	push   %eax
  801e03:	e8 e8 f5 ff ff       	call   8013f0 <fd_alloc>
  801e08:	89 c3                	mov    %eax,%ebx
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 e2 00 00 00    	js     801ef7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e15:	83 ec 04             	sub    $0x4,%esp
  801e18:	68 07 04 00 00       	push   $0x407
  801e1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e20:	6a 00                	push   $0x0
  801e22:	e8 35 ed ff ff       	call   800b5c <sys_page_alloc>
  801e27:	89 c3                	mov    %eax,%ebx
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 c3 00 00 00    	js     801ef7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3a:	e8 9a f5 ff ff       	call   8013d9 <fd2data>
  801e3f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e41:	83 c4 0c             	add    $0xc,%esp
  801e44:	68 07 04 00 00       	push   $0x407
  801e49:	50                   	push   %eax
  801e4a:	6a 00                	push   $0x0
  801e4c:	e8 0b ed ff ff       	call   800b5c <sys_page_alloc>
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	85 c0                	test   %eax,%eax
  801e58:	0f 88 89 00 00 00    	js     801ee7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5e:	83 ec 0c             	sub    $0xc,%esp
  801e61:	ff 75 f0             	pushl  -0x10(%ebp)
  801e64:	e8 70 f5 ff ff       	call   8013d9 <fd2data>
  801e69:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e70:	50                   	push   %eax
  801e71:	6a 00                	push   $0x0
  801e73:	56                   	push   %esi
  801e74:	6a 00                	push   $0x0
  801e76:	e8 24 ed ff ff       	call   800b9f <sys_page_map>
  801e7b:	89 c3                	mov    %eax,%ebx
  801e7d:	83 c4 20             	add    $0x20,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 55                	js     801ed9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e84:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb4:	e8 10 f5 ff ff       	call   8013c9 <fd2num>
  801eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ebc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ebe:	83 c4 04             	add    $0x4,%esp
  801ec1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec4:	e8 00 f5 ff ff       	call   8013c9 <fd2num>
  801ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ecc:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed7:	eb 30                	jmp    801f09 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ed9:	83 ec 08             	sub    $0x8,%esp
  801edc:	56                   	push   %esi
  801edd:	6a 00                	push   $0x0
  801edf:	e8 fd ec ff ff       	call   800be1 <sys_page_unmap>
  801ee4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ee7:	83 ec 08             	sub    $0x8,%esp
  801eea:	ff 75 f0             	pushl  -0x10(%ebp)
  801eed:	6a 00                	push   $0x0
  801eef:	e8 ed ec ff ff       	call   800be1 <sys_page_unmap>
  801ef4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ef7:	83 ec 08             	sub    $0x8,%esp
  801efa:	ff 75 f4             	pushl  -0xc(%ebp)
  801efd:	6a 00                	push   $0x0
  801eff:	e8 dd ec ff ff       	call   800be1 <sys_page_unmap>
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f09:	89 d0                	mov    %edx,%eax
  801f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	ff 75 08             	pushl  0x8(%ebp)
  801f1f:	e8 1b f5 ff ff       	call   80143f <fd_lookup>
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 18                	js     801f43 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f2b:	83 ec 0c             	sub    $0xc,%esp
  801f2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f31:	e8 a3 f4 ff ff       	call   8013d9 <fd2data>
	return _pipeisclosed(fd, p);
  801f36:	89 c2                	mov    %eax,%edx
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	e8 18 fd ff ff       	call   801c58 <_pipeisclosed>
  801f40:	83 c4 10             	add    $0x10,%esp
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f48:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f55:	68 6e 29 80 00       	push   $0x80296e
  801f5a:	ff 75 0c             	pushl  0xc(%ebp)
  801f5d:	e8 f7 e7 ff ff       	call   800759 <strcpy>
	return 0;
}
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	57                   	push   %edi
  801f6d:	56                   	push   %esi
  801f6e:	53                   	push   %ebx
  801f6f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f75:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f7a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f80:	eb 2d                	jmp    801faf <devcons_write+0x46>
		m = n - tot;
  801f82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f85:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f87:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f8a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f8f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f92:	83 ec 04             	sub    $0x4,%esp
  801f95:	53                   	push   %ebx
  801f96:	03 45 0c             	add    0xc(%ebp),%eax
  801f99:	50                   	push   %eax
  801f9a:	57                   	push   %edi
  801f9b:	e8 4b e9 ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  801fa0:	83 c4 08             	add    $0x8,%esp
  801fa3:	53                   	push   %ebx
  801fa4:	57                   	push   %edi
  801fa5:	e8 f6 ea ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801faa:	01 de                	add    %ebx,%esi
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	89 f0                	mov    %esi,%eax
  801fb1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fb4:	72 cc                	jb     801f82 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb9:	5b                   	pop    %ebx
  801fba:	5e                   	pop    %esi
  801fbb:	5f                   	pop    %edi
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 08             	sub    $0x8,%esp
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fcd:	74 2a                	je     801ff9 <devcons_read+0x3b>
  801fcf:	eb 05                	jmp    801fd6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fd1:	e8 67 eb ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fd6:	e8 e3 ea ff ff       	call   800abe <sys_cgetc>
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	74 f2                	je     801fd1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 16                	js     801ff9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fe3:	83 f8 04             	cmp    $0x4,%eax
  801fe6:	74 0c                	je     801ff4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801feb:	88 02                	mov    %al,(%edx)
	return 1;
  801fed:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff2:	eb 05                	jmp    801ff9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802007:	6a 01                	push   $0x1
  802009:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 8e ea ff ff       	call   800aa0 <sys_cputs>
}
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <getchar>:

int
getchar(void)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80201d:	6a 01                	push   $0x1
  80201f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802022:	50                   	push   %eax
  802023:	6a 00                	push   $0x0
  802025:	e8 7e f6 ff ff       	call   8016a8 <read>
	if (r < 0)
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 0f                	js     802040 <getchar+0x29>
		return r;
	if (r < 1)
  802031:	85 c0                	test   %eax,%eax
  802033:	7e 06                	jle    80203b <getchar+0x24>
		return -E_EOF;
	return c;
  802035:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802039:	eb 05                	jmp    802040 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80203b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204b:	50                   	push   %eax
  80204c:	ff 75 08             	pushl  0x8(%ebp)
  80204f:	e8 eb f3 ff ff       	call   80143f <fd_lookup>
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	78 11                	js     80206c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80205b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802064:	39 10                	cmp    %edx,(%eax)
  802066:	0f 94 c0             	sete   %al
  802069:	0f b6 c0             	movzbl %al,%eax
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <opencons>:

int
opencons(void)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802074:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	e8 73 f3 ff ff       	call   8013f0 <fd_alloc>
  80207d:	83 c4 10             	add    $0x10,%esp
		return r;
  802080:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802082:	85 c0                	test   %eax,%eax
  802084:	78 3e                	js     8020c4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802086:	83 ec 04             	sub    $0x4,%esp
  802089:	68 07 04 00 00       	push   $0x407
  80208e:	ff 75 f4             	pushl  -0xc(%ebp)
  802091:	6a 00                	push   $0x0
  802093:	e8 c4 ea ff ff       	call   800b5c <sys_page_alloc>
  802098:	83 c4 10             	add    $0x10,%esp
		return r;
  80209b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 23                	js     8020c4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	50                   	push   %eax
  8020ba:	e8 0a f3 ff ff       	call   8013c9 <fd2num>
  8020bf:	89 c2                	mov    %eax,%edx
  8020c1:	83 c4 10             	add    $0x10,%esp
}
  8020c4:	89 d0                	mov    %edx,%eax
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    

008020c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8020cd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020d0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020d6:	e8 43 ea ff ff       	call   800b1e <sys_getenvid>
  8020db:	83 ec 0c             	sub    $0xc,%esp
  8020de:	ff 75 0c             	pushl  0xc(%ebp)
  8020e1:	ff 75 08             	pushl  0x8(%ebp)
  8020e4:	56                   	push   %esi
  8020e5:	50                   	push   %eax
  8020e6:	68 7c 29 80 00       	push   $0x80297c
  8020eb:	e8 e4 e0 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020f0:	83 c4 18             	add    $0x18,%esp
  8020f3:	53                   	push   %ebx
  8020f4:	ff 75 10             	pushl  0x10(%ebp)
  8020f7:	e8 87 e0 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  8020fc:	c7 04 24 5b 28 80 00 	movl   $0x80285b,(%esp)
  802103:	e8 cc e0 ff ff       	call   8001d4 <cprintf>
  802108:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80210b:	cc                   	int3   
  80210c:	eb fd                	jmp    80210b <_panic+0x43>

0080210e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802114:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80211b:	75 2a                	jne    802147 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80211d:	83 ec 04             	sub    $0x4,%esp
  802120:	6a 07                	push   $0x7
  802122:	68 00 f0 bf ee       	push   $0xeebff000
  802127:	6a 00                	push   $0x0
  802129:	e8 2e ea ff ff       	call   800b5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	85 c0                	test   %eax,%eax
  802133:	79 12                	jns    802147 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802135:	50                   	push   %eax
  802136:	68 72 28 80 00       	push   $0x802872
  80213b:	6a 23                	push   $0x23
  80213d:	68 a0 29 80 00       	push   $0x8029a0
  802142:	e8 81 ff ff ff       	call   8020c8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802147:	8b 45 08             	mov    0x8(%ebp),%eax
  80214a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80214f:	83 ec 08             	sub    $0x8,%esp
  802152:	68 79 21 80 00       	push   $0x802179
  802157:	6a 00                	push   $0x0
  802159:	e8 49 eb ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	85 c0                	test   %eax,%eax
  802163:	79 12                	jns    802177 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802165:	50                   	push   %eax
  802166:	68 72 28 80 00       	push   $0x802872
  80216b:	6a 2c                	push   $0x2c
  80216d:	68 a0 29 80 00       	push   $0x8029a0
  802172:	e8 51 ff ff ff       	call   8020c8 <_panic>
	}
}
  802177:	c9                   	leave  
  802178:	c3                   	ret    

00802179 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802179:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80217a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80217f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802181:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802184:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802188:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80218d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802191:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802193:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802196:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802197:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80219a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80219b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80219c:	c3                   	ret    

0080219d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219d:	55                   	push   %ebp
  80219e:	89 e5                	mov    %esp,%ebp
  8021a0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a3:	89 d0                	mov    %edx,%eax
  8021a5:	c1 e8 16             	shr    $0x16,%eax
  8021a8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b4:	f6 c1 01             	test   $0x1,%cl
  8021b7:	74 1d                	je     8021d6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b9:	c1 ea 0c             	shr    $0xc,%edx
  8021bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c3:	f6 c2 01             	test   $0x1,%dl
  8021c6:	74 0e                	je     8021d6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c8:	c1 ea 0c             	shr    $0xc,%edx
  8021cb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d2:	ef 
  8021d3:	0f b7 c0             	movzwl %ax,%eax
}
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
