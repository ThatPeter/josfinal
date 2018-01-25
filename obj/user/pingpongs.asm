
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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
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
  80003c:	e8 34 10 00 00       	call   801075 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 0c 0b 00 00       	call   800b5f <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 22 80 00       	push   $0x802280
  80005d:	e8 b3 01 00 00       	call   800215 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f5 0a 00 00       	call   800b5f <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 22 80 00       	push   $0x80229a
  800074:	e8 9c 01 00 00       	call   800215 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 b1 10 00 00       	call   801138 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 26 10 00 00       	call   8010c0 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 54             	mov    0x54(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 ac 0a 00 00       	call   800b5f <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 22 80 00       	push   $0x8022b0
  8000c2:	e8 4e 01 00 00       	call   800215 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 4e 10 00 00       	call   801138 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 51 0a 00 00       	call   800b5f <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	89 c2                	mov    %eax,%edx
  800115:	c1 e2 07             	shl    $0x7,%edx
  800118:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80011f:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x31>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 fa fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800139:	e8 2a 00 00 00       	call   800168 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80014e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  800153:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800155:	e8 05 0a 00 00       	call   800b5f <sys_getenvid>
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	50                   	push   %eax
  80015e:	e8 4b 0c 00 00       	call   800dae <sys_thread_free>
}
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80016e:	e8 32 12 00 00       	call   8013a5 <close_all>
	sys_env_destroy(0);
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	6a 00                	push   $0x0
  800178:	e8 a1 09 00 00       	call   800b1e <sys_env_destroy>
}
  80017d:	83 c4 10             	add    $0x10,%esp
  800180:	c9                   	leave  
  800181:	c3                   	ret    

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 2f 09 00 00       	call   800ae1 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 d4 08 00 00       	call   800ae1 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 63 1d 00 00       	call   801fe0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 50 1e 00 00       	call   802110 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 e0 22 80 00 	movsbl 0x8022e0(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 89 03 00 00    	je     8006f1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 1a 03 00 00    	ja     8006d6 <vprintfmt+0x38a>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	77 39                	ja     800425 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 27                	jmp    80042b <vprintfmt+0xdf>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	eb 8c                	jmp    8003a5 <vprintfmt+0x59>
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x59>
  800425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800428:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	0f 89 70 ff ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	e9 5e ff ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 53 ff ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 30                	pushl  (%eax)
  800461:	ff d6                	call   *%esi
			break;
  800463:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 04 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	99                   	cltd   
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 0f             	cmp    $0xf,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x142>
  800483:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 f8 22 80 00       	push   $0x8022f8
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 94 fe ff ff       	call   80032f <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 cc fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 45 27 80 00       	push   $0x802745
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 7c fe ff ff       	call   80032f <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	e9 b4 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 f1 22 80 00       	mov    $0x8022f1,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 8e 94 00 00 00    	jle    800571 <vprintfmt+0x225>
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 98 00 00 00    	je     80057f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 86 02 00 00       	call   800779 <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c0>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x213>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x23f>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x270>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f2>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f2>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x278>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 a2 fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d1>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800620:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	79 74                	jns    8006a2 <vprintfmt+0x356>
				putch('-', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 2d                	push   $0x2d
  800634:	ff d6                	call   *%esi
				num = -(long long) num;
  800636:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800639:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063c:	f7 d8                	neg    %eax
  80063e:	83 d2 00             	adc    $0x0,%edx
  800641:	f7 da                	neg    %edx
  800643:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064b:	eb 55                	jmp    8006a2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 83 fc ff ff       	call   8002d8 <getuint>
			base = 10;
  800655:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065a:	eb 46                	jmp    8006a2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 74 fc ff ff       	call   8002d8 <getuint>
			base = 8;
  800664:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800669:	eb 37                	jmp    8006a2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 30                	push   $0x30
  800671:	ff d6                	call   *%esi
			putch('x', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 78                	push   $0x78
  800679:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800693:	eb 0d                	jmp    8006a2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 3b fc ff ff       	call   8002d8 <getuint>
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a9:	57                   	push   %edi
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	51                   	push   %ecx
  8006ae:	52                   	push   %edx
  8006af:	50                   	push   %eax
  8006b0:	89 da                	mov    %ebx,%edx
  8006b2:	89 f0                	mov    %esi,%eax
  8006b4:	e8 70 fb ff ff       	call   800229 <printnum>
			break;
  8006b9:	83 c4 20             	add    $0x20,%esp
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bf:	e9 ae fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	51                   	push   %ecx
  8006c9:	ff d6                	call   *%esi
			break;
  8006cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d1:	e9 9c fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 03                	jmp    8006e6 <vprintfmt+0x39a>
  8006e3:	83 ef 01             	sub    $0x1,%edi
  8006e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ea:	75 f7                	jne    8006e3 <vprintfmt+0x397>
  8006ec:	e9 81 fc ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f4:	5b                   	pop    %ebx
  8006f5:	5e                   	pop    %esi
  8006f6:	5f                   	pop    %edi
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800708:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 26                	je     800740 <vsnprintf+0x47>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7e 22                	jle    800740 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071e:	ff 75 14             	pushl  0x14(%ebp)
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	68 12 03 80 00       	push   $0x800312
  80072d:	e8 1a fc ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800735:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb 05                	jmp    800745 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800750:	50                   	push   %eax
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	ff 75 08             	pushl  0x8(%ebp)
  80075a:	e8 9a ff ff ff       	call   8006f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 03                	jmp    800771 <strlen+0x10>
		n++;
  80076e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800775:	75 f7                	jne    80076e <strlen+0xd>
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
  800787:	eb 03                	jmp    80078c <strnlen+0x13>
		n++;
  800789:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 08                	je     800798 <strnlen+0x1f>
  800790:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800794:	75 f3                	jne    800789 <strnlen+0x10>
  800796:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ef                	jne    8007a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	53                   	push   %ebx
  8007c2:	e8 9a ff ff ff       	call   800761 <strlen>
  8007c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	50                   	push   %eax
  8007d0:	e8 c5 ff ff ff       	call   80079a <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	89 f2                	mov    %esi,%edx
  8007ee:	eb 0f                	jmp    8007ff <strncpy+0x23>
		*dst++ = *src;
  8007f0:	83 c2 01             	add    $0x1,%edx
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	39 da                	cmp    %ebx,%edx
  800801:	75 ed                	jne    8007f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800803:	89 f0                	mov    %esi,%eax
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800814:	8b 55 10             	mov    0x10(%ebp),%edx
  800817:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 21                	je     80083e <strlcpy+0x35>
  80081d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 09                	jmp    80082e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 09                	je     80083b <strlcpy+0x32>
  800832:	0f b6 19             	movzbl (%ecx),%ebx
  800835:	84 db                	test   %bl,%bl
  800837:	75 ec                	jne    800825 <strlcpy+0x1c>
  800839:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083e:	29 f0                	sub    %esi,%eax
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strcmp+0x11>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	84 c0                	test   %al,%al
  80085a:	74 04                	je     800860 <strcmp+0x1c>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	74 ef                	je     80084f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 c3                	mov    %eax,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800879:	eb 06                	jmp    800881 <strncmp+0x17>
		n--, p++, q++;
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 15                	je     80089a <strncmp+0x30>
  800885:	0f b6 08             	movzbl (%eax),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	74 04                	je     800890 <strncmp+0x26>
  80088c:	3a 0a                	cmp    (%edx),%cl
  80088e:	74 eb                	je     80087b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 00             	movzbl (%eax),%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
  800898:	eb 05                	jmp    80089f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 07                	jmp    8008b5 <strchr+0x13>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 0f                	je     8008c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 03                	jmp    8008d2 <strfind+0xf>
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 04                	je     8008dd <strfind+0x1a>
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f2                	jne    8008cf <strfind+0xc>
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 36                	je     800925 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 28                	jne    80091f <memset+0x40>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 23                	jne    80091f <memset+0x40>
		c &= 0xFF;
  8008fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 08             	shl    $0x8,%ebx
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 18             	shl    $0x18,%esi
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	c1 e0 10             	shl    $0x10,%eax
  80090f:	09 f0                	or     %esi,%eax
  800911:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800913:	89 d8                	mov    %ebx,%eax
  800915:	09 d0                	or     %edx,%eax
  800917:	c1 e9 02             	shr    $0x2,%ecx
  80091a:	fc                   	cld    
  80091b:	f3 ab                	rep stos %eax,%es:(%edi)
  80091d:	eb 06                	jmp    800925 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 35                	jae    800973 <memmove+0x47>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2e                	jae    800973 <memmove+0x47>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 d6                	mov    %edx,%esi
  80094a:	09 fe                	or     %edi,%esi
  80094c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800952:	75 13                	jne    800967 <memmove+0x3b>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0e                	jne    800967 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800959:	83 ef 04             	sub    $0x4,%edi
  80095c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095f:	c1 e9 02             	shr    $0x2,%ecx
  800962:	fd                   	std    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 09                	jmp    800970 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800967:	83 ef 01             	sub    $0x1,%edi
  80096a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096d:	fd                   	std    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800970:	fc                   	cld    
  800971:	eb 1d                	jmp    800990 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 f2                	mov    %esi,%edx
  800975:	09 c2                	or     %eax,%edx
  800977:	f6 c2 03             	test   $0x3,%dl
  80097a:	75 0f                	jne    80098b <memmove+0x5f>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0a                	jne    80098b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800981:	c1 e9 02             	shr    $0x2,%ecx
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 05                	jmp    800990 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800997:	ff 75 10             	pushl  0x10(%ebp)
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	ff 75 08             	pushl  0x8(%ebp)
  8009a0:	e8 87 ff ff ff       	call   80092c <memmove>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	eb 1a                	jmp    8009d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b9:	0f b6 08             	movzbl (%eax),%ecx
  8009bc:	0f b6 1a             	movzbl (%edx),%ebx
  8009bf:	38 d9                	cmp    %bl,%cl
  8009c1:	74 0a                	je     8009cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 0f                	jmp    8009dc <memcmp+0x35>
		s1++, s2++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	39 f0                	cmp    %esi,%eax
  8009d5:	75 e2                	jne    8009b9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e7:	89 c1                	mov    %eax,%ecx
  8009e9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	eb 0a                	jmp    8009fc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f2:	0f b6 10             	movzbl (%eax),%edx
  8009f5:	39 da                	cmp    %ebx,%edx
  8009f7:	74 07                	je     800a00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	39 c8                	cmp    %ecx,%eax
  8009fe:	72 f2                	jb     8009f2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a00:	5b                   	pop    %ebx
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	eb 03                	jmp    800a14 <strtol+0x11>
		s++;
  800a11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	3c 20                	cmp    $0x20,%al
  800a19:	74 f6                	je     800a11 <strtol+0xe>
  800a1b:	3c 09                	cmp    $0x9,%al
  800a1d:	74 f2                	je     800a11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1f:	3c 2b                	cmp    $0x2b,%al
  800a21:	75 0a                	jne    800a2d <strtol+0x2a>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 11                	jmp    800a3e <strtol+0x3b>
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a32:	3c 2d                	cmp    $0x2d,%al
  800a34:	75 08                	jne    800a3e <strtol+0x3b>
		s++, neg = 1;
  800a36:	83 c1 01             	add    $0x1,%ecx
  800a39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a44:	75 15                	jne    800a5b <strtol+0x58>
  800a46:	80 39 30             	cmpb   $0x30,(%ecx)
  800a49:	75 10                	jne    800a5b <strtol+0x58>
  800a4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4f:	75 7c                	jne    800acd <strtol+0xca>
		s += 2, base = 16;
  800a51:	83 c1 02             	add    $0x2,%ecx
  800a54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a59:	eb 16                	jmp    800a71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 12                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 08                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a79:	0f b6 11             	movzbl (%ecx),%edx
  800a7c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x8b>
			dig = *s - '0';
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 30             	sub    $0x30,%edx
  800a8c:	eb 22                	jmp    800ab0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 57             	sub    $0x57,%edx
  800a9e:	eb 10                	jmp    800ab0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 16                	ja     800ac0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab3:	7d 0b                	jge    800ac0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abe:	eb b9                	jmp    800a79 <strtol+0x76>

	if (endptr)
  800ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac4:	74 0d                	je     800ad3 <strtol+0xd0>
		*endptr = (char *) s;
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	89 0e                	mov    %ecx,(%esi)
  800acb:	eb 06                	jmp    800ad3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	74 98                	je     800a69 <strtol+0x66>
  800ad1:	eb 9e                	jmp    800a71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	f7 da                	neg    %edx
  800ad7:	85 ff                	test   %edi,%edi
  800ad9:	0f 45 c2             	cmovne %edx,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cgetc>:

int
sys_cgetc(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	89 cb                	mov    %ecx,%ebx
  800b36:	89 cf                	mov    %ecx,%edi
  800b38:	89 ce                	mov    %ecx,%esi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 03                	push   $0x3
  800b46:	68 df 25 80 00       	push   $0x8025df
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 fc 25 80 00       	push   $0x8025fc
  800b52:	e8 6d 13 00 00       	call   801ec4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_yield>:

void
sys_yield(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	be 00 00 00 00       	mov    $0x0,%esi
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	89 f7                	mov    %esi,%edi
  800bbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 04                	push   $0x4
  800bc7:	68 df 25 80 00       	push   $0x8025df
  800bcc:	6a 23                	push   $0x23
  800bce:	68 fc 25 80 00       	push   $0x8025fc
  800bd3:	e8 ec 12 00 00       	call   801ec4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 05                	push   $0x5
  800c09:	68 df 25 80 00       	push   $0x8025df
  800c0e:	6a 23                	push   $0x23
  800c10:	68 fc 25 80 00       	push   $0x8025fc
  800c15:	e8 aa 12 00 00       	call   801ec4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	b8 06 00 00 00       	mov    $0x6,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 06                	push   $0x6
  800c4b:	68 df 25 80 00       	push   $0x8025df
  800c50:	6a 23                	push   $0x23
  800c52:	68 fc 25 80 00       	push   $0x8025fc
  800c57:	e8 68 12 00 00       	call   801ec4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 08 00 00 00       	mov    $0x8,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 08                	push   $0x8
  800c8d:	68 df 25 80 00       	push   $0x8025df
  800c92:	6a 23                	push   $0x23
  800c94:	68 fc 25 80 00       	push   $0x8025fc
  800c99:	e8 26 12 00 00       	call   801ec4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 09                	push   $0x9
  800ccf:	68 df 25 80 00       	push   $0x8025df
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 fc 25 80 00       	push   $0x8025fc
  800cdb:	e8 e4 11 00 00       	call   801ec4 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 df                	mov    %ebx,%edi
  800d03:	89 de                	mov    %ebx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0a                	push   $0xa
  800d11:	68 df 25 80 00       	push   $0x8025df
  800d16:	6a 23                	push   $0x23
  800d18:	68 fc 25 80 00       	push   $0x8025fc
  800d1d:	e8 a2 11 00 00       	call   801ec4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d46:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 cb                	mov    %ecx,%ebx
  800d65:	89 cf                	mov    %ecx,%edi
  800d67:	89 ce                	mov    %ecx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 0d                	push   $0xd
  800d75:	68 df 25 80 00       	push   $0x8025df
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 fc 25 80 00       	push   $0x8025fc
  800d81:	e8 3e 11 00 00       	call   801ec4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 cb                	mov    %ecx,%ebx
  800dc3:	89 cf                	mov    %ecx,%edi
  800dc5:	89 ce                	mov    %ecx,%esi
  800dc7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dda:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dde:	74 11                	je     800df1 <pgfault+0x23>
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	c1 e8 0c             	shr    $0xc,%eax
  800de5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dec:	f6 c4 08             	test   $0x8,%ah
  800def:	75 14                	jne    800e05 <pgfault+0x37>
		panic("faulting access");
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	68 0a 26 80 00       	push   $0x80260a
  800df9:	6a 1e                	push   $0x1e
  800dfb:	68 1a 26 80 00       	push   $0x80261a
  800e00:	e8 bf 10 00 00       	call   801ec4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	6a 07                	push   $0x7
  800e0a:	68 00 f0 7f 00       	push   $0x7ff000
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 87 fd ff ff       	call   800b9d <sys_page_alloc>
	if (r < 0) {
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	79 12                	jns    800e2f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e1d:	50                   	push   %eax
  800e1e:	68 25 26 80 00       	push   $0x802625
  800e23:	6a 2c                	push   $0x2c
  800e25:	68 1a 26 80 00       	push   $0x80261a
  800e2a:	e8 95 10 00 00       	call   801ec4 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e35:	83 ec 04             	sub    $0x4,%esp
  800e38:	68 00 10 00 00       	push   $0x1000
  800e3d:	53                   	push   %ebx
  800e3e:	68 00 f0 7f 00       	push   $0x7ff000
  800e43:	e8 4c fb ff ff       	call   800994 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e48:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4f:	53                   	push   %ebx
  800e50:	6a 00                	push   $0x0
  800e52:	68 00 f0 7f 00       	push   $0x7ff000
  800e57:	6a 00                	push   $0x0
  800e59:	e8 82 fd ff ff       	call   800be0 <sys_page_map>
	if (r < 0) {
  800e5e:	83 c4 20             	add    $0x20,%esp
  800e61:	85 c0                	test   %eax,%eax
  800e63:	79 12                	jns    800e77 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e65:	50                   	push   %eax
  800e66:	68 25 26 80 00       	push   $0x802625
  800e6b:	6a 33                	push   $0x33
  800e6d:	68 1a 26 80 00       	push   $0x80261a
  800e72:	e8 4d 10 00 00       	call   801ec4 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	68 00 f0 7f 00       	push   $0x7ff000
  800e7f:	6a 00                	push   $0x0
  800e81:	e8 9c fd ff ff       	call   800c22 <sys_page_unmap>
	if (r < 0) {
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	79 12                	jns    800e9f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e8d:	50                   	push   %eax
  800e8e:	68 25 26 80 00       	push   $0x802625
  800e93:	6a 37                	push   $0x37
  800e95:	68 1a 26 80 00       	push   $0x80261a
  800e9a:	e8 25 10 00 00       	call   801ec4 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ead:	68 ce 0d 80 00       	push   $0x800dce
  800eb2:	e8 53 10 00 00       	call   801f0a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebc:	cd 30                	int    $0x30
  800ebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	79 17                	jns    800edf <fork+0x3b>
		panic("fork fault %e");
  800ec8:	83 ec 04             	sub    $0x4,%esp
  800ecb:	68 3e 26 80 00       	push   $0x80263e
  800ed0:	68 84 00 00 00       	push   $0x84
  800ed5:	68 1a 26 80 00       	push   $0x80261a
  800eda:	e8 e5 0f 00 00       	call   801ec4 <_panic>
  800edf:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ee1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee5:	75 25                	jne    800f0c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee7:	e8 73 fc ff ff       	call   800b5f <sys_getenvid>
  800eec:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef1:	89 c2                	mov    %eax,%edx
  800ef3:	c1 e2 07             	shl    $0x7,%edx
  800ef6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800efd:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	e9 61 01 00 00       	jmp    80106d <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f0c:	83 ec 04             	sub    $0x4,%esp
  800f0f:	6a 07                	push   $0x7
  800f11:	68 00 f0 bf ee       	push   $0xeebff000
  800f16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f19:	e8 7f fc ff ff       	call   800b9d <sys_page_alloc>
  800f1e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f21:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f26:	89 d8                	mov    %ebx,%eax
  800f28:	c1 e8 16             	shr    $0x16,%eax
  800f2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f32:	a8 01                	test   $0x1,%al
  800f34:	0f 84 fc 00 00 00    	je     801036 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f3a:	89 d8                	mov    %ebx,%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
  800f3f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f46:	f6 c2 01             	test   $0x1,%dl
  800f49:	0f 84 e7 00 00 00    	je     801036 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f54:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5b:	f6 c6 04             	test   $0x4,%dh
  800f5e:	74 39                	je     800f99 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6f:	50                   	push   %eax
  800f70:	56                   	push   %esi
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	6a 00                	push   $0x0
  800f75:	e8 66 fc ff ff       	call   800be0 <sys_page_map>
		if (r < 0) {
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	0f 89 b1 00 00 00    	jns    801036 <fork+0x192>
		    	panic("sys page map fault %e");
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	68 4c 26 80 00       	push   $0x80264c
  800f8d:	6a 54                	push   $0x54
  800f8f:	68 1a 26 80 00       	push   $0x80261a
  800f94:	e8 2b 0f 00 00       	call   801ec4 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f99:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa0:	f6 c2 02             	test   $0x2,%dl
  800fa3:	75 0c                	jne    800fb1 <fork+0x10d>
  800fa5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fac:	f6 c4 08             	test   $0x8,%ah
  800faf:	74 5b                	je     80100c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	68 05 08 00 00       	push   $0x805
  800fb9:	56                   	push   %esi
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 1d fc ff ff       	call   800be0 <sys_page_map>
		if (r < 0) {
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 14                	jns    800fde <fork+0x13a>
		    	panic("sys page map fault %e");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 4c 26 80 00       	push   $0x80264c
  800fd2:	6a 5b                	push   $0x5b
  800fd4:	68 1a 26 80 00       	push   $0x80261a
  800fd9:	e8 e6 0e 00 00       	call   801ec4 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	68 05 08 00 00       	push   $0x805
  800fe6:	56                   	push   %esi
  800fe7:	6a 00                	push   $0x0
  800fe9:	56                   	push   %esi
  800fea:	6a 00                	push   $0x0
  800fec:	e8 ef fb ff ff       	call   800be0 <sys_page_map>
		if (r < 0) {
  800ff1:	83 c4 20             	add    $0x20,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	79 3e                	jns    801036 <fork+0x192>
		    	panic("sys page map fault %e");
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	68 4c 26 80 00       	push   $0x80264c
  801000:	6a 5f                	push   $0x5f
  801002:	68 1a 26 80 00       	push   $0x80261a
  801007:	e8 b8 0e 00 00       	call   801ec4 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	6a 05                	push   $0x5
  801011:	56                   	push   %esi
  801012:	57                   	push   %edi
  801013:	56                   	push   %esi
  801014:	6a 00                	push   $0x0
  801016:	e8 c5 fb ff ff       	call   800be0 <sys_page_map>
		if (r < 0) {
  80101b:	83 c4 20             	add    $0x20,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	79 14                	jns    801036 <fork+0x192>
		    	panic("sys page map fault %e");
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	68 4c 26 80 00       	push   $0x80264c
  80102a:	6a 64                	push   $0x64
  80102c:	68 1a 26 80 00       	push   $0x80261a
  801031:	e8 8e 0e 00 00       	call   801ec4 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801036:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801042:	0f 85 de fe ff ff    	jne    800f26 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801048:	a1 08 40 80 00       	mov    0x804008,%eax
  80104d:	8b 40 70             	mov    0x70(%eax),%eax
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	50                   	push   %eax
  801054:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801057:	57                   	push   %edi
  801058:	e8 8b fc ff ff       	call   800ce8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	6a 02                	push   $0x2
  801062:	57                   	push   %edi
  801063:	e8 fc fb ff ff       	call   800c64 <sys_env_set_status>
	
	return envid;
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sfork>:

envid_t
sfork(void)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801087:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	53                   	push   %ebx
  801091:	68 64 26 80 00       	push   $0x802664
  801096:	e8 7a f1 ff ff       	call   800215 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80109b:	c7 04 24 48 01 80 00 	movl   $0x800148,(%esp)
  8010a2:	e8 e7 fc ff ff       	call   800d8e <sys_thread_create>
  8010a7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010a9:	83 c4 08             	add    $0x8,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	68 64 26 80 00       	push   $0x802664
  8010b2:	e8 5e f1 ff ff       	call   800215 <cprintf>
	return id;
	//return 0;
}
  8010b7:	89 f0                	mov    %esi,%eax
  8010b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8010c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	75 12                	jne    8010e4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	68 00 00 c0 ee       	push   $0xeec00000
  8010da:	e8 6e fc ff ff       	call   800d4d <sys_ipc_recv>
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	eb 0c                	jmp    8010f0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	50                   	push   %eax
  8010e8:	e8 60 fc ff ff       	call   800d4d <sys_ipc_recv>
  8010ed:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8010f0:	85 f6                	test   %esi,%esi
  8010f2:	0f 95 c1             	setne  %cl
  8010f5:	85 db                	test   %ebx,%ebx
  8010f7:	0f 95 c2             	setne  %dl
  8010fa:	84 d1                	test   %dl,%cl
  8010fc:	74 09                	je     801107 <ipc_recv+0x47>
  8010fe:	89 c2                	mov    %eax,%edx
  801100:	c1 ea 1f             	shr    $0x1f,%edx
  801103:	84 d2                	test   %dl,%dl
  801105:	75 2a                	jne    801131 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801107:	85 f6                	test   %esi,%esi
  801109:	74 0d                	je     801118 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80110b:	a1 08 40 80 00       	mov    0x804008,%eax
  801110:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801116:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801118:	85 db                	test   %ebx,%ebx
  80111a:	74 0d                	je     801129 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80111c:	a1 08 40 80 00       	mov    0x804008,%eax
  801121:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801127:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801129:	a1 08 40 80 00       	mov    0x804008,%eax
  80112e:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801131:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801134:	5b                   	pop    %ebx
  801135:	5e                   	pop    %esi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	8b 7d 08             	mov    0x8(%ebp),%edi
  801144:	8b 75 0c             	mov    0xc(%ebp),%esi
  801147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80114a:	85 db                	test   %ebx,%ebx
  80114c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801151:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801154:	ff 75 14             	pushl  0x14(%ebp)
  801157:	53                   	push   %ebx
  801158:	56                   	push   %esi
  801159:	57                   	push   %edi
  80115a:	e8 cb fb ff ff       	call   800d2a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80115f:	89 c2                	mov    %eax,%edx
  801161:	c1 ea 1f             	shr    $0x1f,%edx
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	84 d2                	test   %dl,%dl
  801169:	74 17                	je     801182 <ipc_send+0x4a>
  80116b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80116e:	74 12                	je     801182 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801170:	50                   	push   %eax
  801171:	68 87 26 80 00       	push   $0x802687
  801176:	6a 47                	push   $0x47
  801178:	68 95 26 80 00       	push   $0x802695
  80117d:	e8 42 0d 00 00       	call   801ec4 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801182:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801185:	75 07                	jne    80118e <ipc_send+0x56>
			sys_yield();
  801187:	e8 f2 f9 ff ff       	call   800b7e <sys_yield>
  80118c:	eb c6                	jmp    801154 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80118e:	85 c0                	test   %eax,%eax
  801190:	75 c2                	jne    801154 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 e2 07             	shl    $0x7,%edx
  8011aa:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8011b1:	8b 52 5c             	mov    0x5c(%edx),%edx
  8011b4:	39 ca                	cmp    %ecx,%edx
  8011b6:	75 11                	jne    8011c9 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 e2 07             	shl    $0x7,%edx
  8011bd:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8011c4:	8b 40 54             	mov    0x54(%eax),%eax
  8011c7:	eb 0f                	jmp    8011d8 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c9:	83 c0 01             	add    $0x1,%eax
  8011cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d1:	75 d2                	jne    8011a5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801207:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	c1 ea 16             	shr    $0x16,%edx
  801211:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 11                	je     80122e <fd_alloc+0x2d>
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 0c             	shr    $0xc,%edx
  801222:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	75 09                	jne    801237 <fd_alloc+0x36>
			*fd_store = fd;
  80122e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 17                	jmp    80124e <fd_alloc+0x4d>
  801237:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801241:	75 c9                	jne    80120c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801243:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801249:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801256:	83 f8 1f             	cmp    $0x1f,%eax
  801259:	77 36                	ja     801291 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125b:	c1 e0 0c             	shl    $0xc,%eax
  80125e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801263:	89 c2                	mov    %eax,%edx
  801265:	c1 ea 16             	shr    $0x16,%edx
  801268:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 24                	je     801298 <fd_lookup+0x48>
  801274:	89 c2                	mov    %eax,%edx
  801276:	c1 ea 0c             	shr    $0xc,%edx
  801279:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801280:	f6 c2 01             	test   $0x1,%dl
  801283:	74 1a                	je     80129f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801285:	8b 55 0c             	mov    0xc(%ebp),%edx
  801288:	89 02                	mov    %eax,(%edx)
	return 0;
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
  80128f:	eb 13                	jmp    8012a4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801296:	eb 0c                	jmp    8012a4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb 05                	jmp    8012a4 <fd_lookup+0x54>
  80129f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012af:	ba 1c 27 80 00       	mov    $0x80271c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b4:	eb 13                	jmp    8012c9 <dev_lookup+0x23>
  8012b6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b9:	39 08                	cmp    %ecx,(%eax)
  8012bb:	75 0c                	jne    8012c9 <dev_lookup+0x23>
			*dev = devtab[i];
  8012bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb 2e                	jmp    8012f7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c9:	8b 02                	mov    (%edx),%eax
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	75 e7                	jne    8012b6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d4:	8b 40 54             	mov    0x54(%eax),%eax
  8012d7:	83 ec 04             	sub    $0x4,%esp
  8012da:	51                   	push   %ecx
  8012db:	50                   	push   %eax
  8012dc:	68 a0 26 80 00       	push   $0x8026a0
  8012e1:	e8 2f ef ff ff       	call   800215 <cprintf>
	*dev = 0;
  8012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	56                   	push   %esi
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 10             	sub    $0x10,%esp
  801301:	8b 75 08             	mov    0x8(%ebp),%esi
  801304:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801311:	c1 e8 0c             	shr    $0xc,%eax
  801314:	50                   	push   %eax
  801315:	e8 36 ff ff ff       	call   801250 <fd_lookup>
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 05                	js     801326 <fd_close+0x2d>
	    || fd != fd2)
  801321:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801324:	74 0c                	je     801332 <fd_close+0x39>
		return (must_exist ? r : 0);
  801326:	84 db                	test   %bl,%bl
  801328:	ba 00 00 00 00       	mov    $0x0,%edx
  80132d:	0f 44 c2             	cmove  %edx,%eax
  801330:	eb 41                	jmp    801373 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 36                	pushl  (%esi)
  80133b:	e8 66 ff ff ff       	call   8012a6 <dev_lookup>
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 1a                	js     801363 <fd_close+0x6a>
		if (dev->dev_close)
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801354:	85 c0                	test   %eax,%eax
  801356:	74 0b                	je     801363 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	56                   	push   %esi
  80135c:	ff d0                	call   *%eax
  80135e:	89 c3                	mov    %eax,%ebx
  801360:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	56                   	push   %esi
  801367:	6a 00                	push   $0x0
  801369:	e8 b4 f8 ff ff       	call   800c22 <sys_page_unmap>
	return r;
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	89 d8                	mov    %ebx,%eax
}
  801373:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 75 08             	pushl  0x8(%ebp)
  801387:	e8 c4 fe ff ff       	call   801250 <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 10                	js     8013a3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	6a 01                	push   $0x1
  801398:	ff 75 f4             	pushl  -0xc(%ebp)
  80139b:	e8 59 ff ff ff       	call   8012f9 <fd_close>
  8013a0:	83 c4 10             	add    $0x10,%esp
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <close_all>:

void
close_all(void)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	e8 c0 ff ff ff       	call   80137a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ba:	83 c3 01             	add    $0x1,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	83 fb 20             	cmp    $0x20,%ebx
  8013c3:	75 ec                	jne    8013b1 <close_all+0xc>
		close(i);
}
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 2c             	sub    $0x2c,%esp
  8013d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 75 08             	pushl  0x8(%ebp)
  8013dd:	e8 6e fe ff ff       	call   801250 <fd_lookup>
  8013e2:	83 c4 08             	add    $0x8,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	0f 88 c1 00 00 00    	js     8014ae <dup+0xe4>
		return r;
	close(newfdnum);
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	56                   	push   %esi
  8013f1:	e8 84 ff ff ff       	call   80137a <close>

	newfd = INDEX2FD(newfdnum);
  8013f6:	89 f3                	mov    %esi,%ebx
  8013f8:	c1 e3 0c             	shl    $0xc,%ebx
  8013fb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801401:	83 c4 04             	add    $0x4,%esp
  801404:	ff 75 e4             	pushl  -0x1c(%ebp)
  801407:	e8 de fd ff ff       	call   8011ea <fd2data>
  80140c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80140e:	89 1c 24             	mov    %ebx,(%esp)
  801411:	e8 d4 fd ff ff       	call   8011ea <fd2data>
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141c:	89 f8                	mov    %edi,%eax
  80141e:	c1 e8 16             	shr    $0x16,%eax
  801421:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801428:	a8 01                	test   $0x1,%al
  80142a:	74 37                	je     801463 <dup+0x99>
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	c1 e8 0c             	shr    $0xc,%eax
  801431:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	74 26                	je     801463 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	25 07 0e 00 00       	and    $0xe07,%eax
  80144c:	50                   	push   %eax
  80144d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801450:	6a 00                	push   $0x0
  801452:	57                   	push   %edi
  801453:	6a 00                	push   $0x0
  801455:	e8 86 f7 ff ff       	call   800be0 <sys_page_map>
  80145a:	89 c7                	mov    %eax,%edi
  80145c:	83 c4 20             	add    $0x20,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 2e                	js     801491 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801463:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801466:	89 d0                	mov    %edx,%eax
  801468:	c1 e8 0c             	shr    $0xc,%eax
  80146b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	25 07 0e 00 00       	and    $0xe07,%eax
  80147a:	50                   	push   %eax
  80147b:	53                   	push   %ebx
  80147c:	6a 00                	push   $0x0
  80147e:	52                   	push   %edx
  80147f:	6a 00                	push   $0x0
  801481:	e8 5a f7 ff ff       	call   800be0 <sys_page_map>
  801486:	89 c7                	mov    %eax,%edi
  801488:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148d:	85 ff                	test   %edi,%edi
  80148f:	79 1d                	jns    8014ae <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	53                   	push   %ebx
  801495:	6a 00                	push   $0x0
  801497:	e8 86 f7 ff ff       	call   800c22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 79 f7 ff ff       	call   800c22 <sys_page_unmap>
	return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	89 f8                	mov    %edi,%eax
}
  8014ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5f                   	pop    %edi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 14             	sub    $0x14,%esp
  8014bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	53                   	push   %ebx
  8014c5:	e8 86 fd ff ff       	call   801250 <fd_lookup>
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 6d                	js     801540 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	ff 30                	pushl  (%eax)
  8014df:	e8 c2 fd ff ff       	call   8012a6 <dev_lookup>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 4c                	js     801537 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ee:	8b 42 08             	mov    0x8(%edx),%eax
  8014f1:	83 e0 03             	and    $0x3,%eax
  8014f4:	83 f8 01             	cmp    $0x1,%eax
  8014f7:	75 21                	jne    80151a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8014fe:	8b 40 54             	mov    0x54(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 e1 26 80 00       	push   $0x8026e1
  80150b:	e8 05 ed ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801518:	eb 26                	jmp    801540 <read+0x8a>
	}
	if (!dev->dev_read)
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	8b 40 08             	mov    0x8(%eax),%eax
  801520:	85 c0                	test   %eax,%eax
  801522:	74 17                	je     80153b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	ff 75 10             	pushl  0x10(%ebp)
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	52                   	push   %edx
  80152e:	ff d0                	call   *%eax
  801530:	89 c2                	mov    %eax,%edx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	eb 09                	jmp    801540 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801537:	89 c2                	mov    %eax,%edx
  801539:	eb 05                	jmp    801540 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801540:	89 d0                	mov    %edx,%eax
  801542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	57                   	push   %edi
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8b 7d 08             	mov    0x8(%ebp),%edi
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155b:	eb 21                	jmp    80157e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	89 f0                	mov    %esi,%eax
  801562:	29 d8                	sub    %ebx,%eax
  801564:	50                   	push   %eax
  801565:	89 d8                	mov    %ebx,%eax
  801567:	03 45 0c             	add    0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	57                   	push   %edi
  80156c:	e8 45 ff ff ff       	call   8014b6 <read>
		if (m < 0)
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 10                	js     801588 <readn+0x41>
			return m;
		if (m == 0)
  801578:	85 c0                	test   %eax,%eax
  80157a:	74 0a                	je     801586 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157c:	01 c3                	add    %eax,%ebx
  80157e:	39 f3                	cmp    %esi,%ebx
  801580:	72 db                	jb     80155d <readn+0x16>
  801582:	89 d8                	mov    %ebx,%eax
  801584:	eb 02                	jmp    801588 <readn+0x41>
  801586:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801588:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5f                   	pop    %edi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 14             	sub    $0x14,%esp
  801597:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	53                   	push   %ebx
  80159f:	e8 ac fc ff ff       	call   801250 <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 68                	js     801615 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b7:	ff 30                	pushl  (%eax)
  8015b9:	e8 e8 fc ff ff       	call   8012a6 <dev_lookup>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 47                	js     80160c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cc:	75 21                	jne    8015ef <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ce:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d3:	8b 40 54             	mov    0x54(%eax),%eax
  8015d6:	83 ec 04             	sub    $0x4,%esp
  8015d9:	53                   	push   %ebx
  8015da:	50                   	push   %eax
  8015db:	68 fd 26 80 00       	push   $0x8026fd
  8015e0:	e8 30 ec ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ed:	eb 26                	jmp    801615 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f5:	85 d2                	test   %edx,%edx
  8015f7:	74 17                	je     801610 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	ff 75 10             	pushl  0x10(%ebp)
  8015ff:	ff 75 0c             	pushl  0xc(%ebp)
  801602:	50                   	push   %eax
  801603:	ff d2                	call   *%edx
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 09                	jmp    801615 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	eb 05                	jmp    801615 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801610:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <seek>:

int
seek(int fdnum, off_t offset)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801622:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	ff 75 08             	pushl  0x8(%ebp)
  801629:	e8 22 fc ff ff       	call   801250 <fd_lookup>
  80162e:	83 c4 08             	add    $0x8,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 0e                	js     801643 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801635:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 14             	sub    $0x14,%esp
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	53                   	push   %ebx
  801654:	e8 f7 fb ff ff       	call   801250 <fd_lookup>
  801659:	83 c4 08             	add    $0x8,%esp
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 65                	js     8016c7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 33 fc ff ff       	call   8012a6 <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 44                	js     8016be <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801681:	75 21                	jne    8016a4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801683:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801688:	8b 40 54             	mov    0x54(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	53                   	push   %ebx
  80168f:	50                   	push   %eax
  801690:	68 c0 26 80 00       	push   $0x8026c0
  801695:	e8 7b eb ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a2:	eb 23                	jmp    8016c7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a7:	8b 52 18             	mov    0x18(%edx),%edx
  8016aa:	85 d2                	test   %edx,%edx
  8016ac:	74 14                	je     8016c2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	50                   	push   %eax
  8016b5:	ff d2                	call   *%edx
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 09                	jmp    8016c7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	eb 05                	jmp    8016c7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c7:	89 d0                	mov    %edx,%eax
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 14             	sub    $0x14,%esp
  8016d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	ff 75 08             	pushl  0x8(%ebp)
  8016df:	e8 6c fb ff ff       	call   801250 <fd_lookup>
  8016e4:	83 c4 08             	add    $0x8,%esp
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 58                	js     801745 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	ff 30                	pushl  (%eax)
  8016f9:	e8 a8 fb ff ff       	call   8012a6 <dev_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 37                	js     80173c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170c:	74 32                	je     801740 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801711:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801718:	00 00 00 
	stat->st_isdir = 0;
  80171b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801722:	00 00 00 
	stat->st_dev = dev;
  801725:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	53                   	push   %ebx
  80172f:	ff 75 f0             	pushl  -0x10(%ebp)
  801732:	ff 50 14             	call   *0x14(%eax)
  801735:	89 c2                	mov    %eax,%edx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 09                	jmp    801745 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	eb 05                	jmp    801745 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801740:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801745:	89 d0                	mov    %edx,%eax
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	6a 00                	push   $0x0
  801756:	ff 75 08             	pushl  0x8(%ebp)
  801759:	e8 e3 01 00 00       	call   801941 <open>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 1b                	js     801782 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	ff 75 0c             	pushl  0xc(%ebp)
  80176d:	50                   	push   %eax
  80176e:	e8 5b ff ff ff       	call   8016ce <fstat>
  801773:	89 c6                	mov    %eax,%esi
	close(fd);
  801775:	89 1c 24             	mov    %ebx,(%esp)
  801778:	e8 fd fb ff ff       	call   80137a <close>
	return r;
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	89 f0                	mov    %esi,%eax
}
  801782:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	89 c6                	mov    %eax,%esi
  801790:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801792:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801799:	75 12                	jne    8017ad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	6a 01                	push   $0x1
  8017a0:	e8 f5 f9 ff ff       	call   80119a <ipc_find_env>
  8017a5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017aa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ad:	6a 07                	push   $0x7
  8017af:	68 00 50 80 00       	push   $0x805000
  8017b4:	56                   	push   %esi
  8017b5:	ff 35 00 40 80 00    	pushl  0x804000
  8017bb:	e8 78 f9 ff ff       	call   801138 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c0:	83 c4 0c             	add    $0xc,%esp
  8017c3:	6a 00                	push   $0x0
  8017c5:	53                   	push   %ebx
  8017c6:	6a 00                	push   $0x0
  8017c8:	e8 f3 f8 ff ff       	call   8010c0 <ipc_recv>
}
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f7:	e8 8d ff ff ff       	call   801789 <fsipc>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8b 40 0c             	mov    0xc(%eax),%eax
  80180a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 06 00 00 00       	mov    $0x6,%eax
  801819:	e8 6b ff ff ff       	call   801789 <fsipc>
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 05 00 00 00       	mov    $0x5,%eax
  80183f:	e8 45 ff ff ff       	call   801789 <fsipc>
  801844:	85 c0                	test   %eax,%eax
  801846:	78 2c                	js     801874 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	68 00 50 80 00       	push   $0x805000
  801850:	53                   	push   %ebx
  801851:	e8 44 ef ff ff       	call   80079a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801856:	a1 80 50 80 00       	mov    0x805080,%eax
  80185b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801861:	a1 84 50 80 00       	mov    0x805084,%eax
  801866:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801882:	8b 55 08             	mov    0x8(%ebp),%edx
  801885:	8b 52 0c             	mov    0xc(%edx),%edx
  801888:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80188e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801893:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801898:	0f 47 c2             	cmova  %edx,%eax
  80189b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018a0:	50                   	push   %eax
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	68 08 50 80 00       	push   $0x805008
  8018a9:	e8 7e f0 ff ff       	call   80092c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b8:	e8 cc fe ff ff       	call   801789 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e2:	e8 a2 fe ff ff       	call   801789 <fsipc>
  8018e7:	89 c3                	mov    %eax,%ebx
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 4b                	js     801938 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ed:	39 c6                	cmp    %eax,%esi
  8018ef:	73 16                	jae    801907 <devfile_read+0x48>
  8018f1:	68 2c 27 80 00       	push   $0x80272c
  8018f6:	68 33 27 80 00       	push   $0x802733
  8018fb:	6a 7c                	push   $0x7c
  8018fd:	68 48 27 80 00       	push   $0x802748
  801902:	e8 bd 05 00 00       	call   801ec4 <_panic>
	assert(r <= PGSIZE);
  801907:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190c:	7e 16                	jle    801924 <devfile_read+0x65>
  80190e:	68 53 27 80 00       	push   $0x802753
  801913:	68 33 27 80 00       	push   $0x802733
  801918:	6a 7d                	push   $0x7d
  80191a:	68 48 27 80 00       	push   $0x802748
  80191f:	e8 a0 05 00 00       	call   801ec4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	50                   	push   %eax
  801928:	68 00 50 80 00       	push   $0x805000
  80192d:	ff 75 0c             	pushl  0xc(%ebp)
  801930:	e8 f7 ef ff ff       	call   80092c <memmove>
	return r;
  801935:	83 c4 10             	add    $0x10,%esp
}
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	53                   	push   %ebx
  801945:	83 ec 20             	sub    $0x20,%esp
  801948:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194b:	53                   	push   %ebx
  80194c:	e8 10 ee ff ff       	call   800761 <strlen>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801959:	7f 67                	jg     8019c2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	e8 9a f8 ff ff       	call   801201 <fd_alloc>
  801967:	83 c4 10             	add    $0x10,%esp
		return r;
  80196a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 57                	js     8019c7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	53                   	push   %ebx
  801974:	68 00 50 80 00       	push   $0x805000
  801979:	e8 1c ee ff ff       	call   80079a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801981:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801986:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801989:	b8 01 00 00 00       	mov    $0x1,%eax
  80198e:	e8 f6 fd ff ff       	call   801789 <fsipc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	79 14                	jns    8019b0 <open+0x6f>
		fd_close(fd, 0);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	6a 00                	push   $0x0
  8019a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a4:	e8 50 f9 ff ff       	call   8012f9 <fd_close>
		return r;
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	89 da                	mov    %ebx,%edx
  8019ae:	eb 17                	jmp    8019c7 <open+0x86>
	}

	return fd2num(fd);
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b6:	e8 1f f8 ff ff       	call   8011da <fd2num>
  8019bb:	89 c2                	mov    %eax,%edx
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	eb 05                	jmp    8019c7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c7:	89 d0                	mov    %edx,%eax
  8019c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8019de:	e8 a6 fd ff ff       	call   801789 <fsipc>
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ed:	83 ec 0c             	sub    $0xc,%esp
  8019f0:	ff 75 08             	pushl  0x8(%ebp)
  8019f3:	e8 f2 f7 ff ff       	call   8011ea <fd2data>
  8019f8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019fa:	83 c4 08             	add    $0x8,%esp
  8019fd:	68 5f 27 80 00       	push   $0x80275f
  801a02:	53                   	push   %ebx
  801a03:	e8 92 ed ff ff       	call   80079a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a08:	8b 46 04             	mov    0x4(%esi),%eax
  801a0b:	2b 06                	sub    (%esi),%eax
  801a0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1a:	00 00 00 
	stat->st_dev = &devpipe;
  801a1d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a24:	30 80 00 
	return 0;
}
  801a27:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	53                   	push   %ebx
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a3d:	53                   	push   %ebx
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 dd f1 ff ff       	call   800c22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a45:	89 1c 24             	mov    %ebx,(%esp)
  801a48:	e8 9d f7 ff ff       	call   8011ea <fd2data>
  801a4d:	83 c4 08             	add    $0x8,%esp
  801a50:	50                   	push   %eax
  801a51:	6a 00                	push   $0x0
  801a53:	e8 ca f1 ff ff       	call   800c22 <sys_page_unmap>
}
  801a58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 1c             	sub    $0x1c,%esp
  801a66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a6b:	a1 08 40 80 00       	mov    0x804008,%eax
  801a70:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	ff 75 e0             	pushl  -0x20(%ebp)
  801a79:	e8 1b 05 00 00       	call   801f99 <pageref>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	89 3c 24             	mov    %edi,(%esp)
  801a83:	e8 11 05 00 00       	call   801f99 <pageref>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	39 c3                	cmp    %eax,%ebx
  801a8d:	0f 94 c1             	sete   %cl
  801a90:	0f b6 c9             	movzbl %cl,%ecx
  801a93:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a96:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a9c:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801a9f:	39 ce                	cmp    %ecx,%esi
  801aa1:	74 1b                	je     801abe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa3:	39 c3                	cmp    %eax,%ebx
  801aa5:	75 c4                	jne    801a6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aa7:	8b 42 64             	mov    0x64(%edx),%eax
  801aaa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aad:	50                   	push   %eax
  801aae:	56                   	push   %esi
  801aaf:	68 66 27 80 00       	push   $0x802766
  801ab4:	e8 5c e7 ff ff       	call   800215 <cprintf>
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb ad                	jmp    801a6b <_pipeisclosed+0xe>
	}
}
  801abe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	57                   	push   %edi
  801acd:	56                   	push   %esi
  801ace:	53                   	push   %ebx
  801acf:	83 ec 28             	sub    $0x28,%esp
  801ad2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ad5:	56                   	push   %esi
  801ad6:	e8 0f f7 ff ff       	call   8011ea <fd2data>
  801adb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae5:	eb 4b                	jmp    801b32 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ae7:	89 da                	mov    %ebx,%edx
  801ae9:	89 f0                	mov    %esi,%eax
  801aeb:	e8 6d ff ff ff       	call   801a5d <_pipeisclosed>
  801af0:	85 c0                	test   %eax,%eax
  801af2:	75 48                	jne    801b3c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af4:	e8 85 f0 ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801af9:	8b 43 04             	mov    0x4(%ebx),%eax
  801afc:	8b 0b                	mov    (%ebx),%ecx
  801afe:	8d 51 20             	lea    0x20(%ecx),%edx
  801b01:	39 d0                	cmp    %edx,%eax
  801b03:	73 e2                	jae    801ae7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b08:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b0c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b0f:	89 c2                	mov    %eax,%edx
  801b11:	c1 fa 1f             	sar    $0x1f,%edx
  801b14:	89 d1                	mov    %edx,%ecx
  801b16:	c1 e9 1b             	shr    $0x1b,%ecx
  801b19:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b1c:	83 e2 1f             	and    $0x1f,%edx
  801b1f:	29 ca                	sub    %ecx,%edx
  801b21:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b29:	83 c0 01             	add    $0x1,%eax
  801b2c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2f:	83 c7 01             	add    $0x1,%edi
  801b32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b35:	75 c2                	jne    801af9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b37:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3a:	eb 05                	jmp    801b41 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b44:	5b                   	pop    %ebx
  801b45:	5e                   	pop    %esi
  801b46:	5f                   	pop    %edi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 18             	sub    $0x18,%esp
  801b52:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b55:	57                   	push   %edi
  801b56:	e8 8f f6 ff ff       	call   8011ea <fd2data>
  801b5b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b65:	eb 3d                	jmp    801ba4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b67:	85 db                	test   %ebx,%ebx
  801b69:	74 04                	je     801b6f <devpipe_read+0x26>
				return i;
  801b6b:	89 d8                	mov    %ebx,%eax
  801b6d:	eb 44                	jmp    801bb3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b6f:	89 f2                	mov    %esi,%edx
  801b71:	89 f8                	mov    %edi,%eax
  801b73:	e8 e5 fe ff ff       	call   801a5d <_pipeisclosed>
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	75 32                	jne    801bae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b7c:	e8 fd ef ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b81:	8b 06                	mov    (%esi),%eax
  801b83:	3b 46 04             	cmp    0x4(%esi),%eax
  801b86:	74 df                	je     801b67 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b88:	99                   	cltd   
  801b89:	c1 ea 1b             	shr    $0x1b,%edx
  801b8c:	01 d0                	add    %edx,%eax
  801b8e:	83 e0 1f             	and    $0x1f,%eax
  801b91:	29 d0                	sub    %edx,%eax
  801b93:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b9e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba1:	83 c3 01             	add    $0x1,%ebx
  801ba4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ba7:	75 d8                	jne    801b81 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ba9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bac:	eb 05                	jmp    801bb3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5f                   	pop    %edi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc6:	50                   	push   %eax
  801bc7:	e8 35 f6 ff ff       	call   801201 <fd_alloc>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	89 c2                	mov    %eax,%edx
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 2c 01 00 00    	js     801d05 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	68 07 04 00 00       	push   $0x407
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	6a 00                	push   $0x0
  801be6:	e8 b2 ef ff ff       	call   800b9d <sys_page_alloc>
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	89 c2                	mov    %eax,%edx
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	0f 88 0d 01 00 00    	js     801d05 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	e8 fd f5 ff ff       	call   801201 <fd_alloc>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 e2 00 00 00    	js     801cf3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	68 07 04 00 00       	push   $0x407
  801c19:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 7a ef ff ff       	call   800b9d <sys_page_alloc>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 c3 00 00 00    	js     801cf3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c30:	83 ec 0c             	sub    $0xc,%esp
  801c33:	ff 75 f4             	pushl  -0xc(%ebp)
  801c36:	e8 af f5 ff ff       	call   8011ea <fd2data>
  801c3b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3d:	83 c4 0c             	add    $0xc,%esp
  801c40:	68 07 04 00 00       	push   $0x407
  801c45:	50                   	push   %eax
  801c46:	6a 00                	push   $0x0
  801c48:	e8 50 ef ff ff       	call   800b9d <sys_page_alloc>
  801c4d:	89 c3                	mov    %eax,%ebx
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	85 c0                	test   %eax,%eax
  801c54:	0f 88 89 00 00 00    	js     801ce3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c60:	e8 85 f5 ff ff       	call   8011ea <fd2data>
  801c65:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c6c:	50                   	push   %eax
  801c6d:	6a 00                	push   $0x0
  801c6f:	56                   	push   %esi
  801c70:	6a 00                	push   $0x0
  801c72:	e8 69 ef ff ff       	call   800be0 <sys_page_map>
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	83 c4 20             	add    $0x20,%esp
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 55                	js     801cd5 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c80:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c89:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c95:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb0:	e8 25 f5 ff ff       	call   8011da <fd2num>
  801cb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cba:	83 c4 04             	add    $0x4,%esp
  801cbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc0:	e8 15 f5 ff ff       	call   8011da <fd2num>
  801cc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc8:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd3:	eb 30                	jmp    801d05 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	56                   	push   %esi
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 42 ef ff ff       	call   800c22 <sys_page_unmap>
  801ce0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce3:	83 ec 08             	sub    $0x8,%esp
  801ce6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 32 ef ff ff       	call   800c22 <sys_page_unmap>
  801cf0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf3:	83 ec 08             	sub    $0x8,%esp
  801cf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 22 ef ff ff       	call   800c22 <sys_page_unmap>
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0a:	5b                   	pop    %ebx
  801d0b:	5e                   	pop    %esi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	ff 75 08             	pushl  0x8(%ebp)
  801d1b:	e8 30 f5 ff ff       	call   801250 <fd_lookup>
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 18                	js     801d3f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2d:	e8 b8 f4 ff ff       	call   8011ea <fd2data>
	return _pipeisclosed(fd, p);
  801d32:	89 c2                	mov    %eax,%edx
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	e8 21 fd ff ff       	call   801a5d <_pipeisclosed>
  801d3c:	83 c4 10             	add    $0x10,%esp
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d51:	68 7e 27 80 00       	push   $0x80277e
  801d56:	ff 75 0c             	pushl  0xc(%ebp)
  801d59:	e8 3c ea ff ff       	call   80079a <strcpy>
	return 0;
}
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	57                   	push   %edi
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d71:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d76:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7c:	eb 2d                	jmp    801dab <devcons_write+0x46>
		m = n - tot;
  801d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d81:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d83:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d86:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d8b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	53                   	push   %ebx
  801d92:	03 45 0c             	add    0xc(%ebp),%eax
  801d95:	50                   	push   %eax
  801d96:	57                   	push   %edi
  801d97:	e8 90 eb ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  801d9c:	83 c4 08             	add    $0x8,%esp
  801d9f:	53                   	push   %ebx
  801da0:	57                   	push   %edi
  801da1:	e8 3b ed ff ff       	call   800ae1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da6:	01 de                	add    %ebx,%esi
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	89 f0                	mov    %esi,%eax
  801dad:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db0:	72 cc                	jb     801d7e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dc5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc9:	74 2a                	je     801df5 <devcons_read+0x3b>
  801dcb:	eb 05                	jmp    801dd2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dcd:	e8 ac ed ff ff       	call   800b7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dd2:	e8 28 ed ff ff       	call   800aff <sys_cgetc>
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	74 f2                	je     801dcd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 16                	js     801df5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ddf:	83 f8 04             	cmp    $0x4,%eax
  801de2:	74 0c                	je     801df0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801de4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de7:	88 02                	mov    %al,(%edx)
	return 1;
  801de9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dee:	eb 05                	jmp    801df5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e03:	6a 01                	push   $0x1
  801e05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e08:	50                   	push   %eax
  801e09:	e8 d3 ec ff ff       	call   800ae1 <sys_cputs>
}
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <getchar>:

int
getchar(void)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e19:	6a 01                	push   $0x1
  801e1b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	6a 00                	push   $0x0
  801e21:	e8 90 f6 ff ff       	call   8014b6 <read>
	if (r < 0)
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 0f                	js     801e3c <getchar+0x29>
		return r;
	if (r < 1)
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	7e 06                	jle    801e37 <getchar+0x24>
		return -E_EOF;
	return c;
  801e31:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e35:	eb 05                	jmp    801e3c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e37:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	ff 75 08             	pushl  0x8(%ebp)
  801e4b:	e8 00 f4 ff ff       	call   801250 <fd_lookup>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 11                	js     801e68 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e60:	39 10                	cmp    %edx,(%eax)
  801e62:	0f 94 c0             	sete   %al
  801e65:	0f b6 c0             	movzbl %al,%eax
}
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    

00801e6a <opencons>:

int
opencons(void)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e73:	50                   	push   %eax
  801e74:	e8 88 f3 ff ff       	call   801201 <fd_alloc>
  801e79:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 3e                	js     801ec0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	68 07 04 00 00       	push   $0x407
  801e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 09 ed ff ff       	call   800b9d <sys_page_alloc>
  801e94:	83 c4 10             	add    $0x10,%esp
		return r;
  801e97:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 23                	js     801ec0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	50                   	push   %eax
  801eb6:	e8 1f f3 ff ff       	call   8011da <fd2num>
  801ebb:	89 c2                	mov    %eax,%edx
  801ebd:	83 c4 10             	add    $0x10,%esp
}
  801ec0:	89 d0                	mov    %edx,%eax
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ec9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ecc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ed2:	e8 88 ec ff ff       	call   800b5f <sys_getenvid>
  801ed7:	83 ec 0c             	sub    $0xc,%esp
  801eda:	ff 75 0c             	pushl  0xc(%ebp)
  801edd:	ff 75 08             	pushl  0x8(%ebp)
  801ee0:	56                   	push   %esi
  801ee1:	50                   	push   %eax
  801ee2:	68 8c 27 80 00       	push   $0x80278c
  801ee7:	e8 29 e3 ff ff       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eec:	83 c4 18             	add    $0x18,%esp
  801eef:	53                   	push   %ebx
  801ef0:	ff 75 10             	pushl  0x10(%ebp)
  801ef3:	e8 cc e2 ff ff       	call   8001c4 <vcprintf>
	cprintf("\n");
  801ef8:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  801eff:	e8 11 e3 ff ff       	call   800215 <cprintf>
  801f04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f07:	cc                   	int3   
  801f08:	eb fd                	jmp    801f07 <_panic+0x43>

00801f0a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f10:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f17:	75 2a                	jne    801f43 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f19:	83 ec 04             	sub    $0x4,%esp
  801f1c:	6a 07                	push   $0x7
  801f1e:	68 00 f0 bf ee       	push   $0xeebff000
  801f23:	6a 00                	push   $0x0
  801f25:	e8 73 ec ff ff       	call   800b9d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	79 12                	jns    801f43 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f31:	50                   	push   %eax
  801f32:	68 b0 27 80 00       	push   $0x8027b0
  801f37:	6a 23                	push   $0x23
  801f39:	68 b4 27 80 00       	push   $0x8027b4
  801f3e:	e8 81 ff ff ff       	call   801ec4 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f4b:	83 ec 08             	sub    $0x8,%esp
  801f4e:	68 75 1f 80 00       	push   $0x801f75
  801f53:	6a 00                	push   $0x0
  801f55:	e8 8e ed ff ff       	call   800ce8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	79 12                	jns    801f73 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f61:	50                   	push   %eax
  801f62:	68 b0 27 80 00       	push   $0x8027b0
  801f67:	6a 2c                	push   $0x2c
  801f69:	68 b4 27 80 00       	push   $0x8027b4
  801f6e:	e8 51 ff ff ff       	call   801ec4 <_panic>
	}
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f75:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f76:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f7b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f7d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f80:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f84:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f89:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f8d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f8f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f92:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f93:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f96:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f97:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f98:	c3                   	ret    

00801f99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	c1 e8 16             	shr    $0x16,%eax
  801fa4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb0:	f6 c1 01             	test   $0x1,%cl
  801fb3:	74 1d                	je     801fd2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb5:	c1 ea 0c             	shr    $0xc,%edx
  801fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbf:	f6 c2 01             	test   $0x1,%dl
  801fc2:	74 0e                	je     801fd2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc4:	c1 ea 0c             	shr    $0xc,%edx
  801fc7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fce:	ef 
  801fcf:	0f b7 c0             	movzwl %ax,%eax
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
