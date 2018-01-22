
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
  80003c:	e8 50 10 00 00       	call   801091 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 48 0b 00 00       	call   800b9b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 22 80 00       	push   $0x802280
  80005d:	e8 ef 01 00 00       	call   800251 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 31 0b 00 00       	call   800b9b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 22 80 00       	push   $0x80229a
  800074:	e8 d8 01 00 00       	call   800251 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 c0 10 00 00       	call   801147 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 38 10 00 00       	call   8010d2 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 50             	mov    0x50(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 e8 0a 00 00       	call   800b9b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 22 80 00       	push   $0x8022b0
  8000c2:	e8 8a 01 00 00       	call   800251 <cprintf>
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
  8000e5:	e8 5d 10 00 00       	call   801147 <ipc_send>
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
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800107:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80010e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800111:	e8 85 0a 00 00       	call   800b9b <sys_getenvid>
  800116:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	50                   	push   %eax
  80011c:	68 d8 22 80 00       	push   $0x8022d8
  800121:	e8 2b 01 00 00       	call   800251 <cprintf>
  800126:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  80012c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800139:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80013e:	89 c1                	mov    %eax,%ecx
  800140:	c1 e1 07             	shl    $0x7,%ecx
  800143:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80014a:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80014d:	39 cb                	cmp    %ecx,%ebx
  80014f:	0f 44 fa             	cmove  %edx,%edi
  800152:	b9 01 00 00 00       	mov    $0x1,%ecx
  800157:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80015a:	83 c0 01             	add    $0x1,%eax
  80015d:	81 c2 84 00 00 00    	add    $0x84,%edx
  800163:	3d 00 04 00 00       	cmp    $0x400,%eax
  800168:	75 d4                	jne    80013e <libmain+0x40>
  80016a:	89 f0                	mov    %esi,%eax
  80016c:	84 c0                	test   %al,%al
  80016e:	74 06                	je     800176 <libmain+0x78>
  800170:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80017a:	7e 0a                	jle    800186 <libmain+0x88>
		binaryname = argv[0];
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	8b 00                	mov    (%eax),%eax
  800181:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800186:	83 ec 08             	sub    $0x8,%esp
  800189:	ff 75 0c             	pushl  0xc(%ebp)
  80018c:	ff 75 08             	pushl  0x8(%ebp)
  80018f:	e8 9f fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800194:	e8 0b 00 00 00       	call   8001a4 <exit>
}
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5f                   	pop    %edi
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001aa:	e8 05 12 00 00       	call   8013b4 <close_all>
	sys_env_destroy(0);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	6a 00                	push   $0x0
  8001b4:	e8 a1 09 00 00       	call   800b5a <sys_env_destroy>
}
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 04             	sub    $0x4,%esp
  8001c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c8:	8b 13                	mov    (%ebx),%edx
  8001ca:	8d 42 01             	lea    0x1(%edx),%eax
  8001cd:	89 03                	mov    %eax,(%ebx)
  8001cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 1a                	jne    8001f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	68 ff 00 00 00       	push   $0xff
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	50                   	push   %eax
  8001e9:	e8 2f 09 00 00       	call   800b1d <sys_cputs>
		b->idx = 0;
  8001ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800209:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800210:	00 00 00 
	b.cnt = 0;
  800213:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	ff 75 08             	pushl  0x8(%ebp)
  800223:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800229:	50                   	push   %eax
  80022a:	68 be 01 80 00       	push   $0x8001be
  80022f:	e8 54 01 00 00       	call   800388 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800234:	83 c4 08             	add    $0x8,%esp
  800237:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800243:	50                   	push   %eax
  800244:	e8 d4 08 00 00       	call   800b1d <sys_cputs>

	return b.cnt;
}
  800249:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800257:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025a:	50                   	push   %eax
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	e8 9d ff ff ff       	call   800200 <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 1c             	sub    $0x1c,%esp
  80026e:	89 c7                	mov    %eax,%edi
  800270:	89 d6                	mov    %edx,%esi
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	8b 55 0c             	mov    0xc(%ebp),%edx
  800278:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80028c:	39 d3                	cmp    %edx,%ebx
  80028e:	72 05                	jb     800295 <printnum+0x30>
  800290:	39 45 10             	cmp    %eax,0x10(%ebp)
  800293:	77 45                	ja     8002da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	ff 75 18             	pushl  0x18(%ebp)
  80029b:	8b 45 14             	mov    0x14(%ebp),%eax
  80029e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002a1:	53                   	push   %ebx
  8002a2:	ff 75 10             	pushl  0x10(%ebp)
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 37 1d 00 00       	call   801ff0 <__udivdi3>
  8002b9:	83 c4 18             	add    $0x18,%esp
  8002bc:	52                   	push   %edx
  8002bd:	50                   	push   %eax
  8002be:	89 f2                	mov    %esi,%edx
  8002c0:	89 f8                	mov    %edi,%eax
  8002c2:	e8 9e ff ff ff       	call   800265 <printnum>
  8002c7:	83 c4 20             	add    $0x20,%esp
  8002ca:	eb 18                	jmp    8002e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	56                   	push   %esi
  8002d0:	ff 75 18             	pushl  0x18(%ebp)
  8002d3:	ff d7                	call   *%edi
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	eb 03                	jmp    8002dd <printnum+0x78>
  8002da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f e8                	jg     8002cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	56                   	push   %esi
  8002e8:	83 ec 04             	sub    $0x4,%esp
  8002eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f7:	e8 24 1e 00 00       	call   802120 <__umoddi3>
  8002fc:	83 c4 14             	add    $0x14,%esp
  8002ff:	0f be 80 01 23 80 00 	movsbl 0x802301(%eax),%eax
  800306:	50                   	push   %eax
  800307:	ff d7                	call   *%edi
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800317:	83 fa 01             	cmp    $0x1,%edx
  80031a:	7e 0e                	jle    80032a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	8b 52 04             	mov    0x4(%edx),%edx
  800328:	eb 22                	jmp    80034c <getuint+0x38>
	else if (lflag)
  80032a:	85 d2                	test   %edx,%edx
  80032c:	74 10                	je     80033e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 04             	lea    0x4(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	ba 00 00 00 00       	mov    $0x0,%edx
  80033c:	eb 0e                	jmp    80034c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 04             	lea    0x4(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800354:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	3b 50 04             	cmp    0x4(%eax),%edx
  80035d:	73 0a                	jae    800369 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	88 02                	mov    %al,(%edx)
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800371:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 10             	pushl  0x10(%ebp)
  800378:	ff 75 0c             	pushl  0xc(%ebp)
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 05 00 00 00       	call   800388 <vprintfmt>
	va_end(ap);
}
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
  80038e:	83 ec 2c             	sub    $0x2c,%esp
  800391:	8b 75 08             	mov    0x8(%ebp),%esi
  800394:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800397:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039a:	eb 12                	jmp    8003ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039c:	85 c0                	test   %eax,%eax
  80039e:	0f 84 89 03 00 00    	je     80072d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	53                   	push   %ebx
  8003a8:	50                   	push   %eax
  8003a9:	ff d6                	call   *%esi
  8003ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ae:	83 c7 01             	add    $0x1,%edi
  8003b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b5:	83 f8 25             	cmp    $0x25,%eax
  8003b8:	75 e2                	jne    80039c <vprintfmt+0x14>
  8003ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d8:	eb 07                	jmp    8003e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8d 47 01             	lea    0x1(%edi),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	0f b6 07             	movzbl (%edi),%eax
  8003ea:	0f b6 c8             	movzbl %al,%ecx
  8003ed:	83 e8 23             	sub    $0x23,%eax
  8003f0:	3c 55                	cmp    $0x55,%al
  8003f2:	0f 87 1a 03 00 00    	ja     800712 <vprintfmt+0x38a>
  8003f8:	0f b6 c0             	movzbl %al,%eax
  8003fb:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800405:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800409:	eb d6                	jmp    8003e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040e:	b8 00 00 00 00       	mov    $0x0,%eax
  800413:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800416:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800419:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80041d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800420:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800423:	83 fa 09             	cmp    $0x9,%edx
  800426:	77 39                	ja     800461 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800428:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042b:	eb e9                	jmp    800416 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 48 04             	lea    0x4(%eax),%ecx
  800433:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043e:	eb 27                	jmp    800467 <vprintfmt+0xdf>
  800440:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044a:	0f 49 c8             	cmovns %eax,%ecx
  80044d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800453:	eb 8c                	jmp    8003e1 <vprintfmt+0x59>
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800458:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045f:	eb 80                	jmp    8003e1 <vprintfmt+0x59>
  800461:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800464:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800467:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046b:	0f 89 70 ff ff ff    	jns    8003e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800471:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800474:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800477:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047e:	e9 5e ff ff ff       	jmp    8003e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800489:	e9 53 ff ff ff       	jmp    8003e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 50 04             	lea    0x4(%eax),%edx
  800494:	89 55 14             	mov    %edx,0x14(%ebp)
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	ff 30                	pushl  (%eax)
  80049d:	ff d6                	call   *%esi
			break;
  80049f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a5:	e9 04 ff ff ff       	jmp    8003ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	99                   	cltd   
  8004b6:	31 d0                	xor    %edx,%eax
  8004b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ba:	83 f8 0f             	cmp    $0xf,%eax
  8004bd:	7f 0b                	jg     8004ca <vprintfmt+0x142>
  8004bf:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	75 18                	jne    8004e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ca:	50                   	push   %eax
  8004cb:	68 19 23 80 00       	push   $0x802319
  8004d0:	53                   	push   %ebx
  8004d1:	56                   	push   %esi
  8004d2:	e8 94 fe ff ff       	call   80036b <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004dd:	e9 cc fe ff ff       	jmp    8003ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e2:	52                   	push   %edx
  8004e3:	68 65 27 80 00       	push   $0x802765
  8004e8:	53                   	push   %ebx
  8004e9:	56                   	push   %esi
  8004ea:	e8 7c fe ff ff       	call   80036b <printfmt>
  8004ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f5:	e9 b4 fe ff ff       	jmp    8003ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800505:	85 ff                	test   %edi,%edi
  800507:	b8 12 23 80 00       	mov    $0x802312,%eax
  80050c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80050f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800513:	0f 8e 94 00 00 00    	jle    8005ad <vprintfmt+0x225>
  800519:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80051d:	0f 84 98 00 00 00    	je     8005bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	ff 75 d0             	pushl  -0x30(%ebp)
  800529:	57                   	push   %edi
  80052a:	e8 86 02 00 00       	call   8007b5 <strnlen>
  80052f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800532:	29 c1                	sub    %eax,%ecx
  800534:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800537:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80053a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80053e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800541:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800544:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800546:	eb 0f                	jmp    800557 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	ff 75 e0             	pushl  -0x20(%ebp)
  80054f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	83 ef 01             	sub    $0x1,%edi
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	85 ff                	test   %edi,%edi
  800559:	7f ed                	jg     800548 <vprintfmt+0x1c0>
  80055b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800561:	85 c9                	test   %ecx,%ecx
  800563:	b8 00 00 00 00       	mov    $0x0,%eax
  800568:	0f 49 c1             	cmovns %ecx,%eax
  80056b:	29 c1                	sub    %eax,%ecx
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	89 cb                	mov    %ecx,%ebx
  800578:	eb 4d                	jmp    8005c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057e:	74 1b                	je     80059b <vprintfmt+0x213>
  800580:	0f be c0             	movsbl %al,%eax
  800583:	83 e8 20             	sub    $0x20,%eax
  800586:	83 f8 5e             	cmp    $0x5e,%eax
  800589:	76 10                	jbe    80059b <vprintfmt+0x213>
					putch('?', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	ff 75 0c             	pushl  0xc(%ebp)
  800591:	6a 3f                	push   $0x3f
  800593:	ff 55 08             	call   *0x8(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	eb 0d                	jmp    8005a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	ff 75 0c             	pushl  0xc(%ebp)
  8005a1:	52                   	push   %edx
  8005a2:	ff 55 08             	call   *0x8(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a8:	83 eb 01             	sub    $0x1,%ebx
  8005ab:	eb 1a                	jmp    8005c7 <vprintfmt+0x23f>
  8005ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b9:	eb 0c                	jmp    8005c7 <vprintfmt+0x23f>
  8005bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c7:	83 c7 01             	add    $0x1,%edi
  8005ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ce:	0f be d0             	movsbl %al,%edx
  8005d1:	85 d2                	test   %edx,%edx
  8005d3:	74 23                	je     8005f8 <vprintfmt+0x270>
  8005d5:	85 f6                	test   %esi,%esi
  8005d7:	78 a1                	js     80057a <vprintfmt+0x1f2>
  8005d9:	83 ee 01             	sub    $0x1,%esi
  8005dc:	79 9c                	jns    80057a <vprintfmt+0x1f2>
  8005de:	89 df                	mov    %ebx,%edi
  8005e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e6:	eb 18                	jmp    800600 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 20                	push   $0x20
  8005ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f0:	83 ef 01             	sub    $0x1,%edi
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	eb 08                	jmp    800600 <vprintfmt+0x278>
  8005f8:	89 df                	mov    %ebx,%edi
  8005fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800600:	85 ff                	test   %edi,%edi
  800602:	7f e4                	jg     8005e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800607:	e9 a2 fd ff ff       	jmp    8003ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060c:	83 fa 01             	cmp    $0x1,%edx
  80060f:	7e 16                	jle    800627 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 08             	lea    0x8(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 50 04             	mov    0x4(%eax),%edx
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800622:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800625:	eb 32                	jmp    800659 <vprintfmt+0x2d1>
	else if (lflag)
  800627:	85 d2                	test   %edx,%edx
  800629:	74 18                	je     800643 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 c1                	mov    %eax,%ecx
  80063b:	c1 f9 1f             	sar    $0x1f,%ecx
  80063e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800641:	eb 16                	jmp    800659 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 00                	mov    (%eax),%eax
  80064e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800651:	89 c1                	mov    %eax,%ecx
  800653:	c1 f9 1f             	sar    $0x1f,%ecx
  800656:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800659:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800664:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800668:	79 74                	jns    8006de <vprintfmt+0x356>
				putch('-', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 2d                	push   $0x2d
  800670:	ff d6                	call   *%esi
				num = -(long long) num;
  800672:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800675:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800678:	f7 d8                	neg    %eax
  80067a:	83 d2 00             	adc    $0x0,%edx
  80067d:	f7 da                	neg    %edx
  80067f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800682:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800687:	eb 55                	jmp    8006de <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
  80068c:	e8 83 fc ff ff       	call   800314 <getuint>
			base = 10;
  800691:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800696:	eb 46                	jmp    8006de <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
  80069b:	e8 74 fc ff ff       	call   800314 <getuint>
			base = 8;
  8006a0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006a5:	eb 37                	jmp    8006de <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 30                	push   $0x30
  8006ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 78                	push   $0x78
  8006b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ca:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006cf:	eb 0d                	jmp    8006de <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 3b fc ff ff       	call   800314 <getuint>
			base = 16;
  8006d9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006de:	83 ec 0c             	sub    $0xc,%esp
  8006e1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e5:	57                   	push   %edi
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	51                   	push   %ecx
  8006ea:	52                   	push   %edx
  8006eb:	50                   	push   %eax
  8006ec:	89 da                	mov    %ebx,%edx
  8006ee:	89 f0                	mov    %esi,%eax
  8006f0:	e8 70 fb ff ff       	call   800265 <printnum>
			break;
  8006f5:	83 c4 20             	add    $0x20,%esp
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fb:	e9 ae fc ff ff       	jmp    8003ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	51                   	push   %ecx
  800705:	ff d6                	call   *%esi
			break;
  800707:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070d:	e9 9c fc ff ff       	jmp    8003ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 25                	push   $0x25
  800718:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 03                	jmp    800722 <vprintfmt+0x39a>
  80071f:	83 ef 01             	sub    $0x1,%edi
  800722:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800726:	75 f7                	jne    80071f <vprintfmt+0x397>
  800728:	e9 81 fc ff ff       	jmp    8003ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5f                   	pop    %edi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800741:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800744:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800748:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800752:	85 c0                	test   %eax,%eax
  800754:	74 26                	je     80077c <vsnprintf+0x47>
  800756:	85 d2                	test   %edx,%edx
  800758:	7e 22                	jle    80077c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075a:	ff 75 14             	pushl  0x14(%ebp)
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	68 4e 03 80 00       	push   $0x80034e
  800769:	e8 1a fc ff ff       	call   800388 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800771:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	eb 05                	jmp    800781 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078c:	50                   	push   %eax
  80078d:	ff 75 10             	pushl  0x10(%ebp)
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 9a ff ff ff       	call   800735 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	eb 03                	jmp    8007ad <strlen+0x10>
		n++;
  8007aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b1:	75 f7                	jne    8007aa <strlen+0xd>
		n++;
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c3:	eb 03                	jmp    8007c8 <strnlen+0x13>
		n++;
  8007c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	39 c2                	cmp    %eax,%edx
  8007ca:	74 08                	je     8007d4 <strnlen+0x1f>
  8007cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d0:	75 f3                	jne    8007c5 <strnlen+0x10>
  8007d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e0:	89 c2                	mov    %eax,%edx
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ef                	jne    8007e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f3:	5b                   	pop    %ebx
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fd:	53                   	push   %ebx
  8007fe:	e8 9a ff ff ff       	call   80079d <strlen>
  800803:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800806:	ff 75 0c             	pushl  0xc(%ebp)
  800809:	01 d8                	add    %ebx,%eax
  80080b:	50                   	push   %eax
  80080c:	e8 c5 ff ff ff       	call   8007d6 <strcpy>
	return dst;
}
  800811:	89 d8                	mov    %ebx,%eax
  800813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	89 f3                	mov    %esi,%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	89 f2                	mov    %esi,%edx
  80082a:	eb 0f                	jmp    80083b <strncpy+0x23>
		*dst++ = *src;
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	0f b6 01             	movzbl (%ecx),%eax
  800832:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800835:	80 39 01             	cmpb   $0x1,(%ecx)
  800838:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	39 da                	cmp    %ebx,%edx
  80083d:	75 ed                	jne    80082c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083f:	89 f0                	mov    %esi,%eax
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 75 08             	mov    0x8(%ebp),%esi
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	8b 55 10             	mov    0x10(%ebp),%edx
  800853:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800855:	85 d2                	test   %edx,%edx
  800857:	74 21                	je     80087a <strlcpy+0x35>
  800859:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085d:	89 f2                	mov    %esi,%edx
  80085f:	eb 09                	jmp    80086a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	83 c1 01             	add    $0x1,%ecx
  800867:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086a:	39 c2                	cmp    %eax,%edx
  80086c:	74 09                	je     800877 <strlcpy+0x32>
  80086e:	0f b6 19             	movzbl (%ecx),%ebx
  800871:	84 db                	test   %bl,%bl
  800873:	75 ec                	jne    800861 <strlcpy+0x1c>
  800875:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800877:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087a:	29 f0                	sub    %esi,%eax
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800889:	eb 06                	jmp    800891 <strcmp+0x11>
		p++, q++;
  80088b:	83 c1 01             	add    $0x1,%ecx
  80088e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800891:	0f b6 01             	movzbl (%ecx),%eax
  800894:	84 c0                	test   %al,%al
  800896:	74 04                	je     80089c <strcmp+0x1c>
  800898:	3a 02                	cmp    (%edx),%al
  80089a:	74 ef                	je     80088b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089c:	0f b6 c0             	movzbl %al,%eax
  80089f:	0f b6 12             	movzbl (%edx),%edx
  8008a2:	29 d0                	sub    %edx,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b0:	89 c3                	mov    %eax,%ebx
  8008b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b5:	eb 06                	jmp    8008bd <strncmp+0x17>
		n--, p++, q++;
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bd:	39 d8                	cmp    %ebx,%eax
  8008bf:	74 15                	je     8008d6 <strncmp+0x30>
  8008c1:	0f b6 08             	movzbl (%eax),%ecx
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	74 04                	je     8008cc <strncmp+0x26>
  8008c8:	3a 0a                	cmp    (%edx),%cl
  8008ca:	74 eb                	je     8008b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cc:	0f b6 00             	movzbl (%eax),%eax
  8008cf:	0f b6 12             	movzbl (%edx),%edx
  8008d2:	29 d0                	sub    %edx,%eax
  8008d4:	eb 05                	jmp    8008db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 07                	jmp    8008f1 <strchr+0x13>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 0f                	je     8008fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f2                	jne    8008ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800909:	eb 03                	jmp    80090e <strfind+0xf>
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 04                	je     800919 <strfind+0x1a>
  800915:	84 d2                	test   %dl,%dl
  800917:	75 f2                	jne    80090b <strfind+0xc>
			break;
	return (char *) s;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	8b 7d 08             	mov    0x8(%ebp),%edi
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800927:	85 c9                	test   %ecx,%ecx
  800929:	74 36                	je     800961 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800931:	75 28                	jne    80095b <memset+0x40>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 23                	jne    80095b <memset+0x40>
		c &= 0xFF;
  800938:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093c:	89 d3                	mov    %edx,%ebx
  80093e:	c1 e3 08             	shl    $0x8,%ebx
  800941:	89 d6                	mov    %edx,%esi
  800943:	c1 e6 18             	shl    $0x18,%esi
  800946:	89 d0                	mov    %edx,%eax
  800948:	c1 e0 10             	shl    $0x10,%eax
  80094b:	09 f0                	or     %esi,%eax
  80094d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094f:	89 d8                	mov    %ebx,%eax
  800951:	09 d0                	or     %edx,%eax
  800953:	c1 e9 02             	shr    $0x2,%ecx
  800956:	fc                   	cld    
  800957:	f3 ab                	rep stos %eax,%es:(%edi)
  800959:	eb 06                	jmp    800961 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 35                	jae    8009af <memmove+0x47>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2e                	jae    8009af <memmove+0x47>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 d6                	mov    %edx,%esi
  800986:	09 fe                	or     %edi,%esi
  800988:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098e:	75 13                	jne    8009a3 <memmove+0x3b>
  800990:	f6 c1 03             	test   $0x3,%cl
  800993:	75 0e                	jne    8009a3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800995:	83 ef 04             	sub    $0x4,%edi
  800998:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099b:	c1 e9 02             	shr    $0x2,%ecx
  80099e:	fd                   	std    
  80099f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a1:	eb 09                	jmp    8009ac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a3:	83 ef 01             	sub    $0x1,%edi
  8009a6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a9:	fd                   	std    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ac:	fc                   	cld    
  8009ad:	eb 1d                	jmp    8009cc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	89 f2                	mov    %esi,%edx
  8009b1:	09 c2                	or     %eax,%edx
  8009b3:	f6 c2 03             	test   $0x3,%dl
  8009b6:	75 0f                	jne    8009c7 <memmove+0x5f>
  8009b8:	f6 c1 03             	test   $0x3,%cl
  8009bb:	75 0a                	jne    8009c7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb 05                	jmp    8009cc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	fc                   	cld    
  8009ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cc:	5e                   	pop    %esi
  8009cd:	5f                   	pop    %edi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d3:	ff 75 10             	pushl  0x10(%ebp)
  8009d6:	ff 75 0c             	pushl  0xc(%ebp)
  8009d9:	ff 75 08             	pushl  0x8(%ebp)
  8009dc:	e8 87 ff ff ff       	call   800968 <memmove>
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ee:	89 c6                	mov    %eax,%esi
  8009f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	eb 1a                	jmp    800a0f <memcmp+0x2c>
		if (*s1 != *s2)
  8009f5:	0f b6 08             	movzbl (%eax),%ecx
  8009f8:	0f b6 1a             	movzbl (%edx),%ebx
  8009fb:	38 d9                	cmp    %bl,%cl
  8009fd:	74 0a                	je     800a09 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ff:	0f b6 c1             	movzbl %cl,%eax
  800a02:	0f b6 db             	movzbl %bl,%ebx
  800a05:	29 d8                	sub    %ebx,%eax
  800a07:	eb 0f                	jmp    800a18 <memcmp+0x35>
		s1++, s2++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	39 f0                	cmp    %esi,%eax
  800a11:	75 e2                	jne    8009f5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	53                   	push   %ebx
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a23:	89 c1                	mov    %eax,%ecx
  800a25:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2c:	eb 0a                	jmp    800a38 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	39 da                	cmp    %ebx,%edx
  800a33:	74 07                	je     800a3c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	39 c8                	cmp    %ecx,%eax
  800a3a:	72 f2                	jb     800a2e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4b:	eb 03                	jmp    800a50 <strtol+0x11>
		s++;
  800a4d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a50:	0f b6 01             	movzbl (%ecx),%eax
  800a53:	3c 20                	cmp    $0x20,%al
  800a55:	74 f6                	je     800a4d <strtol+0xe>
  800a57:	3c 09                	cmp    $0x9,%al
  800a59:	74 f2                	je     800a4d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5b:	3c 2b                	cmp    $0x2b,%al
  800a5d:	75 0a                	jne    800a69 <strtol+0x2a>
		s++;
  800a5f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
  800a67:	eb 11                	jmp    800a7a <strtol+0x3b>
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6e:	3c 2d                	cmp    $0x2d,%al
  800a70:	75 08                	jne    800a7a <strtol+0x3b>
		s++, neg = 1;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a80:	75 15                	jne    800a97 <strtol+0x58>
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	75 10                	jne    800a97 <strtol+0x58>
  800a87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8b:	75 7c                	jne    800b09 <strtol+0xca>
		s += 2, base = 16;
  800a8d:	83 c1 02             	add    $0x2,%ecx
  800a90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a95:	eb 16                	jmp    800aad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a97:	85 db                	test   %ebx,%ebx
  800a99:	75 12                	jne    800aad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa0:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa3:	75 08                	jne    800aad <strtol+0x6e>
		s++, base = 8;
  800aa5:	83 c1 01             	add    $0x1,%ecx
  800aa8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab5:	0f b6 11             	movzbl (%ecx),%edx
  800ab8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abb:	89 f3                	mov    %esi,%ebx
  800abd:	80 fb 09             	cmp    $0x9,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x8b>
			dig = *s - '0';
  800ac2:	0f be d2             	movsbl %dl,%edx
  800ac5:	83 ea 30             	sub    $0x30,%edx
  800ac8:	eb 22                	jmp    800aec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aca:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	80 fb 19             	cmp    $0x19,%bl
  800ad2:	77 08                	ja     800adc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 57             	sub    $0x57,%edx
  800ada:	eb 10                	jmp    800aec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800adc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 16                	ja     800afc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aec:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aef:	7d 0b                	jge    800afc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afa:	eb b9                	jmp    800ab5 <strtol+0x76>

	if (endptr)
  800afc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b00:	74 0d                	je     800b0f <strtol+0xd0>
		*endptr = (char *) s;
  800b02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b05:	89 0e                	mov    %ecx,(%esi)
  800b07:	eb 06                	jmp    800b0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	74 98                	je     800aa5 <strtol+0x66>
  800b0d:	eb 9e                	jmp    800aad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	f7 da                	neg    %edx
  800b13:	85 ff                	test   %edi,%edi
  800b15:	0f 45 c2             	cmovne %edx,%eax
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	89 c3                	mov    %eax,%ebx
  800b30:	89 c7                	mov    %eax,%edi
  800b32:	89 c6                	mov    %eax,%esi
  800b34:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b68:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	89 cb                	mov    %ecx,%ebx
  800b72:	89 cf                	mov    %ecx,%edi
  800b74:	89 ce                	mov    %ecx,%esi
  800b76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 17                	jle    800b93 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 03                	push   $0x3
  800b82:	68 ff 25 80 00       	push   $0x8025ff
  800b87:	6a 23                	push   $0x23
  800b89:	68 1c 26 80 00       	push   $0x80261c
  800b8e:	e8 40 13 00 00       	call   801ed3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_yield>:

void
sys_yield(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	be 00 00 00 00       	mov    $0x0,%esi
  800be7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	89 f7                	mov    %esi,%edi
  800bf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 04                	push   $0x4
  800c03:	68 ff 25 80 00       	push   $0x8025ff
  800c08:	6a 23                	push   $0x23
  800c0a:	68 1c 26 80 00       	push   $0x80261c
  800c0f:	e8 bf 12 00 00       	call   801ed3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c36:	8b 75 18             	mov    0x18(%ebp),%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 05                	push   $0x5
  800c45:	68 ff 25 80 00       	push   $0x8025ff
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 1c 26 80 00       	push   $0x80261c
  800c51:	e8 7d 12 00 00       	call   801ed3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 06                	push   $0x6
  800c87:	68 ff 25 80 00       	push   $0x8025ff
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 1c 26 80 00       	push   $0x80261c
  800c93:	e8 3b 12 00 00       	call   801ed3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cae:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	89 df                	mov    %ebx,%edi
  800cbb:	89 de                	mov    %ebx,%esi
  800cbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 08                	push   $0x8
  800cc9:	68 ff 25 80 00       	push   $0x8025ff
  800cce:	6a 23                	push   $0x23
  800cd0:	68 1c 26 80 00       	push   $0x80261c
  800cd5:	e8 f9 11 00 00       	call   801ed3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 df                	mov    %ebx,%edi
  800cfd:	89 de                	mov    %ebx,%esi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 09                	push   $0x9
  800d0b:	68 ff 25 80 00       	push   $0x8025ff
  800d10:	6a 23                	push   $0x23
  800d12:	68 1c 26 80 00       	push   $0x80261c
  800d17:	e8 b7 11 00 00       	call   801ed3 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 df                	mov    %ebx,%edi
  800d3f:	89 de                	mov    %ebx,%esi
  800d41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0a                	push   $0xa
  800d4d:	68 ff 25 80 00       	push   $0x8025ff
  800d52:	6a 23                	push   $0x23
  800d54:	68 1c 26 80 00       	push   $0x80261c
  800d59:	e8 75 11 00 00       	call   801ed3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 cb                	mov    %ecx,%ebx
  800da1:	89 cf                	mov    %ecx,%edi
  800da3:	89 ce                	mov    %ecx,%esi
  800da5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 0d                	push   $0xd
  800db1:	68 ff 25 80 00       	push   $0x8025ff
  800db6:	6a 23                	push   $0x23
  800db8:	68 1c 26 80 00       	push   $0x80261c
  800dbd:	e8 11 11 00 00       	call   801ed3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 cb                	mov    %ecx,%ebx
  800ddf:	89 cf                	mov    %ecx,%edi
  800de1:	89 ce                	mov    %ecx,%esi
  800de3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	53                   	push   %ebx
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800df6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dfa:	74 11                	je     800e0d <pgfault+0x23>
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	c1 e8 0c             	shr    $0xc,%eax
  800e01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e08:	f6 c4 08             	test   $0x8,%ah
  800e0b:	75 14                	jne    800e21 <pgfault+0x37>
		panic("faulting access");
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	68 2a 26 80 00       	push   $0x80262a
  800e15:	6a 1d                	push   $0x1d
  800e17:	68 3a 26 80 00       	push   $0x80263a
  800e1c:	e8 b2 10 00 00       	call   801ed3 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	6a 07                	push   $0x7
  800e26:	68 00 f0 7f 00       	push   $0x7ff000
  800e2b:	6a 00                	push   $0x0
  800e2d:	e8 a7 fd ff ff       	call   800bd9 <sys_page_alloc>
	if (r < 0) {
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	79 12                	jns    800e4b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e39:	50                   	push   %eax
  800e3a:	68 45 26 80 00       	push   $0x802645
  800e3f:	6a 2b                	push   $0x2b
  800e41:	68 3a 26 80 00       	push   $0x80263a
  800e46:	e8 88 10 00 00       	call   801ed3 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e4b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	68 00 10 00 00       	push   $0x1000
  800e59:	53                   	push   %ebx
  800e5a:	68 00 f0 7f 00       	push   $0x7ff000
  800e5f:	e8 6c fb ff ff       	call   8009d0 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e64:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e6b:	53                   	push   %ebx
  800e6c:	6a 00                	push   $0x0
  800e6e:	68 00 f0 7f 00       	push   $0x7ff000
  800e73:	6a 00                	push   $0x0
  800e75:	e8 a2 fd ff ff       	call   800c1c <sys_page_map>
	if (r < 0) {
  800e7a:	83 c4 20             	add    $0x20,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	79 12                	jns    800e93 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e81:	50                   	push   %eax
  800e82:	68 45 26 80 00       	push   $0x802645
  800e87:	6a 32                	push   $0x32
  800e89:	68 3a 26 80 00       	push   $0x80263a
  800e8e:	e8 40 10 00 00       	call   801ed3 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	68 00 f0 7f 00       	push   $0x7ff000
  800e9b:	6a 00                	push   $0x0
  800e9d:	e8 bc fd ff ff       	call   800c5e <sys_page_unmap>
	if (r < 0) {
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	79 12                	jns    800ebb <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ea9:	50                   	push   %eax
  800eaa:	68 45 26 80 00       	push   $0x802645
  800eaf:	6a 36                	push   $0x36
  800eb1:	68 3a 26 80 00       	push   $0x80263a
  800eb6:	e8 18 10 00 00       	call   801ed3 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ec9:	68 ea 0d 80 00       	push   $0x800dea
  800ece:	e8 46 10 00 00       	call   801f19 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed3:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed8:	cd 30                	int    $0x30
  800eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	79 17                	jns    800efb <fork+0x3b>
		panic("fork fault %e");
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 5e 26 80 00       	push   $0x80265e
  800eec:	68 83 00 00 00       	push   $0x83
  800ef1:	68 3a 26 80 00       	push   $0x80263a
  800ef6:	e8 d8 0f 00 00       	call   801ed3 <_panic>
  800efb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800efd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f01:	75 25                	jne    800f28 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f03:	e8 93 fc ff ff       	call   800b9b <sys_getenvid>
  800f08:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0d:	89 c2                	mov    %eax,%edx
  800f0f:	c1 e2 07             	shl    $0x7,%edx
  800f12:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800f19:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f23:	e9 61 01 00 00       	jmp    801089 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	6a 07                	push   $0x7
  800f2d:	68 00 f0 bf ee       	push   $0xeebff000
  800f32:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f35:	e8 9f fc ff ff       	call   800bd9 <sys_page_alloc>
  800f3a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f42:	89 d8                	mov    %ebx,%eax
  800f44:	c1 e8 16             	shr    $0x16,%eax
  800f47:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4e:	a8 01                	test   $0x1,%al
  800f50:	0f 84 fc 00 00 00    	je     801052 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f56:	89 d8                	mov    %ebx,%eax
  800f58:	c1 e8 0c             	shr    $0xc,%eax
  800f5b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f62:	f6 c2 01             	test   $0x1,%dl
  800f65:	0f 84 e7 00 00 00    	je     801052 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f6b:	89 c6                	mov    %eax,%esi
  800f6d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f70:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f77:	f6 c6 04             	test   $0x4,%dh
  800f7a:	74 39                	je     800fb5 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f7c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	25 07 0e 00 00       	and    $0xe07,%eax
  800f8b:	50                   	push   %eax
  800f8c:	56                   	push   %esi
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 86 fc ff ff       	call   800c1c <sys_page_map>
		if (r < 0) {
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	0f 89 b1 00 00 00    	jns    801052 <fork+0x192>
		    	panic("sys page map fault %e");
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	68 6c 26 80 00       	push   $0x80266c
  800fa9:	6a 53                	push   $0x53
  800fab:	68 3a 26 80 00       	push   $0x80263a
  800fb0:	e8 1e 0f 00 00       	call   801ed3 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c2 02             	test   $0x2,%dl
  800fbf:	75 0c                	jne    800fcd <fork+0x10d>
  800fc1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc8:	f6 c4 08             	test   $0x8,%ah
  800fcb:	74 5b                	je     801028 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	68 05 08 00 00       	push   $0x805
  800fd5:	56                   	push   %esi
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 3d fc ff ff       	call   800c1c <sys_page_map>
		if (r < 0) {
  800fdf:	83 c4 20             	add    $0x20,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 14                	jns    800ffa <fork+0x13a>
		    	panic("sys page map fault %e");
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 6c 26 80 00       	push   $0x80266c
  800fee:	6a 5a                	push   $0x5a
  800ff0:	68 3a 26 80 00       	push   $0x80263a
  800ff5:	e8 d9 0e 00 00       	call   801ed3 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	68 05 08 00 00       	push   $0x805
  801002:	56                   	push   %esi
  801003:	6a 00                	push   $0x0
  801005:	56                   	push   %esi
  801006:	6a 00                	push   $0x0
  801008:	e8 0f fc ff ff       	call   800c1c <sys_page_map>
		if (r < 0) {
  80100d:	83 c4 20             	add    $0x20,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	79 3e                	jns    801052 <fork+0x192>
		    	panic("sys page map fault %e");
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	68 6c 26 80 00       	push   $0x80266c
  80101c:	6a 5e                	push   $0x5e
  80101e:	68 3a 26 80 00       	push   $0x80263a
  801023:	e8 ab 0e 00 00       	call   801ed3 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	6a 05                	push   $0x5
  80102d:	56                   	push   %esi
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	6a 00                	push   $0x0
  801032:	e8 e5 fb ff ff       	call   800c1c <sys_page_map>
		if (r < 0) {
  801037:	83 c4 20             	add    $0x20,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	79 14                	jns    801052 <fork+0x192>
		    	panic("sys page map fault %e");
  80103e:	83 ec 04             	sub    $0x4,%esp
  801041:	68 6c 26 80 00       	push   $0x80266c
  801046:	6a 63                	push   $0x63
  801048:	68 3a 26 80 00       	push   $0x80263a
  80104d:	e8 81 0e 00 00       	call   801ed3 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801052:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801058:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80105e:	0f 85 de fe ff ff    	jne    800f42 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801064:	a1 08 40 80 00       	mov    0x804008,%eax
  801069:	8b 40 6c             	mov    0x6c(%eax),%eax
  80106c:	83 ec 08             	sub    $0x8,%esp
  80106f:	50                   	push   %eax
  801070:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801073:	57                   	push   %edi
  801074:	e8 ab fc ff ff       	call   800d24 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801079:	83 c4 08             	add    $0x8,%esp
  80107c:	6a 02                	push   $0x2
  80107e:	57                   	push   %edi
  80107f:	e8 1c fc ff ff       	call   800ca0 <sys_env_set_status>
	
	return envid;
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sfork>:

envid_t
sfork(void)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801094:	b8 00 00 00 00       	mov    $0x0,%eax
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	53                   	push   %ebx
  8010a7:	68 84 26 80 00       	push   $0x802684
  8010ac:	e8 a0 f1 ff ff       	call   800251 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8010b1:	89 1c 24             	mov    %ebx,(%esp)
  8010b4:	e8 11 fd ff ff       	call   800dca <sys_thread_create>
  8010b9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	53                   	push   %ebx
  8010bf:	68 84 26 80 00       	push   $0x802684
  8010c4:	e8 88 f1 ff ff       	call   800251 <cprintf>
	return id;
}
  8010c9:	89 f0                	mov    %esi,%eax
  8010cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8010da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	75 12                	jne    8010f6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	68 00 00 c0 ee       	push   $0xeec00000
  8010ec:	e8 98 fc ff ff       	call   800d89 <sys_ipc_recv>
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	eb 0c                	jmp    801102 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	50                   	push   %eax
  8010fa:	e8 8a fc ff ff       	call   800d89 <sys_ipc_recv>
  8010ff:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801102:	85 f6                	test   %esi,%esi
  801104:	0f 95 c1             	setne  %cl
  801107:	85 db                	test   %ebx,%ebx
  801109:	0f 95 c2             	setne  %dl
  80110c:	84 d1                	test   %dl,%cl
  80110e:	74 09                	je     801119 <ipc_recv+0x47>
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 1f             	shr    $0x1f,%edx
  801115:	84 d2                	test   %dl,%dl
  801117:	75 27                	jne    801140 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801119:	85 f6                	test   %esi,%esi
  80111b:	74 0a                	je     801127 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80111d:	a1 08 40 80 00       	mov    0x804008,%eax
  801122:	8b 40 7c             	mov    0x7c(%eax),%eax
  801125:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801127:	85 db                	test   %ebx,%ebx
  801129:	74 0d                	je     801138 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  80112b:	a1 08 40 80 00       	mov    0x804008,%eax
  801130:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801136:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801138:	a1 08 40 80 00       	mov    0x804008,%eax
  80113d:	8b 40 78             	mov    0x78(%eax),%eax
}
  801140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	8b 7d 08             	mov    0x8(%ebp),%edi
  801153:	8b 75 0c             	mov    0xc(%ebp),%esi
  801156:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801159:	85 db                	test   %ebx,%ebx
  80115b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801160:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801163:	ff 75 14             	pushl  0x14(%ebp)
  801166:	53                   	push   %ebx
  801167:	56                   	push   %esi
  801168:	57                   	push   %edi
  801169:	e8 f8 fb ff ff       	call   800d66 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80116e:	89 c2                	mov    %eax,%edx
  801170:	c1 ea 1f             	shr    $0x1f,%edx
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	84 d2                	test   %dl,%dl
  801178:	74 17                	je     801191 <ipc_send+0x4a>
  80117a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80117d:	74 12                	je     801191 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80117f:	50                   	push   %eax
  801180:	68 a7 26 80 00       	push   $0x8026a7
  801185:	6a 47                	push   $0x47
  801187:	68 b5 26 80 00       	push   $0x8026b5
  80118c:	e8 42 0d 00 00       	call   801ed3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801191:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801194:	75 07                	jne    80119d <ipc_send+0x56>
			sys_yield();
  801196:	e8 1f fa ff ff       	call   800bba <sys_yield>
  80119b:	eb c6                	jmp    801163 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80119d:	85 c0                	test   %eax,%eax
  80119f:	75 c2                	jne    801163 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	c1 e2 07             	shl    $0x7,%edx
  8011b9:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8011c0:	8b 52 58             	mov    0x58(%edx),%edx
  8011c3:	39 ca                	cmp    %ecx,%edx
  8011c5:	75 11                	jne    8011d8 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	c1 e2 07             	shl    $0x7,%edx
  8011cc:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8011d3:	8b 40 50             	mov    0x50(%eax),%eax
  8011d6:	eb 0f                	jmp    8011e7 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011d8:	83 c0 01             	add    $0x1,%eax
  8011db:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011e0:	75 d2                	jne    8011b4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ff:	05 00 00 00 30       	add    $0x30000000,%eax
  801204:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801209:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801216:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	c1 ea 16             	shr    $0x16,%edx
  801220:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801227:	f6 c2 01             	test   $0x1,%dl
  80122a:	74 11                	je     80123d <fd_alloc+0x2d>
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	c1 ea 0c             	shr    $0xc,%edx
  801231:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801238:	f6 c2 01             	test   $0x1,%dl
  80123b:	75 09                	jne    801246 <fd_alloc+0x36>
			*fd_store = fd;
  80123d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	eb 17                	jmp    80125d <fd_alloc+0x4d>
  801246:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80124b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801250:	75 c9                	jne    80121b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801252:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801258:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801265:	83 f8 1f             	cmp    $0x1f,%eax
  801268:	77 36                	ja     8012a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126a:	c1 e0 0c             	shl    $0xc,%eax
  80126d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 16             	shr    $0x16,%edx
  801277:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 24                	je     8012a7 <fd_lookup+0x48>
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 0c             	shr    $0xc,%edx
  801288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 1a                	je     8012ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801294:	8b 55 0c             	mov    0xc(%ebp),%edx
  801297:	89 02                	mov    %eax,(%edx)
	return 0;
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
  80129e:	eb 13                	jmp    8012b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a5:	eb 0c                	jmp    8012b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 05                	jmp    8012b3 <fd_lookup+0x54>
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012be:	ba 3c 27 80 00       	mov    $0x80273c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c3:	eb 13                	jmp    8012d8 <dev_lookup+0x23>
  8012c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012c8:	39 08                	cmp    %ecx,(%eax)
  8012ca:	75 0c                	jne    8012d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8012cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	eb 2e                	jmp    801306 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d8:	8b 02                	mov    (%edx),%eax
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	75 e7                	jne    8012c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012de:	a1 08 40 80 00       	mov    0x804008,%eax
  8012e3:	8b 40 50             	mov    0x50(%eax),%eax
  8012e6:	83 ec 04             	sub    $0x4,%esp
  8012e9:	51                   	push   %ecx
  8012ea:	50                   	push   %eax
  8012eb:	68 c0 26 80 00       	push   $0x8026c0
  8012f0:	e8 5c ef ff ff       	call   800251 <cprintf>
	*dev = 0;
  8012f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 10             	sub    $0x10,%esp
  801310:	8b 75 08             	mov    0x8(%ebp),%esi
  801313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801320:	c1 e8 0c             	shr    $0xc,%eax
  801323:	50                   	push   %eax
  801324:	e8 36 ff ff ff       	call   80125f <fd_lookup>
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 05                	js     801335 <fd_close+0x2d>
	    || fd != fd2)
  801330:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801333:	74 0c                	je     801341 <fd_close+0x39>
		return (must_exist ? r : 0);
  801335:	84 db                	test   %bl,%bl
  801337:	ba 00 00 00 00       	mov    $0x0,%edx
  80133c:	0f 44 c2             	cmove  %edx,%eax
  80133f:	eb 41                	jmp    801382 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 36                	pushl  (%esi)
  80134a:	e8 66 ff ff ff       	call   8012b5 <dev_lookup>
  80134f:	89 c3                	mov    %eax,%ebx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 1a                	js     801372 <fd_close+0x6a>
		if (dev->dev_close)
  801358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801363:	85 c0                	test   %eax,%eax
  801365:	74 0b                	je     801372 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	56                   	push   %esi
  80136b:	ff d0                	call   *%eax
  80136d:	89 c3                	mov    %eax,%ebx
  80136f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	56                   	push   %esi
  801376:	6a 00                	push   $0x0
  801378:	e8 e1 f8 ff ff       	call   800c5e <sys_page_unmap>
	return r;
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	89 d8                	mov    %ebx,%eax
}
  801382:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	ff 75 08             	pushl  0x8(%ebp)
  801396:	e8 c4 fe ff ff       	call   80125f <fd_lookup>
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 10                	js     8013b2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	6a 01                	push   $0x1
  8013a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013aa:	e8 59 ff ff ff       	call   801308 <fd_close>
  8013af:	83 c4 10             	add    $0x10,%esp
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <close_all>:

void
close_all(void)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	e8 c0 ff ff ff       	call   801389 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c9:	83 c3 01             	add    $0x1,%ebx
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	83 fb 20             	cmp    $0x20,%ebx
  8013d2:	75 ec                	jne    8013c0 <close_all+0xc>
		close(i);
}
  8013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	57                   	push   %edi
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	83 ec 2c             	sub    $0x2c,%esp
  8013e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	ff 75 08             	pushl  0x8(%ebp)
  8013ec:	e8 6e fe ff ff       	call   80125f <fd_lookup>
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	0f 88 c1 00 00 00    	js     8014bd <dup+0xe4>
		return r;
	close(newfdnum);
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	56                   	push   %esi
  801400:	e8 84 ff ff ff       	call   801389 <close>

	newfd = INDEX2FD(newfdnum);
  801405:	89 f3                	mov    %esi,%ebx
  801407:	c1 e3 0c             	shl    $0xc,%ebx
  80140a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801410:	83 c4 04             	add    $0x4,%esp
  801413:	ff 75 e4             	pushl  -0x1c(%ebp)
  801416:	e8 de fd ff ff       	call   8011f9 <fd2data>
  80141b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80141d:	89 1c 24             	mov    %ebx,(%esp)
  801420:	e8 d4 fd ff ff       	call   8011f9 <fd2data>
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142b:	89 f8                	mov    %edi,%eax
  80142d:	c1 e8 16             	shr    $0x16,%eax
  801430:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801437:	a8 01                	test   $0x1,%al
  801439:	74 37                	je     801472 <dup+0x99>
  80143b:	89 f8                	mov    %edi,%eax
  80143d:	c1 e8 0c             	shr    $0xc,%eax
  801440:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801447:	f6 c2 01             	test   $0x1,%dl
  80144a:	74 26                	je     801472 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	25 07 0e 00 00       	and    $0xe07,%eax
  80145b:	50                   	push   %eax
  80145c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145f:	6a 00                	push   $0x0
  801461:	57                   	push   %edi
  801462:	6a 00                	push   $0x0
  801464:	e8 b3 f7 ff ff       	call   800c1c <sys_page_map>
  801469:	89 c7                	mov    %eax,%edi
  80146b:	83 c4 20             	add    $0x20,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 2e                	js     8014a0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801472:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801475:	89 d0                	mov    %edx,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
  80147a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801481:	83 ec 0c             	sub    $0xc,%esp
  801484:	25 07 0e 00 00       	and    $0xe07,%eax
  801489:	50                   	push   %eax
  80148a:	53                   	push   %ebx
  80148b:	6a 00                	push   $0x0
  80148d:	52                   	push   %edx
  80148e:	6a 00                	push   $0x0
  801490:	e8 87 f7 ff ff       	call   800c1c <sys_page_map>
  801495:	89 c7                	mov    %eax,%edi
  801497:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80149a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149c:	85 ff                	test   %edi,%edi
  80149e:	79 1d                	jns    8014bd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 b3 f7 ff ff       	call   800c5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ab:	83 c4 08             	add    $0x8,%esp
  8014ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b1:	6a 00                	push   $0x0
  8014b3:	e8 a6 f7 ff ff       	call   800c5e <sys_page_unmap>
	return r;
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	89 f8                	mov    %edi,%eax
}
  8014bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5f                   	pop    %edi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 14             	sub    $0x14,%esp
  8014cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	53                   	push   %ebx
  8014d4:	e8 86 fd ff ff       	call   80125f <fd_lookup>
  8014d9:	83 c4 08             	add    $0x8,%esp
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 6d                	js     80154f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	ff 30                	pushl  (%eax)
  8014ee:	e8 c2 fd ff ff       	call   8012b5 <dev_lookup>
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 4c                	js     801546 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014fd:	8b 42 08             	mov    0x8(%edx),%eax
  801500:	83 e0 03             	and    $0x3,%eax
  801503:	83 f8 01             	cmp    $0x1,%eax
  801506:	75 21                	jne    801529 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801508:	a1 08 40 80 00       	mov    0x804008,%eax
  80150d:	8b 40 50             	mov    0x50(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	53                   	push   %ebx
  801514:	50                   	push   %eax
  801515:	68 01 27 80 00       	push   $0x802701
  80151a:	e8 32 ed ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801527:	eb 26                	jmp    80154f <read+0x8a>
	}
	if (!dev->dev_read)
  801529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152c:	8b 40 08             	mov    0x8(%eax),%eax
  80152f:	85 c0                	test   %eax,%eax
  801531:	74 17                	je     80154a <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	ff 75 10             	pushl  0x10(%ebp)
  801539:	ff 75 0c             	pushl  0xc(%ebp)
  80153c:	52                   	push   %edx
  80153d:	ff d0                	call   *%eax
  80153f:	89 c2                	mov    %eax,%edx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	eb 09                	jmp    80154f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801546:	89 c2                	mov    %eax,%edx
  801548:	eb 05                	jmp    80154f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80154a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80154f:	89 d0                	mov    %edx,%eax
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801562:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156a:	eb 21                	jmp    80158d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	89 f0                	mov    %esi,%eax
  801571:	29 d8                	sub    %ebx,%eax
  801573:	50                   	push   %eax
  801574:	89 d8                	mov    %ebx,%eax
  801576:	03 45 0c             	add    0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	57                   	push   %edi
  80157b:	e8 45 ff ff ff       	call   8014c5 <read>
		if (m < 0)
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 10                	js     801597 <readn+0x41>
			return m;
		if (m == 0)
  801587:	85 c0                	test   %eax,%eax
  801589:	74 0a                	je     801595 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158b:	01 c3                	add    %eax,%ebx
  80158d:	39 f3                	cmp    %esi,%ebx
  80158f:	72 db                	jb     80156c <readn+0x16>
  801591:	89 d8                	mov    %ebx,%eax
  801593:	eb 02                	jmp    801597 <readn+0x41>
  801595:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801597:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5f                   	pop    %edi
  80159d:	5d                   	pop    %ebp
  80159e:	c3                   	ret    

0080159f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 14             	sub    $0x14,%esp
  8015a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	53                   	push   %ebx
  8015ae:	e8 ac fc ff ff       	call   80125f <fd_lookup>
  8015b3:	83 c4 08             	add    $0x8,%esp
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 68                	js     801624 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	ff 30                	pushl  (%eax)
  8015c8:	e8 e8 fc ff ff       	call   8012b5 <dev_lookup>
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 47                	js     80161b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015db:	75 21                	jne    8015fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e2:	8b 40 50             	mov    0x50(%eax),%eax
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	53                   	push   %ebx
  8015e9:	50                   	push   %eax
  8015ea:	68 1d 27 80 00       	push   $0x80271d
  8015ef:	e8 5d ec ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fc:	eb 26                	jmp    801624 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801601:	8b 52 0c             	mov    0xc(%edx),%edx
  801604:	85 d2                	test   %edx,%edx
  801606:	74 17                	je     80161f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	ff 75 10             	pushl  0x10(%ebp)
  80160e:	ff 75 0c             	pushl  0xc(%ebp)
  801611:	50                   	push   %eax
  801612:	ff d2                	call   *%edx
  801614:	89 c2                	mov    %eax,%edx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb 09                	jmp    801624 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	eb 05                	jmp    801624 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80161f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801624:	89 d0                	mov    %edx,%eax
  801626:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <seek>:

int
seek(int fdnum, off_t offset)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801631:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	ff 75 08             	pushl  0x8(%ebp)
  801638:	e8 22 fc ff ff       	call   80125f <fd_lookup>
  80163d:	83 c4 08             	add    $0x8,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 0e                	js     801652 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801644:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801647:	8b 55 0c             	mov    0xc(%ebp),%edx
  80164a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80164d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 14             	sub    $0x14,%esp
  80165b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	53                   	push   %ebx
  801663:	e8 f7 fb ff ff       	call   80125f <fd_lookup>
  801668:	83 c4 08             	add    $0x8,%esp
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 65                	js     8016d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167b:	ff 30                	pushl  (%eax)
  80167d:	e8 33 fc ff ff       	call   8012b5 <dev_lookup>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	78 44                	js     8016cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801690:	75 21                	jne    8016b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801692:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801697:	8b 40 50             	mov    0x50(%eax),%eax
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	53                   	push   %ebx
  80169e:	50                   	push   %eax
  80169f:	68 e0 26 80 00       	push   $0x8026e0
  8016a4:	e8 a8 eb ff ff       	call   800251 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b1:	eb 23                	jmp    8016d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b6:	8b 52 18             	mov    0x18(%edx),%edx
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	74 14                	je     8016d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	ff 75 0c             	pushl  0xc(%ebp)
  8016c3:	50                   	push   %eax
  8016c4:	ff d2                	call   *%edx
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	eb 09                	jmp    8016d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	eb 05                	jmp    8016d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d6:	89 d0                	mov    %edx,%eax
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	53                   	push   %ebx
  8016e1:	83 ec 14             	sub    $0x14,%esp
  8016e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ea:	50                   	push   %eax
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 6c fb ff ff       	call   80125f <fd_lookup>
  8016f3:	83 c4 08             	add    $0x8,%esp
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 58                	js     801754 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801702:	50                   	push   %eax
  801703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801706:	ff 30                	pushl  (%eax)
  801708:	e8 a8 fb ff ff       	call   8012b5 <dev_lookup>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	78 37                	js     80174b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801717:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171b:	74 32                	je     80174f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801720:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801727:	00 00 00 
	stat->st_isdir = 0;
  80172a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801731:	00 00 00 
	stat->st_dev = dev;
  801734:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	53                   	push   %ebx
  80173e:	ff 75 f0             	pushl  -0x10(%ebp)
  801741:	ff 50 14             	call   *0x14(%eax)
  801744:	89 c2                	mov    %eax,%edx
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	eb 09                	jmp    801754 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	eb 05                	jmp    801754 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80174f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801754:	89 d0                	mov    %edx,%eax
  801756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	6a 00                	push   $0x0
  801765:	ff 75 08             	pushl  0x8(%ebp)
  801768:	e8 e3 01 00 00       	call   801950 <open>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	78 1b                	js     801791 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	ff 75 0c             	pushl  0xc(%ebp)
  80177c:	50                   	push   %eax
  80177d:	e8 5b ff ff ff       	call   8016dd <fstat>
  801782:	89 c6                	mov    %eax,%esi
	close(fd);
  801784:	89 1c 24             	mov    %ebx,(%esp)
  801787:	e8 fd fb ff ff       	call   801389 <close>
	return r;
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	89 f0                	mov    %esi,%eax
}
  801791:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801794:	5b                   	pop    %ebx
  801795:	5e                   	pop    %esi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	89 c6                	mov    %eax,%esi
  80179f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a8:	75 12                	jne    8017bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	6a 01                	push   $0x1
  8017af:	e8 f5 f9 ff ff       	call   8011a9 <ipc_find_env>
  8017b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017bc:	6a 07                	push   $0x7
  8017be:	68 00 50 80 00       	push   $0x805000
  8017c3:	56                   	push   %esi
  8017c4:	ff 35 00 40 80 00    	pushl  0x804000
  8017ca:	e8 78 f9 ff ff       	call   801147 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017cf:	83 c4 0c             	add    $0xc,%esp
  8017d2:	6a 00                	push   $0x0
  8017d4:	53                   	push   %ebx
  8017d5:	6a 00                	push   $0x0
  8017d7:	e8 f6 f8 ff ff       	call   8010d2 <ipc_recv>
}
  8017dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801801:	b8 02 00 00 00       	mov    $0x2,%eax
  801806:	e8 8d ff ff ff       	call   801798 <fsipc>
}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 40 0c             	mov    0xc(%eax),%eax
  801819:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	b8 06 00 00 00       	mov    $0x6,%eax
  801828:	e8 6b ff ff ff       	call   801798 <fsipc>
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	83 ec 04             	sub    $0x4,%esp
  801836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	8b 40 0c             	mov    0xc(%eax),%eax
  80183f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	b8 05 00 00 00       	mov    $0x5,%eax
  80184e:	e8 45 ff ff ff       	call   801798 <fsipc>
  801853:	85 c0                	test   %eax,%eax
  801855:	78 2c                	js     801883 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	68 00 50 80 00       	push   $0x805000
  80185f:	53                   	push   %ebx
  801860:	e8 71 ef ff ff       	call   8007d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801865:	a1 80 50 80 00       	mov    0x805080,%eax
  80186a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801870:	a1 84 50 80 00       	mov    0x805084,%eax
  801875:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801891:	8b 55 08             	mov    0x8(%ebp),%edx
  801894:	8b 52 0c             	mov    0xc(%edx),%edx
  801897:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80189d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018a2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a7:	0f 47 c2             	cmova  %edx,%eax
  8018aa:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018af:	50                   	push   %eax
  8018b0:	ff 75 0c             	pushl  0xc(%ebp)
  8018b3:	68 08 50 80 00       	push   $0x805008
  8018b8:	e8 ab f0 ff ff       	call   800968 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c7:	e8 cc fe ff ff       	call   801798 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f1:	e8 a2 fe ff ff       	call   801798 <fsipc>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 4b                	js     801947 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018fc:	39 c6                	cmp    %eax,%esi
  8018fe:	73 16                	jae    801916 <devfile_read+0x48>
  801900:	68 4c 27 80 00       	push   $0x80274c
  801905:	68 53 27 80 00       	push   $0x802753
  80190a:	6a 7c                	push   $0x7c
  80190c:	68 68 27 80 00       	push   $0x802768
  801911:	e8 bd 05 00 00       	call   801ed3 <_panic>
	assert(r <= PGSIZE);
  801916:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80191b:	7e 16                	jle    801933 <devfile_read+0x65>
  80191d:	68 73 27 80 00       	push   $0x802773
  801922:	68 53 27 80 00       	push   $0x802753
  801927:	6a 7d                	push   $0x7d
  801929:	68 68 27 80 00       	push   $0x802768
  80192e:	e8 a0 05 00 00       	call   801ed3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801933:	83 ec 04             	sub    $0x4,%esp
  801936:	50                   	push   %eax
  801937:	68 00 50 80 00       	push   $0x805000
  80193c:	ff 75 0c             	pushl  0xc(%ebp)
  80193f:	e8 24 f0 ff ff       	call   800968 <memmove>
	return r;
  801944:	83 c4 10             	add    $0x10,%esp
}
  801947:	89 d8                	mov    %ebx,%eax
  801949:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	83 ec 20             	sub    $0x20,%esp
  801957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80195a:	53                   	push   %ebx
  80195b:	e8 3d ee ff ff       	call   80079d <strlen>
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801968:	7f 67                	jg     8019d1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801970:	50                   	push   %eax
  801971:	e8 9a f8 ff ff       	call   801210 <fd_alloc>
  801976:	83 c4 10             	add    $0x10,%esp
		return r;
  801979:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 57                	js     8019d6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	53                   	push   %ebx
  801983:	68 00 50 80 00       	push   $0x805000
  801988:	e8 49 ee ff ff       	call   8007d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80198d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801990:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801995:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801998:	b8 01 00 00 00       	mov    $0x1,%eax
  80199d:	e8 f6 fd ff ff       	call   801798 <fsipc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	79 14                	jns    8019bf <open+0x6f>
		fd_close(fd, 0);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	6a 00                	push   $0x0
  8019b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b3:	e8 50 f9 ff ff       	call   801308 <fd_close>
		return r;
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	89 da                	mov    %ebx,%edx
  8019bd:	eb 17                	jmp    8019d6 <open+0x86>
	}

	return fd2num(fd);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c5:	e8 1f f8 ff ff       	call   8011e9 <fd2num>
  8019ca:	89 c2                	mov    %eax,%edx
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	eb 05                	jmp    8019d6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019d6:	89 d0                	mov    %edx,%eax
  8019d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ed:	e8 a6 fd ff ff       	call   801798 <fsipc>
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	ff 75 08             	pushl  0x8(%ebp)
  801a02:	e8 f2 f7 ff ff       	call   8011f9 <fd2data>
  801a07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a09:	83 c4 08             	add    $0x8,%esp
  801a0c:	68 7f 27 80 00       	push   $0x80277f
  801a11:	53                   	push   %ebx
  801a12:	e8 bf ed ff ff       	call   8007d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a17:	8b 46 04             	mov    0x4(%esi),%eax
  801a1a:	2b 06                	sub    (%esi),%eax
  801a1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a29:	00 00 00 
	stat->st_dev = &devpipe;
  801a2c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a33:	30 80 00 
	return 0;
}
  801a36:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3e:	5b                   	pop    %ebx
  801a3f:	5e                   	pop    %esi
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	53                   	push   %ebx
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a4c:	53                   	push   %ebx
  801a4d:	6a 00                	push   $0x0
  801a4f:	e8 0a f2 ff ff       	call   800c5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a54:	89 1c 24             	mov    %ebx,(%esp)
  801a57:	e8 9d f7 ff ff       	call   8011f9 <fd2data>
  801a5c:	83 c4 08             	add    $0x8,%esp
  801a5f:	50                   	push   %eax
  801a60:	6a 00                	push   $0x0
  801a62:	e8 f7 f1 ff ff       	call   800c5e <sys_page_unmap>
}
  801a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 1c             	sub    $0x1c,%esp
  801a75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801a7f:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	ff 75 e0             	pushl  -0x20(%ebp)
  801a88:	e8 1b 05 00 00       	call   801fa8 <pageref>
  801a8d:	89 c3                	mov    %eax,%ebx
  801a8f:	89 3c 24             	mov    %edi,(%esp)
  801a92:	e8 11 05 00 00       	call   801fa8 <pageref>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	39 c3                	cmp    %eax,%ebx
  801a9c:	0f 94 c1             	sete   %cl
  801a9f:	0f b6 c9             	movzbl %cl,%ecx
  801aa2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aa5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801aab:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801aae:	39 ce                	cmp    %ecx,%esi
  801ab0:	74 1b                	je     801acd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab2:	39 c3                	cmp    %eax,%ebx
  801ab4:	75 c4                	jne    801a7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ab6:	8b 42 60             	mov    0x60(%edx),%eax
  801ab9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abc:	50                   	push   %eax
  801abd:	56                   	push   %esi
  801abe:	68 86 27 80 00       	push   $0x802786
  801ac3:	e8 89 e7 ff ff       	call   800251 <cprintf>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	eb ad                	jmp    801a7a <_pipeisclosed+0xe>
	}
}
  801acd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5f                   	pop    %edi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 28             	sub    $0x28,%esp
  801ae1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ae4:	56                   	push   %esi
  801ae5:	e8 0f f7 ff ff       	call   8011f9 <fd2data>
  801aea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	bf 00 00 00 00       	mov    $0x0,%edi
  801af4:	eb 4b                	jmp    801b41 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801af6:	89 da                	mov    %ebx,%edx
  801af8:	89 f0                	mov    %esi,%eax
  801afa:	e8 6d ff ff ff       	call   801a6c <_pipeisclosed>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	75 48                	jne    801b4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b03:	e8 b2 f0 ff ff       	call   800bba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b08:	8b 43 04             	mov    0x4(%ebx),%eax
  801b0b:	8b 0b                	mov    (%ebx),%ecx
  801b0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b10:	39 d0                	cmp    %edx,%eax
  801b12:	73 e2                	jae    801af6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b17:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b1b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b1e:	89 c2                	mov    %eax,%edx
  801b20:	c1 fa 1f             	sar    $0x1f,%edx
  801b23:	89 d1                	mov    %edx,%ecx
  801b25:	c1 e9 1b             	shr    $0x1b,%ecx
  801b28:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b2b:	83 e2 1f             	and    $0x1f,%edx
  801b2e:	29 ca                	sub    %ecx,%edx
  801b30:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b38:	83 c0 01             	add    $0x1,%eax
  801b3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3e:	83 c7 01             	add    $0x1,%edi
  801b41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b44:	75 c2                	jne    801b08 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b46:	8b 45 10             	mov    0x10(%ebp),%eax
  801b49:	eb 05                	jmp    801b50 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	57                   	push   %edi
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
  801b5e:	83 ec 18             	sub    $0x18,%esp
  801b61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b64:	57                   	push   %edi
  801b65:	e8 8f f6 ff ff       	call   8011f9 <fd2data>
  801b6a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b74:	eb 3d                	jmp    801bb3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b76:	85 db                	test   %ebx,%ebx
  801b78:	74 04                	je     801b7e <devpipe_read+0x26>
				return i;
  801b7a:	89 d8                	mov    %ebx,%eax
  801b7c:	eb 44                	jmp    801bc2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b7e:	89 f2                	mov    %esi,%edx
  801b80:	89 f8                	mov    %edi,%eax
  801b82:	e8 e5 fe ff ff       	call   801a6c <_pipeisclosed>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	75 32                	jne    801bbd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b8b:	e8 2a f0 ff ff       	call   800bba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b90:	8b 06                	mov    (%esi),%eax
  801b92:	3b 46 04             	cmp    0x4(%esi),%eax
  801b95:	74 df                	je     801b76 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b97:	99                   	cltd   
  801b98:	c1 ea 1b             	shr    $0x1b,%edx
  801b9b:	01 d0                	add    %edx,%eax
  801b9d:	83 e0 1f             	and    $0x1f,%eax
  801ba0:	29 d0                	sub    %edx,%eax
  801ba2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801baa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb0:	83 c3 01             	add    $0x1,%ebx
  801bb3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bb6:	75 d8                	jne    801b90 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbb:	eb 05                	jmp    801bc2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5f                   	pop    %edi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 35 f6 ff ff       	call   801210 <fd_alloc>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	89 c2                	mov    %eax,%edx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 2c 01 00 00    	js     801d14 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 df ef ff ff       	call   800bd9 <sys_page_alloc>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	89 c2                	mov    %eax,%edx
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 0d 01 00 00    	js     801d14 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0d:	50                   	push   %eax
  801c0e:	e8 fd f5 ff ff       	call   801210 <fd_alloc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	0f 88 e2 00 00 00    	js     801d02 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c20:	83 ec 04             	sub    $0x4,%esp
  801c23:	68 07 04 00 00       	push   $0x407
  801c28:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 a7 ef ff ff       	call   800bd9 <sys_page_alloc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 c3 00 00 00    	js     801d02 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f4             	pushl  -0xc(%ebp)
  801c45:	e8 af f5 ff ff       	call   8011f9 <fd2data>
  801c4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4c:	83 c4 0c             	add    $0xc,%esp
  801c4f:	68 07 04 00 00       	push   $0x407
  801c54:	50                   	push   %eax
  801c55:	6a 00                	push   $0x0
  801c57:	e8 7d ef ff ff       	call   800bd9 <sys_page_alloc>
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	0f 88 89 00 00 00    	js     801cf2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6f:	e8 85 f5 ff ff       	call   8011f9 <fd2data>
  801c74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c7b:	50                   	push   %eax
  801c7c:	6a 00                	push   $0x0
  801c7e:	56                   	push   %esi
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 96 ef ff ff       	call   800c1c <sys_page_map>
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	83 c4 20             	add    $0x20,%esp
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 55                	js     801ce4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c8f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ca4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbf:	e8 25 f5 ff ff       	call   8011e9 <fd2num>
  801cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cc9:	83 c4 04             	add    $0x4,%esp
  801ccc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccf:	e8 15 f5 ff ff       	call   8011e9 <fd2num>
  801cd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce2:	eb 30                	jmp    801d14 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	56                   	push   %esi
  801ce8:	6a 00                	push   $0x0
  801cea:	e8 6f ef ff ff       	call   800c5e <sys_page_unmap>
  801cef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 5f ef ff ff       	call   800c5e <sys_page_unmap>
  801cff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 4f ef ff ff       	call   800c5e <sys_page_unmap>
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d14:	89 d0                	mov    %edx,%eax
  801d16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d26:	50                   	push   %eax
  801d27:	ff 75 08             	pushl  0x8(%ebp)
  801d2a:	e8 30 f5 ff ff       	call   80125f <fd_lookup>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	78 18                	js     801d4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3c:	e8 b8 f4 ff ff       	call   8011f9 <fd2data>
	return _pipeisclosed(fd, p);
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d46:	e8 21 fd ff ff       	call   801a6c <_pipeisclosed>
  801d4b:	83 c4 10             	add    $0x10,%esp
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d60:	68 9e 27 80 00       	push   $0x80279e
  801d65:	ff 75 0c             	pushl  0xc(%ebp)
  801d68:	e8 69 ea ff ff       	call   8007d6 <strcpy>
	return 0;
}
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	57                   	push   %edi
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
  801d7a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d80:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d85:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8b:	eb 2d                	jmp    801dba <devcons_write+0x46>
		m = n - tot;
  801d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d90:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d92:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d95:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d9a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9d:	83 ec 04             	sub    $0x4,%esp
  801da0:	53                   	push   %ebx
  801da1:	03 45 0c             	add    0xc(%ebp),%eax
  801da4:	50                   	push   %eax
  801da5:	57                   	push   %edi
  801da6:	e8 bd eb ff ff       	call   800968 <memmove>
		sys_cputs(buf, m);
  801dab:	83 c4 08             	add    $0x8,%esp
  801dae:	53                   	push   %ebx
  801daf:	57                   	push   %edi
  801db0:	e8 68 ed ff ff       	call   800b1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db5:	01 de                	add    %ebx,%esi
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	89 f0                	mov    %esi,%eax
  801dbc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbf:	72 cc                	jb     801d8d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 08             	sub    $0x8,%esp
  801dcf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd8:	74 2a                	je     801e04 <devcons_read+0x3b>
  801dda:	eb 05                	jmp    801de1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ddc:	e8 d9 ed ff ff       	call   800bba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de1:	e8 55 ed ff ff       	call   800b3b <sys_cgetc>
  801de6:	85 c0                	test   %eax,%eax
  801de8:	74 f2                	je     801ddc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 16                	js     801e04 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dee:	83 f8 04             	cmp    $0x4,%eax
  801df1:	74 0c                	je     801dff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df6:	88 02                	mov    %al,(%edx)
	return 1;
  801df8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfd:	eb 05                	jmp    801e04 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e12:	6a 01                	push   $0x1
  801e14:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e17:	50                   	push   %eax
  801e18:	e8 00 ed ff ff       	call   800b1d <sys_cputs>
}
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <getchar>:

int
getchar(void)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e28:	6a 01                	push   $0x1
  801e2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2d:	50                   	push   %eax
  801e2e:	6a 00                	push   $0x0
  801e30:	e8 90 f6 ff ff       	call   8014c5 <read>
	if (r < 0)
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 0f                	js     801e4b <getchar+0x29>
		return r;
	if (r < 1)
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	7e 06                	jle    801e46 <getchar+0x24>
		return -E_EOF;
	return c;
  801e40:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e44:	eb 05                	jmp    801e4b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e46:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	ff 75 08             	pushl  0x8(%ebp)
  801e5a:	e8 00 f4 ff ff       	call   80125f <fd_lookup>
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 11                	js     801e77 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6f:	39 10                	cmp    %edx,(%eax)
  801e71:	0f 94 c0             	sete   %al
  801e74:	0f b6 c0             	movzbl %al,%eax
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <opencons>:

int
opencons(void)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	e8 88 f3 ff ff       	call   801210 <fd_alloc>
  801e88:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 3e                	js     801ecf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e91:	83 ec 04             	sub    $0x4,%esp
  801e94:	68 07 04 00 00       	push   $0x407
  801e99:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9c:	6a 00                	push   $0x0
  801e9e:	e8 36 ed ff ff       	call   800bd9 <sys_page_alloc>
  801ea3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	78 23                	js     801ecf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	50                   	push   %eax
  801ec5:	e8 1f f3 ff ff       	call   8011e9 <fd2num>
  801eca:	89 c2                	mov    %eax,%edx
  801ecc:	83 c4 10             	add    $0x10,%esp
}
  801ecf:	89 d0                	mov    %edx,%eax
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ed8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801edb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ee1:	e8 b5 ec ff ff       	call   800b9b <sys_getenvid>
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	ff 75 08             	pushl  0x8(%ebp)
  801eef:	56                   	push   %esi
  801ef0:	50                   	push   %eax
  801ef1:	68 ac 27 80 00       	push   $0x8027ac
  801ef6:	e8 56 e3 ff ff       	call   800251 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801efb:	83 c4 18             	add    $0x18,%esp
  801efe:	53                   	push   %ebx
  801eff:	ff 75 10             	pushl  0x10(%ebp)
  801f02:	e8 f9 e2 ff ff       	call   800200 <vcprintf>
	cprintf("\n");
  801f07:	c7 04 24 97 27 80 00 	movl   $0x802797,(%esp)
  801f0e:	e8 3e e3 ff ff       	call   800251 <cprintf>
  801f13:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f16:	cc                   	int3   
  801f17:	eb fd                	jmp    801f16 <_panic+0x43>

00801f19 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f1f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f26:	75 2a                	jne    801f52 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f28:	83 ec 04             	sub    $0x4,%esp
  801f2b:	6a 07                	push   $0x7
  801f2d:	68 00 f0 bf ee       	push   $0xeebff000
  801f32:	6a 00                	push   $0x0
  801f34:	e8 a0 ec ff ff       	call   800bd9 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	79 12                	jns    801f52 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f40:	50                   	push   %eax
  801f41:	68 d0 27 80 00       	push   $0x8027d0
  801f46:	6a 23                	push   $0x23
  801f48:	68 d4 27 80 00       	push   $0x8027d4
  801f4d:	e8 81 ff ff ff       	call   801ed3 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f52:	8b 45 08             	mov    0x8(%ebp),%eax
  801f55:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f5a:	83 ec 08             	sub    $0x8,%esp
  801f5d:	68 84 1f 80 00       	push   $0x801f84
  801f62:	6a 00                	push   $0x0
  801f64:	e8 bb ed ff ff       	call   800d24 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	79 12                	jns    801f82 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f70:	50                   	push   %eax
  801f71:	68 d0 27 80 00       	push   $0x8027d0
  801f76:	6a 2c                	push   $0x2c
  801f78:	68 d4 27 80 00       	push   $0x8027d4
  801f7d:	e8 51 ff ff ff       	call   801ed3 <_panic>
	}
}
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f84:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f85:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f8f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f93:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f98:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f9c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f9e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fa1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fa2:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fa5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fa6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fa7:	c3                   	ret    

00801fa8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fae:	89 d0                	mov    %edx,%eax
  801fb0:	c1 e8 16             	shr    $0x16,%eax
  801fb3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fba:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fbf:	f6 c1 01             	test   $0x1,%cl
  801fc2:	74 1d                	je     801fe1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc4:	c1 ea 0c             	shr    $0xc,%edx
  801fc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fce:	f6 c2 01             	test   $0x1,%dl
  801fd1:	74 0e                	je     801fe1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd3:	c1 ea 0c             	shr    $0xc,%edx
  801fd6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fdd:	ef 
  801fde:	0f b7 c0             	movzwl %ax,%eax
}
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    
  801fe3:	66 90                	xchg   %ax,%ax
  801fe5:	66 90                	xchg   %ax,%ax
  801fe7:	66 90                	xchg   %ax,%ax
  801fe9:	66 90                	xchg   %ax,%ax
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
