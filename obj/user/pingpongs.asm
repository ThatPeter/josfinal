
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
  800058:	68 e0 22 80 00       	push   $0x8022e0
  80005d:	e8 b5 01 00 00       	call   800217 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f7 0a 00 00       	call   800b61 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 fa 22 80 00       	push   $0x8022fa
  800074:	e8 9e 01 00 00       	call   800217 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 fe 10 00 00       	call   801185 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 70 10 00 00       	call   80110a <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b bb a4 00 00 00    	mov    0xa4(%ebx),%edi
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
  8000c0:	68 10 23 80 00       	push   $0x802310
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
  8000e8:	e8 98 10 00 00       	call   801185 <ipc_send>
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
  800116:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800170:	e8 85 12 00 00       	call   8013fa <close_all>
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
  80027a:	e8 c1 1d 00 00       	call   802040 <__udivdi3>
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
  8002bd:	e8 ae 1e 00 00       	call   802170 <__umoddi3>
  8002c2:	83 c4 14             	add    $0x14,%esp
  8002c5:	0f be 80 40 23 80 00 	movsbl 0x802340(%eax),%eax
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
  8003c1:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
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
  800485:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  80048c:	85 d2                	test   %edx,%edx
  80048e:	75 18                	jne    8004a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800490:	50                   	push   %eax
  800491:	68 58 23 80 00       	push   $0x802358
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
  8004a9:	68 a5 27 80 00       	push   $0x8027a5
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
  8004cd:	b8 51 23 80 00       	mov    $0x802351,%eax
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
  800b48:	68 3f 26 80 00       	push   $0x80263f
  800b4d:	6a 23                	push   $0x23
  800b4f:	68 5c 26 80 00       	push   $0x80265c
  800b54:	e8 d2 13 00 00       	call   801f2b <_panic>

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
  800bc9:	68 3f 26 80 00       	push   $0x80263f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 5c 26 80 00       	push   $0x80265c
  800bd5:	e8 51 13 00 00       	call   801f2b <_panic>

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
  800c0b:	68 3f 26 80 00       	push   $0x80263f
  800c10:	6a 23                	push   $0x23
  800c12:	68 5c 26 80 00       	push   $0x80265c
  800c17:	e8 0f 13 00 00       	call   801f2b <_panic>

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
  800c4d:	68 3f 26 80 00       	push   $0x80263f
  800c52:	6a 23                	push   $0x23
  800c54:	68 5c 26 80 00       	push   $0x80265c
  800c59:	e8 cd 12 00 00       	call   801f2b <_panic>

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
  800c8f:	68 3f 26 80 00       	push   $0x80263f
  800c94:	6a 23                	push   $0x23
  800c96:	68 5c 26 80 00       	push   $0x80265c
  800c9b:	e8 8b 12 00 00       	call   801f2b <_panic>

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
  800cd1:	68 3f 26 80 00       	push   $0x80263f
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 5c 26 80 00       	push   $0x80265c
  800cdd:	e8 49 12 00 00       	call   801f2b <_panic>
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
  800d13:	68 3f 26 80 00       	push   $0x80263f
  800d18:	6a 23                	push   $0x23
  800d1a:	68 5c 26 80 00       	push   $0x80265c
  800d1f:	e8 07 12 00 00       	call   801f2b <_panic>

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
  800d77:	68 3f 26 80 00       	push   $0x80263f
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 5c 26 80 00       	push   $0x80265c
  800d83:	e8 a3 11 00 00       	call   801f2b <_panic>

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
  800e16:	68 6a 26 80 00       	push   $0x80266a
  800e1b:	6a 1e                	push   $0x1e
  800e1d:	68 7a 26 80 00       	push   $0x80267a
  800e22:	e8 04 11 00 00       	call   801f2b <_panic>
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
  800e40:	68 85 26 80 00       	push   $0x802685
  800e45:	6a 2c                	push   $0x2c
  800e47:	68 7a 26 80 00       	push   $0x80267a
  800e4c:	e8 da 10 00 00       	call   801f2b <_panic>
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
  800e88:	68 85 26 80 00       	push   $0x802685
  800e8d:	6a 33                	push   $0x33
  800e8f:	68 7a 26 80 00       	push   $0x80267a
  800e94:	e8 92 10 00 00       	call   801f2b <_panic>
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
  800eb0:	68 85 26 80 00       	push   $0x802685
  800eb5:	6a 37                	push   $0x37
  800eb7:	68 7a 26 80 00       	push   $0x80267a
  800ebc:	e8 6a 10 00 00       	call   801f2b <_panic>
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
  800ed4:	e8 98 10 00 00       	call   801f71 <set_pgfault_handler>
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
  800eed:	68 9e 26 80 00       	push   $0x80269e
  800ef2:	68 84 00 00 00       	push   $0x84
  800ef7:	68 7a 26 80 00       	push   $0x80267a
  800efc:	e8 2a 10 00 00       	call   801f2b <_panic>
  800f01:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f07:	75 24                	jne    800f2d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f09:	e8 53 fc ff ff       	call   800b61 <sys_getenvid>
  800f0e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f13:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800fa9:	68 ac 26 80 00       	push   $0x8026ac
  800fae:	6a 54                	push   $0x54
  800fb0:	68 7a 26 80 00       	push   $0x80267a
  800fb5:	e8 71 0f 00 00       	call   801f2b <_panic>
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
  800fee:	68 ac 26 80 00       	push   $0x8026ac
  800ff3:	6a 5b                	push   $0x5b
  800ff5:	68 7a 26 80 00       	push   $0x80267a
  800ffa:	e8 2c 0f 00 00       	call   801f2b <_panic>
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
  80101c:	68 ac 26 80 00       	push   $0x8026ac
  801021:	6a 5f                	push   $0x5f
  801023:	68 7a 26 80 00       	push   $0x80267a
  801028:	e8 fe 0e 00 00       	call   801f2b <_panic>
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
  801046:	68 ac 26 80 00       	push   $0x8026ac
  80104b:	6a 64                	push   $0x64
  80104d:	68 7a 26 80 00       	push   $0x80267a
  801052:	e8 d4 0e 00 00       	call   801f2b <_panic>
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
  80106e:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010ab:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	68 c4 26 80 00       	push   $0x8026c4
  8010ba:	e8 58 f1 ff ff       	call   800217 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010bf:	c7 04 24 4a 01 80 00 	movl   $0x80014a,(%esp)
  8010c6:	e8 c5 fc ff ff       	call   800d90 <sys_thread_create>
  8010cb:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	68 c4 26 80 00       	push   $0x8026c4
  8010d6:	e8 3c f1 ff ff       	call   800217 <cprintf>
	return id;
}
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8010ea:	ff 75 08             	pushl  0x8(%ebp)
  8010ed:	e8 be fc ff ff       	call   800db0 <sys_thread_free>
}
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8010fd:	ff 75 08             	pushl  0x8(%ebp)
  801100:	e8 cb fc ff ff       	call   800dd0 <sys_thread_join>
}
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	8b 75 08             	mov    0x8(%ebp),%esi
  801112:	8b 45 0c             	mov    0xc(%ebp),%eax
  801115:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801118:	85 c0                	test   %eax,%eax
  80111a:	75 12                	jne    80112e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	68 00 00 c0 ee       	push   $0xeec00000
  801124:	e8 26 fc ff ff       	call   800d4f <sys_ipc_recv>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	eb 0c                	jmp    80113a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	50                   	push   %eax
  801132:	e8 18 fc ff ff       	call   800d4f <sys_ipc_recv>
  801137:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80113a:	85 f6                	test   %esi,%esi
  80113c:	0f 95 c1             	setne  %cl
  80113f:	85 db                	test   %ebx,%ebx
  801141:	0f 95 c2             	setne  %dl
  801144:	84 d1                	test   %dl,%cl
  801146:	74 09                	je     801151 <ipc_recv+0x47>
  801148:	89 c2                	mov    %eax,%edx
  80114a:	c1 ea 1f             	shr    $0x1f,%edx
  80114d:	84 d2                	test   %dl,%dl
  80114f:	75 2d                	jne    80117e <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801151:	85 f6                	test   %esi,%esi
  801153:	74 0d                	je     801162 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801155:	a1 08 40 80 00       	mov    0x804008,%eax
  80115a:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801160:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801162:	85 db                	test   %ebx,%ebx
  801164:	74 0d                	je     801173 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801166:	a1 08 40 80 00       	mov    0x804008,%eax
  80116b:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801171:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801173:	a1 08 40 80 00       	mov    0x804008,%eax
  801178:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80117e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801191:	8b 75 0c             	mov    0xc(%ebp),%esi
  801194:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801197:	85 db                	test   %ebx,%ebx
  801199:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80119e:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011a1:	ff 75 14             	pushl  0x14(%ebp)
  8011a4:	53                   	push   %ebx
  8011a5:	56                   	push   %esi
  8011a6:	57                   	push   %edi
  8011a7:	e8 80 fb ff ff       	call   800d2c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 1f             	shr    $0x1f,%edx
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	84 d2                	test   %dl,%dl
  8011b6:	74 17                	je     8011cf <ipc_send+0x4a>
  8011b8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011bb:	74 12                	je     8011cf <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8011bd:	50                   	push   %eax
  8011be:	68 e7 26 80 00       	push   $0x8026e7
  8011c3:	6a 47                	push   $0x47
  8011c5:	68 f5 26 80 00       	push   $0x8026f5
  8011ca:	e8 5c 0d 00 00       	call   801f2b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8011cf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011d2:	75 07                	jne    8011db <ipc_send+0x56>
			sys_yield();
  8011d4:	e8 a7 f9 ff ff       	call   800b80 <sys_yield>
  8011d9:	eb c6                	jmp    8011a1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	75 c2                	jne    8011a1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f2:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8011f8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011fe:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801204:	39 ca                	cmp    %ecx,%edx
  801206:	75 13                	jne    80121b <ipc_find_env+0x34>
			return envs[i].env_id;
  801208:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80120e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801213:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801219:	eb 0f                	jmp    80122a <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80121b:	83 c0 01             	add    $0x1,%eax
  80121e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801223:	75 cd                	jne    8011f2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	05 00 00 00 30       	add    $0x30000000,%eax
  801237:	c1 e8 0c             	shr    $0xc,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	05 00 00 00 30       	add    $0x30000000,%eax
  801247:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80124c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801259:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125e:	89 c2                	mov    %eax,%edx
  801260:	c1 ea 16             	shr    $0x16,%edx
  801263:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126a:	f6 c2 01             	test   $0x1,%dl
  80126d:	74 11                	je     801280 <fd_alloc+0x2d>
  80126f:	89 c2                	mov    %eax,%edx
  801271:	c1 ea 0c             	shr    $0xc,%edx
  801274:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127b:	f6 c2 01             	test   $0x1,%dl
  80127e:	75 09                	jne    801289 <fd_alloc+0x36>
			*fd_store = fd;
  801280:	89 01                	mov    %eax,(%ecx)
			return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 17                	jmp    8012a0 <fd_alloc+0x4d>
  801289:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80128e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801293:	75 c9                	jne    80125e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801295:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80129b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a8:	83 f8 1f             	cmp    $0x1f,%eax
  8012ab:	77 36                	ja     8012e3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ad:	c1 e0 0c             	shl    $0xc,%eax
  8012b0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	c1 ea 16             	shr    $0x16,%edx
  8012ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 24                	je     8012ea <fd_lookup+0x48>
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 0c             	shr    $0xc,%edx
  8012cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	74 1a                	je     8012f1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012da:	89 02                	mov    %eax,(%edx)
	return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e1:	eb 13                	jmp    8012f6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e8:	eb 0c                	jmp    8012f6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ef:	eb 05                	jmp    8012f6 <fd_lookup+0x54>
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801301:	ba 7c 27 80 00       	mov    $0x80277c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801306:	eb 13                	jmp    80131b <dev_lookup+0x23>
  801308:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80130b:	39 08                	cmp    %ecx,(%eax)
  80130d:	75 0c                	jne    80131b <dev_lookup+0x23>
			*dev = devtab[i];
  80130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801312:	89 01                	mov    %eax,(%ecx)
			return 0;
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	eb 31                	jmp    80134c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131b:	8b 02                	mov    (%edx),%eax
  80131d:	85 c0                	test   %eax,%eax
  80131f:	75 e7                	jne    801308 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801321:	a1 08 40 80 00       	mov    0x804008,%eax
  801326:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80132c:	83 ec 04             	sub    $0x4,%esp
  80132f:	51                   	push   %ecx
  801330:	50                   	push   %eax
  801331:	68 00 27 80 00       	push   $0x802700
  801336:	e8 dc ee ff ff       	call   800217 <cprintf>
	*dev = 0;
  80133b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	56                   	push   %esi
  801352:	53                   	push   %ebx
  801353:	83 ec 10             	sub    $0x10,%esp
  801356:	8b 75 08             	mov    0x8(%ebp),%esi
  801359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801366:	c1 e8 0c             	shr    $0xc,%eax
  801369:	50                   	push   %eax
  80136a:	e8 33 ff ff ff       	call   8012a2 <fd_lookup>
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 05                	js     80137b <fd_close+0x2d>
	    || fd != fd2)
  801376:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801379:	74 0c                	je     801387 <fd_close+0x39>
		return (must_exist ? r : 0);
  80137b:	84 db                	test   %bl,%bl
  80137d:	ba 00 00 00 00       	mov    $0x0,%edx
  801382:	0f 44 c2             	cmove  %edx,%eax
  801385:	eb 41                	jmp    8013c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	ff 36                	pushl  (%esi)
  801390:	e8 63 ff ff ff       	call   8012f8 <dev_lookup>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 1a                	js     8013b8 <fd_close+0x6a>
		if (dev->dev_close)
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	74 0b                	je     8013b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	56                   	push   %esi
  8013b1:	ff d0                	call   *%eax
  8013b3:	89 c3                	mov    %eax,%ebx
  8013b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	56                   	push   %esi
  8013bc:	6a 00                	push   $0x0
  8013be:	e8 61 f8 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	89 d8                	mov    %ebx,%eax
}
  8013c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	ff 75 08             	pushl  0x8(%ebp)
  8013dc:	e8 c1 fe ff ff       	call   8012a2 <fd_lookup>
  8013e1:	83 c4 08             	add    $0x8,%esp
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 10                	js     8013f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	6a 01                	push   $0x1
  8013ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f0:	e8 59 ff ff ff       	call   80134e <fd_close>
  8013f5:	83 c4 10             	add    $0x10,%esp
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <close_all>:

void
close_all(void)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801401:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	53                   	push   %ebx
  80140a:	e8 c0 ff ff ff       	call   8013cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80140f:	83 c3 01             	add    $0x1,%ebx
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	83 fb 20             	cmp    $0x20,%ebx
  801418:	75 ec                	jne    801406 <close_all+0xc>
		close(i);
}
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	57                   	push   %edi
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 2c             	sub    $0x2c,%esp
  801428:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80142b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	ff 75 08             	pushl  0x8(%ebp)
  801432:	e8 6b fe ff ff       	call   8012a2 <fd_lookup>
  801437:	83 c4 08             	add    $0x8,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	0f 88 c1 00 00 00    	js     801503 <dup+0xe4>
		return r;
	close(newfdnum);
  801442:	83 ec 0c             	sub    $0xc,%esp
  801445:	56                   	push   %esi
  801446:	e8 84 ff ff ff       	call   8013cf <close>

	newfd = INDEX2FD(newfdnum);
  80144b:	89 f3                	mov    %esi,%ebx
  80144d:	c1 e3 0c             	shl    $0xc,%ebx
  801450:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801456:	83 c4 04             	add    $0x4,%esp
  801459:	ff 75 e4             	pushl  -0x1c(%ebp)
  80145c:	e8 db fd ff ff       	call   80123c <fd2data>
  801461:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801463:	89 1c 24             	mov    %ebx,(%esp)
  801466:	e8 d1 fd ff ff       	call   80123c <fd2data>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801471:	89 f8                	mov    %edi,%eax
  801473:	c1 e8 16             	shr    $0x16,%eax
  801476:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147d:	a8 01                	test   $0x1,%al
  80147f:	74 37                	je     8014b8 <dup+0x99>
  801481:	89 f8                	mov    %edi,%eax
  801483:	c1 e8 0c             	shr    $0xc,%eax
  801486:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80148d:	f6 c2 01             	test   $0x1,%dl
  801490:	74 26                	je     8014b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801492:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a1:	50                   	push   %eax
  8014a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a5:	6a 00                	push   $0x0
  8014a7:	57                   	push   %edi
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 33 f7 ff ff       	call   800be2 <sys_page_map>
  8014af:	89 c7                	mov    %eax,%edi
  8014b1:	83 c4 20             	add    $0x20,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 2e                	js     8014e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014bb:	89 d0                	mov    %edx,%eax
  8014bd:	c1 e8 0c             	shr    $0xc,%eax
  8014c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cf:	50                   	push   %eax
  8014d0:	53                   	push   %ebx
  8014d1:	6a 00                	push   $0x0
  8014d3:	52                   	push   %edx
  8014d4:	6a 00                	push   $0x0
  8014d6:	e8 07 f7 ff ff       	call   800be2 <sys_page_map>
  8014db:	89 c7                	mov    %eax,%edi
  8014dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e2:	85 ff                	test   %edi,%edi
  8014e4:	79 1d                	jns    801503 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	53                   	push   %ebx
  8014ea:	6a 00                	push   $0x0
  8014ec:	e8 33 f7 ff ff       	call   800c24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 26 f7 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	89 f8                	mov    %edi,%eax
}
  801503:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801506:	5b                   	pop    %ebx
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	53                   	push   %ebx
  80150f:	83 ec 14             	sub    $0x14,%esp
  801512:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801515:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	53                   	push   %ebx
  80151a:	e8 83 fd ff ff       	call   8012a2 <fd_lookup>
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	89 c2                	mov    %eax,%edx
  801524:	85 c0                	test   %eax,%eax
  801526:	78 70                	js     801598 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	ff 30                	pushl  (%eax)
  801534:	e8 bf fd ff ff       	call   8012f8 <dev_lookup>
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 4f                	js     80158f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801540:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801543:	8b 42 08             	mov    0x8(%edx),%eax
  801546:	83 e0 03             	and    $0x3,%eax
  801549:	83 f8 01             	cmp    $0x1,%eax
  80154c:	75 24                	jne    801572 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80154e:	a1 08 40 80 00       	mov    0x804008,%eax
  801553:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	53                   	push   %ebx
  80155d:	50                   	push   %eax
  80155e:	68 41 27 80 00       	push   $0x802741
  801563:	e8 af ec ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801570:	eb 26                	jmp    801598 <read+0x8d>
	}
	if (!dev->dev_read)
  801572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801575:	8b 40 08             	mov    0x8(%eax),%eax
  801578:	85 c0                	test   %eax,%eax
  80157a:	74 17                	je     801593 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	ff 75 10             	pushl  0x10(%ebp)
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	52                   	push   %edx
  801586:	ff d0                	call   *%eax
  801588:	89 c2                	mov    %eax,%edx
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	eb 09                	jmp    801598 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	89 c2                	mov    %eax,%edx
  801591:	eb 05                	jmp    801598 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801593:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801598:	89 d0                	mov    %edx,%eax
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	57                   	push   %edi
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b3:	eb 21                	jmp    8015d6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b5:	83 ec 04             	sub    $0x4,%esp
  8015b8:	89 f0                	mov    %esi,%eax
  8015ba:	29 d8                	sub    %ebx,%eax
  8015bc:	50                   	push   %eax
  8015bd:	89 d8                	mov    %ebx,%eax
  8015bf:	03 45 0c             	add    0xc(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	57                   	push   %edi
  8015c4:	e8 42 ff ff ff       	call   80150b <read>
		if (m < 0)
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 10                	js     8015e0 <readn+0x41>
			return m;
		if (m == 0)
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	74 0a                	je     8015de <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d4:	01 c3                	add    %eax,%ebx
  8015d6:	39 f3                	cmp    %esi,%ebx
  8015d8:	72 db                	jb     8015b5 <readn+0x16>
  8015da:	89 d8                	mov    %ebx,%eax
  8015dc:	eb 02                	jmp    8015e0 <readn+0x41>
  8015de:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5f                   	pop    %edi
  8015e6:	5d                   	pop    %ebp
  8015e7:	c3                   	ret    

008015e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  8015f7:	e8 a6 fc ff ff       	call   8012a2 <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 6b                	js     801670 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 e2 fc ff ff       	call   8012f8 <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 4a                	js     801667 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801624:	75 24                	jne    80164a <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801626:	a1 08 40 80 00       	mov    0x804008,%eax
  80162b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	53                   	push   %ebx
  801635:	50                   	push   %eax
  801636:	68 5d 27 80 00       	push   $0x80275d
  80163b:	e8 d7 eb ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801648:	eb 26                	jmp    801670 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164d:	8b 52 0c             	mov    0xc(%edx),%edx
  801650:	85 d2                	test   %edx,%edx
  801652:	74 17                	je     80166b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	ff 75 10             	pushl  0x10(%ebp)
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	50                   	push   %eax
  80165e:	ff d2                	call   *%edx
  801660:	89 c2                	mov    %eax,%edx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 09                	jmp    801670 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801667:	89 c2                	mov    %eax,%edx
  801669:	eb 05                	jmp    801670 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80166b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801670:	89 d0                	mov    %edx,%eax
  801672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <seek>:

int
seek(int fdnum, off_t offset)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 19 fc ff ff       	call   8012a2 <fd_lookup>
  801689:	83 c4 08             	add    $0x8,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 0e                	js     80169e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801690:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801693:	8b 55 0c             	mov    0xc(%ebp),%edx
  801696:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 14             	sub    $0x14,%esp
  8016a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	53                   	push   %ebx
  8016af:	e8 ee fb ff ff       	call   8012a2 <fd_lookup>
  8016b4:	83 c4 08             	add    $0x8,%esp
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 68                	js     801725 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c7:	ff 30                	pushl  (%eax)
  8016c9:	e8 2a fc ff ff       	call   8012f8 <dev_lookup>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 47                	js     80171c <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016dc:	75 24                	jne    801702 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016de:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	53                   	push   %ebx
  8016ed:	50                   	push   %eax
  8016ee:	68 20 27 80 00       	push   $0x802720
  8016f3:	e8 1f eb ff ff       	call   800217 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801700:	eb 23                	jmp    801725 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801702:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801705:	8b 52 18             	mov    0x18(%edx),%edx
  801708:	85 d2                	test   %edx,%edx
  80170a:	74 14                	je     801720 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	50                   	push   %eax
  801713:	ff d2                	call   *%edx
  801715:	89 c2                	mov    %eax,%edx
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	eb 09                	jmp    801725 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171c:	89 c2                	mov    %eax,%edx
  80171e:	eb 05                	jmp    801725 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801720:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801725:	89 d0                	mov    %edx,%eax
  801727:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	53                   	push   %ebx
  801730:	83 ec 14             	sub    $0x14,%esp
  801733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801736:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801739:	50                   	push   %eax
  80173a:	ff 75 08             	pushl  0x8(%ebp)
  80173d:	e8 60 fb ff ff       	call   8012a2 <fd_lookup>
  801742:	83 c4 08             	add    $0x8,%esp
  801745:	89 c2                	mov    %eax,%edx
  801747:	85 c0                	test   %eax,%eax
  801749:	78 58                	js     8017a3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	ff 30                	pushl  (%eax)
  801757:	e8 9c fb ff ff       	call   8012f8 <dev_lookup>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 37                	js     80179a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801766:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176a:	74 32                	je     80179e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80176f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801776:	00 00 00 
	stat->st_isdir = 0;
  801779:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801780:	00 00 00 
	stat->st_dev = dev;
  801783:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	53                   	push   %ebx
  80178d:	ff 75 f0             	pushl  -0x10(%ebp)
  801790:	ff 50 14             	call   *0x14(%eax)
  801793:	89 c2                	mov    %eax,%edx
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	eb 09                	jmp    8017a3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	eb 05                	jmp    8017a3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80179e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a3:	89 d0                	mov    %edx,%eax
  8017a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	6a 00                	push   $0x0
  8017b4:	ff 75 08             	pushl  0x8(%ebp)
  8017b7:	e8 e3 01 00 00       	call   80199f <open>
  8017bc:	89 c3                	mov    %eax,%ebx
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 1b                	js     8017e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 5b ff ff ff       	call   80172c <fstat>
  8017d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d3:	89 1c 24             	mov    %ebx,(%esp)
  8017d6:	e8 f4 fb ff ff       	call   8013cf <close>
	return r;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	89 f0                	mov    %esi,%eax
}
  8017e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5e                   	pop    %esi
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	89 c6                	mov    %eax,%esi
  8017ee:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f7:	75 12                	jne    80180b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	6a 01                	push   $0x1
  8017fe:	e8 e4 f9 ff ff       	call   8011e7 <ipc_find_env>
  801803:	a3 00 40 80 00       	mov    %eax,0x804000
  801808:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180b:	6a 07                	push   $0x7
  80180d:	68 00 50 80 00       	push   $0x805000
  801812:	56                   	push   %esi
  801813:	ff 35 00 40 80 00    	pushl  0x804000
  801819:	e8 67 f9 ff ff       	call   801185 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181e:	83 c4 0c             	add    $0xc,%esp
  801821:	6a 00                	push   $0x0
  801823:	53                   	push   %ebx
  801824:	6a 00                	push   $0x0
  801826:	e8 df f8 ff ff       	call   80110a <ipc_recv>
}
  80182b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	8b 40 0c             	mov    0xc(%eax),%eax
  80183e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801843:	8b 45 0c             	mov    0xc(%ebp),%eax
  801846:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184b:	ba 00 00 00 00       	mov    $0x0,%edx
  801850:	b8 02 00 00 00       	mov    $0x2,%eax
  801855:	e8 8d ff ff ff       	call   8017e7 <fsipc>
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 40 0c             	mov    0xc(%eax),%eax
  801868:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 06 00 00 00       	mov    $0x6,%eax
  801877:	e8 6b ff ff ff       	call   8017e7 <fsipc>
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 04             	sub    $0x4,%esp
  801885:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 40 0c             	mov    0xc(%eax),%eax
  80188e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801893:	ba 00 00 00 00       	mov    $0x0,%edx
  801898:	b8 05 00 00 00       	mov    $0x5,%eax
  80189d:	e8 45 ff ff ff       	call   8017e7 <fsipc>
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 2c                	js     8018d2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	68 00 50 80 00       	push   $0x805000
  8018ae:	53                   	push   %ebx
  8018af:	e8 e8 ee ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b4:	a1 80 50 80 00       	mov    0x805080,%eax
  8018b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018bf:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018ec:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018f6:	0f 47 c2             	cmova  %edx,%eax
  8018f9:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018fe:	50                   	push   %eax
  8018ff:	ff 75 0c             	pushl  0xc(%ebp)
  801902:	68 08 50 80 00       	push   $0x805008
  801907:	e8 22 f0 ff ff       	call   80092e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80190c:	ba 00 00 00 00       	mov    $0x0,%edx
  801911:	b8 04 00 00 00       	mov    $0x4,%eax
  801916:	e8 cc fe ff ff       	call   8017e7 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 40 0c             	mov    0xc(%eax),%eax
  80192b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801930:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 03 00 00 00       	mov    $0x3,%eax
  801940:	e8 a2 fe ff ff       	call   8017e7 <fsipc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	85 c0                	test   %eax,%eax
  801949:	78 4b                	js     801996 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80194b:	39 c6                	cmp    %eax,%esi
  80194d:	73 16                	jae    801965 <devfile_read+0x48>
  80194f:	68 8c 27 80 00       	push   $0x80278c
  801954:	68 93 27 80 00       	push   $0x802793
  801959:	6a 7c                	push   $0x7c
  80195b:	68 a8 27 80 00       	push   $0x8027a8
  801960:	e8 c6 05 00 00       	call   801f2b <_panic>
	assert(r <= PGSIZE);
  801965:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196a:	7e 16                	jle    801982 <devfile_read+0x65>
  80196c:	68 b3 27 80 00       	push   $0x8027b3
  801971:	68 93 27 80 00       	push   $0x802793
  801976:	6a 7d                	push   $0x7d
  801978:	68 a8 27 80 00       	push   $0x8027a8
  80197d:	e8 a9 05 00 00       	call   801f2b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801982:	83 ec 04             	sub    $0x4,%esp
  801985:	50                   	push   %eax
  801986:	68 00 50 80 00       	push   $0x805000
  80198b:	ff 75 0c             	pushl  0xc(%ebp)
  80198e:	e8 9b ef ff ff       	call   80092e <memmove>
	return r;
  801993:	83 c4 10             	add    $0x10,%esp
}
  801996:	89 d8                	mov    %ebx,%eax
  801998:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 20             	sub    $0x20,%esp
  8019a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a9:	53                   	push   %ebx
  8019aa:	e8 b4 ed ff ff       	call   800763 <strlen>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b7:	7f 67                	jg     801a20 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	e8 8e f8 ff ff       	call   801253 <fd_alloc>
  8019c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 57                	js     801a25 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	53                   	push   %ebx
  8019d2:	68 00 50 80 00       	push   $0x805000
  8019d7:	e8 c0 ed ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ec:	e8 f6 fd ff ff       	call   8017e7 <fsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	79 14                	jns    801a0e <open+0x6f>
		fd_close(fd, 0);
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	6a 00                	push   $0x0
  8019ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801a02:	e8 47 f9 ff ff       	call   80134e <fd_close>
		return r;
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	89 da                	mov    %ebx,%edx
  801a0c:	eb 17                	jmp    801a25 <open+0x86>
	}

	return fd2num(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	ff 75 f4             	pushl  -0xc(%ebp)
  801a14:	e8 13 f8 ff ff       	call   80122c <fd2num>
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	eb 05                	jmp    801a25 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a20:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a25:	89 d0                	mov    %edx,%eax
  801a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3c:	e8 a6 fd ff ff       	call   8017e7 <fsipc>
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	ff 75 08             	pushl  0x8(%ebp)
  801a51:	e8 e6 f7 ff ff       	call   80123c <fd2data>
  801a56:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a58:	83 c4 08             	add    $0x8,%esp
  801a5b:	68 bf 27 80 00       	push   $0x8027bf
  801a60:	53                   	push   %ebx
  801a61:	e8 36 ed ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a66:	8b 46 04             	mov    0x4(%esi),%eax
  801a69:	2b 06                	sub    (%esi),%eax
  801a6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a71:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a78:	00 00 00 
	stat->st_dev = &devpipe;
  801a7b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a82:	30 80 00 
	return 0;
}
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	53                   	push   %ebx
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a9b:	53                   	push   %ebx
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 81 f1 ff ff       	call   800c24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa3:	89 1c 24             	mov    %ebx,(%esp)
  801aa6:	e8 91 f7 ff ff       	call   80123c <fd2data>
  801aab:	83 c4 08             	add    $0x8,%esp
  801aae:	50                   	push   %eax
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 6e f1 ff ff       	call   800c24 <sys_page_unmap>
}
  801ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 1c             	sub    $0x1c,%esp
  801ac4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac9:	a1 08 40 80 00       	mov    0x804008,%eax
  801ace:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	ff 75 e0             	pushl  -0x20(%ebp)
  801ada:	e8 21 05 00 00       	call   802000 <pageref>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	89 3c 24             	mov    %edi,(%esp)
  801ae4:	e8 17 05 00 00       	call   802000 <pageref>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	39 c3                	cmp    %eax,%ebx
  801aee:	0f 94 c1             	sete   %cl
  801af1:	0f b6 c9             	movzbl %cl,%ecx
  801af4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801afd:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801b03:	39 ce                	cmp    %ecx,%esi
  801b05:	74 1e                	je     801b25 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b07:	39 c3                	cmp    %eax,%ebx
  801b09:	75 be                	jne    801ac9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b0b:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801b11:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b14:	50                   	push   %eax
  801b15:	56                   	push   %esi
  801b16:	68 c6 27 80 00       	push   $0x8027c6
  801b1b:	e8 f7 e6 ff ff       	call   800217 <cprintf>
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	eb a4                	jmp    801ac9 <_pipeisclosed+0xe>
	}
}
  801b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	57                   	push   %edi
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
  801b36:	83 ec 28             	sub    $0x28,%esp
  801b39:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b3c:	56                   	push   %esi
  801b3d:	e8 fa f6 ff ff       	call   80123c <fd2data>
  801b42:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	bf 00 00 00 00       	mov    $0x0,%edi
  801b4c:	eb 4b                	jmp    801b99 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b4e:	89 da                	mov    %ebx,%edx
  801b50:	89 f0                	mov    %esi,%eax
  801b52:	e8 64 ff ff ff       	call   801abb <_pipeisclosed>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	75 48                	jne    801ba3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b5b:	e8 20 f0 ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b60:	8b 43 04             	mov    0x4(%ebx),%eax
  801b63:	8b 0b                	mov    (%ebx),%ecx
  801b65:	8d 51 20             	lea    0x20(%ecx),%edx
  801b68:	39 d0                	cmp    %edx,%eax
  801b6a:	73 e2                	jae    801b4e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b73:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b76:	89 c2                	mov    %eax,%edx
  801b78:	c1 fa 1f             	sar    $0x1f,%edx
  801b7b:	89 d1                	mov    %edx,%ecx
  801b7d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b80:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b83:	83 e2 1f             	and    $0x1f,%edx
  801b86:	29 ca                	sub    %ecx,%edx
  801b88:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b8c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b90:	83 c0 01             	add    $0x1,%eax
  801b93:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b96:	83 c7 01             	add    $0x1,%edi
  801b99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b9c:	75 c2                	jne    801b60 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba1:	eb 05                	jmp    801ba8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5f                   	pop    %edi
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	83 ec 18             	sub    $0x18,%esp
  801bb9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bbc:	57                   	push   %edi
  801bbd:	e8 7a f6 ff ff       	call   80123c <fd2data>
  801bc2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bcc:	eb 3d                	jmp    801c0b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bce:	85 db                	test   %ebx,%ebx
  801bd0:	74 04                	je     801bd6 <devpipe_read+0x26>
				return i;
  801bd2:	89 d8                	mov    %ebx,%eax
  801bd4:	eb 44                	jmp    801c1a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bd6:	89 f2                	mov    %esi,%edx
  801bd8:	89 f8                	mov    %edi,%eax
  801bda:	e8 dc fe ff ff       	call   801abb <_pipeisclosed>
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	75 32                	jne    801c15 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801be3:	e8 98 ef ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801be8:	8b 06                	mov    (%esi),%eax
  801bea:	3b 46 04             	cmp    0x4(%esi),%eax
  801bed:	74 df                	je     801bce <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bef:	99                   	cltd   
  801bf0:	c1 ea 1b             	shr    $0x1b,%edx
  801bf3:	01 d0                	add    %edx,%eax
  801bf5:	83 e0 1f             	and    $0x1f,%eax
  801bf8:	29 d0                	sub    %edx,%eax
  801bfa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c02:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c05:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c08:	83 c3 01             	add    $0x1,%ebx
  801c0b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c0e:	75 d8                	jne    801be8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c10:	8b 45 10             	mov    0x10(%ebp),%eax
  801c13:	eb 05                	jmp    801c1a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2d:	50                   	push   %eax
  801c2e:	e8 20 f6 ff ff       	call   801253 <fd_alloc>
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	89 c2                	mov    %eax,%edx
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 2c 01 00 00    	js     801d6c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	68 07 04 00 00       	push   $0x407
  801c48:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 4d ef ff ff       	call   800b9f <sys_page_alloc>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	89 c2                	mov    %eax,%edx
  801c57:	85 c0                	test   %eax,%eax
  801c59:	0f 88 0d 01 00 00    	js     801d6c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c65:	50                   	push   %eax
  801c66:	e8 e8 f5 ff ff       	call   801253 <fd_alloc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 e2 00 00 00    	js     801d5a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	68 07 04 00 00       	push   $0x407
  801c80:	ff 75 f0             	pushl  -0x10(%ebp)
  801c83:	6a 00                	push   $0x0
  801c85:	e8 15 ef ff ff       	call   800b9f <sys_page_alloc>
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	0f 88 c3 00 00 00    	js     801d5a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c97:	83 ec 0c             	sub    $0xc,%esp
  801c9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9d:	e8 9a f5 ff ff       	call   80123c <fd2data>
  801ca2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca4:	83 c4 0c             	add    $0xc,%esp
  801ca7:	68 07 04 00 00       	push   $0x407
  801cac:	50                   	push   %eax
  801cad:	6a 00                	push   $0x0
  801caf:	e8 eb ee ff ff       	call   800b9f <sys_page_alloc>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	0f 88 89 00 00 00    	js     801d4a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc7:	e8 70 f5 ff ff       	call   80123c <fd2data>
  801ccc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cd3:	50                   	push   %eax
  801cd4:	6a 00                	push   $0x0
  801cd6:	56                   	push   %esi
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 04 ef ff ff       	call   800be2 <sys_page_map>
  801cde:	89 c3                	mov    %eax,%ebx
  801ce0:	83 c4 20             	add    $0x20,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 55                	js     801d3c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ce7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cfc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	ff 75 f4             	pushl  -0xc(%ebp)
  801d17:	e8 10 f5 ff ff       	call   80122c <fd2num>
  801d1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d21:	83 c4 04             	add    $0x4,%esp
  801d24:	ff 75 f0             	pushl  -0x10(%ebp)
  801d27:	e8 00 f5 ff ff       	call   80122c <fd2num>
  801d2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3a:	eb 30                	jmp    801d6c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d3c:	83 ec 08             	sub    $0x8,%esp
  801d3f:	56                   	push   %esi
  801d40:	6a 00                	push   $0x0
  801d42:	e8 dd ee ff ff       	call   800c24 <sys_page_unmap>
  801d47:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d4a:	83 ec 08             	sub    $0x8,%esp
  801d4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d50:	6a 00                	push   $0x0
  801d52:	e8 cd ee ff ff       	call   800c24 <sys_page_unmap>
  801d57:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d5a:	83 ec 08             	sub    $0x8,%esp
  801d5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d60:	6a 00                	push   $0x0
  801d62:	e8 bd ee ff ff       	call   800c24 <sys_page_unmap>
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d6c:	89 d0                	mov    %edx,%eax
  801d6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d71:	5b                   	pop    %ebx
  801d72:	5e                   	pop    %esi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7e:	50                   	push   %eax
  801d7f:	ff 75 08             	pushl  0x8(%ebp)
  801d82:	e8 1b f5 ff ff       	call   8012a2 <fd_lookup>
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 18                	js     801da6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d8e:	83 ec 0c             	sub    $0xc,%esp
  801d91:	ff 75 f4             	pushl  -0xc(%ebp)
  801d94:	e8 a3 f4 ff ff       	call   80123c <fd2data>
	return _pipeisclosed(fd, p);
  801d99:	89 c2                	mov    %eax,%edx
  801d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9e:	e8 18 fd ff ff       	call   801abb <_pipeisclosed>
  801da3:	83 c4 10             	add    $0x10,%esp
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dab:	b8 00 00 00 00       	mov    $0x0,%eax
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db8:	68 de 27 80 00       	push   $0x8027de
  801dbd:	ff 75 0c             	pushl  0xc(%ebp)
  801dc0:	e8 d7 e9 ff ff       	call   80079c <strcpy>
	return 0;
}
  801dc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	57                   	push   %edi
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de3:	eb 2d                	jmp    801e12 <devcons_write+0x46>
		m = n - tot;
  801de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dea:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ded:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	53                   	push   %ebx
  801df9:	03 45 0c             	add    0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	57                   	push   %edi
  801dfe:	e8 2b eb ff ff       	call   80092e <memmove>
		sys_cputs(buf, m);
  801e03:	83 c4 08             	add    $0x8,%esp
  801e06:	53                   	push   %ebx
  801e07:	57                   	push   %edi
  801e08:	e8 d6 ec ff ff       	call   800ae3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0d:	01 de                	add    %ebx,%esi
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	89 f0                	mov    %esi,%eax
  801e14:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e17:	72 cc                	jb     801de5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 08             	sub    $0x8,%esp
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e30:	74 2a                	je     801e5c <devcons_read+0x3b>
  801e32:	eb 05                	jmp    801e39 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e34:	e8 47 ed ff ff       	call   800b80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e39:	e8 c3 ec ff ff       	call   800b01 <sys_cgetc>
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	74 f2                	je     801e34 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 16                	js     801e5c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e46:	83 f8 04             	cmp    $0x4,%eax
  801e49:	74 0c                	je     801e57 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4e:	88 02                	mov    %al,(%edx)
	return 1;
  801e50:	b8 01 00 00 00       	mov    $0x1,%eax
  801e55:	eb 05                	jmp    801e5c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e57:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e64:	8b 45 08             	mov    0x8(%ebp),%eax
  801e67:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e6a:	6a 01                	push   $0x1
  801e6c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6f:	50                   	push   %eax
  801e70:	e8 6e ec ff ff       	call   800ae3 <sys_cputs>
}
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <getchar>:

int
getchar(void)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e80:	6a 01                	push   $0x1
  801e82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e85:	50                   	push   %eax
  801e86:	6a 00                	push   $0x0
  801e88:	e8 7e f6 ff ff       	call   80150b <read>
	if (r < 0)
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 0f                	js     801ea3 <getchar+0x29>
		return r;
	if (r < 1)
  801e94:	85 c0                	test   %eax,%eax
  801e96:	7e 06                	jle    801e9e <getchar+0x24>
		return -E_EOF;
	return c;
  801e98:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e9c:	eb 05                	jmp    801ea3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	ff 75 08             	pushl  0x8(%ebp)
  801eb2:	e8 eb f3 ff ff       	call   8012a2 <fd_lookup>
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 11                	js     801ecf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec7:	39 10                	cmp    %edx,(%eax)
  801ec9:	0f 94 c0             	sete   %al
  801ecc:	0f b6 c0             	movzbl %al,%eax
}
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <opencons>:

int
opencons(void)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eda:	50                   	push   %eax
  801edb:	e8 73 f3 ff ff       	call   801253 <fd_alloc>
  801ee0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 3e                	js     801f27 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee9:	83 ec 04             	sub    $0x4,%esp
  801eec:	68 07 04 00 00       	push   $0x407
  801ef1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef4:	6a 00                	push   $0x0
  801ef6:	e8 a4 ec ff ff       	call   800b9f <sys_page_alloc>
  801efb:	83 c4 10             	add    $0x10,%esp
		return r;
  801efe:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 23                	js     801f27 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	50                   	push   %eax
  801f1d:	e8 0a f3 ff ff       	call   80122c <fd2num>
  801f22:	89 c2                	mov    %eax,%edx
  801f24:	83 c4 10             	add    $0x10,%esp
}
  801f27:	89 d0                	mov    %edx,%eax
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f30:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f33:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f39:	e8 23 ec ff ff       	call   800b61 <sys_getenvid>
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	ff 75 0c             	pushl  0xc(%ebp)
  801f44:	ff 75 08             	pushl  0x8(%ebp)
  801f47:	56                   	push   %esi
  801f48:	50                   	push   %eax
  801f49:	68 ec 27 80 00       	push   $0x8027ec
  801f4e:	e8 c4 e2 ff ff       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f53:	83 c4 18             	add    $0x18,%esp
  801f56:	53                   	push   %ebx
  801f57:	ff 75 10             	pushl  0x10(%ebp)
  801f5a:	e8 67 e2 ff ff       	call   8001c6 <vcprintf>
	cprintf("\n");
  801f5f:	c7 04 24 d7 27 80 00 	movl   $0x8027d7,(%esp)
  801f66:	e8 ac e2 ff ff       	call   800217 <cprintf>
  801f6b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f6e:	cc                   	int3   
  801f6f:	eb fd                	jmp    801f6e <_panic+0x43>

00801f71 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f77:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f7e:	75 2a                	jne    801faa <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f80:	83 ec 04             	sub    $0x4,%esp
  801f83:	6a 07                	push   $0x7
  801f85:	68 00 f0 bf ee       	push   $0xeebff000
  801f8a:	6a 00                	push   $0x0
  801f8c:	e8 0e ec ff ff       	call   800b9f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	85 c0                	test   %eax,%eax
  801f96:	79 12                	jns    801faa <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f98:	50                   	push   %eax
  801f99:	68 10 28 80 00       	push   $0x802810
  801f9e:	6a 23                	push   $0x23
  801fa0:	68 14 28 80 00       	push   $0x802814
  801fa5:	e8 81 ff ff ff       	call   801f2b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801faa:	8b 45 08             	mov    0x8(%ebp),%eax
  801fad:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fb2:	83 ec 08             	sub    $0x8,%esp
  801fb5:	68 dc 1f 80 00       	push   $0x801fdc
  801fba:	6a 00                	push   $0x0
  801fbc:	e8 29 ed ff ff       	call   800cea <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	79 12                	jns    801fda <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fc8:	50                   	push   %eax
  801fc9:	68 10 28 80 00       	push   $0x802810
  801fce:	6a 2c                	push   $0x2c
  801fd0:	68 14 28 80 00       	push   $0x802814
  801fd5:	e8 51 ff ff ff       	call   801f2b <_panic>
	}
}
  801fda:	c9                   	leave  
  801fdb:	c3                   	ret    

00801fdc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fdc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fdd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fe2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fe4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fe7:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801feb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ff0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ff4:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ff6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ff9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ffa:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ffd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ffe:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fff:	c3                   	ret    

00802000 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802006:	89 d0                	mov    %edx,%eax
  802008:	c1 e8 16             	shr    $0x16,%eax
  80200b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802017:	f6 c1 01             	test   $0x1,%cl
  80201a:	74 1d                	je     802039 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80201c:	c1 ea 0c             	shr    $0xc,%edx
  80201f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802026:	f6 c2 01             	test   $0x1,%dl
  802029:	74 0e                	je     802039 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80202b:	c1 ea 0c             	shr    $0xc,%edx
  80202e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802035:	ef 
  802036:	0f b7 c0             	movzwl %ax,%eax
}
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	66 90                	xchg   %ax,%ax
  80203d:	66 90                	xchg   %ax,%ax
  80203f:	90                   	nop

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
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
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
