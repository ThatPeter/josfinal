
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
  800054:	68 00 25 80 00       	push   $0x802500
  800059:	e8 76 01 00 00       	call   8001d4 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 38 13 00 00       	call   8013a4 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 aa 12 00 00       	call   801329 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 95 0a 00 00       	call   800b1e <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 16 25 80 00       	push   $0x802516
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
  8000a9:	e8 f6 12 00 00       	call   8013a4 <ipc_send>
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
  8000d3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80012d:	e8 e7 14 00 00       	call   801619 <close_all>
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
  800237:	e8 24 20 00 00       	call   802260 <__udivdi3>
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
  80027a:	e8 11 21 00 00       	call   802390 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 33 25 80 00 	movsbl 0x802533(%eax),%eax
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
  80037e:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
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
  800442:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 4b 25 80 00       	push   $0x80254b
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
  800466:	68 85 2a 80 00       	push   $0x802a85
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
  80048a:	b8 44 25 80 00       	mov    $0x802544,%eax
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
  800b05:	68 3f 28 80 00       	push   $0x80283f
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 5c 28 80 00       	push   $0x80285c
  800b11:	e8 34 16 00 00       	call   80214a <_panic>

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
  800b86:	68 3f 28 80 00       	push   $0x80283f
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 5c 28 80 00       	push   $0x80285c
  800b92:	e8 b3 15 00 00       	call   80214a <_panic>

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
  800bc8:	68 3f 28 80 00       	push   $0x80283f
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 5c 28 80 00       	push   $0x80285c
  800bd4:	e8 71 15 00 00       	call   80214a <_panic>

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
  800c0a:	68 3f 28 80 00       	push   $0x80283f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 5c 28 80 00       	push   $0x80285c
  800c16:	e8 2f 15 00 00       	call   80214a <_panic>

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
  800c4c:	68 3f 28 80 00       	push   $0x80283f
  800c51:	6a 23                	push   $0x23
  800c53:	68 5c 28 80 00       	push   $0x80285c
  800c58:	e8 ed 14 00 00       	call   80214a <_panic>

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
  800c8e:	68 3f 28 80 00       	push   $0x80283f
  800c93:	6a 23                	push   $0x23
  800c95:	68 5c 28 80 00       	push   $0x80285c
  800c9a:	e8 ab 14 00 00       	call   80214a <_panic>
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
  800cd0:	68 3f 28 80 00       	push   $0x80283f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 5c 28 80 00       	push   $0x80285c
  800cdc:	e8 69 14 00 00       	call   80214a <_panic>

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
  800d34:	68 3f 28 80 00       	push   $0x80283f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 5c 28 80 00       	push   $0x80285c
  800d40:	e8 05 14 00 00       	call   80214a <_panic>

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
  800dd3:	68 6a 28 80 00       	push   $0x80286a
  800dd8:	6a 1f                	push   $0x1f
  800dda:	68 7a 28 80 00       	push   $0x80287a
  800ddf:	e8 66 13 00 00       	call   80214a <_panic>
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
  800dfd:	68 85 28 80 00       	push   $0x802885
  800e02:	6a 2d                	push   $0x2d
  800e04:	68 7a 28 80 00       	push   $0x80287a
  800e09:	e8 3c 13 00 00       	call   80214a <_panic>
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
  800e45:	68 85 28 80 00       	push   $0x802885
  800e4a:	6a 34                	push   $0x34
  800e4c:	68 7a 28 80 00       	push   $0x80287a
  800e51:	e8 f4 12 00 00       	call   80214a <_panic>
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
  800e6d:	68 85 28 80 00       	push   $0x802885
  800e72:	6a 38                	push   $0x38
  800e74:	68 7a 28 80 00       	push   $0x80287a
  800e79:	e8 cc 12 00 00       	call   80214a <_panic>
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
  800e91:	e8 fa 12 00 00       	call   802190 <set_pgfault_handler>
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
  800eaa:	68 9e 28 80 00       	push   $0x80289e
  800eaf:	68 85 00 00 00       	push   $0x85
  800eb4:	68 7a 28 80 00       	push   $0x80287a
  800eb9:	e8 8c 12 00 00       	call   80214a <_panic>
  800ebe:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec4:	75 24                	jne    800eea <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec6:	e8 53 fc ff ff       	call   800b1e <sys_getenvid>
  800ecb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed0:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f66:	68 ac 28 80 00       	push   $0x8028ac
  800f6b:	6a 55                	push   $0x55
  800f6d:	68 7a 28 80 00       	push   $0x80287a
  800f72:	e8 d3 11 00 00       	call   80214a <_panic>
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
  800fab:	68 ac 28 80 00       	push   $0x8028ac
  800fb0:	6a 5c                	push   $0x5c
  800fb2:	68 7a 28 80 00       	push   $0x80287a
  800fb7:	e8 8e 11 00 00       	call   80214a <_panic>
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
  800fd9:	68 ac 28 80 00       	push   $0x8028ac
  800fde:	6a 60                	push   $0x60
  800fe0:	68 7a 28 80 00       	push   $0x80287a
  800fe5:	e8 60 11 00 00       	call   80214a <_panic>
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
  801003:	68 ac 28 80 00       	push   $0x8028ac
  801008:	6a 65                	push   $0x65
  80100a:	68 7a 28 80 00       	push   $0x80287a
  80100f:	e8 36 11 00 00       	call   80214a <_panic>
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
  80102b:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801068:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	53                   	push   %ebx
  801072:	68 3c 29 80 00       	push   $0x80293c
  801077:	e8 58 f1 ff ff       	call   8001d4 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80107c:	c7 04 24 07 01 80 00 	movl   $0x800107,(%esp)
  801083:	e8 c5 fc ff ff       	call   800d4d <sys_thread_create>
  801088:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	53                   	push   %ebx
  80108e:	68 3c 29 80 00       	push   $0x80293c
  801093:	e8 3c f1 ff ff       	call   8001d4 <cprintf>
	return id;
}
  801098:	89 f0                	mov    %esi,%eax
  80109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8010a7:	ff 75 08             	pushl  0x8(%ebp)
  8010aa:	e8 be fc ff ff       	call   800d6d <sys_thread_free>
}
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8010ba:	ff 75 08             	pushl  0x8(%ebp)
  8010bd:	e8 cb fc ff ff       	call   800d8d <sys_thread_join>
}
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	56                   	push   %esi
  8010cb:	53                   	push   %ebx
  8010cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	6a 07                	push   $0x7
  8010d7:	6a 00                	push   $0x0
  8010d9:	56                   	push   %esi
  8010da:	e8 7d fa ff ff       	call   800b5c <sys_page_alloc>
	if (r < 0) {
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	79 15                	jns    8010fb <queue_append+0x34>
		panic("%e\n", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 38 29 80 00       	push   $0x802938
  8010ec:	68 c4 00 00 00       	push   $0xc4
  8010f1:	68 7a 28 80 00       	push   $0x80287a
  8010f6:	e8 4f 10 00 00       	call   80214a <_panic>
	}	
	wt->envid = envid;
  8010fb:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	ff 33                	pushl  (%ebx)
  801106:	56                   	push   %esi
  801107:	68 60 29 80 00       	push   $0x802960
  80110c:	e8 c3 f0 ff ff       	call   8001d4 <cprintf>
	if (queue->first == NULL) {
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	83 3b 00             	cmpl   $0x0,(%ebx)
  801117:	75 29                	jne    801142 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	68 c2 28 80 00       	push   $0x8028c2
  801121:	e8 ae f0 ff ff       	call   8001d4 <cprintf>
		queue->first = wt;
  801126:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80112c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801133:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80113a:	00 00 00 
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	eb 2b                	jmp    80116d <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	68 dc 28 80 00       	push   $0x8028dc
  80114a:	e8 85 f0 ff ff       	call   8001d4 <cprintf>
		queue->last->next = wt;
  80114f:	8b 43 04             	mov    0x4(%ebx),%eax
  801152:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801159:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801160:	00 00 00 
		queue->last = wt;
  801163:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80116a:	83 c4 10             	add    $0x10,%esp
	}
}
  80116d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	53                   	push   %ebx
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80117e:	8b 02                	mov    (%edx),%eax
  801180:	85 c0                	test   %eax,%eax
  801182:	75 17                	jne    80119b <queue_pop+0x27>
		panic("queue empty!\n");
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	68 fa 28 80 00       	push   $0x8028fa
  80118c:	68 d8 00 00 00       	push   $0xd8
  801191:	68 7a 28 80 00       	push   $0x80287a
  801196:	e8 af 0f 00 00       	call   80214a <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80119b:	8b 48 04             	mov    0x4(%eax),%ecx
  80119e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8011a0:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	53                   	push   %ebx
  8011a6:	68 08 29 80 00       	push   $0x802908
  8011ab:	e8 24 f0 ff ff       	call   8001d4 <cprintf>
	return envid;
}
  8011b0:	89 d8                	mov    %ebx,%eax
  8011b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8011c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c6:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	74 5a                	je     801227 <mutex_lock+0x70>
  8011cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8011d0:	83 38 00             	cmpl   $0x0,(%eax)
  8011d3:	75 52                	jne    801227 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	68 88 29 80 00       	push   $0x802988
  8011dd:	e8 f2 ef ff ff       	call   8001d4 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8011e2:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8011e5:	e8 34 f9 ff ff       	call   800b1e <sys_getenvid>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	53                   	push   %ebx
  8011ee:	50                   	push   %eax
  8011ef:	e8 d3 fe ff ff       	call   8010c7 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011f4:	e8 25 f9 ff ff       	call   800b1e <sys_getenvid>
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	6a 04                	push   $0x4
  8011fe:	50                   	push   %eax
  8011ff:	e8 1f fa ff ff       	call   800c23 <sys_env_set_status>
		if (r < 0) {
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	79 15                	jns    801220 <mutex_lock+0x69>
			panic("%e\n", r);
  80120b:	50                   	push   %eax
  80120c:	68 38 29 80 00       	push   $0x802938
  801211:	68 eb 00 00 00       	push   $0xeb
  801216:	68 7a 28 80 00       	push   $0x80287a
  80121b:	e8 2a 0f 00 00       	call   80214a <_panic>
		}
		sys_yield();
  801220:	e8 18 f9 ff ff       	call   800b3d <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801225:	eb 18                	jmp    80123f <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801227:	83 ec 0c             	sub    $0xc,%esp
  80122a:	68 a8 29 80 00       	push   $0x8029a8
  80122f:	e8 a0 ef ff ff       	call   8001d4 <cprintf>
	mtx->owner = sys_getenvid();}
  801234:	e8 e5 f8 ff ff       	call   800b1e <sys_getenvid>
  801239:	89 43 08             	mov    %eax,0x8(%ebx)
  80123c:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80124e:	b8 00 00 00 00       	mov    $0x0,%eax
  801253:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801256:	8b 43 04             	mov    0x4(%ebx),%eax
  801259:	83 38 00             	cmpl   $0x0,(%eax)
  80125c:	74 33                	je     801291 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	50                   	push   %eax
  801262:	e8 0d ff ff ff       	call   801174 <queue_pop>
  801267:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80126a:	83 c4 08             	add    $0x8,%esp
  80126d:	6a 02                	push   $0x2
  80126f:	50                   	push   %eax
  801270:	e8 ae f9 ff ff       	call   800c23 <sys_env_set_status>
		if (r < 0) {
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	79 15                	jns    801291 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80127c:	50                   	push   %eax
  80127d:	68 38 29 80 00       	push   $0x802938
  801282:	68 00 01 00 00       	push   $0x100
  801287:	68 7a 28 80 00       	push   $0x80287a
  80128c:	e8 b9 0e 00 00       	call   80214a <_panic>
		}
	}

	asm volatile("pause");
  801291:	f3 90                	pause  
	//sys_yield();
}
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012a2:	e8 77 f8 ff ff       	call   800b1e <sys_getenvid>
  8012a7:	83 ec 04             	sub    $0x4,%esp
  8012aa:	6a 07                	push   $0x7
  8012ac:	53                   	push   %ebx
  8012ad:	50                   	push   %eax
  8012ae:	e8 a9 f8 ff ff       	call   800b5c <sys_page_alloc>
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	79 15                	jns    8012cf <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012ba:	50                   	push   %eax
  8012bb:	68 23 29 80 00       	push   $0x802923
  8012c0:	68 0d 01 00 00       	push   $0x10d
  8012c5:	68 7a 28 80 00       	push   $0x80287a
  8012ca:	e8 7b 0e 00 00       	call   80214a <_panic>
	}	
	mtx->locked = 0;
  8012cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8012d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8012de:	8b 43 04             	mov    0x4(%ebx),%eax
  8012e1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8012e8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8012ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8012fa:	e8 1f f8 ff ff       	call   800b1e <sys_getenvid>
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	50                   	push   %eax
  801306:	e8 d6 f8 ff ff       	call   800be1 <sys_page_unmap>
	if (r < 0) {
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	79 15                	jns    801327 <mutex_destroy+0x33>
		panic("%e\n", r);
  801312:	50                   	push   %eax
  801313:	68 38 29 80 00       	push   $0x802938
  801318:	68 1a 01 00 00       	push   $0x11a
  80131d:	68 7a 28 80 00       	push   $0x80287a
  801322:	e8 23 0e 00 00       	call   80214a <_panic>
	}
}
  801327:	c9                   	leave  
  801328:	c3                   	ret    

00801329 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
  80132e:	8b 75 08             	mov    0x8(%ebp),%esi
  801331:	8b 45 0c             	mov    0xc(%ebp),%eax
  801334:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801337:	85 c0                	test   %eax,%eax
  801339:	75 12                	jne    80134d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	68 00 00 c0 ee       	push   $0xeec00000
  801343:	e8 c4 f9 ff ff       	call   800d0c <sys_ipc_recv>
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	eb 0c                	jmp    801359 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	50                   	push   %eax
  801351:	e8 b6 f9 ff ff       	call   800d0c <sys_ipc_recv>
  801356:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801359:	85 f6                	test   %esi,%esi
  80135b:	0f 95 c1             	setne  %cl
  80135e:	85 db                	test   %ebx,%ebx
  801360:	0f 95 c2             	setne  %dl
  801363:	84 d1                	test   %dl,%cl
  801365:	74 09                	je     801370 <ipc_recv+0x47>
  801367:	89 c2                	mov    %eax,%edx
  801369:	c1 ea 1f             	shr    $0x1f,%edx
  80136c:	84 d2                	test   %dl,%dl
  80136e:	75 2d                	jne    80139d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801370:	85 f6                	test   %esi,%esi
  801372:	74 0d                	je     801381 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801374:	a1 04 40 80 00       	mov    0x804004,%eax
  801379:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80137f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801381:	85 db                	test   %ebx,%ebx
  801383:	74 0d                	je     801392 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801385:	a1 04 40 80 00       	mov    0x804004,%eax
  80138a:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801390:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801392:	a1 04 40 80 00       	mov    0x804004,%eax
  801397:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80139d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	57                   	push   %edi
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8013b6:	85 db                	test   %ebx,%ebx
  8013b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013bd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8013c0:	ff 75 14             	pushl  0x14(%ebp)
  8013c3:	53                   	push   %ebx
  8013c4:	56                   	push   %esi
  8013c5:	57                   	push   %edi
  8013c6:	e8 1e f9 ff ff       	call   800ce9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8013cb:	89 c2                	mov    %eax,%edx
  8013cd:	c1 ea 1f             	shr    $0x1f,%edx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	84 d2                	test   %dl,%dl
  8013d5:	74 17                	je     8013ee <ipc_send+0x4a>
  8013d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013da:	74 12                	je     8013ee <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8013dc:	50                   	push   %eax
  8013dd:	68 c8 29 80 00       	push   $0x8029c8
  8013e2:	6a 47                	push   $0x47
  8013e4:	68 d6 29 80 00       	push   $0x8029d6
  8013e9:	e8 5c 0d 00 00       	call   80214a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8013ee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013f1:	75 07                	jne    8013fa <ipc_send+0x56>
			sys_yield();
  8013f3:	e8 45 f7 ff ff       	call   800b3d <sys_yield>
  8013f8:	eb c6                	jmp    8013c0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	75 c2                	jne    8013c0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8013fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801411:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801417:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80141d:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801423:	39 ca                	cmp    %ecx,%edx
  801425:	75 13                	jne    80143a <ipc_find_env+0x34>
			return envs[i].env_id;
  801427:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80142d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801432:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801438:	eb 0f                	jmp    801449 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80143a:	83 c0 01             	add    $0x1,%eax
  80143d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801442:	75 cd                	jne    801411 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	05 00 00 00 30       	add    $0x30000000,%eax
  801456:	c1 e8 0c             	shr    $0xc,%eax
}
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
  801461:	05 00 00 00 30       	add    $0x30000000,%eax
  801466:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80146b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801478:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80147d:	89 c2                	mov    %eax,%edx
  80147f:	c1 ea 16             	shr    $0x16,%edx
  801482:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801489:	f6 c2 01             	test   $0x1,%dl
  80148c:	74 11                	je     80149f <fd_alloc+0x2d>
  80148e:	89 c2                	mov    %eax,%edx
  801490:	c1 ea 0c             	shr    $0xc,%edx
  801493:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80149a:	f6 c2 01             	test   $0x1,%dl
  80149d:	75 09                	jne    8014a8 <fd_alloc+0x36>
			*fd_store = fd;
  80149f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a6:	eb 17                	jmp    8014bf <fd_alloc+0x4d>
  8014a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014b2:	75 c9                	jne    80147d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014c7:	83 f8 1f             	cmp    $0x1f,%eax
  8014ca:	77 36                	ja     801502 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014cc:	c1 e0 0c             	shl    $0xc,%eax
  8014cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	c1 ea 16             	shr    $0x16,%edx
  8014d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e0:	f6 c2 01             	test   $0x1,%dl
  8014e3:	74 24                	je     801509 <fd_lookup+0x48>
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	c1 ea 0c             	shr    $0xc,%edx
  8014ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f1:	f6 c2 01             	test   $0x1,%dl
  8014f4:	74 1a                	je     801510 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801500:	eb 13                	jmp    801515 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801502:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801507:	eb 0c                	jmp    801515 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801509:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150e:	eb 05                	jmp    801515 <fd_lookup+0x54>
  801510:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801520:	ba 5c 2a 80 00       	mov    $0x802a5c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801525:	eb 13                	jmp    80153a <dev_lookup+0x23>
  801527:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80152a:	39 08                	cmp    %ecx,(%eax)
  80152c:	75 0c                	jne    80153a <dev_lookup+0x23>
			*dev = devtab[i];
  80152e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801531:	89 01                	mov    %eax,(%ecx)
			return 0;
  801533:	b8 00 00 00 00       	mov    $0x0,%eax
  801538:	eb 31                	jmp    80156b <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80153a:	8b 02                	mov    (%edx),%eax
  80153c:	85 c0                	test   %eax,%eax
  80153e:	75 e7                	jne    801527 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801540:	a1 04 40 80 00       	mov    0x804004,%eax
  801545:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	51                   	push   %ecx
  80154f:	50                   	push   %eax
  801550:	68 e0 29 80 00       	push   $0x8029e0
  801555:	e8 7a ec ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  80155a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
  801572:	83 ec 10             	sub    $0x10,%esp
  801575:	8b 75 08             	mov    0x8(%ebp),%esi
  801578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801585:	c1 e8 0c             	shr    $0xc,%eax
  801588:	50                   	push   %eax
  801589:	e8 33 ff ff ff       	call   8014c1 <fd_lookup>
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 05                	js     80159a <fd_close+0x2d>
	    || fd != fd2)
  801595:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801598:	74 0c                	je     8015a6 <fd_close+0x39>
		return (must_exist ? r : 0);
  80159a:	84 db                	test   %bl,%bl
  80159c:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a1:	0f 44 c2             	cmove  %edx,%eax
  8015a4:	eb 41                	jmp    8015e7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	ff 36                	pushl  (%esi)
  8015af:	e8 63 ff ff ff       	call   801517 <dev_lookup>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 1a                	js     8015d7 <fd_close+0x6a>
		if (dev->dev_close)
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	74 0b                	je     8015d7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	56                   	push   %esi
  8015d0:	ff d0                	call   *%eax
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	56                   	push   %esi
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 ff f5 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	89 d8                	mov    %ebx,%eax
}
  8015e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	ff 75 08             	pushl  0x8(%ebp)
  8015fb:	e8 c1 fe ff ff       	call   8014c1 <fd_lookup>
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 10                	js     801617 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	6a 01                	push   $0x1
  80160c:	ff 75 f4             	pushl  -0xc(%ebp)
  80160f:	e8 59 ff ff ff       	call   80156d <fd_close>
  801614:	83 c4 10             	add    $0x10,%esp
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <close_all>:

void
close_all(void)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	53                   	push   %ebx
  80161d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801620:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	53                   	push   %ebx
  801629:	e8 c0 ff ff ff       	call   8015ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80162e:	83 c3 01             	add    $0x1,%ebx
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	83 fb 20             	cmp    $0x20,%ebx
  801637:	75 ec                	jne    801625 <close_all+0xc>
		close(i);
}
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 2c             	sub    $0x2c,%esp
  801647:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80164a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 6b fe ff ff       	call   8014c1 <fd_lookup>
  801656:	83 c4 08             	add    $0x8,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	0f 88 c1 00 00 00    	js     801722 <dup+0xe4>
		return r;
	close(newfdnum);
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	56                   	push   %esi
  801665:	e8 84 ff ff ff       	call   8015ee <close>

	newfd = INDEX2FD(newfdnum);
  80166a:	89 f3                	mov    %esi,%ebx
  80166c:	c1 e3 0c             	shl    $0xc,%ebx
  80166f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801675:	83 c4 04             	add    $0x4,%esp
  801678:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167b:	e8 db fd ff ff       	call   80145b <fd2data>
  801680:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801682:	89 1c 24             	mov    %ebx,(%esp)
  801685:	e8 d1 fd ff ff       	call   80145b <fd2data>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801690:	89 f8                	mov    %edi,%eax
  801692:	c1 e8 16             	shr    $0x16,%eax
  801695:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169c:	a8 01                	test   $0x1,%al
  80169e:	74 37                	je     8016d7 <dup+0x99>
  8016a0:	89 f8                	mov    %edi,%eax
  8016a2:	c1 e8 0c             	shr    $0xc,%eax
  8016a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ac:	f6 c2 01             	test   $0x1,%dl
  8016af:	74 26                	je     8016d7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c0:	50                   	push   %eax
  8016c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c4:	6a 00                	push   $0x0
  8016c6:	57                   	push   %edi
  8016c7:	6a 00                	push   $0x0
  8016c9:	e8 d1 f4 ff ff       	call   800b9f <sys_page_map>
  8016ce:	89 c7                	mov    %eax,%edi
  8016d0:	83 c4 20             	add    $0x20,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 2e                	js     801705 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016da:	89 d0                	mov    %edx,%eax
  8016dc:	c1 e8 0c             	shr    $0xc,%eax
  8016df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ee:	50                   	push   %eax
  8016ef:	53                   	push   %ebx
  8016f0:	6a 00                	push   $0x0
  8016f2:	52                   	push   %edx
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 a5 f4 ff ff       	call   800b9f <sys_page_map>
  8016fa:	89 c7                	mov    %eax,%edi
  8016fc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016ff:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801701:	85 ff                	test   %edi,%edi
  801703:	79 1d                	jns    801722 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	53                   	push   %ebx
  801709:	6a 00                	push   $0x0
  80170b:	e8 d1 f4 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801710:	83 c4 08             	add    $0x8,%esp
  801713:	ff 75 d4             	pushl  -0x2c(%ebp)
  801716:	6a 00                	push   $0x0
  801718:	e8 c4 f4 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	89 f8                	mov    %edi,%eax
}
  801722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5f                   	pop    %edi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	53                   	push   %ebx
  80172e:	83 ec 14             	sub    $0x14,%esp
  801731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801734:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801737:	50                   	push   %eax
  801738:	53                   	push   %ebx
  801739:	e8 83 fd ff ff       	call   8014c1 <fd_lookup>
  80173e:	83 c4 08             	add    $0x8,%esp
  801741:	89 c2                	mov    %eax,%edx
  801743:	85 c0                	test   %eax,%eax
  801745:	78 70                	js     8017b7 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174d:	50                   	push   %eax
  80174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801751:	ff 30                	pushl  (%eax)
  801753:	e8 bf fd ff ff       	call   801517 <dev_lookup>
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 4f                	js     8017ae <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80175f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801762:	8b 42 08             	mov    0x8(%edx),%eax
  801765:	83 e0 03             	and    $0x3,%eax
  801768:	83 f8 01             	cmp    $0x1,%eax
  80176b:	75 24                	jne    801791 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80176d:	a1 04 40 80 00       	mov    0x804004,%eax
  801772:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801778:	83 ec 04             	sub    $0x4,%esp
  80177b:	53                   	push   %ebx
  80177c:	50                   	push   %eax
  80177d:	68 21 2a 80 00       	push   $0x802a21
  801782:	e8 4d ea ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80178f:	eb 26                	jmp    8017b7 <read+0x8d>
	}
	if (!dev->dev_read)
  801791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801794:	8b 40 08             	mov    0x8(%eax),%eax
  801797:	85 c0                	test   %eax,%eax
  801799:	74 17                	je     8017b2 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	ff 75 10             	pushl  0x10(%ebp)
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	52                   	push   %edx
  8017a5:	ff d0                	call   *%eax
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	eb 09                	jmp    8017b7 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	eb 05                	jmp    8017b7 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017b7:	89 d0                	mov    %edx,%eax
  8017b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	57                   	push   %edi
  8017c2:	56                   	push   %esi
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 0c             	sub    $0xc,%esp
  8017c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d2:	eb 21                	jmp    8017f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	89 f0                	mov    %esi,%eax
  8017d9:	29 d8                	sub    %ebx,%eax
  8017db:	50                   	push   %eax
  8017dc:	89 d8                	mov    %ebx,%eax
  8017de:	03 45 0c             	add    0xc(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	57                   	push   %edi
  8017e3:	e8 42 ff ff ff       	call   80172a <read>
		if (m < 0)
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 10                	js     8017ff <readn+0x41>
			return m;
		if (m == 0)
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	74 0a                	je     8017fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017f3:	01 c3                	add    %eax,%ebx
  8017f5:	39 f3                	cmp    %esi,%ebx
  8017f7:	72 db                	jb     8017d4 <readn+0x16>
  8017f9:	89 d8                	mov    %ebx,%eax
  8017fb:	eb 02                	jmp    8017ff <readn+0x41>
  8017fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5f                   	pop    %edi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	83 ec 14             	sub    $0x14,%esp
  80180e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801811:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801814:	50                   	push   %eax
  801815:	53                   	push   %ebx
  801816:	e8 a6 fc ff ff       	call   8014c1 <fd_lookup>
  80181b:	83 c4 08             	add    $0x8,%esp
  80181e:	89 c2                	mov    %eax,%edx
  801820:	85 c0                	test   %eax,%eax
  801822:	78 6b                	js     80188f <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182e:	ff 30                	pushl  (%eax)
  801830:	e8 e2 fc ff ff       	call   801517 <dev_lookup>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 4a                	js     801886 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80183c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801843:	75 24                	jne    801869 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801845:	a1 04 40 80 00       	mov    0x804004,%eax
  80184a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	53                   	push   %ebx
  801854:	50                   	push   %eax
  801855:	68 3d 2a 80 00       	push   $0x802a3d
  80185a:	e8 75 e9 ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801867:	eb 26                	jmp    80188f <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801869:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186c:	8b 52 0c             	mov    0xc(%edx),%edx
  80186f:	85 d2                	test   %edx,%edx
  801871:	74 17                	je     80188a <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	ff 75 10             	pushl  0x10(%ebp)
  801879:	ff 75 0c             	pushl  0xc(%ebp)
  80187c:	50                   	push   %eax
  80187d:	ff d2                	call   *%edx
  80187f:	89 c2                	mov    %eax,%edx
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	eb 09                	jmp    80188f <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	89 c2                	mov    %eax,%edx
  801888:	eb 05                	jmp    80188f <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80188a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80188f:	89 d0                	mov    %edx,%eax
  801891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <seek>:

int
seek(int fdnum, off_t offset)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80189c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	ff 75 08             	pushl  0x8(%ebp)
  8018a3:	e8 19 fc ff ff       	call   8014c1 <fd_lookup>
  8018a8:	83 c4 08             	add    $0x8,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 0e                	js     8018bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 14             	sub    $0x14,%esp
  8018c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	53                   	push   %ebx
  8018ce:	e8 ee fb ff ff       	call   8014c1 <fd_lookup>
  8018d3:	83 c4 08             	add    $0x8,%esp
  8018d6:	89 c2                	mov    %eax,%edx
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 68                	js     801944 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	ff 30                	pushl  (%eax)
  8018e8:	e8 2a fc ff ff       	call   801517 <dev_lookup>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 47                	js     80193b <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018fb:	75 24                	jne    801921 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801902:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801908:	83 ec 04             	sub    $0x4,%esp
  80190b:	53                   	push   %ebx
  80190c:	50                   	push   %eax
  80190d:	68 00 2a 80 00       	push   $0x802a00
  801912:	e8 bd e8 ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80191f:	eb 23                	jmp    801944 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801921:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801924:	8b 52 18             	mov    0x18(%edx),%edx
  801927:	85 d2                	test   %edx,%edx
  801929:	74 14                	je     80193f <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	ff 75 0c             	pushl  0xc(%ebp)
  801931:	50                   	push   %eax
  801932:	ff d2                	call   *%edx
  801934:	89 c2                	mov    %eax,%edx
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	eb 09                	jmp    801944 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193b:	89 c2                	mov    %eax,%edx
  80193d:	eb 05                	jmp    801944 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80193f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801944:	89 d0                	mov    %edx,%eax
  801946:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	83 ec 14             	sub    $0x14,%esp
  801952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801955:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801958:	50                   	push   %eax
  801959:	ff 75 08             	pushl  0x8(%ebp)
  80195c:	e8 60 fb ff ff       	call   8014c1 <fd_lookup>
  801961:	83 c4 08             	add    $0x8,%esp
  801964:	89 c2                	mov    %eax,%edx
  801966:	85 c0                	test   %eax,%eax
  801968:	78 58                	js     8019c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801970:	50                   	push   %eax
  801971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801974:	ff 30                	pushl  (%eax)
  801976:	e8 9c fb ff ff       	call   801517 <dev_lookup>
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 37                	js     8019b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801989:	74 32                	je     8019bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80198b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80198e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801995:	00 00 00 
	stat->st_isdir = 0;
  801998:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80199f:	00 00 00 
	stat->st_dev = dev;
  8019a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019a8:	83 ec 08             	sub    $0x8,%esp
  8019ab:	53                   	push   %ebx
  8019ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8019af:	ff 50 14             	call   *0x14(%eax)
  8019b2:	89 c2                	mov    %eax,%edx
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	eb 09                	jmp    8019c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b9:	89 c2                	mov    %eax,%edx
  8019bb:	eb 05                	jmp    8019c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019c2:	89 d0                	mov    %edx,%eax
  8019c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	6a 00                	push   $0x0
  8019d3:	ff 75 08             	pushl  0x8(%ebp)
  8019d6:	e8 e3 01 00 00       	call   801bbe <open>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 1b                	js     8019ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019e4:	83 ec 08             	sub    $0x8,%esp
  8019e7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ea:	50                   	push   %eax
  8019eb:	e8 5b ff ff ff       	call   80194b <fstat>
  8019f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019f2:	89 1c 24             	mov    %ebx,(%esp)
  8019f5:	e8 f4 fb ff ff       	call   8015ee <close>
	return r;
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	89 f0                	mov    %esi,%eax
}
  8019ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	89 c6                	mov    %eax,%esi
  801a0d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a0f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a16:	75 12                	jne    801a2a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	6a 01                	push   $0x1
  801a1d:	e8 e4 f9 ff ff       	call   801406 <ipc_find_env>
  801a22:	a3 00 40 80 00       	mov    %eax,0x804000
  801a27:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a2a:	6a 07                	push   $0x7
  801a2c:	68 00 50 80 00       	push   $0x805000
  801a31:	56                   	push   %esi
  801a32:	ff 35 00 40 80 00    	pushl  0x804000
  801a38:	e8 67 f9 ff ff       	call   8013a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a3d:	83 c4 0c             	add    $0xc,%esp
  801a40:	6a 00                	push   $0x0
  801a42:	53                   	push   %ebx
  801a43:	6a 00                	push   $0x0
  801a45:	e8 df f8 ff ff       	call   801329 <ipc_recv>
}
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a57:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a65:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6f:	b8 02 00 00 00       	mov    $0x2,%eax
  801a74:	e8 8d ff ff ff       	call   801a06 <fsipc>
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	8b 40 0c             	mov    0xc(%eax),%eax
  801a87:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a91:	b8 06 00 00 00       	mov    $0x6,%eax
  801a96:	e8 6b ff ff ff       	call   801a06 <fsipc>
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 04             	sub    $0x4,%esp
  801aa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  801aad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ab2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab7:	b8 05 00 00 00       	mov    $0x5,%eax
  801abc:	e8 45 ff ff ff       	call   801a06 <fsipc>
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 2c                	js     801af1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac5:	83 ec 08             	sub    $0x8,%esp
  801ac8:	68 00 50 80 00       	push   $0x805000
  801acd:	53                   	push   %ebx
  801ace:	e8 86 ec ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad3:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ade:	a1 84 50 80 00       	mov    0x805084,%eax
  801ae3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aff:	8b 55 08             	mov    0x8(%ebp),%edx
  801b02:	8b 52 0c             	mov    0xc(%edx),%edx
  801b05:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b0b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b10:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b15:	0f 47 c2             	cmova  %edx,%eax
  801b18:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b1d:	50                   	push   %eax
  801b1e:	ff 75 0c             	pushl  0xc(%ebp)
  801b21:	68 08 50 80 00       	push   $0x805008
  801b26:	e8 c0 ed ff ff       	call   8008eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b30:	b8 04 00 00 00       	mov    $0x4,%eax
  801b35:	e8 cc fe ff ff       	call   801a06 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b55:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5a:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5f:	e8 a2 fe ff ff       	call   801a06 <fsipc>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 4b                	js     801bb5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b6a:	39 c6                	cmp    %eax,%esi
  801b6c:	73 16                	jae    801b84 <devfile_read+0x48>
  801b6e:	68 6c 2a 80 00       	push   $0x802a6c
  801b73:	68 73 2a 80 00       	push   $0x802a73
  801b78:	6a 7c                	push   $0x7c
  801b7a:	68 88 2a 80 00       	push   $0x802a88
  801b7f:	e8 c6 05 00 00       	call   80214a <_panic>
	assert(r <= PGSIZE);
  801b84:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b89:	7e 16                	jle    801ba1 <devfile_read+0x65>
  801b8b:	68 93 2a 80 00       	push   $0x802a93
  801b90:	68 73 2a 80 00       	push   $0x802a73
  801b95:	6a 7d                	push   $0x7d
  801b97:	68 88 2a 80 00       	push   $0x802a88
  801b9c:	e8 a9 05 00 00       	call   80214a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	50                   	push   %eax
  801ba5:	68 00 50 80 00       	push   $0x805000
  801baa:	ff 75 0c             	pushl  0xc(%ebp)
  801bad:	e8 39 ed ff ff       	call   8008eb <memmove>
	return r;
  801bb2:	83 c4 10             	add    $0x10,%esp
}
  801bb5:	89 d8                	mov    %ebx,%eax
  801bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 20             	sub    $0x20,%esp
  801bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bc8:	53                   	push   %ebx
  801bc9:	e8 52 eb ff ff       	call   800720 <strlen>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd6:	7f 67                	jg     801c3f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	e8 8e f8 ff ff       	call   801472 <fd_alloc>
  801be4:	83 c4 10             	add    $0x10,%esp
		return r;
  801be7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 57                	js     801c44 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	53                   	push   %ebx
  801bf1:	68 00 50 80 00       	push   $0x805000
  801bf6:	e8 5e eb ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c06:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0b:	e8 f6 fd ff ff       	call   801a06 <fsipc>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	85 c0                	test   %eax,%eax
  801c17:	79 14                	jns    801c2d <open+0x6f>
		fd_close(fd, 0);
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	6a 00                	push   $0x0
  801c1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c21:	e8 47 f9 ff ff       	call   80156d <fd_close>
		return r;
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 da                	mov    %ebx,%edx
  801c2b:	eb 17                	jmp    801c44 <open+0x86>
	}

	return fd2num(fd);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	ff 75 f4             	pushl  -0xc(%ebp)
  801c33:	e8 13 f8 ff ff       	call   80144b <fd2num>
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	eb 05                	jmp    801c44 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c3f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c44:	89 d0                	mov    %edx,%eax
  801c46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	b8 08 00 00 00       	mov    $0x8,%eax
  801c5b:	e8 a6 fd ff ff       	call   801a06 <fsipc>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff 75 08             	pushl  0x8(%ebp)
  801c70:	e8 e6 f7 ff ff       	call   80145b <fd2data>
  801c75:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c77:	83 c4 08             	add    $0x8,%esp
  801c7a:	68 9f 2a 80 00       	push   $0x802a9f
  801c7f:	53                   	push   %ebx
  801c80:	e8 d4 ea ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c85:	8b 46 04             	mov    0x4(%esi),%eax
  801c88:	2b 06                	sub    (%esi),%eax
  801c8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c97:	00 00 00 
	stat->st_dev = &devpipe;
  801c9a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ca1:	30 80 00 
	return 0;
}
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cba:	53                   	push   %ebx
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 1f ef ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc2:	89 1c 24             	mov    %ebx,(%esp)
  801cc5:	e8 91 f7 ff ff       	call   80145b <fd2data>
  801cca:	83 c4 08             	add    $0x8,%esp
  801ccd:	50                   	push   %eax
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 0c ef ff ff       	call   800be1 <sys_page_unmap>
}
  801cd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	57                   	push   %edi
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 1c             	sub    $0x1c,%esp
  801ce3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ce6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ced:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	ff 75 e0             	pushl  -0x20(%ebp)
  801cf9:	e8 21 05 00 00       	call   80221f <pageref>
  801cfe:	89 c3                	mov    %eax,%ebx
  801d00:	89 3c 24             	mov    %edi,(%esp)
  801d03:	e8 17 05 00 00       	call   80221f <pageref>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	39 c3                	cmp    %eax,%ebx
  801d0d:	0f 94 c1             	sete   %cl
  801d10:	0f b6 c9             	movzbl %cl,%ecx
  801d13:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d16:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d1c:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d22:	39 ce                	cmp    %ecx,%esi
  801d24:	74 1e                	je     801d44 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d26:	39 c3                	cmp    %eax,%ebx
  801d28:	75 be                	jne    801ce8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d2a:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801d30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d33:	50                   	push   %eax
  801d34:	56                   	push   %esi
  801d35:	68 a6 2a 80 00       	push   $0x802aa6
  801d3a:	e8 95 e4 ff ff       	call   8001d4 <cprintf>
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	eb a4                	jmp    801ce8 <_pipeisclosed+0xe>
	}
}
  801d44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	57                   	push   %edi
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	83 ec 28             	sub    $0x28,%esp
  801d58:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d5b:	56                   	push   %esi
  801d5c:	e8 fa f6 ff ff       	call   80145b <fd2data>
  801d61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	bf 00 00 00 00       	mov    $0x0,%edi
  801d6b:	eb 4b                	jmp    801db8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d6d:	89 da                	mov    %ebx,%edx
  801d6f:	89 f0                	mov    %esi,%eax
  801d71:	e8 64 ff ff ff       	call   801cda <_pipeisclosed>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	75 48                	jne    801dc2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d7a:	e8 be ed ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d82:	8b 0b                	mov    (%ebx),%ecx
  801d84:	8d 51 20             	lea    0x20(%ecx),%edx
  801d87:	39 d0                	cmp    %edx,%eax
  801d89:	73 e2                	jae    801d6d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d95:	89 c2                	mov    %eax,%edx
  801d97:	c1 fa 1f             	sar    $0x1f,%edx
  801d9a:	89 d1                	mov    %edx,%ecx
  801d9c:	c1 e9 1b             	shr    $0x1b,%ecx
  801d9f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801da2:	83 e2 1f             	and    $0x1f,%edx
  801da5:	29 ca                	sub    %ecx,%edx
  801da7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801daf:	83 c0 01             	add    $0x1,%eax
  801db2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db5:	83 c7 01             	add    $0x1,%edi
  801db8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dbb:	75 c2                	jne    801d7f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc0:	eb 05                	jmp    801dc7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dca:	5b                   	pop    %ebx
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	57                   	push   %edi
  801dd3:	56                   	push   %esi
  801dd4:	53                   	push   %ebx
  801dd5:	83 ec 18             	sub    $0x18,%esp
  801dd8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ddb:	57                   	push   %edi
  801ddc:	e8 7a f6 ff ff       	call   80145b <fd2data>
  801de1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801deb:	eb 3d                	jmp    801e2a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ded:	85 db                	test   %ebx,%ebx
  801def:	74 04                	je     801df5 <devpipe_read+0x26>
				return i;
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	eb 44                	jmp    801e39 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801df5:	89 f2                	mov    %esi,%edx
  801df7:	89 f8                	mov    %edi,%eax
  801df9:	e8 dc fe ff ff       	call   801cda <_pipeisclosed>
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	75 32                	jne    801e34 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e02:	e8 36 ed ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e07:	8b 06                	mov    (%esi),%eax
  801e09:	3b 46 04             	cmp    0x4(%esi),%eax
  801e0c:	74 df                	je     801ded <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e0e:	99                   	cltd   
  801e0f:	c1 ea 1b             	shr    $0x1b,%edx
  801e12:	01 d0                	add    %edx,%eax
  801e14:	83 e0 1f             	and    $0x1f,%eax
  801e17:	29 d0                	sub    %edx,%eax
  801e19:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e21:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e24:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e27:	83 c3 01             	add    $0x1,%ebx
  801e2a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e2d:	75 d8                	jne    801e07 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e2f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e32:	eb 05                	jmp    801e39 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5f                   	pop    %edi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	56                   	push   %esi
  801e45:	53                   	push   %ebx
  801e46:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	e8 20 f6 ff ff       	call   801472 <fd_alloc>
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	89 c2                	mov    %eax,%edx
  801e57:	85 c0                	test   %eax,%eax
  801e59:	0f 88 2c 01 00 00    	js     801f8b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	68 07 04 00 00       	push   $0x407
  801e67:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 eb ec ff ff       	call   800b5c <sys_page_alloc>
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	89 c2                	mov    %eax,%edx
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 0d 01 00 00    	js     801f8b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	e8 e8 f5 ff ff       	call   801472 <fd_alloc>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	0f 88 e2 00 00 00    	js     801f79 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	68 07 04 00 00       	push   $0x407
  801e9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 b3 ec ff ff       	call   800b5c <sys_page_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	0f 88 c3 00 00 00    	js     801f79 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebc:	e8 9a f5 ff ff       	call   80145b <fd2data>
  801ec1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec3:	83 c4 0c             	add    $0xc,%esp
  801ec6:	68 07 04 00 00       	push   $0x407
  801ecb:	50                   	push   %eax
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 89 ec ff ff       	call   800b5c <sys_page_alloc>
  801ed3:	89 c3                	mov    %eax,%ebx
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	0f 88 89 00 00 00    	js     801f69 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee6:	e8 70 f5 ff ff       	call   80145b <fd2data>
  801eeb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ef2:	50                   	push   %eax
  801ef3:	6a 00                	push   $0x0
  801ef5:	56                   	push   %esi
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 a2 ec ff ff       	call   800b9f <sys_page_map>
  801efd:	89 c3                	mov    %eax,%ebx
  801eff:	83 c4 20             	add    $0x20,%esp
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 55                	js     801f5b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f1b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f24:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f29:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	ff 75 f4             	pushl  -0xc(%ebp)
  801f36:	e8 10 f5 ff ff       	call   80144b <fd2num>
  801f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f3e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f40:	83 c4 04             	add    $0x4,%esp
  801f43:	ff 75 f0             	pushl  -0x10(%ebp)
  801f46:	e8 00 f5 ff ff       	call   80144b <fd2num>
  801f4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4e:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	ba 00 00 00 00       	mov    $0x0,%edx
  801f59:	eb 30                	jmp    801f8b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	56                   	push   %esi
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 7b ec ff ff       	call   800be1 <sys_page_unmap>
  801f66:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f69:	83 ec 08             	sub    $0x8,%esp
  801f6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 6b ec ff ff       	call   800be1 <sys_page_unmap>
  801f76:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f79:	83 ec 08             	sub    $0x8,%esp
  801f7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7f:	6a 00                	push   $0x0
  801f81:	e8 5b ec ff ff       	call   800be1 <sys_page_unmap>
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f90:	5b                   	pop    %ebx
  801f91:	5e                   	pop    %esi
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    

00801f94 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9d:	50                   	push   %eax
  801f9e:	ff 75 08             	pushl  0x8(%ebp)
  801fa1:	e8 1b f5 ff ff       	call   8014c1 <fd_lookup>
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 18                	js     801fc5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb3:	e8 a3 f4 ff ff       	call   80145b <fd2data>
	return _pipeisclosed(fd, p);
  801fb8:	89 c2                	mov    %eax,%edx
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	e8 18 fd ff ff       	call   801cda <_pipeisclosed>
  801fc2:	83 c4 10             	add    $0x10,%esp
}
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fca:	b8 00 00 00 00       	mov    $0x0,%eax
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fd7:	68 be 2a 80 00       	push   $0x802abe
  801fdc:	ff 75 0c             	pushl  0xc(%ebp)
  801fdf:	e8 75 e7 ff ff       	call   800759 <strcpy>
	return 0;
}
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	57                   	push   %edi
  801fef:	56                   	push   %esi
  801ff0:	53                   	push   %ebx
  801ff1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ffc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802002:	eb 2d                	jmp    802031 <devcons_write+0x46>
		m = n - tot;
  802004:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802007:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802009:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80200c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802011:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802014:	83 ec 04             	sub    $0x4,%esp
  802017:	53                   	push   %ebx
  802018:	03 45 0c             	add    0xc(%ebp),%eax
  80201b:	50                   	push   %eax
  80201c:	57                   	push   %edi
  80201d:	e8 c9 e8 ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  802022:	83 c4 08             	add    $0x8,%esp
  802025:	53                   	push   %ebx
  802026:	57                   	push   %edi
  802027:	e8 74 ea ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202c:	01 de                	add    %ebx,%esi
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	89 f0                	mov    %esi,%eax
  802033:	3b 75 10             	cmp    0x10(%ebp),%esi
  802036:	72 cc                	jb     802004 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802038:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203b:	5b                   	pop    %ebx
  80203c:	5e                   	pop    %esi
  80203d:	5f                   	pop    %edi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 08             	sub    $0x8,%esp
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80204b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80204f:	74 2a                	je     80207b <devcons_read+0x3b>
  802051:	eb 05                	jmp    802058 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802053:	e8 e5 ea ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802058:	e8 61 ea ff ff       	call   800abe <sys_cgetc>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	74 f2                	je     802053 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802061:	85 c0                	test   %eax,%eax
  802063:	78 16                	js     80207b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802065:	83 f8 04             	cmp    $0x4,%eax
  802068:	74 0c                	je     802076 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80206a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80206d:	88 02                	mov    %al,(%edx)
	return 1;
  80206f:	b8 01 00 00 00       	mov    $0x1,%eax
  802074:	eb 05                	jmp    80207b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802076:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80207b:	c9                   	leave  
  80207c:	c3                   	ret    

0080207d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802083:	8b 45 08             	mov    0x8(%ebp),%eax
  802086:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802089:	6a 01                	push   $0x1
  80208b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80208e:	50                   	push   %eax
  80208f:	e8 0c ea ff ff       	call   800aa0 <sys_cputs>
}
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	c9                   	leave  
  802098:	c3                   	ret    

00802099 <getchar>:

int
getchar(void)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80209f:	6a 01                	push   $0x1
  8020a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a4:	50                   	push   %eax
  8020a5:	6a 00                	push   $0x0
  8020a7:	e8 7e f6 ff ff       	call   80172a <read>
	if (r < 0)
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	78 0f                	js     8020c2 <getchar+0x29>
		return r;
	if (r < 1)
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	7e 06                	jle    8020bd <getchar+0x24>
		return -E_EOF;
	return c;
  8020b7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020bb:	eb 05                	jmp    8020c2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020bd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cd:	50                   	push   %eax
  8020ce:	ff 75 08             	pushl  0x8(%ebp)
  8020d1:	e8 eb f3 ff ff       	call   8014c1 <fd_lookup>
  8020d6:	83 c4 10             	add    $0x10,%esp
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	78 11                	js     8020ee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e6:	39 10                	cmp    %edx,(%eax)
  8020e8:	0f 94 c0             	sete   %al
  8020eb:	0f b6 c0             	movzbl %al,%eax
}
  8020ee:	c9                   	leave  
  8020ef:	c3                   	ret    

008020f0 <opencons>:

int
opencons(void)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f9:	50                   	push   %eax
  8020fa:	e8 73 f3 ff ff       	call   801472 <fd_alloc>
  8020ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802102:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802104:	85 c0                	test   %eax,%eax
  802106:	78 3e                	js     802146 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802108:	83 ec 04             	sub    $0x4,%esp
  80210b:	68 07 04 00 00       	push   $0x407
  802110:	ff 75 f4             	pushl  -0xc(%ebp)
  802113:	6a 00                	push   $0x0
  802115:	e8 42 ea ff ff       	call   800b5c <sys_page_alloc>
  80211a:	83 c4 10             	add    $0x10,%esp
		return r;
  80211d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 23                	js     802146 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802123:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802138:	83 ec 0c             	sub    $0xc,%esp
  80213b:	50                   	push   %eax
  80213c:	e8 0a f3 ff ff       	call   80144b <fd2num>
  802141:	89 c2                	mov    %eax,%edx
  802143:	83 c4 10             	add    $0x10,%esp
}
  802146:	89 d0                	mov    %edx,%eax
  802148:	c9                   	leave  
  802149:	c3                   	ret    

0080214a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	56                   	push   %esi
  80214e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80214f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802152:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802158:	e8 c1 e9 ff ff       	call   800b1e <sys_getenvid>
  80215d:	83 ec 0c             	sub    $0xc,%esp
  802160:	ff 75 0c             	pushl  0xc(%ebp)
  802163:	ff 75 08             	pushl  0x8(%ebp)
  802166:	56                   	push   %esi
  802167:	50                   	push   %eax
  802168:	68 cc 2a 80 00       	push   $0x802acc
  80216d:	e8 62 e0 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802172:	83 c4 18             	add    $0x18,%esp
  802175:	53                   	push   %ebx
  802176:	ff 75 10             	pushl  0x10(%ebp)
  802179:	e8 05 e0 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  80217e:	c7 04 24 06 29 80 00 	movl   $0x802906,(%esp)
  802185:	e8 4a e0 ff ff       	call   8001d4 <cprintf>
  80218a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80218d:	cc                   	int3   
  80218e:	eb fd                	jmp    80218d <_panic+0x43>

00802190 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802196:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80219d:	75 2a                	jne    8021c9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	6a 07                	push   $0x7
  8021a4:	68 00 f0 bf ee       	push   $0xeebff000
  8021a9:	6a 00                	push   $0x0
  8021ab:	e8 ac e9 ff ff       	call   800b5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	79 12                	jns    8021c9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021b7:	50                   	push   %eax
  8021b8:	68 38 29 80 00       	push   $0x802938
  8021bd:	6a 23                	push   $0x23
  8021bf:	68 f0 2a 80 00       	push   $0x802af0
  8021c4:	e8 81 ff ff ff       	call   80214a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cc:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021d1:	83 ec 08             	sub    $0x8,%esp
  8021d4:	68 fb 21 80 00       	push   $0x8021fb
  8021d9:	6a 00                	push   $0x0
  8021db:	e8 c7 ea ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	79 12                	jns    8021f9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021e7:	50                   	push   %eax
  8021e8:	68 38 29 80 00       	push   $0x802938
  8021ed:	6a 2c                	push   $0x2c
  8021ef:	68 f0 2a 80 00       	push   $0x802af0
  8021f4:	e8 51 ff ff ff       	call   80214a <_panic>
	}
}
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021fb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021fc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802201:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802203:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802206:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80220a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80220f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802213:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802215:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802218:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802219:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80221c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80221d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80221e:	c3                   	ret    

0080221f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802225:	89 d0                	mov    %edx,%eax
  802227:	c1 e8 16             	shr    $0x16,%eax
  80222a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802236:	f6 c1 01             	test   $0x1,%cl
  802239:	74 1d                	je     802258 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80223b:	c1 ea 0c             	shr    $0xc,%edx
  80223e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802245:	f6 c2 01             	test   $0x1,%dl
  802248:	74 0e                	je     802258 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80224a:	c1 ea 0c             	shr    $0xc,%edx
  80224d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802254:	ef 
  802255:	0f b7 c0             	movzwl %ax,%eax
}
  802258:	5d                   	pop    %ebp
  802259:	c3                   	ret    
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__udivdi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80226b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80226f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 f6                	test   %esi,%esi
  802279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227d:	89 ca                	mov    %ecx,%edx
  80227f:	89 f8                	mov    %edi,%eax
  802281:	75 3d                	jne    8022c0 <__udivdi3+0x60>
  802283:	39 cf                	cmp    %ecx,%edi
  802285:	0f 87 c5 00 00 00    	ja     802350 <__udivdi3+0xf0>
  80228b:	85 ff                	test   %edi,%edi
  80228d:	89 fd                	mov    %edi,%ebp
  80228f:	75 0b                	jne    80229c <__udivdi3+0x3c>
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	f7 f7                	div    %edi
  80229a:	89 c5                	mov    %eax,%ebp
  80229c:	89 c8                	mov    %ecx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	f7 f5                	div    %ebp
  8022a2:	89 c1                	mov    %eax,%ecx
  8022a4:	89 d8                	mov    %ebx,%eax
  8022a6:	89 cf                	mov    %ecx,%edi
  8022a8:	f7 f5                	div    %ebp
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 ce                	cmp    %ecx,%esi
  8022c2:	77 74                	ja     802338 <__udivdi3+0xd8>
  8022c4:	0f bd fe             	bsr    %esi,%edi
  8022c7:	83 f7 1f             	xor    $0x1f,%edi
  8022ca:	0f 84 98 00 00 00    	je     802368 <__udivdi3+0x108>
  8022d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	29 fb                	sub    %edi,%ebx
  8022db:	d3 e6                	shl    %cl,%esi
  8022dd:	89 d9                	mov    %ebx,%ecx
  8022df:	d3 ed                	shr    %cl,%ebp
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	d3 e0                	shl    %cl,%eax
  8022e5:	09 ee                	or     %ebp,%esi
  8022e7:	89 d9                	mov    %ebx,%ecx
  8022e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ed:	89 d5                	mov    %edx,%ebp
  8022ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022f3:	d3 ed                	shr    %cl,%ebp
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e2                	shl    %cl,%edx
  8022f9:	89 d9                	mov    %ebx,%ecx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	09 c2                	or     %eax,%edx
  8022ff:	89 d0                	mov    %edx,%eax
  802301:	89 ea                	mov    %ebp,%edx
  802303:	f7 f6                	div    %esi
  802305:	89 d5                	mov    %edx,%ebp
  802307:	89 c3                	mov    %eax,%ebx
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	72 10                	jb     802321 <__udivdi3+0xc1>
  802311:	8b 74 24 08          	mov    0x8(%esp),%esi
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e6                	shl    %cl,%esi
  802319:	39 c6                	cmp    %eax,%esi
  80231b:	73 07                	jae    802324 <__udivdi3+0xc4>
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	75 03                	jne    802324 <__udivdi3+0xc4>
  802321:	83 eb 01             	sub    $0x1,%ebx
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 d8                	mov    %ebx,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	31 db                	xor    %ebx,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	89 d8                	mov    %ebx,%eax
  802352:	f7 f7                	div    %edi
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 c3                	mov    %eax,%ebx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 fa                	mov    %edi,%edx
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	5b                   	pop    %ebx
  802360:	5e                   	pop    %esi
  802361:	5f                   	pop    %edi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    
  802364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802368:	39 ce                	cmp    %ecx,%esi
  80236a:	72 0c                	jb     802378 <__udivdi3+0x118>
  80236c:	31 db                	xor    %ebx,%ebx
  80236e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802372:	0f 87 34 ff ff ff    	ja     8022ac <__udivdi3+0x4c>
  802378:	bb 01 00 00 00       	mov    $0x1,%ebx
  80237d:	e9 2a ff ff ff       	jmp    8022ac <__udivdi3+0x4c>
  802382:	66 90                	xchg   %ax,%ax
  802384:	66 90                	xchg   %ax,%ax
  802386:	66 90                	xchg   %ax,%ax
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__umoddi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80239b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80239f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 d2                	test   %edx,%edx
  8023a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 f3                	mov    %esi,%ebx
  8023b3:	89 3c 24             	mov    %edi,(%esp)
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	75 1c                	jne    8023d8 <__umoddi3+0x48>
  8023bc:	39 f7                	cmp    %esi,%edi
  8023be:	76 50                	jbe    802410 <__umoddi3+0x80>
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	f7 f7                	div    %edi
  8023c6:	89 d0                	mov    %edx,%eax
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	39 f2                	cmp    %esi,%edx
  8023da:	89 d0                	mov    %edx,%eax
  8023dc:	77 52                	ja     802430 <__umoddi3+0xa0>
  8023de:	0f bd ea             	bsr    %edx,%ebp
  8023e1:	83 f5 1f             	xor    $0x1f,%ebp
  8023e4:	75 5a                	jne    802440 <__umoddi3+0xb0>
  8023e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ea:	0f 82 e0 00 00 00    	jb     8024d0 <__umoddi3+0x140>
  8023f0:	39 0c 24             	cmp    %ecx,(%esp)
  8023f3:	0f 86 d7 00 00 00    	jbe    8024d0 <__umoddi3+0x140>
  8023f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	85 ff                	test   %edi,%edi
  802412:	89 fd                	mov    %edi,%ebp
  802414:	75 0b                	jne    802421 <__umoddi3+0x91>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f7                	div    %edi
  80241f:	89 c5                	mov    %eax,%ebp
  802421:	89 f0                	mov    %esi,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f5                	div    %ebp
  802427:	89 c8                	mov    %ecx,%eax
  802429:	f7 f5                	div    %ebp
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	eb 99                	jmp    8023c8 <__umoddi3+0x38>
  80242f:	90                   	nop
  802430:	89 c8                	mov    %ecx,%eax
  802432:	89 f2                	mov    %esi,%edx
  802434:	83 c4 1c             	add    $0x1c,%esp
  802437:	5b                   	pop    %ebx
  802438:	5e                   	pop    %esi
  802439:	5f                   	pop    %edi
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	8b 34 24             	mov    (%esp),%esi
  802443:	bf 20 00 00 00       	mov    $0x20,%edi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	29 ef                	sub    %ebp,%edi
  80244c:	d3 e0                	shl    %cl,%eax
  80244e:	89 f9                	mov    %edi,%ecx
  802450:	89 f2                	mov    %esi,%edx
  802452:	d3 ea                	shr    %cl,%edx
  802454:	89 e9                	mov    %ebp,%ecx
  802456:	09 c2                	or     %eax,%edx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 14 24             	mov    %edx,(%esp)
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	d3 e2                	shl    %cl,%edx
  802461:	89 f9                	mov    %edi,%ecx
  802463:	89 54 24 04          	mov    %edx,0x4(%esp)
  802467:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	89 c6                	mov    %eax,%esi
  802471:	d3 e3                	shl    %cl,%ebx
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 d0                	mov    %edx,%eax
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	09 d8                	or     %ebx,%eax
  80247d:	89 d3                	mov    %edx,%ebx
  80247f:	89 f2                	mov    %esi,%edx
  802481:	f7 34 24             	divl   (%esp)
  802484:	89 d6                	mov    %edx,%esi
  802486:	d3 e3                	shl    %cl,%ebx
  802488:	f7 64 24 04          	mull   0x4(%esp)
  80248c:	39 d6                	cmp    %edx,%esi
  80248e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802492:	89 d1                	mov    %edx,%ecx
  802494:	89 c3                	mov    %eax,%ebx
  802496:	72 08                	jb     8024a0 <__umoddi3+0x110>
  802498:	75 11                	jne    8024ab <__umoddi3+0x11b>
  80249a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80249e:	73 0b                	jae    8024ab <__umoddi3+0x11b>
  8024a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024a4:	1b 14 24             	sbb    (%esp),%edx
  8024a7:	89 d1                	mov    %edx,%ecx
  8024a9:	89 c3                	mov    %eax,%ebx
  8024ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024af:	29 da                	sub    %ebx,%edx
  8024b1:	19 ce                	sbb    %ecx,%esi
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e0                	shl    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	d3 ea                	shr    %cl,%edx
  8024bd:	89 e9                	mov    %ebp,%ecx
  8024bf:	d3 ee                	shr    %cl,%esi
  8024c1:	09 d0                	or     %edx,%eax
  8024c3:	89 f2                	mov    %esi,%edx
  8024c5:	83 c4 1c             	add    $0x1c,%esp
  8024c8:	5b                   	pop    %ebx
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	29 f9                	sub    %edi,%ecx
  8024d2:	19 d6                	sbb    %edx,%esi
  8024d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dc:	e9 18 ff ff ff       	jmp    8023f9 <__umoddi3+0x69>
