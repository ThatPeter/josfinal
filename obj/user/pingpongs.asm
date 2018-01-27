
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
  80003c:	e8 35 10 00 00       	call   801076 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 0b 0b 00 00       	call   800b5e <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 22 80 00       	push   $0x802280
  80005d:	e8 b2 01 00 00       	call   800214 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f4 0a 00 00       	call   800b5e <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 22 80 00       	push   $0x80229a
  800074:	e8 9b 01 00 00       	call   800214 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 b5 10 00 00       	call   80113c <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 27 10 00 00       	call   8010c1 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 7c             	mov    0x7c(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 ab 0a 00 00       	call   800b5e <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 22 80 00       	push   $0x8022b0
  8000c2:	e8 4d 01 00 00       	call   800214 <cprintf>
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
  8000e5:	e8 52 10 00 00       	call   80113c <ipc_send>
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
  800109:	e8 50 0a 00 00       	call   800b5e <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 db                	test   %ebx,%ebx
  800125:	7e 07                	jle    80012e <libmain+0x30>
		binaryname = argv[0];
  800127:	8b 06                	mov    (%esi),%eax
  800129:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
  800133:	e8 fb fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800138:	e8 2a 00 00 00       	call   800167 <exit>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80014d:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  800152:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800154:	e8 05 0a 00 00       	call   800b5e <sys_getenvid>
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	50                   	push   %eax
  80015d:	e8 4b 0c 00 00       	call   800dad <sys_thread_free>
}
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80016d:	e8 39 12 00 00       	call   8013ab <close_all>
	sys_env_destroy(0);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	6a 00                	push   $0x0
  800177:	e8 a1 09 00 00       	call   800b1d <sys_env_destroy>
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	53                   	push   %ebx
  800185:	83 ec 04             	sub    $0x4,%esp
  800188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018b:	8b 13                	mov    (%ebx),%edx
  80018d:	8d 42 01             	lea    0x1(%edx),%eax
  800190:	89 03                	mov    %eax,(%ebx)
  800192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800195:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800199:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019e:	75 1a                	jne    8001ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	68 ff 00 00 00       	push   $0xff
  8001a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 2f 09 00 00       	call   800ae0 <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d3:	00 00 00 
	b.cnt = 0;
  8001d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e0:	ff 75 0c             	pushl  0xc(%ebp)
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	68 81 01 80 00       	push   $0x800181
  8001f2:	e8 54 01 00 00       	call   80034b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	83 c4 08             	add    $0x8,%esp
  8001fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800200:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	e8 d4 08 00 00       	call   800ae0 <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 9d ff ff ff       	call   8001c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 c7                	mov    %eax,%edi
  800233:	89 d6                	mov    %edx,%esi
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800241:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024f:	39 d3                	cmp    %edx,%ebx
  800251:	72 05                	jb     800258 <printnum+0x30>
  800253:	39 45 10             	cmp    %eax,0x10(%ebp)
  800256:	77 45                	ja     80029d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	8b 45 14             	mov    0x14(%ebp),%eax
  800261:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800264:	53                   	push   %ebx
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026e:	ff 75 e0             	pushl  -0x20(%ebp)
  800271:	ff 75 dc             	pushl  -0x24(%ebp)
  800274:	ff 75 d8             	pushl  -0x28(%ebp)
  800277:	e8 74 1d 00 00       	call   801ff0 <__udivdi3>
  80027c:	83 c4 18             	add    $0x18,%esp
  80027f:	52                   	push   %edx
  800280:	50                   	push   %eax
  800281:	89 f2                	mov    %esi,%edx
  800283:	89 f8                	mov    %edi,%eax
  800285:	e8 9e ff ff ff       	call   800228 <printnum>
  80028a:	83 c4 20             	add    $0x20,%esp
  80028d:	eb 18                	jmp    8002a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	ff 75 18             	pushl  0x18(%ebp)
  800296:	ff d7                	call   *%edi
  800298:	83 c4 10             	add    $0x10,%esp
  80029b:	eb 03                	jmp    8002a0 <printnum+0x78>
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f e8                	jg     80028f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 61 1e 00 00       	call   802120 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 e0 22 80 00 	movsbl 0x8022e0(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002da:	83 fa 01             	cmp    $0x1,%edx
  8002dd:	7e 0e                	jle    8002ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	8b 52 04             	mov    0x4(%edx),%edx
  8002eb:	eb 22                	jmp    80030f <getuint+0x38>
	else if (lflag)
  8002ed:	85 d2                	test   %edx,%edx
  8002ef:	74 10                	je     800301 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	eb 0e                	jmp    80030f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800317:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	3b 50 04             	cmp    0x4(%eax),%edx
  800320:	73 0a                	jae    80032c <sprintputch+0x1b>
		*b->buf++ = ch;
  800322:	8d 4a 01             	lea    0x1(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	88 02                	mov    %al,(%edx)
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800337:	50                   	push   %eax
  800338:	ff 75 10             	pushl  0x10(%ebp)
  80033b:	ff 75 0c             	pushl  0xc(%ebp)
  80033e:	ff 75 08             	pushl  0x8(%ebp)
  800341:	e8 05 00 00 00       	call   80034b <vprintfmt>
	va_end(ap);
}
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	83 ec 2c             	sub    $0x2c,%esp
  800354:	8b 75 08             	mov    0x8(%ebp),%esi
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035d:	eb 12                	jmp    800371 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 84 89 03 00 00    	je     8006f0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	50                   	push   %eax
  80036c:	ff d6                	call   *%esi
  80036e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	83 c7 01             	add    $0x1,%edi
  800374:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800378:	83 f8 25             	cmp    $0x25,%eax
  80037b:	75 e2                	jne    80035f <vprintfmt+0x14>
  80037d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800381:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800388:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 07                	jmp    8003a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8d 47 01             	lea    0x1(%edi),%eax
  8003a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003aa:	0f b6 07             	movzbl (%edi),%eax
  8003ad:	0f b6 c8             	movzbl %al,%ecx
  8003b0:	83 e8 23             	sub    $0x23,%eax
  8003b3:	3c 55                	cmp    $0x55,%al
  8003b5:	0f 87 1a 03 00 00    	ja     8006d5 <vprintfmt+0x38a>
  8003bb:	0f b6 c0             	movzbl %al,%eax
  8003be:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cc:	eb d6                	jmp    8003a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e6:	83 fa 09             	cmp    $0x9,%edx
  8003e9:	77 39                	ja     800424 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ee:	eb e9                	jmp    8003d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800401:	eb 27                	jmp    80042a <vprintfmt+0xdf>
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040d:	0f 49 c8             	cmovns %eax,%ecx
  800410:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800416:	eb 8c                	jmp    8003a4 <vprintfmt+0x59>
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800422:	eb 80                	jmp    8003a4 <vprintfmt+0x59>
  800424:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800427:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	0f 89 70 ff ff ff    	jns    8003a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800434:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800441:	e9 5e ff ff ff       	jmp    8003a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800446:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044c:	e9 53 ff ff ff       	jmp    8003a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 30                	pushl  (%eax)
  800460:	ff d6                	call   *%esi
			break;
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800468:	e9 04 ff ff ff       	jmp    800371 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	99                   	cltd   
  800479:	31 d0                	xor    %edx,%eax
  80047b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 0f             	cmp    $0xf,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x142>
  800482:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800489:	85 d2                	test   %edx,%edx
  80048b:	75 18                	jne    8004a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048d:	50                   	push   %eax
  80048e:	68 f8 22 80 00       	push   $0x8022f8
  800493:	53                   	push   %ebx
  800494:	56                   	push   %esi
  800495:	e8 94 fe ff ff       	call   80032e <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a0:	e9 cc fe ff ff       	jmp    800371 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a5:	52                   	push   %edx
  8004a6:	68 45 27 80 00       	push   $0x802745
  8004ab:	53                   	push   %ebx
  8004ac:	56                   	push   %esi
  8004ad:	e8 7c fe ff ff       	call   80032e <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b8:	e9 b4 fe ff ff       	jmp    800371 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 f1 22 80 00       	mov    $0x8022f1,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d6:	0f 8e 94 00 00 00    	jle    800570 <vprintfmt+0x225>
  8004dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e0:	0f 84 98 00 00 00    	je     80057e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ec:	57                   	push   %edi
  8004ed:	e8 86 02 00 00       	call   800778 <strnlen>
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 c1                	sub    %eax,%ecx
  8004f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800507:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	eb 0f                	jmp    80051a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	ff 75 e0             	pushl  -0x20(%ebp)
  800512:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f ed                	jg     80050b <vprintfmt+0x1c0>
  80051e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800521:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800524:	85 c9                	test   %ecx,%ecx
  800526:	b8 00 00 00 00       	mov    $0x0,%eax
  80052b:	0f 49 c1             	cmovns %ecx,%eax
  80052e:	29 c1                	sub    %eax,%ecx
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	eb 4d                	jmp    80058a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	74 1b                	je     80055e <vprintfmt+0x213>
  800543:	0f be c0             	movsbl %al,%eax
  800546:	83 e8 20             	sub    $0x20,%eax
  800549:	83 f8 5e             	cmp    $0x5e,%eax
  80054c:	76 10                	jbe    80055e <vprintfmt+0x213>
					putch('?', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	6a 3f                	push   $0x3f
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 0d                	jmp    80056b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	52                   	push   %edx
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056b:	83 eb 01             	sub    $0x1,%ebx
  80056e:	eb 1a                	jmp    80058a <vprintfmt+0x23f>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	eb 0c                	jmp    80058a <vprintfmt+0x23f>
  80057e:	89 75 08             	mov    %esi,0x8(%ebp)
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800584:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800591:	0f be d0             	movsbl %al,%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	74 23                	je     8005bb <vprintfmt+0x270>
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 a1                	js     80053d <vprintfmt+0x1f2>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 9c                	jns    80053d <vprintfmt+0x1f2>
  8005a1:	89 df                	mov    %ebx,%edi
  8005a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a9:	eb 18                	jmp    8005c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 20                	push   $0x20
  8005b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	eb 08                	jmp    8005c3 <vprintfmt+0x278>
  8005bb:	89 df                	mov    %ebx,%edi
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	7f e4                	jg     8005ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	e9 a2 fd ff ff       	jmp    800371 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cf:	83 fa 01             	cmp    $0x1,%edx
  8005d2:	7e 16                	jle    8005ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 08             	lea    0x8(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 50 04             	mov    0x4(%eax),%edx
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e8:	eb 32                	jmp    80061c <vprintfmt+0x2d1>
	else if (lflag)
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	74 18                	je     800606 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800604:	eb 16                	jmp    80061c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 c1                	mov    %eax,%ecx
  800616:	c1 f9 1f             	sar    $0x1f,%ecx
  800619:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800627:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062b:	79 74                	jns    8006a1 <vprintfmt+0x356>
				putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 2d                	push   $0x2d
  800633:	ff d6                	call   *%esi
				num = -(long long) num;
  800635:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800638:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063b:	f7 d8                	neg    %eax
  80063d:	83 d2 00             	adc    $0x0,%edx
  800640:	f7 da                	neg    %edx
  800642:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064a:	eb 55                	jmp    8006a1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 83 fc ff ff       	call   8002d7 <getuint>
			base = 10;
  800654:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800659:	eb 46                	jmp    8006a1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 74 fc ff ff       	call   8002d7 <getuint>
			base = 8;
  800663:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800668:	eb 37                	jmp    8006a1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 30                	push   $0x30
  800670:	ff d6                	call   *%esi
			putch('x', putdat);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 78                	push   $0x78
  800678:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800692:	eb 0d                	jmp    8006a1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	e8 3b fc ff ff       	call   8002d7 <getuint>
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a8:	57                   	push   %edi
  8006a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	50                   	push   %eax
  8006af:	89 da                	mov    %ebx,%edx
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	e8 70 fb ff ff       	call   800228 <printnum>
			break;
  8006b8:	83 c4 20             	add    $0x20,%esp
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006be:	e9 ae fc ff ff       	jmp    800371 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	51                   	push   %ecx
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d0:	e9 9c fc ff ff       	jmp    800371 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 25                	push   $0x25
  8006db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 03                	jmp    8006e5 <vprintfmt+0x39a>
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e9:	75 f7                	jne    8006e2 <vprintfmt+0x397>
  8006eb:	e9 81 fc ff ff       	jmp    800371 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 18             	sub    $0x18,%esp
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800704:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800707:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800715:	85 c0                	test   %eax,%eax
  800717:	74 26                	je     80073f <vsnprintf+0x47>
  800719:	85 d2                	test   %edx,%edx
  80071b:	7e 22                	jle    80073f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071d:	ff 75 14             	pushl  0x14(%ebp)
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800726:	50                   	push   %eax
  800727:	68 11 03 80 00       	push   $0x800311
  80072c:	e8 1a fc ff ff       	call   80034b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800731:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800734:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 05                	jmp    800744 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074f:	50                   	push   %eax
  800750:	ff 75 10             	pushl  0x10(%ebp)
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	ff 75 08             	pushl  0x8(%ebp)
  800759:	e8 9a ff ff ff       	call   8006f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	eb 03                	jmp    80078b <strnlen+0x13>
		n++;
  800788:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 c2                	cmp    %eax,%edx
  80078d:	74 08                	je     800797 <strnlen+0x1f>
  80078f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800793:	75 f3                	jne    800788 <strnlen+0x10>
  800795:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a3:	89 c2                	mov    %eax,%edx
  8007a5:	83 c2 01             	add    $0x1,%edx
  8007a8:	83 c1 01             	add    $0x1,%ecx
  8007ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b2:	84 db                	test   %bl,%bl
  8007b4:	75 ef                	jne    8007a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c0:	53                   	push   %ebx
  8007c1:	e8 9a ff ff ff       	call   800760 <strlen>
  8007c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	01 d8                	add    %ebx,%eax
  8007ce:	50                   	push   %eax
  8007cf:	e8 c5 ff ff ff       	call   800799 <strcpy>
	return dst;
}
  8007d4:	89 d8                	mov    %ebx,%eax
  8007d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e6:	89 f3                	mov    %esi,%ebx
  8007e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	89 f2                	mov    %esi,%edx
  8007ed:	eb 0f                	jmp    8007fe <strncpy+0x23>
		*dst++ = *src;
  8007ef:	83 c2 01             	add    $0x1,%edx
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	39 da                	cmp    %ebx,%edx
  800800:	75 ed                	jne    8007ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800802:	89 f0                	mov    %esi,%eax
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	8b 55 10             	mov    0x10(%ebp),%edx
  800816:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 21                	je     80083d <strlcpy+0x35>
  80081c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800820:	89 f2                	mov    %esi,%edx
  800822:	eb 09                	jmp    80082d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800824:	83 c2 01             	add    $0x1,%edx
  800827:	83 c1 01             	add    $0x1,%ecx
  80082a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 09                	je     80083a <strlcpy+0x32>
  800831:	0f b6 19             	movzbl (%ecx),%ebx
  800834:	84 db                	test   %bl,%bl
  800836:	75 ec                	jne    800824 <strlcpy+0x1c>
  800838:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083d:	29 f0                	sub    %esi,%eax
}
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084c:	eb 06                	jmp    800854 <strcmp+0x11>
		p++, q++;
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	84 c0                	test   %al,%al
  800859:	74 04                	je     80085f <strcmp+0x1c>
  80085b:	3a 02                	cmp    (%edx),%al
  80085d:	74 ef                	je     80084e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085f:	0f b6 c0             	movzbl %al,%eax
  800862:	0f b6 12             	movzbl (%edx),%edx
  800865:	29 d0                	sub    %edx,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 c3                	mov    %eax,%ebx
  800875:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800878:	eb 06                	jmp    800880 <strncmp+0x17>
		n--, p++, q++;
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800880:	39 d8                	cmp    %ebx,%eax
  800882:	74 15                	je     800899 <strncmp+0x30>
  800884:	0f b6 08             	movzbl (%eax),%ecx
  800887:	84 c9                	test   %cl,%cl
  800889:	74 04                	je     80088f <strncmp+0x26>
  80088b:	3a 0a                	cmp    (%edx),%cl
  80088d:	74 eb                	je     80087a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	eb 07                	jmp    8008b4 <strchr+0x13>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 0f                	je     8008c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	0f b6 10             	movzbl (%eax),%edx
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f2                	jne    8008ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	eb 03                	jmp    8008d1 <strfind+0xf>
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 04                	je     8008dc <strfind+0x1a>
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f2                	jne    8008ce <strfind+0xc>
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 36                	je     800924 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f4:	75 28                	jne    80091e <memset+0x40>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 23                	jne    80091e <memset+0x40>
		c &= 0xFF;
  8008fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ff:	89 d3                	mov    %edx,%ebx
  800901:	c1 e3 08             	shl    $0x8,%ebx
  800904:	89 d6                	mov    %edx,%esi
  800906:	c1 e6 18             	shl    $0x18,%esi
  800909:	89 d0                	mov    %edx,%eax
  80090b:	c1 e0 10             	shl    $0x10,%eax
  80090e:	09 f0                	or     %esi,%eax
  800910:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800912:	89 d8                	mov    %ebx,%eax
  800914:	09 d0                	or     %edx,%eax
  800916:	c1 e9 02             	shr    $0x2,%ecx
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 06                	jmp    800924 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	fc                   	cld    
  800922:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800924:	89 f8                	mov    %edi,%eax
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 75 0c             	mov    0xc(%ebp),%esi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800939:	39 c6                	cmp    %eax,%esi
  80093b:	73 35                	jae    800972 <memmove+0x47>
  80093d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800940:	39 d0                	cmp    %edx,%eax
  800942:	73 2e                	jae    800972 <memmove+0x47>
		s += n;
		d += n;
  800944:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800947:	89 d6                	mov    %edx,%esi
  800949:	09 fe                	or     %edi,%esi
  80094b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800951:	75 13                	jne    800966 <memmove+0x3b>
  800953:	f6 c1 03             	test   $0x3,%cl
  800956:	75 0e                	jne    800966 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800958:	83 ef 04             	sub    $0x4,%edi
  80095b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	fd                   	std    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 09                	jmp    80096f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 1d                	jmp    80098f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	89 f2                	mov    %esi,%edx
  800974:	09 c2                	or     %eax,%edx
  800976:	f6 c2 03             	test   $0x3,%dl
  800979:	75 0f                	jne    80098a <memmove+0x5f>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0a                	jne    80098a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800980:	c1 e9 02             	shr    $0x2,%ecx
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 05                	jmp    80098f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	ff 75 0c             	pushl  0xc(%ebp)
  80099c:	ff 75 08             	pushl  0x8(%ebp)
  80099f:	e8 87 ff ff ff       	call   80092b <memmove>
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	89 c6                	mov    %eax,%esi
  8009b3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	eb 1a                	jmp    8009d2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b8:	0f b6 08             	movzbl (%eax),%ecx
  8009bb:	0f b6 1a             	movzbl (%edx),%ebx
  8009be:	38 d9                	cmp    %bl,%cl
  8009c0:	74 0a                	je     8009cc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c2:	0f b6 c1             	movzbl %cl,%eax
  8009c5:	0f b6 db             	movzbl %bl,%ebx
  8009c8:	29 d8                	sub    %ebx,%eax
  8009ca:	eb 0f                	jmp    8009db <memcmp+0x35>
		s1++, s2++;
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	39 f0                	cmp    %esi,%eax
  8009d4:	75 e2                	jne    8009b8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e6:	89 c1                	mov    %eax,%ecx
  8009e8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009eb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ef:	eb 0a                	jmp    8009fb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f1:	0f b6 10             	movzbl (%eax),%edx
  8009f4:	39 da                	cmp    %ebx,%edx
  8009f6:	74 07                	je     8009ff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f8:	83 c0 01             	add    $0x1,%eax
  8009fb:	39 c8                	cmp    %ecx,%eax
  8009fd:	72 f2                	jb     8009f1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	eb 03                	jmp    800a13 <strtol+0x11>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	0f b6 01             	movzbl (%ecx),%eax
  800a16:	3c 20                	cmp    $0x20,%al
  800a18:	74 f6                	je     800a10 <strtol+0xe>
  800a1a:	3c 09                	cmp    $0x9,%al
  800a1c:	74 f2                	je     800a10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1e:	3c 2b                	cmp    $0x2b,%al
  800a20:	75 0a                	jne    800a2c <strtol+0x2a>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2a:	eb 11                	jmp    800a3d <strtol+0x3b>
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 08                	jne    800a3d <strtol+0x3b>
		s++, neg = 1;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 15                	jne    800a5a <strtol+0x58>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	75 10                	jne    800a5a <strtol+0x58>
  800a4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4e:	75 7c                	jne    800acc <strtol+0xca>
		s += 2, base = 16;
  800a50:	83 c1 02             	add    $0x2,%ecx
  800a53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a58:	eb 16                	jmp    800a70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	75 12                	jne    800a70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 08                	jne    800a70 <strtol+0x6e>
		s++, base = 8;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	0f b6 11             	movzbl (%ecx),%edx
  800a7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 09             	cmp    $0x9,%bl
  800a83:	77 08                	ja     800a8d <strtol+0x8b>
			dig = *s - '0';
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 30             	sub    $0x30,%edx
  800a8b:	eb 22                	jmp    800aaf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 19             	cmp    $0x19,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 57             	sub    $0x57,%edx
  800a9d:	eb 10                	jmp    800aaf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 16                	ja     800abf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab2:	7d 0b                	jge    800abf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abd:	eb b9                	jmp    800a78 <strtol+0x76>

	if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 0d                	je     800ad2 <strtol+0xd0>
		*endptr = (char *) s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 0e                	mov    %ecx,(%esi)
  800aca:	eb 06                	jmp    800ad2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acc:	85 db                	test   %ebx,%ebx
  800ace:	74 98                	je     800a68 <strtol+0x66>
  800ad0:	eb 9e                	jmp    800a70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad2:	89 c2                	mov    %eax,%edx
  800ad4:	f7 da                	neg    %edx
  800ad6:	85 ff                	test   %edi,%edi
  800ad8:	0f 45 c2             	cmovne %edx,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	89 c7                	mov    %eax,%edi
  800af5:	89 c6                	mov    %eax,%esi
  800af7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cgetc>:

int
sys_cgetc(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	89 cb                	mov    %ecx,%ebx
  800b35:	89 cf                	mov    %ecx,%edi
  800b37:	89 ce                	mov    %ecx,%esi
  800b39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 03                	push   $0x3
  800b45:	68 df 25 80 00       	push   $0x8025df
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 fc 25 80 00       	push   $0x8025fc
  800b51:	e8 7d 13 00 00       	call   801ed3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_yield>:

void
sys_yield(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	be 00 00 00 00       	mov    $0x0,%esi
  800baa:	b8 04 00 00 00       	mov    $0x4,%eax
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb8:	89 f7                	mov    %esi,%edi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 04                	push   $0x4
  800bc6:	68 df 25 80 00       	push   $0x8025df
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 fc 25 80 00       	push   $0x8025fc
  800bd2:	e8 fc 12 00 00       	call   801ed3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 05                	push   $0x5
  800c08:	68 df 25 80 00       	push   $0x8025df
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 fc 25 80 00       	push   $0x8025fc
  800c14:	e8 ba 12 00 00       	call   801ed3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 df                	mov    %ebx,%edi
  800c3c:	89 de                	mov    %ebx,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 06                	push   $0x6
  800c4a:	68 df 25 80 00       	push   $0x8025df
  800c4f:	6a 23                	push   $0x23
  800c51:	68 fc 25 80 00       	push   $0x8025fc
  800c56:	e8 78 12 00 00       	call   801ed3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 08 00 00 00       	mov    $0x8,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 08                	push   $0x8
  800c8c:	68 df 25 80 00       	push   $0x8025df
  800c91:	6a 23                	push   $0x23
  800c93:	68 fc 25 80 00       	push   $0x8025fc
  800c98:	e8 36 12 00 00       	call   801ed3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 09                	push   $0x9
  800cce:	68 df 25 80 00       	push   $0x8025df
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 fc 25 80 00       	push   $0x8025fc
  800cda:	e8 f4 11 00 00       	call   801ed3 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 0a                	push   $0xa
  800d10:	68 df 25 80 00       	push   $0x8025df
  800d15:	6a 23                	push   $0x23
  800d17:	68 fc 25 80 00       	push   $0x8025fc
  800d1c:	e8 b2 11 00 00       	call   801ed3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	be 00 00 00 00       	mov    $0x0,%esi
  800d34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 cb                	mov    %ecx,%ebx
  800d64:	89 cf                	mov    %ecx,%edi
  800d66:	89 ce                	mov    %ecx,%esi
  800d68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 17                	jle    800d85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	83 ec 0c             	sub    $0xc,%esp
  800d71:	50                   	push   %eax
  800d72:	6a 0d                	push   $0xd
  800d74:	68 df 25 80 00       	push   $0x8025df
  800d79:	6a 23                	push   $0x23
  800d7b:	68 fc 25 80 00       	push   $0x8025fc
  800d80:	e8 4e 11 00 00       	call   801ed3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
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
  800d98:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 cb                	mov    %ecx,%ebx
  800da2:	89 cf                	mov    %ecx,%edi
  800da4:	89 ce                	mov    %ecx,%esi
  800da6:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dd9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ddd:	74 11                	je     800df0 <pgfault+0x23>
  800ddf:	89 d8                	mov    %ebx,%eax
  800de1:	c1 e8 0c             	shr    $0xc,%eax
  800de4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800deb:	f6 c4 08             	test   $0x8,%ah
  800dee:	75 14                	jne    800e04 <pgfault+0x37>
		panic("faulting access");
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	68 0a 26 80 00       	push   $0x80260a
  800df8:	6a 1e                	push   $0x1e
  800dfa:	68 1a 26 80 00       	push   $0x80261a
  800dff:	e8 cf 10 00 00       	call   801ed3 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	6a 07                	push   $0x7
  800e09:	68 00 f0 7f 00       	push   $0x7ff000
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 87 fd ff ff       	call   800b9c <sys_page_alloc>
	if (r < 0) {
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	79 12                	jns    800e2e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e1c:	50                   	push   %eax
  800e1d:	68 25 26 80 00       	push   $0x802625
  800e22:	6a 2c                	push   $0x2c
  800e24:	68 1a 26 80 00       	push   $0x80261a
  800e29:	e8 a5 10 00 00       	call   801ed3 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	68 00 10 00 00       	push   $0x1000
  800e3c:	53                   	push   %ebx
  800e3d:	68 00 f0 7f 00       	push   $0x7ff000
  800e42:	e8 4c fb ff ff       	call   800993 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e47:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4e:	53                   	push   %ebx
  800e4f:	6a 00                	push   $0x0
  800e51:	68 00 f0 7f 00       	push   $0x7ff000
  800e56:	6a 00                	push   $0x0
  800e58:	e8 82 fd ff ff       	call   800bdf <sys_page_map>
	if (r < 0) {
  800e5d:	83 c4 20             	add    $0x20,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 12                	jns    800e76 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e64:	50                   	push   %eax
  800e65:	68 25 26 80 00       	push   $0x802625
  800e6a:	6a 33                	push   $0x33
  800e6c:	68 1a 26 80 00       	push   $0x80261a
  800e71:	e8 5d 10 00 00       	call   801ed3 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 9c fd ff ff       	call   800c21 <sys_page_unmap>
	if (r < 0) {
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 12                	jns    800e9e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e8c:	50                   	push   %eax
  800e8d:	68 25 26 80 00       	push   $0x802625
  800e92:	6a 37                	push   $0x37
  800e94:	68 1a 26 80 00       	push   $0x80261a
  800e99:	e8 35 10 00 00       	call   801ed3 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800eac:	68 cd 0d 80 00       	push   $0x800dcd
  800eb1:	e8 63 10 00 00       	call   801f19 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebb:	cd 30                	int    $0x30
  800ebd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	79 17                	jns    800ede <fork+0x3b>
		panic("fork fault %e");
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	68 3e 26 80 00       	push   $0x80263e
  800ecf:	68 84 00 00 00       	push   $0x84
  800ed4:	68 1a 26 80 00       	push   $0x80261a
  800ed9:	e8 f5 0f 00 00       	call   801ed3 <_panic>
  800ede:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ee0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee4:	75 24                	jne    800f0a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee6:	e8 73 fc ff ff       	call   800b5e <sys_getenvid>
  800eeb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800ef6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efb:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
  800f05:	e9 64 01 00 00       	jmp    80106e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	6a 07                	push   $0x7
  800f0f:	68 00 f0 bf ee       	push   $0xeebff000
  800f14:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f17:	e8 80 fc ff ff       	call   800b9c <sys_page_alloc>
  800f1c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f1f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	c1 e8 16             	shr    $0x16,%eax
  800f29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f30:	a8 01                	test   $0x1,%al
  800f32:	0f 84 fc 00 00 00    	je     801034 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	c1 e8 0c             	shr    $0xc,%eax
  800f3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f44:	f6 c2 01             	test   $0x1,%dl
  800f47:	0f 84 e7 00 00 00    	je     801034 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f4d:	89 c6                	mov    %eax,%esi
  800f4f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f52:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f59:	f6 c6 04             	test   $0x4,%dh
  800f5c:	74 39                	je     800f97 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6d:	50                   	push   %eax
  800f6e:	56                   	push   %esi
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	6a 00                	push   $0x0
  800f73:	e8 67 fc ff ff       	call   800bdf <sys_page_map>
		if (r < 0) {
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	0f 89 b1 00 00 00    	jns    801034 <fork+0x191>
		    	panic("sys page map fault %e");
  800f83:	83 ec 04             	sub    $0x4,%esp
  800f86:	68 4c 26 80 00       	push   $0x80264c
  800f8b:	6a 54                	push   $0x54
  800f8d:	68 1a 26 80 00       	push   $0x80261a
  800f92:	e8 3c 0f 00 00       	call   801ed3 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f97:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9e:	f6 c2 02             	test   $0x2,%dl
  800fa1:	75 0c                	jne    800faf <fork+0x10c>
  800fa3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faa:	f6 c4 08             	test   $0x8,%ah
  800fad:	74 5b                	je     80100a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	68 05 08 00 00       	push   $0x805
  800fb7:	56                   	push   %esi
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 1e fc ff ff       	call   800bdf <sys_page_map>
		if (r < 0) {
  800fc1:	83 c4 20             	add    $0x20,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 14                	jns    800fdc <fork+0x139>
		    	panic("sys page map fault %e");
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	68 4c 26 80 00       	push   $0x80264c
  800fd0:	6a 5b                	push   $0x5b
  800fd2:	68 1a 26 80 00       	push   $0x80261a
  800fd7:	e8 f7 0e 00 00       	call   801ed3 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	68 05 08 00 00       	push   $0x805
  800fe4:	56                   	push   %esi
  800fe5:	6a 00                	push   $0x0
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 f0 fb ff ff       	call   800bdf <sys_page_map>
		if (r < 0) {
  800fef:	83 c4 20             	add    $0x20,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 3e                	jns    801034 <fork+0x191>
		    	panic("sys page map fault %e");
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 4c 26 80 00       	push   $0x80264c
  800ffe:	6a 5f                	push   $0x5f
  801000:	68 1a 26 80 00       	push   $0x80261a
  801005:	e8 c9 0e 00 00       	call   801ed3 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	6a 05                	push   $0x5
  80100f:	56                   	push   %esi
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	6a 00                	push   $0x0
  801014:	e8 c6 fb ff ff       	call   800bdf <sys_page_map>
		if (r < 0) {
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 14                	jns    801034 <fork+0x191>
		    	panic("sys page map fault %e");
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	68 4c 26 80 00       	push   $0x80264c
  801028:	6a 64                	push   $0x64
  80102a:	68 1a 26 80 00       	push   $0x80261a
  80102f:	e8 9f 0e 00 00       	call   801ed3 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801034:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801040:	0f 85 de fe ff ff    	jne    800f24 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801046:	a1 08 40 80 00       	mov    0x804008,%eax
  80104b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	50                   	push   %eax
  801055:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801058:	57                   	push   %edi
  801059:	e8 89 fc ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	6a 02                	push   $0x2
  801063:	57                   	push   %edi
  801064:	e8 fa fb ff ff       	call   800c63 <sys_env_set_status>
	
	return envid;
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80106e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sfork>:

envid_t
sfork(void)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801088:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80108e:	83 ec 08             	sub    $0x8,%esp
  801091:	53                   	push   %ebx
  801092:	68 64 26 80 00       	push   $0x802664
  801097:	e8 78 f1 ff ff       	call   800214 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80109c:	c7 04 24 47 01 80 00 	movl   $0x800147,(%esp)
  8010a3:	e8 e5 fc ff ff       	call   800d8d <sys_thread_create>
  8010a8:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010aa:	83 c4 08             	add    $0x8,%esp
  8010ad:	53                   	push   %ebx
  8010ae:	68 64 26 80 00       	push   $0x802664
  8010b3:	e8 5c f1 ff ff       	call   800214 <cprintf>
	return id;
}
  8010b8:	89 f0                	mov    %esi,%eax
  8010ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8010c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	75 12                	jne    8010e5 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	68 00 00 c0 ee       	push   $0xeec00000
  8010db:	e8 6c fc ff ff       	call   800d4c <sys_ipc_recv>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	eb 0c                	jmp    8010f1 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	50                   	push   %eax
  8010e9:	e8 5e fc ff ff       	call   800d4c <sys_ipc_recv>
  8010ee:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8010f1:	85 f6                	test   %esi,%esi
  8010f3:	0f 95 c1             	setne  %cl
  8010f6:	85 db                	test   %ebx,%ebx
  8010f8:	0f 95 c2             	setne  %dl
  8010fb:	84 d1                	test   %dl,%cl
  8010fd:	74 09                	je     801108 <ipc_recv+0x47>
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	c1 ea 1f             	shr    $0x1f,%edx
  801104:	84 d2                	test   %dl,%dl
  801106:	75 2d                	jne    801135 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801108:	85 f6                	test   %esi,%esi
  80110a:	74 0d                	je     801119 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80110c:	a1 08 40 80 00       	mov    0x804008,%eax
  801111:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801117:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801119:	85 db                	test   %ebx,%ebx
  80111b:	74 0d                	je     80112a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80111d:	a1 08 40 80 00       	mov    0x804008,%eax
  801122:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801128:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80112a:	a1 08 40 80 00       	mov    0x804008,%eax
  80112f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	8b 7d 08             	mov    0x8(%ebp),%edi
  801148:	8b 75 0c             	mov    0xc(%ebp),%esi
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80114e:	85 db                	test   %ebx,%ebx
  801150:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801155:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801158:	ff 75 14             	pushl  0x14(%ebp)
  80115b:	53                   	push   %ebx
  80115c:	56                   	push   %esi
  80115d:	57                   	push   %edi
  80115e:	e8 c6 fb ff ff       	call   800d29 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801163:	89 c2                	mov    %eax,%edx
  801165:	c1 ea 1f             	shr    $0x1f,%edx
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	84 d2                	test   %dl,%dl
  80116d:	74 17                	je     801186 <ipc_send+0x4a>
  80116f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801172:	74 12                	je     801186 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801174:	50                   	push   %eax
  801175:	68 87 26 80 00       	push   $0x802687
  80117a:	6a 47                	push   $0x47
  80117c:	68 95 26 80 00       	push   $0x802695
  801181:	e8 4d 0d 00 00       	call   801ed3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801186:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801189:	75 07                	jne    801192 <ipc_send+0x56>
			sys_yield();
  80118b:	e8 ed f9 ff ff       	call   800b7d <sys_yield>
  801190:	eb c6                	jmp    801158 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801192:	85 c0                	test   %eax,%eax
  801194:	75 c2                	jne    801158 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a9:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8011af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b5:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8011bb:	39 ca                	cmp    %ecx,%edx
  8011bd:	75 10                	jne    8011cf <ipc_find_env+0x31>
			return envs[i].env_id;
  8011bf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8011c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ca:	8b 40 7c             	mov    0x7c(%eax),%eax
  8011cd:	eb 0f                	jmp    8011de <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011cf:	83 c0 01             	add    $0x1,%eax
  8011d2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d7:	75 d0                	jne    8011a9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801200:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801212:	89 c2                	mov    %eax,%edx
  801214:	c1 ea 16             	shr    $0x16,%edx
  801217:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	74 11                	je     801234 <fd_alloc+0x2d>
  801223:	89 c2                	mov    %eax,%edx
  801225:	c1 ea 0c             	shr    $0xc,%edx
  801228:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122f:	f6 c2 01             	test   $0x1,%dl
  801232:	75 09                	jne    80123d <fd_alloc+0x36>
			*fd_store = fd;
  801234:	89 01                	mov    %eax,(%ecx)
			return 0;
  801236:	b8 00 00 00 00       	mov    $0x0,%eax
  80123b:	eb 17                	jmp    801254 <fd_alloc+0x4d>
  80123d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801242:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801247:	75 c9                	jne    801212 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801249:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80125c:	83 f8 1f             	cmp    $0x1f,%eax
  80125f:	77 36                	ja     801297 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801261:	c1 e0 0c             	shl    $0xc,%eax
  801264:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801269:	89 c2                	mov    %eax,%edx
  80126b:	c1 ea 16             	shr    $0x16,%edx
  80126e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801275:	f6 c2 01             	test   $0x1,%dl
  801278:	74 24                	je     80129e <fd_lookup+0x48>
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	c1 ea 0c             	shr    $0xc,%edx
  80127f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801286:	f6 c2 01             	test   $0x1,%dl
  801289:	74 1a                	je     8012a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80128b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128e:	89 02                	mov    %eax,(%edx)
	return 0;
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
  801295:	eb 13                	jmp    8012aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129c:	eb 0c                	jmp    8012aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a3:	eb 05                	jmp    8012aa <fd_lookup+0x54>
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b5:	ba 1c 27 80 00       	mov    $0x80271c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ba:	eb 13                	jmp    8012cf <dev_lookup+0x23>
  8012bc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012bf:	39 08                	cmp    %ecx,(%eax)
  8012c1:	75 0c                	jne    8012cf <dev_lookup+0x23>
			*dev = devtab[i];
  8012c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cd:	eb 2e                	jmp    8012fd <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012cf:	8b 02                	mov    (%edx),%eax
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	75 e7                	jne    8012bc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012da:	8b 40 7c             	mov    0x7c(%eax),%eax
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	51                   	push   %ecx
  8012e1:	50                   	push   %eax
  8012e2:	68 a0 26 80 00       	push   $0x8026a0
  8012e7:	e8 28 ef ff ff       	call   800214 <cprintf>
	*dev = 0;
  8012ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	83 ec 10             	sub    $0x10,%esp
  801307:	8b 75 08             	mov    0x8(%ebp),%esi
  80130a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801317:	c1 e8 0c             	shr    $0xc,%eax
  80131a:	50                   	push   %eax
  80131b:	e8 36 ff ff ff       	call   801256 <fd_lookup>
  801320:	83 c4 08             	add    $0x8,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 05                	js     80132c <fd_close+0x2d>
	    || fd != fd2)
  801327:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80132a:	74 0c                	je     801338 <fd_close+0x39>
		return (must_exist ? r : 0);
  80132c:	84 db                	test   %bl,%bl
  80132e:	ba 00 00 00 00       	mov    $0x0,%edx
  801333:	0f 44 c2             	cmove  %edx,%eax
  801336:	eb 41                	jmp    801379 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 36                	pushl  (%esi)
  801341:	e8 66 ff ff ff       	call   8012ac <dev_lookup>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 1a                	js     801369 <fd_close+0x6a>
		if (dev->dev_close)
  80134f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801352:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801355:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80135a:	85 c0                	test   %eax,%eax
  80135c:	74 0b                	je     801369 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	56                   	push   %esi
  801362:	ff d0                	call   *%eax
  801364:	89 c3                	mov    %eax,%ebx
  801366:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	56                   	push   %esi
  80136d:	6a 00                	push   $0x0
  80136f:	e8 ad f8 ff ff       	call   800c21 <sys_page_unmap>
	return r;
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	89 d8                	mov    %ebx,%eax
}
  801379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 c4 fe ff ff       	call   801256 <fd_lookup>
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 10                	js     8013a9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	6a 01                	push   $0x1
  80139e:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a1:	e8 59 ff ff ff       	call   8012ff <fd_close>
  8013a6:	83 c4 10             	add    $0x10,%esp
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <close_all>:

void
close_all(void)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	e8 c0 ff ff ff       	call   801380 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c0:	83 c3 01             	add    $0x1,%ebx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	83 fb 20             	cmp    $0x20,%ebx
  8013c9:	75 ec                	jne    8013b7 <close_all+0xc>
		close(i);
}
  8013cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 2c             	sub    $0x2c,%esp
  8013d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	ff 75 08             	pushl  0x8(%ebp)
  8013e3:	e8 6e fe ff ff       	call   801256 <fd_lookup>
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	0f 88 c1 00 00 00    	js     8014b4 <dup+0xe4>
		return r;
	close(newfdnum);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	56                   	push   %esi
  8013f7:	e8 84 ff ff ff       	call   801380 <close>

	newfd = INDEX2FD(newfdnum);
  8013fc:	89 f3                	mov    %esi,%ebx
  8013fe:	c1 e3 0c             	shl    $0xc,%ebx
  801401:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801407:	83 c4 04             	add    $0x4,%esp
  80140a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140d:	e8 de fd ff ff       	call   8011f0 <fd2data>
  801412:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801414:	89 1c 24             	mov    %ebx,(%esp)
  801417:	e8 d4 fd ff ff       	call   8011f0 <fd2data>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801422:	89 f8                	mov    %edi,%eax
  801424:	c1 e8 16             	shr    $0x16,%eax
  801427:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142e:	a8 01                	test   $0x1,%al
  801430:	74 37                	je     801469 <dup+0x99>
  801432:	89 f8                	mov    %edi,%eax
  801434:	c1 e8 0c             	shr    $0xc,%eax
  801437:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143e:	f6 c2 01             	test   $0x1,%dl
  801441:	74 26                	je     801469 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801443:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	25 07 0e 00 00       	and    $0xe07,%eax
  801452:	50                   	push   %eax
  801453:	ff 75 d4             	pushl  -0x2c(%ebp)
  801456:	6a 00                	push   $0x0
  801458:	57                   	push   %edi
  801459:	6a 00                	push   $0x0
  80145b:	e8 7f f7 ff ff       	call   800bdf <sys_page_map>
  801460:	89 c7                	mov    %eax,%edi
  801462:	83 c4 20             	add    $0x20,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 2e                	js     801497 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801469:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80146c:	89 d0                	mov    %edx,%eax
  80146e:	c1 e8 0c             	shr    $0xc,%eax
  801471:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	25 07 0e 00 00       	and    $0xe07,%eax
  801480:	50                   	push   %eax
  801481:	53                   	push   %ebx
  801482:	6a 00                	push   $0x0
  801484:	52                   	push   %edx
  801485:	6a 00                	push   $0x0
  801487:	e8 53 f7 ff ff       	call   800bdf <sys_page_map>
  80148c:	89 c7                	mov    %eax,%edi
  80148e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801491:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801493:	85 ff                	test   %edi,%edi
  801495:	79 1d                	jns    8014b4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	53                   	push   %ebx
  80149b:	6a 00                	push   $0x0
  80149d:	e8 7f f7 ff ff       	call   800c21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 72 f7 ff ff       	call   800c21 <sys_page_unmap>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f8                	mov    %edi,%eax
}
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 14             	sub    $0x14,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	e8 86 fd ff ff       	call   801256 <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 6d                	js     801546 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	ff 30                	pushl  (%eax)
  8014e5:	e8 c2 fd ff ff       	call   8012ac <dev_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 4c                	js     80153d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f4:	8b 42 08             	mov    0x8(%edx),%eax
  8014f7:	83 e0 03             	and    $0x3,%eax
  8014fa:	83 f8 01             	cmp    $0x1,%eax
  8014fd:	75 21                	jne    801520 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ff:	a1 08 40 80 00       	mov    0x804008,%eax
  801504:	8b 40 7c             	mov    0x7c(%eax),%eax
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	53                   	push   %ebx
  80150b:	50                   	push   %eax
  80150c:	68 e1 26 80 00       	push   $0x8026e1
  801511:	e8 fe ec ff ff       	call   800214 <cprintf>
		return -E_INVAL;
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151e:	eb 26                	jmp    801546 <read+0x8a>
	}
	if (!dev->dev_read)
  801520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801523:	8b 40 08             	mov    0x8(%eax),%eax
  801526:	85 c0                	test   %eax,%eax
  801528:	74 17                	je     801541 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	ff 75 10             	pushl  0x10(%ebp)
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	52                   	push   %edx
  801534:	ff d0                	call   *%eax
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	8b 7d 08             	mov    0x8(%ebp),%edi
  801559:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801561:	eb 21                	jmp    801584 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	89 f0                	mov    %esi,%eax
  801568:	29 d8                	sub    %ebx,%eax
  80156a:	50                   	push   %eax
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	03 45 0c             	add    0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	57                   	push   %edi
  801572:	e8 45 ff ff ff       	call   8014bc <read>
		if (m < 0)
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 10                	js     80158e <readn+0x41>
			return m;
		if (m == 0)
  80157e:	85 c0                	test   %eax,%eax
  801580:	74 0a                	je     80158c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801582:	01 c3                	add    %eax,%ebx
  801584:	39 f3                	cmp    %esi,%ebx
  801586:	72 db                	jb     801563 <readn+0x16>
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	eb 02                	jmp    80158e <readn+0x41>
  80158c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	53                   	push   %ebx
  8015a5:	e8 ac fc ff ff       	call   801256 <fd_lookup>
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 68                	js     80161b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 e8 fc ff ff       	call   8012ac <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 47                	js     801612 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d2:	75 21                	jne    8015f5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d9:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	53                   	push   %ebx
  8015e0:	50                   	push   %eax
  8015e1:	68 fd 26 80 00       	push   $0x8026fd
  8015e6:	e8 29 ec ff ff       	call   800214 <cprintf>
		return -E_INVAL;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f3:	eb 26                	jmp    80161b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015fb:	85 d2                	test   %edx,%edx
  8015fd:	74 17                	je     801616 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	ff 75 10             	pushl  0x10(%ebp)
  801605:	ff 75 0c             	pushl  0xc(%ebp)
  801608:	50                   	push   %eax
  801609:	ff d2                	call   *%edx
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	eb 09                	jmp    80161b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	89 c2                	mov    %eax,%edx
  801614:	eb 05                	jmp    80161b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801616:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80161b:	89 d0                	mov    %edx,%eax
  80161d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801620:	c9                   	leave  
  801621:	c3                   	ret    

00801622 <seek>:

int
seek(int fdnum, off_t offset)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801628:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	ff 75 08             	pushl  0x8(%ebp)
  80162f:	e8 22 fc ff ff       	call   801256 <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 0e                	js     801649 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80163b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801641:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801644:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 14             	sub    $0x14,%esp
  801652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801655:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801658:	50                   	push   %eax
  801659:	53                   	push   %ebx
  80165a:	e8 f7 fb ff ff       	call   801256 <fd_lookup>
  80165f:	83 c4 08             	add    $0x8,%esp
  801662:	89 c2                	mov    %eax,%edx
  801664:	85 c0                	test   %eax,%eax
  801666:	78 65                	js     8016cd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	ff 30                	pushl  (%eax)
  801674:	e8 33 fc ff ff       	call   8012ac <dev_lookup>
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 44                	js     8016c4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801683:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801687:	75 21                	jne    8016aa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801689:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168e:	8b 40 7c             	mov    0x7c(%eax),%eax
  801691:	83 ec 04             	sub    $0x4,%esp
  801694:	53                   	push   %ebx
  801695:	50                   	push   %eax
  801696:	68 c0 26 80 00       	push   $0x8026c0
  80169b:	e8 74 eb ff ff       	call   800214 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a8:	eb 23                	jmp    8016cd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ad:	8b 52 18             	mov    0x18(%edx),%edx
  8016b0:	85 d2                	test   %edx,%edx
  8016b2:	74 14                	je     8016c8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	50                   	push   %eax
  8016bb:	ff d2                	call   *%edx
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 09                	jmp    8016cd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	eb 05                	jmp    8016cd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016cd:	89 d0                	mov    %edx,%eax
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 14             	sub    $0x14,%esp
  8016db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	ff 75 08             	pushl  0x8(%ebp)
  8016e5:	e8 6c fb ff ff       	call   801256 <fd_lookup>
  8016ea:	83 c4 08             	add    $0x8,%esp
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 58                	js     80174b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	ff 30                	pushl  (%eax)
  8016ff:	e8 a8 fb ff ff       	call   8012ac <dev_lookup>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 37                	js     801742 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80170b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801712:	74 32                	je     801746 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801714:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801717:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171e:	00 00 00 
	stat->st_isdir = 0;
  801721:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801728:	00 00 00 
	stat->st_dev = dev;
  80172b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	53                   	push   %ebx
  801735:	ff 75 f0             	pushl  -0x10(%ebp)
  801738:	ff 50 14             	call   *0x14(%eax)
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	eb 09                	jmp    80174b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801742:	89 c2                	mov    %eax,%edx
  801744:	eb 05                	jmp    80174b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801746:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80174b:	89 d0                	mov    %edx,%eax
  80174d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	6a 00                	push   $0x0
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 e3 01 00 00       	call   801947 <open>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 1b                	js     801788 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	50                   	push   %eax
  801774:	e8 5b ff ff ff       	call   8016d4 <fstat>
  801779:	89 c6                	mov    %eax,%esi
	close(fd);
  80177b:	89 1c 24             	mov    %ebx,(%esp)
  80177e:	e8 fd fb ff ff       	call   801380 <close>
	return r;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	89 f0                	mov    %esi,%eax
}
  801788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	89 c6                	mov    %eax,%esi
  801796:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801798:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179f:	75 12                	jne    8017b3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	6a 01                	push   $0x1
  8017a6:	e8 f3 f9 ff ff       	call   80119e <ipc_find_env>
  8017ab:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b3:	6a 07                	push   $0x7
  8017b5:	68 00 50 80 00       	push   $0x805000
  8017ba:	56                   	push   %esi
  8017bb:	ff 35 00 40 80 00    	pushl  0x804000
  8017c1:	e8 76 f9 ff ff       	call   80113c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c6:	83 c4 0c             	add    $0xc,%esp
  8017c9:	6a 00                	push   $0x0
  8017cb:	53                   	push   %ebx
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 ee f8 ff ff       	call   8010c1 <ipc_recv>
}
  8017d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ee:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fd:	e8 8d ff ff ff       	call   80178f <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 40 0c             	mov    0xc(%eax),%eax
  801810:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 06 00 00 00       	mov    $0x6,%eax
  80181f:	e8 6b ff ff ff       	call   80178f <fsipc>
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	53                   	push   %ebx
  80182a:	83 ec 04             	sub    $0x4,%esp
  80182d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	8b 40 0c             	mov    0xc(%eax),%eax
  801836:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	b8 05 00 00 00       	mov    $0x5,%eax
  801845:	e8 45 ff ff ff       	call   80178f <fsipc>
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 2c                	js     80187a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	68 00 50 80 00       	push   $0x805000
  801856:	53                   	push   %ebx
  801857:	e8 3d ef ff ff       	call   800799 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185c:	a1 80 50 80 00       	mov    0x805080,%eax
  801861:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801867:	a1 84 50 80 00       	mov    0x805084,%eax
  80186c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801888:	8b 55 08             	mov    0x8(%ebp),%edx
  80188b:	8b 52 0c             	mov    0xc(%edx),%edx
  80188e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801894:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801899:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80189e:	0f 47 c2             	cmova  %edx,%eax
  8018a1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018a6:	50                   	push   %eax
  8018a7:	ff 75 0c             	pushl  0xc(%ebp)
  8018aa:	68 08 50 80 00       	push   $0x805008
  8018af:	e8 77 f0 ff ff       	call   80092b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	b8 04 00 00 00       	mov    $0x4,%eax
  8018be:	e8 cc fe ff ff       	call   80178f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e8:	e8 a2 fe ff ff       	call   80178f <fsipc>
  8018ed:	89 c3                	mov    %eax,%ebx
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 4b                	js     80193e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f3:	39 c6                	cmp    %eax,%esi
  8018f5:	73 16                	jae    80190d <devfile_read+0x48>
  8018f7:	68 2c 27 80 00       	push   $0x80272c
  8018fc:	68 33 27 80 00       	push   $0x802733
  801901:	6a 7c                	push   $0x7c
  801903:	68 48 27 80 00       	push   $0x802748
  801908:	e8 c6 05 00 00       	call   801ed3 <_panic>
	assert(r <= PGSIZE);
  80190d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801912:	7e 16                	jle    80192a <devfile_read+0x65>
  801914:	68 53 27 80 00       	push   $0x802753
  801919:	68 33 27 80 00       	push   $0x802733
  80191e:	6a 7d                	push   $0x7d
  801920:	68 48 27 80 00       	push   $0x802748
  801925:	e8 a9 05 00 00       	call   801ed3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	50                   	push   %eax
  80192e:	68 00 50 80 00       	push   $0x805000
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	e8 f0 ef ff ff       	call   80092b <memmove>
	return r;
  80193b:	83 c4 10             	add    $0x10,%esp
}
  80193e:	89 d8                	mov    %ebx,%eax
  801940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801943:	5b                   	pop    %ebx
  801944:	5e                   	pop    %esi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	53                   	push   %ebx
  80194b:	83 ec 20             	sub    $0x20,%esp
  80194e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801951:	53                   	push   %ebx
  801952:	e8 09 ee ff ff       	call   800760 <strlen>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195f:	7f 67                	jg     8019c8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	e8 9a f8 ff ff       	call   801207 <fd_alloc>
  80196d:	83 c4 10             	add    $0x10,%esp
		return r;
  801970:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801972:	85 c0                	test   %eax,%eax
  801974:	78 57                	js     8019cd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	53                   	push   %ebx
  80197a:	68 00 50 80 00       	push   $0x805000
  80197f:	e8 15 ee ff ff       	call   800799 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198f:	b8 01 00 00 00       	mov    $0x1,%eax
  801994:	e8 f6 fd ff ff       	call   80178f <fsipc>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	79 14                	jns    8019b6 <open+0x6f>
		fd_close(fd, 0);
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	6a 00                	push   $0x0
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	e8 50 f9 ff ff       	call   8012ff <fd_close>
		return r;
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	89 da                	mov    %ebx,%edx
  8019b4:	eb 17                	jmp    8019cd <open+0x86>
	}

	return fd2num(fd);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bc:	e8 1f f8 ff ff       	call   8011e0 <fd2num>
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb 05                	jmp    8019cd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019cd:	89 d0                	mov    %edx,%eax
  8019cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e4:	e8 a6 fd ff ff       	call   80178f <fsipc>
}
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	ff 75 08             	pushl  0x8(%ebp)
  8019f9:	e8 f2 f7 ff ff       	call   8011f0 <fd2data>
  8019fe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a00:	83 c4 08             	add    $0x8,%esp
  801a03:	68 5f 27 80 00       	push   $0x80275f
  801a08:	53                   	push   %ebx
  801a09:	e8 8b ed ff ff       	call   800799 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0e:	8b 46 04             	mov    0x4(%esi),%eax
  801a11:	2b 06                	sub    (%esi),%eax
  801a13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a19:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a20:	00 00 00 
	stat->st_dev = &devpipe;
  801a23:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a2a:	30 80 00 
	return 0;
}
  801a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a43:	53                   	push   %ebx
  801a44:	6a 00                	push   $0x0
  801a46:	e8 d6 f1 ff ff       	call   800c21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a4b:	89 1c 24             	mov    %ebx,(%esp)
  801a4e:	e8 9d f7 ff ff       	call   8011f0 <fd2data>
  801a53:	83 c4 08             	add    $0x8,%esp
  801a56:	50                   	push   %eax
  801a57:	6a 00                	push   $0x0
  801a59:	e8 c3 f1 ff ff       	call   800c21 <sys_page_unmap>
}
  801a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	57                   	push   %edi
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	83 ec 1c             	sub    $0x1c,%esp
  801a6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a71:	a1 08 40 80 00       	mov    0x804008,%eax
  801a76:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a82:	e8 21 05 00 00       	call   801fa8 <pageref>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	89 3c 24             	mov    %edi,(%esp)
  801a8c:	e8 17 05 00 00       	call   801fa8 <pageref>
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	39 c3                	cmp    %eax,%ebx
  801a96:	0f 94 c1             	sete   %cl
  801a99:	0f b6 c9             	movzbl %cl,%ecx
  801a9c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a9f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801aa5:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801aab:	39 ce                	cmp    %ecx,%esi
  801aad:	74 1e                	je     801acd <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801aaf:	39 c3                	cmp    %eax,%ebx
  801ab1:	75 be                	jne    801a71 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ab3:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801ab9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abc:	50                   	push   %eax
  801abd:	56                   	push   %esi
  801abe:	68 66 27 80 00       	push   $0x802766
  801ac3:	e8 4c e7 ff ff       	call   800214 <cprintf>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	eb a4                	jmp    801a71 <_pipeisclosed+0xe>
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
  801ae5:	e8 06 f7 ff ff       	call   8011f0 <fd2data>
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
  801afa:	e8 64 ff ff ff       	call   801a63 <_pipeisclosed>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	75 48                	jne    801b4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b03:	e8 75 f0 ff ff       	call   800b7d <sys_yield>
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
  801b65:	e8 86 f6 ff ff       	call   8011f0 <fd2data>
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
  801b82:	e8 dc fe ff ff       	call   801a63 <_pipeisclosed>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	75 32                	jne    801bbd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b8b:	e8 ed ef ff ff       	call   800b7d <sys_yield>
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
  801bd6:	e8 2c f6 ff ff       	call   801207 <fd_alloc>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	89 c2                	mov    %eax,%edx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 2c 01 00 00    	js     801d14 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 a2 ef ff ff       	call   800b9c <sys_page_alloc>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	89 c2                	mov    %eax,%edx
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 0d 01 00 00    	js     801d14 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0d:	50                   	push   %eax
  801c0e:	e8 f4 f5 ff ff       	call   801207 <fd_alloc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	0f 88 e2 00 00 00    	js     801d02 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c20:	83 ec 04             	sub    $0x4,%esp
  801c23:	68 07 04 00 00       	push   $0x407
  801c28:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 6a ef ff ff       	call   800b9c <sys_page_alloc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 c3 00 00 00    	js     801d02 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f4             	pushl  -0xc(%ebp)
  801c45:	e8 a6 f5 ff ff       	call   8011f0 <fd2data>
  801c4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4c:	83 c4 0c             	add    $0xc,%esp
  801c4f:	68 07 04 00 00       	push   $0x407
  801c54:	50                   	push   %eax
  801c55:	6a 00                	push   $0x0
  801c57:	e8 40 ef ff ff       	call   800b9c <sys_page_alloc>
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	0f 88 89 00 00 00    	js     801cf2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6f:	e8 7c f5 ff ff       	call   8011f0 <fd2data>
  801c74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c7b:	50                   	push   %eax
  801c7c:	6a 00                	push   $0x0
  801c7e:	56                   	push   %esi
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 59 ef ff ff       	call   800bdf <sys_page_map>
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
  801cbf:	e8 1c f5 ff ff       	call   8011e0 <fd2num>
  801cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cc9:	83 c4 04             	add    $0x4,%esp
  801ccc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccf:	e8 0c f5 ff ff       	call   8011e0 <fd2num>
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
  801cea:	e8 32 ef ff ff       	call   800c21 <sys_page_unmap>
  801cef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 22 ef ff ff       	call   800c21 <sys_page_unmap>
  801cff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 12 ef ff ff       	call   800c21 <sys_page_unmap>
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
  801d2a:	e8 27 f5 ff ff       	call   801256 <fd_lookup>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	78 18                	js     801d4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3c:	e8 af f4 ff ff       	call   8011f0 <fd2data>
	return _pipeisclosed(fd, p);
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d46:	e8 18 fd ff ff       	call   801a63 <_pipeisclosed>
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
  801d60:	68 7e 27 80 00       	push   $0x80277e
  801d65:	ff 75 0c             	pushl  0xc(%ebp)
  801d68:	e8 2c ea ff ff       	call   800799 <strcpy>
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
  801da6:	e8 80 eb ff ff       	call   80092b <memmove>
		sys_cputs(buf, m);
  801dab:	83 c4 08             	add    $0x8,%esp
  801dae:	53                   	push   %ebx
  801daf:	57                   	push   %edi
  801db0:	e8 2b ed ff ff       	call   800ae0 <sys_cputs>
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
  801ddc:	e8 9c ed ff ff       	call   800b7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de1:	e8 18 ed ff ff       	call   800afe <sys_cgetc>
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
  801e18:	e8 c3 ec ff ff       	call   800ae0 <sys_cputs>
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
  801e30:	e8 87 f6 ff ff       	call   8014bc <read>
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
  801e5a:	e8 f7 f3 ff ff       	call   801256 <fd_lookup>
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
  801e83:	e8 7f f3 ff ff       	call   801207 <fd_alloc>
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
  801e9e:	e8 f9 ec ff ff       	call   800b9c <sys_page_alloc>
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
  801ec5:	e8 16 f3 ff ff       	call   8011e0 <fd2num>
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
  801ee1:	e8 78 ec ff ff       	call   800b5e <sys_getenvid>
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	ff 75 08             	pushl  0x8(%ebp)
  801eef:	56                   	push   %esi
  801ef0:	50                   	push   %eax
  801ef1:	68 8c 27 80 00       	push   $0x80278c
  801ef6:	e8 19 e3 ff ff       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801efb:	83 c4 18             	add    $0x18,%esp
  801efe:	53                   	push   %ebx
  801eff:	ff 75 10             	pushl  0x10(%ebp)
  801f02:	e8 bc e2 ff ff       	call   8001c3 <vcprintf>
	cprintf("\n");
  801f07:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  801f0e:	e8 01 e3 ff ff       	call   800214 <cprintf>
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
  801f34:	e8 63 ec ff ff       	call   800b9c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	79 12                	jns    801f52 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f40:	50                   	push   %eax
  801f41:	68 b0 27 80 00       	push   $0x8027b0
  801f46:	6a 23                	push   $0x23
  801f48:	68 b4 27 80 00       	push   $0x8027b4
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
  801f64:	e8 7e ed ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	79 12                	jns    801f82 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f70:	50                   	push   %eax
  801f71:	68 b0 27 80 00       	push   $0x8027b0
  801f76:	6a 2c                	push   $0x2c
  801f78:	68 b4 27 80 00       	push   $0x8027b4
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
