
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
  80003c:	e8 23 0e 00 00       	call   800e64 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 d0 0a 00 00       	call   800b1f <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 40 22 80 00       	push   $0x802240
  800059:	e8 77 01 00 00       	call   8001d5 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 8c 10 00 00       	call   8010f8 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 01 10 00 00       	call   801080 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 96 0a 00 00       	call   800b1f <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 22 80 00       	push   $0x802256
  800091:	e8 3f 01 00 00       	call   8001d5 <cprintf>
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
  8000a9:	e8 4a 10 00 00       	call   8010f8 <ipc_send>
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
  8000c9:	e8 51 0a 00 00       	call   800b1f <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	89 c2                	mov    %eax,%edx
  8000d5:	c1 e2 07             	shl    $0x7,%edx
  8000d8:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000df:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x31>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	e8 3a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f9:	e8 2a 00 00 00       	call   800128 <exit>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80010e:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800113:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800115:	e8 05 0a 00 00       	call   800b1f <sys_getenvid>
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	50                   	push   %eax
  80011e:	e8 4b 0c 00 00       	call   800d6e <sys_thread_free>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012e:	e8 32 12 00 00       	call   801365 <close_all>
	sys_env_destroy(0);
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	6a 00                	push   $0x0
  800138:	e8 a1 09 00 00       	call   800ade <sys_env_destroy>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	53                   	push   %ebx
  800146:	83 ec 04             	sub    $0x4,%esp
  800149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014c:	8b 13                	mov    (%ebx),%edx
  80014e:	8d 42 01             	lea    0x1(%edx),%eax
  800151:	89 03                	mov    %eax,(%ebx)
  800153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800156:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015f:	75 1a                	jne    80017b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	68 ff 00 00 00       	push   $0xff
  800169:	8d 43 08             	lea    0x8(%ebx),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 2f 09 00 00       	call   800aa1 <sys_cputs>
		b->idx = 0;
  800172:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800178:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800194:	00 00 00 
	b.cnt = 0;
  800197:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a1:	ff 75 0c             	pushl  0xc(%ebp)
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ad:	50                   	push   %eax
  8001ae:	68 42 01 80 00       	push   $0x800142
  8001b3:	e8 54 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b8:	83 c4 08             	add    $0x8,%esp
  8001bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c7:	50                   	push   %eax
  8001c8:	e8 d4 08 00 00       	call   800aa1 <sys_cputs>

	return b.cnt;
}
  8001cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001de:	50                   	push   %eax
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	e8 9d ff ff ff       	call   800184 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 1c             	sub    $0x1c,%esp
  8001f2:	89 c7                	mov    %eax,%edi
  8001f4:	89 d6                	mov    %edx,%esi
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800210:	39 d3                	cmp    %edx,%ebx
  800212:	72 05                	jb     800219 <printnum+0x30>
  800214:	39 45 10             	cmp    %eax,0x10(%ebp)
  800217:	77 45                	ja     80025e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	ff 75 18             	pushl  0x18(%ebp)
  80021f:	8b 45 14             	mov    0x14(%ebp),%eax
  800222:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800225:	53                   	push   %ebx
  800226:	ff 75 10             	pushl  0x10(%ebp)
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022f:	ff 75 e0             	pushl  -0x20(%ebp)
  800232:	ff 75 dc             	pushl  -0x24(%ebp)
  800235:	ff 75 d8             	pushl  -0x28(%ebp)
  800238:	e8 63 1d 00 00       	call   801fa0 <__udivdi3>
  80023d:	83 c4 18             	add    $0x18,%esp
  800240:	52                   	push   %edx
  800241:	50                   	push   %eax
  800242:	89 f2                	mov    %esi,%edx
  800244:	89 f8                	mov    %edi,%eax
  800246:	e8 9e ff ff ff       	call   8001e9 <printnum>
  80024b:	83 c4 20             	add    $0x20,%esp
  80024e:	eb 18                	jmp    800268 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	56                   	push   %esi
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	ff d7                	call   *%edi
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	eb 03                	jmp    800261 <printnum+0x78>
  80025e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800261:	83 eb 01             	sub    $0x1,%ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f e8                	jg     800250 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	56                   	push   %esi
  80026c:	83 ec 04             	sub    $0x4,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 50 1e 00 00       	call   8020d0 <__umoddi3>
  800280:	83 c4 14             	add    $0x14,%esp
  800283:	0f be 80 73 22 80 00 	movsbl 0x802273(%eax),%eax
  80028a:	50                   	push   %eax
  80028b:	ff d7                	call   *%edi
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029b:	83 fa 01             	cmp    $0x1,%edx
  80029e:	7e 0e                	jle    8002ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ac:	eb 22                	jmp    8002d0 <getuint+0x38>
	else if (lflag)
  8002ae:	85 d2                	test   %edx,%edx
  8002b0:	74 10                	je     8002c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c0:	eb 0e                	jmp    8002d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e1:	73 0a                	jae    8002ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	88 02                	mov    %al,(%edx)
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f8:	50                   	push   %eax
  8002f9:	ff 75 10             	pushl  0x10(%ebp)
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	e8 05 00 00 00       	call   80030c <vprintfmt>
	va_end(ap);
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 2c             	sub    $0x2c,%esp
  800315:	8b 75 08             	mov    0x8(%ebp),%esi
  800318:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031e:	eb 12                	jmp    800332 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800320:	85 c0                	test   %eax,%eax
  800322:	0f 84 89 03 00 00    	je     8006b1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	53                   	push   %ebx
  80032c:	50                   	push   %eax
  80032d:	ff d6                	call   *%esi
  80032f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	83 c7 01             	add    $0x1,%edi
  800335:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e2                	jne    800320 <vprintfmt+0x14>
  80033e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800342:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800349:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800350:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	eb 07                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800361:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 07             	movzbl (%edi),%eax
  80036e:	0f b6 c8             	movzbl %al,%ecx
  800371:	83 e8 23             	sub    $0x23,%eax
  800374:	3c 55                	cmp    $0x55,%al
  800376:	0f 87 1a 03 00 00    	ja     800696 <vprintfmt+0x38a>
  80037c:	0f b6 c0             	movzbl %al,%eax
  80037f:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800389:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038d:	eb d6                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
  800397:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a7:	83 fa 09             	cmp    $0x9,%edx
  8003aa:	77 39                	ja     8003e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003af:	eb e9                	jmp    80039a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c2:	eb 27                	jmp    8003eb <vprintfmt+0xdf>
  8003c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c7:	85 c0                	test   %eax,%eax
  8003c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ce:	0f 49 c8             	cmovns %eax,%ecx
  8003d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d7:	eb 8c                	jmp    800365 <vprintfmt+0x59>
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e3:	eb 80                	jmp    800365 <vprintfmt+0x59>
  8003e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ef:	0f 89 70 ff ff ff    	jns    800365 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800402:	e9 5e ff ff ff       	jmp    800365 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800407:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040d:	e9 53 ff ff ff       	jmp    800365 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	53                   	push   %ebx
  80041f:	ff 30                	pushl  (%eax)
  800421:	ff d6                	call   *%esi
			break;
  800423:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800429:	e9 04 ff ff ff       	jmp    800332 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	99                   	cltd   
  80043a:	31 d0                	xor    %edx,%eax
  80043c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043e:	83 f8 0f             	cmp    $0xf,%eax
  800441:	7f 0b                	jg     80044e <vprintfmt+0x142>
  800443:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80044a:	85 d2                	test   %edx,%edx
  80044c:	75 18                	jne    800466 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044e:	50                   	push   %eax
  80044f:	68 8b 22 80 00       	push   $0x80228b
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 94 fe ff ff       	call   8002ef <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800461:	e9 cc fe ff ff       	jmp    800332 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800466:	52                   	push   %edx
  800467:	68 e5 26 80 00       	push   $0x8026e5
  80046c:	53                   	push   %ebx
  80046d:	56                   	push   %esi
  80046e:	e8 7c fe ff ff       	call   8002ef <printfmt>
  800473:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800479:	e9 b4 fe ff ff       	jmp    800332 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 84 22 80 00       	mov    $0x802284,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x225>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 86 02 00 00       	call   800739 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1c0>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x213>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x213>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x23f>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x23f>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x270>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1f2>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1f2>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x278>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058b:	e9 a2 fd ff ff       	jmp    800332 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800590:	83 fa 01             	cmp    $0x1,%edx
  800593:	7e 16                	jle    8005ab <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 08             	lea    0x8(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	eb 32                	jmp    8005dd <vprintfmt+0x2d1>
	else if (lflag)
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	74 18                	je     8005c7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	eb 16                	jmp    8005dd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c1                	mov    %eax,%ecx
  8005d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ec:	79 74                	jns    800662 <vprintfmt+0x356>
				putch('-', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	53                   	push   %ebx
  8005f2:	6a 2d                	push   $0x2d
  8005f4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fc:	f7 d8                	neg    %eax
  8005fe:	83 d2 00             	adc    $0x0,%edx
  800601:	f7 da                	neg    %edx
  800603:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060b:	eb 55                	jmp    800662 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 83 fc ff ff       	call   800298 <getuint>
			base = 10;
  800615:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061a:	eb 46                	jmp    800662 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061c:	8d 45 14             	lea    0x14(%ebp),%eax
  80061f:	e8 74 fc ff ff       	call   800298 <getuint>
			base = 8;
  800624:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800629:	eb 37                	jmp    800662 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 30                	push   $0x30
  800631:	ff d6                	call   *%esi
			putch('x', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 78                	push   $0x78
  800639:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 50 04             	lea    0x4(%eax),%edx
  800641:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800644:	8b 00                	mov    (%eax),%eax
  800646:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800653:	eb 0d                	jmp    800662 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 3b fc ff ff       	call   800298 <getuint>
			base = 16;
  80065d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800662:	83 ec 0c             	sub    $0xc,%esp
  800665:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800669:	57                   	push   %edi
  80066a:	ff 75 e0             	pushl  -0x20(%ebp)
  80066d:	51                   	push   %ecx
  80066e:	52                   	push   %edx
  80066f:	50                   	push   %eax
  800670:	89 da                	mov    %ebx,%edx
  800672:	89 f0                	mov    %esi,%eax
  800674:	e8 70 fb ff ff       	call   8001e9 <printnum>
			break;
  800679:	83 c4 20             	add    $0x20,%esp
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 ae fc ff ff       	jmp    800332 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	51                   	push   %ecx
  800689:	ff d6                	call   *%esi
			break;
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800691:	e9 9c fc ff ff       	jmp    800332 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 25                	push   $0x25
  80069c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 03                	jmp    8006a6 <vprintfmt+0x39a>
  8006a3:	83 ef 01             	sub    $0x1,%edi
  8006a6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006aa:	75 f7                	jne    8006a3 <vprintfmt+0x397>
  8006ac:	e9 81 fc ff ff       	jmp    800332 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b4:	5b                   	pop    %ebx
  8006b5:	5e                   	pop    %esi
  8006b6:	5f                   	pop    %edi
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    

008006b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 18             	sub    $0x18,%esp
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 26                	je     800700 <vsnprintf+0x47>
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	7e 22                	jle    800700 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006de:	ff 75 14             	pushl  0x14(%ebp)
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	68 d2 02 80 00       	push   $0x8002d2
  8006ed:	e8 1a fc ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 05                	jmp    800705 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800710:	50                   	push   %eax
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	ff 75 08             	pushl  0x8(%ebp)
  80071a:	e8 9a ff ff ff       	call   8006b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 03                	jmp    800731 <strlen+0x10>
		n++;
  80072e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800735:	75 f7                	jne    80072e <strlen+0xd>
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800742:	ba 00 00 00 00       	mov    $0x0,%edx
  800747:	eb 03                	jmp    80074c <strnlen+0x13>
		n++;
  800749:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074c:	39 c2                	cmp    %eax,%edx
  80074e:	74 08                	je     800758 <strnlen+0x1f>
  800750:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800754:	75 f3                	jne    800749 <strnlen+0x10>
  800756:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800764:	89 c2                	mov    %eax,%edx
  800766:	83 c2 01             	add    $0x1,%edx
  800769:	83 c1 01             	add    $0x1,%ecx
  80076c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800770:	88 5a ff             	mov    %bl,-0x1(%edx)
  800773:	84 db                	test   %bl,%bl
  800775:	75 ef                	jne    800766 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800777:	5b                   	pop    %ebx
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800781:	53                   	push   %ebx
  800782:	e8 9a ff ff ff       	call   800721 <strlen>
  800787:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	01 d8                	add    %ebx,%eax
  80078f:	50                   	push   %eax
  800790:	e8 c5 ff ff ff       	call   80075a <strcpy>
	return dst;
}
  800795:	89 d8                	mov    %ebx,%eax
  800797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	89 f3                	mov    %esi,%ebx
  8007a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	eb 0f                	jmp    8007bf <strncpy+0x23>
		*dst++ = *src;
  8007b0:	83 c2 01             	add    $0x1,%edx
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	39 da                	cmp    %ebx,%edx
  8007c1:	75 ed                	jne    8007b0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c3:	89 f0                	mov    %esi,%eax
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 21                	je     8007fe <strlcpy+0x35>
  8007dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e1:	89 f2                	mov    %esi,%edx
  8007e3:	eb 09                	jmp    8007ee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e5:	83 c2 01             	add    $0x1,%edx
  8007e8:	83 c1 01             	add    $0x1,%ecx
  8007eb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ee:	39 c2                	cmp    %eax,%edx
  8007f0:	74 09                	je     8007fb <strlcpy+0x32>
  8007f2:	0f b6 19             	movzbl (%ecx),%ebx
  8007f5:	84 db                	test   %bl,%bl
  8007f7:	75 ec                	jne    8007e5 <strlcpy+0x1c>
  8007f9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fe:	29 f0                	sub    %esi,%eax
}
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080d:	eb 06                	jmp    800815 <strcmp+0x11>
		p++, q++;
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800815:	0f b6 01             	movzbl (%ecx),%eax
  800818:	84 c0                	test   %al,%al
  80081a:	74 04                	je     800820 <strcmp+0x1c>
  80081c:	3a 02                	cmp    (%edx),%al
  80081e:	74 ef                	je     80080f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800820:	0f b6 c0             	movzbl %al,%eax
  800823:	0f b6 12             	movzbl (%edx),%edx
  800826:	29 d0                	sub    %edx,%eax
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
  800834:	89 c3                	mov    %eax,%ebx
  800836:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800839:	eb 06                	jmp    800841 <strncmp+0x17>
		n--, p++, q++;
  80083b:	83 c0 01             	add    $0x1,%eax
  80083e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800841:	39 d8                	cmp    %ebx,%eax
  800843:	74 15                	je     80085a <strncmp+0x30>
  800845:	0f b6 08             	movzbl (%eax),%ecx
  800848:	84 c9                	test   %cl,%cl
  80084a:	74 04                	je     800850 <strncmp+0x26>
  80084c:	3a 0a                	cmp    (%edx),%cl
  80084e:	74 eb                	je     80083b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	0f b6 00             	movzbl (%eax),%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
  800858:	eb 05                	jmp    80085f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 07                	jmp    800875 <strchr+0x13>
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 0f                	je     800881 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	0f b6 10             	movzbl (%eax),%edx
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088d:	eb 03                	jmp    800892 <strfind+0xf>
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800895:	38 ca                	cmp    %cl,%dl
  800897:	74 04                	je     80089d <strfind+0x1a>
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f2                	jne    80088f <strfind+0xc>
			break;
	return (char *) s;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	57                   	push   %edi
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ab:	85 c9                	test   %ecx,%ecx
  8008ad:	74 36                	je     8008e5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b5:	75 28                	jne    8008df <memset+0x40>
  8008b7:	f6 c1 03             	test   $0x3,%cl
  8008ba:	75 23                	jne    8008df <memset+0x40>
		c &= 0xFF;
  8008bc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c0:	89 d3                	mov    %edx,%ebx
  8008c2:	c1 e3 08             	shl    $0x8,%ebx
  8008c5:	89 d6                	mov    %edx,%esi
  8008c7:	c1 e6 18             	shl    $0x18,%esi
  8008ca:	89 d0                	mov    %edx,%eax
  8008cc:	c1 e0 10             	shl    $0x10,%eax
  8008cf:	09 f0                	or     %esi,%eax
  8008d1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	09 d0                	or     %edx,%eax
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	fc                   	cld    
  8008db:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dd:	eb 06                	jmp    8008e5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	fc                   	cld    
  8008e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e5:	89 f8                	mov    %edi,%eax
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5f                   	pop    %edi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	57                   	push   %edi
  8008f0:	56                   	push   %esi
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fa:	39 c6                	cmp    %eax,%esi
  8008fc:	73 35                	jae    800933 <memmove+0x47>
  8008fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800901:	39 d0                	cmp    %edx,%eax
  800903:	73 2e                	jae    800933 <memmove+0x47>
		s += n;
		d += n;
  800905:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800908:	89 d6                	mov    %edx,%esi
  80090a:	09 fe                	or     %edi,%esi
  80090c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800912:	75 13                	jne    800927 <memmove+0x3b>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 0e                	jne    800927 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800919:	83 ef 04             	sub    $0x4,%edi
  80091c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091f:	c1 e9 02             	shr    $0x2,%ecx
  800922:	fd                   	std    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 09                	jmp    800930 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800927:	83 ef 01             	sub    $0x1,%edi
  80092a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092d:	fd                   	std    
  80092e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800930:	fc                   	cld    
  800931:	eb 1d                	jmp    800950 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	89 f2                	mov    %esi,%edx
  800935:	09 c2                	or     %eax,%edx
  800937:	f6 c2 03             	test   $0x3,%dl
  80093a:	75 0f                	jne    80094b <memmove+0x5f>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0a                	jne    80094b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800941:	c1 e9 02             	shr    $0x2,%ecx
  800944:	89 c7                	mov    %eax,%edi
  800946:	fc                   	cld    
  800947:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800949:	eb 05                	jmp    800950 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094b:	89 c7                	mov    %eax,%edi
  80094d:	fc                   	cld    
  80094e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 87 ff ff ff       	call   8008ec <memmove>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800972:	89 c6                	mov    %eax,%esi
  800974:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800977:	eb 1a                	jmp    800993 <memcmp+0x2c>
		if (*s1 != *s2)
  800979:	0f b6 08             	movzbl (%eax),%ecx
  80097c:	0f b6 1a             	movzbl (%edx),%ebx
  80097f:	38 d9                	cmp    %bl,%cl
  800981:	74 0a                	je     80098d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800983:	0f b6 c1             	movzbl %cl,%eax
  800986:	0f b6 db             	movzbl %bl,%ebx
  800989:	29 d8                	sub    %ebx,%eax
  80098b:	eb 0f                	jmp    80099c <memcmp+0x35>
		s1++, s2++;
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 f0                	cmp    %esi,%eax
  800995:	75 e2                	jne    800979 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a7:	89 c1                	mov    %eax,%ecx
  8009a9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b0:	eb 0a                	jmp    8009bc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b2:	0f b6 10             	movzbl (%eax),%edx
  8009b5:	39 da                	cmp    %ebx,%edx
  8009b7:	74 07                	je     8009c0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	39 c8                	cmp    %ecx,%eax
  8009be:	72 f2                	jb     8009b2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cf:	eb 03                	jmp    8009d4 <strtol+0x11>
		s++;
  8009d1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d4:	0f b6 01             	movzbl (%ecx),%eax
  8009d7:	3c 20                	cmp    $0x20,%al
  8009d9:	74 f6                	je     8009d1 <strtol+0xe>
  8009db:	3c 09                	cmp    $0x9,%al
  8009dd:	74 f2                	je     8009d1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009df:	3c 2b                	cmp    $0x2b,%al
  8009e1:	75 0a                	jne    8009ed <strtol+0x2a>
		s++;
  8009e3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009eb:	eb 11                	jmp    8009fe <strtol+0x3b>
  8009ed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f2:	3c 2d                	cmp    $0x2d,%al
  8009f4:	75 08                	jne    8009fe <strtol+0x3b>
		s++, neg = 1;
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a04:	75 15                	jne    800a1b <strtol+0x58>
  800a06:	80 39 30             	cmpb   $0x30,(%ecx)
  800a09:	75 10                	jne    800a1b <strtol+0x58>
  800a0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0f:	75 7c                	jne    800a8d <strtol+0xca>
		s += 2, base = 16;
  800a11:	83 c1 02             	add    $0x2,%ecx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 16                	jmp    800a31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 12                	jne    800a31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	75 08                	jne    800a31 <strtol+0x6e>
		s++, base = 8;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a39:	0f b6 11             	movzbl (%ecx),%edx
  800a3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 09             	cmp    $0x9,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x8b>
			dig = *s - '0';
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 30             	sub    $0x30,%edx
  800a4c:	eb 22                	jmp    800a70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a51:	89 f3                	mov    %esi,%ebx
  800a53:	80 fb 19             	cmp    $0x19,%bl
  800a56:	77 08                	ja     800a60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a58:	0f be d2             	movsbl %dl,%edx
  800a5b:	83 ea 57             	sub    $0x57,%edx
  800a5e:	eb 10                	jmp    800a70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a63:	89 f3                	mov    %esi,%ebx
  800a65:	80 fb 19             	cmp    $0x19,%bl
  800a68:	77 16                	ja     800a80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6a:	0f be d2             	movsbl %dl,%edx
  800a6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a73:	7d 0b                	jge    800a80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7e:	eb b9                	jmp    800a39 <strtol+0x76>

	if (endptr)
  800a80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a84:	74 0d                	je     800a93 <strtol+0xd0>
		*endptr = (char *) s;
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	89 0e                	mov    %ecx,(%esi)
  800a8b:	eb 06                	jmp    800a93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	74 98                	je     800a29 <strtol+0x66>
  800a91:	eb 9e                	jmp    800a31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a93:	89 c2                	mov    %eax,%edx
  800a95:	f7 da                	neg    %edx
  800a97:	85 ff                	test   %edi,%edi
  800a99:	0f 45 c2             	cmovne %edx,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	89 c3                	mov    %eax,%ebx
  800ab4:	89 c7                	mov    %eax,%edi
  800ab6:	89 c6                	mov    %eax,%esi
  800ab8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_cgetc>:

int
sys_cgetc(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	89 d1                	mov    %edx,%ecx
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	89 d7                	mov    %edx,%edi
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aec:	b8 03 00 00 00       	mov    $0x3,%eax
  800af1:	8b 55 08             	mov    0x8(%ebp),%edx
  800af4:	89 cb                	mov    %ecx,%ebx
  800af6:	89 cf                	mov    %ecx,%edi
  800af8:	89 ce                	mov    %ecx,%esi
  800afa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afc:	85 c0                	test   %eax,%eax
  800afe:	7e 17                	jle    800b17 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	50                   	push   %eax
  800b04:	6a 03                	push   $0x3
  800b06:	68 7f 25 80 00       	push   $0x80257f
  800b0b:	6a 23                	push   $0x23
  800b0d:	68 9c 25 80 00       	push   $0x80259c
  800b12:	e8 6d 13 00 00       	call   801e84 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 04                	push   $0x4
  800b87:	68 7f 25 80 00       	push   $0x80257f
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 9c 25 80 00       	push   $0x80259c
  800b93:	e8 ec 12 00 00       	call   801e84 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bba:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 05                	push   $0x5
  800bc9:	68 7f 25 80 00       	push   $0x80257f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 9c 25 80 00       	push   $0x80259c
  800bd5:	e8 aa 12 00 00       	call   801e84 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 06                	push   $0x6
  800c0b:	68 7f 25 80 00       	push   $0x80257f
  800c10:	6a 23                	push   $0x23
  800c12:	68 9c 25 80 00       	push   $0x80259c
  800c17:	e8 68 12 00 00       	call   801e84 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 08 00 00 00       	mov    $0x8,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 08                	push   $0x8
  800c4d:	68 7f 25 80 00       	push   $0x80257f
  800c52:	6a 23                	push   $0x23
  800c54:	68 9c 25 80 00       	push   $0x80259c
  800c59:	e8 26 12 00 00       	call   801e84 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	b8 09 00 00 00       	mov    $0x9,%eax
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 17                	jle    800ca0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 09                	push   $0x9
  800c8f:	68 7f 25 80 00       	push   $0x80257f
  800c94:	6a 23                	push   $0x23
  800c96:	68 9c 25 80 00       	push   $0x80259c
  800c9b:	e8 e4 11 00 00       	call   801e84 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 17                	jle    800ce2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	50                   	push   %eax
  800ccf:	6a 0a                	push   $0xa
  800cd1:	68 7f 25 80 00       	push   $0x80257f
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 9c 25 80 00       	push   $0x80259c
  800cdd:	e8 a2 11 00 00       	call   801e84 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	be 00 00 00 00       	mov    $0x0,%esi
  800cf5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d06:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 cb                	mov    %ecx,%ebx
  800d25:	89 cf                	mov    %ecx,%edi
  800d27:	89 ce                	mov    %ecx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 0d                	push   $0xd
  800d35:	68 7f 25 80 00       	push   $0x80257f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 9c 25 80 00       	push   $0x80259c
  800d41:	e8 3e 11 00 00       	call   801e84 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	53                   	push   %ebx
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d98:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d9a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d9e:	74 11                	je     800db1 <pgfault+0x23>
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	c1 e8 0c             	shr    $0xc,%eax
  800da5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dac:	f6 c4 08             	test   $0x8,%ah
  800daf:	75 14                	jne    800dc5 <pgfault+0x37>
		panic("faulting access");
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 aa 25 80 00       	push   $0x8025aa
  800db9:	6a 1e                	push   $0x1e
  800dbb:	68 ba 25 80 00       	push   $0x8025ba
  800dc0:	e8 bf 10 00 00       	call   801e84 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dc5:	83 ec 04             	sub    $0x4,%esp
  800dc8:	6a 07                	push   $0x7
  800dca:	68 00 f0 7f 00       	push   $0x7ff000
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 87 fd ff ff       	call   800b5d <sys_page_alloc>
	if (r < 0) {
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	79 12                	jns    800def <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ddd:	50                   	push   %eax
  800dde:	68 c5 25 80 00       	push   $0x8025c5
  800de3:	6a 2c                	push   $0x2c
  800de5:	68 ba 25 80 00       	push   $0x8025ba
  800dea:	e8 95 10 00 00       	call   801e84 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800def:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	68 00 10 00 00       	push   $0x1000
  800dfd:	53                   	push   %ebx
  800dfe:	68 00 f0 7f 00       	push   $0x7ff000
  800e03:	e8 4c fb ff ff       	call   800954 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e08:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e0f:	53                   	push   %ebx
  800e10:	6a 00                	push   $0x0
  800e12:	68 00 f0 7f 00       	push   $0x7ff000
  800e17:	6a 00                	push   $0x0
  800e19:	e8 82 fd ff ff       	call   800ba0 <sys_page_map>
	if (r < 0) {
  800e1e:	83 c4 20             	add    $0x20,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	79 12                	jns    800e37 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e25:	50                   	push   %eax
  800e26:	68 c5 25 80 00       	push   $0x8025c5
  800e2b:	6a 33                	push   $0x33
  800e2d:	68 ba 25 80 00       	push   $0x8025ba
  800e32:	e8 4d 10 00 00       	call   801e84 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e37:	83 ec 08             	sub    $0x8,%esp
  800e3a:	68 00 f0 7f 00       	push   $0x7ff000
  800e3f:	6a 00                	push   $0x0
  800e41:	e8 9c fd ff ff       	call   800be2 <sys_page_unmap>
	if (r < 0) {
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	79 12                	jns    800e5f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e4d:	50                   	push   %eax
  800e4e:	68 c5 25 80 00       	push   $0x8025c5
  800e53:	6a 37                	push   $0x37
  800e55:	68 ba 25 80 00       	push   $0x8025ba
  800e5a:	e8 25 10 00 00       	call   801e84 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e6d:	68 8e 0d 80 00       	push   $0x800d8e
  800e72:	e8 53 10 00 00       	call   801eca <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e77:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7c:	cd 30                	int    $0x30
  800e7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	85 c0                	test   %eax,%eax
  800e86:	79 17                	jns    800e9f <fork+0x3b>
		panic("fork fault %e");
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	68 de 25 80 00       	push   $0x8025de
  800e90:	68 84 00 00 00       	push   $0x84
  800e95:	68 ba 25 80 00       	push   $0x8025ba
  800e9a:	e8 e5 0f 00 00       	call   801e84 <_panic>
  800e9f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea5:	75 25                	jne    800ecc <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea7:	e8 73 fc ff ff       	call   800b1f <sys_getenvid>
  800eac:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	c1 e2 07             	shl    $0x7,%edx
  800eb6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800ebd:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec7:	e9 61 01 00 00       	jmp    80102d <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	6a 07                	push   $0x7
  800ed1:	68 00 f0 bf ee       	push   $0xeebff000
  800ed6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ed9:	e8 7f fc ff ff       	call   800b5d <sys_page_alloc>
  800ede:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee6:	89 d8                	mov    %ebx,%eax
  800ee8:	c1 e8 16             	shr    $0x16,%eax
  800eeb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef2:	a8 01                	test   $0x1,%al
  800ef4:	0f 84 fc 00 00 00    	je     800ff6 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800efa:	89 d8                	mov    %ebx,%eax
  800efc:	c1 e8 0c             	shr    $0xc,%eax
  800eff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f06:	f6 c2 01             	test   $0x1,%dl
  800f09:	0f 84 e7 00 00 00    	je     800ff6 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1b:	f6 c6 04             	test   $0x4,%dh
  800f1e:	74 39                	je     800f59 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f20:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f2f:	50                   	push   %eax
  800f30:	56                   	push   %esi
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	6a 00                	push   $0x0
  800f35:	e8 66 fc ff ff       	call   800ba0 <sys_page_map>
		if (r < 0) {
  800f3a:	83 c4 20             	add    $0x20,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	0f 89 b1 00 00 00    	jns    800ff6 <fork+0x192>
		    	panic("sys page map fault %e");
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	68 ec 25 80 00       	push   $0x8025ec
  800f4d:	6a 54                	push   $0x54
  800f4f:	68 ba 25 80 00       	push   $0x8025ba
  800f54:	e8 2b 0f 00 00       	call   801e84 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f59:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f60:	f6 c2 02             	test   $0x2,%dl
  800f63:	75 0c                	jne    800f71 <fork+0x10d>
  800f65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6c:	f6 c4 08             	test   $0x8,%ah
  800f6f:	74 5b                	je     800fcc <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	68 05 08 00 00       	push   $0x805
  800f79:	56                   	push   %esi
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 1d fc ff ff       	call   800ba0 <sys_page_map>
		if (r < 0) {
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 14                	jns    800f9e <fork+0x13a>
		    	panic("sys page map fault %e");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 ec 25 80 00       	push   $0x8025ec
  800f92:	6a 5b                	push   $0x5b
  800f94:	68 ba 25 80 00       	push   $0x8025ba
  800f99:	e8 e6 0e 00 00       	call   801e84 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	68 05 08 00 00       	push   $0x805
  800fa6:	56                   	push   %esi
  800fa7:	6a 00                	push   $0x0
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	e8 ef fb ff ff       	call   800ba0 <sys_page_map>
		if (r < 0) {
  800fb1:	83 c4 20             	add    $0x20,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	79 3e                	jns    800ff6 <fork+0x192>
		    	panic("sys page map fault %e");
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	68 ec 25 80 00       	push   $0x8025ec
  800fc0:	6a 5f                	push   $0x5f
  800fc2:	68 ba 25 80 00       	push   $0x8025ba
  800fc7:	e8 b8 0e 00 00       	call   801e84 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	6a 05                	push   $0x5
  800fd1:	56                   	push   %esi
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 c5 fb ff ff       	call   800ba0 <sys_page_map>
		if (r < 0) {
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 14                	jns    800ff6 <fork+0x192>
		    	panic("sys page map fault %e");
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	68 ec 25 80 00       	push   $0x8025ec
  800fea:	6a 64                	push   $0x64
  800fec:	68 ba 25 80 00       	push   $0x8025ba
  800ff1:	e8 8e 0e 00 00       	call   801e84 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801002:	0f 85 de fe ff ff    	jne    800ee6 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801008:	a1 04 40 80 00       	mov    0x804004,%eax
  80100d:	8b 40 70             	mov    0x70(%eax),%eax
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	50                   	push   %eax
  801014:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801017:	57                   	push   %edi
  801018:	e8 8b fc ff ff       	call   800ca8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80101d:	83 c4 08             	add    $0x8,%esp
  801020:	6a 02                	push   $0x2
  801022:	57                   	push   %edi
  801023:	e8 fc fb ff ff       	call   800c24 <sys_env_set_status>
	
	return envid;
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80102d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sfork>:

envid_t
sfork(void)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801047:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	53                   	push   %ebx
  801051:	68 04 26 80 00       	push   $0x802604
  801056:	e8 7a f1 ff ff       	call   8001d5 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80105b:	c7 04 24 08 01 80 00 	movl   $0x800108,(%esp)
  801062:	e8 e7 fc ff ff       	call   800d4e <sys_thread_create>
  801067:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801069:	83 c4 08             	add    $0x8,%esp
  80106c:	53                   	push   %ebx
  80106d:	68 04 26 80 00       	push   $0x802604
  801072:	e8 5e f1 ff ff       	call   8001d5 <cprintf>
	return id;
	//return 0;
}
  801077:	89 f0                	mov    %esi,%eax
  801079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	8b 75 08             	mov    0x8(%ebp),%esi
  801088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80108e:	85 c0                	test   %eax,%eax
  801090:	75 12                	jne    8010a4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	68 00 00 c0 ee       	push   $0xeec00000
  80109a:	e8 6e fc ff ff       	call   800d0d <sys_ipc_recv>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	eb 0c                	jmp    8010b0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	50                   	push   %eax
  8010a8:	e8 60 fc ff ff       	call   800d0d <sys_ipc_recv>
  8010ad:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8010b0:	85 f6                	test   %esi,%esi
  8010b2:	0f 95 c1             	setne  %cl
  8010b5:	85 db                	test   %ebx,%ebx
  8010b7:	0f 95 c2             	setne  %dl
  8010ba:	84 d1                	test   %dl,%cl
  8010bc:	74 09                	je     8010c7 <ipc_recv+0x47>
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	c1 ea 1f             	shr    $0x1f,%edx
  8010c3:	84 d2                	test   %dl,%dl
  8010c5:	75 2a                	jne    8010f1 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010c7:	85 f6                	test   %esi,%esi
  8010c9:	74 0d                	je     8010d8 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8010cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8010d6:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8010d8:	85 db                	test   %ebx,%ebx
  8010da:	74 0d                	je     8010e9 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8010dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e1:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8010e7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ee:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  8010f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	8b 7d 08             	mov    0x8(%ebp),%edi
  801104:	8b 75 0c             	mov    0xc(%ebp),%esi
  801107:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80110a:	85 db                	test   %ebx,%ebx
  80110c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801111:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801114:	ff 75 14             	pushl  0x14(%ebp)
  801117:	53                   	push   %ebx
  801118:	56                   	push   %esi
  801119:	57                   	push   %edi
  80111a:	e8 cb fb ff ff       	call   800cea <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80111f:	89 c2                	mov    %eax,%edx
  801121:	c1 ea 1f             	shr    $0x1f,%edx
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	84 d2                	test   %dl,%dl
  801129:	74 17                	je     801142 <ipc_send+0x4a>
  80112b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80112e:	74 12                	je     801142 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801130:	50                   	push   %eax
  801131:	68 27 26 80 00       	push   $0x802627
  801136:	6a 47                	push   $0x47
  801138:	68 35 26 80 00       	push   $0x802635
  80113d:	e8 42 0d 00 00       	call   801e84 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801142:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801145:	75 07                	jne    80114e <ipc_send+0x56>
			sys_yield();
  801147:	e8 f2 f9 ff ff       	call   800b3e <sys_yield>
  80114c:	eb c6                	jmp    801114 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80114e:	85 c0                	test   %eax,%eax
  801150:	75 c2                	jne    801114 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801165:	89 c2                	mov    %eax,%edx
  801167:	c1 e2 07             	shl    $0x7,%edx
  80116a:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801171:	8b 52 5c             	mov    0x5c(%edx),%edx
  801174:	39 ca                	cmp    %ecx,%edx
  801176:	75 11                	jne    801189 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801178:	89 c2                	mov    %eax,%edx
  80117a:	c1 e2 07             	shl    $0x7,%edx
  80117d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801184:	8b 40 54             	mov    0x54(%eax),%eax
  801187:	eb 0f                	jmp    801198 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801189:	83 c0 01             	add    $0x1,%eax
  80118c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801191:	75 d2                	jne    801165 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ba:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	c1 ea 16             	shr    $0x16,%edx
  8011d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d8:	f6 c2 01             	test   $0x1,%dl
  8011db:	74 11                	je     8011ee <fd_alloc+0x2d>
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 ea 0c             	shr    $0xc,%edx
  8011e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	75 09                	jne    8011f7 <fd_alloc+0x36>
			*fd_store = fd;
  8011ee:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f5:	eb 17                	jmp    80120e <fd_alloc+0x4d>
  8011f7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011fc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801201:	75 c9                	jne    8011cc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801203:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801209:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801216:	83 f8 1f             	cmp    $0x1f,%eax
  801219:	77 36                	ja     801251 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80121b:	c1 e0 0c             	shl    $0xc,%eax
  80121e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801223:	89 c2                	mov    %eax,%edx
  801225:	c1 ea 16             	shr    $0x16,%edx
  801228:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122f:	f6 c2 01             	test   $0x1,%dl
  801232:	74 24                	je     801258 <fd_lookup+0x48>
  801234:	89 c2                	mov    %eax,%edx
  801236:	c1 ea 0c             	shr    $0xc,%edx
  801239:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801240:	f6 c2 01             	test   $0x1,%dl
  801243:	74 1a                	je     80125f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801245:	8b 55 0c             	mov    0xc(%ebp),%edx
  801248:	89 02                	mov    %eax,(%edx)
	return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
  80124f:	eb 13                	jmp    801264 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801251:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801256:	eb 0c                	jmp    801264 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801258:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125d:	eb 05                	jmp    801264 <fd_lookup+0x54>
  80125f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126f:	ba bc 26 80 00       	mov    $0x8026bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801274:	eb 13                	jmp    801289 <dev_lookup+0x23>
  801276:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801279:	39 08                	cmp    %ecx,(%eax)
  80127b:	75 0c                	jne    801289 <dev_lookup+0x23>
			*dev = devtab[i];
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	89 01                	mov    %eax,(%ecx)
			return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 2e                	jmp    8012b7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801289:	8b 02                	mov    (%edx),%eax
  80128b:	85 c0                	test   %eax,%eax
  80128d:	75 e7                	jne    801276 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128f:	a1 04 40 80 00       	mov    0x804004,%eax
  801294:	8b 40 54             	mov    0x54(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	51                   	push   %ecx
  80129b:	50                   	push   %eax
  80129c:	68 40 26 80 00       	push   $0x802640
  8012a1:	e8 2f ef ff ff       	call   8001d5 <cprintf>
	*dev = 0;
  8012a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 10             	sub    $0x10,%esp
  8012c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d1:	c1 e8 0c             	shr    $0xc,%eax
  8012d4:	50                   	push   %eax
  8012d5:	e8 36 ff ff ff       	call   801210 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 05                	js     8012e6 <fd_close+0x2d>
	    || fd != fd2)
  8012e1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e4:	74 0c                	je     8012f2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e6:	84 db                	test   %bl,%bl
  8012e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ed:	0f 44 c2             	cmove  %edx,%eax
  8012f0:	eb 41                	jmp    801333 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 36                	pushl  (%esi)
  8012fb:	e8 66 ff ff ff       	call   801266 <dev_lookup>
  801300:	89 c3                	mov    %eax,%ebx
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 1a                	js     801323 <fd_close+0x6a>
		if (dev->dev_close)
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801314:	85 c0                	test   %eax,%eax
  801316:	74 0b                	je     801323 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	56                   	push   %esi
  80131c:	ff d0                	call   *%eax
  80131e:	89 c3                	mov    %eax,%ebx
  801320:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	56                   	push   %esi
  801327:	6a 00                	push   $0x0
  801329:	e8 b4 f8 ff ff       	call   800be2 <sys_page_unmap>
	return r;
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	89 d8                	mov    %ebx,%eax
}
  801333:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	ff 75 08             	pushl  0x8(%ebp)
  801347:	e8 c4 fe ff ff       	call   801210 <fd_lookup>
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 10                	js     801363 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	6a 01                	push   $0x1
  801358:	ff 75 f4             	pushl  -0xc(%ebp)
  80135b:	e8 59 ff ff ff       	call   8012b9 <fd_close>
  801360:	83 c4 10             	add    $0x10,%esp
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <close_all>:

void
close_all(void)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	53                   	push   %ebx
  801375:	e8 c0 ff ff ff       	call   80133a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80137a:	83 c3 01             	add    $0x1,%ebx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	83 fb 20             	cmp    $0x20,%ebx
  801383:	75 ec                	jne    801371 <close_all+0xc>
		close(i);
}
  801385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	57                   	push   %edi
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
  801390:	83 ec 2c             	sub    $0x2c,%esp
  801393:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801396:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 08             	pushl  0x8(%ebp)
  80139d:	e8 6e fe ff ff       	call   801210 <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	0f 88 c1 00 00 00    	js     80146e <dup+0xe4>
		return r;
	close(newfdnum);
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	56                   	push   %esi
  8013b1:	e8 84 ff ff ff       	call   80133a <close>

	newfd = INDEX2FD(newfdnum);
  8013b6:	89 f3                	mov    %esi,%ebx
  8013b8:	c1 e3 0c             	shl    $0xc,%ebx
  8013bb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c1:	83 c4 04             	add    $0x4,%esp
  8013c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c7:	e8 de fd ff ff       	call   8011aa <fd2data>
  8013cc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ce:	89 1c 24             	mov    %ebx,(%esp)
  8013d1:	e8 d4 fd ff ff       	call   8011aa <fd2data>
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013dc:	89 f8                	mov    %edi,%eax
  8013de:	c1 e8 16             	shr    $0x16,%eax
  8013e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e8:	a8 01                	test   $0x1,%al
  8013ea:	74 37                	je     801423 <dup+0x99>
  8013ec:	89 f8                	mov    %edi,%eax
  8013ee:	c1 e8 0c             	shr    $0xc,%eax
  8013f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f8:	f6 c2 01             	test   $0x1,%dl
  8013fb:	74 26                	je     801423 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	25 07 0e 00 00       	and    $0xe07,%eax
  80140c:	50                   	push   %eax
  80140d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801410:	6a 00                	push   $0x0
  801412:	57                   	push   %edi
  801413:	6a 00                	push   $0x0
  801415:	e8 86 f7 ff ff       	call   800ba0 <sys_page_map>
  80141a:	89 c7                	mov    %eax,%edi
  80141c:	83 c4 20             	add    $0x20,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 2e                	js     801451 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801426:	89 d0                	mov    %edx,%eax
  801428:	c1 e8 0c             	shr    $0xc,%eax
  80142b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	25 07 0e 00 00       	and    $0xe07,%eax
  80143a:	50                   	push   %eax
  80143b:	53                   	push   %ebx
  80143c:	6a 00                	push   $0x0
  80143e:	52                   	push   %edx
  80143f:	6a 00                	push   $0x0
  801441:	e8 5a f7 ff ff       	call   800ba0 <sys_page_map>
  801446:	89 c7                	mov    %eax,%edi
  801448:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80144b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144d:	85 ff                	test   %edi,%edi
  80144f:	79 1d                	jns    80146e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	53                   	push   %ebx
  801455:	6a 00                	push   $0x0
  801457:	e8 86 f7 ff ff       	call   800be2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801462:	6a 00                	push   $0x0
  801464:	e8 79 f7 ff ff       	call   800be2 <sys_page_unmap>
	return r;
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	89 f8                	mov    %edi,%eax
}
  80146e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 14             	sub    $0x14,%esp
  80147d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801480:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	53                   	push   %ebx
  801485:	e8 86 fd ff ff       	call   801210 <fd_lookup>
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 6d                	js     801500 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149d:	ff 30                	pushl  (%eax)
  80149f:	e8 c2 fd ff ff       	call   801266 <dev_lookup>
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 4c                	js     8014f7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ae:	8b 42 08             	mov    0x8(%edx),%eax
  8014b1:	83 e0 03             	and    $0x3,%eax
  8014b4:	83 f8 01             	cmp    $0x1,%eax
  8014b7:	75 21                	jne    8014da <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014be:	8b 40 54             	mov    0x54(%eax),%eax
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	50                   	push   %eax
  8014c6:	68 81 26 80 00       	push   $0x802681
  8014cb:	e8 05 ed ff ff       	call   8001d5 <cprintf>
		return -E_INVAL;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d8:	eb 26                	jmp    801500 <read+0x8a>
	}
	if (!dev->dev_read)
  8014da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dd:	8b 40 08             	mov    0x8(%eax),%eax
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	74 17                	je     8014fb <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	ff 75 10             	pushl  0x10(%ebp)
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	52                   	push   %edx
  8014ee:	ff d0                	call   *%eax
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 09                	jmp    801500 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	eb 05                	jmp    801500 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801500:	89 d0                	mov    %edx,%eax
  801502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	57                   	push   %edi
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	8b 7d 08             	mov    0x8(%ebp),%edi
  801513:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801516:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151b:	eb 21                	jmp    80153e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	89 f0                	mov    %esi,%eax
  801522:	29 d8                	sub    %ebx,%eax
  801524:	50                   	push   %eax
  801525:	89 d8                	mov    %ebx,%eax
  801527:	03 45 0c             	add    0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	57                   	push   %edi
  80152c:	e8 45 ff ff ff       	call   801476 <read>
		if (m < 0)
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 10                	js     801548 <readn+0x41>
			return m;
		if (m == 0)
  801538:	85 c0                	test   %eax,%eax
  80153a:	74 0a                	je     801546 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153c:	01 c3                	add    %eax,%ebx
  80153e:	39 f3                	cmp    %esi,%ebx
  801540:	72 db                	jb     80151d <readn+0x16>
  801542:	89 d8                	mov    %ebx,%eax
  801544:	eb 02                	jmp    801548 <readn+0x41>
  801546:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 14             	sub    $0x14,%esp
  801557:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	53                   	push   %ebx
  80155f:	e8 ac fc ff ff       	call   801210 <fd_lookup>
  801564:	83 c4 08             	add    $0x8,%esp
  801567:	89 c2                	mov    %eax,%edx
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 68                	js     8015d5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801577:	ff 30                	pushl  (%eax)
  801579:	e8 e8 fc ff ff       	call   801266 <dev_lookup>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 47                	js     8015cc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801585:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801588:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158c:	75 21                	jne    8015af <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158e:	a1 04 40 80 00       	mov    0x804004,%eax
  801593:	8b 40 54             	mov    0x54(%eax),%eax
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	53                   	push   %ebx
  80159a:	50                   	push   %eax
  80159b:	68 9d 26 80 00       	push   $0x80269d
  8015a0:	e8 30 ec ff ff       	call   8001d5 <cprintf>
		return -E_INVAL;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ad:	eb 26                	jmp    8015d5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b5:	85 d2                	test   %edx,%edx
  8015b7:	74 17                	je     8015d0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	ff 75 10             	pushl  0x10(%ebp)
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	ff d2                	call   *%edx
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 09                	jmp    8015d5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	eb 05                	jmp    8015d5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	ff 75 08             	pushl  0x8(%ebp)
  8015e9:	e8 22 fc ff ff       	call   801210 <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 0e                	js     801603 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	53                   	push   %ebx
  801609:	83 ec 14             	sub    $0x14,%esp
  80160c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	53                   	push   %ebx
  801614:	e8 f7 fb ff ff       	call   801210 <fd_lookup>
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 65                	js     801687 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	ff 30                	pushl  (%eax)
  80162e:	e8 33 fc ff ff       	call   801266 <dev_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 44                	js     80167e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801641:	75 21                	jne    801664 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801643:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801648:	8b 40 54             	mov    0x54(%eax),%eax
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	53                   	push   %ebx
  80164f:	50                   	push   %eax
  801650:	68 60 26 80 00       	push   $0x802660
  801655:	e8 7b eb ff ff       	call   8001d5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801662:	eb 23                	jmp    801687 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801664:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801667:	8b 52 18             	mov    0x18(%edx),%edx
  80166a:	85 d2                	test   %edx,%edx
  80166c:	74 14                	je     801682 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	50                   	push   %eax
  801675:	ff d2                	call   *%edx
  801677:	89 c2                	mov    %eax,%edx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb 09                	jmp    801687 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167e:	89 c2                	mov    %eax,%edx
  801680:	eb 05                	jmp    801687 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801682:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801687:	89 d0                	mov    %edx,%eax
  801689:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 14             	sub    $0x14,%esp
  801695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 6c fb ff ff       	call   801210 <fd_lookup>
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 58                	js     801705 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b7:	ff 30                	pushl  (%eax)
  8016b9:	e8 a8 fb ff ff       	call   801266 <dev_lookup>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 37                	js     8016fc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cc:	74 32                	je     801700 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d8:	00 00 00 
	stat->st_isdir = 0;
  8016db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e2:	00 00 00 
	stat->st_dev = dev;
  8016e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f2:	ff 50 14             	call   *0x14(%eax)
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	eb 09                	jmp    801705 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	eb 05                	jmp    801705 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801700:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801705:	89 d0                	mov    %edx,%eax
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	6a 00                	push   $0x0
  801716:	ff 75 08             	pushl  0x8(%ebp)
  801719:	e8 e3 01 00 00       	call   801901 <open>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 1b                	js     801742 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	50                   	push   %eax
  80172e:	e8 5b ff ff ff       	call   80168e <fstat>
  801733:	89 c6                	mov    %eax,%esi
	close(fd);
  801735:	89 1c 24             	mov    %ebx,(%esp)
  801738:	e8 fd fb ff ff       	call   80133a <close>
	return r;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	89 f0                	mov    %esi,%eax
}
  801742:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
  80174e:	89 c6                	mov    %eax,%esi
  801750:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801752:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801759:	75 12                	jne    80176d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80175b:	83 ec 0c             	sub    $0xc,%esp
  80175e:	6a 01                	push   $0x1
  801760:	e8 f5 f9 ff ff       	call   80115a <ipc_find_env>
  801765:	a3 00 40 80 00       	mov    %eax,0x804000
  80176a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176d:	6a 07                	push   $0x7
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	56                   	push   %esi
  801775:	ff 35 00 40 80 00    	pushl  0x804000
  80177b:	e8 78 f9 ff ff       	call   8010f8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801780:	83 c4 0c             	add    $0xc,%esp
  801783:	6a 00                	push   $0x0
  801785:	53                   	push   %ebx
  801786:	6a 00                	push   $0x0
  801788:	e8 f3 f8 ff ff       	call   801080 <ipc_recv>
}
  80178d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b7:	e8 8d ff ff ff       	call   801749 <fsipc>
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d9:	e8 6b ff ff ff       	call   801749 <fsipc>
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	53                   	push   %ebx
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ff:	e8 45 ff ff ff       	call   801749 <fsipc>
  801804:	85 c0                	test   %eax,%eax
  801806:	78 2c                	js     801834 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	68 00 50 80 00       	push   $0x805000
  801810:	53                   	push   %ebx
  801811:	e8 44 ef ff ff       	call   80075a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801816:	a1 80 50 80 00       	mov    0x805080,%eax
  80181b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801821:	a1 84 50 80 00       	mov    0x805084,%eax
  801826:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 0c             	sub    $0xc,%esp
  80183f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801842:	8b 55 08             	mov    0x8(%ebp),%edx
  801845:	8b 52 0c             	mov    0xc(%edx),%edx
  801848:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80184e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801853:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801858:	0f 47 c2             	cmova  %edx,%eax
  80185b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801860:	50                   	push   %eax
  801861:	ff 75 0c             	pushl  0xc(%ebp)
  801864:	68 08 50 80 00       	push   $0x805008
  801869:	e8 7e f0 ff ff       	call   8008ec <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 04 00 00 00       	mov    $0x4,%eax
  801878:	e8 cc fe ff ff       	call   801749 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
  80188d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801892:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a2:	e8 a2 fe ff ff       	call   801749 <fsipc>
  8018a7:	89 c3                	mov    %eax,%ebx
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 4b                	js     8018f8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ad:	39 c6                	cmp    %eax,%esi
  8018af:	73 16                	jae    8018c7 <devfile_read+0x48>
  8018b1:	68 cc 26 80 00       	push   $0x8026cc
  8018b6:	68 d3 26 80 00       	push   $0x8026d3
  8018bb:	6a 7c                	push   $0x7c
  8018bd:	68 e8 26 80 00       	push   $0x8026e8
  8018c2:	e8 bd 05 00 00       	call   801e84 <_panic>
	assert(r <= PGSIZE);
  8018c7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cc:	7e 16                	jle    8018e4 <devfile_read+0x65>
  8018ce:	68 f3 26 80 00       	push   $0x8026f3
  8018d3:	68 d3 26 80 00       	push   $0x8026d3
  8018d8:	6a 7d                	push   $0x7d
  8018da:	68 e8 26 80 00       	push   $0x8026e8
  8018df:	e8 a0 05 00 00       	call   801e84 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	50                   	push   %eax
  8018e8:	68 00 50 80 00       	push   $0x805000
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	e8 f7 ef ff ff       	call   8008ec <memmove>
	return r;
  8018f5:	83 c4 10             	add    $0x10,%esp
}
  8018f8:	89 d8                	mov    %ebx,%eax
  8018fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	53                   	push   %ebx
  801905:	83 ec 20             	sub    $0x20,%esp
  801908:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190b:	53                   	push   %ebx
  80190c:	e8 10 ee ff ff       	call   800721 <strlen>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801919:	7f 67                	jg     801982 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801921:	50                   	push   %eax
  801922:	e8 9a f8 ff ff       	call   8011c1 <fd_alloc>
  801927:	83 c4 10             	add    $0x10,%esp
		return r;
  80192a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 57                	js     801987 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	53                   	push   %ebx
  801934:	68 00 50 80 00       	push   $0x805000
  801939:	e8 1c ee ff ff       	call   80075a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801941:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801946:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801949:	b8 01 00 00 00       	mov    $0x1,%eax
  80194e:	e8 f6 fd ff ff       	call   801749 <fsipc>
  801953:	89 c3                	mov    %eax,%ebx
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	79 14                	jns    801970 <open+0x6f>
		fd_close(fd, 0);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	6a 00                	push   $0x0
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	e8 50 f9 ff ff       	call   8012b9 <fd_close>
		return r;
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	89 da                	mov    %ebx,%edx
  80196e:	eb 17                	jmp    801987 <open+0x86>
	}

	return fd2num(fd);
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	ff 75 f4             	pushl  -0xc(%ebp)
  801976:	e8 1f f8 ff ff       	call   80119a <fd2num>
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	eb 05                	jmp    801987 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801982:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801987:	89 d0                	mov    %edx,%eax
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801994:	ba 00 00 00 00       	mov    $0x0,%edx
  801999:	b8 08 00 00 00       	mov    $0x8,%eax
  80199e:	e8 a6 fd ff ff       	call   801749 <fsipc>
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	ff 75 08             	pushl  0x8(%ebp)
  8019b3:	e8 f2 f7 ff ff       	call   8011aa <fd2data>
  8019b8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ba:	83 c4 08             	add    $0x8,%esp
  8019bd:	68 ff 26 80 00       	push   $0x8026ff
  8019c2:	53                   	push   %ebx
  8019c3:	e8 92 ed ff ff       	call   80075a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c8:	8b 46 04             	mov    0x4(%esi),%eax
  8019cb:	2b 06                	sub    (%esi),%eax
  8019cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019da:	00 00 00 
	stat->st_dev = &devpipe;
  8019dd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e4:	30 80 00 
	return 0;
}
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fd:	53                   	push   %ebx
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 dd f1 ff ff       	call   800be2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a05:	89 1c 24             	mov    %ebx,(%esp)
  801a08:	e8 9d f7 ff ff       	call   8011aa <fd2data>
  801a0d:	83 c4 08             	add    $0x8,%esp
  801a10:	50                   	push   %eax
  801a11:	6a 00                	push   $0x0
  801a13:	e8 ca f1 ff ff       	call   800be2 <sys_page_unmap>
}
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	57                   	push   %edi
  801a21:	56                   	push   %esi
  801a22:	53                   	push   %ebx
  801a23:	83 ec 1c             	sub    $0x1c,%esp
  801a26:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a29:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a30:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	ff 75 e0             	pushl  -0x20(%ebp)
  801a39:	e8 1b 05 00 00       	call   801f59 <pageref>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	89 3c 24             	mov    %edi,(%esp)
  801a43:	e8 11 05 00 00       	call   801f59 <pageref>
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	39 c3                	cmp    %eax,%ebx
  801a4d:	0f 94 c1             	sete   %cl
  801a50:	0f b6 c9             	movzbl %cl,%ecx
  801a53:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5c:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801a5f:	39 ce                	cmp    %ecx,%esi
  801a61:	74 1b                	je     801a7e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a63:	39 c3                	cmp    %eax,%ebx
  801a65:	75 c4                	jne    801a2b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a67:	8b 42 64             	mov    0x64(%edx),%eax
  801a6a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6d:	50                   	push   %eax
  801a6e:	56                   	push   %esi
  801a6f:	68 06 27 80 00       	push   $0x802706
  801a74:	e8 5c e7 ff ff       	call   8001d5 <cprintf>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb ad                	jmp    801a2b <_pipeisclosed+0xe>
	}
}
  801a7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5e                   	pop    %esi
  801a86:	5f                   	pop    %edi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 28             	sub    $0x28,%esp
  801a92:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a95:	56                   	push   %esi
  801a96:	e8 0f f7 ff ff       	call   8011aa <fd2data>
  801a9b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa5:	eb 4b                	jmp    801af2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa7:	89 da                	mov    %ebx,%edx
  801aa9:	89 f0                	mov    %esi,%eax
  801aab:	e8 6d ff ff ff       	call   801a1d <_pipeisclosed>
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	75 48                	jne    801afc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab4:	e8 85 f0 ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab9:	8b 43 04             	mov    0x4(%ebx),%eax
  801abc:	8b 0b                	mov    (%ebx),%ecx
  801abe:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac1:	39 d0                	cmp    %edx,%eax
  801ac3:	73 e2                	jae    801aa7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801acc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801acf:	89 c2                	mov    %eax,%edx
  801ad1:	c1 fa 1f             	sar    $0x1f,%edx
  801ad4:	89 d1                	mov    %edx,%ecx
  801ad6:	c1 e9 1b             	shr    $0x1b,%ecx
  801ad9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801adc:	83 e2 1f             	and    $0x1f,%edx
  801adf:	29 ca                	sub    %ecx,%edx
  801ae1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae9:	83 c0 01             	add    $0x1,%eax
  801aec:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aef:	83 c7 01             	add    $0x1,%edi
  801af2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af5:	75 c2                	jne    801ab9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af7:	8b 45 10             	mov    0x10(%ebp),%eax
  801afa:	eb 05                	jmp    801b01 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5f                   	pop    %edi
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	57                   	push   %edi
  801b0d:	56                   	push   %esi
  801b0e:	53                   	push   %ebx
  801b0f:	83 ec 18             	sub    $0x18,%esp
  801b12:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b15:	57                   	push   %edi
  801b16:	e8 8f f6 ff ff       	call   8011aa <fd2data>
  801b1b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b25:	eb 3d                	jmp    801b64 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b27:	85 db                	test   %ebx,%ebx
  801b29:	74 04                	je     801b2f <devpipe_read+0x26>
				return i;
  801b2b:	89 d8                	mov    %ebx,%eax
  801b2d:	eb 44                	jmp    801b73 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b2f:	89 f2                	mov    %esi,%edx
  801b31:	89 f8                	mov    %edi,%eax
  801b33:	e8 e5 fe ff ff       	call   801a1d <_pipeisclosed>
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	75 32                	jne    801b6e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b3c:	e8 fd ef ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b41:	8b 06                	mov    (%esi),%eax
  801b43:	3b 46 04             	cmp    0x4(%esi),%eax
  801b46:	74 df                	je     801b27 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b48:	99                   	cltd   
  801b49:	c1 ea 1b             	shr    $0x1b,%edx
  801b4c:	01 d0                	add    %edx,%eax
  801b4e:	83 e0 1f             	and    $0x1f,%eax
  801b51:	29 d0                	sub    %edx,%eax
  801b53:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b5e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b61:	83 c3 01             	add    $0x1,%ebx
  801b64:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b67:	75 d8                	jne    801b41 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b69:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6c:	eb 05                	jmp    801b73 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b86:	50                   	push   %eax
  801b87:	e8 35 f6 ff ff       	call   8011c1 <fd_alloc>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	89 c2                	mov    %eax,%edx
  801b91:	85 c0                	test   %eax,%eax
  801b93:	0f 88 2c 01 00 00    	js     801cc5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b99:	83 ec 04             	sub    $0x4,%esp
  801b9c:	68 07 04 00 00       	push   $0x407
  801ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba4:	6a 00                	push   $0x0
  801ba6:	e8 b2 ef ff ff       	call   800b5d <sys_page_alloc>
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	89 c2                	mov    %eax,%edx
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	0f 88 0d 01 00 00    	js     801cc5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bbe:	50                   	push   %eax
  801bbf:	e8 fd f5 ff ff       	call   8011c1 <fd_alloc>
  801bc4:	89 c3                	mov    %eax,%ebx
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	0f 88 e2 00 00 00    	js     801cb3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd1:	83 ec 04             	sub    $0x4,%esp
  801bd4:	68 07 04 00 00       	push   $0x407
  801bd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 7a ef ff ff       	call   800b5d <sys_page_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 c3 00 00 00    	js     801cb3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf6:	e8 af f5 ff ff       	call   8011aa <fd2data>
  801bfb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfd:	83 c4 0c             	add    $0xc,%esp
  801c00:	68 07 04 00 00       	push   $0x407
  801c05:	50                   	push   %eax
  801c06:	6a 00                	push   $0x0
  801c08:	e8 50 ef ff ff       	call   800b5d <sys_page_alloc>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	85 c0                	test   %eax,%eax
  801c14:	0f 88 89 00 00 00    	js     801ca3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c20:	e8 85 f5 ff ff       	call   8011aa <fd2data>
  801c25:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c2c:	50                   	push   %eax
  801c2d:	6a 00                	push   $0x0
  801c2f:	56                   	push   %esi
  801c30:	6a 00                	push   $0x0
  801c32:	e8 69 ef ff ff       	call   800ba0 <sys_page_map>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 20             	add    $0x20,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 55                	js     801c95 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c49:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c55:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c63:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c70:	e8 25 f5 ff ff       	call   80119a <fd2num>
  801c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c78:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c7a:	83 c4 04             	add    $0x4,%esp
  801c7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c80:	e8 15 f5 ff ff       	call   80119a <fd2num>
  801c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c88:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c93:	eb 30                	jmp    801cc5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	56                   	push   %esi
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 42 ef ff ff       	call   800be2 <sys_page_unmap>
  801ca0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 32 ef ff ff       	call   800be2 <sys_page_unmap>
  801cb0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 22 ef ff ff       	call   800be2 <sys_page_unmap>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	ff 75 08             	pushl  0x8(%ebp)
  801cdb:	e8 30 f5 ff ff       	call   801210 <fd_lookup>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 18                	js     801cff <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	e8 b8 f4 ff ff       	call   8011aa <fd2data>
	return _pipeisclosed(fd, p);
  801cf2:	89 c2                	mov    %eax,%edx
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	e8 21 fd ff ff       	call   801a1d <_pipeisclosed>
  801cfc:	83 c4 10             	add    $0x10,%esp
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d11:	68 1e 27 80 00       	push   $0x80271e
  801d16:	ff 75 0c             	pushl  0xc(%ebp)
  801d19:	e8 3c ea ff ff       	call   80075a <strcpy>
	return 0;
}
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	57                   	push   %edi
  801d29:	56                   	push   %esi
  801d2a:	53                   	push   %ebx
  801d2b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d31:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d36:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d3c:	eb 2d                	jmp    801d6b <devcons_write+0x46>
		m = n - tot;
  801d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d41:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d43:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d46:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d4b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	53                   	push   %ebx
  801d52:	03 45 0c             	add    0xc(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	57                   	push   %edi
  801d57:	e8 90 eb ff ff       	call   8008ec <memmove>
		sys_cputs(buf, m);
  801d5c:	83 c4 08             	add    $0x8,%esp
  801d5f:	53                   	push   %ebx
  801d60:	57                   	push   %edi
  801d61:	e8 3b ed ff ff       	call   800aa1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d66:	01 de                	add    %ebx,%esi
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	89 f0                	mov    %esi,%eax
  801d6d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d70:	72 cc                	jb     801d3e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d75:	5b                   	pop    %ebx
  801d76:	5e                   	pop    %esi
  801d77:	5f                   	pop    %edi
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d89:	74 2a                	je     801db5 <devcons_read+0x3b>
  801d8b:	eb 05                	jmp    801d92 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d8d:	e8 ac ed ff ff       	call   800b3e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d92:	e8 28 ed ff ff       	call   800abf <sys_cgetc>
  801d97:	85 c0                	test   %eax,%eax
  801d99:	74 f2                	je     801d8d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 16                	js     801db5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d9f:	83 f8 04             	cmp    $0x4,%eax
  801da2:	74 0c                	je     801db0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801da4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da7:	88 02                	mov    %al,(%edx)
	return 1;
  801da9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dae:	eb 05                	jmp    801db5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dc3:	6a 01                	push   $0x1
  801dc5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc8:	50                   	push   %eax
  801dc9:	e8 d3 ec ff ff       	call   800aa1 <sys_cputs>
}
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <getchar>:

int
getchar(void)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd9:	6a 01                	push   $0x1
  801ddb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dde:	50                   	push   %eax
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 90 f6 ff ff       	call   801476 <read>
	if (r < 0)
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 0f                	js     801dfc <getchar+0x29>
		return r;
	if (r < 1)
  801ded:	85 c0                	test   %eax,%eax
  801def:	7e 06                	jle    801df7 <getchar+0x24>
		return -E_EOF;
	return c;
  801df1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df5:	eb 05                	jmp    801dfc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	ff 75 08             	pushl  0x8(%ebp)
  801e0b:	e8 00 f4 ff ff       	call   801210 <fd_lookup>
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 11                	js     801e28 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e20:	39 10                	cmp    %edx,(%eax)
  801e22:	0f 94 c0             	sete   %al
  801e25:	0f b6 c0             	movzbl %al,%eax
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <opencons>:

int
opencons(void)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	e8 88 f3 ff ff       	call   8011c1 <fd_alloc>
  801e39:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 3e                	js     801e80 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	68 07 04 00 00       	push   $0x407
  801e4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 09 ed ff ff       	call   800b5d <sys_page_alloc>
  801e54:	83 c4 10             	add    $0x10,%esp
		return r;
  801e57:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 23                	js     801e80 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	50                   	push   %eax
  801e76:	e8 1f f3 ff ff       	call   80119a <fd2num>
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	83 c4 10             	add    $0x10,%esp
}
  801e80:	89 d0                	mov    %edx,%eax
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e89:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e8c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e92:	e8 88 ec ff ff       	call   800b1f <sys_getenvid>
  801e97:	83 ec 0c             	sub    $0xc,%esp
  801e9a:	ff 75 0c             	pushl  0xc(%ebp)
  801e9d:	ff 75 08             	pushl  0x8(%ebp)
  801ea0:	56                   	push   %esi
  801ea1:	50                   	push   %eax
  801ea2:	68 2c 27 80 00       	push   $0x80272c
  801ea7:	e8 29 e3 ff ff       	call   8001d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eac:	83 c4 18             	add    $0x18,%esp
  801eaf:	53                   	push   %ebx
  801eb0:	ff 75 10             	pushl  0x10(%ebp)
  801eb3:	e8 cc e2 ff ff       	call   800184 <vcprintf>
	cprintf("\n");
  801eb8:	c7 04 24 17 27 80 00 	movl   $0x802717,(%esp)
  801ebf:	e8 11 e3 ff ff       	call   8001d5 <cprintf>
  801ec4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ec7:	cc                   	int3   
  801ec8:	eb fd                	jmp    801ec7 <_panic+0x43>

00801eca <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ed7:	75 2a                	jne    801f03 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ed9:	83 ec 04             	sub    $0x4,%esp
  801edc:	6a 07                	push   $0x7
  801ede:	68 00 f0 bf ee       	push   $0xeebff000
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 73 ec ff ff       	call   800b5d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	79 12                	jns    801f03 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ef1:	50                   	push   %eax
  801ef2:	68 50 27 80 00       	push   $0x802750
  801ef7:	6a 23                	push   $0x23
  801ef9:	68 54 27 80 00       	push   $0x802754
  801efe:	e8 81 ff ff ff       	call   801e84 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	68 35 1f 80 00       	push   $0x801f35
  801f13:	6a 00                	push   $0x0
  801f15:	e8 8e ed ff ff       	call   800ca8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	79 12                	jns    801f33 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f21:	50                   	push   %eax
  801f22:	68 50 27 80 00       	push   $0x802750
  801f27:	6a 2c                	push   $0x2c
  801f29:	68 54 27 80 00       	push   $0x802754
  801f2e:	e8 51 ff ff ff       	call   801e84 <_panic>
	}
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f35:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f36:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f3d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f40:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f44:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f49:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f4d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f4f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f52:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f53:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f56:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f57:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f58:	c3                   	ret    

00801f59 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5f:	89 d0                	mov    %edx,%eax
  801f61:	c1 e8 16             	shr    $0x16,%eax
  801f64:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f6b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f70:	f6 c1 01             	test   $0x1,%cl
  801f73:	74 1d                	je     801f92 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f75:	c1 ea 0c             	shr    $0xc,%edx
  801f78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f7f:	f6 c2 01             	test   $0x1,%dl
  801f82:	74 0e                	je     801f92 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f84:	c1 ea 0c             	shr    $0xc,%edx
  801f87:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f8e:	ef 
  801f8f:	0f b7 c0             	movzwl %ax,%eax
}
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
