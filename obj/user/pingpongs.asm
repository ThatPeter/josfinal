
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
  800058:	68 40 25 80 00       	push   $0x802540
  80005d:	e8 b5 01 00 00       	call   800217 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f7 0a 00 00       	call   800b61 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 5a 25 80 00       	push   $0x80255a
  800074:	e8 9e 01 00 00       	call   800217 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 60 13 00 00       	call   8013e7 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 d2 12 00 00       	call   80136c <ipc_recv>
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
  8000c0:	68 70 25 80 00       	push   $0x802570
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
  8000e8:	e8 fa 12 00 00       	call   8013e7 <ipc_send>
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
  800170:	e8 e7 14 00 00       	call   80165c <close_all>
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
  80027a:	e8 21 20 00 00       	call   8022a0 <__udivdi3>
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
  8002bd:	e8 0e 21 00 00       	call   8023d0 <__umoddi3>
  8002c2:	83 c4 14             	add    $0x14,%esp
  8002c5:	0f be 80 a0 25 80 00 	movsbl 0x8025a0(%eax),%eax
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
  8003c1:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
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
  800485:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  80048c:	85 d2                	test   %edx,%edx
  80048e:	75 18                	jne    8004a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800490:	50                   	push   %eax
  800491:	68 b8 25 80 00       	push   $0x8025b8
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
  8004a9:	68 e5 2a 80 00       	push   $0x802ae5
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
  8004cd:	b8 b1 25 80 00       	mov    $0x8025b1,%eax
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
  800b48:	68 9f 28 80 00       	push   $0x80289f
  800b4d:	6a 23                	push   $0x23
  800b4f:	68 bc 28 80 00       	push   $0x8028bc
  800b54:	e8 34 16 00 00       	call   80218d <_panic>

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
  800bc9:	68 9f 28 80 00       	push   $0x80289f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 bc 28 80 00       	push   $0x8028bc
  800bd5:	e8 b3 15 00 00       	call   80218d <_panic>

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
  800c0b:	68 9f 28 80 00       	push   $0x80289f
  800c10:	6a 23                	push   $0x23
  800c12:	68 bc 28 80 00       	push   $0x8028bc
  800c17:	e8 71 15 00 00       	call   80218d <_panic>

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
  800c4d:	68 9f 28 80 00       	push   $0x80289f
  800c52:	6a 23                	push   $0x23
  800c54:	68 bc 28 80 00       	push   $0x8028bc
  800c59:	e8 2f 15 00 00       	call   80218d <_panic>

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
  800c8f:	68 9f 28 80 00       	push   $0x80289f
  800c94:	6a 23                	push   $0x23
  800c96:	68 bc 28 80 00       	push   $0x8028bc
  800c9b:	e8 ed 14 00 00       	call   80218d <_panic>

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
  800cd1:	68 9f 28 80 00       	push   $0x80289f
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 bc 28 80 00       	push   $0x8028bc
  800cdd:	e8 ab 14 00 00       	call   80218d <_panic>
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
  800d13:	68 9f 28 80 00       	push   $0x80289f
  800d18:	6a 23                	push   $0x23
  800d1a:	68 bc 28 80 00       	push   $0x8028bc
  800d1f:	e8 69 14 00 00       	call   80218d <_panic>

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
  800d77:	68 9f 28 80 00       	push   $0x80289f
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 bc 28 80 00       	push   $0x8028bc
  800d83:	e8 05 14 00 00       	call   80218d <_panic>

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
  800e16:	68 ca 28 80 00       	push   $0x8028ca
  800e1b:	6a 1f                	push   $0x1f
  800e1d:	68 da 28 80 00       	push   $0x8028da
  800e22:	e8 66 13 00 00       	call   80218d <_panic>
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
  800e40:	68 e5 28 80 00       	push   $0x8028e5
  800e45:	6a 2d                	push   $0x2d
  800e47:	68 da 28 80 00       	push   $0x8028da
  800e4c:	e8 3c 13 00 00       	call   80218d <_panic>
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
  800e88:	68 e5 28 80 00       	push   $0x8028e5
  800e8d:	6a 34                	push   $0x34
  800e8f:	68 da 28 80 00       	push   $0x8028da
  800e94:	e8 f4 12 00 00       	call   80218d <_panic>
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
  800eb0:	68 e5 28 80 00       	push   $0x8028e5
  800eb5:	6a 38                	push   $0x38
  800eb7:	68 da 28 80 00       	push   $0x8028da
  800ebc:	e8 cc 12 00 00       	call   80218d <_panic>
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
  800ed4:	e8 fa 12 00 00       	call   8021d3 <set_pgfault_handler>
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
  800eed:	68 fe 28 80 00       	push   $0x8028fe
  800ef2:	68 85 00 00 00       	push   $0x85
  800ef7:	68 da 28 80 00       	push   $0x8028da
  800efc:	e8 8c 12 00 00       	call   80218d <_panic>
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
  800fa9:	68 0c 29 80 00       	push   $0x80290c
  800fae:	6a 55                	push   $0x55
  800fb0:	68 da 28 80 00       	push   $0x8028da
  800fb5:	e8 d3 11 00 00       	call   80218d <_panic>
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
  800fee:	68 0c 29 80 00       	push   $0x80290c
  800ff3:	6a 5c                	push   $0x5c
  800ff5:	68 da 28 80 00       	push   $0x8028da
  800ffa:	e8 8e 11 00 00       	call   80218d <_panic>
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
  80101c:	68 0c 29 80 00       	push   $0x80290c
  801021:	6a 60                	push   $0x60
  801023:	68 da 28 80 00       	push   $0x8028da
  801028:	e8 60 11 00 00       	call   80218d <_panic>
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
  801046:	68 0c 29 80 00       	push   $0x80290c
  80104b:	6a 65                	push   $0x65
  80104d:	68 da 28 80 00       	push   $0x8028da
  801052:	e8 36 11 00 00       	call   80218d <_panic>
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
  8010b5:	68 9c 29 80 00       	push   $0x80299c
  8010ba:	e8 58 f1 ff ff       	call   800217 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010bf:	c7 04 24 4a 01 80 00 	movl   $0x80014a,(%esp)
  8010c6:	e8 c5 fc ff ff       	call   800d90 <sys_thread_create>
  8010cb:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	68 9c 29 80 00       	push   $0x80299c
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

0080110a <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	8b 75 08             	mov    0x8(%ebp),%esi
  801112:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	6a 07                	push   $0x7
  80111a:	6a 00                	push   $0x0
  80111c:	56                   	push   %esi
  80111d:	e8 7d fa ff ff       	call   800b9f <sys_page_alloc>
	if (r < 0) {
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	79 15                	jns    80113e <queue_append+0x34>
		panic("%e\n", r);
  801129:	50                   	push   %eax
  80112a:	68 98 29 80 00       	push   $0x802998
  80112f:	68 c4 00 00 00       	push   $0xc4
  801134:	68 da 28 80 00       	push   $0x8028da
  801139:	e8 4f 10 00 00       	call   80218d <_panic>
	}	
	wt->envid = envid;
  80113e:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	ff 33                	pushl  (%ebx)
  801149:	56                   	push   %esi
  80114a:	68 c0 29 80 00       	push   $0x8029c0
  80114f:	e8 c3 f0 ff ff       	call   800217 <cprintf>
	if (queue->first == NULL) {
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	83 3b 00             	cmpl   $0x0,(%ebx)
  80115a:	75 29                	jne    801185 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	68 22 29 80 00       	push   $0x802922
  801164:	e8 ae f0 ff ff       	call   800217 <cprintf>
		queue->first = wt;
  801169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80116f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801176:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80117d:	00 00 00 
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	eb 2b                	jmp    8011b0 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	68 3c 29 80 00       	push   $0x80293c
  80118d:	e8 85 f0 ff ff       	call   800217 <cprintf>
		queue->last->next = wt;
  801192:	8b 43 04             	mov    0x4(%ebx),%eax
  801195:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80119c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011a3:	00 00 00 
		queue->last = wt;
  8011a6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011ad:	83 c4 10             	add    $0x10,%esp
	}
}
  8011b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	75 17                	jne    8011de <queue_pop+0x27>
		panic("queue empty!\n");
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	68 5a 29 80 00       	push   $0x80295a
  8011cf:	68 d8 00 00 00       	push   $0xd8
  8011d4:	68 da 28 80 00       	push   $0x8028da
  8011d9:	e8 af 0f 00 00       	call   80218d <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011de:	8b 48 04             	mov    0x4(%eax),%ecx
  8011e1:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8011e3:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	53                   	push   %ebx
  8011e9:	68 68 29 80 00       	push   $0x802968
  8011ee:	e8 24 f0 ff ff       	call   800217 <cprintf>
	return envid;
}
  8011f3:	89 d8                	mov    %ebx,%eax
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801204:	b8 01 00 00 00       	mov    $0x1,%eax
  801209:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80120c:	85 c0                	test   %eax,%eax
  80120e:	74 5a                	je     80126a <mutex_lock+0x70>
  801210:	8b 43 04             	mov    0x4(%ebx),%eax
  801213:	83 38 00             	cmpl   $0x0,(%eax)
  801216:	75 52                	jne    80126a <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	68 e8 29 80 00       	push   $0x8029e8
  801220:	e8 f2 ef ff ff       	call   800217 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801225:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801228:	e8 34 f9 ff ff       	call   800b61 <sys_getenvid>
  80122d:	83 c4 08             	add    $0x8,%esp
  801230:	53                   	push   %ebx
  801231:	50                   	push   %eax
  801232:	e8 d3 fe ff ff       	call   80110a <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801237:	e8 25 f9 ff ff       	call   800b61 <sys_getenvid>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	6a 04                	push   $0x4
  801241:	50                   	push   %eax
  801242:	e8 1f fa ff ff       	call   800c66 <sys_env_set_status>
		if (r < 0) {
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	79 15                	jns    801263 <mutex_lock+0x69>
			panic("%e\n", r);
  80124e:	50                   	push   %eax
  80124f:	68 98 29 80 00       	push   $0x802998
  801254:	68 eb 00 00 00       	push   $0xeb
  801259:	68 da 28 80 00       	push   $0x8028da
  80125e:	e8 2a 0f 00 00       	call   80218d <_panic>
		}
		sys_yield();
  801263:	e8 18 f9 ff ff       	call   800b80 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801268:	eb 18                	jmp    801282 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80126a:	83 ec 0c             	sub    $0xc,%esp
  80126d:	68 08 2a 80 00       	push   $0x802a08
  801272:	e8 a0 ef ff ff       	call   800217 <cprintf>
	mtx->owner = sys_getenvid();}
  801277:	e8 e5 f8 ff ff       	call   800b61 <sys_getenvid>
  80127c:	89 43 08             	mov    %eax,0x8(%ebx)
  80127f:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	53                   	push   %ebx
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801299:	8b 43 04             	mov    0x4(%ebx),%eax
  80129c:	83 38 00             	cmpl   $0x0,(%eax)
  80129f:	74 33                	je     8012d4 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	50                   	push   %eax
  8012a5:	e8 0d ff ff ff       	call   8011b7 <queue_pop>
  8012aa:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	6a 02                	push   $0x2
  8012b2:	50                   	push   %eax
  8012b3:	e8 ae f9 ff ff       	call   800c66 <sys_env_set_status>
		if (r < 0) {
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	79 15                	jns    8012d4 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012bf:	50                   	push   %eax
  8012c0:	68 98 29 80 00       	push   $0x802998
  8012c5:	68 00 01 00 00       	push   $0x100
  8012ca:	68 da 28 80 00       	push   $0x8028da
  8012cf:	e8 b9 0e 00 00       	call   80218d <_panic>
		}
	}

	asm volatile("pause");
  8012d4:	f3 90                	pause  
	//sys_yield();
}
  8012d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	53                   	push   %ebx
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012e5:	e8 77 f8 ff ff       	call   800b61 <sys_getenvid>
  8012ea:	83 ec 04             	sub    $0x4,%esp
  8012ed:	6a 07                	push   $0x7
  8012ef:	53                   	push   %ebx
  8012f0:	50                   	push   %eax
  8012f1:	e8 a9 f8 ff ff       	call   800b9f <sys_page_alloc>
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	79 15                	jns    801312 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012fd:	50                   	push   %eax
  8012fe:	68 83 29 80 00       	push   $0x802983
  801303:	68 0d 01 00 00       	push   $0x10d
  801308:	68 da 28 80 00       	push   $0x8028da
  80130d:	e8 7b 0e 00 00       	call   80218d <_panic>
	}	
	mtx->locked = 0;
  801312:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801318:	8b 43 04             	mov    0x4(%ebx),%eax
  80131b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801321:	8b 43 04             	mov    0x4(%ebx),%eax
  801324:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80132b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80133d:	e8 1f f8 ff ff       	call   800b61 <sys_getenvid>
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	ff 75 08             	pushl  0x8(%ebp)
  801348:	50                   	push   %eax
  801349:	e8 d6 f8 ff ff       	call   800c24 <sys_page_unmap>
	if (r < 0) {
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	79 15                	jns    80136a <mutex_destroy+0x33>
		panic("%e\n", r);
  801355:	50                   	push   %eax
  801356:	68 98 29 80 00       	push   $0x802998
  80135b:	68 1a 01 00 00       	push   $0x11a
  801360:	68 da 28 80 00       	push   $0x8028da
  801365:	e8 23 0e 00 00       	call   80218d <_panic>
	}
}
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
  801371:	8b 75 08             	mov    0x8(%ebp),%esi
  801374:	8b 45 0c             	mov    0xc(%ebp),%eax
  801377:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80137a:	85 c0                	test   %eax,%eax
  80137c:	75 12                	jne    801390 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	68 00 00 c0 ee       	push   $0xeec00000
  801386:	e8 c4 f9 ff ff       	call   800d4f <sys_ipc_recv>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	eb 0c                	jmp    80139c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	50                   	push   %eax
  801394:	e8 b6 f9 ff ff       	call   800d4f <sys_ipc_recv>
  801399:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80139c:	85 f6                	test   %esi,%esi
  80139e:	0f 95 c1             	setne  %cl
  8013a1:	85 db                	test   %ebx,%ebx
  8013a3:	0f 95 c2             	setne  %dl
  8013a6:	84 d1                	test   %dl,%cl
  8013a8:	74 09                	je     8013b3 <ipc_recv+0x47>
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	c1 ea 1f             	shr    $0x1f,%edx
  8013af:	84 d2                	test   %dl,%dl
  8013b1:	75 2d                	jne    8013e0 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8013b3:	85 f6                	test   %esi,%esi
  8013b5:	74 0d                	je     8013c4 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8013b7:	a1 08 40 80 00       	mov    0x804008,%eax
  8013bc:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8013c2:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8013c4:	85 db                	test   %ebx,%ebx
  8013c6:	74 0d                	je     8013d5 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8013c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8013cd:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8013d3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8013d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8013da:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8013e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	57                   	push   %edi
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8013f9:	85 db                	test   %ebx,%ebx
  8013fb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801400:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801403:	ff 75 14             	pushl  0x14(%ebp)
  801406:	53                   	push   %ebx
  801407:	56                   	push   %esi
  801408:	57                   	push   %edi
  801409:	e8 1e f9 ff ff       	call   800d2c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80140e:	89 c2                	mov    %eax,%edx
  801410:	c1 ea 1f             	shr    $0x1f,%edx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	84 d2                	test   %dl,%dl
  801418:	74 17                	je     801431 <ipc_send+0x4a>
  80141a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80141d:	74 12                	je     801431 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80141f:	50                   	push   %eax
  801420:	68 28 2a 80 00       	push   $0x802a28
  801425:	6a 47                	push   $0x47
  801427:	68 36 2a 80 00       	push   $0x802a36
  80142c:	e8 5c 0d 00 00       	call   80218d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801431:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801434:	75 07                	jne    80143d <ipc_send+0x56>
			sys_yield();
  801436:	e8 45 f7 ff ff       	call   800b80 <sys_yield>
  80143b:	eb c6                	jmp    801403 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80143d:	85 c0                	test   %eax,%eax
  80143f:	75 c2                	jne    801403 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801441:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    

00801449 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801454:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80145a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801460:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801466:	39 ca                	cmp    %ecx,%edx
  801468:	75 13                	jne    80147d <ipc_find_env+0x34>
			return envs[i].env_id;
  80146a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801470:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801475:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80147b:	eb 0f                	jmp    80148c <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80147d:	83 c0 01             	add    $0x1,%eax
  801480:	3d 00 04 00 00       	cmp    $0x400,%eax
  801485:	75 cd                	jne    801454 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	05 00 00 00 30       	add    $0x30000000,%eax
  801499:	c1 e8 0c             	shr    $0xc,%eax
}
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8014a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c0:	89 c2                	mov    %eax,%edx
  8014c2:	c1 ea 16             	shr    $0x16,%edx
  8014c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cc:	f6 c2 01             	test   $0x1,%dl
  8014cf:	74 11                	je     8014e2 <fd_alloc+0x2d>
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	c1 ea 0c             	shr    $0xc,%edx
  8014d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014dd:	f6 c2 01             	test   $0x1,%dl
  8014e0:	75 09                	jne    8014eb <fd_alloc+0x36>
			*fd_store = fd;
  8014e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e9:	eb 17                	jmp    801502 <fd_alloc+0x4d>
  8014eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014f5:	75 c9                	jne    8014c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80150a:	83 f8 1f             	cmp    $0x1f,%eax
  80150d:	77 36                	ja     801545 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80150f:	c1 e0 0c             	shl    $0xc,%eax
  801512:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801517:	89 c2                	mov    %eax,%edx
  801519:	c1 ea 16             	shr    $0x16,%edx
  80151c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801523:	f6 c2 01             	test   $0x1,%dl
  801526:	74 24                	je     80154c <fd_lookup+0x48>
  801528:	89 c2                	mov    %eax,%edx
  80152a:	c1 ea 0c             	shr    $0xc,%edx
  80152d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801534:	f6 c2 01             	test   $0x1,%dl
  801537:	74 1a                	je     801553 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801539:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153c:	89 02                	mov    %eax,(%edx)
	return 0;
  80153e:	b8 00 00 00 00       	mov    $0x0,%eax
  801543:	eb 13                	jmp    801558 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801545:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154a:	eb 0c                	jmp    801558 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80154c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801551:	eb 05                	jmp    801558 <fd_lookup+0x54>
  801553:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801563:	ba bc 2a 80 00       	mov    $0x802abc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801568:	eb 13                	jmp    80157d <dev_lookup+0x23>
  80156a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80156d:	39 08                	cmp    %ecx,(%eax)
  80156f:	75 0c                	jne    80157d <dev_lookup+0x23>
			*dev = devtab[i];
  801571:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801574:	89 01                	mov    %eax,(%ecx)
			return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
  80157b:	eb 31                	jmp    8015ae <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80157d:	8b 02                	mov    (%edx),%eax
  80157f:	85 c0                	test   %eax,%eax
  801581:	75 e7                	jne    80156a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801583:	a1 08 40 80 00       	mov    0x804008,%eax
  801588:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	51                   	push   %ecx
  801592:	50                   	push   %eax
  801593:	68 40 2a 80 00       	push   $0x802a40
  801598:	e8 7a ec ff ff       	call   800217 <cprintf>
	*dev = 0;
  80159d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 10             	sub    $0x10,%esp
  8015b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015c8:	c1 e8 0c             	shr    $0xc,%eax
  8015cb:	50                   	push   %eax
  8015cc:	e8 33 ff ff ff       	call   801504 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 05                	js     8015dd <fd_close+0x2d>
	    || fd != fd2)
  8015d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015db:	74 0c                	je     8015e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015dd:	84 db                	test   %bl,%bl
  8015df:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e4:	0f 44 c2             	cmove  %edx,%eax
  8015e7:	eb 41                	jmp    80162a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	ff 36                	pushl  (%esi)
  8015f2:	e8 63 ff ff ff       	call   80155a <dev_lookup>
  8015f7:	89 c3                	mov    %eax,%ebx
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 1a                	js     80161a <fd_close+0x6a>
		if (dev->dev_close)
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801606:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80160b:	85 c0                	test   %eax,%eax
  80160d:	74 0b                	je     80161a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80160f:	83 ec 0c             	sub    $0xc,%esp
  801612:	56                   	push   %esi
  801613:	ff d0                	call   *%eax
  801615:	89 c3                	mov    %eax,%ebx
  801617:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	56                   	push   %esi
  80161e:	6a 00                	push   $0x0
  801620:	e8 ff f5 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	89 d8                	mov    %ebx,%eax
}
  80162a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162d:	5b                   	pop    %ebx
  80162e:	5e                   	pop    %esi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    

00801631 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801637:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	ff 75 08             	pushl  0x8(%ebp)
  80163e:	e8 c1 fe ff ff       	call   801504 <fd_lookup>
  801643:	83 c4 08             	add    $0x8,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 10                	js     80165a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	6a 01                	push   $0x1
  80164f:	ff 75 f4             	pushl  -0xc(%ebp)
  801652:	e8 59 ff ff ff       	call   8015b0 <fd_close>
  801657:	83 c4 10             	add    $0x10,%esp
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <close_all>:

void
close_all(void)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801663:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	53                   	push   %ebx
  80166c:	e8 c0 ff ff ff       	call   801631 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801671:	83 c3 01             	add    $0x1,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	83 fb 20             	cmp    $0x20,%ebx
  80167a:	75 ec                	jne    801668 <close_all+0xc>
		close(i);
}
  80167c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	57                   	push   %edi
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	83 ec 2c             	sub    $0x2c,%esp
  80168a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80168d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 6b fe ff ff       	call   801504 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	0f 88 c1 00 00 00    	js     801765 <dup+0xe4>
		return r;
	close(newfdnum);
  8016a4:	83 ec 0c             	sub    $0xc,%esp
  8016a7:	56                   	push   %esi
  8016a8:	e8 84 ff ff ff       	call   801631 <close>

	newfd = INDEX2FD(newfdnum);
  8016ad:	89 f3                	mov    %esi,%ebx
  8016af:	c1 e3 0c             	shl    $0xc,%ebx
  8016b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016b8:	83 c4 04             	add    $0x4,%esp
  8016bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016be:	e8 db fd ff ff       	call   80149e <fd2data>
  8016c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016c5:	89 1c 24             	mov    %ebx,(%esp)
  8016c8:	e8 d1 fd ff ff       	call   80149e <fd2data>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016d3:	89 f8                	mov    %edi,%eax
  8016d5:	c1 e8 16             	shr    $0x16,%eax
  8016d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016df:	a8 01                	test   $0x1,%al
  8016e1:	74 37                	je     80171a <dup+0x99>
  8016e3:	89 f8                	mov    %edi,%eax
  8016e5:	c1 e8 0c             	shr    $0xc,%eax
  8016e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ef:	f6 c2 01             	test   $0x1,%dl
  8016f2:	74 26                	je     80171a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016fb:	83 ec 0c             	sub    $0xc,%esp
  8016fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801703:	50                   	push   %eax
  801704:	ff 75 d4             	pushl  -0x2c(%ebp)
  801707:	6a 00                	push   $0x0
  801709:	57                   	push   %edi
  80170a:	6a 00                	push   $0x0
  80170c:	e8 d1 f4 ff ff       	call   800be2 <sys_page_map>
  801711:	89 c7                	mov    %eax,%edi
  801713:	83 c4 20             	add    $0x20,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 2e                	js     801748 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171d:	89 d0                	mov    %edx,%eax
  80171f:	c1 e8 0c             	shr    $0xc,%eax
  801722:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	25 07 0e 00 00       	and    $0xe07,%eax
  801731:	50                   	push   %eax
  801732:	53                   	push   %ebx
  801733:	6a 00                	push   $0x0
  801735:	52                   	push   %edx
  801736:	6a 00                	push   $0x0
  801738:	e8 a5 f4 ff ff       	call   800be2 <sys_page_map>
  80173d:	89 c7                	mov    %eax,%edi
  80173f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801742:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801744:	85 ff                	test   %edi,%edi
  801746:	79 1d                	jns    801765 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	e8 d1 f4 ff ff       	call   800c24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801753:	83 c4 08             	add    $0x8,%esp
  801756:	ff 75 d4             	pushl  -0x2c(%ebp)
  801759:	6a 00                	push   $0x0
  80175b:	e8 c4 f4 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	89 f8                	mov    %edi,%eax
}
  801765:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5f                   	pop    %edi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	53                   	push   %ebx
  801771:	83 ec 14             	sub    $0x14,%esp
  801774:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801777:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	53                   	push   %ebx
  80177c:	e8 83 fd ff ff       	call   801504 <fd_lookup>
  801781:	83 c4 08             	add    $0x8,%esp
  801784:	89 c2                	mov    %eax,%edx
  801786:	85 c0                	test   %eax,%eax
  801788:	78 70                	js     8017fa <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801790:	50                   	push   %eax
  801791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801794:	ff 30                	pushl  (%eax)
  801796:	e8 bf fd ff ff       	call   80155a <dev_lookup>
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 4f                	js     8017f1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a5:	8b 42 08             	mov    0x8(%edx),%eax
  8017a8:	83 e0 03             	and    $0x3,%eax
  8017ab:	83 f8 01             	cmp    $0x1,%eax
  8017ae:	75 24                	jne    8017d4 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8017b5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	53                   	push   %ebx
  8017bf:	50                   	push   %eax
  8017c0:	68 81 2a 80 00       	push   $0x802a81
  8017c5:	e8 4d ea ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017d2:	eb 26                	jmp    8017fa <read+0x8d>
	}
	if (!dev->dev_read)
  8017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d7:	8b 40 08             	mov    0x8(%eax),%eax
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	74 17                	je     8017f5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	ff 75 10             	pushl  0x10(%ebp)
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	52                   	push   %edx
  8017e8:	ff d0                	call   *%eax
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	eb 09                	jmp    8017fa <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	eb 05                	jmp    8017fa <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017fa:	89 d0                	mov    %edx,%eax
  8017fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	83 ec 0c             	sub    $0xc,%esp
  80180a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801810:	bb 00 00 00 00       	mov    $0x0,%ebx
  801815:	eb 21                	jmp    801838 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	89 f0                	mov    %esi,%eax
  80181c:	29 d8                	sub    %ebx,%eax
  80181e:	50                   	push   %eax
  80181f:	89 d8                	mov    %ebx,%eax
  801821:	03 45 0c             	add    0xc(%ebp),%eax
  801824:	50                   	push   %eax
  801825:	57                   	push   %edi
  801826:	e8 42 ff ff ff       	call   80176d <read>
		if (m < 0)
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 10                	js     801842 <readn+0x41>
			return m;
		if (m == 0)
  801832:	85 c0                	test   %eax,%eax
  801834:	74 0a                	je     801840 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801836:	01 c3                	add    %eax,%ebx
  801838:	39 f3                	cmp    %esi,%ebx
  80183a:	72 db                	jb     801817 <readn+0x16>
  80183c:	89 d8                	mov    %ebx,%eax
  80183e:	eb 02                	jmp    801842 <readn+0x41>
  801840:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801842:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5f                   	pop    %edi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	53                   	push   %ebx
  80184e:	83 ec 14             	sub    $0x14,%esp
  801851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	53                   	push   %ebx
  801859:	e8 a6 fc ff ff       	call   801504 <fd_lookup>
  80185e:	83 c4 08             	add    $0x8,%esp
  801861:	89 c2                	mov    %eax,%edx
  801863:	85 c0                	test   %eax,%eax
  801865:	78 6b                	js     8018d2 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186d:	50                   	push   %eax
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	ff 30                	pushl  (%eax)
  801873:	e8 e2 fc ff ff       	call   80155a <dev_lookup>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 4a                	js     8018c9 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801882:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801886:	75 24                	jne    8018ac <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801888:	a1 08 40 80 00       	mov    0x804008,%eax
  80188d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801893:	83 ec 04             	sub    $0x4,%esp
  801896:	53                   	push   %ebx
  801897:	50                   	push   %eax
  801898:	68 9d 2a 80 00       	push   $0x802a9d
  80189d:	e8 75 e9 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018aa:	eb 26                	jmp    8018d2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018af:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b2:	85 d2                	test   %edx,%edx
  8018b4:	74 17                	je     8018cd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	ff 75 10             	pushl  0x10(%ebp)
  8018bc:	ff 75 0c             	pushl  0xc(%ebp)
  8018bf:	50                   	push   %eax
  8018c0:	ff d2                	call   *%edx
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	eb 09                	jmp    8018d2 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	eb 05                	jmp    8018d2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018d2:	89 d0                	mov    %edx,%eax
  8018d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	ff 75 08             	pushl  0x8(%ebp)
  8018e6:	e8 19 fc ff ff       	call   801504 <fd_lookup>
  8018eb:	83 c4 08             	add    $0x8,%esp
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 0e                	js     801900 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 14             	sub    $0x14,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	53                   	push   %ebx
  801911:	e8 ee fb ff ff       	call   801504 <fd_lookup>
  801916:	83 c4 08             	add    $0x8,%esp
  801919:	89 c2                	mov    %eax,%edx
  80191b:	85 c0                	test   %eax,%eax
  80191d:	78 68                	js     801987 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801925:	50                   	push   %eax
  801926:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801929:	ff 30                	pushl  (%eax)
  80192b:	e8 2a fc ff ff       	call   80155a <dev_lookup>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 47                	js     80197e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80193e:	75 24                	jne    801964 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801940:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801945:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80194b:	83 ec 04             	sub    $0x4,%esp
  80194e:	53                   	push   %ebx
  80194f:	50                   	push   %eax
  801950:	68 60 2a 80 00       	push   $0x802a60
  801955:	e8 bd e8 ff ff       	call   800217 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801962:	eb 23                	jmp    801987 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801964:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801967:	8b 52 18             	mov    0x18(%edx),%edx
  80196a:	85 d2                	test   %edx,%edx
  80196c:	74 14                	je     801982 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	ff 75 0c             	pushl  0xc(%ebp)
  801974:	50                   	push   %eax
  801975:	ff d2                	call   *%edx
  801977:	89 c2                	mov    %eax,%edx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	eb 09                	jmp    801987 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197e:	89 c2                	mov    %eax,%edx
  801980:	eb 05                	jmp    801987 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801982:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801987:	89 d0                	mov    %edx,%eax
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	53                   	push   %ebx
  801992:	83 ec 14             	sub    $0x14,%esp
  801995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 60 fb ff ff       	call   801504 <fd_lookup>
  8019a4:	83 c4 08             	add    $0x8,%esp
  8019a7:	89 c2                	mov    %eax,%edx
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 58                	js     801a05 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b7:	ff 30                	pushl  (%eax)
  8019b9:	e8 9c fb ff ff       	call   80155a <dev_lookup>
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 37                	js     8019fc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019cc:	74 32                	je     801a00 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019d8:	00 00 00 
	stat->st_isdir = 0;
  8019db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e2:	00 00 00 
	stat->st_dev = dev;
  8019e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	53                   	push   %ebx
  8019ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f2:	ff 50 14             	call   *0x14(%eax)
  8019f5:	89 c2                	mov    %eax,%edx
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	eb 09                	jmp    801a05 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	eb 05                	jmp    801a05 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a00:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a05:	89 d0                	mov    %edx,%eax
  801a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	6a 00                	push   $0x0
  801a16:	ff 75 08             	pushl  0x8(%ebp)
  801a19:	e8 e3 01 00 00       	call   801c01 <open>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 1b                	js     801a42 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	50                   	push   %eax
  801a2e:	e8 5b ff ff ff       	call   80198e <fstat>
  801a33:	89 c6                	mov    %eax,%esi
	close(fd);
  801a35:	89 1c 24             	mov    %ebx,(%esp)
  801a38:	e8 f4 fb ff ff       	call   801631 <close>
	return r;
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	89 f0                	mov    %esi,%eax
}
  801a42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	89 c6                	mov    %eax,%esi
  801a50:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a52:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a59:	75 12                	jne    801a6d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	6a 01                	push   $0x1
  801a60:	e8 e4 f9 ff ff       	call   801449 <ipc_find_env>
  801a65:	a3 00 40 80 00       	mov    %eax,0x804000
  801a6a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a6d:	6a 07                	push   $0x7
  801a6f:	68 00 50 80 00       	push   $0x805000
  801a74:	56                   	push   %esi
  801a75:	ff 35 00 40 80 00    	pushl  0x804000
  801a7b:	e8 67 f9 ff ff       	call   8013e7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a80:	83 c4 0c             	add    $0xc,%esp
  801a83:	6a 00                	push   $0x0
  801a85:	53                   	push   %ebx
  801a86:	6a 00                	push   $0x0
  801a88:	e8 df f8 ff ff       	call   80136c <ipc_recv>
}
  801a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab7:	e8 8d ff ff ff       	call   801a49 <fsipc>
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ad9:	e8 6b ff ff ff       	call   801a49 <fsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	8b 40 0c             	mov    0xc(%eax),%eax
  801af0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801af5:	ba 00 00 00 00       	mov    $0x0,%edx
  801afa:	b8 05 00 00 00       	mov    $0x5,%eax
  801aff:	e8 45 ff ff ff       	call   801a49 <fsipc>
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 2c                	js     801b34 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b08:	83 ec 08             	sub    $0x8,%esp
  801b0b:	68 00 50 80 00       	push   $0x805000
  801b10:	53                   	push   %ebx
  801b11:	e8 86 ec ff ff       	call   80079c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b16:	a1 80 50 80 00       	mov    0x805080,%eax
  801b1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b21:	a1 84 50 80 00       	mov    0x805084,%eax
  801b26:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 0c             	sub    $0xc,%esp
  801b3f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b42:	8b 55 08             	mov    0x8(%ebp),%edx
  801b45:	8b 52 0c             	mov    0xc(%edx),%edx
  801b48:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b4e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b53:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b58:	0f 47 c2             	cmova  %edx,%eax
  801b5b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b60:	50                   	push   %eax
  801b61:	ff 75 0c             	pushl  0xc(%ebp)
  801b64:	68 08 50 80 00       	push   $0x805008
  801b69:	e8 c0 ed ff ff       	call   80092e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b73:	b8 04 00 00 00       	mov    $0x4,%eax
  801b78:	e8 cc fe ff ff       	call   801a49 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b92:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b98:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9d:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba2:	e8 a2 fe ff ff       	call   801a49 <fsipc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 4b                	js     801bf8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bad:	39 c6                	cmp    %eax,%esi
  801baf:	73 16                	jae    801bc7 <devfile_read+0x48>
  801bb1:	68 cc 2a 80 00       	push   $0x802acc
  801bb6:	68 d3 2a 80 00       	push   $0x802ad3
  801bbb:	6a 7c                	push   $0x7c
  801bbd:	68 e8 2a 80 00       	push   $0x802ae8
  801bc2:	e8 c6 05 00 00       	call   80218d <_panic>
	assert(r <= PGSIZE);
  801bc7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bcc:	7e 16                	jle    801be4 <devfile_read+0x65>
  801bce:	68 f3 2a 80 00       	push   $0x802af3
  801bd3:	68 d3 2a 80 00       	push   $0x802ad3
  801bd8:	6a 7d                	push   $0x7d
  801bda:	68 e8 2a 80 00       	push   $0x802ae8
  801bdf:	e8 a9 05 00 00       	call   80218d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	50                   	push   %eax
  801be8:	68 00 50 80 00       	push   $0x805000
  801bed:	ff 75 0c             	pushl  0xc(%ebp)
  801bf0:	e8 39 ed ff ff       	call   80092e <memmove>
	return r;
  801bf5:	83 c4 10             	add    $0x10,%esp
}
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	53                   	push   %ebx
  801c05:	83 ec 20             	sub    $0x20,%esp
  801c08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c0b:	53                   	push   %ebx
  801c0c:	e8 52 eb ff ff       	call   800763 <strlen>
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c19:	7f 67                	jg     801c82 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c21:	50                   	push   %eax
  801c22:	e8 8e f8 ff ff       	call   8014b5 <fd_alloc>
  801c27:	83 c4 10             	add    $0x10,%esp
		return r;
  801c2a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 57                	js     801c87 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c30:	83 ec 08             	sub    $0x8,%esp
  801c33:	53                   	push   %ebx
  801c34:	68 00 50 80 00       	push   $0x805000
  801c39:	e8 5e eb ff ff       	call   80079c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c41:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c49:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4e:	e8 f6 fd ff ff       	call   801a49 <fsipc>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	79 14                	jns    801c70 <open+0x6f>
		fd_close(fd, 0);
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	6a 00                	push   $0x0
  801c61:	ff 75 f4             	pushl  -0xc(%ebp)
  801c64:	e8 47 f9 ff ff       	call   8015b0 <fd_close>
		return r;
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	89 da                	mov    %ebx,%edx
  801c6e:	eb 17                	jmp    801c87 <open+0x86>
	}

	return fd2num(fd);
  801c70:	83 ec 0c             	sub    $0xc,%esp
  801c73:	ff 75 f4             	pushl  -0xc(%ebp)
  801c76:	e8 13 f8 ff ff       	call   80148e <fd2num>
  801c7b:	89 c2                	mov    %eax,%edx
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	eb 05                	jmp    801c87 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c82:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c87:	89 d0                	mov    %edx,%eax
  801c89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c94:	ba 00 00 00 00       	mov    $0x0,%edx
  801c99:	b8 08 00 00 00       	mov    $0x8,%eax
  801c9e:	e8 a6 fd ff ff       	call   801a49 <fsipc>
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	ff 75 08             	pushl  0x8(%ebp)
  801cb3:	e8 e6 f7 ff ff       	call   80149e <fd2data>
  801cb8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cba:	83 c4 08             	add    $0x8,%esp
  801cbd:	68 ff 2a 80 00       	push   $0x802aff
  801cc2:	53                   	push   %ebx
  801cc3:	e8 d4 ea ff ff       	call   80079c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc8:	8b 46 04             	mov    0x4(%esi),%eax
  801ccb:	2b 06                	sub    (%esi),%eax
  801ccd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cd3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cda:	00 00 00 
	stat->st_dev = &devpipe;
  801cdd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ce4:	30 80 00 
	return 0;
}
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cfd:	53                   	push   %ebx
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 1f ef ff ff       	call   800c24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d05:	89 1c 24             	mov    %ebx,(%esp)
  801d08:	e8 91 f7 ff ff       	call   80149e <fd2data>
  801d0d:	83 c4 08             	add    $0x8,%esp
  801d10:	50                   	push   %eax
  801d11:	6a 00                	push   $0x0
  801d13:	e8 0c ef ff ff       	call   800c24 <sys_page_unmap>
}
  801d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	57                   	push   %edi
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	83 ec 1c             	sub    $0x1c,%esp
  801d26:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d29:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d2b:	a1 08 40 80 00       	mov    0x804008,%eax
  801d30:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 e0             	pushl  -0x20(%ebp)
  801d3c:	e8 21 05 00 00       	call   802262 <pageref>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	89 3c 24             	mov    %edi,(%esp)
  801d46:	e8 17 05 00 00       	call   802262 <pageref>
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	39 c3                	cmp    %eax,%ebx
  801d50:	0f 94 c1             	sete   %cl
  801d53:	0f b6 c9             	movzbl %cl,%ecx
  801d56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d59:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d5f:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d65:	39 ce                	cmp    %ecx,%esi
  801d67:	74 1e                	je     801d87 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d69:	39 c3                	cmp    %eax,%ebx
  801d6b:	75 be                	jne    801d2b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d6d:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801d73:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d76:	50                   	push   %eax
  801d77:	56                   	push   %esi
  801d78:	68 06 2b 80 00       	push   $0x802b06
  801d7d:	e8 95 e4 ff ff       	call   800217 <cprintf>
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	eb a4                	jmp    801d2b <_pipeisclosed+0xe>
	}
}
  801d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 28             	sub    $0x28,%esp
  801d9b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d9e:	56                   	push   %esi
  801d9f:	e8 fa f6 ff ff       	call   80149e <fd2data>
  801da4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	bf 00 00 00 00       	mov    $0x0,%edi
  801dae:	eb 4b                	jmp    801dfb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801db0:	89 da                	mov    %ebx,%edx
  801db2:	89 f0                	mov    %esi,%eax
  801db4:	e8 64 ff ff ff       	call   801d1d <_pipeisclosed>
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	75 48                	jne    801e05 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dbd:	e8 be ed ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dc2:	8b 43 04             	mov    0x4(%ebx),%eax
  801dc5:	8b 0b                	mov    (%ebx),%ecx
  801dc7:	8d 51 20             	lea    0x20(%ecx),%edx
  801dca:	39 d0                	cmp    %edx,%eax
  801dcc:	73 e2                	jae    801db0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dd5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dd8:	89 c2                	mov    %eax,%edx
  801dda:	c1 fa 1f             	sar    $0x1f,%edx
  801ddd:	89 d1                	mov    %edx,%ecx
  801ddf:	c1 e9 1b             	shr    $0x1b,%ecx
  801de2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801de5:	83 e2 1f             	and    $0x1f,%edx
  801de8:	29 ca                	sub    %ecx,%edx
  801dea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801df2:	83 c0 01             	add    $0x1,%eax
  801df5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801df8:	83 c7 01             	add    $0x1,%edi
  801dfb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dfe:	75 c2                	jne    801dc2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e00:	8b 45 10             	mov    0x10(%ebp),%eax
  801e03:	eb 05                	jmp    801e0a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	83 ec 18             	sub    $0x18,%esp
  801e1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e1e:	57                   	push   %edi
  801e1f:	e8 7a f6 ff ff       	call   80149e <fd2data>
  801e24:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e2e:	eb 3d                	jmp    801e6d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e30:	85 db                	test   %ebx,%ebx
  801e32:	74 04                	je     801e38 <devpipe_read+0x26>
				return i;
  801e34:	89 d8                	mov    %ebx,%eax
  801e36:	eb 44                	jmp    801e7c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e38:	89 f2                	mov    %esi,%edx
  801e3a:	89 f8                	mov    %edi,%eax
  801e3c:	e8 dc fe ff ff       	call   801d1d <_pipeisclosed>
  801e41:	85 c0                	test   %eax,%eax
  801e43:	75 32                	jne    801e77 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e45:	e8 36 ed ff ff       	call   800b80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e4a:	8b 06                	mov    (%esi),%eax
  801e4c:	3b 46 04             	cmp    0x4(%esi),%eax
  801e4f:	74 df                	je     801e30 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e51:	99                   	cltd   
  801e52:	c1 ea 1b             	shr    $0x1b,%edx
  801e55:	01 d0                	add    %edx,%eax
  801e57:	83 e0 1f             	and    $0x1f,%eax
  801e5a:	29 d0                	sub    %edx,%eax
  801e5c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e64:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e67:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e6a:	83 c3 01             	add    $0x1,%ebx
  801e6d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e70:	75 d8                	jne    801e4a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e72:	8b 45 10             	mov    0x10(%ebp),%eax
  801e75:	eb 05                	jmp    801e7c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5f                   	pop    %edi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	e8 20 f6 ff ff       	call   8014b5 <fd_alloc>
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	89 c2                	mov    %eax,%edx
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	0f 88 2c 01 00 00    	js     801fce <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea2:	83 ec 04             	sub    $0x4,%esp
  801ea5:	68 07 04 00 00       	push   $0x407
  801eaa:	ff 75 f4             	pushl  -0xc(%ebp)
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 eb ec ff ff       	call   800b9f <sys_page_alloc>
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	89 c2                	mov    %eax,%edx
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	0f 88 0d 01 00 00    	js     801fce <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec7:	50                   	push   %eax
  801ec8:	e8 e8 f5 ff ff       	call   8014b5 <fd_alloc>
  801ecd:	89 c3                	mov    %eax,%ebx
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	0f 88 e2 00 00 00    	js     801fbc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eda:	83 ec 04             	sub    $0x4,%esp
  801edd:	68 07 04 00 00       	push   $0x407
  801ee2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee5:	6a 00                	push   $0x0
  801ee7:	e8 b3 ec ff ff       	call   800b9f <sys_page_alloc>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	0f 88 c3 00 00 00    	js     801fbc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	ff 75 f4             	pushl  -0xc(%ebp)
  801eff:	e8 9a f5 ff ff       	call   80149e <fd2data>
  801f04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f06:	83 c4 0c             	add    $0xc,%esp
  801f09:	68 07 04 00 00       	push   $0x407
  801f0e:	50                   	push   %eax
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 89 ec ff ff       	call   800b9f <sys_page_alloc>
  801f16:	89 c3                	mov    %eax,%ebx
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	0f 88 89 00 00 00    	js     801fac <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	ff 75 f0             	pushl  -0x10(%ebp)
  801f29:	e8 70 f5 ff ff       	call   80149e <fd2data>
  801f2e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f35:	50                   	push   %eax
  801f36:	6a 00                	push   $0x0
  801f38:	56                   	push   %esi
  801f39:	6a 00                	push   $0x0
  801f3b:	e8 a2 ec ff ff       	call   800be2 <sys_page_map>
  801f40:	89 c3                	mov    %eax,%ebx
  801f42:	83 c4 20             	add    $0x20,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 55                	js     801f9e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f49:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f5e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f73:	83 ec 0c             	sub    $0xc,%esp
  801f76:	ff 75 f4             	pushl  -0xc(%ebp)
  801f79:	e8 10 f5 ff ff       	call   80148e <fd2num>
  801f7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f83:	83 c4 04             	add    $0x4,%esp
  801f86:	ff 75 f0             	pushl  -0x10(%ebp)
  801f89:	e8 00 f5 ff ff       	call   80148e <fd2num>
  801f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f91:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9c:	eb 30                	jmp    801fce <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f9e:	83 ec 08             	sub    $0x8,%esp
  801fa1:	56                   	push   %esi
  801fa2:	6a 00                	push   $0x0
  801fa4:	e8 7b ec ff ff       	call   800c24 <sys_page_unmap>
  801fa9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fac:	83 ec 08             	sub    $0x8,%esp
  801faf:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb2:	6a 00                	push   $0x0
  801fb4:	e8 6b ec ff ff       	call   800c24 <sys_page_unmap>
  801fb9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fbc:	83 ec 08             	sub    $0x8,%esp
  801fbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 5b ec ff ff       	call   800c24 <sys_page_unmap>
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fce:	89 d0                	mov    %edx,%eax
  801fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	ff 75 08             	pushl  0x8(%ebp)
  801fe4:	e8 1b f5 ff ff       	call   801504 <fd_lookup>
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 18                	js     802008 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ff0:	83 ec 0c             	sub    $0xc,%esp
  801ff3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff6:	e8 a3 f4 ff ff       	call   80149e <fd2data>
	return _pipeisclosed(fd, p);
  801ffb:	89 c2                	mov    %eax,%edx
  801ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802000:	e8 18 fd ff ff       	call   801d1d <_pipeisclosed>
  802005:	83 c4 10             	add    $0x10,%esp
}
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80200d:	b8 00 00 00 00       	mov    $0x0,%eax
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    

00802014 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80201a:	68 1e 2b 80 00       	push   $0x802b1e
  80201f:	ff 75 0c             	pushl  0xc(%ebp)
  802022:	e8 75 e7 ff ff       	call   80079c <strcpy>
	return 0;
}
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
  80202c:	c9                   	leave  
  80202d:	c3                   	ret    

0080202e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80203f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802045:	eb 2d                	jmp    802074 <devcons_write+0x46>
		m = n - tot;
  802047:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80204a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80204c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80204f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802054:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802057:	83 ec 04             	sub    $0x4,%esp
  80205a:	53                   	push   %ebx
  80205b:	03 45 0c             	add    0xc(%ebp),%eax
  80205e:	50                   	push   %eax
  80205f:	57                   	push   %edi
  802060:	e8 c9 e8 ff ff       	call   80092e <memmove>
		sys_cputs(buf, m);
  802065:	83 c4 08             	add    $0x8,%esp
  802068:	53                   	push   %ebx
  802069:	57                   	push   %edi
  80206a:	e8 74 ea ff ff       	call   800ae3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80206f:	01 de                	add    %ebx,%esi
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	89 f0                	mov    %esi,%eax
  802076:	3b 75 10             	cmp    0x10(%ebp),%esi
  802079:	72 cc                	jb     802047 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80207b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207e:	5b                   	pop    %ebx
  80207f:	5e                   	pop    %esi
  802080:	5f                   	pop    %edi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    

00802083 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	83 ec 08             	sub    $0x8,%esp
  802089:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80208e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802092:	74 2a                	je     8020be <devcons_read+0x3b>
  802094:	eb 05                	jmp    80209b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802096:	e8 e5 ea ff ff       	call   800b80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80209b:	e8 61 ea ff ff       	call   800b01 <sys_cgetc>
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	74 f2                	je     802096 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	78 16                	js     8020be <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020a8:	83 f8 04             	cmp    $0x4,%eax
  8020ab:	74 0c                	je     8020b9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b0:	88 02                	mov    %al,(%edx)
	return 1;
  8020b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b7:	eb 05                	jmp    8020be <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020b9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    

008020c0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020cc:	6a 01                	push   $0x1
  8020ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d1:	50                   	push   %eax
  8020d2:	e8 0c ea ff ff       	call   800ae3 <sys_cputs>
}
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <getchar>:

int
getchar(void)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020e2:	6a 01                	push   $0x1
  8020e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e7:	50                   	push   %eax
  8020e8:	6a 00                	push   $0x0
  8020ea:	e8 7e f6 ff ff       	call   80176d <read>
	if (r < 0)
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 0f                	js     802105 <getchar+0x29>
		return r;
	if (r < 1)
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	7e 06                	jle    802100 <getchar+0x24>
		return -E_EOF;
	return c;
  8020fa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020fe:	eb 05                	jmp    802105 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802100:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802105:	c9                   	leave  
  802106:	c3                   	ret    

00802107 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802110:	50                   	push   %eax
  802111:	ff 75 08             	pushl  0x8(%ebp)
  802114:	e8 eb f3 ff ff       	call   801504 <fd_lookup>
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	85 c0                	test   %eax,%eax
  80211e:	78 11                	js     802131 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802120:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802123:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802129:	39 10                	cmp    %edx,(%eax)
  80212b:	0f 94 c0             	sete   %al
  80212e:	0f b6 c0             	movzbl %al,%eax
}
  802131:	c9                   	leave  
  802132:	c3                   	ret    

00802133 <opencons>:

int
opencons(void)
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802139:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213c:	50                   	push   %eax
  80213d:	e8 73 f3 ff ff       	call   8014b5 <fd_alloc>
  802142:	83 c4 10             	add    $0x10,%esp
		return r;
  802145:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802147:	85 c0                	test   %eax,%eax
  802149:	78 3e                	js     802189 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214b:	83 ec 04             	sub    $0x4,%esp
  80214e:	68 07 04 00 00       	push   $0x407
  802153:	ff 75 f4             	pushl  -0xc(%ebp)
  802156:	6a 00                	push   $0x0
  802158:	e8 42 ea ff ff       	call   800b9f <sys_page_alloc>
  80215d:	83 c4 10             	add    $0x10,%esp
		return r;
  802160:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802162:	85 c0                	test   %eax,%eax
  802164:	78 23                	js     802189 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802166:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80216c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802174:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80217b:	83 ec 0c             	sub    $0xc,%esp
  80217e:	50                   	push   %eax
  80217f:	e8 0a f3 ff ff       	call   80148e <fd2num>
  802184:	89 c2                	mov    %eax,%edx
  802186:	83 c4 10             	add    $0x10,%esp
}
  802189:	89 d0                	mov    %edx,%eax
  80218b:	c9                   	leave  
  80218c:	c3                   	ret    

0080218d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	56                   	push   %esi
  802191:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802192:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802195:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80219b:	e8 c1 e9 ff ff       	call   800b61 <sys_getenvid>
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 0c             	pushl  0xc(%ebp)
  8021a6:	ff 75 08             	pushl  0x8(%ebp)
  8021a9:	56                   	push   %esi
  8021aa:	50                   	push   %eax
  8021ab:	68 2c 2b 80 00       	push   $0x802b2c
  8021b0:	e8 62 e0 ff ff       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021b5:	83 c4 18             	add    $0x18,%esp
  8021b8:	53                   	push   %ebx
  8021b9:	ff 75 10             	pushl  0x10(%ebp)
  8021bc:	e8 05 e0 ff ff       	call   8001c6 <vcprintf>
	cprintf("\n");
  8021c1:	c7 04 24 66 29 80 00 	movl   $0x802966,(%esp)
  8021c8:	e8 4a e0 ff ff       	call   800217 <cprintf>
  8021cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021d0:	cc                   	int3   
  8021d1:	eb fd                	jmp    8021d0 <_panic+0x43>

008021d3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021d9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021e0:	75 2a                	jne    80220c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021e2:	83 ec 04             	sub    $0x4,%esp
  8021e5:	6a 07                	push   $0x7
  8021e7:	68 00 f0 bf ee       	push   $0xeebff000
  8021ec:	6a 00                	push   $0x0
  8021ee:	e8 ac e9 ff ff       	call   800b9f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	79 12                	jns    80220c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021fa:	50                   	push   %eax
  8021fb:	68 98 29 80 00       	push   $0x802998
  802200:	6a 23                	push   $0x23
  802202:	68 50 2b 80 00       	push   $0x802b50
  802207:	e8 81 ff ff ff       	call   80218d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802214:	83 ec 08             	sub    $0x8,%esp
  802217:	68 3e 22 80 00       	push   $0x80223e
  80221c:	6a 00                	push   $0x0
  80221e:	e8 c7 ea ff ff       	call   800cea <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802223:	83 c4 10             	add    $0x10,%esp
  802226:	85 c0                	test   %eax,%eax
  802228:	79 12                	jns    80223c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80222a:	50                   	push   %eax
  80222b:	68 98 29 80 00       	push   $0x802998
  802230:	6a 2c                	push   $0x2c
  802232:	68 50 2b 80 00       	push   $0x802b50
  802237:	e8 51 ff ff ff       	call   80218d <_panic>
	}
}
  80223c:	c9                   	leave  
  80223d:	c3                   	ret    

0080223e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80223e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80223f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802244:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802246:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802249:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80224d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802252:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802256:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802258:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80225b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80225c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80225f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802260:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802261:	c3                   	ret    

00802262 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802268:	89 d0                	mov    %edx,%eax
  80226a:	c1 e8 16             	shr    $0x16,%eax
  80226d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802274:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802279:	f6 c1 01             	test   $0x1,%cl
  80227c:	74 1d                	je     80229b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80227e:	c1 ea 0c             	shr    $0xc,%edx
  802281:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802288:	f6 c2 01             	test   $0x1,%dl
  80228b:	74 0e                	je     80229b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80228d:	c1 ea 0c             	shr    $0xc,%edx
  802290:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802297:	ef 
  802298:	0f b7 c0             	movzwl %ax,%eax
}
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__udivdi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 f6                	test   %esi,%esi
  8022b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022bd:	89 ca                	mov    %ecx,%edx
  8022bf:	89 f8                	mov    %edi,%eax
  8022c1:	75 3d                	jne    802300 <__udivdi3+0x60>
  8022c3:	39 cf                	cmp    %ecx,%edi
  8022c5:	0f 87 c5 00 00 00    	ja     802390 <__udivdi3+0xf0>
  8022cb:	85 ff                	test   %edi,%edi
  8022cd:	89 fd                	mov    %edi,%ebp
  8022cf:	75 0b                	jne    8022dc <__udivdi3+0x3c>
  8022d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d6:	31 d2                	xor    %edx,%edx
  8022d8:	f7 f7                	div    %edi
  8022da:	89 c5                	mov    %eax,%ebp
  8022dc:	89 c8                	mov    %ecx,%eax
  8022de:	31 d2                	xor    %edx,%edx
  8022e0:	f7 f5                	div    %ebp
  8022e2:	89 c1                	mov    %eax,%ecx
  8022e4:	89 d8                	mov    %ebx,%eax
  8022e6:	89 cf                	mov    %ecx,%edi
  8022e8:	f7 f5                	div    %ebp
  8022ea:	89 c3                	mov    %eax,%ebx
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	39 ce                	cmp    %ecx,%esi
  802302:	77 74                	ja     802378 <__udivdi3+0xd8>
  802304:	0f bd fe             	bsr    %esi,%edi
  802307:	83 f7 1f             	xor    $0x1f,%edi
  80230a:	0f 84 98 00 00 00    	je     8023a8 <__udivdi3+0x108>
  802310:	bb 20 00 00 00       	mov    $0x20,%ebx
  802315:	89 f9                	mov    %edi,%ecx
  802317:	89 c5                	mov    %eax,%ebp
  802319:	29 fb                	sub    %edi,%ebx
  80231b:	d3 e6                	shl    %cl,%esi
  80231d:	89 d9                	mov    %ebx,%ecx
  80231f:	d3 ed                	shr    %cl,%ebp
  802321:	89 f9                	mov    %edi,%ecx
  802323:	d3 e0                	shl    %cl,%eax
  802325:	09 ee                	or     %ebp,%esi
  802327:	89 d9                	mov    %ebx,%ecx
  802329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80232d:	89 d5                	mov    %edx,%ebp
  80232f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802333:	d3 ed                	shr    %cl,%ebp
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e2                	shl    %cl,%edx
  802339:	89 d9                	mov    %ebx,%ecx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	09 c2                	or     %eax,%edx
  80233f:	89 d0                	mov    %edx,%eax
  802341:	89 ea                	mov    %ebp,%edx
  802343:	f7 f6                	div    %esi
  802345:	89 d5                	mov    %edx,%ebp
  802347:	89 c3                	mov    %eax,%ebx
  802349:	f7 64 24 0c          	mull   0xc(%esp)
  80234d:	39 d5                	cmp    %edx,%ebp
  80234f:	72 10                	jb     802361 <__udivdi3+0xc1>
  802351:	8b 74 24 08          	mov    0x8(%esp),%esi
  802355:	89 f9                	mov    %edi,%ecx
  802357:	d3 e6                	shl    %cl,%esi
  802359:	39 c6                	cmp    %eax,%esi
  80235b:	73 07                	jae    802364 <__udivdi3+0xc4>
  80235d:	39 d5                	cmp    %edx,%ebp
  80235f:	75 03                	jne    802364 <__udivdi3+0xc4>
  802361:	83 eb 01             	sub    $0x1,%ebx
  802364:	31 ff                	xor    %edi,%edi
  802366:	89 d8                	mov    %ebx,%eax
  802368:	89 fa                	mov    %edi,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	31 ff                	xor    %edi,%edi
  80237a:	31 db                	xor    %ebx,%ebx
  80237c:	89 d8                	mov    %ebx,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 1c             	add    $0x1c,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5f                   	pop    %edi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	90                   	nop
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	89 d8                	mov    %ebx,%eax
  802392:	f7 f7                	div    %edi
  802394:	31 ff                	xor    %edi,%edi
  802396:	89 c3                	mov    %eax,%ebx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 fa                	mov    %edi,%edx
  80239c:	83 c4 1c             	add    $0x1c,%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	39 ce                	cmp    %ecx,%esi
  8023aa:	72 0c                	jb     8023b8 <__udivdi3+0x118>
  8023ac:	31 db                	xor    %ebx,%ebx
  8023ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023b2:	0f 87 34 ff ff ff    	ja     8022ec <__udivdi3+0x4c>
  8023b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023bd:	e9 2a ff ff ff       	jmp    8022ec <__udivdi3+0x4c>
  8023c2:	66 90                	xchg   %ax,%ax
  8023c4:	66 90                	xchg   %ax,%ax
  8023c6:	66 90                	xchg   %ax,%ax
  8023c8:	66 90                	xchg   %ax,%ax
  8023ca:	66 90                	xchg   %ax,%ax
  8023cc:	66 90                	xchg   %ax,%ax
  8023ce:	66 90                	xchg   %ax,%ax

008023d0 <__umoddi3>:
  8023d0:	55                   	push   %ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 1c             	sub    $0x1c,%esp
  8023d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023e7:	85 d2                	test   %edx,%edx
  8023e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023f1:	89 f3                	mov    %esi,%ebx
  8023f3:	89 3c 24             	mov    %edi,(%esp)
  8023f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023fa:	75 1c                	jne    802418 <__umoddi3+0x48>
  8023fc:	39 f7                	cmp    %esi,%edi
  8023fe:	76 50                	jbe    802450 <__umoddi3+0x80>
  802400:	89 c8                	mov    %ecx,%eax
  802402:	89 f2                	mov    %esi,%edx
  802404:	f7 f7                	div    %edi
  802406:	89 d0                	mov    %edx,%eax
  802408:	31 d2                	xor    %edx,%edx
  80240a:	83 c4 1c             	add    $0x1c,%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	39 f2                	cmp    %esi,%edx
  80241a:	89 d0                	mov    %edx,%eax
  80241c:	77 52                	ja     802470 <__umoddi3+0xa0>
  80241e:	0f bd ea             	bsr    %edx,%ebp
  802421:	83 f5 1f             	xor    $0x1f,%ebp
  802424:	75 5a                	jne    802480 <__umoddi3+0xb0>
  802426:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80242a:	0f 82 e0 00 00 00    	jb     802510 <__umoddi3+0x140>
  802430:	39 0c 24             	cmp    %ecx,(%esp)
  802433:	0f 86 d7 00 00 00    	jbe    802510 <__umoddi3+0x140>
  802439:	8b 44 24 08          	mov    0x8(%esp),%eax
  80243d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802441:	83 c4 1c             	add    $0x1c,%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	85 ff                	test   %edi,%edi
  802452:	89 fd                	mov    %edi,%ebp
  802454:	75 0b                	jne    802461 <__umoddi3+0x91>
  802456:	b8 01 00 00 00       	mov    $0x1,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	f7 f7                	div    %edi
  80245f:	89 c5                	mov    %eax,%ebp
  802461:	89 f0                	mov    %esi,%eax
  802463:	31 d2                	xor    %edx,%edx
  802465:	f7 f5                	div    %ebp
  802467:	89 c8                	mov    %ecx,%eax
  802469:	f7 f5                	div    %ebp
  80246b:	89 d0                	mov    %edx,%eax
  80246d:	eb 99                	jmp    802408 <__umoddi3+0x38>
  80246f:	90                   	nop
  802470:	89 c8                	mov    %ecx,%eax
  802472:	89 f2                	mov    %esi,%edx
  802474:	83 c4 1c             	add    $0x1c,%esp
  802477:	5b                   	pop    %ebx
  802478:	5e                   	pop    %esi
  802479:	5f                   	pop    %edi
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    
  80247c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802480:	8b 34 24             	mov    (%esp),%esi
  802483:	bf 20 00 00 00       	mov    $0x20,%edi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	29 ef                	sub    %ebp,%edi
  80248c:	d3 e0                	shl    %cl,%eax
  80248e:	89 f9                	mov    %edi,%ecx
  802490:	89 f2                	mov    %esi,%edx
  802492:	d3 ea                	shr    %cl,%edx
  802494:	89 e9                	mov    %ebp,%ecx
  802496:	09 c2                	or     %eax,%edx
  802498:	89 d8                	mov    %ebx,%eax
  80249a:	89 14 24             	mov    %edx,(%esp)
  80249d:	89 f2                	mov    %esi,%edx
  80249f:	d3 e2                	shl    %cl,%edx
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	89 e9                	mov    %ebp,%ecx
  8024af:	89 c6                	mov    %eax,%esi
  8024b1:	d3 e3                	shl    %cl,%ebx
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 d0                	mov    %edx,%eax
  8024b7:	d3 e8                	shr    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	09 d8                	or     %ebx,%eax
  8024bd:	89 d3                	mov    %edx,%ebx
  8024bf:	89 f2                	mov    %esi,%edx
  8024c1:	f7 34 24             	divl   (%esp)
  8024c4:	89 d6                	mov    %edx,%esi
  8024c6:	d3 e3                	shl    %cl,%ebx
  8024c8:	f7 64 24 04          	mull   0x4(%esp)
  8024cc:	39 d6                	cmp    %edx,%esi
  8024ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024d2:	89 d1                	mov    %edx,%ecx
  8024d4:	89 c3                	mov    %eax,%ebx
  8024d6:	72 08                	jb     8024e0 <__umoddi3+0x110>
  8024d8:	75 11                	jne    8024eb <__umoddi3+0x11b>
  8024da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024de:	73 0b                	jae    8024eb <__umoddi3+0x11b>
  8024e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024e4:	1b 14 24             	sbb    (%esp),%edx
  8024e7:	89 d1                	mov    %edx,%ecx
  8024e9:	89 c3                	mov    %eax,%ebx
  8024eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024ef:	29 da                	sub    %ebx,%edx
  8024f1:	19 ce                	sbb    %ecx,%esi
  8024f3:	89 f9                	mov    %edi,%ecx
  8024f5:	89 f0                	mov    %esi,%eax
  8024f7:	d3 e0                	shl    %cl,%eax
  8024f9:	89 e9                	mov    %ebp,%ecx
  8024fb:	d3 ea                	shr    %cl,%edx
  8024fd:	89 e9                	mov    %ebp,%ecx
  8024ff:	d3 ee                	shr    %cl,%esi
  802501:	09 d0                	or     %edx,%eax
  802503:	89 f2                	mov    %esi,%edx
  802505:	83 c4 1c             	add    $0x1c,%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    
  80250d:	8d 76 00             	lea    0x0(%esi),%esi
  802510:	29 f9                	sub    %edi,%ecx
  802512:	19 d6                	sbb    %edx,%esi
  802514:	89 74 24 04          	mov    %esi,0x4(%esp)
  802518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80251c:	e9 18 ff ff ff       	jmp    802439 <__umoddi3+0x69>
