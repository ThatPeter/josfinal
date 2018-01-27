
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
  80003c:	e8 22 0e 00 00       	call   800e63 <fork>
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
  800054:	68 40 22 80 00       	push   $0x802240
  800059:	e8 76 01 00 00       	call   8001d4 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 90 10 00 00       	call   8010fc <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 02 10 00 00       	call   801081 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 95 0a 00 00       	call   800b1e <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 22 80 00       	push   $0x802256
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
  8000a9:	e8 4e 10 00 00       	call   8010fc <ipc_send>
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
  8000d3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80012d:	e8 39 12 00 00       	call   80136b <close_all>
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
  800237:	e8 74 1d 00 00       	call   801fb0 <__udivdi3>
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
  80027a:	e8 61 1e 00 00       	call   8020e0 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 73 22 80 00 	movsbl 0x802273(%eax),%eax
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
  80037e:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  800442:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 8b 22 80 00       	push   $0x80228b
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
  800466:	68 e5 26 80 00       	push   $0x8026e5
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
  80048a:	b8 84 22 80 00       	mov    $0x802284,%eax
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
  800b05:	68 7f 25 80 00       	push   $0x80257f
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 9c 25 80 00       	push   $0x80259c
  800b11:	e8 7d 13 00 00       	call   801e93 <_panic>

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
  800b86:	68 7f 25 80 00       	push   $0x80257f
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 9c 25 80 00       	push   $0x80259c
  800b92:	e8 fc 12 00 00       	call   801e93 <_panic>

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
  800bc8:	68 7f 25 80 00       	push   $0x80257f
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 9c 25 80 00       	push   $0x80259c
  800bd4:	e8 ba 12 00 00       	call   801e93 <_panic>

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
  800c0a:	68 7f 25 80 00       	push   $0x80257f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 9c 25 80 00       	push   $0x80259c
  800c16:	e8 78 12 00 00       	call   801e93 <_panic>

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
  800c4c:	68 7f 25 80 00       	push   $0x80257f
  800c51:	6a 23                	push   $0x23
  800c53:	68 9c 25 80 00       	push   $0x80259c
  800c58:	e8 36 12 00 00       	call   801e93 <_panic>

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
  800c8e:	68 7f 25 80 00       	push   $0x80257f
  800c93:	6a 23                	push   $0x23
  800c95:	68 9c 25 80 00       	push   $0x80259c
  800c9a:	e8 f4 11 00 00       	call   801e93 <_panic>
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
  800cd0:	68 7f 25 80 00       	push   $0x80257f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 9c 25 80 00       	push   $0x80259c
  800cdc:	e8 b2 11 00 00       	call   801e93 <_panic>

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
  800d34:	68 7f 25 80 00       	push   $0x80257f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 9c 25 80 00       	push   $0x80259c
  800d40:	e8 4e 11 00 00       	call   801e93 <_panic>

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

00800d8d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	53                   	push   %ebx
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d97:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d99:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d9d:	74 11                	je     800db0 <pgfault+0x23>
  800d9f:	89 d8                	mov    %ebx,%eax
  800da1:	c1 e8 0c             	shr    $0xc,%eax
  800da4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dab:	f6 c4 08             	test   $0x8,%ah
  800dae:	75 14                	jne    800dc4 <pgfault+0x37>
		panic("faulting access");
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	68 aa 25 80 00       	push   $0x8025aa
  800db8:	6a 1e                	push   $0x1e
  800dba:	68 ba 25 80 00       	push   $0x8025ba
  800dbf:	e8 cf 10 00 00       	call   801e93 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	6a 07                	push   $0x7
  800dc9:	68 00 f0 7f 00       	push   $0x7ff000
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 87 fd ff ff       	call   800b5c <sys_page_alloc>
	if (r < 0) {
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	79 12                	jns    800dee <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ddc:	50                   	push   %eax
  800ddd:	68 c5 25 80 00       	push   $0x8025c5
  800de2:	6a 2c                	push   $0x2c
  800de4:	68 ba 25 80 00       	push   $0x8025ba
  800de9:	e8 a5 10 00 00       	call   801e93 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dee:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	68 00 10 00 00       	push   $0x1000
  800dfc:	53                   	push   %ebx
  800dfd:	68 00 f0 7f 00       	push   $0x7ff000
  800e02:	e8 4c fb ff ff       	call   800953 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e07:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e0e:	53                   	push   %ebx
  800e0f:	6a 00                	push   $0x0
  800e11:	68 00 f0 7f 00       	push   $0x7ff000
  800e16:	6a 00                	push   $0x0
  800e18:	e8 82 fd ff ff       	call   800b9f <sys_page_map>
	if (r < 0) {
  800e1d:	83 c4 20             	add    $0x20,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	79 12                	jns    800e36 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e24:	50                   	push   %eax
  800e25:	68 c5 25 80 00       	push   $0x8025c5
  800e2a:	6a 33                	push   $0x33
  800e2c:	68 ba 25 80 00       	push   $0x8025ba
  800e31:	e8 5d 10 00 00       	call   801e93 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	68 00 f0 7f 00       	push   $0x7ff000
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 9c fd ff ff       	call   800be1 <sys_page_unmap>
	if (r < 0) {
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	79 12                	jns    800e5e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e4c:	50                   	push   %eax
  800e4d:	68 c5 25 80 00       	push   $0x8025c5
  800e52:	6a 37                	push   $0x37
  800e54:	68 ba 25 80 00       	push   $0x8025ba
  800e59:	e8 35 10 00 00       	call   801e93 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    

00800e63 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e6c:	68 8d 0d 80 00       	push   $0x800d8d
  800e71:	e8 63 10 00 00       	call   801ed9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e76:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7b:	cd 30                	int    $0x30
  800e7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	79 17                	jns    800e9e <fork+0x3b>
		panic("fork fault %e");
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	68 de 25 80 00       	push   $0x8025de
  800e8f:	68 84 00 00 00       	push   $0x84
  800e94:	68 ba 25 80 00       	push   $0x8025ba
  800e99:	e8 f5 0f 00 00       	call   801e93 <_panic>
  800e9e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea4:	75 24                	jne    800eca <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea6:	e8 73 fc ff ff       	call   800b1e <sys_getenvid>
  800eab:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800eb6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	e9 64 01 00 00       	jmp    80102e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	6a 07                	push   $0x7
  800ecf:	68 00 f0 bf ee       	push   $0xeebff000
  800ed4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ed7:	e8 80 fc ff ff       	call   800b5c <sys_page_alloc>
  800edc:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee4:	89 d8                	mov    %ebx,%eax
  800ee6:	c1 e8 16             	shr    $0x16,%eax
  800ee9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef0:	a8 01                	test   $0x1,%al
  800ef2:	0f 84 fc 00 00 00    	je     800ff4 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	c1 e8 0c             	shr    $0xc,%eax
  800efd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f04:	f6 c2 01             	test   $0x1,%dl
  800f07:	0f 84 e7 00 00 00    	je     800ff4 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f0d:	89 c6                	mov    %eax,%esi
  800f0f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f12:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f19:	f6 c6 04             	test   $0x4,%dh
  800f1c:	74 39                	je     800f57 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	25 07 0e 00 00       	and    $0xe07,%eax
  800f2d:	50                   	push   %eax
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	6a 00                	push   $0x0
  800f33:	e8 67 fc ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	0f 89 b1 00 00 00    	jns    800ff4 <fork+0x191>
		    	panic("sys page map fault %e");
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 ec 25 80 00       	push   $0x8025ec
  800f4b:	6a 54                	push   $0x54
  800f4d:	68 ba 25 80 00       	push   $0x8025ba
  800f52:	e8 3c 0f 00 00       	call   801e93 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f57:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5e:	f6 c2 02             	test   $0x2,%dl
  800f61:	75 0c                	jne    800f6f <fork+0x10c>
  800f63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6a:	f6 c4 08             	test   $0x8,%ah
  800f6d:	74 5b                	je     800fca <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	68 05 08 00 00       	push   $0x805
  800f77:	56                   	push   %esi
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 1e fc ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 14                	jns    800f9c <fork+0x139>
		    	panic("sys page map fault %e");
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	68 ec 25 80 00       	push   $0x8025ec
  800f90:	6a 5b                	push   $0x5b
  800f92:	68 ba 25 80 00       	push   $0x8025ba
  800f97:	e8 f7 0e 00 00       	call   801e93 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	68 05 08 00 00       	push   $0x805
  800fa4:	56                   	push   %esi
  800fa5:	6a 00                	push   $0x0
  800fa7:	56                   	push   %esi
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 f0 fb ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 3e                	jns    800ff4 <fork+0x191>
		    	panic("sys page map fault %e");
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 ec 25 80 00       	push   $0x8025ec
  800fbe:	6a 5f                	push   $0x5f
  800fc0:	68 ba 25 80 00       	push   $0x8025ba
  800fc5:	e8 c9 0e 00 00       	call   801e93 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	6a 05                	push   $0x5
  800fcf:	56                   	push   %esi
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 c6 fb ff ff       	call   800b9f <sys_page_map>
		if (r < 0) {
  800fd9:	83 c4 20             	add    $0x20,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	79 14                	jns    800ff4 <fork+0x191>
		    	panic("sys page map fault %e");
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 ec 25 80 00       	push   $0x8025ec
  800fe8:	6a 64                	push   $0x64
  800fea:	68 ba 25 80 00       	push   $0x8025ba
  800fef:	e8 9f 0e 00 00       	call   801e93 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801000:	0f 85 de fe ff ff    	jne    800ee4 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801006:	a1 04 40 80 00       	mov    0x804004,%eax
  80100b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	50                   	push   %eax
  801015:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801018:	57                   	push   %edi
  801019:	e8 89 fc ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	6a 02                	push   $0x2
  801023:	57                   	push   %edi
  801024:	e8 fa fb ff ff       	call   800c23 <sys_env_set_status>
	
	return envid;
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80102e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sfork>:

envid_t
sfork(void)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801039:	b8 00 00 00 00       	mov    $0x0,%eax
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	56                   	push   %esi
  801044:	53                   	push   %ebx
  801045:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801048:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	53                   	push   %ebx
  801052:	68 04 26 80 00       	push   $0x802604
  801057:	e8 78 f1 ff ff       	call   8001d4 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80105c:	c7 04 24 07 01 80 00 	movl   $0x800107,(%esp)
  801063:	e8 e5 fc ff ff       	call   800d4d <sys_thread_create>
  801068:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80106a:	83 c4 08             	add    $0x8,%esp
  80106d:	53                   	push   %ebx
  80106e:	68 04 26 80 00       	push   $0x802604
  801073:	e8 5c f1 ff ff       	call   8001d4 <cprintf>
	return id;
}
  801078:	89 f0                	mov    %esi,%eax
  80107a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	8b 75 08             	mov    0x8(%ebp),%esi
  801089:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80108f:	85 c0                	test   %eax,%eax
  801091:	75 12                	jne    8010a5 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	68 00 00 c0 ee       	push   $0xeec00000
  80109b:	e8 6c fc ff ff       	call   800d0c <sys_ipc_recv>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	eb 0c                	jmp    8010b1 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	50                   	push   %eax
  8010a9:	e8 5e fc ff ff       	call   800d0c <sys_ipc_recv>
  8010ae:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8010b1:	85 f6                	test   %esi,%esi
  8010b3:	0f 95 c1             	setne  %cl
  8010b6:	85 db                	test   %ebx,%ebx
  8010b8:	0f 95 c2             	setne  %dl
  8010bb:	84 d1                	test   %dl,%cl
  8010bd:	74 09                	je     8010c8 <ipc_recv+0x47>
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	c1 ea 1f             	shr    $0x1f,%edx
  8010c4:	84 d2                	test   %dl,%dl
  8010c6:	75 2d                	jne    8010f5 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010c8:	85 f6                	test   %esi,%esi
  8010ca:	74 0d                	je     8010d9 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8010cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  8010d7:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8010d9:	85 db                	test   %ebx,%ebx
  8010db:	74 0d                	je     8010ea <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8010dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  8010e8:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  8010f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	8b 7d 08             	mov    0x8(%ebp),%edi
  801108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80110e:	85 db                	test   %ebx,%ebx
  801110:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801115:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801118:	ff 75 14             	pushl  0x14(%ebp)
  80111b:	53                   	push   %ebx
  80111c:	56                   	push   %esi
  80111d:	57                   	push   %edi
  80111e:	e8 c6 fb ff ff       	call   800ce9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 1f             	shr    $0x1f,%edx
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	84 d2                	test   %dl,%dl
  80112d:	74 17                	je     801146 <ipc_send+0x4a>
  80112f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801132:	74 12                	je     801146 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801134:	50                   	push   %eax
  801135:	68 27 26 80 00       	push   $0x802627
  80113a:	6a 47                	push   $0x47
  80113c:	68 35 26 80 00       	push   $0x802635
  801141:	e8 4d 0d 00 00       	call   801e93 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801146:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801149:	75 07                	jne    801152 <ipc_send+0x56>
			sys_yield();
  80114b:	e8 ed f9 ff ff       	call   800b3d <sys_yield>
  801150:	eb c6                	jmp    801118 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801152:	85 c0                	test   %eax,%eax
  801154:	75 c2                	jne    801118 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801169:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  80116f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801175:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80117b:	39 ca                	cmp    %ecx,%edx
  80117d:	75 10                	jne    80118f <ipc_find_env+0x31>
			return envs[i].env_id;
  80117f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801185:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80118a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80118d:	eb 0f                	jmp    80119e <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80118f:	83 c0 01             	add    $0x1,%eax
  801192:	3d 00 04 00 00       	cmp    $0x400,%eax
  801197:	75 d0                	jne    801169 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 16             	shr    $0x16,%edx
  8011d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	74 11                	je     8011f4 <fd_alloc+0x2d>
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	c1 ea 0c             	shr    $0xc,%edx
  8011e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ef:	f6 c2 01             	test   $0x1,%dl
  8011f2:	75 09                	jne    8011fd <fd_alloc+0x36>
			*fd_store = fd;
  8011f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fb:	eb 17                	jmp    801214 <fd_alloc+0x4d>
  8011fd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801202:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801207:	75 c9                	jne    8011d2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801209:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80120f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80121c:	83 f8 1f             	cmp    $0x1f,%eax
  80121f:	77 36                	ja     801257 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801221:	c1 e0 0c             	shl    $0xc,%eax
  801224:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 16             	shr    $0x16,%edx
  80122e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 24                	je     80125e <fd_lookup+0x48>
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	c1 ea 0c             	shr    $0xc,%edx
  80123f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801246:	f6 c2 01             	test   $0x1,%dl
  801249:	74 1a                	je     801265 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	89 02                	mov    %eax,(%edx)
	return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
  801255:	eb 13                	jmp    80126a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801257:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125c:	eb 0c                	jmp    80126a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801263:	eb 05                	jmp    80126a <fd_lookup+0x54>
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801275:	ba bc 26 80 00       	mov    $0x8026bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80127a:	eb 13                	jmp    80128f <dev_lookup+0x23>
  80127c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80127f:	39 08                	cmp    %ecx,(%eax)
  801281:	75 0c                	jne    80128f <dev_lookup+0x23>
			*dev = devtab[i];
  801283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801286:	89 01                	mov    %eax,(%ecx)
			return 0;
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
  80128d:	eb 2e                	jmp    8012bd <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80128f:	8b 02                	mov    (%edx),%eax
  801291:	85 c0                	test   %eax,%eax
  801293:	75 e7                	jne    80127c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801295:	a1 04 40 80 00       	mov    0x804004,%eax
  80129a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80129d:	83 ec 04             	sub    $0x4,%esp
  8012a0:	51                   	push   %ecx
  8012a1:	50                   	push   %eax
  8012a2:	68 40 26 80 00       	push   $0x802640
  8012a7:	e8 28 ef ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8012ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 10             	sub    $0x10,%esp
  8012c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d0:	50                   	push   %eax
  8012d1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d7:	c1 e8 0c             	shr    $0xc,%eax
  8012da:	50                   	push   %eax
  8012db:	e8 36 ff ff ff       	call   801216 <fd_lookup>
  8012e0:	83 c4 08             	add    $0x8,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 05                	js     8012ec <fd_close+0x2d>
	    || fd != fd2)
  8012e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ea:	74 0c                	je     8012f8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ec:	84 db                	test   %bl,%bl
  8012ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f3:	0f 44 c2             	cmove  %edx,%eax
  8012f6:	eb 41                	jmp    801339 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fe:	50                   	push   %eax
  8012ff:	ff 36                	pushl  (%esi)
  801301:	e8 66 ff ff ff       	call   80126c <dev_lookup>
  801306:	89 c3                	mov    %eax,%ebx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 1a                	js     801329 <fd_close+0x6a>
		if (dev->dev_close)
  80130f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801312:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801315:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80131a:	85 c0                	test   %eax,%eax
  80131c:	74 0b                	je     801329 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80131e:	83 ec 0c             	sub    $0xc,%esp
  801321:	56                   	push   %esi
  801322:	ff d0                	call   *%eax
  801324:	89 c3                	mov    %eax,%ebx
  801326:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	56                   	push   %esi
  80132d:	6a 00                	push   $0x0
  80132f:	e8 ad f8 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	89 d8                	mov    %ebx,%eax
}
  801339:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	ff 75 08             	pushl  0x8(%ebp)
  80134d:	e8 c4 fe ff ff       	call   801216 <fd_lookup>
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 10                	js     801369 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	6a 01                	push   $0x1
  80135e:	ff 75 f4             	pushl  -0xc(%ebp)
  801361:	e8 59 ff ff ff       	call   8012bf <fd_close>
  801366:	83 c4 10             	add    $0x10,%esp
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <close_all>:

void
close_all(void)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801377:	83 ec 0c             	sub    $0xc,%esp
  80137a:	53                   	push   %ebx
  80137b:	e8 c0 ff ff ff       	call   801340 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801380:	83 c3 01             	add    $0x1,%ebx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	83 fb 20             	cmp    $0x20,%ebx
  801389:	75 ec                	jne    801377 <close_all+0xc>
		close(i);
}
  80138b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	83 ec 2c             	sub    $0x2c,%esp
  801399:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80139c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	ff 75 08             	pushl  0x8(%ebp)
  8013a3:	e8 6e fe ff ff       	call   801216 <fd_lookup>
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	0f 88 c1 00 00 00    	js     801474 <dup+0xe4>
		return r;
	close(newfdnum);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	56                   	push   %esi
  8013b7:	e8 84 ff ff ff       	call   801340 <close>

	newfd = INDEX2FD(newfdnum);
  8013bc:	89 f3                	mov    %esi,%ebx
  8013be:	c1 e3 0c             	shl    $0xc,%ebx
  8013c1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c7:	83 c4 04             	add    $0x4,%esp
  8013ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013cd:	e8 de fd ff ff       	call   8011b0 <fd2data>
  8013d2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013d4:	89 1c 24             	mov    %ebx,(%esp)
  8013d7:	e8 d4 fd ff ff       	call   8011b0 <fd2data>
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013e2:	89 f8                	mov    %edi,%eax
  8013e4:	c1 e8 16             	shr    $0x16,%eax
  8013e7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ee:	a8 01                	test   $0x1,%al
  8013f0:	74 37                	je     801429 <dup+0x99>
  8013f2:	89 f8                	mov    %edi,%eax
  8013f4:	c1 e8 0c             	shr    $0xc,%eax
  8013f7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	74 26                	je     801429 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801403:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	25 07 0e 00 00       	and    $0xe07,%eax
  801412:	50                   	push   %eax
  801413:	ff 75 d4             	pushl  -0x2c(%ebp)
  801416:	6a 00                	push   $0x0
  801418:	57                   	push   %edi
  801419:	6a 00                	push   $0x0
  80141b:	e8 7f f7 ff ff       	call   800b9f <sys_page_map>
  801420:	89 c7                	mov    %eax,%edi
  801422:	83 c4 20             	add    $0x20,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 2e                	js     801457 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801429:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80142c:	89 d0                	mov    %edx,%eax
  80142e:	c1 e8 0c             	shr    $0xc,%eax
  801431:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	25 07 0e 00 00       	and    $0xe07,%eax
  801440:	50                   	push   %eax
  801441:	53                   	push   %ebx
  801442:	6a 00                	push   $0x0
  801444:	52                   	push   %edx
  801445:	6a 00                	push   $0x0
  801447:	e8 53 f7 ff ff       	call   800b9f <sys_page_map>
  80144c:	89 c7                	mov    %eax,%edi
  80144e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801451:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801453:	85 ff                	test   %edi,%edi
  801455:	79 1d                	jns    801474 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	53                   	push   %ebx
  80145b:	6a 00                	push   $0x0
  80145d:	e8 7f f7 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801462:	83 c4 08             	add    $0x8,%esp
  801465:	ff 75 d4             	pushl  -0x2c(%ebp)
  801468:	6a 00                	push   $0x0
  80146a:	e8 72 f7 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 f8                	mov    %edi,%eax
}
  801474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 14             	sub    $0x14,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	53                   	push   %ebx
  80148b:	e8 86 fd ff ff       	call   801216 <fd_lookup>
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	89 c2                	mov    %eax,%edx
  801495:	85 c0                	test   %eax,%eax
  801497:	78 6d                	js     801506 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a3:	ff 30                	pushl  (%eax)
  8014a5:	e8 c2 fd ff ff       	call   80126c <dev_lookup>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 4c                	js     8014fd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014b4:	8b 42 08             	mov    0x8(%edx),%eax
  8014b7:	83 e0 03             	and    $0x3,%eax
  8014ba:	83 f8 01             	cmp    $0x1,%eax
  8014bd:	75 21                	jne    8014e0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c4:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014c7:	83 ec 04             	sub    $0x4,%esp
  8014ca:	53                   	push   %ebx
  8014cb:	50                   	push   %eax
  8014cc:	68 81 26 80 00       	push   $0x802681
  8014d1:	e8 fe ec ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014de:	eb 26                	jmp    801506 <read+0x8a>
	}
	if (!dev->dev_read)
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e3:	8b 40 08             	mov    0x8(%eax),%eax
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	74 17                	je     801501 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	ff 75 10             	pushl  0x10(%ebp)
  8014f0:	ff 75 0c             	pushl  0xc(%ebp)
  8014f3:	52                   	push   %edx
  8014f4:	ff d0                	call   *%eax
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	eb 09                	jmp    801506 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	eb 05                	jmp    801506 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801501:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801506:	89 d0                	mov    %edx,%eax
  801508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	8b 7d 08             	mov    0x8(%ebp),%edi
  801519:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801521:	eb 21                	jmp    801544 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	89 f0                	mov    %esi,%eax
  801528:	29 d8                	sub    %ebx,%eax
  80152a:	50                   	push   %eax
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	03 45 0c             	add    0xc(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	57                   	push   %edi
  801532:	e8 45 ff ff ff       	call   80147c <read>
		if (m < 0)
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 10                	js     80154e <readn+0x41>
			return m;
		if (m == 0)
  80153e:	85 c0                	test   %eax,%eax
  801540:	74 0a                	je     80154c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801542:	01 c3                	add    %eax,%ebx
  801544:	39 f3                	cmp    %esi,%ebx
  801546:	72 db                	jb     801523 <readn+0x16>
  801548:	89 d8                	mov    %ebx,%eax
  80154a:	eb 02                	jmp    80154e <readn+0x41>
  80154c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80154e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 14             	sub    $0x14,%esp
  80155d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	53                   	push   %ebx
  801565:	e8 ac fc ff ff       	call   801216 <fd_lookup>
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 68                	js     8015db <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157d:	ff 30                	pushl  (%eax)
  80157f:	e8 e8 fc ff ff       	call   80126c <dev_lookup>
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	78 47                	js     8015d2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801592:	75 21                	jne    8015b5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801594:	a1 04 40 80 00       	mov    0x804004,%eax
  801599:	8b 40 7c             	mov    0x7c(%eax),%eax
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	53                   	push   %ebx
  8015a0:	50                   	push   %eax
  8015a1:	68 9d 26 80 00       	push   $0x80269d
  8015a6:	e8 29 ec ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b3:	eb 26                	jmp    8015db <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bb:	85 d2                	test   %edx,%edx
  8015bd:	74 17                	je     8015d6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	ff 75 10             	pushl  0x10(%ebp)
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	50                   	push   %eax
  8015c9:	ff d2                	call   *%edx
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 09                	jmp    8015db <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	eb 05                	jmp    8015db <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 22 fc ff ff       	call   801216 <fd_lookup>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 0e                	js     801609 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801601:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	83 ec 14             	sub    $0x14,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	53                   	push   %ebx
  80161a:	e8 f7 fb ff ff       	call   801216 <fd_lookup>
  80161f:	83 c4 08             	add    $0x8,%esp
  801622:	89 c2                	mov    %eax,%edx
  801624:	85 c0                	test   %eax,%eax
  801626:	78 65                	js     80168d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	ff 30                	pushl  (%eax)
  801634:	e8 33 fc ff ff       	call   80126c <dev_lookup>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 44                	js     801684 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801643:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801647:	75 21                	jne    80166a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801649:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80164e:	8b 40 7c             	mov    0x7c(%eax),%eax
  801651:	83 ec 04             	sub    $0x4,%esp
  801654:	53                   	push   %ebx
  801655:	50                   	push   %eax
  801656:	68 60 26 80 00       	push   $0x802660
  80165b:	e8 74 eb ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801668:	eb 23                	jmp    80168d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166d:	8b 52 18             	mov    0x18(%edx),%edx
  801670:	85 d2                	test   %edx,%edx
  801672:	74 14                	je     801688 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	ff 75 0c             	pushl  0xc(%ebp)
  80167a:	50                   	push   %eax
  80167b:	ff d2                	call   *%edx
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	eb 09                	jmp    80168d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801684:	89 c2                	mov    %eax,%edx
  801686:	eb 05                	jmp    80168d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801688:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80168d:	89 d0                	mov    %edx,%eax
  80168f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	83 ec 14             	sub    $0x14,%esp
  80169b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 08             	pushl  0x8(%ebp)
  8016a5:	e8 6c fb ff ff       	call   801216 <fd_lookup>
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 58                	js     80170b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bd:	ff 30                	pushl  (%eax)
  8016bf:	e8 a8 fb ff ff       	call   80126c <dev_lookup>
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 37                	js     801702 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016d2:	74 32                	je     801706 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016de:	00 00 00 
	stat->st_isdir = 0;
  8016e1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e8:	00 00 00 
	stat->st_dev = dev;
  8016eb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	53                   	push   %ebx
  8016f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f8:	ff 50 14             	call   *0x14(%eax)
  8016fb:	89 c2                	mov    %eax,%edx
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	eb 09                	jmp    80170b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801702:	89 c2                	mov    %eax,%edx
  801704:	eb 05                	jmp    80170b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801706:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80170b:	89 d0                	mov    %edx,%eax
  80170d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	6a 00                	push   $0x0
  80171c:	ff 75 08             	pushl  0x8(%ebp)
  80171f:	e8 e3 01 00 00       	call   801907 <open>
  801724:	89 c3                	mov    %eax,%ebx
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	85 c0                	test   %eax,%eax
  80172b:	78 1b                	js     801748 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	ff 75 0c             	pushl  0xc(%ebp)
  801733:	50                   	push   %eax
  801734:	e8 5b ff ff ff       	call   801694 <fstat>
  801739:	89 c6                	mov    %eax,%esi
	close(fd);
  80173b:	89 1c 24             	mov    %ebx,(%esp)
  80173e:	e8 fd fb ff ff       	call   801340 <close>
	return r;
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	89 f0                	mov    %esi,%eax
}
  801748:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	89 c6                	mov    %eax,%esi
  801756:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801758:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80175f:	75 12                	jne    801773 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801761:	83 ec 0c             	sub    $0xc,%esp
  801764:	6a 01                	push   $0x1
  801766:	e8 f3 f9 ff ff       	call   80115e <ipc_find_env>
  80176b:	a3 00 40 80 00       	mov    %eax,0x804000
  801770:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801773:	6a 07                	push   $0x7
  801775:	68 00 50 80 00       	push   $0x805000
  80177a:	56                   	push   %esi
  80177b:	ff 35 00 40 80 00    	pushl  0x804000
  801781:	e8 76 f9 ff ff       	call   8010fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801786:	83 c4 0c             	add    $0xc,%esp
  801789:	6a 00                	push   $0x0
  80178b:	53                   	push   %ebx
  80178c:	6a 00                	push   $0x0
  80178e:	e8 ee f8 ff ff       	call   801081 <ipc_recv>
}
  801793:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801796:	5b                   	pop    %ebx
  801797:	5e                   	pop    %esi
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ae:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017bd:	e8 8d ff ff ff       	call   80174f <fsipc>
}
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017da:	b8 06 00 00 00       	mov    $0x6,%eax
  8017df:	e8 6b ff ff ff       	call   80174f <fsipc>
}
  8017e4:	c9                   	leave  
  8017e5:	c3                   	ret    

008017e6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	53                   	push   %ebx
  8017ea:	83 ec 04             	sub    $0x4,%esp
  8017ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801800:	b8 05 00 00 00       	mov    $0x5,%eax
  801805:	e8 45 ff ff ff       	call   80174f <fsipc>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 2c                	js     80183a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	68 00 50 80 00       	push   $0x805000
  801816:	53                   	push   %ebx
  801817:	e8 3d ef ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80181c:	a1 80 50 80 00       	mov    0x805080,%eax
  801821:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801827:	a1 84 50 80 00       	mov    0x805084,%eax
  80182c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801848:	8b 55 08             	mov    0x8(%ebp),%edx
  80184b:	8b 52 0c             	mov    0xc(%edx),%edx
  80184e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801854:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801859:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80185e:	0f 47 c2             	cmova  %edx,%eax
  801861:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801866:	50                   	push   %eax
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	68 08 50 80 00       	push   $0x805008
  80186f:	e8 77 f0 ff ff       	call   8008eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 04 00 00 00       	mov    $0x4,%eax
  80187e:	e8 cc fe ff ff       	call   80174f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	56                   	push   %esi
  801889:	53                   	push   %ebx
  80188a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	8b 40 0c             	mov    0xc(%eax),%eax
  801893:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801898:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a8:	e8 a2 fe ff ff       	call   80174f <fsipc>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 4b                	js     8018fe <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018b3:	39 c6                	cmp    %eax,%esi
  8018b5:	73 16                	jae    8018cd <devfile_read+0x48>
  8018b7:	68 cc 26 80 00       	push   $0x8026cc
  8018bc:	68 d3 26 80 00       	push   $0x8026d3
  8018c1:	6a 7c                	push   $0x7c
  8018c3:	68 e8 26 80 00       	push   $0x8026e8
  8018c8:	e8 c6 05 00 00       	call   801e93 <_panic>
	assert(r <= PGSIZE);
  8018cd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d2:	7e 16                	jle    8018ea <devfile_read+0x65>
  8018d4:	68 f3 26 80 00       	push   $0x8026f3
  8018d9:	68 d3 26 80 00       	push   $0x8026d3
  8018de:	6a 7d                	push   $0x7d
  8018e0:	68 e8 26 80 00       	push   $0x8026e8
  8018e5:	e8 a9 05 00 00       	call   801e93 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ea:	83 ec 04             	sub    $0x4,%esp
  8018ed:	50                   	push   %eax
  8018ee:	68 00 50 80 00       	push   $0x805000
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	e8 f0 ef ff ff       	call   8008eb <memmove>
	return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
}
  8018fe:	89 d8                	mov    %ebx,%eax
  801900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	53                   	push   %ebx
  80190b:	83 ec 20             	sub    $0x20,%esp
  80190e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801911:	53                   	push   %ebx
  801912:	e8 09 ee ff ff       	call   800720 <strlen>
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191f:	7f 67                	jg     801988 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	e8 9a f8 ff ff       	call   8011c7 <fd_alloc>
  80192d:	83 c4 10             	add    $0x10,%esp
		return r;
  801930:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801932:	85 c0                	test   %eax,%eax
  801934:	78 57                	js     80198d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801936:	83 ec 08             	sub    $0x8,%esp
  801939:	53                   	push   %ebx
  80193a:	68 00 50 80 00       	push   $0x805000
  80193f:	e8 15 ee ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801944:	8b 45 0c             	mov    0xc(%ebp),%eax
  801947:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80194c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194f:	b8 01 00 00 00       	mov    $0x1,%eax
  801954:	e8 f6 fd ff ff       	call   80174f <fsipc>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	85 c0                	test   %eax,%eax
  801960:	79 14                	jns    801976 <open+0x6f>
		fd_close(fd, 0);
  801962:	83 ec 08             	sub    $0x8,%esp
  801965:	6a 00                	push   $0x0
  801967:	ff 75 f4             	pushl  -0xc(%ebp)
  80196a:	e8 50 f9 ff ff       	call   8012bf <fd_close>
		return r;
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	89 da                	mov    %ebx,%edx
  801974:	eb 17                	jmp    80198d <open+0x86>
	}

	return fd2num(fd);
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	ff 75 f4             	pushl  -0xc(%ebp)
  80197c:	e8 1f f8 ff ff       	call   8011a0 <fd2num>
  801981:	89 c2                	mov    %eax,%edx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	eb 05                	jmp    80198d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801988:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80198d:	89 d0                	mov    %edx,%eax
  80198f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80199a:	ba 00 00 00 00       	mov    $0x0,%edx
  80199f:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a4:	e8 a6 fd ff ff       	call   80174f <fsipc>
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 f2 f7 ff ff       	call   8011b0 <fd2data>
  8019be:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019c0:	83 c4 08             	add    $0x8,%esp
  8019c3:	68 ff 26 80 00       	push   $0x8026ff
  8019c8:	53                   	push   %ebx
  8019c9:	e8 8b ed ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ce:	8b 46 04             	mov    0x4(%esi),%eax
  8019d1:	2b 06                	sub    (%esi),%eax
  8019d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e0:	00 00 00 
	stat->st_dev = &devpipe;
  8019e3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ea:	30 80 00 
	return 0;
}
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a03:	53                   	push   %ebx
  801a04:	6a 00                	push   $0x0
  801a06:	e8 d6 f1 ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a0b:	89 1c 24             	mov    %ebx,(%esp)
  801a0e:	e8 9d f7 ff ff       	call   8011b0 <fd2data>
  801a13:	83 c4 08             	add    $0x8,%esp
  801a16:	50                   	push   %eax
  801a17:	6a 00                	push   $0x0
  801a19:	e8 c3 f1 ff ff       	call   800be1 <sys_page_unmap>
}
  801a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	57                   	push   %edi
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	83 ec 1c             	sub    $0x1c,%esp
  801a2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a2f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a31:	a1 04 40 80 00       	mov    0x804004,%eax
  801a36:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a42:	e8 21 05 00 00       	call   801f68 <pageref>
  801a47:	89 c3                	mov    %eax,%ebx
  801a49:	89 3c 24             	mov    %edi,(%esp)
  801a4c:	e8 17 05 00 00       	call   801f68 <pageref>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	39 c3                	cmp    %eax,%ebx
  801a56:	0f 94 c1             	sete   %cl
  801a59:	0f b6 c9             	movzbl %cl,%ecx
  801a5c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a5f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a65:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801a6b:	39 ce                	cmp    %ecx,%esi
  801a6d:	74 1e                	je     801a8d <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801a6f:	39 c3                	cmp    %eax,%ebx
  801a71:	75 be                	jne    801a31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a73:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801a79:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a7c:	50                   	push   %eax
  801a7d:	56                   	push   %esi
  801a7e:	68 06 27 80 00       	push   $0x802706
  801a83:	e8 4c e7 ff ff       	call   8001d4 <cprintf>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb a4                	jmp    801a31 <_pipeisclosed+0xe>
	}
}
  801a8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 28             	sub    $0x28,%esp
  801aa1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa4:	56                   	push   %esi
  801aa5:	e8 06 f7 ff ff       	call   8011b0 <fd2data>
  801aaa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab4:	eb 4b                	jmp    801b01 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab6:	89 da                	mov    %ebx,%edx
  801ab8:	89 f0                	mov    %esi,%eax
  801aba:	e8 64 ff ff ff       	call   801a23 <_pipeisclosed>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	75 48                	jne    801b0b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac3:	e8 75 f0 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac8:	8b 43 04             	mov    0x4(%ebx),%eax
  801acb:	8b 0b                	mov    (%ebx),%ecx
  801acd:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad0:	39 d0                	cmp    %edx,%eax
  801ad2:	73 e2                	jae    801ab6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801adb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ade:	89 c2                	mov    %eax,%edx
  801ae0:	c1 fa 1f             	sar    $0x1f,%edx
  801ae3:	89 d1                	mov    %edx,%ecx
  801ae5:	c1 e9 1b             	shr    $0x1b,%ecx
  801ae8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aeb:	83 e2 1f             	and    $0x1f,%edx
  801aee:	29 ca                	sub    %ecx,%edx
  801af0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801af4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801af8:	83 c0 01             	add    $0x1,%eax
  801afb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afe:	83 c7 01             	add    $0x1,%edi
  801b01:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b04:	75 c2                	jne    801ac8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b06:	8b 45 10             	mov    0x10(%ebp),%eax
  801b09:	eb 05                	jmp    801b10 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 18             	sub    $0x18,%esp
  801b21:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b24:	57                   	push   %edi
  801b25:	e8 86 f6 ff ff       	call   8011b0 <fd2data>
  801b2a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b34:	eb 3d                	jmp    801b73 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b36:	85 db                	test   %ebx,%ebx
  801b38:	74 04                	je     801b3e <devpipe_read+0x26>
				return i;
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	eb 44                	jmp    801b82 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b3e:	89 f2                	mov    %esi,%edx
  801b40:	89 f8                	mov    %edi,%eax
  801b42:	e8 dc fe ff ff       	call   801a23 <_pipeisclosed>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	75 32                	jne    801b7d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b4b:	e8 ed ef ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b50:	8b 06                	mov    (%esi),%eax
  801b52:	3b 46 04             	cmp    0x4(%esi),%eax
  801b55:	74 df                	je     801b36 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b57:	99                   	cltd   
  801b58:	c1 ea 1b             	shr    $0x1b,%edx
  801b5b:	01 d0                	add    %edx,%eax
  801b5d:	83 e0 1f             	and    $0x1f,%eax
  801b60:	29 d0                	sub    %edx,%eax
  801b62:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b6d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b70:	83 c3 01             	add    $0x1,%ebx
  801b73:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b76:	75 d8                	jne    801b50 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b78:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7b:	eb 05                	jmp    801b82 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	e8 2c f6 ff ff       	call   8011c7 <fd_alloc>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	0f 88 2c 01 00 00    	js     801cd4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba8:	83 ec 04             	sub    $0x4,%esp
  801bab:	68 07 04 00 00       	push   $0x407
  801bb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 a2 ef ff ff       	call   800b5c <sys_page_alloc>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	89 c2                	mov    %eax,%edx
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	0f 88 0d 01 00 00    	js     801cd4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	e8 f4 f5 ff ff       	call   8011c7 <fd_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 e2 00 00 00    	js     801cc2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	ff 75 f0             	pushl  -0x10(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 6a ef ff ff       	call   800b5c <sys_page_alloc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 c3 00 00 00    	js     801cc2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	ff 75 f4             	pushl  -0xc(%ebp)
  801c05:	e8 a6 f5 ff ff       	call   8011b0 <fd2data>
  801c0a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 c4 0c             	add    $0xc,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	50                   	push   %eax
  801c15:	6a 00                	push   $0x0
  801c17:	e8 40 ef ff ff       	call   800b5c <sys_page_alloc>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	0f 88 89 00 00 00    	js     801cb2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2f:	e8 7c f5 ff ff       	call   8011b0 <fd2data>
  801c34:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c3b:	50                   	push   %eax
  801c3c:	6a 00                	push   $0x0
  801c3e:	56                   	push   %esi
  801c3f:	6a 00                	push   $0x0
  801c41:	e8 59 ef ff ff       	call   800b9f <sys_page_map>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	83 c4 20             	add    $0x20,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 55                	js     801ca4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c4f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c72:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7f:	e8 1c f5 ff ff       	call   8011a0 <fd2num>
  801c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c87:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c89:	83 c4 04             	add    $0x4,%esp
  801c8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8f:	e8 0c f5 ff ff       	call   8011a0 <fd2num>
  801c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c97:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca2:	eb 30                	jmp    801cd4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	56                   	push   %esi
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 32 ef ff ff       	call   800be1 <sys_page_unmap>
  801caf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cb2:	83 ec 08             	sub    $0x8,%esp
  801cb5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 22 ef ff ff       	call   800be1 <sys_page_unmap>
  801cbf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 12 ef ff ff       	call   800be1 <sys_page_unmap>
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cd4:	89 d0                	mov    %edx,%eax
  801cd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd9:	5b                   	pop    %ebx
  801cda:	5e                   	pop    %esi
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    

00801cdd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	ff 75 08             	pushl  0x8(%ebp)
  801cea:	e8 27 f5 ff ff       	call   801216 <fd_lookup>
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 18                	js     801d0e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfc:	e8 af f4 ff ff       	call   8011b0 <fd2data>
	return _pipeisclosed(fd, p);
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d06:	e8 18 fd ff ff       	call   801a23 <_pipeisclosed>
  801d0b:	83 c4 10             	add    $0x10,%esp
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d20:	68 1e 27 80 00       	push   $0x80271e
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	e8 2c ea ff ff       	call   800759 <strcpy>
	return 0;
}
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	57                   	push   %edi
  801d38:	56                   	push   %esi
  801d39:	53                   	push   %ebx
  801d3a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d40:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d45:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4b:	eb 2d                	jmp    801d7a <devcons_write+0x46>
		m = n - tot;
  801d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d50:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d52:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d55:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d5a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	53                   	push   %ebx
  801d61:	03 45 0c             	add    0xc(%ebp),%eax
  801d64:	50                   	push   %eax
  801d65:	57                   	push   %edi
  801d66:	e8 80 eb ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  801d6b:	83 c4 08             	add    $0x8,%esp
  801d6e:	53                   	push   %ebx
  801d6f:	57                   	push   %edi
  801d70:	e8 2b ed ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d75:	01 de                	add    %ebx,%esi
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	89 f0                	mov    %esi,%eax
  801d7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d7f:	72 cc                	jb     801d4d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d98:	74 2a                	je     801dc4 <devcons_read+0x3b>
  801d9a:	eb 05                	jmp    801da1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d9c:	e8 9c ed ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801da1:	e8 18 ed ff ff       	call   800abe <sys_cgetc>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	74 f2                	je     801d9c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 16                	js     801dc4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dae:	83 f8 04             	cmp    $0x4,%eax
  801db1:	74 0c                	je     801dbf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801db3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db6:	88 02                	mov    %al,(%edx)
	return 1;
  801db8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbd:	eb 05                	jmp    801dc4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dd2:	6a 01                	push   $0x1
  801dd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd7:	50                   	push   %eax
  801dd8:	e8 c3 ec ff ff       	call   800aa0 <sys_cputs>
}
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <getchar>:

int
getchar(void)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801de8:	6a 01                	push   $0x1
  801dea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	6a 00                	push   $0x0
  801df0:	e8 87 f6 ff ff       	call   80147c <read>
	if (r < 0)
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 0f                	js     801e0b <getchar+0x29>
		return r;
	if (r < 1)
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	7e 06                	jle    801e06 <getchar+0x24>
		return -E_EOF;
	return c;
  801e00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e04:	eb 05                	jmp    801e0b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e06:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	ff 75 08             	pushl  0x8(%ebp)
  801e1a:	e8 f7 f3 ff ff       	call   801216 <fd_lookup>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 11                	js     801e37 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e2f:	39 10                	cmp    %edx,(%eax)
  801e31:	0f 94 c0             	sete   %al
  801e34:	0f b6 c0             	movzbl %al,%eax
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <opencons>:

int
opencons(void)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	e8 7f f3 ff ff       	call   8011c7 <fd_alloc>
  801e48:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 3e                	js     801e8f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e51:	83 ec 04             	sub    $0x4,%esp
  801e54:	68 07 04 00 00       	push   $0x407
  801e59:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 f9 ec ff ff       	call   800b5c <sys_page_alloc>
  801e63:	83 c4 10             	add    $0x10,%esp
		return r;
  801e66:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 23                	js     801e8f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	50                   	push   %eax
  801e85:	e8 16 f3 ff ff       	call   8011a0 <fd2num>
  801e8a:	89 c2                	mov    %eax,%edx
  801e8c:	83 c4 10             	add    $0x10,%esp
}
  801e8f:	89 d0                	mov    %edx,%eax
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e98:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e9b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ea1:	e8 78 ec ff ff       	call   800b1e <sys_getenvid>
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	ff 75 0c             	pushl  0xc(%ebp)
  801eac:	ff 75 08             	pushl  0x8(%ebp)
  801eaf:	56                   	push   %esi
  801eb0:	50                   	push   %eax
  801eb1:	68 2c 27 80 00       	push   $0x80272c
  801eb6:	e8 19 e3 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ebb:	83 c4 18             	add    $0x18,%esp
  801ebe:	53                   	push   %ebx
  801ebf:	ff 75 10             	pushl  0x10(%ebp)
  801ec2:	e8 bc e2 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801ec7:	c7 04 24 17 27 80 00 	movl   $0x802717,(%esp)
  801ece:	e8 01 e3 ff ff       	call   8001d4 <cprintf>
  801ed3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ed6:	cc                   	int3   
  801ed7:	eb fd                	jmp    801ed6 <_panic+0x43>

00801ed9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801edf:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee6:	75 2a                	jne    801f12 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	6a 07                	push   $0x7
  801eed:	68 00 f0 bf ee       	push   $0xeebff000
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 63 ec ff ff       	call   800b5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	79 12                	jns    801f12 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f00:	50                   	push   %eax
  801f01:	68 50 27 80 00       	push   $0x802750
  801f06:	6a 23                	push   $0x23
  801f08:	68 54 27 80 00       	push   $0x802754
  801f0d:	e8 81 ff ff ff       	call   801e93 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f12:	8b 45 08             	mov    0x8(%ebp),%eax
  801f15:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	68 44 1f 80 00       	push   $0x801f44
  801f22:	6a 00                	push   $0x0
  801f24:	e8 7e ed ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	79 12                	jns    801f42 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f30:	50                   	push   %eax
  801f31:	68 50 27 80 00       	push   $0x802750
  801f36:	6a 2c                	push   $0x2c
  801f38:	68 54 27 80 00       	push   $0x802754
  801f3d:	e8 51 ff ff ff       	call   801e93 <_panic>
	}
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f44:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f45:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f4a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f4f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f53:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f58:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f5c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f5e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f61:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f62:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f65:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f66:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f67:	c3                   	ret    

00801f68 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6e:	89 d0                	mov    %edx,%eax
  801f70:	c1 e8 16             	shr    $0x16,%eax
  801f73:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7f:	f6 c1 01             	test   $0x1,%cl
  801f82:	74 1d                	je     801fa1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f84:	c1 ea 0c             	shr    $0xc,%edx
  801f87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f8e:	f6 c2 01             	test   $0x1,%dl
  801f91:	74 0e                	je     801fa1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f93:	c1 ea 0c             	shr    $0xc,%edx
  801f96:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f9d:	ef 
  801f9e:	0f b7 c0             	movzwl %ax,%eax
}
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
  801fa3:	66 90                	xchg   %ax,%ax
  801fa5:	66 90                	xchg   %ax,%ax
  801fa7:	66 90                	xchg   %ax,%ax
  801fa9:	66 90                	xchg   %ax,%ax
  801fab:	66 90                	xchg   %ax,%ax
  801fad:	66 90                	xchg   %ax,%ax
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
