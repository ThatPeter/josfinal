
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
  80003c:	e8 14 10 00 00       	call   801055 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 30 0b 00 00       	call   800b83 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 20 22 80 00       	push   $0x802220
  80005d:	e8 d7 01 00 00       	call   800239 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 19 0b 00 00       	call   800b83 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 3a 22 80 00       	push   $0x80223a
  800074:	e8 c0 01 00 00       	call   800239 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 5a 10 00 00       	call   8010e1 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 d5 0f 00 00       	call   80106f <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 d0 0a 00 00       	call   800b83 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 50 22 80 00       	push   $0x802250
  8000c2:	e8 72 01 00 00       	call   800239 <cprintf>
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
  8000e5:	e8 f7 0f 00 00       	call   8010e1 <ipc_send>
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
  800111:	e8 6d 0a 00 00       	call   800b83 <sys_getenvid>
  800116:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  80011c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800121:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80012b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80012e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800134:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800137:	39 c8                	cmp    %ecx,%eax
  800139:	0f 44 fb             	cmove  %ebx,%edi
  80013c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800141:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800144:	83 c2 01             	add    $0x1,%edx
  800147:	83 c3 7c             	add    $0x7c,%ebx
  80014a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800150:	75 d9                	jne    80012b <libmain+0x2d>
  800152:	89 f0                	mov    %esi,%eax
  800154:	84 c0                	test   %al,%al
  800156:	74 06                	je     80015e <libmain+0x60>
  800158:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800162:	7e 0a                	jle    80016e <libmain+0x70>
		binaryname = argv[0];
  800164:	8b 45 0c             	mov    0xc(%ebp),%eax
  800167:	8b 00                	mov    (%eax),%eax
  800169:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	ff 75 0c             	pushl  0xc(%ebp)
  800174:	ff 75 08             	pushl  0x8(%ebp)
  800177:	e8 b7 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80017c:	e8 0b 00 00 00       	call   80018c <exit>
}
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5f                   	pop    %edi
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800192:	e8 b0 11 00 00       	call   801347 <close_all>
	sys_env_destroy(0);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	6a 00                	push   $0x0
  80019c:	e8 a1 09 00 00       	call   800b42 <sys_env_destroy>
}
  8001a1:	83 c4 10             	add    $0x10,%esp
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 04             	sub    $0x4,%esp
  8001ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b0:	8b 13                	mov    (%ebx),%edx
  8001b2:	8d 42 01             	lea    0x1(%edx),%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
  8001b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 1a                	jne    8001df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 2f 09 00 00       	call   800b05 <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f8:	00 00 00 
	b.cnt = 0;
  8001fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800202:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800205:	ff 75 0c             	pushl  0xc(%ebp)
  800208:	ff 75 08             	pushl  0x8(%ebp)
  80020b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	68 a6 01 80 00       	push   $0x8001a6
  800217:	e8 54 01 00 00       	call   800370 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021c:	83 c4 08             	add    $0x8,%esp
  80021f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800225:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022b:	50                   	push   %eax
  80022c:	e8 d4 08 00 00       	call   800b05 <sys_cputs>

	return b.cnt;
}
  800231:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800242:	50                   	push   %eax
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	e8 9d ff ff ff       	call   8001e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	57                   	push   %edi
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 1c             	sub    $0x1c,%esp
  800256:	89 c7                	mov    %eax,%edi
  800258:	89 d6                	mov    %edx,%esi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800271:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800274:	39 d3                	cmp    %edx,%ebx
  800276:	72 05                	jb     80027d <printnum+0x30>
  800278:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027b:	77 45                	ja     8002c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	8b 45 14             	mov    0x14(%ebp),%eax
  800286:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800289:	53                   	push   %ebx
  80028a:	ff 75 10             	pushl  0x10(%ebp)
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 df 1c 00 00       	call   801f80 <__udivdi3>
  8002a1:	83 c4 18             	add    $0x18,%esp
  8002a4:	52                   	push   %edx
  8002a5:	50                   	push   %eax
  8002a6:	89 f2                	mov    %esi,%edx
  8002a8:	89 f8                	mov    %edi,%eax
  8002aa:	e8 9e ff ff ff       	call   80024d <printnum>
  8002af:	83 c4 20             	add    $0x20,%esp
  8002b2:	eb 18                	jmp    8002cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	ff 75 18             	pushl  0x18(%ebp)
  8002bb:	ff d7                	call   *%edi
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	eb 03                	jmp    8002c5 <printnum+0x78>
  8002c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c5:	83 eb 01             	sub    $0x1,%ebx
  8002c8:	85 db                	test   %ebx,%ebx
  8002ca:	7f e8                	jg     8002b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	56                   	push   %esi
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002df:	e8 cc 1d 00 00       	call   8020b0 <__umoddi3>
  8002e4:	83 c4 14             	add    $0x14,%esp
  8002e7:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  8002ee:	50                   	push   %eax
  8002ef:	ff d7                	call   *%edi
}
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ff:	83 fa 01             	cmp    $0x1,%edx
  800302:	7e 0e                	jle    800312 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 08             	lea    0x8(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	8b 52 04             	mov    0x4(%edx),%edx
  800310:	eb 22                	jmp    800334 <getuint+0x38>
	else if (lflag)
  800312:	85 d2                	test   %edx,%edx
  800314:	74 10                	je     800326 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
  800324:	eb 0e                	jmp    800334 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800340:	8b 10                	mov    (%eax),%edx
  800342:	3b 50 04             	cmp    0x4(%eax),%edx
  800345:	73 0a                	jae    800351 <sprintputch+0x1b>
		*b->buf++ = ch;
  800347:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034a:	89 08                	mov    %ecx,(%eax)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	88 02                	mov    %al,(%edx)
}
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800359:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035c:	50                   	push   %eax
  80035d:	ff 75 10             	pushl  0x10(%ebp)
  800360:	ff 75 0c             	pushl  0xc(%ebp)
  800363:	ff 75 08             	pushl  0x8(%ebp)
  800366:	e8 05 00 00 00       	call   800370 <vprintfmt>
	va_end(ap);
}
  80036b:	83 c4 10             	add    $0x10,%esp
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 2c             	sub    $0x2c,%esp
  800379:	8b 75 08             	mov    0x8(%ebp),%esi
  80037c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800382:	eb 12                	jmp    800396 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800384:	85 c0                	test   %eax,%eax
  800386:	0f 84 89 03 00 00    	je     800715 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	53                   	push   %ebx
  800390:	50                   	push   %eax
  800391:	ff d6                	call   *%esi
  800393:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800396:	83 c7 01             	add    $0x1,%edi
  800399:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039d:	83 f8 25             	cmp    $0x25,%eax
  8003a0:	75 e2                	jne    800384 <vprintfmt+0x14>
  8003a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	eb 07                	jmp    8003c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8d 47 01             	lea    0x1(%edi),%eax
  8003cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cf:	0f b6 07             	movzbl (%edi),%eax
  8003d2:	0f b6 c8             	movzbl %al,%ecx
  8003d5:	83 e8 23             	sub    $0x23,%eax
  8003d8:	3c 55                	cmp    $0x55,%al
  8003da:	0f 87 1a 03 00 00    	ja     8006fa <vprintfmt+0x38a>
  8003e0:	0f b6 c0             	movzbl %al,%eax
  8003e3:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f1:	eb d6                	jmp    8003c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800401:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800405:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800408:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040b:	83 fa 09             	cmp    $0x9,%edx
  80040e:	77 39                	ja     800449 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800410:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800413:	eb e9                	jmp    8003fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8d 48 04             	lea    0x4(%eax),%ecx
  80041b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800426:	eb 27                	jmp    80044f <vprintfmt+0xdf>
  800428:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800432:	0f 49 c8             	cmovns %eax,%ecx
  800435:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043b:	eb 8c                	jmp    8003c9 <vprintfmt+0x59>
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800440:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800447:	eb 80                	jmp    8003c9 <vprintfmt+0x59>
  800449:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800453:	0f 89 70 ff ff ff    	jns    8003c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800459:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800466:	e9 5e ff ff ff       	jmp    8003c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800471:	e9 53 ff ff ff       	jmp    8003c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	ff 30                	pushl  (%eax)
  800485:	ff d6                	call   *%esi
			break;
  800487:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048d:	e9 04 ff ff ff       	jmp    800396 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	99                   	cltd   
  80049e:	31 d0                	xor    %edx,%eax
  8004a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a2:	83 f8 0f             	cmp    $0xf,%eax
  8004a5:	7f 0b                	jg     8004b2 <vprintfmt+0x142>
  8004a7:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	75 18                	jne    8004ca <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b2:	50                   	push   %eax
  8004b3:	68 98 22 80 00       	push   $0x802298
  8004b8:	53                   	push   %ebx
  8004b9:	56                   	push   %esi
  8004ba:	e8 94 fe ff ff       	call   800353 <printfmt>
  8004bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c5:	e9 cc fe ff ff       	jmp    800396 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ca:	52                   	push   %edx
  8004cb:	68 d5 26 80 00       	push   $0x8026d5
  8004d0:	53                   	push   %ebx
  8004d1:	56                   	push   %esi
  8004d2:	e8 7c fe ff ff       	call   800353 <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004dd:	e9 b4 fe ff ff       	jmp    800396 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	b8 91 22 80 00       	mov    $0x802291,%eax
  8004f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fb:	0f 8e 94 00 00 00    	jle    800595 <vprintfmt+0x225>
  800501:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800505:	0f 84 98 00 00 00    	je     8005a3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	ff 75 d0             	pushl  -0x30(%ebp)
  800511:	57                   	push   %edi
  800512:	e8 86 02 00 00       	call   80079d <strnlen>
  800517:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800522:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800526:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800529:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	eb 0f                	jmp    80053f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	ff 75 e0             	pushl  -0x20(%ebp)
  800537:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 ef 01             	sub    $0x1,%edi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	85 ff                	test   %edi,%edi
  800541:	7f ed                	jg     800530 <vprintfmt+0x1c0>
  800543:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800546:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800549:	85 c9                	test   %ecx,%ecx
  80054b:	b8 00 00 00 00       	mov    $0x0,%eax
  800550:	0f 49 c1             	cmovns %ecx,%eax
  800553:	29 c1                	sub    %eax,%ecx
  800555:	89 75 08             	mov    %esi,0x8(%ebp)
  800558:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055e:	89 cb                	mov    %ecx,%ebx
  800560:	eb 4d                	jmp    8005af <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800562:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800566:	74 1b                	je     800583 <vprintfmt+0x213>
  800568:	0f be c0             	movsbl %al,%eax
  80056b:	83 e8 20             	sub    $0x20,%eax
  80056e:	83 f8 5e             	cmp    $0x5e,%eax
  800571:	76 10                	jbe    800583 <vprintfmt+0x213>
					putch('?', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	6a 3f                	push   $0x3f
  80057b:	ff 55 08             	call   *0x8(%ebp)
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb 0d                	jmp    800590 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 0c             	pushl  0xc(%ebp)
  800589:	52                   	push   %edx
  80058a:	ff 55 08             	call   *0x8(%ebp)
  80058d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800590:	83 eb 01             	sub    $0x1,%ebx
  800593:	eb 1a                	jmp    8005af <vprintfmt+0x23f>
  800595:	89 75 08             	mov    %esi,0x8(%ebp)
  800598:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a1:	eb 0c                	jmp    8005af <vprintfmt+0x23f>
  8005a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005af:	83 c7 01             	add    $0x1,%edi
  8005b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b6:	0f be d0             	movsbl %al,%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	74 23                	je     8005e0 <vprintfmt+0x270>
  8005bd:	85 f6                	test   %esi,%esi
  8005bf:	78 a1                	js     800562 <vprintfmt+0x1f2>
  8005c1:	83 ee 01             	sub    $0x1,%esi
  8005c4:	79 9c                	jns    800562 <vprintfmt+0x1f2>
  8005c6:	89 df                	mov    %ebx,%edi
  8005c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ce:	eb 18                	jmp    8005e8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 20                	push   $0x20
  8005d6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d8:	83 ef 01             	sub    $0x1,%edi
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	eb 08                	jmp    8005e8 <vprintfmt+0x278>
  8005e0:	89 df                	mov    %ebx,%edi
  8005e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e8:	85 ff                	test   %edi,%edi
  8005ea:	7f e4                	jg     8005d0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ef:	e9 a2 fd ff ff       	jmp    800396 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f4:	83 fa 01             	cmp    $0x1,%edx
  8005f7:	7e 16                	jle    80060f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 08             	lea    0x8(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 50 04             	mov    0x4(%eax),%edx
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060d:	eb 32                	jmp    800641 <vprintfmt+0x2d1>
	else if (lflag)
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 18                	je     80062b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800621:	89 c1                	mov    %eax,%ecx
  800623:	c1 f9 1f             	sar    $0x1f,%ecx
  800626:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800629:	eb 16                	jmp    800641 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 c1                	mov    %eax,%ecx
  80063b:	c1 f9 1f             	sar    $0x1f,%ecx
  80063e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800641:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800644:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800647:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800650:	79 74                	jns    8006c6 <vprintfmt+0x356>
				putch('-', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 2d                	push   $0x2d
  800658:	ff d6                	call   *%esi
				num = -(long long) num;
  80065a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800660:	f7 d8                	neg    %eax
  800662:	83 d2 00             	adc    $0x0,%edx
  800665:	f7 da                	neg    %edx
  800667:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066f:	eb 55                	jmp    8006c6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 83 fc ff ff       	call   8002fc <getuint>
			base = 10;
  800679:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067e:	eb 46                	jmp    8006c6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 74 fc ff ff       	call   8002fc <getuint>
			base = 8;
  800688:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068d:	eb 37                	jmp    8006c6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 30                	push   $0x30
  800695:	ff d6                	call   *%esi
			putch('x', putdat);
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 78                	push   $0x78
  80069d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b7:	eb 0d                	jmp    8006c6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bc:	e8 3b fc ff ff       	call   8002fc <getuint>
			base = 16;
  8006c1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c6:	83 ec 0c             	sub    $0xc,%esp
  8006c9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cd:	57                   	push   %edi
  8006ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d1:	51                   	push   %ecx
  8006d2:	52                   	push   %edx
  8006d3:	50                   	push   %eax
  8006d4:	89 da                	mov    %ebx,%edx
  8006d6:	89 f0                	mov    %esi,%eax
  8006d8:	e8 70 fb ff ff       	call   80024d <printnum>
			break;
  8006dd:	83 c4 20             	add    $0x20,%esp
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e3:	e9 ae fc ff ff       	jmp    800396 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	51                   	push   %ecx
  8006ed:	ff d6                	call   *%esi
			break;
  8006ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f5:	e9 9c fc ff ff       	jmp    800396 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 25                	push   $0x25
  800700:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 03                	jmp    80070a <vprintfmt+0x39a>
  800707:	83 ef 01             	sub    $0x1,%edi
  80070a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070e:	75 f7                	jne    800707 <vprintfmt+0x397>
  800710:	e9 81 fc ff ff       	jmp    800396 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 18             	sub    $0x18,%esp
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800730:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 26                	je     800764 <vsnprintf+0x47>
  80073e:	85 d2                	test   %edx,%edx
  800740:	7e 22                	jle    800764 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800742:	ff 75 14             	pushl  0x14(%ebp)
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	68 36 03 80 00       	push   $0x800336
  800751:	e8 1a fc ff ff       	call   800370 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800756:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800759:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 05                	jmp    800769 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 9a ff ff ff       	call   80071d <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 03                	jmp    800795 <strlen+0x10>
		n++;
  800792:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	75 f7                	jne    800792 <strlen+0xd>
		n++;
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ab:	eb 03                	jmp    8007b0 <strnlen+0x13>
		n++;
  8007ad:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 08                	je     8007bc <strnlen+0x1f>
  8007b4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b8:	75 f3                	jne    8007ad <strnlen+0x10>
  8007ba:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ef                	jne    8007ca <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e5:	53                   	push   %ebx
  8007e6:	e8 9a ff ff ff       	call   800785 <strlen>
  8007eb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	01 d8                	add    %ebx,%eax
  8007f3:	50                   	push   %eax
  8007f4:	e8 c5 ff ff ff       	call   8007be <strcpy>
	return dst;
}
  8007f9:	89 d8                	mov    %ebx,%eax
  8007fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	89 f3                	mov    %esi,%ebx
  80080d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	89 f2                	mov    %esi,%edx
  800812:	eb 0f                	jmp    800823 <strncpy+0x23>
		*dst++ = *src;
  800814:	83 c2 01             	add    $0x1,%edx
  800817:	0f b6 01             	movzbl (%ecx),%eax
  80081a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081d:	80 39 01             	cmpb   $0x1,(%ecx)
  800820:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	39 da                	cmp    %ebx,%edx
  800825:	75 ed                	jne    800814 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800827:	89 f0                	mov    %esi,%eax
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800838:	8b 55 10             	mov    0x10(%ebp),%edx
  80083b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 21                	je     800862 <strlcpy+0x35>
  800841:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800845:	89 f2                	mov    %esi,%edx
  800847:	eb 09                	jmp    800852 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800852:	39 c2                	cmp    %eax,%edx
  800854:	74 09                	je     80085f <strlcpy+0x32>
  800856:	0f b6 19             	movzbl (%ecx),%ebx
  800859:	84 db                	test   %bl,%bl
  80085b:	75 ec                	jne    800849 <strlcpy+0x1c>
  80085d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800862:	29 f0                	sub    %esi,%eax
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800871:	eb 06                	jmp    800879 <strcmp+0x11>
		p++, q++;
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	84 c0                	test   %al,%al
  80087e:	74 04                	je     800884 <strcmp+0x1c>
  800880:	3a 02                	cmp    (%edx),%al
  800882:	74 ef                	je     800873 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 c0             	movzbl %al,%eax
  800887:	0f b6 12             	movzbl (%edx),%edx
  80088a:	29 d0                	sub    %edx,%eax
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
  800898:	89 c3                	mov    %eax,%ebx
  80089a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strncmp+0x17>
		n--, p++, q++;
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a5:	39 d8                	cmp    %ebx,%eax
  8008a7:	74 15                	je     8008be <strncmp+0x30>
  8008a9:	0f b6 08             	movzbl (%eax),%ecx
  8008ac:	84 c9                	test   %cl,%cl
  8008ae:	74 04                	je     8008b4 <strncmp+0x26>
  8008b0:	3a 0a                	cmp    (%edx),%cl
  8008b2:	74 eb                	je     80089f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	0f b6 00             	movzbl (%eax),%eax
  8008b7:	0f b6 12             	movzbl (%edx),%edx
  8008ba:	29 d0                	sub    %edx,%eax
  8008bc:	eb 05                	jmp    8008c3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 07                	jmp    8008d9 <strchr+0x13>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0f                	je     8008e5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	0f b6 10             	movzbl (%eax),%edx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f2                	jne    8008d2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f1:	eb 03                	jmp    8008f6 <strfind+0xf>
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 04                	je     800901 <strfind+0x1a>
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f2                	jne    8008f3 <strfind+0xc>
			break;
	return (char *) s;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090f:	85 c9                	test   %ecx,%ecx
  800911:	74 36                	je     800949 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800913:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800919:	75 28                	jne    800943 <memset+0x40>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 23                	jne    800943 <memset+0x40>
		c &= 0xFF;
  800920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800924:	89 d3                	mov    %edx,%ebx
  800926:	c1 e3 08             	shl    $0x8,%ebx
  800929:	89 d6                	mov    %edx,%esi
  80092b:	c1 e6 18             	shl    $0x18,%esi
  80092e:	89 d0                	mov    %edx,%eax
  800930:	c1 e0 10             	shl    $0x10,%eax
  800933:	09 f0                	or     %esi,%eax
  800935:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800937:	89 d8                	mov    %ebx,%eax
  800939:	09 d0                	or     %edx,%eax
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb 06                	jmp    800949 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	fc                   	cld    
  800947:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800949:	89 f8                	mov    %edi,%eax
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095e:	39 c6                	cmp    %eax,%esi
  800960:	73 35                	jae    800997 <memmove+0x47>
  800962:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800965:	39 d0                	cmp    %edx,%eax
  800967:	73 2e                	jae    800997 <memmove+0x47>
		s += n;
		d += n;
  800969:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	89 d6                	mov    %edx,%esi
  80096e:	09 fe                	or     %edi,%esi
  800970:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800976:	75 13                	jne    80098b <memmove+0x3b>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0e                	jne    80098b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097d:	83 ef 04             	sub    $0x4,%edi
  800980:	8d 72 fc             	lea    -0x4(%edx),%esi
  800983:	c1 e9 02             	shr    $0x2,%ecx
  800986:	fd                   	std    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 09                	jmp    800994 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098b:	83 ef 01             	sub    $0x1,%edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 1d                	jmp    8009b4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	89 f2                	mov    %esi,%edx
  800999:	09 c2                	or     %eax,%edx
  80099b:	f6 c2 03             	test   $0x3,%dl
  80099e:	75 0f                	jne    8009af <memmove+0x5f>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 0a                	jne    8009af <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 05                	jmp    8009b4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bb:	ff 75 10             	pushl  0x10(%ebp)
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 87 ff ff ff       	call   800950 <memmove>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	eb 1a                	jmp    8009f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	0f b6 1a             	movzbl (%edx),%ebx
  8009e3:	38 d9                	cmp    %bl,%cl
  8009e5:	74 0a                	je     8009f1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e7:	0f b6 c1             	movzbl %cl,%eax
  8009ea:	0f b6 db             	movzbl %bl,%ebx
  8009ed:	29 d8                	sub    %ebx,%eax
  8009ef:	eb 0f                	jmp    800a00 <memcmp+0x35>
		s1++, s2++;
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	75 e2                	jne    8009dd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0b:	89 c1                	mov    %eax,%ecx
  800a0d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	eb 0a                	jmp    800a20 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	0f b6 10             	movzbl (%eax),%edx
  800a19:	39 da                	cmp    %ebx,%edx
  800a1b:	74 07                	je     800a24 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	39 c8                	cmp    %ecx,%eax
  800a22:	72 f2                	jb     800a16 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	eb 03                	jmp    800a38 <strtol+0x11>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a38:	0f b6 01             	movzbl (%ecx),%eax
  800a3b:	3c 20                	cmp    $0x20,%al
  800a3d:	74 f6                	je     800a35 <strtol+0xe>
  800a3f:	3c 09                	cmp    $0x9,%al
  800a41:	74 f2                	je     800a35 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a43:	3c 2b                	cmp    $0x2b,%al
  800a45:	75 0a                	jne    800a51 <strtol+0x2a>
		s++;
  800a47:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4f:	eb 11                	jmp    800a62 <strtol+0x3b>
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a56:	3c 2d                	cmp    $0x2d,%al
  800a58:	75 08                	jne    800a62 <strtol+0x3b>
		s++, neg = 1;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a68:	75 15                	jne    800a7f <strtol+0x58>
  800a6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6d:	75 10                	jne    800a7f <strtol+0x58>
  800a6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a73:	75 7c                	jne    800af1 <strtol+0xca>
		s += 2, base = 16;
  800a75:	83 c1 02             	add    $0x2,%ecx
  800a78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7d:	eb 16                	jmp    800a95 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7f:	85 db                	test   %ebx,%ebx
  800a81:	75 12                	jne    800a95 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a83:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	75 08                	jne    800a95 <strtol+0x6e>
		s++, base = 8;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9d:	0f b6 11             	movzbl (%ecx),%edx
  800aa0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 09             	cmp    $0x9,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x8b>
			dig = *s - '0';
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 30             	sub    $0x30,%edx
  800ab0:	eb 22                	jmp    800ad4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 57             	sub    $0x57,%edx
  800ac2:	eb 10                	jmp    800ad4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 16                	ja     800ae4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ace:	0f be d2             	movsbl %dl,%edx
  800ad1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad7:	7d 0b                	jge    800ae4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae2:	eb b9                	jmp    800a9d <strtol+0x76>

	if (endptr)
  800ae4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae8:	74 0d                	je     800af7 <strtol+0xd0>
		*endptr = (char *) s;
  800aea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aed:	89 0e                	mov    %ecx,(%esi)
  800aef:	eb 06                	jmp    800af7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	74 98                	je     800a8d <strtol+0x66>
  800af5:	eb 9e                	jmp    800a95 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	f7 da                	neg    %edx
  800afb:	85 ff                	test   %edi,%edi
  800afd:	0f 45 c2             	cmovne %edx,%eax
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	89 c6                	mov    %eax,%esi
  800b1c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b50:	b8 03 00 00 00       	mov    $0x3,%eax
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	89 cb                	mov    %ecx,%ebx
  800b5a:	89 cf                	mov    %ecx,%edi
  800b5c:	89 ce                	mov    %ecx,%esi
  800b5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 03                	push   $0x3
  800b6a:	68 7f 25 80 00       	push   $0x80257f
  800b6f:	6a 23                	push   $0x23
  800b71:	68 9c 25 80 00       	push   $0x80259c
  800b76:	e8 eb 12 00 00       	call   801e66 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_yield>:

void
sys_yield(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	be 00 00 00 00       	mov    $0x0,%esi
  800bcf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	89 f7                	mov    %esi,%edi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 04                	push   $0x4
  800beb:	68 7f 25 80 00       	push   $0x80257f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 9c 25 80 00       	push   $0x80259c
  800bf7:	e8 6a 12 00 00       	call   801e66 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 05                	push   $0x5
  800c2d:	68 7f 25 80 00       	push   $0x80257f
  800c32:	6a 23                	push   $0x23
  800c34:	68 9c 25 80 00       	push   $0x80259c
  800c39:	e8 28 12 00 00       	call   801e66 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 06 00 00 00       	mov    $0x6,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 06                	push   $0x6
  800c6f:	68 7f 25 80 00       	push   $0x80257f
  800c74:	6a 23                	push   $0x23
  800c76:	68 9c 25 80 00       	push   $0x80259c
  800c7b:	e8 e6 11 00 00       	call   801e66 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 08                	push   $0x8
  800cb1:	68 7f 25 80 00       	push   $0x80257f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 9c 25 80 00       	push   $0x80259c
  800cbd:	e8 a4 11 00 00       	call   801e66 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 09                	push   $0x9
  800cf3:	68 7f 25 80 00       	push   $0x80257f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 9c 25 80 00       	push   $0x80259c
  800cff:	e8 62 11 00 00       	call   801e66 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 0a                	push   $0xa
  800d35:	68 7f 25 80 00       	push   $0x80257f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 9c 25 80 00       	push   $0x80259c
  800d41:	e8 20 11 00 00       	call   801e66 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d54:	be 00 00 00 00       	mov    $0x0,%esi
  800d59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	89 cb                	mov    %ecx,%ebx
  800d89:	89 cf                	mov    %ecx,%edi
  800d8b:	89 ce                	mov    %ecx,%esi
  800d8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 17                	jle    800daa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 0d                	push   $0xd
  800d99:	68 7f 25 80 00       	push   $0x80257f
  800d9e:	6a 23                	push   $0x23
  800da0:	68 9c 25 80 00       	push   $0x80259c
  800da5:	e8 bc 10 00 00       	call   801e66 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	53                   	push   %ebx
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dbe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc2:	74 11                	je     800dd5 <pgfault+0x23>
  800dc4:	89 d8                	mov    %ebx,%eax
  800dc6:	c1 e8 0c             	shr    $0xc,%eax
  800dc9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd0:	f6 c4 08             	test   $0x8,%ah
  800dd3:	75 14                	jne    800de9 <pgfault+0x37>
		panic("faulting access");
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	68 aa 25 80 00       	push   $0x8025aa
  800ddd:	6a 1d                	push   $0x1d
  800ddf:	68 ba 25 80 00       	push   $0x8025ba
  800de4:	e8 7d 10 00 00       	call   801e66 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	6a 07                	push   $0x7
  800dee:	68 00 f0 7f 00       	push   $0x7ff000
  800df3:	6a 00                	push   $0x0
  800df5:	e8 c7 fd ff ff       	call   800bc1 <sys_page_alloc>
	if (r < 0) {
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	79 12                	jns    800e13 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e01:	50                   	push   %eax
  800e02:	68 c5 25 80 00       	push   $0x8025c5
  800e07:	6a 2b                	push   $0x2b
  800e09:	68 ba 25 80 00       	push   $0x8025ba
  800e0e:	e8 53 10 00 00       	call   801e66 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e13:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e19:	83 ec 04             	sub    $0x4,%esp
  800e1c:	68 00 10 00 00       	push   $0x1000
  800e21:	53                   	push   %ebx
  800e22:	68 00 f0 7f 00       	push   $0x7ff000
  800e27:	e8 8c fb ff ff       	call   8009b8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e2c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e33:	53                   	push   %ebx
  800e34:	6a 00                	push   $0x0
  800e36:	68 00 f0 7f 00       	push   $0x7ff000
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 c2 fd ff ff       	call   800c04 <sys_page_map>
	if (r < 0) {
  800e42:	83 c4 20             	add    $0x20,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	79 12                	jns    800e5b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e49:	50                   	push   %eax
  800e4a:	68 c5 25 80 00       	push   $0x8025c5
  800e4f:	6a 32                	push   $0x32
  800e51:	68 ba 25 80 00       	push   $0x8025ba
  800e56:	e8 0b 10 00 00       	call   801e66 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	68 00 f0 7f 00       	push   $0x7ff000
  800e63:	6a 00                	push   $0x0
  800e65:	e8 dc fd ff ff       	call   800c46 <sys_page_unmap>
	if (r < 0) {
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	79 12                	jns    800e83 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e71:	50                   	push   %eax
  800e72:	68 c5 25 80 00       	push   $0x8025c5
  800e77:	6a 36                	push   $0x36
  800e79:	68 ba 25 80 00       	push   $0x8025ba
  800e7e:	e8 e3 0f 00 00       	call   801e66 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e91:	68 b2 0d 80 00       	push   $0x800db2
  800e96:	e8 11 10 00 00       	call   801eac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e9b:	b8 07 00 00 00       	mov    $0x7,%eax
  800ea0:	cd 30                	int    $0x30
  800ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	79 17                	jns    800ec3 <fork+0x3b>
		panic("fork fault %e");
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	68 de 25 80 00       	push   $0x8025de
  800eb4:	68 83 00 00 00       	push   $0x83
  800eb9:	68 ba 25 80 00       	push   $0x8025ba
  800ebe:	e8 a3 0f 00 00       	call   801e66 <_panic>
  800ec3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec9:	75 21                	jne    800eec <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ecb:	e8 b3 fc ff ff       	call   800b83 <sys_getenvid>
  800ed0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edd:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	e9 61 01 00 00       	jmp    80104d <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	6a 07                	push   $0x7
  800ef1:	68 00 f0 bf ee       	push   $0xeebff000
  800ef6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef9:	e8 c3 fc ff ff       	call   800bc1 <sys_page_alloc>
  800efe:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f01:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f06:	89 d8                	mov    %ebx,%eax
  800f08:	c1 e8 16             	shr    $0x16,%eax
  800f0b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f12:	a8 01                	test   $0x1,%al
  800f14:	0f 84 fc 00 00 00    	je     801016 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f1a:	89 d8                	mov    %ebx,%eax
  800f1c:	c1 e8 0c             	shr    $0xc,%eax
  800f1f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f26:	f6 c2 01             	test   $0x1,%dl
  800f29:	0f 84 e7 00 00 00    	je     801016 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f34:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3b:	f6 c6 04             	test   $0x4,%dh
  800f3e:	74 39                	je     800f79 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f40:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4f:	50                   	push   %eax
  800f50:	56                   	push   %esi
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	6a 00                	push   $0x0
  800f55:	e8 aa fc ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	0f 89 b1 00 00 00    	jns    801016 <fork+0x18e>
		    	panic("sys page map fault %e");
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	68 ec 25 80 00       	push   $0x8025ec
  800f6d:	6a 53                	push   $0x53
  800f6f:	68 ba 25 80 00       	push   $0x8025ba
  800f74:	e8 ed 0e 00 00       	call   801e66 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f79:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f80:	f6 c2 02             	test   $0x2,%dl
  800f83:	75 0c                	jne    800f91 <fork+0x109>
  800f85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8c:	f6 c4 08             	test   $0x8,%ah
  800f8f:	74 5b                	je     800fec <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	68 05 08 00 00       	push   $0x805
  800f99:	56                   	push   %esi
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 61 fc ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  800fa3:	83 c4 20             	add    $0x20,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 14                	jns    800fbe <fork+0x136>
		    	panic("sys page map fault %e");
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	68 ec 25 80 00       	push   $0x8025ec
  800fb2:	6a 5a                	push   $0x5a
  800fb4:	68 ba 25 80 00       	push   $0x8025ba
  800fb9:	e8 a8 0e 00 00       	call   801e66 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	68 05 08 00 00       	push   $0x805
  800fc6:	56                   	push   %esi
  800fc7:	6a 00                	push   $0x0
  800fc9:	56                   	push   %esi
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 33 fc ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	79 3e                	jns    801016 <fork+0x18e>
		    	panic("sys page map fault %e");
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	68 ec 25 80 00       	push   $0x8025ec
  800fe0:	6a 5e                	push   $0x5e
  800fe2:	68 ba 25 80 00       	push   $0x8025ba
  800fe7:	e8 7a 0e 00 00       	call   801e66 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	6a 05                	push   $0x5
  800ff1:	56                   	push   %esi
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	6a 00                	push   $0x0
  800ff6:	e8 09 fc ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  800ffb:	83 c4 20             	add    $0x20,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	79 14                	jns    801016 <fork+0x18e>
		    	panic("sys page map fault %e");
  801002:	83 ec 04             	sub    $0x4,%esp
  801005:	68 ec 25 80 00       	push   $0x8025ec
  80100a:	6a 63                	push   $0x63
  80100c:	68 ba 25 80 00       	push   $0x8025ba
  801011:	e8 50 0e 00 00       	call   801e66 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801016:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801022:	0f 85 de fe ff ff    	jne    800f06 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801028:	a1 08 40 80 00       	mov    0x804008,%eax
  80102d:	8b 40 64             	mov    0x64(%eax),%eax
  801030:	83 ec 08             	sub    $0x8,%esp
  801033:	50                   	push   %eax
  801034:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801037:	57                   	push   %edi
  801038:	e8 cf fc ff ff       	call   800d0c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80103d:	83 c4 08             	add    $0x8,%esp
  801040:	6a 02                	push   $0x2
  801042:	57                   	push   %edi
  801043:	e8 40 fc ff ff       	call   800c88 <sys_env_set_status>
	
	return envid;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80104d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sfork>:

// Challenge!
int
sfork(void)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105b:	68 02 26 80 00       	push   $0x802602
  801060:	68 a1 00 00 00       	push   $0xa1
  801065:	68 ba 25 80 00       	push   $0x8025ba
  80106a:	e8 f7 0d 00 00       	call   801e66 <_panic>

0080106f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	8b 75 08             	mov    0x8(%ebp),%esi
  801077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80107d:	85 c0                	test   %eax,%eax
  80107f:	75 12                	jne    801093 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	68 00 00 c0 ee       	push   $0xeec00000
  801089:	e8 e3 fc ff ff       	call   800d71 <sys_ipc_recv>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	eb 0c                	jmp    80109f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	e8 d5 fc ff ff       	call   800d71 <sys_ipc_recv>
  80109c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80109f:	85 f6                	test   %esi,%esi
  8010a1:	0f 95 c1             	setne  %cl
  8010a4:	85 db                	test   %ebx,%ebx
  8010a6:	0f 95 c2             	setne  %dl
  8010a9:	84 d1                	test   %dl,%cl
  8010ab:	74 09                	je     8010b6 <ipc_recv+0x47>
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	c1 ea 1f             	shr    $0x1f,%edx
  8010b2:	84 d2                	test   %dl,%dl
  8010b4:	75 24                	jne    8010da <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010b6:	85 f6                	test   %esi,%esi
  8010b8:	74 0a                	je     8010c4 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8010ba:	a1 08 40 80 00       	mov    0x804008,%eax
  8010bf:	8b 40 74             	mov    0x74(%eax),%eax
  8010c2:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8010c4:	85 db                	test   %ebx,%ebx
  8010c6:	74 0a                	je     8010d2 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  8010c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010cd:	8b 40 78             	mov    0x78(%eax),%eax
  8010d0:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8010f3:	85 db                	test   %ebx,%ebx
  8010f5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010fa:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8010fd:	ff 75 14             	pushl  0x14(%ebp)
  801100:	53                   	push   %ebx
  801101:	56                   	push   %esi
  801102:	57                   	push   %edi
  801103:	e8 46 fc ff ff       	call   800d4e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801108:	89 c2                	mov    %eax,%edx
  80110a:	c1 ea 1f             	shr    $0x1f,%edx
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	84 d2                	test   %dl,%dl
  801112:	74 17                	je     80112b <ipc_send+0x4a>
  801114:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801117:	74 12                	je     80112b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801119:	50                   	push   %eax
  80111a:	68 18 26 80 00       	push   $0x802618
  80111f:	6a 47                	push   $0x47
  801121:	68 26 26 80 00       	push   $0x802626
  801126:	e8 3b 0d 00 00       	call   801e66 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80112b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80112e:	75 07                	jne    801137 <ipc_send+0x56>
			sys_yield();
  801130:	e8 6d fa ff ff       	call   800ba2 <sys_yield>
  801135:	eb c6                	jmp    8010fd <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801137:	85 c0                	test   %eax,%eax
  801139:	75 c2                	jne    8010fd <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80114e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801151:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801157:	8b 52 50             	mov    0x50(%edx),%edx
  80115a:	39 ca                	cmp    %ecx,%edx
  80115c:	75 0d                	jne    80116b <ipc_find_env+0x28>
			return envs[i].env_id;
  80115e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801161:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801166:	8b 40 48             	mov    0x48(%eax),%eax
  801169:	eb 0f                	jmp    80117a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80116b:	83 c0 01             	add    $0x1,%eax
  80116e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801173:	75 d9                	jne    80114e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801175:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	05 00 00 00 30       	add    $0x30000000,%eax
  801187:	c1 e8 0c             	shr    $0xc,%eax
}
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118f:	8b 45 08             	mov    0x8(%ebp),%eax
  801192:	05 00 00 00 30       	add    $0x30000000,%eax
  801197:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 16             	shr    $0x16,%edx
  8011b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ba:	f6 c2 01             	test   $0x1,%dl
  8011bd:	74 11                	je     8011d0 <fd_alloc+0x2d>
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	c1 ea 0c             	shr    $0xc,%edx
  8011c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	75 09                	jne    8011d9 <fd_alloc+0x36>
			*fd_store = fd;
  8011d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	eb 17                	jmp    8011f0 <fd_alloc+0x4d>
  8011d9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011de:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e3:	75 c9                	jne    8011ae <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011eb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f8:	83 f8 1f             	cmp    $0x1f,%eax
  8011fb:	77 36                	ja     801233 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fd:	c1 e0 0c             	shl    $0xc,%eax
  801200:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 16             	shr    $0x16,%edx
  80120a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 24                	je     80123a <fd_lookup+0x48>
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 0c             	shr    $0xc,%edx
  80121b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 1a                	je     801241 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122a:	89 02                	mov    %eax,(%edx)
	return 0;
  80122c:	b8 00 00 00 00       	mov    $0x0,%eax
  801231:	eb 13                	jmp    801246 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb 0c                	jmp    801246 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123f:	eb 05                	jmp    801246 <fd_lookup+0x54>
  801241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801251:	ba ac 26 80 00       	mov    $0x8026ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801256:	eb 13                	jmp    80126b <dev_lookup+0x23>
  801258:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125b:	39 08                	cmp    %ecx,(%eax)
  80125d:	75 0c                	jne    80126b <dev_lookup+0x23>
			*dev = devtab[i];
  80125f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801262:	89 01                	mov    %eax,(%ecx)
			return 0;
  801264:	b8 00 00 00 00       	mov    $0x0,%eax
  801269:	eb 2e                	jmp    801299 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126b:	8b 02                	mov    (%edx),%eax
  80126d:	85 c0                	test   %eax,%eax
  80126f:	75 e7                	jne    801258 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801271:	a1 08 40 80 00       	mov    0x804008,%eax
  801276:	8b 40 48             	mov    0x48(%eax),%eax
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	51                   	push   %ecx
  80127d:	50                   	push   %eax
  80127e:	68 30 26 80 00       	push   $0x802630
  801283:	e8 b1 ef ff ff       	call   800239 <cprintf>
	*dev = 0;
  801288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 10             	sub    $0x10,%esp
  8012a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b3:	c1 e8 0c             	shr    $0xc,%eax
  8012b6:	50                   	push   %eax
  8012b7:	e8 36 ff ff ff       	call   8011f2 <fd_lookup>
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 05                	js     8012c8 <fd_close+0x2d>
	    || fd != fd2)
  8012c3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c6:	74 0c                	je     8012d4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c8:	84 db                	test   %bl,%bl
  8012ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cf:	0f 44 c2             	cmove  %edx,%eax
  8012d2:	eb 41                	jmp    801315 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	ff 36                	pushl  (%esi)
  8012dd:	e8 66 ff ff ff       	call   801248 <dev_lookup>
  8012e2:	89 c3                	mov    %eax,%ebx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 1a                	js     801305 <fd_close+0x6a>
		if (dev->dev_close)
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	74 0b                	je     801305 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	56                   	push   %esi
  8012fe:	ff d0                	call   *%eax
  801300:	89 c3                	mov    %eax,%ebx
  801302:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	56                   	push   %esi
  801309:	6a 00                	push   $0x0
  80130b:	e8 36 f9 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	89 d8                	mov    %ebx,%eax
}
  801315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	pushl  0x8(%ebp)
  801329:	e8 c4 fe ff ff       	call   8011f2 <fd_lookup>
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 10                	js     801345 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	6a 01                	push   $0x1
  80133a:	ff 75 f4             	pushl  -0xc(%ebp)
  80133d:	e8 59 ff ff ff       	call   80129b <fd_close>
  801342:	83 c4 10             	add    $0x10,%esp
}
  801345:	c9                   	leave  
  801346:	c3                   	ret    

00801347 <close_all>:

void
close_all(void)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	53                   	push   %ebx
  801357:	e8 c0 ff ff ff       	call   80131c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135c:	83 c3 01             	add    $0x1,%ebx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	83 fb 20             	cmp    $0x20,%ebx
  801365:	75 ec                	jne    801353 <close_all+0xc>
		close(i);
}
  801367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	83 ec 2c             	sub    $0x2c,%esp
  801375:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801378:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 75 08             	pushl  0x8(%ebp)
  80137f:	e8 6e fe ff ff       	call   8011f2 <fd_lookup>
  801384:	83 c4 08             	add    $0x8,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	0f 88 c1 00 00 00    	js     801450 <dup+0xe4>
		return r;
	close(newfdnum);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	56                   	push   %esi
  801393:	e8 84 ff ff ff       	call   80131c <close>

	newfd = INDEX2FD(newfdnum);
  801398:	89 f3                	mov    %esi,%ebx
  80139a:	c1 e3 0c             	shl    $0xc,%ebx
  80139d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a3:	83 c4 04             	add    $0x4,%esp
  8013a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a9:	e8 de fd ff ff       	call   80118c <fd2data>
  8013ae:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b0:	89 1c 24             	mov    %ebx,(%esp)
  8013b3:	e8 d4 fd ff ff       	call   80118c <fd2data>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013be:	89 f8                	mov    %edi,%eax
  8013c0:	c1 e8 16             	shr    $0x16,%eax
  8013c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ca:	a8 01                	test   $0x1,%al
  8013cc:	74 37                	je     801405 <dup+0x99>
  8013ce:	89 f8                	mov    %edi,%eax
  8013d0:	c1 e8 0c             	shr    $0xc,%eax
  8013d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013da:	f6 c2 01             	test   $0x1,%dl
  8013dd:	74 26                	je     801405 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f2:	6a 00                	push   $0x0
  8013f4:	57                   	push   %edi
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 08 f8 ff ff       	call   800c04 <sys_page_map>
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	83 c4 20             	add    $0x20,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 2e                	js     801433 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801408:	89 d0                	mov    %edx,%eax
  80140a:	c1 e8 0c             	shr    $0xc,%eax
  80140d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	25 07 0e 00 00       	and    $0xe07,%eax
  80141c:	50                   	push   %eax
  80141d:	53                   	push   %ebx
  80141e:	6a 00                	push   $0x0
  801420:	52                   	push   %edx
  801421:	6a 00                	push   $0x0
  801423:	e8 dc f7 ff ff       	call   800c04 <sys_page_map>
  801428:	89 c7                	mov    %eax,%edi
  80142a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142f:	85 ff                	test   %edi,%edi
  801431:	79 1d                	jns    801450 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	53                   	push   %ebx
  801437:	6a 00                	push   $0x0
  801439:	e8 08 f8 ff ff       	call   800c46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143e:	83 c4 08             	add    $0x8,%esp
  801441:	ff 75 d4             	pushl  -0x2c(%ebp)
  801444:	6a 00                	push   $0x0
  801446:	e8 fb f7 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 f8                	mov    %edi,%eax
}
  801450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801453:	5b                   	pop    %ebx
  801454:	5e                   	pop    %esi
  801455:	5f                   	pop    %edi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 14             	sub    $0x14,%esp
  80145f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	53                   	push   %ebx
  801467:	e8 86 fd ff ff       	call   8011f2 <fd_lookup>
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	89 c2                	mov    %eax,%edx
  801471:	85 c0                	test   %eax,%eax
  801473:	78 6d                	js     8014e2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147f:	ff 30                	pushl  (%eax)
  801481:	e8 c2 fd ff ff       	call   801248 <dev_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 4c                	js     8014d9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801490:	8b 42 08             	mov    0x8(%edx),%eax
  801493:	83 e0 03             	and    $0x3,%eax
  801496:	83 f8 01             	cmp    $0x1,%eax
  801499:	75 21                	jne    8014bc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149b:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a0:	8b 40 48             	mov    0x48(%eax),%eax
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	50                   	push   %eax
  8014a8:	68 71 26 80 00       	push   $0x802671
  8014ad:	e8 87 ed ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ba:	eb 26                	jmp    8014e2 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bf:	8b 40 08             	mov    0x8(%eax),%eax
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	74 17                	je     8014dd <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014c6:	83 ec 04             	sub    $0x4,%esp
  8014c9:	ff 75 10             	pushl  0x10(%ebp)
  8014cc:	ff 75 0c             	pushl  0xc(%ebp)
  8014cf:	52                   	push   %edx
  8014d0:	ff d0                	call   *%eax
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	eb 09                	jmp    8014e2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	eb 05                	jmp    8014e2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014e2:	89 d0                	mov    %edx,%eax
  8014e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	57                   	push   %edi
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fd:	eb 21                	jmp    801520 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	89 f0                	mov    %esi,%eax
  801504:	29 d8                	sub    %ebx,%eax
  801506:	50                   	push   %eax
  801507:	89 d8                	mov    %ebx,%eax
  801509:	03 45 0c             	add    0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	57                   	push   %edi
  80150e:	e8 45 ff ff ff       	call   801458 <read>
		if (m < 0)
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 10                	js     80152a <readn+0x41>
			return m;
		if (m == 0)
  80151a:	85 c0                	test   %eax,%eax
  80151c:	74 0a                	je     801528 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151e:	01 c3                	add    %eax,%ebx
  801520:	39 f3                	cmp    %esi,%ebx
  801522:	72 db                	jb     8014ff <readn+0x16>
  801524:	89 d8                	mov    %ebx,%eax
  801526:	eb 02                	jmp    80152a <readn+0x41>
  801528:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5f                   	pop    %edi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	53                   	push   %ebx
  801536:	83 ec 14             	sub    $0x14,%esp
  801539:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	53                   	push   %ebx
  801541:	e8 ac fc ff ff       	call   8011f2 <fd_lookup>
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	89 c2                	mov    %eax,%edx
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 68                	js     8015b7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	ff 30                	pushl  (%eax)
  80155b:	e8 e8 fc ff ff       	call   801248 <dev_lookup>
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 47                	js     8015ae <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156e:	75 21                	jne    801591 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801570:	a1 08 40 80 00       	mov    0x804008,%eax
  801575:	8b 40 48             	mov    0x48(%eax),%eax
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	53                   	push   %ebx
  80157c:	50                   	push   %eax
  80157d:	68 8d 26 80 00       	push   $0x80268d
  801582:	e8 b2 ec ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158f:	eb 26                	jmp    8015b7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801591:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801594:	8b 52 0c             	mov    0xc(%edx),%edx
  801597:	85 d2                	test   %edx,%edx
  801599:	74 17                	je     8015b2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	ff 75 10             	pushl  0x10(%ebp)
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	50                   	push   %eax
  8015a5:	ff d2                	call   *%edx
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	eb 09                	jmp    8015b7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	eb 05                	jmp    8015b7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b7:	89 d0                	mov    %edx,%eax
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <seek>:

int
seek(int fdnum, off_t offset)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 22 fc ff ff       	call   8011f2 <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 0e                	js     8015e5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015dd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	53                   	push   %ebx
  8015eb:	83 ec 14             	sub    $0x14,%esp
  8015ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	53                   	push   %ebx
  8015f6:	e8 f7 fb ff ff       	call   8011f2 <fd_lookup>
  8015fb:	83 c4 08             	add    $0x8,%esp
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	85 c0                	test   %eax,%eax
  801602:	78 65                	js     801669 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	ff 30                	pushl  (%eax)
  801610:	e8 33 fc ff ff       	call   801248 <dev_lookup>
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 44                	js     801660 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801623:	75 21                	jne    801646 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801625:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162a:	8b 40 48             	mov    0x48(%eax),%eax
  80162d:	83 ec 04             	sub    $0x4,%esp
  801630:	53                   	push   %ebx
  801631:	50                   	push   %eax
  801632:	68 50 26 80 00       	push   $0x802650
  801637:	e8 fd eb ff ff       	call   800239 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801644:	eb 23                	jmp    801669 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801646:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801649:	8b 52 18             	mov    0x18(%edx),%edx
  80164c:	85 d2                	test   %edx,%edx
  80164e:	74 14                	je     801664 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	ff 75 0c             	pushl  0xc(%ebp)
  801656:	50                   	push   %eax
  801657:	ff d2                	call   *%edx
  801659:	89 c2                	mov    %eax,%edx
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	eb 09                	jmp    801669 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	89 c2                	mov    %eax,%edx
  801662:	eb 05                	jmp    801669 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801664:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801669:	89 d0                	mov    %edx,%eax
  80166b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	53                   	push   %ebx
  801674:	83 ec 14             	sub    $0x14,%esp
  801677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 6c fb ff ff       	call   8011f2 <fd_lookup>
  801686:	83 c4 08             	add    $0x8,%esp
  801689:	89 c2                	mov    %eax,%edx
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 58                	js     8016e7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801699:	ff 30                	pushl  (%eax)
  80169b:	e8 a8 fb ff ff       	call   801248 <dev_lookup>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 37                	js     8016de <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ae:	74 32                	je     8016e2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ba:	00 00 00 
	stat->st_isdir = 0;
  8016bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c4:	00 00 00 
	stat->st_dev = dev;
  8016c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d4:	ff 50 14             	call   *0x14(%eax)
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	eb 09                	jmp    8016e7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	eb 05                	jmp    8016e7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e7:	89 d0                	mov    %edx,%eax
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	6a 00                	push   $0x0
  8016f8:	ff 75 08             	pushl  0x8(%ebp)
  8016fb:	e8 e3 01 00 00       	call   8018e3 <open>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 1b                	js     801724 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	e8 5b ff ff ff       	call   801670 <fstat>
  801715:	89 c6                	mov    %eax,%esi
	close(fd);
  801717:	89 1c 24             	mov    %ebx,(%esp)
  80171a:	e8 fd fb ff ff       	call   80131c <close>
	return r;
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	89 f0                	mov    %esi,%eax
}
  801724:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	89 c6                	mov    %eax,%esi
  801732:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801734:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173b:	75 12                	jne    80174f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	6a 01                	push   $0x1
  801742:	e8 fc f9 ff ff       	call   801143 <ipc_find_env>
  801747:	a3 00 40 80 00       	mov    %eax,0x804000
  80174c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174f:	6a 07                	push   $0x7
  801751:	68 00 50 80 00       	push   $0x805000
  801756:	56                   	push   %esi
  801757:	ff 35 00 40 80 00    	pushl  0x804000
  80175d:	e8 7f f9 ff ff       	call   8010e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801762:	83 c4 0c             	add    $0xc,%esp
  801765:	6a 00                	push   $0x0
  801767:	53                   	push   %ebx
  801768:	6a 00                	push   $0x0
  80176a:	e8 00 f9 ff ff       	call   80106f <ipc_recv>
}
  80176f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8b 40 0c             	mov    0xc(%eax),%eax
  801782:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801787:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 02 00 00 00       	mov    $0x2,%eax
  801799:	e8 8d ff ff ff       	call   80172b <fsipc>
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ac:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bb:	e8 6b ff ff ff       	call   80172b <fsipc>
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 04             	sub    $0x4,%esp
  8017c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e1:	e8 45 ff ff ff       	call   80172b <fsipc>
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 2c                	js     801816 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	68 00 50 80 00       	push   $0x805000
  8017f2:	53                   	push   %ebx
  8017f3:	e8 c6 ef ff ff       	call   8007be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f8:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801803:	a1 84 50 80 00       	mov    0x805084,%eax
  801808:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801824:	8b 55 08             	mov    0x8(%ebp),%edx
  801827:	8b 52 0c             	mov    0xc(%edx),%edx
  80182a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801830:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801835:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183a:	0f 47 c2             	cmova  %edx,%eax
  80183d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801842:	50                   	push   %eax
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	68 08 50 80 00       	push   $0x805008
  80184b:	e8 00 f1 ff ff       	call   800950 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 04 00 00 00       	mov    $0x4,%eax
  80185a:	e8 cc fe ff ff       	call   80172b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801874:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	b8 03 00 00 00       	mov    $0x3,%eax
  801884:	e8 a2 fe ff ff       	call   80172b <fsipc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 4b                	js     8018da <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188f:	39 c6                	cmp    %eax,%esi
  801891:	73 16                	jae    8018a9 <devfile_read+0x48>
  801893:	68 bc 26 80 00       	push   $0x8026bc
  801898:	68 c3 26 80 00       	push   $0x8026c3
  80189d:	6a 7c                	push   $0x7c
  80189f:	68 d8 26 80 00       	push   $0x8026d8
  8018a4:	e8 bd 05 00 00       	call   801e66 <_panic>
	assert(r <= PGSIZE);
  8018a9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ae:	7e 16                	jle    8018c6 <devfile_read+0x65>
  8018b0:	68 e3 26 80 00       	push   $0x8026e3
  8018b5:	68 c3 26 80 00       	push   $0x8026c3
  8018ba:	6a 7d                	push   $0x7d
  8018bc:	68 d8 26 80 00       	push   $0x8026d8
  8018c1:	e8 a0 05 00 00       	call   801e66 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	50                   	push   %eax
  8018ca:	68 00 50 80 00       	push   $0x805000
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	e8 79 f0 ff ff       	call   800950 <memmove>
	return r;
  8018d7:	83 c4 10             	add    $0x10,%esp
}
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	83 ec 20             	sub    $0x20,%esp
  8018ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ed:	53                   	push   %ebx
  8018ee:	e8 92 ee ff ff       	call   800785 <strlen>
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fb:	7f 67                	jg     801964 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fd:	83 ec 0c             	sub    $0xc,%esp
  801900:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801903:	50                   	push   %eax
  801904:	e8 9a f8 ff ff       	call   8011a3 <fd_alloc>
  801909:	83 c4 10             	add    $0x10,%esp
		return r;
  80190c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 57                	js     801969 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	53                   	push   %ebx
  801916:	68 00 50 80 00       	push   $0x805000
  80191b:	e8 9e ee ff ff       	call   8007be <strcpy>
	fsipcbuf.open.req_omode = mode;
  801920:	8b 45 0c             	mov    0xc(%ebp),%eax
  801923:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801928:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192b:	b8 01 00 00 00       	mov    $0x1,%eax
  801930:	e8 f6 fd ff ff       	call   80172b <fsipc>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	79 14                	jns    801952 <open+0x6f>
		fd_close(fd, 0);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	6a 00                	push   $0x0
  801943:	ff 75 f4             	pushl  -0xc(%ebp)
  801946:	e8 50 f9 ff ff       	call   80129b <fd_close>
		return r;
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	89 da                	mov    %ebx,%edx
  801950:	eb 17                	jmp    801969 <open+0x86>
	}

	return fd2num(fd);
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 1f f8 ff ff       	call   80117c <fd2num>
  80195d:	89 c2                	mov    %eax,%edx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb 05                	jmp    801969 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801964:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801969:	89 d0                	mov    %edx,%eax
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	b8 08 00 00 00       	mov    $0x8,%eax
  801980:	e8 a6 fd ff ff       	call   80172b <fsipc>
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
  80198c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	ff 75 08             	pushl  0x8(%ebp)
  801995:	e8 f2 f7 ff ff       	call   80118c <fd2data>
  80199a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199c:	83 c4 08             	add    $0x8,%esp
  80199f:	68 ef 26 80 00       	push   $0x8026ef
  8019a4:	53                   	push   %ebx
  8019a5:	e8 14 ee ff ff       	call   8007be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019aa:	8b 46 04             	mov    0x4(%esi),%eax
  8019ad:	2b 06                	sub    (%esi),%eax
  8019af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bc:	00 00 00 
	stat->st_dev = &devpipe;
  8019bf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c6:	30 80 00 
	return 0;
}
  8019c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019df:	53                   	push   %ebx
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 5f f2 ff ff       	call   800c46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e7:	89 1c 24             	mov    %ebx,(%esp)
  8019ea:	e8 9d f7 ff ff       	call   80118c <fd2data>
  8019ef:	83 c4 08             	add    $0x8,%esp
  8019f2:	50                   	push   %eax
  8019f3:	6a 00                	push   $0x0
  8019f5:	e8 4c f2 ff ff       	call   800c46 <sys_page_unmap>
}
  8019fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	57                   	push   %edi
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	83 ec 1c             	sub    $0x1c,%esp
  801a08:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a0d:	a1 08 40 80 00       	mov    0x804008,%eax
  801a12:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1b:	e8 1b 05 00 00       	call   801f3b <pageref>
  801a20:	89 c3                	mov    %eax,%ebx
  801a22:	89 3c 24             	mov    %edi,(%esp)
  801a25:	e8 11 05 00 00       	call   801f3b <pageref>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	39 c3                	cmp    %eax,%ebx
  801a2f:	0f 94 c1             	sete   %cl
  801a32:	0f b6 c9             	movzbl %cl,%ecx
  801a35:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a38:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a3e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a41:	39 ce                	cmp    %ecx,%esi
  801a43:	74 1b                	je     801a60 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a45:	39 c3                	cmp    %eax,%ebx
  801a47:	75 c4                	jne    801a0d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a49:	8b 42 58             	mov    0x58(%edx),%eax
  801a4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a4f:	50                   	push   %eax
  801a50:	56                   	push   %esi
  801a51:	68 f6 26 80 00       	push   $0x8026f6
  801a56:	e8 de e7 ff ff       	call   800239 <cprintf>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb ad                	jmp    801a0d <_pipeisclosed+0xe>
	}
}
  801a60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 28             	sub    $0x28,%esp
  801a74:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a77:	56                   	push   %esi
  801a78:	e8 0f f7 ff ff       	call   80118c <fd2data>
  801a7d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	bf 00 00 00 00       	mov    $0x0,%edi
  801a87:	eb 4b                	jmp    801ad4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a89:	89 da                	mov    %ebx,%edx
  801a8b:	89 f0                	mov    %esi,%eax
  801a8d:	e8 6d ff ff ff       	call   8019ff <_pipeisclosed>
  801a92:	85 c0                	test   %eax,%eax
  801a94:	75 48                	jne    801ade <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a96:	e8 07 f1 ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9e:	8b 0b                	mov    (%ebx),%ecx
  801aa0:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa3:	39 d0                	cmp    %edx,%eax
  801aa5:	73 e2                	jae    801a89 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aaa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab1:	89 c2                	mov    %eax,%edx
  801ab3:	c1 fa 1f             	sar    $0x1f,%edx
  801ab6:	89 d1                	mov    %edx,%ecx
  801ab8:	c1 e9 1b             	shr    $0x1b,%ecx
  801abb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801abe:	83 e2 1f             	and    $0x1f,%edx
  801ac1:	29 ca                	sub    %ecx,%edx
  801ac3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ac7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801acb:	83 c0 01             	add    $0x1,%eax
  801ace:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad1:	83 c7 01             	add    $0x1,%edi
  801ad4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad7:	75 c2                	jne    801a9b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ad9:	8b 45 10             	mov    0x10(%ebp),%eax
  801adc:	eb 05                	jmp    801ae3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	57                   	push   %edi
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	83 ec 18             	sub    $0x18,%esp
  801af4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801af7:	57                   	push   %edi
  801af8:	e8 8f f6 ff ff       	call   80118c <fd2data>
  801afd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b07:	eb 3d                	jmp    801b46 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b09:	85 db                	test   %ebx,%ebx
  801b0b:	74 04                	je     801b11 <devpipe_read+0x26>
				return i;
  801b0d:	89 d8                	mov    %ebx,%eax
  801b0f:	eb 44                	jmp    801b55 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b11:	89 f2                	mov    %esi,%edx
  801b13:	89 f8                	mov    %edi,%eax
  801b15:	e8 e5 fe ff ff       	call   8019ff <_pipeisclosed>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	75 32                	jne    801b50 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b1e:	e8 7f f0 ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b23:	8b 06                	mov    (%esi),%eax
  801b25:	3b 46 04             	cmp    0x4(%esi),%eax
  801b28:	74 df                	je     801b09 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b2a:	99                   	cltd   
  801b2b:	c1 ea 1b             	shr    $0x1b,%edx
  801b2e:	01 d0                	add    %edx,%eax
  801b30:	83 e0 1f             	and    $0x1f,%eax
  801b33:	29 d0                	sub    %edx,%eax
  801b35:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b40:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b43:	83 c3 01             	add    $0x1,%ebx
  801b46:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b49:	75 d8                	jne    801b23 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4e:	eb 05                	jmp    801b55 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5e                   	pop    %esi
  801b5a:	5f                   	pop    %edi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	56                   	push   %esi
  801b61:	53                   	push   %ebx
  801b62:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	e8 35 f6 ff ff       	call   8011a3 <fd_alloc>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	0f 88 2c 01 00 00    	js     801ca7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	68 07 04 00 00       	push   $0x407
  801b83:	ff 75 f4             	pushl  -0xc(%ebp)
  801b86:	6a 00                	push   $0x0
  801b88:	e8 34 f0 ff ff       	call   800bc1 <sys_page_alloc>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	89 c2                	mov    %eax,%edx
  801b92:	85 c0                	test   %eax,%eax
  801b94:	0f 88 0d 01 00 00    	js     801ca7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	e8 fd f5 ff ff       	call   8011a3 <fd_alloc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 88 e2 00 00 00    	js     801c95 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb3:	83 ec 04             	sub    $0x4,%esp
  801bb6:	68 07 04 00 00       	push   $0x407
  801bbb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 fc ef ff ff       	call   800bc1 <sys_page_alloc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	0f 88 c3 00 00 00    	js     801c95 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd8:	e8 af f5 ff ff       	call   80118c <fd2data>
  801bdd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdf:	83 c4 0c             	add    $0xc,%esp
  801be2:	68 07 04 00 00       	push   $0x407
  801be7:	50                   	push   %eax
  801be8:	6a 00                	push   $0x0
  801bea:	e8 d2 ef ff ff       	call   800bc1 <sys_page_alloc>
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	0f 88 89 00 00 00    	js     801c85 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfc:	83 ec 0c             	sub    $0xc,%esp
  801bff:	ff 75 f0             	pushl  -0x10(%ebp)
  801c02:	e8 85 f5 ff ff       	call   80118c <fd2data>
  801c07:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c0e:	50                   	push   %eax
  801c0f:	6a 00                	push   $0x0
  801c11:	56                   	push   %esi
  801c12:	6a 00                	push   $0x0
  801c14:	e8 eb ef ff ff       	call   800c04 <sys_page_map>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	83 c4 20             	add    $0x20,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 55                	js     801c77 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c30:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c37:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c40:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c45:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c52:	e8 25 f5 ff ff       	call   80117c <fd2num>
  801c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5c:	83 c4 04             	add    $0x4,%esp
  801c5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c62:	e8 15 f5 ff ff       	call   80117c <fd2num>
  801c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	ba 00 00 00 00       	mov    $0x0,%edx
  801c75:	eb 30                	jmp    801ca7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c77:	83 ec 08             	sub    $0x8,%esp
  801c7a:	56                   	push   %esi
  801c7b:	6a 00                	push   $0x0
  801c7d:	e8 c4 ef ff ff       	call   800c46 <sys_page_unmap>
  801c82:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 b4 ef ff ff       	call   800c46 <sys_page_unmap>
  801c92:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 a4 ef ff ff       	call   800c46 <sys_page_unmap>
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ca7:	89 d0                	mov    %edx,%eax
  801ca9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	ff 75 08             	pushl  0x8(%ebp)
  801cbd:	e8 30 f5 ff ff       	call   8011f2 <fd_lookup>
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 18                	js     801ce1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccf:	e8 b8 f4 ff ff       	call   80118c <fd2data>
	return _pipeisclosed(fd, p);
  801cd4:	89 c2                	mov    %eax,%edx
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	e8 21 fd ff ff       	call   8019ff <_pipeisclosed>
  801cde:	83 c4 10             	add    $0x10,%esp
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf3:	68 0e 27 80 00       	push   $0x80270e
  801cf8:	ff 75 0c             	pushl  0xc(%ebp)
  801cfb:	e8 be ea ff ff       	call   8007be <strcpy>
	return 0;
}
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	57                   	push   %edi
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
  801d0d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d13:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d18:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1e:	eb 2d                	jmp    801d4d <devcons_write+0x46>
		m = n - tot;
  801d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d23:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d25:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d28:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d2d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	53                   	push   %ebx
  801d34:	03 45 0c             	add    0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	57                   	push   %edi
  801d39:	e8 12 ec ff ff       	call   800950 <memmove>
		sys_cputs(buf, m);
  801d3e:	83 c4 08             	add    $0x8,%esp
  801d41:	53                   	push   %ebx
  801d42:	57                   	push   %edi
  801d43:	e8 bd ed ff ff       	call   800b05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d48:	01 de                	add    %ebx,%esi
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d52:	72 cc                	jb     801d20 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6b:	74 2a                	je     801d97 <devcons_read+0x3b>
  801d6d:	eb 05                	jmp    801d74 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d6f:	e8 2e ee ff ff       	call   800ba2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d74:	e8 aa ed ff ff       	call   800b23 <sys_cgetc>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	74 f2                	je     801d6f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	78 16                	js     801d97 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d81:	83 f8 04             	cmp    $0x4,%eax
  801d84:	74 0c                	je     801d92 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d89:	88 02                	mov    %al,(%edx)
	return 1;
  801d8b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d90:	eb 05                	jmp    801d97 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da5:	6a 01                	push   $0x1
  801da7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	e8 55 ed ff ff       	call   800b05 <sys_cputs>
}
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <getchar>:

int
getchar(void)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbb:	6a 01                	push   $0x1
  801dbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc0:	50                   	push   %eax
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 90 f6 ff ff       	call   801458 <read>
	if (r < 0)
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 0f                	js     801dde <getchar+0x29>
		return r;
	if (r < 1)
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	7e 06                	jle    801dd9 <getchar+0x24>
		return -E_EOF;
	return c;
  801dd3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dd7:	eb 05                	jmp    801dde <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dd9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	ff 75 08             	pushl  0x8(%ebp)
  801ded:	e8 00 f4 ff ff       	call   8011f2 <fd_lookup>
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 11                	js     801e0a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e02:	39 10                	cmp    %edx,(%eax)
  801e04:	0f 94 c0             	sete   %al
  801e07:	0f b6 c0             	movzbl %al,%eax
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <opencons>:

int
opencons(void)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	e8 88 f3 ff ff       	call   8011a3 <fd_alloc>
  801e1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e20:	85 c0                	test   %eax,%eax
  801e22:	78 3e                	js     801e62 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e24:	83 ec 04             	sub    $0x4,%esp
  801e27:	68 07 04 00 00       	push   $0x407
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 8b ed ff ff       	call   800bc1 <sys_page_alloc>
  801e36:	83 c4 10             	add    $0x10,%esp
		return r;
  801e39:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 23                	js     801e62 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e3f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e48:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e54:	83 ec 0c             	sub    $0xc,%esp
  801e57:	50                   	push   %eax
  801e58:	e8 1f f3 ff ff       	call   80117c <fd2num>
  801e5d:	89 c2                	mov    %eax,%edx
  801e5f:	83 c4 10             	add    $0x10,%esp
}
  801e62:	89 d0                	mov    %edx,%eax
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	56                   	push   %esi
  801e6a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e6e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e74:	e8 0a ed ff ff       	call   800b83 <sys_getenvid>
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	ff 75 0c             	pushl  0xc(%ebp)
  801e7f:	ff 75 08             	pushl  0x8(%ebp)
  801e82:	56                   	push   %esi
  801e83:	50                   	push   %eax
  801e84:	68 1c 27 80 00       	push   $0x80271c
  801e89:	e8 ab e3 ff ff       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e8e:	83 c4 18             	add    $0x18,%esp
  801e91:	53                   	push   %ebx
  801e92:	ff 75 10             	pushl  0x10(%ebp)
  801e95:	e8 4e e3 ff ff       	call   8001e8 <vcprintf>
	cprintf("\n");
  801e9a:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  801ea1:	e8 93 e3 ff ff       	call   800239 <cprintf>
  801ea6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ea9:	cc                   	int3   
  801eaa:	eb fd                	jmp    801ea9 <_panic+0x43>

00801eac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb9:	75 2a                	jne    801ee5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	6a 07                	push   $0x7
  801ec0:	68 00 f0 bf ee       	push   $0xeebff000
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 f5 ec ff ff       	call   800bc1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	79 12                	jns    801ee5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ed3:	50                   	push   %eax
  801ed4:	68 40 27 80 00       	push   $0x802740
  801ed9:	6a 23                	push   $0x23
  801edb:	68 44 27 80 00       	push   $0x802744
  801ee0:	e8 81 ff ff ff       	call   801e66 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	68 17 1f 80 00       	push   $0x801f17
  801ef5:	6a 00                	push   $0x0
  801ef7:	e8 10 ee ff ff       	call   800d0c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	79 12                	jns    801f15 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f03:	50                   	push   %eax
  801f04:	68 40 27 80 00       	push   $0x802740
  801f09:	6a 2c                	push   $0x2c
  801f0b:	68 44 27 80 00       	push   $0x802744
  801f10:	e8 51 ff ff ff       	call   801e66 <_panic>
	}
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f17:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f18:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f1d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f1f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f22:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f26:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f2b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f2f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f31:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f34:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f35:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f38:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f39:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f3a:	c3                   	ret    

00801f3b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f41:	89 d0                	mov    %edx,%eax
  801f43:	c1 e8 16             	shr    $0x16,%eax
  801f46:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f52:	f6 c1 01             	test   $0x1,%cl
  801f55:	74 1d                	je     801f74 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f57:	c1 ea 0c             	shr    $0xc,%edx
  801f5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f61:	f6 c2 01             	test   $0x1,%dl
  801f64:	74 0e                	je     801f74 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f66:	c1 ea 0c             	shr    $0xc,%edx
  801f69:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f70:	ef 
  801f71:	0f b7 c0             	movzwl %ax,%eax
}
  801f74:	5d                   	pop    %ebp
  801f75:	c3                   	ret    
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
