
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
  800082:	e8 de 12 00 00       	call   801365 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 50 12 00 00       	call   8012ea <ipc_recv>
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
  8000e8:	e8 78 12 00 00       	call   801365 <ipc_send>
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
  800170:	e8 65 14 00 00       	call   8015da <close_all>
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
  800b54:	e8 b2 15 00 00       	call   80210b <_panic>

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
  800bd5:	e8 31 15 00 00       	call   80210b <_panic>

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
  800c17:	e8 ef 14 00 00       	call   80210b <_panic>

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
  800c59:	e8 ad 14 00 00       	call   80210b <_panic>

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
  800c9b:	e8 6b 14 00 00       	call   80210b <_panic>

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
  800cdd:	e8 29 14 00 00       	call   80210b <_panic>
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
  800d1f:	e8 e7 13 00 00       	call   80210b <_panic>

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
  800d83:	e8 83 13 00 00       	call   80210b <_panic>

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
  800e22:	e8 e4 12 00 00       	call   80210b <_panic>
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
  800e4c:	e8 ba 12 00 00       	call   80210b <_panic>
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
  800e94:	e8 72 12 00 00       	call   80210b <_panic>
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
  800ebc:	e8 4a 12 00 00       	call   80210b <_panic>
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
  800ed4:	e8 78 12 00 00       	call   802151 <set_pgfault_handler>
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
  800efc:	e8 0a 12 00 00       	call   80210b <_panic>
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
  800fb5:	e8 51 11 00 00       	call   80210b <_panic>
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
  800ffa:	e8 0c 11 00 00       	call   80210b <_panic>
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
  801028:	e8 de 10 00 00       	call   80210b <_panic>
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
  801052:	e8 b4 10 00 00       	call   80210b <_panic>
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
  801112:	e8 f4 0f 00 00       	call   80210b <_panic>
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
  801178:	e8 8e 0f 00 00       	call   80210b <_panic>
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
  801189:	53                   	push   %ebx
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801190:	b8 01 00 00 00       	mov    $0x1,%eax
  801195:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801198:	85 c0                	test   %eax,%eax
  80119a:	74 45                	je     8011e1 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80119c:	e8 c0 f9 ff ff       	call   800b61 <sys_getenvid>
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	83 c3 04             	add    $0x4,%ebx
  8011a7:	53                   	push   %ebx
  8011a8:	50                   	push   %eax
  8011a9:	e8 35 ff ff ff       	call   8010e3 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011ae:	e8 ae f9 ff ff       	call   800b61 <sys_getenvid>
  8011b3:	83 c4 08             	add    $0x8,%esp
  8011b6:	6a 04                	push   $0x4
  8011b8:	50                   	push   %eax
  8011b9:	e8 a8 fa ff ff       	call   800c66 <sys_env_set_status>

		if (r < 0) {
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	79 15                	jns    8011da <mutex_lock+0x54>
			panic("%e\n", r);
  8011c5:	50                   	push   %eax
  8011c6:	68 d2 28 80 00       	push   $0x8028d2
  8011cb:	68 02 01 00 00       	push   $0x102
  8011d0:	68 5a 28 80 00       	push   $0x80285a
  8011d5:	e8 31 0f 00 00       	call   80210b <_panic>
		}
		sys_yield();
  8011da:	e8 a1 f9 ff ff       	call   800b80 <sys_yield>
  8011df:	eb 08                	jmp    8011e9 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8011e1:	e8 7b f9 ff ff       	call   800b61 <sys_getenvid>
  8011e6:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8011e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8011f8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8011fc:	74 36                	je     801234 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	8d 43 04             	lea    0x4(%ebx),%eax
  801204:	50                   	push   %eax
  801205:	e8 4d ff ff ff       	call   801157 <queue_pop>
  80120a:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	6a 02                	push   $0x2
  801212:	50                   	push   %eax
  801213:	e8 4e fa ff ff       	call   800c66 <sys_env_set_status>
		if (r < 0) {
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	79 1d                	jns    80123c <mutex_unlock+0x4e>
			panic("%e\n", r);
  80121f:	50                   	push   %eax
  801220:	68 d2 28 80 00       	push   $0x8028d2
  801225:	68 16 01 00 00       	push   $0x116
  80122a:	68 5a 28 80 00       	push   $0x80285a
  80122f:	e8 d7 0e 00 00       	call   80210b <_panic>
  801234:	b8 00 00 00 00       	mov    $0x0,%eax
  801239:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80123c:	e8 3f f9 ff ff       	call   800b80 <sys_yield>
}
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	53                   	push   %ebx
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801250:	e8 0c f9 ff ff       	call   800b61 <sys_getenvid>
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	6a 07                	push   $0x7
  80125a:	53                   	push   %ebx
  80125b:	50                   	push   %eax
  80125c:	e8 3e f9 ff ff       	call   800b9f <sys_page_alloc>
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	79 15                	jns    80127d <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801268:	50                   	push   %eax
  801269:	68 bd 28 80 00       	push   $0x8028bd
  80126e:	68 23 01 00 00       	push   $0x123
  801273:	68 5a 28 80 00       	push   $0x80285a
  801278:	e8 8e 0e 00 00       	call   80210b <_panic>
	}	
	mtx->locked = 0;
  80127d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801283:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80128a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801291:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012a5:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012a8:	eb 20                	jmp    8012ca <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	56                   	push   %esi
  8012ae:	e8 a4 fe ff ff       	call   801157 <queue_pop>
  8012b3:	83 c4 08             	add    $0x8,%esp
  8012b6:	6a 02                	push   $0x2
  8012b8:	50                   	push   %eax
  8012b9:	e8 a8 f9 ff ff       	call   800c66 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8012be:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c1:	8b 40 04             	mov    0x4(%eax),%eax
  8012c4:	89 43 04             	mov    %eax,0x4(%ebx)
  8012c7:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012ca:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012ce:	75 da                	jne    8012aa <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012d0:	83 ec 04             	sub    $0x4,%esp
  8012d3:	68 00 10 00 00       	push   $0x1000
  8012d8:	6a 00                	push   $0x0
  8012da:	53                   	push   %ebx
  8012db:	e8 01 f6 ff ff       	call   8008e1 <memset>
	mtx = NULL;
}
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
  8012ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	75 12                	jne    80130e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8012fc:	83 ec 0c             	sub    $0xc,%esp
  8012ff:	68 00 00 c0 ee       	push   $0xeec00000
  801304:	e8 46 fa ff ff       	call   800d4f <sys_ipc_recv>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	eb 0c                	jmp    80131a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	50                   	push   %eax
  801312:	e8 38 fa ff ff       	call   800d4f <sys_ipc_recv>
  801317:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80131a:	85 f6                	test   %esi,%esi
  80131c:	0f 95 c1             	setne  %cl
  80131f:	85 db                	test   %ebx,%ebx
  801321:	0f 95 c2             	setne  %dl
  801324:	84 d1                	test   %dl,%cl
  801326:	74 09                	je     801331 <ipc_recv+0x47>
  801328:	89 c2                	mov    %eax,%edx
  80132a:	c1 ea 1f             	shr    $0x1f,%edx
  80132d:	84 d2                	test   %dl,%dl
  80132f:	75 2d                	jne    80135e <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801331:	85 f6                	test   %esi,%esi
  801333:	74 0d                	je     801342 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801335:	a1 08 40 80 00       	mov    0x804008,%eax
  80133a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  801340:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801342:	85 db                	test   %ebx,%ebx
  801344:	74 0d                	je     801353 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801346:	a1 08 40 80 00       	mov    0x804008,%eax
  80134b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801351:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801353:	a1 08 40 80 00       	mov    0x804008,%eax
  801358:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80135e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	57                   	push   %edi
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801371:	8b 75 0c             	mov    0xc(%ebp),%esi
  801374:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801377:	85 db                	test   %ebx,%ebx
  801379:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80137e:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801381:	ff 75 14             	pushl  0x14(%ebp)
  801384:	53                   	push   %ebx
  801385:	56                   	push   %esi
  801386:	57                   	push   %edi
  801387:	e8 a0 f9 ff ff       	call   800d2c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	c1 ea 1f             	shr    $0x1f,%edx
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	84 d2                	test   %dl,%dl
  801396:	74 17                	je     8013af <ipc_send+0x4a>
  801398:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80139b:	74 12                	je     8013af <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80139d:	50                   	push   %eax
  80139e:	68 d6 28 80 00       	push   $0x8028d6
  8013a3:	6a 47                	push   $0x47
  8013a5:	68 e4 28 80 00       	push   $0x8028e4
  8013aa:	e8 5c 0d 00 00       	call   80210b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8013af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013b2:	75 07                	jne    8013bb <ipc_send+0x56>
			sys_yield();
  8013b4:	e8 c7 f7 ff ff       	call   800b80 <sys_yield>
  8013b9:	eb c6                	jmp    801381 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	75 c2                	jne    801381 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8013bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5f                   	pop    %edi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013cd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013d2:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8013d8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013de:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8013e4:	39 ca                	cmp    %ecx,%edx
  8013e6:	75 13                	jne    8013fb <ipc_find_env+0x34>
			return envs[i].env_id;
  8013e8:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8013ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013f3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013f9:	eb 0f                	jmp    80140a <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013fb:	83 c0 01             	add    $0x1,%eax
  8013fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801403:	75 cd                	jne    8013d2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	05 00 00 00 30       	add    $0x30000000,%eax
  801417:	c1 e8 0c             	shr    $0xc,%eax
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	05 00 00 00 30       	add    $0x30000000,%eax
  801427:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80142c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801439:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80143e:	89 c2                	mov    %eax,%edx
  801440:	c1 ea 16             	shr    $0x16,%edx
  801443:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80144a:	f6 c2 01             	test   $0x1,%dl
  80144d:	74 11                	je     801460 <fd_alloc+0x2d>
  80144f:	89 c2                	mov    %eax,%edx
  801451:	c1 ea 0c             	shr    $0xc,%edx
  801454:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145b:	f6 c2 01             	test   $0x1,%dl
  80145e:	75 09                	jne    801469 <fd_alloc+0x36>
			*fd_store = fd;
  801460:	89 01                	mov    %eax,(%ecx)
			return 0;
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	eb 17                	jmp    801480 <fd_alloc+0x4d>
  801469:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80146e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801473:	75 c9                	jne    80143e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801475:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80147b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801488:	83 f8 1f             	cmp    $0x1f,%eax
  80148b:	77 36                	ja     8014c3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80148d:	c1 e0 0c             	shl    $0xc,%eax
  801490:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801495:	89 c2                	mov    %eax,%edx
  801497:	c1 ea 16             	shr    $0x16,%edx
  80149a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a1:	f6 c2 01             	test   $0x1,%dl
  8014a4:	74 24                	je     8014ca <fd_lookup+0x48>
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	c1 ea 0c             	shr    $0xc,%edx
  8014ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b2:	f6 c2 01             	test   $0x1,%dl
  8014b5:	74 1a                	je     8014d1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c1:	eb 13                	jmp    8014d6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c8:	eb 0c                	jmp    8014d6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cf:	eb 05                	jmp    8014d6 <fd_lookup+0x54>
  8014d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e1:	ba 6c 29 80 00       	mov    $0x80296c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014e6:	eb 13                	jmp    8014fb <dev_lookup+0x23>
  8014e8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014eb:	39 08                	cmp    %ecx,(%eax)
  8014ed:	75 0c                	jne    8014fb <dev_lookup+0x23>
			*dev = devtab[i];
  8014ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f9:	eb 31                	jmp    80152c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014fb:	8b 02                	mov    (%edx),%eax
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	75 e7                	jne    8014e8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801501:	a1 08 40 80 00       	mov    0x804008,%eax
  801506:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	51                   	push   %ecx
  801510:	50                   	push   %eax
  801511:	68 f0 28 80 00       	push   $0x8028f0
  801516:	e8 fc ec ff ff       	call   800217 <cprintf>
	*dev = 0;
  80151b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80152c:	c9                   	leave  
  80152d:	c3                   	ret    

0080152e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	83 ec 10             	sub    $0x10,%esp
  801536:	8b 75 08             	mov    0x8(%ebp),%esi
  801539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80153c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801546:	c1 e8 0c             	shr    $0xc,%eax
  801549:	50                   	push   %eax
  80154a:	e8 33 ff ff ff       	call   801482 <fd_lookup>
  80154f:	83 c4 08             	add    $0x8,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 05                	js     80155b <fd_close+0x2d>
	    || fd != fd2)
  801556:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801559:	74 0c                	je     801567 <fd_close+0x39>
		return (must_exist ? r : 0);
  80155b:	84 db                	test   %bl,%bl
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	0f 44 c2             	cmove  %edx,%eax
  801565:	eb 41                	jmp    8015a8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	ff 36                	pushl  (%esi)
  801570:	e8 63 ff ff ff       	call   8014d8 <dev_lookup>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 1a                	js     801598 <fd_close+0x6a>
		if (dev->dev_close)
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801584:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801589:	85 c0                	test   %eax,%eax
  80158b:	74 0b                	je     801598 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	56                   	push   %esi
  801591:	ff d0                	call   *%eax
  801593:	89 c3                	mov    %eax,%ebx
  801595:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	56                   	push   %esi
  80159c:	6a 00                	push   $0x0
  80159e:	e8 81 f6 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	89 d8                	mov    %ebx,%eax
}
  8015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	ff 75 08             	pushl  0x8(%ebp)
  8015bc:	e8 c1 fe ff ff       	call   801482 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 10                	js     8015d8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	6a 01                	push   $0x1
  8015cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d0:	e8 59 ff ff ff       	call   80152e <fd_close>
  8015d5:	83 c4 10             	add    $0x10,%esp
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <close_all>:

void
close_all(void)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	e8 c0 ff ff ff       	call   8015af <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ef:	83 c3 01             	add    $0x1,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	83 fb 20             	cmp    $0x20,%ebx
  8015f8:	75 ec                	jne    8015e6 <close_all+0xc>
		close(i);
}
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 2c             	sub    $0x2c,%esp
  801608:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80160b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	ff 75 08             	pushl  0x8(%ebp)
  801612:	e8 6b fe ff ff       	call   801482 <fd_lookup>
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	0f 88 c1 00 00 00    	js     8016e3 <dup+0xe4>
		return r;
	close(newfdnum);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	56                   	push   %esi
  801626:	e8 84 ff ff ff       	call   8015af <close>

	newfd = INDEX2FD(newfdnum);
  80162b:	89 f3                	mov    %esi,%ebx
  80162d:	c1 e3 0c             	shl    $0xc,%ebx
  801630:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801636:	83 c4 04             	add    $0x4,%esp
  801639:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163c:	e8 db fd ff ff       	call   80141c <fd2data>
  801641:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801643:	89 1c 24             	mov    %ebx,(%esp)
  801646:	e8 d1 fd ff ff       	call   80141c <fd2data>
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801651:	89 f8                	mov    %edi,%eax
  801653:	c1 e8 16             	shr    $0x16,%eax
  801656:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80165d:	a8 01                	test   $0x1,%al
  80165f:	74 37                	je     801698 <dup+0x99>
  801661:	89 f8                	mov    %edi,%eax
  801663:	c1 e8 0c             	shr    $0xc,%eax
  801666:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80166d:	f6 c2 01             	test   $0x1,%dl
  801670:	74 26                	je     801698 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801672:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	25 07 0e 00 00       	and    $0xe07,%eax
  801681:	50                   	push   %eax
  801682:	ff 75 d4             	pushl  -0x2c(%ebp)
  801685:	6a 00                	push   $0x0
  801687:	57                   	push   %edi
  801688:	6a 00                	push   $0x0
  80168a:	e8 53 f5 ff ff       	call   800be2 <sys_page_map>
  80168f:	89 c7                	mov    %eax,%edi
  801691:	83 c4 20             	add    $0x20,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 2e                	js     8016c6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169b:	89 d0                	mov    %edx,%eax
  80169d:	c1 e8 0c             	shr    $0xc,%eax
  8016a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a7:	83 ec 0c             	sub    $0xc,%esp
  8016aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8016af:	50                   	push   %eax
  8016b0:	53                   	push   %ebx
  8016b1:	6a 00                	push   $0x0
  8016b3:	52                   	push   %edx
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 27 f5 ff ff       	call   800be2 <sys_page_map>
  8016bb:	89 c7                	mov    %eax,%edi
  8016bd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016c0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c2:	85 ff                	test   %edi,%edi
  8016c4:	79 1d                	jns    8016e3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	53                   	push   %ebx
  8016ca:	6a 00                	push   $0x0
  8016cc:	e8 53 f5 ff ff       	call   800c24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016d7:	6a 00                	push   $0x0
  8016d9:	e8 46 f5 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	89 f8                	mov    %edi,%eax
}
  8016e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	83 ec 14             	sub    $0x14,%esp
  8016f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	53                   	push   %ebx
  8016fa:	e8 83 fd ff ff       	call   801482 <fd_lookup>
  8016ff:	83 c4 08             	add    $0x8,%esp
  801702:	89 c2                	mov    %eax,%edx
  801704:	85 c0                	test   %eax,%eax
  801706:	78 70                	js     801778 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801708:	83 ec 08             	sub    $0x8,%esp
  80170b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170e:	50                   	push   %eax
  80170f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801712:	ff 30                	pushl  (%eax)
  801714:	e8 bf fd ff ff       	call   8014d8 <dev_lookup>
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 4f                	js     80176f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801720:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801723:	8b 42 08             	mov    0x8(%edx),%eax
  801726:	83 e0 03             	and    $0x3,%eax
  801729:	83 f8 01             	cmp    $0x1,%eax
  80172c:	75 24                	jne    801752 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80172e:	a1 08 40 80 00       	mov    0x804008,%eax
  801733:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	53                   	push   %ebx
  80173d:	50                   	push   %eax
  80173e:	68 31 29 80 00       	push   $0x802931
  801743:	e8 cf ea ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801750:	eb 26                	jmp    801778 <read+0x8d>
	}
	if (!dev->dev_read)
  801752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801755:	8b 40 08             	mov    0x8(%eax),%eax
  801758:	85 c0                	test   %eax,%eax
  80175a:	74 17                	je     801773 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	ff 75 10             	pushl  0x10(%ebp)
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	52                   	push   %edx
  801766:	ff d0                	call   *%eax
  801768:	89 c2                	mov    %eax,%edx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	eb 09                	jmp    801778 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	89 c2                	mov    %eax,%edx
  801771:	eb 05                	jmp    801778 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801773:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801778:	89 d0                	mov    %edx,%eax
  80177a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	57                   	push   %edi
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	83 ec 0c             	sub    $0xc,%esp
  801788:	8b 7d 08             	mov    0x8(%ebp),%edi
  80178b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801793:	eb 21                	jmp    8017b6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801795:	83 ec 04             	sub    $0x4,%esp
  801798:	89 f0                	mov    %esi,%eax
  80179a:	29 d8                	sub    %ebx,%eax
  80179c:	50                   	push   %eax
  80179d:	89 d8                	mov    %ebx,%eax
  80179f:	03 45 0c             	add    0xc(%ebp),%eax
  8017a2:	50                   	push   %eax
  8017a3:	57                   	push   %edi
  8017a4:	e8 42 ff ff ff       	call   8016eb <read>
		if (m < 0)
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 10                	js     8017c0 <readn+0x41>
			return m;
		if (m == 0)
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	74 0a                	je     8017be <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b4:	01 c3                	add    %eax,%ebx
  8017b6:	39 f3                	cmp    %esi,%ebx
  8017b8:	72 db                	jb     801795 <readn+0x16>
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	eb 02                	jmp    8017c0 <readn+0x41>
  8017be:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 14             	sub    $0x14,%esp
  8017cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d5:	50                   	push   %eax
  8017d6:	53                   	push   %ebx
  8017d7:	e8 a6 fc ff ff       	call   801482 <fd_lookup>
  8017dc:	83 c4 08             	add    $0x8,%esp
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 6b                	js     801850 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	ff 30                	pushl  (%eax)
  8017f1:	e8 e2 fc ff ff       	call   8014d8 <dev_lookup>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 4a                	js     801847 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801800:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801804:	75 24                	jne    80182a <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801806:	a1 08 40 80 00       	mov    0x804008,%eax
  80180b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801811:	83 ec 04             	sub    $0x4,%esp
  801814:	53                   	push   %ebx
  801815:	50                   	push   %eax
  801816:	68 4d 29 80 00       	push   $0x80294d
  80181b:	e8 f7 e9 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801828:	eb 26                	jmp    801850 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	8b 52 0c             	mov    0xc(%edx),%edx
  801830:	85 d2                	test   %edx,%edx
  801832:	74 17                	je     80184b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801834:	83 ec 04             	sub    $0x4,%esp
  801837:	ff 75 10             	pushl  0x10(%ebp)
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	50                   	push   %eax
  80183e:	ff d2                	call   *%edx
  801840:	89 c2                	mov    %eax,%edx
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	eb 09                	jmp    801850 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801847:	89 c2                	mov    %eax,%edx
  801849:	eb 05                	jmp    801850 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80184b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801850:	89 d0                	mov    %edx,%eax
  801852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <seek>:

int
seek(int fdnum, off_t offset)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	ff 75 08             	pushl  0x8(%ebp)
  801864:	e8 19 fc ff ff       	call   801482 <fd_lookup>
  801869:	83 c4 08             	add    $0x8,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 0e                	js     80187e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801870:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801873:	8b 55 0c             	mov    0xc(%ebp),%edx
  801876:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 14             	sub    $0x14,%esp
  801887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	53                   	push   %ebx
  80188f:	e8 ee fb ff ff       	call   801482 <fd_lookup>
  801894:	83 c4 08             	add    $0x8,%esp
  801897:	89 c2                	mov    %eax,%edx
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 68                	js     801905 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a7:	ff 30                	pushl  (%eax)
  8018a9:	e8 2a fc ff ff       	call   8014d8 <dev_lookup>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 47                	js     8018fc <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018bc:	75 24                	jne    8018e2 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018be:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	53                   	push   %ebx
  8018cd:	50                   	push   %eax
  8018ce:	68 10 29 80 00       	push   $0x802910
  8018d3:	e8 3f e9 ff ff       	call   800217 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e0:	eb 23                	jmp    801905 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e5:	8b 52 18             	mov    0x18(%edx),%edx
  8018e8:	85 d2                	test   %edx,%edx
  8018ea:	74 14                	je     801900 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ec:	83 ec 08             	sub    $0x8,%esp
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	50                   	push   %eax
  8018f3:	ff d2                	call   *%edx
  8018f5:	89 c2                	mov    %eax,%edx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	eb 09                	jmp    801905 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fc:	89 c2                	mov    %eax,%edx
  8018fe:	eb 05                	jmp    801905 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801900:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801905:	89 d0                	mov    %edx,%eax
  801907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	53                   	push   %ebx
  801910:	83 ec 14             	sub    $0x14,%esp
  801913:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801916:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801919:	50                   	push   %eax
  80191a:	ff 75 08             	pushl  0x8(%ebp)
  80191d:	e8 60 fb ff ff       	call   801482 <fd_lookup>
  801922:	83 c4 08             	add    $0x8,%esp
  801925:	89 c2                	mov    %eax,%edx
  801927:	85 c0                	test   %eax,%eax
  801929:	78 58                	js     801983 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801931:	50                   	push   %eax
  801932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801935:	ff 30                	pushl  (%eax)
  801937:	e8 9c fb ff ff       	call   8014d8 <dev_lookup>
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 37                	js     80197a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801946:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80194a:	74 32                	je     80197e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80194c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80194f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801956:	00 00 00 
	stat->st_isdir = 0;
  801959:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801960:	00 00 00 
	stat->st_dev = dev;
  801963:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	53                   	push   %ebx
  80196d:	ff 75 f0             	pushl  -0x10(%ebp)
  801970:	ff 50 14             	call   *0x14(%eax)
  801973:	89 c2                	mov    %eax,%edx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	eb 09                	jmp    801983 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197a:	89 c2                	mov    %eax,%edx
  80197c:	eb 05                	jmp    801983 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80197e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801983:	89 d0                	mov    %edx,%eax
  801985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	6a 00                	push   $0x0
  801994:	ff 75 08             	pushl  0x8(%ebp)
  801997:	e8 e3 01 00 00       	call   801b7f <open>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 1b                	js     8019c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019a5:	83 ec 08             	sub    $0x8,%esp
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	50                   	push   %eax
  8019ac:	e8 5b ff ff ff       	call   80190c <fstat>
  8019b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b3:	89 1c 24             	mov    %ebx,(%esp)
  8019b6:	e8 f4 fb ff ff       	call   8015af <close>
	return r;
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	89 f0                	mov    %esi,%eax
}
  8019c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	5d                   	pop    %ebp
  8019c6:	c3                   	ret    

008019c7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	56                   	push   %esi
  8019cb:	53                   	push   %ebx
  8019cc:	89 c6                	mov    %eax,%esi
  8019ce:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019d0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019d7:	75 12                	jne    8019eb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	6a 01                	push   $0x1
  8019de:	e8 e4 f9 ff ff       	call   8013c7 <ipc_find_env>
  8019e3:	a3 00 40 80 00       	mov    %eax,0x804000
  8019e8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019eb:	6a 07                	push   $0x7
  8019ed:	68 00 50 80 00       	push   $0x805000
  8019f2:	56                   	push   %esi
  8019f3:	ff 35 00 40 80 00    	pushl  0x804000
  8019f9:	e8 67 f9 ff ff       	call   801365 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019fe:	83 c4 0c             	add    $0xc,%esp
  801a01:	6a 00                	push   $0x0
  801a03:	53                   	push   %ebx
  801a04:	6a 00                	push   $0x0
  801a06:	e8 df f8 ff ff       	call   8012ea <ipc_recv>
}
  801a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a26:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	b8 02 00 00 00       	mov    $0x2,%eax
  801a35:	e8 8d ff ff ff       	call   8019c7 <fsipc>
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	8b 40 0c             	mov    0xc(%eax),%eax
  801a48:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a52:	b8 06 00 00 00       	mov    $0x6,%eax
  801a57:	e8 6b ff ff ff       	call   8019c7 <fsipc>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	53                   	push   %ebx
  801a62:	83 ec 04             	sub    $0x4,%esp
  801a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a73:	ba 00 00 00 00       	mov    $0x0,%edx
  801a78:	b8 05 00 00 00       	mov    $0x5,%eax
  801a7d:	e8 45 ff ff ff       	call   8019c7 <fsipc>
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 2c                	js     801ab2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a86:	83 ec 08             	sub    $0x8,%esp
  801a89:	68 00 50 80 00       	push   $0x805000
  801a8e:	53                   	push   %ebx
  801a8f:	e8 08 ed ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a94:	a1 80 50 80 00       	mov    0x805080,%eax
  801a99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9f:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac3:	8b 52 0c             	mov    0xc(%edx),%edx
  801ac6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801acc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ad1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ad6:	0f 47 c2             	cmova  %edx,%eax
  801ad9:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ade:	50                   	push   %eax
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	68 08 50 80 00       	push   $0x805008
  801ae7:	e8 42 ee ff ff       	call   80092e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801aec:	ba 00 00 00 00       	mov    $0x0,%edx
  801af1:	b8 04 00 00 00       	mov    $0x4,%eax
  801af6:	e8 cc fe ff ff       	call   8019c7 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b10:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b16:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b20:	e8 a2 fe ff ff       	call   8019c7 <fsipc>
  801b25:	89 c3                	mov    %eax,%ebx
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 4b                	js     801b76 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b2b:	39 c6                	cmp    %eax,%esi
  801b2d:	73 16                	jae    801b45 <devfile_read+0x48>
  801b2f:	68 7c 29 80 00       	push   $0x80297c
  801b34:	68 83 29 80 00       	push   $0x802983
  801b39:	6a 7c                	push   $0x7c
  801b3b:	68 98 29 80 00       	push   $0x802998
  801b40:	e8 c6 05 00 00       	call   80210b <_panic>
	assert(r <= PGSIZE);
  801b45:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4a:	7e 16                	jle    801b62 <devfile_read+0x65>
  801b4c:	68 a3 29 80 00       	push   $0x8029a3
  801b51:	68 83 29 80 00       	push   $0x802983
  801b56:	6a 7d                	push   $0x7d
  801b58:	68 98 29 80 00       	push   $0x802998
  801b5d:	e8 a9 05 00 00       	call   80210b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b62:	83 ec 04             	sub    $0x4,%esp
  801b65:	50                   	push   %eax
  801b66:	68 00 50 80 00       	push   $0x805000
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	e8 bb ed ff ff       	call   80092e <memmove>
	return r;
  801b73:	83 c4 10             	add    $0x10,%esp
}
  801b76:	89 d8                	mov    %ebx,%eax
  801b78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	53                   	push   %ebx
  801b83:	83 ec 20             	sub    $0x20,%esp
  801b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b89:	53                   	push   %ebx
  801b8a:	e8 d4 eb ff ff       	call   800763 <strlen>
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b97:	7f 67                	jg     801c00 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9f:	50                   	push   %eax
  801ba0:	e8 8e f8 ff ff       	call   801433 <fd_alloc>
  801ba5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ba8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 57                	js     801c05 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bae:	83 ec 08             	sub    $0x8,%esp
  801bb1:	53                   	push   %ebx
  801bb2:	68 00 50 80 00       	push   $0x805000
  801bb7:	e8 e0 eb ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcc:	e8 f6 fd ff ff       	call   8019c7 <fsipc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	79 14                	jns    801bee <open+0x6f>
		fd_close(fd, 0);
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	6a 00                	push   $0x0
  801bdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801be2:	e8 47 f9 ff ff       	call   80152e <fd_close>
		return r;
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	89 da                	mov    %ebx,%edx
  801bec:	eb 17                	jmp    801c05 <open+0x86>
	}

	return fd2num(fd);
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf4:	e8 13 f8 ff ff       	call   80140c <fd2num>
  801bf9:	89 c2                	mov    %eax,%edx
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	eb 05                	jmp    801c05 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c00:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c05:	89 d0                	mov    %edx,%eax
  801c07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c12:	ba 00 00 00 00       	mov    $0x0,%edx
  801c17:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1c:	e8 a6 fd ff ff       	call   8019c7 <fsipc>
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c2b:	83 ec 0c             	sub    $0xc,%esp
  801c2e:	ff 75 08             	pushl  0x8(%ebp)
  801c31:	e8 e6 f7 ff ff       	call   80141c <fd2data>
  801c36:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c38:	83 c4 08             	add    $0x8,%esp
  801c3b:	68 af 29 80 00       	push   $0x8029af
  801c40:	53                   	push   %ebx
  801c41:	e8 56 eb ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c46:	8b 46 04             	mov    0x4(%esi),%eax
  801c49:	2b 06                	sub    (%esi),%eax
  801c4b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c51:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c58:	00 00 00 
	stat->st_dev = &devpipe;
  801c5b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c62:	30 80 00 
	return 0;
}
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	53                   	push   %ebx
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c7b:	53                   	push   %ebx
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 a1 ef ff ff       	call   800c24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c83:	89 1c 24             	mov    %ebx,(%esp)
  801c86:	e8 91 f7 ff ff       	call   80141c <fd2data>
  801c8b:	83 c4 08             	add    $0x8,%esp
  801c8e:	50                   	push   %eax
  801c8f:	6a 00                	push   $0x0
  801c91:	e8 8e ef ff ff       	call   800c24 <sys_page_unmap>
}
  801c96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	57                   	push   %edi
  801c9f:	56                   	push   %esi
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 1c             	sub    $0x1c,%esp
  801ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ca7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ca9:	a1 08 40 80 00       	mov    0x804008,%eax
  801cae:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	ff 75 e0             	pushl  -0x20(%ebp)
  801cba:	e8 21 05 00 00       	call   8021e0 <pageref>
  801cbf:	89 c3                	mov    %eax,%ebx
  801cc1:	89 3c 24             	mov    %edi,(%esp)
  801cc4:	e8 17 05 00 00       	call   8021e0 <pageref>
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	39 c3                	cmp    %eax,%ebx
  801cce:	0f 94 c1             	sete   %cl
  801cd1:	0f b6 c9             	movzbl %cl,%ecx
  801cd4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cd7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801cdd:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801ce3:	39 ce                	cmp    %ecx,%esi
  801ce5:	74 1e                	je     801d05 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ce7:	39 c3                	cmp    %eax,%ebx
  801ce9:	75 be                	jne    801ca9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ceb:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801cf1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf4:	50                   	push   %eax
  801cf5:	56                   	push   %esi
  801cf6:	68 b6 29 80 00       	push   $0x8029b6
  801cfb:	e8 17 e5 ff ff       	call   800217 <cprintf>
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	eb a4                	jmp    801ca9 <_pipeisclosed+0xe>
	}
}
  801d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0b:	5b                   	pop    %ebx
  801d0c:	5e                   	pop    %esi
  801d0d:	5f                   	pop    %edi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	57                   	push   %edi
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	83 ec 28             	sub    $0x28,%esp
  801d19:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d1c:	56                   	push   %esi
  801d1d:	e8 fa f6 ff ff       	call   80141c <fd2data>
  801d22:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	bf 00 00 00 00       	mov    $0x0,%edi
  801d2c:	eb 4b                	jmp    801d79 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d2e:	89 da                	mov    %ebx,%edx
  801d30:	89 f0                	mov    %esi,%eax
  801d32:	e8 64 ff ff ff       	call   801c9b <_pipeisclosed>
  801d37:	85 c0                	test   %eax,%eax
  801d39:	75 48                	jne    801d83 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3b:	e8 40 ee ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d40:	8b 43 04             	mov    0x4(%ebx),%eax
  801d43:	8b 0b                	mov    (%ebx),%ecx
  801d45:	8d 51 20             	lea    0x20(%ecx),%edx
  801d48:	39 d0                	cmp    %edx,%eax
  801d4a:	73 e2                	jae    801d2e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d53:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	c1 fa 1f             	sar    $0x1f,%edx
  801d5b:	89 d1                	mov    %edx,%ecx
  801d5d:	c1 e9 1b             	shr    $0x1b,%ecx
  801d60:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d63:	83 e2 1f             	and    $0x1f,%edx
  801d66:	29 ca                	sub    %ecx,%edx
  801d68:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d6c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d70:	83 c0 01             	add    $0x1,%eax
  801d73:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d76:	83 c7 01             	add    $0x1,%edi
  801d79:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d7c:	75 c2                	jne    801d40 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d7e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d81:	eb 05                	jmp    801d88 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	57                   	push   %edi
  801d94:	56                   	push   %esi
  801d95:	53                   	push   %ebx
  801d96:	83 ec 18             	sub    $0x18,%esp
  801d99:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d9c:	57                   	push   %edi
  801d9d:	e8 7a f6 ff ff       	call   80141c <fd2data>
  801da2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dac:	eb 3d                	jmp    801deb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dae:	85 db                	test   %ebx,%ebx
  801db0:	74 04                	je     801db6 <devpipe_read+0x26>
				return i;
  801db2:	89 d8                	mov    %ebx,%eax
  801db4:	eb 44                	jmp    801dfa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801db6:	89 f2                	mov    %esi,%edx
  801db8:	89 f8                	mov    %edi,%eax
  801dba:	e8 dc fe ff ff       	call   801c9b <_pipeisclosed>
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	75 32                	jne    801df5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dc3:	e8 b8 ed ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dc8:	8b 06                	mov    (%esi),%eax
  801dca:	3b 46 04             	cmp    0x4(%esi),%eax
  801dcd:	74 df                	je     801dae <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dcf:	99                   	cltd   
  801dd0:	c1 ea 1b             	shr    $0x1b,%edx
  801dd3:	01 d0                	add    %edx,%eax
  801dd5:	83 e0 1f             	and    $0x1f,%eax
  801dd8:	29 d0                	sub    %edx,%eax
  801dda:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801de5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de8:	83 c3 01             	add    $0x1,%ebx
  801deb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dee:	75 d8                	jne    801dc8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801df0:	8b 45 10             	mov    0x10(%ebp),%eax
  801df3:	eb 05                	jmp    801dfa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	56                   	push   %esi
  801e06:	53                   	push   %ebx
  801e07:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0d:	50                   	push   %eax
  801e0e:	e8 20 f6 ff ff       	call   801433 <fd_alloc>
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	0f 88 2c 01 00 00    	js     801f4c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e20:	83 ec 04             	sub    $0x4,%esp
  801e23:	68 07 04 00 00       	push   $0x407
  801e28:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2b:	6a 00                	push   $0x0
  801e2d:	e8 6d ed ff ff       	call   800b9f <sys_page_alloc>
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	89 c2                	mov    %eax,%edx
  801e37:	85 c0                	test   %eax,%eax
  801e39:	0f 88 0d 01 00 00    	js     801f4c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e45:	50                   	push   %eax
  801e46:	e8 e8 f5 ff ff       	call   801433 <fd_alloc>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	0f 88 e2 00 00 00    	js     801f3a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e58:	83 ec 04             	sub    $0x4,%esp
  801e5b:	68 07 04 00 00       	push   $0x407
  801e60:	ff 75 f0             	pushl  -0x10(%ebp)
  801e63:	6a 00                	push   $0x0
  801e65:	e8 35 ed ff ff       	call   800b9f <sys_page_alloc>
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	0f 88 c3 00 00 00    	js     801f3a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7d:	e8 9a f5 ff ff       	call   80141c <fd2data>
  801e82:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e84:	83 c4 0c             	add    $0xc,%esp
  801e87:	68 07 04 00 00       	push   $0x407
  801e8c:	50                   	push   %eax
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 0b ed ff ff       	call   800b9f <sys_page_alloc>
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	0f 88 89 00 00 00    	js     801f2a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea7:	e8 70 f5 ff ff       	call   80141c <fd2data>
  801eac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eb3:	50                   	push   %eax
  801eb4:	6a 00                	push   $0x0
  801eb6:	56                   	push   %esi
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 24 ed ff ff       	call   800be2 <sys_page_map>
  801ebe:	89 c3                	mov    %eax,%ebx
  801ec0:	83 c4 20             	add    $0x20,%esp
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	78 55                	js     801f1c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ec7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801edc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef7:	e8 10 f5 ff ff       	call   80140c <fd2num>
  801efc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f01:	83 c4 04             	add    $0x4,%esp
  801f04:	ff 75 f0             	pushl  -0x10(%ebp)
  801f07:	e8 00 f5 ff ff       	call   80140c <fd2num>
  801f0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1a:	eb 30                	jmp    801f4c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f1c:	83 ec 08             	sub    $0x8,%esp
  801f1f:	56                   	push   %esi
  801f20:	6a 00                	push   $0x0
  801f22:	e8 fd ec ff ff       	call   800c24 <sys_page_unmap>
  801f27:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f2a:	83 ec 08             	sub    $0x8,%esp
  801f2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f30:	6a 00                	push   $0x0
  801f32:	e8 ed ec ff ff       	call   800c24 <sys_page_unmap>
  801f37:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f3a:	83 ec 08             	sub    $0x8,%esp
  801f3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f40:	6a 00                	push   $0x0
  801f42:	e8 dd ec ff ff       	call   800c24 <sys_page_unmap>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f4c:	89 d0                	mov    %edx,%eax
  801f4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5e:	50                   	push   %eax
  801f5f:	ff 75 08             	pushl  0x8(%ebp)
  801f62:	e8 1b f5 ff ff       	call   801482 <fd_lookup>
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 18                	js     801f86 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f6e:	83 ec 0c             	sub    $0xc,%esp
  801f71:	ff 75 f4             	pushl  -0xc(%ebp)
  801f74:	e8 a3 f4 ff ff       	call   80141c <fd2data>
	return _pipeisclosed(fd, p);
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7e:	e8 18 fd ff ff       	call   801c9b <_pipeisclosed>
  801f83:	83 c4 10             	add    $0x10,%esp
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f98:	68 ce 29 80 00       	push   $0x8029ce
  801f9d:	ff 75 0c             	pushl  0xc(%ebp)
  801fa0:	e8 f7 e7 ff ff       	call   80079c <strcpy>
	return 0;
}
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	57                   	push   %edi
  801fb0:	56                   	push   %esi
  801fb1:	53                   	push   %ebx
  801fb2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fbd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc3:	eb 2d                	jmp    801ff2 <devcons_write+0x46>
		m = n - tot;
  801fc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fca:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fcd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fd2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd5:	83 ec 04             	sub    $0x4,%esp
  801fd8:	53                   	push   %ebx
  801fd9:	03 45 0c             	add    0xc(%ebp),%eax
  801fdc:	50                   	push   %eax
  801fdd:	57                   	push   %edi
  801fde:	e8 4b e9 ff ff       	call   80092e <memmove>
		sys_cputs(buf, m);
  801fe3:	83 c4 08             	add    $0x8,%esp
  801fe6:	53                   	push   %ebx
  801fe7:	57                   	push   %edi
  801fe8:	e8 f6 ea ff ff       	call   800ae3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fed:	01 de                	add    %ebx,%esi
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	89 f0                	mov    %esi,%eax
  801ff4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ff7:	72 cc                	jb     801fc5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5e                   	pop    %esi
  801ffe:	5f                   	pop    %edi
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    

00802001 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 08             	sub    $0x8,%esp
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80200c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802010:	74 2a                	je     80203c <devcons_read+0x3b>
  802012:	eb 05                	jmp    802019 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802014:	e8 67 eb ff ff       	call   800b80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802019:	e8 e3 ea ff ff       	call   800b01 <sys_cgetc>
  80201e:	85 c0                	test   %eax,%eax
  802020:	74 f2                	je     802014 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802022:	85 c0                	test   %eax,%eax
  802024:	78 16                	js     80203c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802026:	83 f8 04             	cmp    $0x4,%eax
  802029:	74 0c                	je     802037 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80202b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202e:	88 02                	mov    %al,(%edx)
	return 1;
  802030:	b8 01 00 00 00       	mov    $0x1,%eax
  802035:	eb 05                	jmp    80203c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80204a:	6a 01                	push   $0x1
  80204c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	e8 8e ea ff ff       	call   800ae3 <sys_cputs>
}
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <getchar>:

int
getchar(void)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802060:	6a 01                	push   $0x1
  802062:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802065:	50                   	push   %eax
  802066:	6a 00                	push   $0x0
  802068:	e8 7e f6 ff ff       	call   8016eb <read>
	if (r < 0)
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	78 0f                	js     802083 <getchar+0x29>
		return r;
	if (r < 1)
  802074:	85 c0                	test   %eax,%eax
  802076:	7e 06                	jle    80207e <getchar+0x24>
		return -E_EOF;
	return c;
  802078:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80207c:	eb 05                	jmp    802083 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80207e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802083:	c9                   	leave  
  802084:	c3                   	ret    

00802085 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208e:	50                   	push   %eax
  80208f:	ff 75 08             	pushl  0x8(%ebp)
  802092:	e8 eb f3 ff ff       	call   801482 <fd_lookup>
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 11                	js     8020af <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80209e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a7:	39 10                	cmp    %edx,(%eax)
  8020a9:	0f 94 c0             	sete   %al
  8020ac:	0f b6 c0             	movzbl %al,%eax
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <opencons>:

int
opencons(void)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ba:	50                   	push   %eax
  8020bb:	e8 73 f3 ff ff       	call   801433 <fd_alloc>
  8020c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8020c3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	78 3e                	js     802107 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020c9:	83 ec 04             	sub    $0x4,%esp
  8020cc:	68 07 04 00 00       	push   $0x407
  8020d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 c4 ea ff ff       	call   800b9f <sys_page_alloc>
  8020db:	83 c4 10             	add    $0x10,%esp
		return r;
  8020de:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 23                	js     802107 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020e4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020f9:	83 ec 0c             	sub    $0xc,%esp
  8020fc:	50                   	push   %eax
  8020fd:	e8 0a f3 ff ff       	call   80140c <fd2num>
  802102:	89 c2                	mov    %eax,%edx
  802104:	83 c4 10             	add    $0x10,%esp
}
  802107:	89 d0                	mov    %edx,%eax
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	56                   	push   %esi
  80210f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802110:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802113:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802119:	e8 43 ea ff ff       	call   800b61 <sys_getenvid>
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	ff 75 0c             	pushl  0xc(%ebp)
  802124:	ff 75 08             	pushl  0x8(%ebp)
  802127:	56                   	push   %esi
  802128:	50                   	push   %eax
  802129:	68 dc 29 80 00       	push   $0x8029dc
  80212e:	e8 e4 e0 ff ff       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802133:	83 c4 18             	add    $0x18,%esp
  802136:	53                   	push   %ebx
  802137:	ff 75 10             	pushl  0x10(%ebp)
  80213a:	e8 87 e0 ff ff       	call   8001c6 <vcprintf>
	cprintf("\n");
  80213f:	c7 04 24 bb 28 80 00 	movl   $0x8028bb,(%esp)
  802146:	e8 cc e0 ff ff       	call   800217 <cprintf>
  80214b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80214e:	cc                   	int3   
  80214f:	eb fd                	jmp    80214e <_panic+0x43>

00802151 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802157:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80215e:	75 2a                	jne    80218a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802160:	83 ec 04             	sub    $0x4,%esp
  802163:	6a 07                	push   $0x7
  802165:	68 00 f0 bf ee       	push   $0xeebff000
  80216a:	6a 00                	push   $0x0
  80216c:	e8 2e ea ff ff       	call   800b9f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	85 c0                	test   %eax,%eax
  802176:	79 12                	jns    80218a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802178:	50                   	push   %eax
  802179:	68 d2 28 80 00       	push   $0x8028d2
  80217e:	6a 23                	push   $0x23
  802180:	68 00 2a 80 00       	push   $0x802a00
  802185:	e8 81 ff ff ff       	call   80210b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80218a:	8b 45 08             	mov    0x8(%ebp),%eax
  80218d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802192:	83 ec 08             	sub    $0x8,%esp
  802195:	68 bc 21 80 00       	push   $0x8021bc
  80219a:	6a 00                	push   $0x0
  80219c:	e8 49 eb ff ff       	call   800cea <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	79 12                	jns    8021ba <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021a8:	50                   	push   %eax
  8021a9:	68 d2 28 80 00       	push   $0x8028d2
  8021ae:	6a 2c                	push   $0x2c
  8021b0:	68 00 2a 80 00       	push   $0x802a00
  8021b5:	e8 51 ff ff ff       	call   80210b <_panic>
	}
}
  8021ba:	c9                   	leave  
  8021bb:	c3                   	ret    

008021bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021bd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021c4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021c7:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021cb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021d0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021d4:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021d6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021d9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021da:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8021dd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8021de:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021df:	c3                   	ret    

008021e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	c1 e8 16             	shr    $0x16,%eax
  8021eb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f7:	f6 c1 01             	test   $0x1,%cl
  8021fa:	74 1d                	je     802219 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fc:	c1 ea 0c             	shr    $0xc,%edx
  8021ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802206:	f6 c2 01             	test   $0x1,%dl
  802209:	74 0e                	je     802219 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220b:	c1 ea 0c             	shr    $0xc,%edx
  80220e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802215:	ef 
  802216:	0f b7 c0             	movzwl %ax,%eax
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
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
