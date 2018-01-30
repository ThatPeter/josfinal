
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 d0 00 00 00       	call   800101 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 58 10 00 00       	call   801099 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 0e 0b 00 00       	call   800b61 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 c0 24 80 00       	push   $0x8024c0
  80005d:	e8 b5 01 00 00       	call   800217 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f7 0a 00 00       	call   800b61 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 da 24 80 00       	push   $0x8024da
  800074:	e8 9e 01 00 00       	call   800217 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 e2 12 00 00       	call   801369 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 54 12 00 00       	call   8012ee <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b bb a0 00 00 00    	mov    0xa0(%ebx),%edi
  8000a6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000b1:	e8 ab 0a 00 00       	call   800b61 <sys_getenvid>
  8000b6:	83 c4 08             	add    $0x8,%esp
  8000b9:	57                   	push   %edi
  8000ba:	53                   	push   %ebx
  8000bb:	56                   	push   %esi
  8000bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bf:	50                   	push   %eax
  8000c0:	68 f0 24 80 00       	push   $0x8024f0
  8000c5:	e8 4d 01 00 00       	call   800217 <cprintf>
		if (val == 10)
  8000ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cf:	83 c4 20             	add    $0x20,%esp
  8000d2:	83 f8 0a             	cmp    $0xa,%eax
  8000d5:	74 22                	je     8000f9 <umain+0xc6>
			return;
		++val;
  8000d7:	83 c0 01             	add    $0x1,%eax
  8000da:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000df:	6a 00                	push   $0x0
  8000e1:	6a 00                	push   $0x0
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e8:	e8 7c 12 00 00       	call   801369 <ipc_send>
		if (val == 10)
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f7:	75 91                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800109:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010c:	e8 50 0a 00 00       	call   800b61 <sys_getenvid>
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 db                	test   %ebx,%ebx
  800128:	7e 07                	jle    800131 <libmain+0x30>
		binaryname = argv[0];
  80012a:	8b 06                	mov    (%esi),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	56                   	push   %esi
  800135:	53                   	push   %ebx
  800136:	e8 f8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013b:	e8 2a 00 00 00       	call   80016a <exit>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800150:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  800155:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800157:	e8 05 0a 00 00       	call   800b61 <sys_getenvid>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	50                   	push   %eax
  800160:	e8 4b 0c 00 00       	call   800db0 <sys_thread_free>
}
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800170:	e8 69 14 00 00       	call   8015de <close_all>
	sys_env_destroy(0);
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	6a 00                	push   $0x0
  80017a:	e8 a1 09 00 00       	call   800b20 <sys_env_destroy>
}
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 13                	mov    (%ebx),%edx
  800190:	8d 42 01             	lea    0x1(%edx),%eax
  800193:	89 03                	mov    %eax,(%ebx)
  800195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800198:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a1:	75 1a                	jne    8001bd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a3:	83 ec 08             	sub    $0x8,%esp
  8001a6:	68 ff 00 00 00       	push   $0xff
  8001ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ae:	50                   	push   %eax
  8001af:	e8 2f 09 00 00       	call   800ae3 <sys_cputs>
		b->idx = 0;
  8001b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ba:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d6:	00 00 00 
	b.cnt = 0;
  8001d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	ff 75 08             	pushl  0x8(%ebp)
  8001e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 84 01 80 00       	push   $0x800184
  8001f5:	e8 54 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fa:	83 c4 08             	add    $0x8,%esp
  8001fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800203:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	e8 d4 08 00 00       	call   800ae3 <sys_cputs>

	return b.cnt;
}
  80020f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800220:	50                   	push   %eax
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	e8 9d ff ff ff       	call   8001c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 1c             	sub    $0x1c,%esp
  800234:	89 c7                	mov    %eax,%edi
  800236:	89 d6                	mov    %edx,%esi
  800238:	8b 45 08             	mov    0x8(%ebp),%eax
  80023b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800241:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800252:	39 d3                	cmp    %edx,%ebx
  800254:	72 05                	jb     80025b <printnum+0x30>
  800256:	39 45 10             	cmp    %eax,0x10(%ebp)
  800259:	77 45                	ja     8002a0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025b:	83 ec 0c             	sub    $0xc,%esp
  80025e:	ff 75 18             	pushl  0x18(%ebp)
  800261:	8b 45 14             	mov    0x14(%ebp),%eax
  800264:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800267:	53                   	push   %ebx
  800268:	ff 75 10             	pushl  0x10(%ebp)
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 a1 1f 00 00       	call   802220 <__udivdi3>
  80027f:	83 c4 18             	add    $0x18,%esp
  800282:	52                   	push   %edx
  800283:	50                   	push   %eax
  800284:	89 f2                	mov    %esi,%edx
  800286:	89 f8                	mov    %edi,%eax
  800288:	e8 9e ff ff ff       	call   80022b <printnum>
  80028d:	83 c4 20             	add    $0x20,%esp
  800290:	eb 18                	jmp    8002aa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	56                   	push   %esi
  800296:	ff 75 18             	pushl  0x18(%ebp)
  800299:	ff d7                	call   *%edi
  80029b:	83 c4 10             	add    $0x10,%esp
  80029e:	eb 03                	jmp    8002a3 <printnum+0x78>
  8002a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	83 eb 01             	sub    $0x1,%ebx
  8002a6:	85 db                	test   %ebx,%ebx
  8002a8:	7f e8                	jg     800292 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	56                   	push   %esi
  8002ae:	83 ec 04             	sub    $0x4,%esp
  8002b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bd:	e8 8e 20 00 00       	call   802350 <__umoddi3>
  8002c2:	83 c4 14             	add    $0x14,%esp
  8002c5:	0f be 80 20 25 80 00 	movsbl 0x802520(%eax),%eax
  8002cc:	50                   	push   %eax
  8002cd:	ff d7                	call   *%edi
}
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002dd:	83 fa 01             	cmp    $0x1,%edx
  8002e0:	7e 0e                	jle    8002f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ee:	eb 22                	jmp    800312 <getuint+0x38>
	else if (lflag)
  8002f0:	85 d2                	test   %edx,%edx
  8002f2:	74 10                	je     800304 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800302:	eb 0e                	jmp    800312 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	3b 50 04             	cmp    0x4(%eax),%edx
  800323:	73 0a                	jae    80032f <sprintputch+0x1b>
		*b->buf++ = ch;
  800325:	8d 4a 01             	lea    0x1(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	88 02                	mov    %al,(%edx)
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800337:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033a:	50                   	push   %eax
  80033b:	ff 75 10             	pushl  0x10(%ebp)
  80033e:	ff 75 0c             	pushl  0xc(%ebp)
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	e8 05 00 00 00       	call   80034e <vprintfmt>
	va_end(ap);
}
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 2c             	sub    $0x2c,%esp
  800357:	8b 75 08             	mov    0x8(%ebp),%esi
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800360:	eb 12                	jmp    800374 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800362:	85 c0                	test   %eax,%eax
  800364:	0f 84 89 03 00 00    	je     8006f3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	53                   	push   %ebx
  80036e:	50                   	push   %eax
  80036f:	ff d6                	call   *%esi
  800371:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800374:	83 c7 01             	add    $0x1,%edi
  800377:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037b:	83 f8 25             	cmp    $0x25,%eax
  80037e:	75 e2                	jne    800362 <vprintfmt+0x14>
  800380:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800384:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800392:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	eb 07                	jmp    8003a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8d 47 01             	lea    0x1(%edi),%eax
  8003aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ad:	0f b6 07             	movzbl (%edi),%eax
  8003b0:	0f b6 c8             	movzbl %al,%ecx
  8003b3:	83 e8 23             	sub    $0x23,%eax
  8003b6:	3c 55                	cmp    $0x55,%al
  8003b8:	0f 87 1a 03 00 00    	ja     8006d8 <vprintfmt+0x38a>
  8003be:	0f b6 c0             	movzbl %al,%eax
  8003c1:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cf:	eb d6                	jmp    8003a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003df:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e9:	83 fa 09             	cmp    $0x9,%edx
  8003ec:	77 39                	ja     800427 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f1:	eb e9                	jmp    8003dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800404:	eb 27                	jmp    80042d <vprintfmt+0xdf>
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800410:	0f 49 c8             	cmovns %eax,%ecx
  800413:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800419:	eb 8c                	jmp    8003a7 <vprintfmt+0x59>
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800425:	eb 80                	jmp    8003a7 <vprintfmt+0x59>
  800427:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	0f 89 70 ff ff ff    	jns    8003a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800437:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800444:	e9 5e ff ff ff       	jmp    8003a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800449:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044f:	e9 53 ff ff ff       	jmp    8003a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	ff 30                	pushl  (%eax)
  800463:	ff d6                	call   *%esi
			break;
  800465:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046b:	e9 04 ff ff ff       	jmp    800374 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	99                   	cltd   
  80047c:	31 d0                	xor    %edx,%eax
  80047e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800480:	83 f8 0f             	cmp    $0xf,%eax
  800483:	7f 0b                	jg     800490 <vprintfmt+0x142>
  800485:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80048c:	85 d2                	test   %edx,%edx
  80048e:	75 18                	jne    8004a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800490:	50                   	push   %eax
  800491:	68 38 25 80 00       	push   $0x802538
  800496:	53                   	push   %ebx
  800497:	56                   	push   %esi
  800498:	e8 94 fe ff ff       	call   800331 <printfmt>
  80049d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a3:	e9 cc fe ff ff       	jmp    800374 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a8:	52                   	push   %edx
  8004a9:	68 95 29 80 00       	push   $0x802995
  8004ae:	53                   	push   %ebx
  8004af:	56                   	push   %esi
  8004b0:	e8 7c fe ff ff       	call   800331 <printfmt>
  8004b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bb:	e9 b4 fe ff ff       	jmp    800374 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cb:	85 ff                	test   %edi,%edi
  8004cd:	b8 31 25 80 00       	mov    $0x802531,%eax
  8004d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d9:	0f 8e 94 00 00 00    	jle    800573 <vprintfmt+0x225>
  8004df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e3:	0f 84 98 00 00 00    	je     800581 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ef:	57                   	push   %edi
  8004f0:	e8 86 02 00 00       	call   80077b <strnlen>
  8004f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f8:	29 c1                	sub    %eax,%ecx
  8004fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800500:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800504:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800507:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	eb 0f                	jmp    80051d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	ff 75 e0             	pushl  -0x20(%ebp)
  800515:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	83 ef 01             	sub    $0x1,%edi
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 ff                	test   %edi,%edi
  80051f:	7f ed                	jg     80050e <vprintfmt+0x1c0>
  800521:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800524:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800527:	85 c9                	test   %ecx,%ecx
  800529:	b8 00 00 00 00       	mov    $0x0,%eax
  80052e:	0f 49 c1             	cmovns %ecx,%eax
  800531:	29 c1                	sub    %eax,%ecx
  800533:	89 75 08             	mov    %esi,0x8(%ebp)
  800536:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053c:	89 cb                	mov    %ecx,%ebx
  80053e:	eb 4d                	jmp    80058d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800540:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800544:	74 1b                	je     800561 <vprintfmt+0x213>
  800546:	0f be c0             	movsbl %al,%eax
  800549:	83 e8 20             	sub    $0x20,%eax
  80054c:	83 f8 5e             	cmp    $0x5e,%eax
  80054f:	76 10                	jbe    800561 <vprintfmt+0x213>
					putch('?', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	6a 3f                	push   $0x3f
  800559:	ff 55 08             	call   *0x8(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 0d                	jmp    80056e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	52                   	push   %edx
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	83 eb 01             	sub    $0x1,%ebx
  800571:	eb 1a                	jmp    80058d <vprintfmt+0x23f>
  800573:	89 75 08             	mov    %esi,0x8(%ebp)
  800576:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800579:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057f:	eb 0c                	jmp    80058d <vprintfmt+0x23f>
  800581:	89 75 08             	mov    %esi,0x8(%ebp)
  800584:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800587:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058d:	83 c7 01             	add    $0x1,%edi
  800590:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800594:	0f be d0             	movsbl %al,%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	74 23                	je     8005be <vprintfmt+0x270>
  80059b:	85 f6                	test   %esi,%esi
  80059d:	78 a1                	js     800540 <vprintfmt+0x1f2>
  80059f:	83 ee 01             	sub    $0x1,%esi
  8005a2:	79 9c                	jns    800540 <vprintfmt+0x1f2>
  8005a4:	89 df                	mov    %ebx,%edi
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ac:	eb 18                	jmp    8005c6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 20                	push   $0x20
  8005b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b6:	83 ef 01             	sub    $0x1,%edi
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	eb 08                	jmp    8005c6 <vprintfmt+0x278>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f e4                	jg     8005ae <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cd:	e9 a2 fd ff ff       	jmp    800374 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d2:	83 fa 01             	cmp    $0x1,%edx
  8005d5:	7e 16                	jle    8005ed <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 08             	lea    0x8(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	8b 50 04             	mov    0x4(%eax),%edx
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005eb:	eb 32                	jmp    80061f <vprintfmt+0x2d1>
	else if (lflag)
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 18                	je     800609 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 c1                	mov    %eax,%ecx
  800601:	c1 f9 1f             	sar    $0x1f,%ecx
  800604:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800607:	eb 16                	jmp    80061f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 50 04             	lea    0x4(%eax),%edx
  80060f:	89 55 14             	mov    %edx,0x14(%ebp)
  800612:	8b 00                	mov    (%eax),%eax
  800614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800617:	89 c1                	mov    %eax,%ecx
  800619:	c1 f9 1f             	sar    $0x1f,%ecx
  80061c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800622:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800625:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062e:	79 74                	jns    8006a4 <vprintfmt+0x356>
				putch('-', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 2d                	push   $0x2d
  800636:	ff d6                	call   *%esi
				num = -(long long) num;
  800638:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063e:	f7 d8                	neg    %eax
  800640:	83 d2 00             	adc    $0x0,%edx
  800643:	f7 da                	neg    %edx
  800645:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800648:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064d:	eb 55                	jmp    8006a4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 83 fc ff ff       	call   8002da <getuint>
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065c:	eb 46                	jmp    8006a4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 74 fc ff ff       	call   8002da <getuint>
			base = 8;
  800666:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80066b:	eb 37                	jmp    8006a4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	6a 30                	push   $0x30
  800673:	ff d6                	call   *%esi
			putch('x', putdat);
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 78                	push   $0x78
  80067b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800686:	8b 00                	mov    (%eax),%eax
  800688:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800690:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800695:	eb 0d                	jmp    8006a4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 3b fc ff ff       	call   8002da <getuint>
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ab:	57                   	push   %edi
  8006ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8006af:	51                   	push   %ecx
  8006b0:	52                   	push   %edx
  8006b1:	50                   	push   %eax
  8006b2:	89 da                	mov    %ebx,%edx
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	e8 70 fb ff ff       	call   80022b <printnum>
			break;
  8006bb:	83 c4 20             	add    $0x20,%esp
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c1:	e9 ae fc ff ff       	jmp    800374 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	51                   	push   %ecx
  8006cb:	ff d6                	call   *%esi
			break;
  8006cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d3:	e9 9c fc ff ff       	jmp    800374 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	6a 25                	push   $0x25
  8006de:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb 03                	jmp    8006e8 <vprintfmt+0x39a>
  8006e5:	83 ef 01             	sub    $0x1,%edi
  8006e8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ec:	75 f7                	jne    8006e5 <vprintfmt+0x397>
  8006ee:	e9 81 fc ff ff       	jmp    800374 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 18             	sub    $0x18,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 26                	je     800742 <vsnprintf+0x47>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 22                	jle    800742 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	ff 75 14             	pushl  0x14(%ebp)
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	68 14 03 80 00       	push   $0x800314
  80072f:	e8 1a fc ff ff       	call   80034e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	eb 05                	jmp    800747 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	50                   	push   %eax
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	ff 75 0c             	pushl  0xc(%ebp)
  800759:	ff 75 08             	pushl  0x8(%ebp)
  80075c:	e8 9a ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
  80076e:	eb 03                	jmp    800773 <strlen+0x10>
		n++;
  800770:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800773:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800777:	75 f7                	jne    800770 <strlen+0xd>
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800781:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	ba 00 00 00 00       	mov    $0x0,%edx
  800789:	eb 03                	jmp    80078e <strnlen+0x13>
		n++;
  80078b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	39 c2                	cmp    %eax,%edx
  800790:	74 08                	je     80079a <strnlen+0x1f>
  800792:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800796:	75 f3                	jne    80078b <strnlen+0x10>
  800798:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a6:	89 c2                	mov    %eax,%edx
  8007a8:	83 c2 01             	add    $0x1,%edx
  8007ab:	83 c1 01             	add    $0x1,%ecx
  8007ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b5:	84 db                	test   %bl,%bl
  8007b7:	75 ef                	jne    8007a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c3:	53                   	push   %ebx
  8007c4:	e8 9a ff ff ff       	call   800763 <strlen>
  8007c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	50                   	push   %eax
  8007d2:	e8 c5 ff ff ff       	call   80079c <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	89 f3                	mov    %esi,%ebx
  8007eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ee:	89 f2                	mov    %esi,%edx
  8007f0:	eb 0f                	jmp    800801 <strncpy+0x23>
		*dst++ = *src;
  8007f2:	83 c2 01             	add    $0x1,%edx
  8007f5:	0f b6 01             	movzbl (%ecx),%eax
  8007f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	39 da                	cmp    %ebx,%edx
  800803:	75 ed                	jne    8007f2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800805:	89 f0                	mov    %esi,%eax
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	8b 55 10             	mov    0x10(%ebp),%edx
  800819:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 21                	je     800840 <strlcpy+0x35>
  80081f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800823:	89 f2                	mov    %esi,%edx
  800825:	eb 09                	jmp    800830 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800830:	39 c2                	cmp    %eax,%edx
  800832:	74 09                	je     80083d <strlcpy+0x32>
  800834:	0f b6 19             	movzbl (%ecx),%ebx
  800837:	84 db                	test   %bl,%bl
  800839:	75 ec                	jne    800827 <strlcpy+0x1c>
  80083b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800840:	29 f0                	sub    %esi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084f:	eb 06                	jmp    800857 <strcmp+0x11>
		p++, q++;
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800857:	0f b6 01             	movzbl (%ecx),%eax
  80085a:	84 c0                	test   %al,%al
  80085c:	74 04                	je     800862 <strcmp+0x1c>
  80085e:	3a 02                	cmp    (%edx),%al
  800860:	74 ef                	je     800851 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800862:	0f b6 c0             	movzbl %al,%eax
  800865:	0f b6 12             	movzbl (%edx),%edx
  800868:	29 d0                	sub    %edx,%eax
}
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	53                   	push   %ebx
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 c3                	mov    %eax,%ebx
  800878:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087b:	eb 06                	jmp    800883 <strncmp+0x17>
		n--, p++, q++;
  80087d:	83 c0 01             	add    $0x1,%eax
  800880:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800883:	39 d8                	cmp    %ebx,%eax
  800885:	74 15                	je     80089c <strncmp+0x30>
  800887:	0f b6 08             	movzbl (%eax),%ecx
  80088a:	84 c9                	test   %cl,%cl
  80088c:	74 04                	je     800892 <strncmp+0x26>
  80088e:	3a 0a                	cmp    (%edx),%cl
  800890:	74 eb                	je     80087d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 00             	movzbl (%eax),%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
  80089a:	eb 05                	jmp    8008a1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ae:	eb 07                	jmp    8008b7 <strchr+0x13>
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 0f                	je     8008c3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	0f b6 10             	movzbl (%eax),%edx
  8008ba:	84 d2                	test   %dl,%dl
  8008bc:	75 f2                	jne    8008b0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cf:	eb 03                	jmp    8008d4 <strfind+0xf>
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	74 04                	je     8008df <strfind+0x1a>
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	75 f2                	jne    8008d1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	57                   	push   %edi
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 36                	je     800927 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 28                	jne    800921 <memset+0x40>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 23                	jne    800921 <memset+0x40>
		c &= 0xFF;
  8008fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	89 d3                	mov    %edx,%ebx
  800904:	c1 e3 08             	shl    $0x8,%ebx
  800907:	89 d6                	mov    %edx,%esi
  800909:	c1 e6 18             	shl    $0x18,%esi
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	c1 e0 10             	shl    $0x10,%eax
  800911:	09 f0                	or     %esi,%eax
  800913:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800915:	89 d8                	mov    %ebx,%eax
  800917:	09 d0                	or     %edx,%eax
  800919:	c1 e9 02             	shr    $0x2,%ecx
  80091c:	fc                   	cld    
  80091d:	f3 ab                	rep stos %eax,%es:(%edi)
  80091f:	eb 06                	jmp    800927 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800921:	8b 45 0c             	mov    0xc(%ebp),%eax
  800924:	fc                   	cld    
  800925:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800927:	89 f8                	mov    %edi,%eax
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5f                   	pop    %edi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 75 0c             	mov    0xc(%ebp),%esi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093c:	39 c6                	cmp    %eax,%esi
  80093e:	73 35                	jae    800975 <memmove+0x47>
  800940:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800943:	39 d0                	cmp    %edx,%eax
  800945:	73 2e                	jae    800975 <memmove+0x47>
		s += n;
		d += n;
  800947:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	09 fe                	or     %edi,%esi
  80094e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800954:	75 13                	jne    800969 <memmove+0x3b>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0e                	jne    800969 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095b:	83 ef 04             	sub    $0x4,%edi
  80095e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800961:	c1 e9 02             	shr    $0x2,%ecx
  800964:	fd                   	std    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb 09                	jmp    800972 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800969:	83 ef 01             	sub    $0x1,%edi
  80096c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096f:	fd                   	std    
  800970:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800972:	fc                   	cld    
  800973:	eb 1d                	jmp    800992 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800975:	89 f2                	mov    %esi,%edx
  800977:	09 c2                	or     %eax,%edx
  800979:	f6 c2 03             	test   $0x3,%dl
  80097c:	75 0f                	jne    80098d <memmove+0x5f>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0a                	jne    80098d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800983:	c1 e9 02             	shr    $0x2,%ecx
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800999:	ff 75 10             	pushl  0x10(%ebp)
  80099c:	ff 75 0c             	pushl  0xc(%ebp)
  80099f:	ff 75 08             	pushl  0x8(%ebp)
  8009a2:	e8 87 ff ff ff       	call   80092e <memmove>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b4:	89 c6                	mov    %eax,%esi
  8009b6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b9:	eb 1a                	jmp    8009d5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009bb:	0f b6 08             	movzbl (%eax),%ecx
  8009be:	0f b6 1a             	movzbl (%edx),%ebx
  8009c1:	38 d9                	cmp    %bl,%cl
  8009c3:	74 0a                	je     8009cf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c5:	0f b6 c1             	movzbl %cl,%eax
  8009c8:	0f b6 db             	movzbl %bl,%ebx
  8009cb:	29 d8                	sub    %ebx,%eax
  8009cd:	eb 0f                	jmp    8009de <memcmp+0x35>
		s1++, s2++;
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	39 f0                	cmp    %esi,%eax
  8009d7:	75 e2                	jne    8009bb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e9:	89 c1                	mov    %eax,%ecx
  8009eb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f2:	eb 0a                	jmp    8009fe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f4:	0f b6 10             	movzbl (%eax),%edx
  8009f7:	39 da                	cmp    %ebx,%edx
  8009f9:	74 07                	je     800a02 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	39 c8                	cmp    %ecx,%eax
  800a00:	72 f2                	jb     8009f4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	eb 03                	jmp    800a16 <strtol+0x11>
		s++;
  800a13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	0f b6 01             	movzbl (%ecx),%eax
  800a19:	3c 20                	cmp    $0x20,%al
  800a1b:	74 f6                	je     800a13 <strtol+0xe>
  800a1d:	3c 09                	cmp    $0x9,%al
  800a1f:	74 f2                	je     800a13 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a21:	3c 2b                	cmp    $0x2b,%al
  800a23:	75 0a                	jne    800a2f <strtol+0x2a>
		s++;
  800a25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a28:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2d:	eb 11                	jmp    800a40 <strtol+0x3b>
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a34:	3c 2d                	cmp    $0x2d,%al
  800a36:	75 08                	jne    800a40 <strtol+0x3b>
		s++, neg = 1;
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a46:	75 15                	jne    800a5d <strtol+0x58>
  800a48:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4b:	75 10                	jne    800a5d <strtol+0x58>
  800a4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a51:	75 7c                	jne    800acf <strtol+0xca>
		s += 2, base = 16;
  800a53:	83 c1 02             	add    $0x2,%ecx
  800a56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5b:	eb 16                	jmp    800a73 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	75 12                	jne    800a73 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a66:	80 39 30             	cmpb   $0x30,(%ecx)
  800a69:	75 08                	jne    800a73 <strtol+0x6e>
		s++, base = 8;
  800a6b:	83 c1 01             	add    $0x1,%ecx
  800a6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7b:	0f b6 11             	movzbl (%ecx),%edx
  800a7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 09             	cmp    $0x9,%bl
  800a86:	77 08                	ja     800a90 <strtol+0x8b>
			dig = *s - '0';
  800a88:	0f be d2             	movsbl %dl,%edx
  800a8b:	83 ea 30             	sub    $0x30,%edx
  800a8e:	eb 22                	jmp    800ab2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a93:	89 f3                	mov    %esi,%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a9a:	0f be d2             	movsbl %dl,%edx
  800a9d:	83 ea 57             	sub    $0x57,%edx
  800aa0:	eb 10                	jmp    800ab2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 16                	ja     800ac2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab5:	7d 0b                	jge    800ac2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac0:	eb b9                	jmp    800a7b <strtol+0x76>

	if (endptr)
  800ac2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac6:	74 0d                	je     800ad5 <strtol+0xd0>
		*endptr = (char *) s;
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acb:	89 0e                	mov    %ecx,(%esi)
  800acd:	eb 06                	jmp    800ad5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acf:	85 db                	test   %ebx,%ebx
  800ad1:	74 98                	je     800a6b <strtol+0x66>
  800ad3:	eb 9e                	jmp    800a73 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	f7 da                	neg    %edx
  800ad9:	85 ff                	test   %edi,%edi
  800adb:	0f 45 c2             	cmovne %edx,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af1:	8b 55 08             	mov    0x8(%ebp),%edx
  800af4:	89 c3                	mov    %eax,%ebx
  800af6:	89 c7                	mov    %eax,%edi
  800af8:	89 c6                	mov    %eax,%esi
  800afa:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	89 cb                	mov    %ecx,%ebx
  800b38:	89 cf                	mov    %ecx,%edi
  800b3a:	89 ce                	mov    %ecx,%esi
  800b3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	7e 17                	jle    800b59 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	50                   	push   %eax
  800b46:	6a 03                	push   $0x3
  800b48:	68 1f 28 80 00       	push   $0x80281f
  800b4d:	6a 23                	push   $0x23
  800b4f:	68 3c 28 80 00       	push   $0x80283c
  800b54:	e8 b6 15 00 00       	call   80210f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_yield>:

void
sys_yield(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800ba8:	be 00 00 00 00       	mov    $0x0,%esi
  800bad:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbb:	89 f7                	mov    %esi,%edi
  800bbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 04                	push   $0x4
  800bc9:	68 1f 28 80 00       	push   $0x80281f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 3c 28 80 00       	push   $0x80283c
  800bd5:	e8 35 15 00 00       	call   80210f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800beb:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 05                	push   $0x5
  800c0b:	68 1f 28 80 00       	push   $0x80281f
  800c10:	6a 23                	push   $0x23
  800c12:	68 3c 28 80 00       	push   $0x80283c
  800c17:	e8 f3 14 00 00       	call   80210f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c32:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c45:	7e 17                	jle    800c5e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 06                	push   $0x6
  800c4d:	68 1f 28 80 00       	push   $0x80281f
  800c52:	6a 23                	push   $0x23
  800c54:	68 3c 28 80 00       	push   $0x80283c
  800c59:	e8 b1 14 00 00       	call   80210f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c74:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c87:	7e 17                	jle    800ca0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 08                	push   $0x8
  800c8f:	68 1f 28 80 00       	push   $0x80281f
  800c94:	6a 23                	push   $0x23
  800c96:	68 3c 28 80 00       	push   $0x80283c
  800c9b:	e8 6f 14 00 00       	call   80210f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cb6:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cc9:	7e 17                	jle    800ce2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	50                   	push   %eax
  800ccf:	6a 09                	push   $0x9
  800cd1:	68 1f 28 80 00       	push   $0x80281f
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 3c 28 80 00       	push   $0x80283c
  800cdd:	e8 2d 14 00 00       	call   80210f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 17                	jle    800d24 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 0a                	push   $0xa
  800d13:	68 1f 28 80 00       	push   $0x80281f
  800d18:	6a 23                	push   $0x23
  800d1a:	68 3c 28 80 00       	push   $0x80283c
  800d1f:	e8 eb 13 00 00       	call   80210f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	be 00 00 00 00       	mov    $0x0,%esi
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 cb                	mov    %ecx,%ebx
  800d67:	89 cf                	mov    %ecx,%edi
  800d69:	89 ce                	mov    %ecx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 17                	jle    800d88 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	50                   	push   %eax
  800d75:	6a 0d                	push   $0xd
  800d77:	68 1f 28 80 00       	push   $0x80281f
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 3c 28 80 00       	push   $0x80283c
  800d83:	e8 87 13 00 00       	call   80210f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 ce                	mov    %ecx,%esi
  800da9:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	89 ce                	mov    %ecx,%esi
  800dc9:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddb:	b8 10 00 00 00       	mov    $0x10,%eax
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 cb                	mov    %ecx,%ebx
  800de5:	89 cf                	mov    %ecx,%edi
  800de7:	89 ce                	mov    %ecx,%esi
  800de9:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	53                   	push   %ebx
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfa:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dfc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e00:	74 11                	je     800e13 <pgfault+0x23>
  800e02:	89 d8                	mov    %ebx,%eax
  800e04:	c1 e8 0c             	shr    $0xc,%eax
  800e07:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e0e:	f6 c4 08             	test   $0x8,%ah
  800e11:	75 14                	jne    800e27 <pgfault+0x37>
		panic("faulting access");
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	68 4a 28 80 00       	push   $0x80284a
  800e1b:	6a 1f                	push   $0x1f
  800e1d:	68 5a 28 80 00       	push   $0x80285a
  800e22:	e8 e8 12 00 00       	call   80210f <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	6a 07                	push   $0x7
  800e2c:	68 00 f0 7f 00       	push   $0x7ff000
  800e31:	6a 00                	push   $0x0
  800e33:	e8 67 fd ff ff       	call   800b9f <sys_page_alloc>
	if (r < 0) {
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	79 12                	jns    800e51 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e3f:	50                   	push   %eax
  800e40:	68 65 28 80 00       	push   $0x802865
  800e45:	6a 2d                	push   $0x2d
  800e47:	68 5a 28 80 00       	push   $0x80285a
  800e4c:	e8 be 12 00 00       	call   80210f <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e51:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	68 00 10 00 00       	push   $0x1000
  800e5f:	53                   	push   %ebx
  800e60:	68 00 f0 7f 00       	push   $0x7ff000
  800e65:	e8 2c fb ff ff       	call   800996 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e6a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e71:	53                   	push   %ebx
  800e72:	6a 00                	push   $0x0
  800e74:	68 00 f0 7f 00       	push   $0x7ff000
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 62 fd ff ff       	call   800be2 <sys_page_map>
	if (r < 0) {
  800e80:	83 c4 20             	add    $0x20,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	79 12                	jns    800e99 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e87:	50                   	push   %eax
  800e88:	68 65 28 80 00       	push   $0x802865
  800e8d:	6a 34                	push   $0x34
  800e8f:	68 5a 28 80 00       	push   $0x80285a
  800e94:	e8 76 12 00 00       	call   80210f <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	68 00 f0 7f 00       	push   $0x7ff000
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 7c fd ff ff       	call   800c24 <sys_page_unmap>
	if (r < 0) {
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	79 12                	jns    800ec1 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eaf:	50                   	push   %eax
  800eb0:	68 65 28 80 00       	push   $0x802865
  800eb5:	6a 38                	push   $0x38
  800eb7:	68 5a 28 80 00       	push   $0x80285a
  800ebc:	e8 4e 12 00 00       	call   80210f <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ec1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ecf:	68 f0 0d 80 00       	push   $0x800df0
  800ed4:	e8 7c 12 00 00       	call   802155 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ede:	cd 30                	int    $0x30
  800ee0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 17                	jns    800f01 <fork+0x3b>
		panic("fork fault %e");
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	68 7e 28 80 00       	push   $0x80287e
  800ef2:	68 85 00 00 00       	push   $0x85
  800ef7:	68 5a 28 80 00       	push   $0x80285a
  800efc:	e8 0e 12 00 00       	call   80210f <_panic>
  800f01:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f07:	75 24                	jne    800f2d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f09:	e8 53 fc ff ff       	call   800b61 <sys_getenvid>
  800f0e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f13:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800f19:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1e:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	e9 64 01 00 00       	jmp    801091 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	6a 07                	push   $0x7
  800f32:	68 00 f0 bf ee       	push   $0xeebff000
  800f37:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3a:	e8 60 fc ff ff       	call   800b9f <sys_page_alloc>
  800f3f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f47:	89 d8                	mov    %ebx,%eax
  800f49:	c1 e8 16             	shr    $0x16,%eax
  800f4c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f53:	a8 01                	test   $0x1,%al
  800f55:	0f 84 fc 00 00 00    	je     801057 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f5b:	89 d8                	mov    %ebx,%eax
  800f5d:	c1 e8 0c             	shr    $0xc,%eax
  800f60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	0f 84 e7 00 00 00    	je     801057 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f70:	89 c6                	mov    %eax,%esi
  800f72:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7c:	f6 c6 04             	test   $0x4,%dh
  800f7f:	74 39                	je     800fba <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f90:	50                   	push   %eax
  800f91:	56                   	push   %esi
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	6a 00                	push   $0x0
  800f96:	e8 47 fc ff ff       	call   800be2 <sys_page_map>
		if (r < 0) {
  800f9b:	83 c4 20             	add    $0x20,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	0f 89 b1 00 00 00    	jns    801057 <fork+0x191>
		    	panic("sys page map fault %e");
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	68 8c 28 80 00       	push   $0x80288c
  800fae:	6a 55                	push   $0x55
  800fb0:	68 5a 28 80 00       	push   $0x80285a
  800fb5:	e8 55 11 00 00       	call   80210f <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc1:	f6 c2 02             	test   $0x2,%dl
  800fc4:	75 0c                	jne    800fd2 <fork+0x10c>
  800fc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcd:	f6 c4 08             	test   $0x8,%ah
  800fd0:	74 5b                	je     80102d <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	68 05 08 00 00       	push   $0x805
  800fda:	56                   	push   %esi
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	6a 00                	push   $0x0
  800fdf:	e8 fe fb ff ff       	call   800be2 <sys_page_map>
		if (r < 0) {
  800fe4:	83 c4 20             	add    $0x20,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 14                	jns    800fff <fork+0x139>
		    	panic("sys page map fault %e");
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	68 8c 28 80 00       	push   $0x80288c
  800ff3:	6a 5c                	push   $0x5c
  800ff5:	68 5a 28 80 00       	push   $0x80285a
  800ffa:	e8 10 11 00 00       	call   80210f <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	68 05 08 00 00       	push   $0x805
  801007:	56                   	push   %esi
  801008:	6a 00                	push   $0x0
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	e8 d0 fb ff ff       	call   800be2 <sys_page_map>
		if (r < 0) {
  801012:	83 c4 20             	add    $0x20,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 3e                	jns    801057 <fork+0x191>
		    	panic("sys page map fault %e");
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	68 8c 28 80 00       	push   $0x80288c
  801021:	6a 60                	push   $0x60
  801023:	68 5a 28 80 00       	push   $0x80285a
  801028:	e8 e2 10 00 00       	call   80210f <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	6a 05                	push   $0x5
  801032:	56                   	push   %esi
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	6a 00                	push   $0x0
  801037:	e8 a6 fb ff ff       	call   800be2 <sys_page_map>
		if (r < 0) {
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 14                	jns    801057 <fork+0x191>
		    	panic("sys page map fault %e");
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	68 8c 28 80 00       	push   $0x80288c
  80104b:	6a 65                	push   $0x65
  80104d:	68 5a 28 80 00       	push   $0x80285a
  801052:	e8 b8 10 00 00       	call   80210f <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801057:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80105d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801063:	0f 85 de fe ff ff    	jne    800f47 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801069:	a1 08 40 80 00       	mov    0x804008,%eax
  80106e:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	50                   	push   %eax
  801078:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80107b:	57                   	push   %edi
  80107c:	e8 69 fc ff ff       	call   800cea <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801081:	83 c4 08             	add    $0x8,%esp
  801084:	6a 02                	push   $0x2
  801086:	57                   	push   %edi
  801087:	e8 da fb ff ff       	call   800c66 <sys_env_set_status>
	
	return envid;
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sfork>:

envid_t
sfork(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	a3 0c 40 80 00       	mov    %eax,0x80400c
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010b1:	68 4a 01 80 00       	push   $0x80014a
  8010b6:	e8 d5 fc ff ff       	call   800d90 <sys_thread_create>

	return id;
}
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010c3:	ff 75 08             	pushl  0x8(%ebp)
  8010c6:	e8 e5 fc ff ff       	call   800db0 <sys_thread_free>
}
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010d6:	ff 75 08             	pushl  0x8(%ebp)
  8010d9:	e8 f2 fc ff ff       	call   800dd0 <sys_thread_join>
}
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	6a 07                	push   $0x7
  8010f3:	6a 00                	push   $0x0
  8010f5:	56                   	push   %esi
  8010f6:	e8 a4 fa ff ff       	call   800b9f <sys_page_alloc>
	if (r < 0) {
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	79 15                	jns    801117 <queue_append+0x34>
		panic("%e\n", r);
  801102:	50                   	push   %eax
  801103:	68 d2 28 80 00       	push   $0x8028d2
  801108:	68 d5 00 00 00       	push   $0xd5
  80110d:	68 5a 28 80 00       	push   $0x80285a
  801112:	e8 f8 0f 00 00       	call   80210f <_panic>
	}	

	wt->envid = envid;
  801117:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80111d:	83 3b 00             	cmpl   $0x0,(%ebx)
  801120:	75 13                	jne    801135 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801122:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801129:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801130:	00 00 00 
  801133:	eb 1b                	jmp    801150 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801135:	8b 43 04             	mov    0x4(%ebx),%eax
  801138:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80113f:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801146:	00 00 00 
		queue->last = wt;
  801149:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801160:	8b 02                	mov    (%edx),%eax
  801162:	85 c0                	test   %eax,%eax
  801164:	75 17                	jne    80117d <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	68 a2 28 80 00       	push   $0x8028a2
  80116e:	68 ec 00 00 00       	push   $0xec
  801173:	68 5a 28 80 00       	push   $0x80285a
  801178:	e8 92 0f 00 00       	call   80210f <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80117d:	8b 48 04             	mov    0x4(%eax),%ecx
  801180:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801182:	8b 00                	mov    (%eax),%eax
}
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80118e:	b8 01 00 00 00       	mov    $0x1,%eax
  801193:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801196:	85 c0                	test   %eax,%eax
  801198:	74 4a                	je     8011e4 <mutex_lock+0x5e>
  80119a:	8b 73 04             	mov    0x4(%ebx),%esi
  80119d:	83 3e 00             	cmpl   $0x0,(%esi)
  8011a0:	75 42                	jne    8011e4 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  8011a2:	e8 ba f9 ff ff       	call   800b61 <sys_getenvid>
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	56                   	push   %esi
  8011ab:	50                   	push   %eax
  8011ac:	e8 32 ff ff ff       	call   8010e3 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011b1:	e8 ab f9 ff ff       	call   800b61 <sys_getenvid>
  8011b6:	83 c4 08             	add    $0x8,%esp
  8011b9:	6a 04                	push   $0x4
  8011bb:	50                   	push   %eax
  8011bc:	e8 a5 fa ff ff       	call   800c66 <sys_env_set_status>

		if (r < 0) {
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	79 15                	jns    8011dd <mutex_lock+0x57>
			panic("%e\n", r);
  8011c8:	50                   	push   %eax
  8011c9:	68 d2 28 80 00       	push   $0x8028d2
  8011ce:	68 02 01 00 00       	push   $0x102
  8011d3:	68 5a 28 80 00       	push   $0x80285a
  8011d8:	e8 32 0f 00 00       	call   80210f <_panic>
		}
		sys_yield();
  8011dd:	e8 9e f9 ff ff       	call   800b80 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011e2:	eb 08                	jmp    8011ec <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8011e4:	e8 78 f9 ff ff       	call   800b61 <sys_getenvid>
  8011e9:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8011ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801205:	8b 43 04             	mov    0x4(%ebx),%eax
  801208:	83 38 00             	cmpl   $0x0,(%eax)
  80120b:	74 33                	je     801240 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	50                   	push   %eax
  801211:	e8 41 ff ff ff       	call   801157 <queue_pop>
  801216:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	6a 02                	push   $0x2
  80121e:	50                   	push   %eax
  80121f:	e8 42 fa ff ff       	call   800c66 <sys_env_set_status>
		if (r < 0) {
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 15                	jns    801240 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80122b:	50                   	push   %eax
  80122c:	68 d2 28 80 00       	push   $0x8028d2
  801231:	68 16 01 00 00       	push   $0x116
  801236:	68 5a 28 80 00       	push   $0x80285a
  80123b:	e8 cf 0e 00 00       	call   80210f <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	53                   	push   %ebx
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80124f:	e8 0d f9 ff ff       	call   800b61 <sys_getenvid>
  801254:	83 ec 04             	sub    $0x4,%esp
  801257:	6a 07                	push   $0x7
  801259:	53                   	push   %ebx
  80125a:	50                   	push   %eax
  80125b:	e8 3f f9 ff ff       	call   800b9f <sys_page_alloc>
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	79 15                	jns    80127c <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801267:	50                   	push   %eax
  801268:	68 bd 28 80 00       	push   $0x8028bd
  80126d:	68 22 01 00 00       	push   $0x122
  801272:	68 5a 28 80 00       	push   $0x80285a
  801277:	e8 93 0e 00 00       	call   80210f <_panic>
	}	
	mtx->locked = 0;
  80127c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801282:	8b 43 04             	mov    0x4(%ebx),%eax
  801285:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80128b:	8b 43 04             	mov    0x4(%ebx),%eax
  80128e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801295:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 04             	sub    $0x4,%esp
  8012a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  8012ab:	eb 21                	jmp    8012ce <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	50                   	push   %eax
  8012b1:	e8 a1 fe ff ff       	call   801157 <queue_pop>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	6a 02                	push   $0x2
  8012bb:	50                   	push   %eax
  8012bc:	e8 a5 f9 ff ff       	call   800c66 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8012c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c4:	8b 10                	mov    (%eax),%edx
  8012c6:	8b 52 04             	mov    0x4(%edx),%edx
  8012c9:	89 10                	mov    %edx,(%eax)
  8012cb:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8012ce:	8b 43 04             	mov    0x4(%ebx),%eax
  8012d1:	83 38 00             	cmpl   $0x0,(%eax)
  8012d4:	75 d7                	jne    8012ad <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012d6:	83 ec 04             	sub    $0x4,%esp
  8012d9:	68 00 10 00 00       	push   $0x1000
  8012de:	6a 00                	push   $0x0
  8012e0:	53                   	push   %ebx
  8012e1:	e8 fb f5 ff ff       	call   8008e1 <memset>
	mtx = NULL;
}
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
  8012f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	75 12                	jne    801312 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801300:	83 ec 0c             	sub    $0xc,%esp
  801303:	68 00 00 c0 ee       	push   $0xeec00000
  801308:	e8 42 fa ff ff       	call   800d4f <sys_ipc_recv>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	eb 0c                	jmp    80131e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	50                   	push   %eax
  801316:	e8 34 fa ff ff       	call   800d4f <sys_ipc_recv>
  80131b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80131e:	85 f6                	test   %esi,%esi
  801320:	0f 95 c1             	setne  %cl
  801323:	85 db                	test   %ebx,%ebx
  801325:	0f 95 c2             	setne  %dl
  801328:	84 d1                	test   %dl,%cl
  80132a:	74 09                	je     801335 <ipc_recv+0x47>
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	c1 ea 1f             	shr    $0x1f,%edx
  801331:	84 d2                	test   %dl,%dl
  801333:	75 2d                	jne    801362 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801335:	85 f6                	test   %esi,%esi
  801337:	74 0d                	je     801346 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801339:	a1 08 40 80 00       	mov    0x804008,%eax
  80133e:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  801344:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801346:	85 db                	test   %ebx,%ebx
  801348:	74 0d                	je     801357 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80134a:	a1 08 40 80 00       	mov    0x804008,%eax
  80134f:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801355:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801357:	a1 08 40 80 00       	mov    0x804008,%eax
  80135c:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  801362:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    

00801369 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	57                   	push   %edi
  80136d:	56                   	push   %esi
  80136e:	53                   	push   %ebx
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	8b 7d 08             	mov    0x8(%ebp),%edi
  801375:	8b 75 0c             	mov    0xc(%ebp),%esi
  801378:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80137b:	85 db                	test   %ebx,%ebx
  80137d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801382:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801385:	ff 75 14             	pushl  0x14(%ebp)
  801388:	53                   	push   %ebx
  801389:	56                   	push   %esi
  80138a:	57                   	push   %edi
  80138b:	e8 9c f9 ff ff       	call   800d2c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801390:	89 c2                	mov    %eax,%edx
  801392:	c1 ea 1f             	shr    $0x1f,%edx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	84 d2                	test   %dl,%dl
  80139a:	74 17                	je     8013b3 <ipc_send+0x4a>
  80139c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80139f:	74 12                	je     8013b3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8013a1:	50                   	push   %eax
  8013a2:	68 d6 28 80 00       	push   $0x8028d6
  8013a7:	6a 47                	push   $0x47
  8013a9:	68 e4 28 80 00       	push   $0x8028e4
  8013ae:	e8 5c 0d 00 00       	call   80210f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8013b3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013b6:	75 07                	jne    8013bf <ipc_send+0x56>
			sys_yield();
  8013b8:	e8 c3 f7 ff ff       	call   800b80 <sys_yield>
  8013bd:	eb c6                	jmp    801385 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	75 c2                	jne    801385 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013d6:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8013dc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013e2:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8013e8:	39 ca                	cmp    %ecx,%edx
  8013ea:	75 13                	jne    8013ff <ipc_find_env+0x34>
			return envs[i].env_id;
  8013ec:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8013f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013f7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013fd:	eb 0f                	jmp    80140e <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013ff:	83 c0 01             	add    $0x1,%eax
  801402:	3d 00 04 00 00       	cmp    $0x400,%eax
  801407:	75 cd                	jne    8013d6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
  801416:	05 00 00 00 30       	add    $0x30000000,%eax
  80141b:	c1 e8 0c             	shr    $0xc,%eax
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	05 00 00 00 30       	add    $0x30000000,%eax
  80142b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801430:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 16             	shr    $0x16,%edx
  801447:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 11                	je     801464 <fd_alloc+0x2d>
  801453:	89 c2                	mov    %eax,%edx
  801455:	c1 ea 0c             	shr    $0xc,%edx
  801458:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145f:	f6 c2 01             	test   $0x1,%dl
  801462:	75 09                	jne    80146d <fd_alloc+0x36>
			*fd_store = fd;
  801464:	89 01                	mov    %eax,(%ecx)
			return 0;
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	eb 17                	jmp    801484 <fd_alloc+0x4d>
  80146d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801472:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801477:	75 c9                	jne    801442 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801479:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80147f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80148c:	83 f8 1f             	cmp    $0x1f,%eax
  80148f:	77 36                	ja     8014c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801491:	c1 e0 0c             	shl    $0xc,%eax
  801494:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 16             	shr    $0x16,%edx
  80149e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a5:	f6 c2 01             	test   $0x1,%dl
  8014a8:	74 24                	je     8014ce <fd_lookup+0x48>
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 0c             	shr    $0xc,%edx
  8014af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	74 1a                	je     8014d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014be:	89 02                	mov    %eax,(%edx)
	return 0;
  8014c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c5:	eb 13                	jmp    8014da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cc:	eb 0c                	jmp    8014da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb 05                	jmp    8014da <fd_lookup+0x54>
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e5:	ba 6c 29 80 00       	mov    $0x80296c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ea:	eb 13                	jmp    8014ff <dev_lookup+0x23>
  8014ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014ef:	39 08                	cmp    %ecx,(%eax)
  8014f1:	75 0c                	jne    8014ff <dev_lookup+0x23>
			*dev = devtab[i];
  8014f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fd:	eb 31                	jmp    801530 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ff:	8b 02                	mov    (%edx),%eax
  801501:	85 c0                	test   %eax,%eax
  801503:	75 e7                	jne    8014ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801505:	a1 08 40 80 00       	mov    0x804008,%eax
  80150a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	51                   	push   %ecx
  801514:	50                   	push   %eax
  801515:	68 f0 28 80 00       	push   $0x8028f0
  80151a:	e8 f8 ec ff ff       	call   800217 <cprintf>
	*dev = 0;
  80151f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801522:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	56                   	push   %esi
  801536:	53                   	push   %ebx
  801537:	83 ec 10             	sub    $0x10,%esp
  80153a:	8b 75 08             	mov    0x8(%ebp),%esi
  80153d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80154a:	c1 e8 0c             	shr    $0xc,%eax
  80154d:	50                   	push   %eax
  80154e:	e8 33 ff ff ff       	call   801486 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 05                	js     80155f <fd_close+0x2d>
	    || fd != fd2)
  80155a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80155d:	74 0c                	je     80156b <fd_close+0x39>
		return (must_exist ? r : 0);
  80155f:	84 db                	test   %bl,%bl
  801561:	ba 00 00 00 00       	mov    $0x0,%edx
  801566:	0f 44 c2             	cmove  %edx,%eax
  801569:	eb 41                	jmp    8015ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 36                	pushl  (%esi)
  801574:	e8 63 ff ff ff       	call   8014dc <dev_lookup>
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 1a                	js     80159c <fd_close+0x6a>
		if (dev->dev_close)
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801588:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	74 0b                	je     80159c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	56                   	push   %esi
  801595:	ff d0                	call   *%eax
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	56                   	push   %esi
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 7d f6 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	89 d8                	mov    %ebx,%eax
}
  8015ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	ff 75 08             	pushl  0x8(%ebp)
  8015c0:	e8 c1 fe ff ff       	call   801486 <fd_lookup>
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 10                	js     8015dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	6a 01                	push   $0x1
  8015d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d4:	e8 59 ff ff ff       	call   801532 <fd_close>
  8015d9:	83 c4 10             	add    $0x10,%esp
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <close_all>:

void
close_all(void)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	e8 c0 ff ff ff       	call   8015b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f3:	83 c3 01             	add    $0x1,%ebx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	83 fb 20             	cmp    $0x20,%ebx
  8015fc:	75 ec                	jne    8015ea <close_all+0xc>
		close(i);
}
  8015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	57                   	push   %edi
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 2c             	sub    $0x2c,%esp
  80160c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80160f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	ff 75 08             	pushl  0x8(%ebp)
  801616:	e8 6b fe ff ff       	call   801486 <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	0f 88 c1 00 00 00    	js     8016e7 <dup+0xe4>
		return r;
	close(newfdnum);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	56                   	push   %esi
  80162a:	e8 84 ff ff ff       	call   8015b3 <close>

	newfd = INDEX2FD(newfdnum);
  80162f:	89 f3                	mov    %esi,%ebx
  801631:	c1 e3 0c             	shl    $0xc,%ebx
  801634:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80163a:	83 c4 04             	add    $0x4,%esp
  80163d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801640:	e8 db fd ff ff       	call   801420 <fd2data>
  801645:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801647:	89 1c 24             	mov    %ebx,(%esp)
  80164a:	e8 d1 fd ff ff       	call   801420 <fd2data>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801655:	89 f8                	mov    %edi,%eax
  801657:	c1 e8 16             	shr    $0x16,%eax
  80165a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801661:	a8 01                	test   $0x1,%al
  801663:	74 37                	je     80169c <dup+0x99>
  801665:	89 f8                	mov    %edi,%eax
  801667:	c1 e8 0c             	shr    $0xc,%eax
  80166a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801671:	f6 c2 01             	test   $0x1,%dl
  801674:	74 26                	je     80169c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801676:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	25 07 0e 00 00       	and    $0xe07,%eax
  801685:	50                   	push   %eax
  801686:	ff 75 d4             	pushl  -0x2c(%ebp)
  801689:	6a 00                	push   $0x0
  80168b:	57                   	push   %edi
  80168c:	6a 00                	push   $0x0
  80168e:	e8 4f f5 ff ff       	call   800be2 <sys_page_map>
  801693:	89 c7                	mov    %eax,%edi
  801695:	83 c4 20             	add    $0x20,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 2e                	js     8016ca <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169f:	89 d0                	mov    %edx,%eax
  8016a1:	c1 e8 0c             	shr    $0xc,%eax
  8016a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b3:	50                   	push   %eax
  8016b4:	53                   	push   %ebx
  8016b5:	6a 00                	push   $0x0
  8016b7:	52                   	push   %edx
  8016b8:	6a 00                	push   $0x0
  8016ba:	e8 23 f5 ff ff       	call   800be2 <sys_page_map>
  8016bf:	89 c7                	mov    %eax,%edi
  8016c1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016c4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c6:	85 ff                	test   %edi,%edi
  8016c8:	79 1d                	jns    8016e7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	6a 00                	push   $0x0
  8016d0:	e8 4f f5 ff ff       	call   800c24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d5:	83 c4 08             	add    $0x8,%esp
  8016d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 42 f5 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	89 f8                	mov    %edi,%eax
}
  8016e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5f                   	pop    %edi
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 14             	sub    $0x14,%esp
  8016f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	53                   	push   %ebx
  8016fe:	e8 83 fd ff ff       	call   801486 <fd_lookup>
  801703:	83 c4 08             	add    $0x8,%esp
  801706:	89 c2                	mov    %eax,%edx
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 70                	js     80177c <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	ff 30                	pushl  (%eax)
  801718:	e8 bf fd ff ff       	call   8014dc <dev_lookup>
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	78 4f                	js     801773 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801724:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801727:	8b 42 08             	mov    0x8(%edx),%eax
  80172a:	83 e0 03             	and    $0x3,%eax
  80172d:	83 f8 01             	cmp    $0x1,%eax
  801730:	75 24                	jne    801756 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801732:	a1 08 40 80 00       	mov    0x804008,%eax
  801737:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	53                   	push   %ebx
  801741:	50                   	push   %eax
  801742:	68 31 29 80 00       	push   $0x802931
  801747:	e8 cb ea ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801754:	eb 26                	jmp    80177c <read+0x8d>
	}
	if (!dev->dev_read)
  801756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801759:	8b 40 08             	mov    0x8(%eax),%eax
  80175c:	85 c0                	test   %eax,%eax
  80175e:	74 17                	je     801777 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801760:	83 ec 04             	sub    $0x4,%esp
  801763:	ff 75 10             	pushl  0x10(%ebp)
  801766:	ff 75 0c             	pushl  0xc(%ebp)
  801769:	52                   	push   %edx
  80176a:	ff d0                	call   *%eax
  80176c:	89 c2                	mov    %eax,%edx
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	eb 09                	jmp    80177c <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801773:	89 c2                	mov    %eax,%edx
  801775:	eb 05                	jmp    80177c <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801777:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80177c:	89 d0                	mov    %edx,%eax
  80177e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	57                   	push   %edi
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	83 ec 0c             	sub    $0xc,%esp
  80178c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80178f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801792:	bb 00 00 00 00       	mov    $0x0,%ebx
  801797:	eb 21                	jmp    8017ba <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801799:	83 ec 04             	sub    $0x4,%esp
  80179c:	89 f0                	mov    %esi,%eax
  80179e:	29 d8                	sub    %ebx,%eax
  8017a0:	50                   	push   %eax
  8017a1:	89 d8                	mov    %ebx,%eax
  8017a3:	03 45 0c             	add    0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	57                   	push   %edi
  8017a8:	e8 42 ff ff ff       	call   8016ef <read>
		if (m < 0)
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 10                	js     8017c4 <readn+0x41>
			return m;
		if (m == 0)
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	74 0a                	je     8017c2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b8:	01 c3                	add    %eax,%ebx
  8017ba:	39 f3                	cmp    %esi,%ebx
  8017bc:	72 db                	jb     801799 <readn+0x16>
  8017be:	89 d8                	mov    %ebx,%eax
  8017c0:	eb 02                	jmp    8017c4 <readn+0x41>
  8017c2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5f                   	pop    %edi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 14             	sub    $0x14,%esp
  8017d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	53                   	push   %ebx
  8017db:	e8 a6 fc ff ff       	call   801486 <fd_lookup>
  8017e0:	83 c4 08             	add    $0x8,%esp
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 6b                	js     801854 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ef:	50                   	push   %eax
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	ff 30                	pushl  (%eax)
  8017f5:	e8 e2 fc ff ff       	call   8014dc <dev_lookup>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 4a                	js     80184b <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801808:	75 24                	jne    80182e <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80180a:	a1 08 40 80 00       	mov    0x804008,%eax
  80180f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801815:	83 ec 04             	sub    $0x4,%esp
  801818:	53                   	push   %ebx
  801819:	50                   	push   %eax
  80181a:	68 4d 29 80 00       	push   $0x80294d
  80181f:	e8 f3 e9 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182c:	eb 26                	jmp    801854 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80182e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801831:	8b 52 0c             	mov    0xc(%edx),%edx
  801834:	85 d2                	test   %edx,%edx
  801836:	74 17                	je     80184f <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801838:	83 ec 04             	sub    $0x4,%esp
  80183b:	ff 75 10             	pushl  0x10(%ebp)
  80183e:	ff 75 0c             	pushl  0xc(%ebp)
  801841:	50                   	push   %eax
  801842:	ff d2                	call   *%edx
  801844:	89 c2                	mov    %eax,%edx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	eb 09                	jmp    801854 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	eb 05                	jmp    801854 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80184f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801854:	89 d0                	mov    %edx,%eax
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <seek>:

int
seek(int fdnum, off_t offset)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801861:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	ff 75 08             	pushl  0x8(%ebp)
  801868:	e8 19 fc ff ff       	call   801486 <fd_lookup>
  80186d:	83 c4 08             	add    $0x8,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	78 0e                	js     801882 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801874:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80187d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	53                   	push   %ebx
  801888:	83 ec 14             	sub    $0x14,%esp
  80188b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801891:	50                   	push   %eax
  801892:	53                   	push   %ebx
  801893:	e8 ee fb ff ff       	call   801486 <fd_lookup>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 68                	js     801909 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a7:	50                   	push   %eax
  8018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ab:	ff 30                	pushl  (%eax)
  8018ad:	e8 2a fc ff ff       	call   8014dc <dev_lookup>
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 47                	js     801900 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c0:	75 24                	jne    8018e6 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c2:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	53                   	push   %ebx
  8018d1:	50                   	push   %eax
  8018d2:	68 10 29 80 00       	push   $0x802910
  8018d7:	e8 3b e9 ff ff       	call   800217 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e4:	eb 23                	jmp    801909 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e9:	8b 52 18             	mov    0x18(%edx),%edx
  8018ec:	85 d2                	test   %edx,%edx
  8018ee:	74 14                	je     801904 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	50                   	push   %eax
  8018f7:	ff d2                	call   *%edx
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb 09                	jmp    801909 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801900:	89 c2                	mov    %eax,%edx
  801902:	eb 05                	jmp    801909 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801904:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801909:	89 d0                	mov    %edx,%eax
  80190b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	53                   	push   %ebx
  801914:	83 ec 14             	sub    $0x14,%esp
  801917:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191d:	50                   	push   %eax
  80191e:	ff 75 08             	pushl  0x8(%ebp)
  801921:	e8 60 fb ff ff       	call   801486 <fd_lookup>
  801926:	83 c4 08             	add    $0x8,%esp
  801929:	89 c2                	mov    %eax,%edx
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 58                	js     801987 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801935:	50                   	push   %eax
  801936:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801939:	ff 30                	pushl  (%eax)
  80193b:	e8 9c fb ff ff       	call   8014dc <dev_lookup>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	78 37                	js     80197e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80194e:	74 32                	je     801982 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801950:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801953:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195a:	00 00 00 
	stat->st_isdir = 0;
  80195d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801964:	00 00 00 
	stat->st_dev = dev;
  801967:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	53                   	push   %ebx
  801971:	ff 75 f0             	pushl  -0x10(%ebp)
  801974:	ff 50 14             	call   *0x14(%eax)
  801977:	89 c2                	mov    %eax,%edx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	eb 09                	jmp    801987 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197e:	89 c2                	mov    %eax,%edx
  801980:	eb 05                	jmp    801987 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801982:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801987:	89 d0                	mov    %edx,%eax
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	6a 00                	push   $0x0
  801998:	ff 75 08             	pushl  0x8(%ebp)
  80199b:	e8 e3 01 00 00       	call   801b83 <open>
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 1b                	js     8019c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	ff 75 0c             	pushl  0xc(%ebp)
  8019af:	50                   	push   %eax
  8019b0:	e8 5b ff ff ff       	call   801910 <fstat>
  8019b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b7:	89 1c 24             	mov    %ebx,(%esp)
  8019ba:	e8 f4 fb ff ff       	call   8015b3 <close>
	return r;
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	89 f0                	mov    %esi,%eax
}
  8019c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	89 c6                	mov    %eax,%esi
  8019d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019db:	75 12                	jne    8019ef <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019dd:	83 ec 0c             	sub    $0xc,%esp
  8019e0:	6a 01                	push   $0x1
  8019e2:	e8 e4 f9 ff ff       	call   8013cb <ipc_find_env>
  8019e7:	a3 00 40 80 00       	mov    %eax,0x804000
  8019ec:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ef:	6a 07                	push   $0x7
  8019f1:	68 00 50 80 00       	push   $0x805000
  8019f6:	56                   	push   %esi
  8019f7:	ff 35 00 40 80 00    	pushl  0x804000
  8019fd:	e8 67 f9 ff ff       	call   801369 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a02:	83 c4 0c             	add    $0xc,%esp
  801a05:	6a 00                	push   $0x0
  801a07:	53                   	push   %ebx
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 df f8 ff ff       	call   8012ee <ipc_recv>
}
  801a0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	5d                   	pop    %ebp
  801a15:	c3                   	ret    

00801a16 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a34:	b8 02 00 00 00       	mov    $0x2,%eax
  801a39:	e8 8d ff ff ff       	call   8019cb <fsipc>
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a46:	8b 45 08             	mov    0x8(%ebp),%eax
  801a49:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a51:	ba 00 00 00 00       	mov    $0x0,%edx
  801a56:	b8 06 00 00 00       	mov    $0x6,%eax
  801a5b:	e8 6b ff ff ff       	call   8019cb <fsipc>
}
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	53                   	push   %ebx
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a72:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a77:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a81:	e8 45 ff ff ff       	call   8019cb <fsipc>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 2c                	js     801ab6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	68 00 50 80 00       	push   $0x805000
  801a92:	53                   	push   %ebx
  801a93:	e8 04 ed ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a98:	a1 80 50 80 00       	mov    0x805080,%eax
  801a9d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa3:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac7:	8b 52 0c             	mov    0xc(%edx),%edx
  801aca:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ad0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ad5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ada:	0f 47 c2             	cmova  %edx,%eax
  801add:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ae2:	50                   	push   %eax
  801ae3:	ff 75 0c             	pushl  0xc(%ebp)
  801ae6:	68 08 50 80 00       	push   $0x805008
  801aeb:	e8 3e ee ff ff       	call   80092e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	b8 04 00 00 00       	mov    $0x4,%eax
  801afa:	e8 cc fe ff ff       	call   8019cb <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b14:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b24:	e8 a2 fe ff ff       	call   8019cb <fsipc>
  801b29:	89 c3                	mov    %eax,%ebx
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 4b                	js     801b7a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b2f:	39 c6                	cmp    %eax,%esi
  801b31:	73 16                	jae    801b49 <devfile_read+0x48>
  801b33:	68 7c 29 80 00       	push   $0x80297c
  801b38:	68 83 29 80 00       	push   $0x802983
  801b3d:	6a 7c                	push   $0x7c
  801b3f:	68 98 29 80 00       	push   $0x802998
  801b44:	e8 c6 05 00 00       	call   80210f <_panic>
	assert(r <= PGSIZE);
  801b49:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4e:	7e 16                	jle    801b66 <devfile_read+0x65>
  801b50:	68 a3 29 80 00       	push   $0x8029a3
  801b55:	68 83 29 80 00       	push   $0x802983
  801b5a:	6a 7d                	push   $0x7d
  801b5c:	68 98 29 80 00       	push   $0x802998
  801b61:	e8 a9 05 00 00       	call   80210f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	50                   	push   %eax
  801b6a:	68 00 50 80 00       	push   $0x805000
  801b6f:	ff 75 0c             	pushl  0xc(%ebp)
  801b72:	e8 b7 ed ff ff       	call   80092e <memmove>
	return r;
  801b77:	83 c4 10             	add    $0x10,%esp
}
  801b7a:	89 d8                	mov    %ebx,%eax
  801b7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 20             	sub    $0x20,%esp
  801b8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b8d:	53                   	push   %ebx
  801b8e:	e8 d0 eb ff ff       	call   800763 <strlen>
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b9b:	7f 67                	jg     801c04 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 8e f8 ff ff       	call   801437 <fd_alloc>
  801ba9:	83 c4 10             	add    $0x10,%esp
		return r;
  801bac:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 57                	js     801c09 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	53                   	push   %ebx
  801bb6:	68 00 50 80 00       	push   $0x805000
  801bbb:	e8 dc eb ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcb:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd0:	e8 f6 fd ff ff       	call   8019cb <fsipc>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	79 14                	jns    801bf2 <open+0x6f>
		fd_close(fd, 0);
  801bde:	83 ec 08             	sub    $0x8,%esp
  801be1:	6a 00                	push   $0x0
  801be3:	ff 75 f4             	pushl  -0xc(%ebp)
  801be6:	e8 47 f9 ff ff       	call   801532 <fd_close>
		return r;
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	89 da                	mov    %ebx,%edx
  801bf0:	eb 17                	jmp    801c09 <open+0x86>
	}

	return fd2num(fd);
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf8:	e8 13 f8 ff ff       	call   801410 <fd2num>
  801bfd:	89 c2                	mov    %eax,%edx
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	eb 05                	jmp    801c09 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c04:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c09:	89 d0                	mov    %edx,%eax
  801c0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0e:	c9                   	leave  
  801c0f:	c3                   	ret    

00801c10 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c16:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c20:	e8 a6 fd ff ff       	call   8019cb <fsipc>
}
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c2f:	83 ec 0c             	sub    $0xc,%esp
  801c32:	ff 75 08             	pushl  0x8(%ebp)
  801c35:	e8 e6 f7 ff ff       	call   801420 <fd2data>
  801c3a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c3c:	83 c4 08             	add    $0x8,%esp
  801c3f:	68 af 29 80 00       	push   $0x8029af
  801c44:	53                   	push   %ebx
  801c45:	e8 52 eb ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c4a:	8b 46 04             	mov    0x4(%esi),%eax
  801c4d:	2b 06                	sub    (%esi),%eax
  801c4f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c55:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c5c:	00 00 00 
	stat->st_dev = &devpipe;
  801c5f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c66:	30 80 00 
	return 0;
}
  801c69:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c7f:	53                   	push   %ebx
  801c80:	6a 00                	push   $0x0
  801c82:	e8 9d ef ff ff       	call   800c24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c87:	89 1c 24             	mov    %ebx,(%esp)
  801c8a:	e8 91 f7 ff ff       	call   801420 <fd2data>
  801c8f:	83 c4 08             	add    $0x8,%esp
  801c92:	50                   	push   %eax
  801c93:	6a 00                	push   $0x0
  801c95:	e8 8a ef ff ff       	call   800c24 <sys_page_unmap>
}
  801c9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	57                   	push   %edi
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	83 ec 1c             	sub    $0x1c,%esp
  801ca8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cab:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cad:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb2:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	ff 75 e0             	pushl  -0x20(%ebp)
  801cbe:	e8 21 05 00 00       	call   8021e4 <pageref>
  801cc3:	89 c3                	mov    %eax,%ebx
  801cc5:	89 3c 24             	mov    %edi,(%esp)
  801cc8:	e8 17 05 00 00       	call   8021e4 <pageref>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	39 c3                	cmp    %eax,%ebx
  801cd2:	0f 94 c1             	sete   %cl
  801cd5:	0f b6 c9             	movzbl %cl,%ecx
  801cd8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cdb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ce1:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801ce7:	39 ce                	cmp    %ecx,%esi
  801ce9:	74 1e                	je     801d09 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ceb:	39 c3                	cmp    %eax,%ebx
  801ced:	75 be                	jne    801cad <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cef:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801cf5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf8:	50                   	push   %eax
  801cf9:	56                   	push   %esi
  801cfa:	68 b6 29 80 00       	push   $0x8029b6
  801cff:	e8 13 e5 ff ff       	call   800217 <cprintf>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	eb a4                	jmp    801cad <_pipeisclosed+0xe>
	}
}
  801d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	83 ec 28             	sub    $0x28,%esp
  801d1d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d20:	56                   	push   %esi
  801d21:	e8 fa f6 ff ff       	call   801420 <fd2data>
  801d26:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d30:	eb 4b                	jmp    801d7d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d32:	89 da                	mov    %ebx,%edx
  801d34:	89 f0                	mov    %esi,%eax
  801d36:	e8 64 ff ff ff       	call   801c9f <_pipeisclosed>
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	75 48                	jne    801d87 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3f:	e8 3c ee ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d44:	8b 43 04             	mov    0x4(%ebx),%eax
  801d47:	8b 0b                	mov    (%ebx),%ecx
  801d49:	8d 51 20             	lea    0x20(%ecx),%edx
  801d4c:	39 d0                	cmp    %edx,%eax
  801d4e:	73 e2                	jae    801d32 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d53:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d57:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d5a:	89 c2                	mov    %eax,%edx
  801d5c:	c1 fa 1f             	sar    $0x1f,%edx
  801d5f:	89 d1                	mov    %edx,%ecx
  801d61:	c1 e9 1b             	shr    $0x1b,%ecx
  801d64:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d67:	83 e2 1f             	and    $0x1f,%edx
  801d6a:	29 ca                	sub    %ecx,%edx
  801d6c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d70:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d74:	83 c0 01             	add    $0x1,%eax
  801d77:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7a:	83 c7 01             	add    $0x1,%edi
  801d7d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d80:	75 c2                	jne    801d44 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d82:	8b 45 10             	mov    0x10(%ebp),%eax
  801d85:	eb 05                	jmp    801d8c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 18             	sub    $0x18,%esp
  801d9d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801da0:	57                   	push   %edi
  801da1:	e8 7a f6 ff ff       	call   801420 <fd2data>
  801da6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db0:	eb 3d                	jmp    801def <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801db2:	85 db                	test   %ebx,%ebx
  801db4:	74 04                	je     801dba <devpipe_read+0x26>
				return i;
  801db6:	89 d8                	mov    %ebx,%eax
  801db8:	eb 44                	jmp    801dfe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dba:	89 f2                	mov    %esi,%edx
  801dbc:	89 f8                	mov    %edi,%eax
  801dbe:	e8 dc fe ff ff       	call   801c9f <_pipeisclosed>
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	75 32                	jne    801df9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dc7:	e8 b4 ed ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dcc:	8b 06                	mov    (%esi),%eax
  801dce:	3b 46 04             	cmp    0x4(%esi),%eax
  801dd1:	74 df                	je     801db2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dd3:	99                   	cltd   
  801dd4:	c1 ea 1b             	shr    $0x1b,%edx
  801dd7:	01 d0                	add    %edx,%eax
  801dd9:	83 e0 1f             	and    $0x1f,%eax
  801ddc:	29 d0                	sub    %edx,%eax
  801dde:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801de9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dec:	83 c3 01             	add    $0x1,%ebx
  801def:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801df2:	75 d8                	jne    801dcc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801df4:	8b 45 10             	mov    0x10(%ebp),%eax
  801df7:	eb 05                	jmp    801dfe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e01:	5b                   	pop    %ebx
  801e02:	5e                   	pop    %esi
  801e03:	5f                   	pop    %edi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    

00801e06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	56                   	push   %esi
  801e0a:	53                   	push   %ebx
  801e0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e11:	50                   	push   %eax
  801e12:	e8 20 f6 ff ff       	call   801437 <fd_alloc>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 2c 01 00 00    	js     801f50 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e24:	83 ec 04             	sub    $0x4,%esp
  801e27:	68 07 04 00 00       	push   $0x407
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 69 ed ff ff       	call   800b9f <sys_page_alloc>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	89 c2                	mov    %eax,%edx
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	0f 88 0d 01 00 00    	js     801f50 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	e8 e8 f5 ff ff       	call   801437 <fd_alloc>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	0f 88 e2 00 00 00    	js     801f3e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	68 07 04 00 00       	push   $0x407
  801e64:	ff 75 f0             	pushl  -0x10(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 31 ed ff ff       	call   800b9f <sys_page_alloc>
  801e6e:	89 c3                	mov    %eax,%ebx
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 c3 00 00 00    	js     801f3e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e81:	e8 9a f5 ff ff       	call   801420 <fd2data>
  801e86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e88:	83 c4 0c             	add    $0xc,%esp
  801e8b:	68 07 04 00 00       	push   $0x407
  801e90:	50                   	push   %eax
  801e91:	6a 00                	push   $0x0
  801e93:	e8 07 ed ff ff       	call   800b9f <sys_page_alloc>
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 89 00 00 00    	js     801f2e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  801eab:	e8 70 f5 ff ff       	call   801420 <fd2data>
  801eb0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eb7:	50                   	push   %eax
  801eb8:	6a 00                	push   $0x0
  801eba:	56                   	push   %esi
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 20 ed ff ff       	call   800be2 <sys_page_map>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	83 c4 20             	add    $0x20,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 55                	js     801f20 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ecb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ee0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ef5:	83 ec 0c             	sub    $0xc,%esp
  801ef8:	ff 75 f4             	pushl  -0xc(%ebp)
  801efb:	e8 10 f5 ff ff       	call   801410 <fd2num>
  801f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f03:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f05:	83 c4 04             	add    $0x4,%esp
  801f08:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0b:	e8 00 f5 ff ff       	call   801410 <fd2num>
  801f10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f13:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1e:	eb 30                	jmp    801f50 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f20:	83 ec 08             	sub    $0x8,%esp
  801f23:	56                   	push   %esi
  801f24:	6a 00                	push   $0x0
  801f26:	e8 f9 ec ff ff       	call   800c24 <sys_page_unmap>
  801f2b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f2e:	83 ec 08             	sub    $0x8,%esp
  801f31:	ff 75 f0             	pushl  -0x10(%ebp)
  801f34:	6a 00                	push   $0x0
  801f36:	e8 e9 ec ff ff       	call   800c24 <sys_page_unmap>
  801f3b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	ff 75 f4             	pushl  -0xc(%ebp)
  801f44:	6a 00                	push   $0x0
  801f46:	e8 d9 ec ff ff       	call   800c24 <sys_page_unmap>
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f50:	89 d0                	mov    %edx,%eax
  801f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	ff 75 08             	pushl  0x8(%ebp)
  801f66:	e8 1b f5 ff ff       	call   801486 <fd_lookup>
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 18                	js     801f8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	ff 75 f4             	pushl  -0xc(%ebp)
  801f78:	e8 a3 f4 ff ff       	call   801420 <fd2data>
	return _pipeisclosed(fd, p);
  801f7d:	89 c2                	mov    %eax,%edx
  801f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f82:	e8 18 fd ff ff       	call   801c9f <_pipeisclosed>
  801f87:	83 c4 10             	add    $0x10,%esp
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f9c:	68 ce 29 80 00       	push   $0x8029ce
  801fa1:	ff 75 0c             	pushl  0xc(%ebp)
  801fa4:	e8 f3 e7 ff ff       	call   80079c <strcpy>
	return 0;
}
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	53                   	push   %ebx
  801fb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fbc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fc1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc7:	eb 2d                	jmp    801ff6 <devcons_write+0x46>
		m = n - tot;
  801fc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fcc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fd1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fd6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd9:	83 ec 04             	sub    $0x4,%esp
  801fdc:	53                   	push   %ebx
  801fdd:	03 45 0c             	add    0xc(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	57                   	push   %edi
  801fe2:	e8 47 e9 ff ff       	call   80092e <memmove>
		sys_cputs(buf, m);
  801fe7:	83 c4 08             	add    $0x8,%esp
  801fea:	53                   	push   %ebx
  801feb:	57                   	push   %edi
  801fec:	e8 f2 ea ff ff       	call   800ae3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff1:	01 de                	add    %ebx,%esi
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	89 f0                	mov    %esi,%eax
  801ff8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ffb:	72 cc                	jb     801fc9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 08             	sub    $0x8,%esp
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802010:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802014:	74 2a                	je     802040 <devcons_read+0x3b>
  802016:	eb 05                	jmp    80201d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802018:	e8 63 eb ff ff       	call   800b80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80201d:	e8 df ea ff ff       	call   800b01 <sys_cgetc>
  802022:	85 c0                	test   %eax,%eax
  802024:	74 f2                	je     802018 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802026:	85 c0                	test   %eax,%eax
  802028:	78 16                	js     802040 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80202a:	83 f8 04             	cmp    $0x4,%eax
  80202d:	74 0c                	je     80203b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80202f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802032:	88 02                	mov    %al,(%edx)
	return 1;
  802034:	b8 01 00 00 00       	mov    $0x1,%eax
  802039:	eb 05                	jmp    802040 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802048:	8b 45 08             	mov    0x8(%ebp),%eax
  80204b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80204e:	6a 01                	push   $0x1
  802050:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	e8 8a ea ff ff       	call   800ae3 <sys_cputs>
}
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <getchar>:

int
getchar(void)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802064:	6a 01                	push   $0x1
  802066:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	6a 00                	push   $0x0
  80206c:	e8 7e f6 ff ff       	call   8016ef <read>
	if (r < 0)
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	78 0f                	js     802087 <getchar+0x29>
		return r;
	if (r < 1)
  802078:	85 c0                	test   %eax,%eax
  80207a:	7e 06                	jle    802082 <getchar+0x24>
		return -E_EOF;
	return c;
  80207c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802080:	eb 05                	jmp    802087 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802082:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	ff 75 08             	pushl  0x8(%ebp)
  802096:	e8 eb f3 ff ff       	call   801486 <fd_lookup>
  80209b:	83 c4 10             	add    $0x10,%esp
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	78 11                	js     8020b3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ab:	39 10                	cmp    %edx,(%eax)
  8020ad:	0f 94 c0             	sete   %al
  8020b0:	0f b6 c0             	movzbl %al,%eax
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <opencons>:

int
opencons(void)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020be:	50                   	push   %eax
  8020bf:	e8 73 f3 ff ff       	call   801437 <fd_alloc>
  8020c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8020c7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 3e                	js     80210b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020cd:	83 ec 04             	sub    $0x4,%esp
  8020d0:	68 07 04 00 00       	push   $0x407
  8020d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 c0 ea ff ff       	call   800b9f <sys_page_alloc>
  8020df:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 23                	js     80210b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020fd:	83 ec 0c             	sub    $0xc,%esp
  802100:	50                   	push   %eax
  802101:	e8 0a f3 ff ff       	call   801410 <fd2num>
  802106:	89 c2                	mov    %eax,%edx
  802108:	83 c4 10             	add    $0x10,%esp
}
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	c9                   	leave  
  80210e:	c3                   	ret    

0080210f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802114:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802117:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80211d:	e8 3f ea ff ff       	call   800b61 <sys_getenvid>
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	ff 75 0c             	pushl  0xc(%ebp)
  802128:	ff 75 08             	pushl  0x8(%ebp)
  80212b:	56                   	push   %esi
  80212c:	50                   	push   %eax
  80212d:	68 dc 29 80 00       	push   $0x8029dc
  802132:	e8 e0 e0 ff ff       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802137:	83 c4 18             	add    $0x18,%esp
  80213a:	53                   	push   %ebx
  80213b:	ff 75 10             	pushl  0x10(%ebp)
  80213e:	e8 83 e0 ff ff       	call   8001c6 <vcprintf>
	cprintf("\n");
  802143:	c7 04 24 bb 28 80 00 	movl   $0x8028bb,(%esp)
  80214a:	e8 c8 e0 ff ff       	call   800217 <cprintf>
  80214f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802152:	cc                   	int3   
  802153:	eb fd                	jmp    802152 <_panic+0x43>

00802155 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80215b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802162:	75 2a                	jne    80218e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802164:	83 ec 04             	sub    $0x4,%esp
  802167:	6a 07                	push   $0x7
  802169:	68 00 f0 bf ee       	push   $0xeebff000
  80216e:	6a 00                	push   $0x0
  802170:	e8 2a ea ff ff       	call   800b9f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	79 12                	jns    80218e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80217c:	50                   	push   %eax
  80217d:	68 d2 28 80 00       	push   $0x8028d2
  802182:	6a 23                	push   $0x23
  802184:	68 00 2a 80 00       	push   $0x802a00
  802189:	e8 81 ff ff ff       	call   80210f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80218e:	8b 45 08             	mov    0x8(%ebp),%eax
  802191:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802196:	83 ec 08             	sub    $0x8,%esp
  802199:	68 c0 21 80 00       	push   $0x8021c0
  80219e:	6a 00                	push   $0x0
  8021a0:	e8 45 eb ff ff       	call   800cea <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021a5:	83 c4 10             	add    $0x10,%esp
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	79 12                	jns    8021be <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021ac:	50                   	push   %eax
  8021ad:	68 d2 28 80 00       	push   $0x8028d2
  8021b2:	6a 2c                	push   $0x2c
  8021b4:	68 00 2a 80 00       	push   $0x802a00
  8021b9:	e8 51 ff ff ff       	call   80210f <_panic>
	}
}
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021c1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021c8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021cb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021cf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021d4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021d8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021da:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021dd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021de:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8021e1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8021e2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021e3:	c3                   	ret    

008021e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	c1 e8 16             	shr    $0x16,%eax
  8021ef:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021fb:	f6 c1 01             	test   $0x1,%cl
  8021fe:	74 1d                	je     80221d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802200:	c1 ea 0c             	shr    $0xc,%edx
  802203:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80220a:	f6 c2 01             	test   $0x1,%dl
  80220d:	74 0e                	je     80221d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220f:	c1 ea 0c             	shr    $0xc,%edx
  802212:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802219:	ef 
  80221a:	0f b7 c0             	movzwl %ax,%eax
}
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    
  80221f:	90                   	nop

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80222b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80222f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 f6                	test   %esi,%esi
  802239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223d:	89 ca                	mov    %ecx,%edx
  80223f:	89 f8                	mov    %edi,%eax
  802241:	75 3d                	jne    802280 <__udivdi3+0x60>
  802243:	39 cf                	cmp    %ecx,%edi
  802245:	0f 87 c5 00 00 00    	ja     802310 <__udivdi3+0xf0>
  80224b:	85 ff                	test   %edi,%edi
  80224d:	89 fd                	mov    %edi,%ebp
  80224f:	75 0b                	jne    80225c <__udivdi3+0x3c>
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	31 d2                	xor    %edx,%edx
  802258:	f7 f7                	div    %edi
  80225a:	89 c5                	mov    %eax,%ebp
  80225c:	89 c8                	mov    %ecx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	f7 f5                	div    %ebp
  802262:	89 c1                	mov    %eax,%ecx
  802264:	89 d8                	mov    %ebx,%eax
  802266:	89 cf                	mov    %ecx,%edi
  802268:	f7 f5                	div    %ebp
  80226a:	89 c3                	mov    %eax,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	39 ce                	cmp    %ecx,%esi
  802282:	77 74                	ja     8022f8 <__udivdi3+0xd8>
  802284:	0f bd fe             	bsr    %esi,%edi
  802287:	83 f7 1f             	xor    $0x1f,%edi
  80228a:	0f 84 98 00 00 00    	je     802328 <__udivdi3+0x108>
  802290:	bb 20 00 00 00       	mov    $0x20,%ebx
  802295:	89 f9                	mov    %edi,%ecx
  802297:	89 c5                	mov    %eax,%ebp
  802299:	29 fb                	sub    %edi,%ebx
  80229b:	d3 e6                	shl    %cl,%esi
  80229d:	89 d9                	mov    %ebx,%ecx
  80229f:	d3 ed                	shr    %cl,%ebp
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	09 ee                	or     %ebp,%esi
  8022a7:	89 d9                	mov    %ebx,%ecx
  8022a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ad:	89 d5                	mov    %edx,%ebp
  8022af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b3:	d3 ed                	shr    %cl,%ebp
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e2                	shl    %cl,%edx
  8022b9:	89 d9                	mov    %ebx,%ecx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	09 c2                	or     %eax,%edx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	89 ea                	mov    %ebp,%edx
  8022c3:	f7 f6                	div    %esi
  8022c5:	89 d5                	mov    %edx,%ebp
  8022c7:	89 c3                	mov    %eax,%ebx
  8022c9:	f7 64 24 0c          	mull   0xc(%esp)
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	72 10                	jb     8022e1 <__udivdi3+0xc1>
  8022d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e6                	shl    %cl,%esi
  8022d9:	39 c6                	cmp    %eax,%esi
  8022db:	73 07                	jae    8022e4 <__udivdi3+0xc4>
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	75 03                	jne    8022e4 <__udivdi3+0xc4>
  8022e1:	83 eb 01             	sub    $0x1,%ebx
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 d8                	mov    %ebx,%eax
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 ff                	xor    %edi,%edi
  8022fa:	31 db                	xor    %ebx,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d8                	mov    %ebx,%eax
  802312:	f7 f7                	div    %edi
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 c3                	mov    %eax,%ebx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 fa                	mov    %edi,%edx
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	39 ce                	cmp    %ecx,%esi
  80232a:	72 0c                	jb     802338 <__udivdi3+0x118>
  80232c:	31 db                	xor    %ebx,%ebx
  80232e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802332:	0f 87 34 ff ff ff    	ja     80226c <__udivdi3+0x4c>
  802338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80233d:	e9 2a ff ff ff       	jmp    80226c <__udivdi3+0x4c>
  802342:	66 90                	xchg   %ax,%ax
  802344:	66 90                	xchg   %ax,%ax
  802346:	66 90                	xchg   %ax,%ax
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__umoddi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80235f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 d2                	test   %edx,%edx
  802369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 f3                	mov    %esi,%ebx
  802373:	89 3c 24             	mov    %edi,(%esp)
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	75 1c                	jne    802398 <__umoddi3+0x48>
  80237c:	39 f7                	cmp    %esi,%edi
  80237e:	76 50                	jbe    8023d0 <__umoddi3+0x80>
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	f7 f7                	div    %edi
  802386:	89 d0                	mov    %edx,%eax
  802388:	31 d2                	xor    %edx,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	39 f2                	cmp    %esi,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	77 52                	ja     8023f0 <__umoddi3+0xa0>
  80239e:	0f bd ea             	bsr    %edx,%ebp
  8023a1:	83 f5 1f             	xor    $0x1f,%ebp
  8023a4:	75 5a                	jne    802400 <__umoddi3+0xb0>
  8023a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023aa:	0f 82 e0 00 00 00    	jb     802490 <__umoddi3+0x140>
  8023b0:	39 0c 24             	cmp    %ecx,(%esp)
  8023b3:	0f 86 d7 00 00 00    	jbe    802490 <__umoddi3+0x140>
  8023b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	85 ff                	test   %edi,%edi
  8023d2:	89 fd                	mov    %edi,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x91>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f7                	div    %edi
  8023df:	89 c5                	mov    %eax,%ebp
  8023e1:	89 f0                	mov    %esi,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f5                	div    %ebp
  8023e7:	89 c8                	mov    %ecx,%eax
  8023e9:	f7 f5                	div    %ebp
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	eb 99                	jmp    802388 <__umoddi3+0x38>
  8023ef:	90                   	nop
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	83 c4 1c             	add    $0x1c,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	8b 34 24             	mov    (%esp),%esi
  802403:	bf 20 00 00 00       	mov    $0x20,%edi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	29 ef                	sub    %ebp,%edi
  80240c:	d3 e0                	shl    %cl,%eax
  80240e:	89 f9                	mov    %edi,%ecx
  802410:	89 f2                	mov    %esi,%edx
  802412:	d3 ea                	shr    %cl,%edx
  802414:	89 e9                	mov    %ebp,%ecx
  802416:	09 c2                	or     %eax,%edx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 14 24             	mov    %edx,(%esp)
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	d3 e2                	shl    %cl,%edx
  802421:	89 f9                	mov    %edi,%ecx
  802423:	89 54 24 04          	mov    %edx,0x4(%esp)
  802427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	89 c6                	mov    %eax,%esi
  802431:	d3 e3                	shl    %cl,%ebx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 d0                	mov    %edx,%eax
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	09 d8                	or     %ebx,%eax
  80243d:	89 d3                	mov    %edx,%ebx
  80243f:	89 f2                	mov    %esi,%edx
  802441:	f7 34 24             	divl   (%esp)
  802444:	89 d6                	mov    %edx,%esi
  802446:	d3 e3                	shl    %cl,%ebx
  802448:	f7 64 24 04          	mull   0x4(%esp)
  80244c:	39 d6                	cmp    %edx,%esi
  80244e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802452:	89 d1                	mov    %edx,%ecx
  802454:	89 c3                	mov    %eax,%ebx
  802456:	72 08                	jb     802460 <__umoddi3+0x110>
  802458:	75 11                	jne    80246b <__umoddi3+0x11b>
  80245a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80245e:	73 0b                	jae    80246b <__umoddi3+0x11b>
  802460:	2b 44 24 04          	sub    0x4(%esp),%eax
  802464:	1b 14 24             	sbb    (%esp),%edx
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 c3                	mov    %eax,%ebx
  80246b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80246f:	29 da                	sub    %ebx,%edx
  802471:	19 ce                	sbb    %ecx,%esi
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e0                	shl    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	d3 ee                	shr    %cl,%esi
  802481:	09 d0                	or     %edx,%eax
  802483:	89 f2                	mov    %esi,%edx
  802485:	83 c4 1c             	add    $0x1c,%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	29 f9                	sub    %edi,%ecx
  802492:	19 d6                	sbb    %edx,%esi
  802494:	89 74 24 04          	mov    %esi,0x4(%esp)
  802498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80249c:	e9 18 ff ff ff       	jmp    8023b9 <__umoddi3+0x69>
