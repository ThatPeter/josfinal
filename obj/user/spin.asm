
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 21 80 00       	push   $0x8021c0
  80003f:	e8 ac 01 00 00       	call   8001f0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 f6 0d 00 00       	call   800e3f <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 22 80 00       	push   $0x802238
  800058:	e8 93 01 00 00       	call   8001f0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 21 80 00       	push   $0x8021e8
  80006c:	e8 7f 01 00 00       	call   8001f0 <cprintf>
	sys_yield();
  800071:	e8 e3 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800076:	e8 de 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80007b:	e8 d9 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800080:	e8 d4 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800085:	e8 cf 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008a:	e8 ca 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008f:	e8 c5 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800094:	e8 c0 0a 00 00       	call   800b59 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 22 80 00 	movl   $0x802210,(%esp)
  8000a0:	e8 4b 01 00 00       	call   8001f0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 4c 0a 00 00       	call   800af9 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
  8000bb:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000be:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000c5:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000c8:	e8 6d 0a 00 00       	call   800b3a <sys_getenvid>
  8000cd:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000d3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000d8:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000dd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000e2:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000e5:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000eb:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000ee:	39 c8                	cmp    %ecx,%eax
  8000f0:	0f 44 fb             	cmove  %ebx,%edi
  8000f3:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000f8:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000fb:	83 c2 01             	add    $0x1,%edx
  8000fe:	83 c3 7c             	add    $0x7c,%ebx
  800101:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800107:	75 d9                	jne    8000e2 <libmain+0x2d>
  800109:	89 f0                	mov    %esi,%eax
  80010b:	84 c0                	test   %al,%al
  80010d:	74 06                	je     800115 <libmain+0x60>
  80010f:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800115:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800119:	7e 0a                	jle    800125 <libmain+0x70>
		binaryname = argv[0];
  80011b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011e:	8b 00                	mov    (%eax),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	ff 75 0c             	pushl  0xc(%ebp)
  80012b:	ff 75 08             	pushl  0x8(%ebp)
  80012e:	e8 00 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800133:	e8 0b 00 00 00       	call   800143 <exit>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800149:	e8 a3 10 00 00       	call   8011f1 <close_all>
	sys_env_destroy(0);
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	6a 00                	push   $0x0
  800153:	e8 a1 09 00 00       	call   800af9 <sys_env_destroy>
}
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	53                   	push   %ebx
  800161:	83 ec 04             	sub    $0x4,%esp
  800164:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800167:	8b 13                	mov    (%ebx),%edx
  800169:	8d 42 01             	lea    0x1(%edx),%eax
  80016c:	89 03                	mov    %eax,(%ebx)
  80016e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800171:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800175:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017a:	75 1a                	jne    800196 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	68 ff 00 00 00       	push   $0xff
  800184:	8d 43 08             	lea    0x8(%ebx),%eax
  800187:	50                   	push   %eax
  800188:	e8 2f 09 00 00       	call   800abc <sys_cputs>
		b->idx = 0;
  80018d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800193:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800196:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5d 01 80 00       	push   $0x80015d
  8001ce:	e8 54 01 00 00       	call   800327 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 d4 08 00 00       	call   800abc <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800228:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022b:	39 d3                	cmp    %edx,%ebx
  80022d:	72 05                	jb     800234 <printnum+0x30>
  80022f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800232:	77 45                	ja     800279 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	8b 45 14             	mov    0x14(%ebp),%eax
  80023d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800240:	53                   	push   %ebx
  800241:	ff 75 10             	pushl  0x10(%ebp)
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	ff 75 dc             	pushl  -0x24(%ebp)
  800250:	ff 75 d8             	pushl  -0x28(%ebp)
  800253:	e8 d8 1c 00 00       	call   801f30 <__udivdi3>
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	89 f2                	mov    %esi,%edx
  80025f:	89 f8                	mov    %edi,%eax
  800261:	e8 9e ff ff ff       	call   800204 <printnum>
  800266:	83 c4 20             	add    $0x20,%esp
  800269:	eb 18                	jmp    800283 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	56                   	push   %esi
  80026f:	ff 75 18             	pushl  0x18(%ebp)
  800272:	ff d7                	call   *%edi
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	eb 03                	jmp    80027c <printnum+0x78>
  800279:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	85 db                	test   %ebx,%ebx
  800281:	7f e8                	jg     80026b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	83 ec 04             	sub    $0x4,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 c5 1d 00 00       	call   802060 <__umoddi3>
  80029b:	83 c4 14             	add    $0x14,%esp
  80029e:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  8002a5:	50                   	push   %eax
  8002a6:	ff d7                	call   *%edi
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b6:	83 fa 01             	cmp    $0x1,%edx
  8002b9:	7e 0e                	jle    8002c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	8b 52 04             	mov    0x4(%edx),%edx
  8002c7:	eb 22                	jmp    8002eb <getuint+0x38>
	else if (lflag)
  8002c9:	85 d2                	test   %edx,%edx
  8002cb:	74 10                	je     8002dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d2:	89 08                	mov    %ecx,(%eax)
  8002d4:	8b 02                	mov    (%edx),%eax
  8002d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002db:	eb 0e                	jmp    8002eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fc:	73 0a                	jae    800308 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fe:	8d 4a 01             	lea    0x1(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	88 02                	mov    %al,(%edx)
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800310:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800313:	50                   	push   %eax
  800314:	ff 75 10             	pushl  0x10(%ebp)
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	e8 05 00 00 00       	call   800327 <vprintfmt>
	va_end(ap);
}
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	57                   	push   %edi
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 2c             	sub    $0x2c,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800336:	8b 7d 10             	mov    0x10(%ebp),%edi
  800339:	eb 12                	jmp    80034d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033b:	85 c0                	test   %eax,%eax
  80033d:	0f 84 89 03 00 00    	je     8006cc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	53                   	push   %ebx
  800347:	50                   	push   %eax
  800348:	ff d6                	call   *%esi
  80034a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034d:	83 c7 01             	add    $0x1,%edi
  800350:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800354:	83 f8 25             	cmp    $0x25,%eax
  800357:	75 e2                	jne    80033b <vprintfmt+0x14>
  800359:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800364:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 07                	jmp    800380 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8d 47 01             	lea    0x1(%edi),%eax
  800383:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800386:	0f b6 07             	movzbl (%edi),%eax
  800389:	0f b6 c8             	movzbl %al,%ecx
  80038c:	83 e8 23             	sub    $0x23,%eax
  80038f:	3c 55                	cmp    $0x55,%al
  800391:	0f 87 1a 03 00 00    	ja     8006b1 <vprintfmt+0x38a>
  800397:	0f b6 c0             	movzbl %al,%eax
  80039a:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a8:	eb d6                	jmp    800380 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c2:	83 fa 09             	cmp    $0x9,%edx
  8003c5:	77 39                	ja     800400 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ca:	eb e9                	jmp    8003b5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dd:	eb 27                	jmp    800406 <vprintfmt+0xdf>
  8003df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e2:	85 c0                	test   %eax,%eax
  8003e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e9:	0f 49 c8             	cmovns %eax,%ecx
  8003ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f2:	eb 8c                	jmp    800380 <vprintfmt+0x59>
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fe:	eb 80                	jmp    800380 <vprintfmt+0x59>
  800400:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800403:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800406:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040a:	0f 89 70 ff ff ff    	jns    800380 <vprintfmt+0x59>
				width = precision, precision = -1;
  800410:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041d:	e9 5e ff ff ff       	jmp    800380 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800422:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800428:	e9 53 ff ff ff       	jmp    800380 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	ff 30                	pushl  (%eax)
  80043c:	ff d6                	call   *%esi
			break;
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800444:	e9 04 ff ff ff       	jmp    80034d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	99                   	cltd   
  800455:	31 d0                	xor    %edx,%eax
  800457:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800459:	83 f8 0f             	cmp    $0xf,%eax
  80045c:	7f 0b                	jg     800469 <vprintfmt+0x142>
  80045e:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800465:	85 d2                	test   %edx,%edx
  800467:	75 18                	jne    800481 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800469:	50                   	push   %eax
  80046a:	68 78 22 80 00       	push   $0x802278
  80046f:	53                   	push   %ebx
  800470:	56                   	push   %esi
  800471:	e8 94 fe ff ff       	call   80030a <printfmt>
  800476:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047c:	e9 cc fe ff ff       	jmp    80034d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800481:	52                   	push   %edx
  800482:	68 9d 26 80 00       	push   $0x80269d
  800487:	53                   	push   %ebx
  800488:	56                   	push   %esi
  800489:	e8 7c fe ff ff       	call   80030a <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800494:	e9 b4 fe ff ff       	jmp    80034d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a4:	85 ff                	test   %edi,%edi
  8004a6:	b8 71 22 80 00       	mov    $0x802271,%eax
  8004ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b2:	0f 8e 94 00 00 00    	jle    80054c <vprintfmt+0x225>
  8004b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bc:	0f 84 98 00 00 00    	je     80055a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c8:	57                   	push   %edi
  8004c9:	e8 86 02 00 00       	call   800754 <strnlen>
  8004ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d1:	29 c1                	sub    %eax,%ecx
  8004d3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1c0>
  8004fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800500:	85 c9                	test   %ecx,%ecx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c1             	cmovns %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 4d                	jmp    800566 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1b                	je     80053a <vprintfmt+0x213>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 10                	jbe    80053a <vprintfmt+0x213>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	6a 3f                	push   $0x3f
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb 0d                	jmp    800547 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	52                   	push   %edx
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	83 eb 01             	sub    $0x1,%ebx
  80054a:	eb 1a                	jmp    800566 <vprintfmt+0x23f>
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800558:	eb 0c                	jmp    800566 <vprintfmt+0x23f>
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	83 c7 01             	add    $0x1,%edi
  800569:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056d:	0f be d0             	movsbl %al,%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	74 23                	je     800597 <vprintfmt+0x270>
  800574:	85 f6                	test   %esi,%esi
  800576:	78 a1                	js     800519 <vprintfmt+0x1f2>
  800578:	83 ee 01             	sub    $0x1,%esi
  80057b:	79 9c                	jns    800519 <vprintfmt+0x1f2>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb 18                	jmp    80059f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	6a 20                	push   $0x20
  80058d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb 08                	jmp    80059f <vprintfmt+0x278>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	85 ff                	test   %edi,%edi
  8005a1:	7f e4                	jg     800587 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a6:	e9 a2 fd ff ff       	jmp    80034d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 fa 01             	cmp    $0x1,%edx
  8005ae:	7e 16                	jle    8005c6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 08             	lea    0x8(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c4:	eb 32                	jmp    8005f8 <vprintfmt+0x2d1>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 18                	je     8005e2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e0:	eb 16                	jmp    8005f8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800603:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800607:	79 74                	jns    80067d <vprintfmt+0x356>
				putch('-', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 2d                	push   $0x2d
  80060f:	ff d6                	call   *%esi
				num = -(long long) num;
  800611:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800614:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800617:	f7 d8                	neg    %eax
  800619:	83 d2 00             	adc    $0x0,%edx
  80061c:	f7 da                	neg    %edx
  80061e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800626:	eb 55                	jmp    80067d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 83 fc ff ff       	call   8002b3 <getuint>
			base = 10;
  800630:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800635:	eb 46                	jmp    80067d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 74 fc ff ff       	call   8002b3 <getuint>
			base = 8;
  80063f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800644:	eb 37                	jmp    80067d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 30                	push   $0x30
  80064c:	ff d6                	call   *%esi
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 78                	push   $0x78
  800654:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800669:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066e:	eb 0d                	jmp    80067d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 3b fc ff ff       	call   8002b3 <getuint>
			base = 16;
  800678:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800684:	57                   	push   %edi
  800685:	ff 75 e0             	pushl  -0x20(%ebp)
  800688:	51                   	push   %ecx
  800689:	52                   	push   %edx
  80068a:	50                   	push   %eax
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 70 fb ff ff       	call   800204 <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069a:	e9 ae fc ff ff       	jmp    80034d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	51                   	push   %ecx
  8006a4:	ff d6                	call   *%esi
			break;
  8006a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ac:	e9 9c fc ff ff       	jmp    80034d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 25                	push   $0x25
  8006b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 03                	jmp    8006c1 <vprintfmt+0x39a>
  8006be:	83 ef 01             	sub    $0x1,%edi
  8006c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c5:	75 f7                	jne    8006be <vprintfmt+0x397>
  8006c7:	e9 81 fc ff ff       	jmp    80034d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 26                	je     80071b <vsnprintf+0x47>
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	7e 22                	jle    80071b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f9:	ff 75 14             	pushl  0x14(%ebp)
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	68 ed 02 80 00       	push   $0x8002ed
  800708:	e8 1a fc ff ff       	call   800327 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800710:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 05                	jmp    800720 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072b:	50                   	push   %eax
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	ff 75 08             	pushl  0x8(%ebp)
  800735:	e8 9a ff ff ff       	call   8006d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 03                	jmp    80074c <strlen+0x10>
		n++;
  800749:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800750:	75 f7                	jne    800749 <strlen+0xd>
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
  800762:	eb 03                	jmp    800767 <strnlen+0x13>
		n++;
  800764:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 c2                	cmp    %eax,%edx
  800769:	74 08                	je     800773 <strnlen+0x1f>
  80076b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076f:	75 f3                	jne    800764 <strnlen+0x10>
  800771:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078e:	84 db                	test   %bl,%bl
  800790:	75 ef                	jne    800781 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800792:	5b                   	pop    %ebx
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079c:	53                   	push   %ebx
  80079d:	e8 9a ff ff ff       	call   80073c <strlen>
  8007a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	50                   	push   %eax
  8007ab:	e8 c5 ff ff ff       	call   800775 <strcpy>
	return dst;
}
  8007b0:	89 d8                	mov    %ebx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	89 f3                	mov    %esi,%ebx
  8007c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 0f                	jmp    8007da <strncpy+0x23>
		*dst++ = *src;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	0f b6 01             	movzbl (%ecx),%eax
  8007d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	39 da                	cmp    %ebx,%edx
  8007dc:	75 ed                	jne    8007cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	74 21                	je     800819 <strlcpy+0x35>
  8007f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fc:	89 f2                	mov    %esi,%edx
  8007fe:	eb 09                	jmp    800809 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800809:	39 c2                	cmp    %eax,%edx
  80080b:	74 09                	je     800816 <strlcpy+0x32>
  80080d:	0f b6 19             	movzbl (%ecx),%ebx
  800810:	84 db                	test   %bl,%bl
  800812:	75 ec                	jne    800800 <strlcpy+0x1c>
  800814:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800816:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800819:	29 f0                	sub    %esi,%eax
}
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	eb 06                	jmp    800830 <strcmp+0x11>
		p++, q++;
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800830:	0f b6 01             	movzbl (%ecx),%eax
  800833:	84 c0                	test   %al,%al
  800835:	74 04                	je     80083b <strcmp+0x1c>
  800837:	3a 02                	cmp    (%edx),%al
  800839:	74 ef                	je     80082a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 c0             	movzbl %al,%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 c3                	mov    %eax,%ebx
  800851:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800854:	eb 06                	jmp    80085c <strncmp+0x17>
		n--, p++, q++;
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085c:	39 d8                	cmp    %ebx,%eax
  80085e:	74 15                	je     800875 <strncmp+0x30>
  800860:	0f b6 08             	movzbl (%eax),%ecx
  800863:	84 c9                	test   %cl,%cl
  800865:	74 04                	je     80086b <strncmp+0x26>
  800867:	3a 0a                	cmp    (%edx),%cl
  800869:	74 eb                	je     800856 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb 05                	jmp    80087a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 07                	jmp    800890 <strchr+0x13>
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 0f                	je     80089c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 03                	jmp    8008ad <strfind+0xf>
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 04                	je     8008b8 <strfind+0x1a>
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strfind+0xc>
			break;
	return (char *) s;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c6:	85 c9                	test   %ecx,%ecx
  8008c8:	74 36                	je     800900 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d0:	75 28                	jne    8008fa <memset+0x40>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 23                	jne    8008fa <memset+0x40>
		c &= 0xFF;
  8008d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008db:	89 d3                	mov    %edx,%ebx
  8008dd:	c1 e3 08             	shl    $0x8,%ebx
  8008e0:	89 d6                	mov    %edx,%esi
  8008e2:	c1 e6 18             	shl    $0x18,%esi
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	c1 e0 10             	shl    $0x10,%eax
  8008ea:	09 f0                	or     %esi,%eax
  8008ec:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	09 d0                	or     %edx,%eax
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb 06                	jmp    800900 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fd:	fc                   	cld    
  8008fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800900:	89 f8                	mov    %edi,%eax
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800915:	39 c6                	cmp    %eax,%esi
  800917:	73 35                	jae    80094e <memmove+0x47>
  800919:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	73 2e                	jae    80094e <memmove+0x47>
		s += n;
		d += n;
  800920:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800923:	89 d6                	mov    %edx,%esi
  800925:	09 fe                	or     %edi,%esi
  800927:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092d:	75 13                	jne    800942 <memmove+0x3b>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 0e                	jne    800942 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800934:	83 ef 04             	sub    $0x4,%edi
  800937:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093a:	c1 e9 02             	shr    $0x2,%ecx
  80093d:	fd                   	std    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 09                	jmp    80094b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800942:	83 ef 01             	sub    $0x1,%edi
  800945:	8d 72 ff             	lea    -0x1(%edx),%esi
  800948:	fd                   	std    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094b:	fc                   	cld    
  80094c:	eb 1d                	jmp    80096b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	89 f2                	mov    %esi,%edx
  800950:	09 c2                	or     %eax,%edx
  800952:	f6 c2 03             	test   $0x3,%dl
  800955:	75 0f                	jne    800966 <memmove+0x5f>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 0a                	jne    800966 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	89 c7                	mov    %eax,%edi
  800961:	fc                   	cld    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 05                	jmp    80096b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800972:	ff 75 10             	pushl  0x10(%ebp)
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	ff 75 08             	pushl  0x8(%ebp)
  80097b:	e8 87 ff ff ff       	call   800907 <memmove>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 c6                	mov    %eax,%esi
  80098f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	eb 1a                	jmp    8009ae <memcmp+0x2c>
		if (*s1 != *s2)
  800994:	0f b6 08             	movzbl (%eax),%ecx
  800997:	0f b6 1a             	movzbl (%edx),%ebx
  80099a:	38 d9                	cmp    %bl,%cl
  80099c:	74 0a                	je     8009a8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099e:	0f b6 c1             	movzbl %cl,%eax
  8009a1:	0f b6 db             	movzbl %bl,%ebx
  8009a4:	29 d8                	sub    %ebx,%eax
  8009a6:	eb 0f                	jmp    8009b7 <memcmp+0x35>
		s1++, s2++;
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	75 e2                	jne    800994 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c2:	89 c1                	mov    %eax,%ecx
  8009c4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cb:	eb 0a                	jmp    8009d7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	39 da                	cmp    %ebx,%edx
  8009d2:	74 07                	je     8009db <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	39 c8                	cmp    %ecx,%eax
  8009d9:	72 f2                	jb     8009cd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ea:	eb 03                	jmp    8009ef <strtol+0x11>
		s++;
  8009ec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ef:	0f b6 01             	movzbl (%ecx),%eax
  8009f2:	3c 20                	cmp    $0x20,%al
  8009f4:	74 f6                	je     8009ec <strtol+0xe>
  8009f6:	3c 09                	cmp    $0x9,%al
  8009f8:	74 f2                	je     8009ec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fa:	3c 2b                	cmp    $0x2b,%al
  8009fc:	75 0a                	jne    800a08 <strtol+0x2a>
		s++;
  8009fe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a01:	bf 00 00 00 00       	mov    $0x0,%edi
  800a06:	eb 11                	jmp    800a19 <strtol+0x3b>
  800a08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0d:	3c 2d                	cmp    $0x2d,%al
  800a0f:	75 08                	jne    800a19 <strtol+0x3b>
		s++, neg = 1;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1f:	75 15                	jne    800a36 <strtol+0x58>
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	75 10                	jne    800a36 <strtol+0x58>
  800a26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2a:	75 7c                	jne    800aa8 <strtol+0xca>
		s += 2, base = 16;
  800a2c:	83 c1 02             	add    $0x2,%ecx
  800a2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a34:	eb 16                	jmp    800a4c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	75 12                	jne    800a4c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a42:	75 08                	jne    800a4c <strtol+0x6e>
		s++, base = 8;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a54:	0f b6 11             	movzbl (%ecx),%edx
  800a57:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 09             	cmp    $0x9,%bl
  800a5f:	77 08                	ja     800a69 <strtol+0x8b>
			dig = *s - '0';
  800a61:	0f be d2             	movsbl %dl,%edx
  800a64:	83 ea 30             	sub    $0x30,%edx
  800a67:	eb 22                	jmp    800a8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 19             	cmp    $0x19,%bl
  800a71:	77 08                	ja     800a7b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a73:	0f be d2             	movsbl %dl,%edx
  800a76:	83 ea 57             	sub    $0x57,%edx
  800a79:	eb 10                	jmp    800a8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 19             	cmp    $0x19,%bl
  800a83:	77 16                	ja     800a9b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8e:	7d 0b                	jge    800a9b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a90:	83 c1 01             	add    $0x1,%ecx
  800a93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a99:	eb b9                	jmp    800a54 <strtol+0x76>

	if (endptr)
  800a9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9f:	74 0d                	je     800aae <strtol+0xd0>
		*endptr = (char *) s;
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	89 0e                	mov    %ecx,(%esi)
  800aa6:	eb 06                	jmp    800aae <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	74 98                	je     800a44 <strtol+0x66>
  800aac:	eb 9e                	jmp    800a4c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aae:	89 c2                	mov    %eax,%edx
  800ab0:	f7 da                	neg    %edx
  800ab2:	85 ff                	test   %edi,%edi
  800ab4:	0f 45 c2             	cmovne %edx,%eax
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aca:	8b 55 08             	mov    0x8(%ebp),%edx
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cgetc>:

int
sys_cgetc(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b07:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	89 cb                	mov    %ecx,%ebx
  800b11:	89 cf                	mov    %ecx,%edi
  800b13:	89 ce                	mov    %ecx,%esi
  800b15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7e 17                	jle    800b32 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	50                   	push   %eax
  800b1f:	6a 03                	push   $0x3
  800b21:	68 5f 25 80 00       	push   $0x80255f
  800b26:	6a 23                	push   $0x23
  800b28:	68 7c 25 80 00       	push   $0x80257c
  800b2d:	e8 de 11 00 00       	call   801d10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_yield>:

void
sys_yield(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	be 00 00 00 00       	mov    $0x0,%esi
  800b86:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	89 f7                	mov    %esi,%edi
  800b96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7e 17                	jle    800bb3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 04                	push   $0x4
  800ba2:	68 5f 25 80 00       	push   $0x80255f
  800ba7:	6a 23                	push   $0x23
  800ba9:	68 7c 25 80 00       	push   $0x80257c
  800bae:	e8 5d 11 00 00       	call   801d10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7e 17                	jle    800bf5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 05                	push   $0x5
  800be4:	68 5f 25 80 00       	push   $0x80255f
  800be9:	6a 23                	push   $0x23
  800beb:	68 7c 25 80 00       	push   $0x80257c
  800bf0:	e8 1b 11 00 00       	call   801d10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	89 df                	mov    %ebx,%edi
  800c18:	89 de                	mov    %ebx,%esi
  800c1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 17                	jle    800c37 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 06                	push   $0x6
  800c26:	68 5f 25 80 00       	push   $0x80255f
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 7c 25 80 00       	push   $0x80257c
  800c32:	e8 d9 10 00 00       	call   801d10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 17                	jle    800c79 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 08                	push   $0x8
  800c68:	68 5f 25 80 00       	push   $0x80255f
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 7c 25 80 00       	push   $0x80257c
  800c74:	e8 97 10 00 00       	call   801d10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 09                	push   $0x9
  800caa:	68 5f 25 80 00       	push   $0x80255f
  800caf:	6a 23                	push   $0x23
  800cb1:	68 7c 25 80 00       	push   $0x80257c
  800cb6:	e8 55 10 00 00       	call   801d10 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 0a                	push   $0xa
  800cec:	68 5f 25 80 00       	push   $0x80255f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 7c 25 80 00       	push   $0x80257c
  800cf8:	e8 13 10 00 00       	call   801d10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	be 00 00 00 00       	mov    $0x0,%esi
  800d10:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d36:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 cb                	mov    %ecx,%ebx
  800d40:	89 cf                	mov    %ecx,%edi
  800d42:	89 ce                	mov    %ecx,%esi
  800d44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 0d                	push   $0xd
  800d50:	68 5f 25 80 00       	push   $0x80255f
  800d55:	6a 23                	push   $0x23
  800d57:	68 7c 25 80 00       	push   $0x80257c
  800d5c:	e8 af 0f 00 00       	call   801d10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d73:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d75:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d79:	74 11                	je     800d8c <pgfault+0x23>
  800d7b:	89 d8                	mov    %ebx,%eax
  800d7d:	c1 e8 0c             	shr    $0xc,%eax
  800d80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d87:	f6 c4 08             	test   $0x8,%ah
  800d8a:	75 14                	jne    800da0 <pgfault+0x37>
		panic("faulting access");
  800d8c:	83 ec 04             	sub    $0x4,%esp
  800d8f:	68 8a 25 80 00       	push   $0x80258a
  800d94:	6a 1d                	push   $0x1d
  800d96:	68 9a 25 80 00       	push   $0x80259a
  800d9b:	e8 70 0f 00 00       	call   801d10 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	6a 07                	push   $0x7
  800da5:	68 00 f0 7f 00       	push   $0x7ff000
  800daa:	6a 00                	push   $0x0
  800dac:	e8 c7 fd ff ff       	call   800b78 <sys_page_alloc>
	if (r < 0) {
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	79 12                	jns    800dca <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800db8:	50                   	push   %eax
  800db9:	68 a5 25 80 00       	push   $0x8025a5
  800dbe:	6a 2b                	push   $0x2b
  800dc0:	68 9a 25 80 00       	push   $0x80259a
  800dc5:	e8 46 0f 00 00       	call   801d10 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	68 00 10 00 00       	push   $0x1000
  800dd8:	53                   	push   %ebx
  800dd9:	68 00 f0 7f 00       	push   $0x7ff000
  800dde:	e8 8c fb ff ff       	call   80096f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800de3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dea:	53                   	push   %ebx
  800deb:	6a 00                	push   $0x0
  800ded:	68 00 f0 7f 00       	push   $0x7ff000
  800df2:	6a 00                	push   $0x0
  800df4:	e8 c2 fd ff ff       	call   800bbb <sys_page_map>
	if (r < 0) {
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	79 12                	jns    800e12 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e00:	50                   	push   %eax
  800e01:	68 a5 25 80 00       	push   $0x8025a5
  800e06:	6a 32                	push   $0x32
  800e08:	68 9a 25 80 00       	push   $0x80259a
  800e0d:	e8 fe 0e 00 00       	call   801d10 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 dc fd ff ff       	call   800bfd <sys_page_unmap>
	if (r < 0) {
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	79 12                	jns    800e3a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e28:	50                   	push   %eax
  800e29:	68 a5 25 80 00       	push   $0x8025a5
  800e2e:	6a 36                	push   $0x36
  800e30:	68 9a 25 80 00       	push   $0x80259a
  800e35:	e8 d6 0e 00 00       	call   801d10 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e48:	68 69 0d 80 00       	push   $0x800d69
  800e4d:	e8 04 0f 00 00       	call   801d56 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e52:	b8 07 00 00 00       	mov    $0x7,%eax
  800e57:	cd 30                	int    $0x30
  800e59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 17                	jns    800e7a <fork+0x3b>
		panic("fork fault %e");
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 be 25 80 00       	push   $0x8025be
  800e6b:	68 83 00 00 00       	push   $0x83
  800e70:	68 9a 25 80 00       	push   $0x80259a
  800e75:	e8 96 0e 00 00       	call   801d10 <_panic>
  800e7a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e80:	75 21                	jne    800ea3 <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e82:	e8 b3 fc ff ff       	call   800b3a <sys_getenvid>
  800e87:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e8f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e94:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	e9 61 01 00 00       	jmp    801004 <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	6a 07                	push   $0x7
  800ea8:	68 00 f0 bf ee       	push   $0xeebff000
  800ead:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eb0:	e8 c3 fc ff ff       	call   800b78 <sys_page_alloc>
  800eb5:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800eb8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ebd:	89 d8                	mov    %ebx,%eax
  800ebf:	c1 e8 16             	shr    $0x16,%eax
  800ec2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec9:	a8 01                	test   $0x1,%al
  800ecb:	0f 84 fc 00 00 00    	je     800fcd <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ed1:	89 d8                	mov    %ebx,%eax
  800ed3:	c1 e8 0c             	shr    $0xc,%eax
  800ed6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	0f 84 e7 00 00 00    	je     800fcd <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eeb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef2:	f6 c6 04             	test   $0x4,%dh
  800ef5:	74 39                	je     800f30 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ef7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	25 07 0e 00 00       	and    $0xe07,%eax
  800f06:	50                   	push   %eax
  800f07:	56                   	push   %esi
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 aa fc ff ff       	call   800bbb <sys_page_map>
		if (r < 0) {
  800f11:	83 c4 20             	add    $0x20,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	0f 89 b1 00 00 00    	jns    800fcd <fork+0x18e>
		    	panic("sys page map fault %e");
  800f1c:	83 ec 04             	sub    $0x4,%esp
  800f1f:	68 cc 25 80 00       	push   $0x8025cc
  800f24:	6a 53                	push   $0x53
  800f26:	68 9a 25 80 00       	push   $0x80259a
  800f2b:	e8 e0 0d 00 00       	call   801d10 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f37:	f6 c2 02             	test   $0x2,%dl
  800f3a:	75 0c                	jne    800f48 <fork+0x109>
  800f3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f43:	f6 c4 08             	test   $0x8,%ah
  800f46:	74 5b                	je     800fa3 <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	68 05 08 00 00       	push   $0x805
  800f50:	56                   	push   %esi
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	6a 00                	push   $0x0
  800f55:	e8 61 fc ff ff       	call   800bbb <sys_page_map>
		if (r < 0) {
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	79 14                	jns    800f75 <fork+0x136>
		    	panic("sys page map fault %e");
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	68 cc 25 80 00       	push   $0x8025cc
  800f69:	6a 5a                	push   $0x5a
  800f6b:	68 9a 25 80 00       	push   $0x80259a
  800f70:	e8 9b 0d 00 00       	call   801d10 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	68 05 08 00 00       	push   $0x805
  800f7d:	56                   	push   %esi
  800f7e:	6a 00                	push   $0x0
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	e8 33 fc ff ff       	call   800bbb <sys_page_map>
		if (r < 0) {
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 3e                	jns    800fcd <fork+0x18e>
		    	panic("sys page map fault %e");
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	68 cc 25 80 00       	push   $0x8025cc
  800f97:	6a 5e                	push   $0x5e
  800f99:	68 9a 25 80 00       	push   $0x80259a
  800f9e:	e8 6d 0d 00 00       	call   801d10 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	6a 05                	push   $0x5
  800fa8:	56                   	push   %esi
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 09 fc ff ff       	call   800bbb <sys_page_map>
		if (r < 0) {
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 14                	jns    800fcd <fork+0x18e>
		    	panic("sys page map fault %e");
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 cc 25 80 00       	push   $0x8025cc
  800fc1:	6a 63                	push   $0x63
  800fc3:	68 9a 25 80 00       	push   $0x80259a
  800fc8:	e8 43 0d 00 00       	call   801d10 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fcd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd3:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fd9:	0f 85 de fe ff ff    	jne    800ebd <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fdf:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe4:	8b 40 64             	mov    0x64(%eax),%eax
  800fe7:	83 ec 08             	sub    $0x8,%esp
  800fea:	50                   	push   %eax
  800feb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fee:	57                   	push   %edi
  800fef:	e8 cf fc ff ff       	call   800cc3 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	6a 02                	push   $0x2
  800ff9:	57                   	push   %edi
  800ffa:	e8 40 fc ff ff       	call   800c3f <sys_env_set_status>
	
	return envid;
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sfork>:

// Challenge!
int
sfork(void)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801012:	68 e2 25 80 00       	push   $0x8025e2
  801017:	68 a1 00 00 00       	push   $0xa1
  80101c:	68 9a 25 80 00       	push   $0x80259a
  801021:	e8 ea 0c 00 00       	call   801d10 <_panic>

00801026 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
  80102c:	05 00 00 00 30       	add    $0x30000000,%eax
  801031:	c1 e8 0c             	shr    $0xc,%eax
}
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801039:	8b 45 08             	mov    0x8(%ebp),%eax
  80103c:	05 00 00 00 30       	add    $0x30000000,%eax
  801041:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801046:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801053:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801058:	89 c2                	mov    %eax,%edx
  80105a:	c1 ea 16             	shr    $0x16,%edx
  80105d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801064:	f6 c2 01             	test   $0x1,%dl
  801067:	74 11                	je     80107a <fd_alloc+0x2d>
  801069:	89 c2                	mov    %eax,%edx
  80106b:	c1 ea 0c             	shr    $0xc,%edx
  80106e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801075:	f6 c2 01             	test   $0x1,%dl
  801078:	75 09                	jne    801083 <fd_alloc+0x36>
			*fd_store = fd;
  80107a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	eb 17                	jmp    80109a <fd_alloc+0x4d>
  801083:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801088:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80108d:	75 c9                	jne    801058 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80108f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801095:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010a2:	83 f8 1f             	cmp    $0x1f,%eax
  8010a5:	77 36                	ja     8010dd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a7:	c1 e0 0c             	shl    $0xc,%eax
  8010aa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	c1 ea 16             	shr    $0x16,%edx
  8010b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010bb:	f6 c2 01             	test   $0x1,%dl
  8010be:	74 24                	je     8010e4 <fd_lookup+0x48>
  8010c0:	89 c2                	mov    %eax,%edx
  8010c2:	c1 ea 0c             	shr    $0xc,%edx
  8010c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cc:	f6 c2 01             	test   $0x1,%dl
  8010cf:	74 1a                	je     8010eb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d4:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010db:	eb 13                	jmp    8010f0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e2:	eb 0c                	jmp    8010f0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e9:	eb 05                	jmp    8010f0 <fd_lookup+0x54>
  8010eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fb:	ba 74 26 80 00       	mov    $0x802674,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801100:	eb 13                	jmp    801115 <dev_lookup+0x23>
  801102:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801105:	39 08                	cmp    %ecx,(%eax)
  801107:	75 0c                	jne    801115 <dev_lookup+0x23>
			*dev = devtab[i];
  801109:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	eb 2e                	jmp    801143 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801115:	8b 02                	mov    (%edx),%eax
  801117:	85 c0                	test   %eax,%eax
  801119:	75 e7                	jne    801102 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80111b:	a1 04 40 80 00       	mov    0x804004,%eax
  801120:	8b 40 48             	mov    0x48(%eax),%eax
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	51                   	push   %ecx
  801127:	50                   	push   %eax
  801128:	68 f8 25 80 00       	push   $0x8025f8
  80112d:	e8 be f0 ff ff       	call   8001f0 <cprintf>
	*dev = 0;
  801132:	8b 45 0c             	mov    0xc(%ebp),%eax
  801135:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	83 ec 10             	sub    $0x10,%esp
  80114d:	8b 75 08             	mov    0x8(%ebp),%esi
  801150:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801153:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80115d:	c1 e8 0c             	shr    $0xc,%eax
  801160:	50                   	push   %eax
  801161:	e8 36 ff ff ff       	call   80109c <fd_lookup>
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 05                	js     801172 <fd_close+0x2d>
	    || fd != fd2)
  80116d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801170:	74 0c                	je     80117e <fd_close+0x39>
		return (must_exist ? r : 0);
  801172:	84 db                	test   %bl,%bl
  801174:	ba 00 00 00 00       	mov    $0x0,%edx
  801179:	0f 44 c2             	cmove  %edx,%eax
  80117c:	eb 41                	jmp    8011bf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	ff 36                	pushl  (%esi)
  801187:	e8 66 ff ff ff       	call   8010f2 <dev_lookup>
  80118c:	89 c3                	mov    %eax,%ebx
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 1a                	js     8011af <fd_close+0x6a>
		if (dev->dev_close)
  801195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801198:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80119b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	74 0b                	je     8011af <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	56                   	push   %esi
  8011a8:	ff d0                	call   *%eax
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	56                   	push   %esi
  8011b3:	6a 00                	push   $0x0
  8011b5:	e8 43 fa ff ff       	call   800bfd <sys_page_unmap>
	return r;
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	89 d8                	mov    %ebx,%eax
}
  8011bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 75 08             	pushl  0x8(%ebp)
  8011d3:	e8 c4 fe ff ff       	call   80109c <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 10                	js     8011ef <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	6a 01                	push   $0x1
  8011e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e7:	e8 59 ff ff ff       	call   801145 <fd_close>
  8011ec:	83 c4 10             	add    $0x10,%esp
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <close_all>:

void
close_all(void)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	53                   	push   %ebx
  801201:	e8 c0 ff ff ff       	call   8011c6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801206:	83 c3 01             	add    $0x1,%ebx
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	83 fb 20             	cmp    $0x20,%ebx
  80120f:	75 ec                	jne    8011fd <close_all+0xc>
		close(i);
}
  801211:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801214:	c9                   	leave  
  801215:	c3                   	ret    

00801216 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	57                   	push   %edi
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 2c             	sub    $0x2c,%esp
  80121f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801222:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	ff 75 08             	pushl  0x8(%ebp)
  801229:	e8 6e fe ff ff       	call   80109c <fd_lookup>
  80122e:	83 c4 08             	add    $0x8,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	0f 88 c1 00 00 00    	js     8012fa <dup+0xe4>
		return r;
	close(newfdnum);
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	56                   	push   %esi
  80123d:	e8 84 ff ff ff       	call   8011c6 <close>

	newfd = INDEX2FD(newfdnum);
  801242:	89 f3                	mov    %esi,%ebx
  801244:	c1 e3 0c             	shl    $0xc,%ebx
  801247:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80124d:	83 c4 04             	add    $0x4,%esp
  801250:	ff 75 e4             	pushl  -0x1c(%ebp)
  801253:	e8 de fd ff ff       	call   801036 <fd2data>
  801258:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80125a:	89 1c 24             	mov    %ebx,(%esp)
  80125d:	e8 d4 fd ff ff       	call   801036 <fd2data>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801268:	89 f8                	mov    %edi,%eax
  80126a:	c1 e8 16             	shr    $0x16,%eax
  80126d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801274:	a8 01                	test   $0x1,%al
  801276:	74 37                	je     8012af <dup+0x99>
  801278:	89 f8                	mov    %edi,%eax
  80127a:	c1 e8 0c             	shr    $0xc,%eax
  80127d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801284:	f6 c2 01             	test   $0x1,%dl
  801287:	74 26                	je     8012af <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801289:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	25 07 0e 00 00       	and    $0xe07,%eax
  801298:	50                   	push   %eax
  801299:	ff 75 d4             	pushl  -0x2c(%ebp)
  80129c:	6a 00                	push   $0x0
  80129e:	57                   	push   %edi
  80129f:	6a 00                	push   $0x0
  8012a1:	e8 15 f9 ff ff       	call   800bbb <sys_page_map>
  8012a6:	89 c7                	mov    %eax,%edi
  8012a8:	83 c4 20             	add    $0x20,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 2e                	js     8012dd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012b2:	89 d0                	mov    %edx,%eax
  8012b4:	c1 e8 0c             	shr    $0xc,%eax
  8012b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012be:	83 ec 0c             	sub    $0xc,%esp
  8012c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c6:	50                   	push   %eax
  8012c7:	53                   	push   %ebx
  8012c8:	6a 00                	push   $0x0
  8012ca:	52                   	push   %edx
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 e9 f8 ff ff       	call   800bbb <sys_page_map>
  8012d2:	89 c7                	mov    %eax,%edi
  8012d4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d9:	85 ff                	test   %edi,%edi
  8012db:	79 1d                	jns    8012fa <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	53                   	push   %ebx
  8012e1:	6a 00                	push   $0x0
  8012e3:	e8 15 f9 ff ff       	call   800bfd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ee:	6a 00                	push   $0x0
  8012f0:	e8 08 f9 ff ff       	call   800bfd <sys_page_unmap>
	return r;
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	89 f8                	mov    %edi,%eax
}
  8012fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 14             	sub    $0x14,%esp
  801309:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	53                   	push   %ebx
  801311:	e8 86 fd ff ff       	call   80109c <fd_lookup>
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	89 c2                	mov    %eax,%edx
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 6d                	js     80138c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	ff 30                	pushl  (%eax)
  80132b:	e8 c2 fd ff ff       	call   8010f2 <dev_lookup>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 4c                	js     801383 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801337:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80133a:	8b 42 08             	mov    0x8(%edx),%eax
  80133d:	83 e0 03             	and    $0x3,%eax
  801340:	83 f8 01             	cmp    $0x1,%eax
  801343:	75 21                	jne    801366 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801345:	a1 04 40 80 00       	mov    0x804004,%eax
  80134a:	8b 40 48             	mov    0x48(%eax),%eax
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	53                   	push   %ebx
  801351:	50                   	push   %eax
  801352:	68 39 26 80 00       	push   $0x802639
  801357:	e8 94 ee ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801364:	eb 26                	jmp    80138c <read+0x8a>
	}
	if (!dev->dev_read)
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	8b 40 08             	mov    0x8(%eax),%eax
  80136c:	85 c0                	test   %eax,%eax
  80136e:	74 17                	je     801387 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	ff 75 10             	pushl  0x10(%ebp)
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	52                   	push   %edx
  80137a:	ff d0                	call   *%eax
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	eb 09                	jmp    80138c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801383:	89 c2                	mov    %eax,%edx
  801385:	eb 05                	jmp    80138c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801387:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80138c:	89 d0                	mov    %edx,%eax
  80138e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	57                   	push   %edi
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a7:	eb 21                	jmp    8013ca <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	89 f0                	mov    %esi,%eax
  8013ae:	29 d8                	sub    %ebx,%eax
  8013b0:	50                   	push   %eax
  8013b1:	89 d8                	mov    %ebx,%eax
  8013b3:	03 45 0c             	add    0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	57                   	push   %edi
  8013b8:	e8 45 ff ff ff       	call   801302 <read>
		if (m < 0)
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 10                	js     8013d4 <readn+0x41>
			return m;
		if (m == 0)
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	74 0a                	je     8013d2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c8:	01 c3                	add    %eax,%ebx
  8013ca:	39 f3                	cmp    %esi,%ebx
  8013cc:	72 db                	jb     8013a9 <readn+0x16>
  8013ce:	89 d8                	mov    %ebx,%eax
  8013d0:	eb 02                	jmp    8013d4 <readn+0x41>
  8013d2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5f                   	pop    %edi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 14             	sub    $0x14,%esp
  8013e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	53                   	push   %ebx
  8013eb:	e8 ac fc ff ff       	call   80109c <fd_lookup>
  8013f0:	83 c4 08             	add    $0x8,%esp
  8013f3:	89 c2                	mov    %eax,%edx
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 68                	js     801461 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801403:	ff 30                	pushl  (%eax)
  801405:	e8 e8 fc ff ff       	call   8010f2 <dev_lookup>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 47                	js     801458 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801411:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801414:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801418:	75 21                	jne    80143b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80141a:	a1 04 40 80 00       	mov    0x804004,%eax
  80141f:	8b 40 48             	mov    0x48(%eax),%eax
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	53                   	push   %ebx
  801426:	50                   	push   %eax
  801427:	68 55 26 80 00       	push   $0x802655
  80142c:	e8 bf ed ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801439:	eb 26                	jmp    801461 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80143b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143e:	8b 52 0c             	mov    0xc(%edx),%edx
  801441:	85 d2                	test   %edx,%edx
  801443:	74 17                	je     80145c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	ff 75 10             	pushl  0x10(%ebp)
  80144b:	ff 75 0c             	pushl  0xc(%ebp)
  80144e:	50                   	push   %eax
  80144f:	ff d2                	call   *%edx
  801451:	89 c2                	mov    %eax,%edx
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	eb 09                	jmp    801461 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801458:	89 c2                	mov    %eax,%edx
  80145a:	eb 05                	jmp    801461 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80145c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801461:	89 d0                	mov    %edx,%eax
  801463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <seek>:

int
seek(int fdnum, off_t offset)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 22 fc ff ff       	call   80109c <fd_lookup>
  80147a:	83 c4 08             	add    $0x8,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 0e                	js     80148f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801481:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801484:	8b 55 0c             	mov    0xc(%ebp),%edx
  801487:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 14             	sub    $0x14,%esp
  801498:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	53                   	push   %ebx
  8014a0:	e8 f7 fb ff ff       	call   80109c <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	89 c2                	mov    %eax,%edx
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 65                	js     801513 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b8:	ff 30                	pushl  (%eax)
  8014ba:	e8 33 fc ff ff       	call   8010f2 <dev_lookup>
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 44                	js     80150a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014cd:	75 21                	jne    8014f0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014cf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014d4:	8b 40 48             	mov    0x48(%eax),%eax
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	53                   	push   %ebx
  8014db:	50                   	push   %eax
  8014dc:	68 18 26 80 00       	push   $0x802618
  8014e1:	e8 0a ed ff ff       	call   8001f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ee:	eb 23                	jmp    801513 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f3:	8b 52 18             	mov    0x18(%edx),%edx
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	74 14                	je     80150e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	ff 75 0c             	pushl  0xc(%ebp)
  801500:	50                   	push   %eax
  801501:	ff d2                	call   *%edx
  801503:	89 c2                	mov    %eax,%edx
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	eb 09                	jmp    801513 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150a:	89 c2                	mov    %eax,%edx
  80150c:	eb 05                	jmp    801513 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80150e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801513:	89 d0                	mov    %edx,%eax
  801515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	53                   	push   %ebx
  80151e:	83 ec 14             	sub    $0x14,%esp
  801521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801524:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	ff 75 08             	pushl  0x8(%ebp)
  80152b:	e8 6c fb ff ff       	call   80109c <fd_lookup>
  801530:	83 c4 08             	add    $0x8,%esp
  801533:	89 c2                	mov    %eax,%edx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 58                	js     801591 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801543:	ff 30                	pushl  (%eax)
  801545:	e8 a8 fb ff ff       	call   8010f2 <dev_lookup>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 37                	js     801588 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801551:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801554:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801558:	74 32                	je     80158c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80155a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80155d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801564:	00 00 00 
	stat->st_isdir = 0;
  801567:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156e:	00 00 00 
	stat->st_dev = dev;
  801571:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	53                   	push   %ebx
  80157b:	ff 75 f0             	pushl  -0x10(%ebp)
  80157e:	ff 50 14             	call   *0x14(%eax)
  801581:	89 c2                	mov    %eax,%edx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb 09                	jmp    801591 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	89 c2                	mov    %eax,%edx
  80158a:	eb 05                	jmp    801591 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80158c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801591:	89 d0                	mov    %edx,%eax
  801593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	6a 00                	push   $0x0
  8015a2:	ff 75 08             	pushl  0x8(%ebp)
  8015a5:	e8 e3 01 00 00       	call   80178d <open>
  8015aa:	89 c3                	mov    %eax,%ebx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 1b                	js     8015ce <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	ff 75 0c             	pushl  0xc(%ebp)
  8015b9:	50                   	push   %eax
  8015ba:	e8 5b ff ff ff       	call   80151a <fstat>
  8015bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8015c1:	89 1c 24             	mov    %ebx,(%esp)
  8015c4:	e8 fd fb ff ff       	call   8011c6 <close>
	return r;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	89 f0                	mov    %esi,%eax
}
  8015ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	89 c6                	mov    %eax,%esi
  8015dc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015de:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e5:	75 12                	jne    8015f9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	6a 01                	push   $0x1
  8015ec:	e8 c8 08 00 00       	call   801eb9 <ipc_find_env>
  8015f1:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f9:	6a 07                	push   $0x7
  8015fb:	68 00 50 80 00       	push   $0x805000
  801600:	56                   	push   %esi
  801601:	ff 35 00 40 80 00    	pushl  0x804000
  801607:	e8 4b 08 00 00       	call   801e57 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80160c:	83 c4 0c             	add    $0xc,%esp
  80160f:	6a 00                	push   $0x0
  801611:	53                   	push   %ebx
  801612:	6a 00                	push   $0x0
  801614:	e8 cc 07 00 00       	call   801de5 <ipc_recv>
}
  801619:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161c:	5b                   	pop    %ebx
  80161d:	5e                   	pop    %esi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801626:	8b 45 08             	mov    0x8(%ebp),%eax
  801629:	8b 40 0c             	mov    0xc(%eax),%eax
  80162c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801631:	8b 45 0c             	mov    0xc(%ebp),%eax
  801634:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801639:	ba 00 00 00 00       	mov    $0x0,%edx
  80163e:	b8 02 00 00 00       	mov    $0x2,%eax
  801643:	e8 8d ff ff ff       	call   8015d5 <fsipc>
}
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 40 0c             	mov    0xc(%eax),%eax
  801656:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 06 00 00 00       	mov    $0x6,%eax
  801665:	e8 6b ff ff ff       	call   8015d5 <fsipc>
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 04             	sub    $0x4,%esp
  801673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	8b 40 0c             	mov    0xc(%eax),%eax
  80167c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801681:	ba 00 00 00 00       	mov    $0x0,%edx
  801686:	b8 05 00 00 00       	mov    $0x5,%eax
  80168b:	e8 45 ff ff ff       	call   8015d5 <fsipc>
  801690:	85 c0                	test   %eax,%eax
  801692:	78 2c                	js     8016c0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	68 00 50 80 00       	push   $0x805000
  80169c:	53                   	push   %ebx
  80169d:	e8 d3 f0 ff ff       	call   800775 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8016b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016da:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016df:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016e4:	0f 47 c2             	cmova  %edx,%eax
  8016e7:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016ec:	50                   	push   %eax
  8016ed:	ff 75 0c             	pushl  0xc(%ebp)
  8016f0:	68 08 50 80 00       	push   $0x805008
  8016f5:	e8 0d f2 ff ff       	call   800907 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801704:	e8 cc fe ff ff       	call   8015d5 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	8b 40 0c             	mov    0xc(%eax),%eax
  801719:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 03 00 00 00       	mov    $0x3,%eax
  80172e:	e8 a2 fe ff ff       	call   8015d5 <fsipc>
  801733:	89 c3                	mov    %eax,%ebx
  801735:	85 c0                	test   %eax,%eax
  801737:	78 4b                	js     801784 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801739:	39 c6                	cmp    %eax,%esi
  80173b:	73 16                	jae    801753 <devfile_read+0x48>
  80173d:	68 84 26 80 00       	push   $0x802684
  801742:	68 8b 26 80 00       	push   $0x80268b
  801747:	6a 7c                	push   $0x7c
  801749:	68 a0 26 80 00       	push   $0x8026a0
  80174e:	e8 bd 05 00 00       	call   801d10 <_panic>
	assert(r <= PGSIZE);
  801753:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801758:	7e 16                	jle    801770 <devfile_read+0x65>
  80175a:	68 ab 26 80 00       	push   $0x8026ab
  80175f:	68 8b 26 80 00       	push   $0x80268b
  801764:	6a 7d                	push   $0x7d
  801766:	68 a0 26 80 00       	push   $0x8026a0
  80176b:	e8 a0 05 00 00       	call   801d10 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801770:	83 ec 04             	sub    $0x4,%esp
  801773:	50                   	push   %eax
  801774:	68 00 50 80 00       	push   $0x805000
  801779:	ff 75 0c             	pushl  0xc(%ebp)
  80177c:	e8 86 f1 ff ff       	call   800907 <memmove>
	return r;
  801781:	83 c4 10             	add    $0x10,%esp
}
  801784:	89 d8                	mov    %ebx,%eax
  801786:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	53                   	push   %ebx
  801791:	83 ec 20             	sub    $0x20,%esp
  801794:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801797:	53                   	push   %ebx
  801798:	e8 9f ef ff ff       	call   80073c <strlen>
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a5:	7f 67                	jg     80180e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a7:	83 ec 0c             	sub    $0xc,%esp
  8017aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ad:	50                   	push   %eax
  8017ae:	e8 9a f8 ff ff       	call   80104d <fd_alloc>
  8017b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 57                	js     801813 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017bc:	83 ec 08             	sub    $0x8,%esp
  8017bf:	53                   	push   %ebx
  8017c0:	68 00 50 80 00       	push   $0x805000
  8017c5:	e8 ab ef ff ff       	call   800775 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8017da:	e8 f6 fd ff ff       	call   8015d5 <fsipc>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	79 14                	jns    8017fc <open+0x6f>
		fd_close(fd, 0);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	6a 00                	push   $0x0
  8017ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f0:	e8 50 f9 ff ff       	call   801145 <fd_close>
		return r;
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	89 da                	mov    %ebx,%edx
  8017fa:	eb 17                	jmp    801813 <open+0x86>
	}

	return fd2num(fd);
  8017fc:	83 ec 0c             	sub    $0xc,%esp
  8017ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801802:	e8 1f f8 ff ff       	call   801026 <fd2num>
  801807:	89 c2                	mov    %eax,%edx
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	eb 05                	jmp    801813 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801813:	89 d0                	mov    %edx,%eax
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801820:	ba 00 00 00 00       	mov    $0x0,%edx
  801825:	b8 08 00 00 00       	mov    $0x8,%eax
  80182a:	e8 a6 fd ff ff       	call   8015d5 <fsipc>
}
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	ff 75 08             	pushl  0x8(%ebp)
  80183f:	e8 f2 f7 ff ff       	call   801036 <fd2data>
  801844:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801846:	83 c4 08             	add    $0x8,%esp
  801849:	68 b7 26 80 00       	push   $0x8026b7
  80184e:	53                   	push   %ebx
  80184f:	e8 21 ef ff ff       	call   800775 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801854:	8b 46 04             	mov    0x4(%esi),%eax
  801857:	2b 06                	sub    (%esi),%eax
  801859:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801866:	00 00 00 
	stat->st_dev = &devpipe;
  801869:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801870:	30 80 00 
	return 0;
}
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
  801878:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	53                   	push   %ebx
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801889:	53                   	push   %ebx
  80188a:	6a 00                	push   $0x0
  80188c:	e8 6c f3 ff ff       	call   800bfd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801891:	89 1c 24             	mov    %ebx,(%esp)
  801894:	e8 9d f7 ff ff       	call   801036 <fd2data>
  801899:	83 c4 08             	add    $0x8,%esp
  80189c:	50                   	push   %eax
  80189d:	6a 00                	push   $0x0
  80189f:	e8 59 f3 ff ff       	call   800bfd <sys_page_unmap>
}
  8018a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	57                   	push   %edi
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 1c             	sub    $0x1c,%esp
  8018b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8018bc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c5:	e8 28 06 00 00       	call   801ef2 <pageref>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	89 3c 24             	mov    %edi,(%esp)
  8018cf:	e8 1e 06 00 00       	call   801ef2 <pageref>
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	39 c3                	cmp    %eax,%ebx
  8018d9:	0f 94 c1             	sete   %cl
  8018dc:	0f b6 c9             	movzbl %cl,%ecx
  8018df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018eb:	39 ce                	cmp    %ecx,%esi
  8018ed:	74 1b                	je     80190a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018ef:	39 c3                	cmp    %eax,%ebx
  8018f1:	75 c4                	jne    8018b7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f3:	8b 42 58             	mov    0x58(%edx),%eax
  8018f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f9:	50                   	push   %eax
  8018fa:	56                   	push   %esi
  8018fb:	68 be 26 80 00       	push   $0x8026be
  801900:	e8 eb e8 ff ff       	call   8001f0 <cprintf>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	eb ad                	jmp    8018b7 <_pipeisclosed+0xe>
	}
}
  80190a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801910:	5b                   	pop    %ebx
  801911:	5e                   	pop    %esi
  801912:	5f                   	pop    %edi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	57                   	push   %edi
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	83 ec 28             	sub    $0x28,%esp
  80191e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801921:	56                   	push   %esi
  801922:	e8 0f f7 ff ff       	call   801036 <fd2data>
  801927:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	bf 00 00 00 00       	mov    $0x0,%edi
  801931:	eb 4b                	jmp    80197e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801933:	89 da                	mov    %ebx,%edx
  801935:	89 f0                	mov    %esi,%eax
  801937:	e8 6d ff ff ff       	call   8018a9 <_pipeisclosed>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	75 48                	jne    801988 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801940:	e8 14 f2 ff ff       	call   800b59 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801945:	8b 43 04             	mov    0x4(%ebx),%eax
  801948:	8b 0b                	mov    (%ebx),%ecx
  80194a:	8d 51 20             	lea    0x20(%ecx),%edx
  80194d:	39 d0                	cmp    %edx,%eax
  80194f:	73 e2                	jae    801933 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801954:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801958:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80195b:	89 c2                	mov    %eax,%edx
  80195d:	c1 fa 1f             	sar    $0x1f,%edx
  801960:	89 d1                	mov    %edx,%ecx
  801962:	c1 e9 1b             	shr    $0x1b,%ecx
  801965:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801968:	83 e2 1f             	and    $0x1f,%edx
  80196b:	29 ca                	sub    %ecx,%edx
  80196d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801971:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801975:	83 c0 01             	add    $0x1,%eax
  801978:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197b:	83 c7 01             	add    $0x1,%edi
  80197e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801981:	75 c2                	jne    801945 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801983:	8b 45 10             	mov    0x10(%ebp),%eax
  801986:	eb 05                	jmp    80198d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801988:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80198d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5f                   	pop    %edi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	57                   	push   %edi
  801999:	56                   	push   %esi
  80199a:	53                   	push   %ebx
  80199b:	83 ec 18             	sub    $0x18,%esp
  80199e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a1:	57                   	push   %edi
  8019a2:	e8 8f f6 ff ff       	call   801036 <fd2data>
  8019a7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b1:	eb 3d                	jmp    8019f0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b3:	85 db                	test   %ebx,%ebx
  8019b5:	74 04                	je     8019bb <devpipe_read+0x26>
				return i;
  8019b7:	89 d8                	mov    %ebx,%eax
  8019b9:	eb 44                	jmp    8019ff <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019bb:	89 f2                	mov    %esi,%edx
  8019bd:	89 f8                	mov    %edi,%eax
  8019bf:	e8 e5 fe ff ff       	call   8018a9 <_pipeisclosed>
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	75 32                	jne    8019fa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c8:	e8 8c f1 ff ff       	call   800b59 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019cd:	8b 06                	mov    (%esi),%eax
  8019cf:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d2:	74 df                	je     8019b3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d4:	99                   	cltd   
  8019d5:	c1 ea 1b             	shr    $0x1b,%edx
  8019d8:	01 d0                	add    %edx,%eax
  8019da:	83 e0 1f             	and    $0x1f,%eax
  8019dd:	29 d0                	sub    %edx,%eax
  8019df:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019ea:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ed:	83 c3 01             	add    $0x1,%ebx
  8019f0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f3:	75 d8                	jne    8019cd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f8:	eb 05                	jmp    8019ff <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5f                   	pop    %edi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a12:	50                   	push   %eax
  801a13:	e8 35 f6 ff ff       	call   80104d <fd_alloc>
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	89 c2                	mov    %eax,%edx
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	0f 88 2c 01 00 00    	js     801b51 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a25:	83 ec 04             	sub    $0x4,%esp
  801a28:	68 07 04 00 00       	push   $0x407
  801a2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a30:	6a 00                	push   $0x0
  801a32:	e8 41 f1 ff ff       	call   800b78 <sys_page_alloc>
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	89 c2                	mov    %eax,%edx
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	0f 88 0d 01 00 00    	js     801b51 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4a:	50                   	push   %eax
  801a4b:	e8 fd f5 ff ff       	call   80104d <fd_alloc>
  801a50:	89 c3                	mov    %eax,%ebx
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	85 c0                	test   %eax,%eax
  801a57:	0f 88 e2 00 00 00    	js     801b3f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5d:	83 ec 04             	sub    $0x4,%esp
  801a60:	68 07 04 00 00       	push   $0x407
  801a65:	ff 75 f0             	pushl  -0x10(%ebp)
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 09 f1 ff ff       	call   800b78 <sys_page_alloc>
  801a6f:	89 c3                	mov    %eax,%ebx
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	0f 88 c3 00 00 00    	js     801b3f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a82:	e8 af f5 ff ff       	call   801036 <fd2data>
  801a87:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a89:	83 c4 0c             	add    $0xc,%esp
  801a8c:	68 07 04 00 00       	push   $0x407
  801a91:	50                   	push   %eax
  801a92:	6a 00                	push   $0x0
  801a94:	e8 df f0 ff ff       	call   800b78 <sys_page_alloc>
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	0f 88 89 00 00 00    	js     801b2f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	ff 75 f0             	pushl  -0x10(%ebp)
  801aac:	e8 85 f5 ff ff       	call   801036 <fd2data>
  801ab1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab8:	50                   	push   %eax
  801ab9:	6a 00                	push   $0x0
  801abb:	56                   	push   %esi
  801abc:	6a 00                	push   $0x0
  801abe:	e8 f8 f0 ff ff       	call   800bbb <sys_page_map>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	83 c4 20             	add    $0x20,%esp
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	78 55                	js     801b21 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801acc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ada:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aea:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 f4             	pushl  -0xc(%ebp)
  801afc:	e8 25 f5 ff ff       	call   801026 <fd2num>
  801b01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b04:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b06:	83 c4 04             	add    $0x4,%esp
  801b09:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0c:	e8 15 f5 ff ff       	call   801026 <fd2num>
  801b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b14:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1f:	eb 30                	jmp    801b51 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	56                   	push   %esi
  801b25:	6a 00                	push   $0x0
  801b27:	e8 d1 f0 ff ff       	call   800bfd <sys_page_unmap>
  801b2c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b2f:	83 ec 08             	sub    $0x8,%esp
  801b32:	ff 75 f0             	pushl  -0x10(%ebp)
  801b35:	6a 00                	push   $0x0
  801b37:	e8 c1 f0 ff ff       	call   800bfd <sys_page_unmap>
  801b3c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b3f:	83 ec 08             	sub    $0x8,%esp
  801b42:	ff 75 f4             	pushl  -0xc(%ebp)
  801b45:	6a 00                	push   $0x0
  801b47:	e8 b1 f0 ff ff       	call   800bfd <sys_page_unmap>
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b51:	89 d0                	mov    %edx,%eax
  801b53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5e                   	pop    %esi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b63:	50                   	push   %eax
  801b64:	ff 75 08             	pushl  0x8(%ebp)
  801b67:	e8 30 f5 ff ff       	call   80109c <fd_lookup>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 18                	js     801b8b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	ff 75 f4             	pushl  -0xc(%ebp)
  801b79:	e8 b8 f4 ff ff       	call   801036 <fd2data>
	return _pipeisclosed(fd, p);
  801b7e:	89 c2                	mov    %eax,%edx
  801b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b83:	e8 21 fd ff ff       	call   8018a9 <_pipeisclosed>
  801b88:	83 c4 10             	add    $0x10,%esp
}
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b9d:	68 d6 26 80 00       	push   $0x8026d6
  801ba2:	ff 75 0c             	pushl  0xc(%ebp)
  801ba5:	e8 cb eb ff ff       	call   800775 <strcpy>
	return 0;
}
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    

00801bb1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	57                   	push   %edi
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc8:	eb 2d                	jmp    801bf7 <devcons_write+0x46>
		m = n - tot;
  801bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bcd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bcf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bda:	83 ec 04             	sub    $0x4,%esp
  801bdd:	53                   	push   %ebx
  801bde:	03 45 0c             	add    0xc(%ebp),%eax
  801be1:	50                   	push   %eax
  801be2:	57                   	push   %edi
  801be3:	e8 1f ed ff ff       	call   800907 <memmove>
		sys_cputs(buf, m);
  801be8:	83 c4 08             	add    $0x8,%esp
  801beb:	53                   	push   %ebx
  801bec:	57                   	push   %edi
  801bed:	e8 ca ee ff ff       	call   800abc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf2:	01 de                	add    %ebx,%esi
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	89 f0                	mov    %esi,%eax
  801bf9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfc:	72 cc                	jb     801bca <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c15:	74 2a                	je     801c41 <devcons_read+0x3b>
  801c17:	eb 05                	jmp    801c1e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c19:	e8 3b ef ff ff       	call   800b59 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c1e:	e8 b7 ee ff ff       	call   800ada <sys_cgetc>
  801c23:	85 c0                	test   %eax,%eax
  801c25:	74 f2                	je     801c19 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 16                	js     801c41 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c2b:	83 f8 04             	cmp    $0x4,%eax
  801c2e:	74 0c                	je     801c3c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c30:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c33:	88 02                	mov    %al,(%edx)
	return 1;
  801c35:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3a:	eb 05                	jmp    801c41 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4f:	6a 01                	push   $0x1
  801c51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c54:	50                   	push   %eax
  801c55:	e8 62 ee ff ff       	call   800abc <sys_cputs>
}
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <getchar>:

int
getchar(void)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c65:	6a 01                	push   $0x1
  801c67:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 90 f6 ff ff       	call   801302 <read>
	if (r < 0)
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 0f                	js     801c88 <getchar+0x29>
		return r;
	if (r < 1)
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	7e 06                	jle    801c83 <getchar+0x24>
		return -E_EOF;
	return c;
  801c7d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c81:	eb 05                	jmp    801c88 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c83:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	ff 75 08             	pushl  0x8(%ebp)
  801c97:	e8 00 f4 ff ff       	call   80109c <fd_lookup>
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 11                	js     801cb4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cac:	39 10                	cmp    %edx,(%eax)
  801cae:	0f 94 c0             	sete   %al
  801cb1:	0f b6 c0             	movzbl %al,%eax
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <opencons>:

int
opencons(void)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	e8 88 f3 ff ff       	call   80104d <fd_alloc>
  801cc5:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 3e                	js     801d0c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cce:	83 ec 04             	sub    $0x4,%esp
  801cd1:	68 07 04 00 00       	push   $0x407
  801cd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 98 ee ff ff       	call   800b78 <sys_page_alloc>
  801ce0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 23                	js     801d0c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	50                   	push   %eax
  801d02:	e8 1f f3 ff ff       	call   801026 <fd2num>
  801d07:	89 c2                	mov    %eax,%edx
  801d09:	83 c4 10             	add    $0x10,%esp
}
  801d0c:	89 d0                	mov    %edx,%eax
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d15:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d18:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d1e:	e8 17 ee ff ff       	call   800b3a <sys_getenvid>
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	ff 75 08             	pushl  0x8(%ebp)
  801d2c:	56                   	push   %esi
  801d2d:	50                   	push   %eax
  801d2e:	68 e4 26 80 00       	push   $0x8026e4
  801d33:	e8 b8 e4 ff ff       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d38:	83 c4 18             	add    $0x18,%esp
  801d3b:	53                   	push   %ebx
  801d3c:	ff 75 10             	pushl  0x10(%ebp)
  801d3f:	e8 5b e4 ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  801d44:	c7 04 24 54 22 80 00 	movl   $0x802254,(%esp)
  801d4b:	e8 a0 e4 ff ff       	call   8001f0 <cprintf>
  801d50:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d53:	cc                   	int3   
  801d54:	eb fd                	jmp    801d53 <_panic+0x43>

00801d56 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d5c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d63:	75 2a                	jne    801d8f <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d65:	83 ec 04             	sub    $0x4,%esp
  801d68:	6a 07                	push   $0x7
  801d6a:	68 00 f0 bf ee       	push   $0xeebff000
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 02 ee ff ff       	call   800b78 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	79 12                	jns    801d8f <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d7d:	50                   	push   %eax
  801d7e:	68 08 27 80 00       	push   $0x802708
  801d83:	6a 23                	push   $0x23
  801d85:	68 0c 27 80 00       	push   $0x80270c
  801d8a:	e8 81 ff ff ff       	call   801d10 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d97:	83 ec 08             	sub    $0x8,%esp
  801d9a:	68 c1 1d 80 00       	push   $0x801dc1
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 1d ef ff ff       	call   800cc3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	79 12                	jns    801dbf <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dad:	50                   	push   %eax
  801dae:	68 08 27 80 00       	push   $0x802708
  801db3:	6a 2c                	push   $0x2c
  801db5:	68 0c 27 80 00       	push   $0x80270c
  801dba:	e8 51 ff ff ff       	call   801d10 <_panic>
	}
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dc1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dc2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dc7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dc9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dcc:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dd0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dd5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dd9:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ddb:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dde:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ddf:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801de2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801de3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801de4:	c3                   	ret    

00801de5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	56                   	push   %esi
  801de9:	53                   	push   %ebx
  801dea:	8b 75 08             	mov    0x8(%ebp),%esi
  801ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801df3:	85 c0                	test   %eax,%eax
  801df5:	75 12                	jne    801e09 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	68 00 00 c0 ee       	push   $0xeec00000
  801dff:	e8 24 ef ff ff       	call   800d28 <sys_ipc_recv>
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	eb 0c                	jmp    801e15 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	50                   	push   %eax
  801e0d:	e8 16 ef ff ff       	call   800d28 <sys_ipc_recv>
  801e12:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e15:	85 f6                	test   %esi,%esi
  801e17:	0f 95 c1             	setne  %cl
  801e1a:	85 db                	test   %ebx,%ebx
  801e1c:	0f 95 c2             	setne  %dl
  801e1f:	84 d1                	test   %dl,%cl
  801e21:	74 09                	je     801e2c <ipc_recv+0x47>
  801e23:	89 c2                	mov    %eax,%edx
  801e25:	c1 ea 1f             	shr    $0x1f,%edx
  801e28:	84 d2                	test   %dl,%dl
  801e2a:	75 24                	jne    801e50 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e2c:	85 f6                	test   %esi,%esi
  801e2e:	74 0a                	je     801e3a <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801e30:	a1 04 40 80 00       	mov    0x804004,%eax
  801e35:	8b 40 74             	mov    0x74(%eax),%eax
  801e38:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e3a:	85 db                	test   %ebx,%ebx
  801e3c:	74 0a                	je     801e48 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801e3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e43:	8b 40 78             	mov    0x78(%eax),%eax
  801e46:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e48:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	57                   	push   %edi
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e63:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e69:	85 db                	test   %ebx,%ebx
  801e6b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e70:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e73:	ff 75 14             	pushl  0x14(%ebp)
  801e76:	53                   	push   %ebx
  801e77:	56                   	push   %esi
  801e78:	57                   	push   %edi
  801e79:	e8 87 ee ff ff       	call   800d05 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e7e:	89 c2                	mov    %eax,%edx
  801e80:	c1 ea 1f             	shr    $0x1f,%edx
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	84 d2                	test   %dl,%dl
  801e88:	74 17                	je     801ea1 <ipc_send+0x4a>
  801e8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8d:	74 12                	je     801ea1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e8f:	50                   	push   %eax
  801e90:	68 1a 27 80 00       	push   $0x80271a
  801e95:	6a 47                	push   $0x47
  801e97:	68 28 27 80 00       	push   $0x802728
  801e9c:	e8 6f fe ff ff       	call   801d10 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ea1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea4:	75 07                	jne    801ead <ipc_send+0x56>
			sys_yield();
  801ea6:	e8 ae ec ff ff       	call   800b59 <sys_yield>
  801eab:	eb c6                	jmp    801e73 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	75 c2                	jne    801e73 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ebf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ec7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ecd:	8b 52 50             	mov    0x50(%edx),%edx
  801ed0:	39 ca                	cmp    %ecx,%edx
  801ed2:	75 0d                	jne    801ee1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ed4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ed7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801edc:	8b 40 48             	mov    0x48(%eax),%eax
  801edf:	eb 0f                	jmp    801ef0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee1:	83 c0 01             	add    $0x1,%eax
  801ee4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee9:	75 d9                	jne    801ec4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef8:	89 d0                	mov    %edx,%eax
  801efa:	c1 e8 16             	shr    $0x16,%eax
  801efd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f09:	f6 c1 01             	test   $0x1,%cl
  801f0c:	74 1d                	je     801f2b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0e:	c1 ea 0c             	shr    $0xc,%edx
  801f11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f18:	f6 c2 01             	test   $0x1,%dl
  801f1b:	74 0e                	je     801f2b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1d:	c1 ea 0c             	shr    $0xc,%edx
  801f20:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f27:	ef 
  801f28:	0f b7 c0             	movzwl %ax,%eax
}
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	66 90                	xchg   %ax,%ax
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
