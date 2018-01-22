
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
  80003a:	68 40 22 80 00       	push   $0x802240
  80003f:	e8 c4 01 00 00       	call   800208 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 2e 0e 00 00       	call   800e77 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 b8 22 80 00       	push   $0x8022b8
  800058:	e8 ab 01 00 00       	call   800208 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 22 80 00       	push   $0x802268
  80006c:	e8 97 01 00 00       	call   800208 <cprintf>
	sys_yield();
  800071:	e8 fb 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  800076:	e8 f6 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  80007b:	e8 f1 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  800080:	e8 ec 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  800085:	e8 e7 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  80008a:	e8 e2 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  80008f:	e8 dd 0a 00 00       	call   800b71 <sys_yield>
	sys_yield();
  800094:	e8 d8 0a 00 00       	call   800b71 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  8000a0:	e8 63 01 00 00       	call   800208 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 64 0a 00 00       	call   800b11 <sys_env_destroy>
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
  8000c8:	e8 85 0a 00 00       	call   800b52 <sys_getenvid>
  8000cd:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	50                   	push   %eax
  8000d3:	68 d8 22 80 00       	push   $0x8022d8
  8000d8:	e8 2b 01 00 00       	call   800208 <cprintf>
  8000dd:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000f5:	89 c1                	mov    %eax,%ecx
  8000f7:	c1 e1 07             	shl    $0x7,%ecx
  8000fa:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800101:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800104:	39 cb                	cmp    %ecx,%ebx
  800106:	0f 44 fa             	cmove  %edx,%edi
  800109:	b9 01 00 00 00       	mov    $0x1,%ecx
  80010e:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	81 c2 84 00 00 00    	add    $0x84,%edx
  80011a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80011f:	75 d4                	jne    8000f5 <libmain+0x40>
  800121:	89 f0                	mov    %esi,%eax
  800123:	84 c0                	test   %al,%al
  800125:	74 06                	je     80012d <libmain+0x78>
  800127:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800131:	7e 0a                	jle    80013d <libmain+0x88>
		binaryname = argv[0];
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	8b 00                	mov    (%eax),%eax
  800138:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 e8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80014b:	e8 0b 00 00 00       	call   80015b <exit>
}
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800161:	e8 ee 10 00 00       	call   801254 <close_all>
	sys_env_destroy(0);
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	6a 00                	push   $0x0
  80016b:	e8 a1 09 00 00       	call   800b11 <sys_env_destroy>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	53                   	push   %ebx
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017f:	8b 13                	mov    (%ebx),%edx
  800181:	8d 42 01             	lea    0x1(%edx),%eax
  800184:	89 03                	mov    %eax,(%ebx)
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	75 1a                	jne    8001ae <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800194:	83 ec 08             	sub    $0x8,%esp
  800197:	68 ff 00 00 00       	push   $0xff
  80019c:	8d 43 08             	lea    0x8(%ebx),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 2f 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ab:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ae:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 75 01 80 00       	push   $0x800175
  8001e6:	e8 54 01 00 00       	call   80033f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 d4 08 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800232:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800235:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800240:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800243:	39 d3                	cmp    %edx,%ebx
  800245:	72 05                	jb     80024c <printnum+0x30>
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 45                	ja     800291 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	8b 45 14             	mov    0x14(%ebp),%eax
  800255:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800258:	53                   	push   %ebx
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800262:	ff 75 e0             	pushl  -0x20(%ebp)
  800265:	ff 75 dc             	pushl  -0x24(%ebp)
  800268:	ff 75 d8             	pushl  -0x28(%ebp)
  80026b:	e8 30 1d 00 00       	call   801fa0 <__udivdi3>
  800270:	83 c4 18             	add    $0x18,%esp
  800273:	52                   	push   %edx
  800274:	50                   	push   %eax
  800275:	89 f2                	mov    %esi,%edx
  800277:	89 f8                	mov    %edi,%eax
  800279:	e8 9e ff ff ff       	call   80021c <printnum>
  80027e:	83 c4 20             	add    $0x20,%esp
  800281:	eb 18                	jmp    80029b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	ff 75 18             	pushl  0x18(%ebp)
  80028a:	ff d7                	call   *%edi
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	eb 03                	jmp    800294 <printnum+0x78>
  800291:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800294:	83 eb 01             	sub    $0x1,%ebx
  800297:	85 db                	test   %ebx,%ebx
  800299:	7f e8                	jg     800283 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	56                   	push   %esi
  80029f:	83 ec 04             	sub    $0x4,%esp
  8002a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ae:	e8 1d 1e 00 00       	call   8020d0 <__umoddi3>
  8002b3:	83 c4 14             	add    $0x14,%esp
  8002b6:	0f be 80 01 23 80 00 	movsbl 0x802301(%eax),%eax
  8002bd:	50                   	push   %eax
  8002be:	ff d7                	call   *%edi
}
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ce:	83 fa 01             	cmp    $0x1,%edx
  8002d1:	7e 0e                	jle    8002e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	8b 52 04             	mov    0x4(%edx),%edx
  8002df:	eb 22                	jmp    800303 <getuint+0x38>
	else if (lflag)
  8002e1:	85 d2                	test   %edx,%edx
  8002e3:	74 10                	je     8002f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 0e                	jmp    800303 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 0a                	jae    800320 <sprintputch+0x1b>
		*b->buf++ = ch;
  800316:	8d 4a 01             	lea    0x1(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	88 02                	mov    %al,(%edx)
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800328:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032b:	50                   	push   %eax
  80032c:	ff 75 10             	pushl  0x10(%ebp)
  80032f:	ff 75 0c             	pushl  0xc(%ebp)
  800332:	ff 75 08             	pushl  0x8(%ebp)
  800335:	e8 05 00 00 00       	call   80033f <vprintfmt>
	va_end(ap);
}
  80033a:	83 c4 10             	add    $0x10,%esp
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 2c             	sub    $0x2c,%esp
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800351:	eb 12                	jmp    800365 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 84 89 03 00 00    	je     8006e4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	53                   	push   %ebx
  80035f:	50                   	push   %eax
  800360:	ff d6                	call   *%esi
  800362:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	83 c7 01             	add    $0x1,%edi
  800368:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036c:	83 f8 25             	cmp    $0x25,%eax
  80036f:	75 e2                	jne    800353 <vprintfmt+0x14>
  800371:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800375:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800383:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
  80038f:	eb 07                	jmp    800398 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800394:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8d 47 01             	lea    0x1(%edi),%eax
  80039b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039e:	0f b6 07             	movzbl (%edi),%eax
  8003a1:	0f b6 c8             	movzbl %al,%ecx
  8003a4:	83 e8 23             	sub    $0x23,%eax
  8003a7:	3c 55                	cmp    $0x55,%al
  8003a9:	0f 87 1a 03 00 00    	ja     8006c9 <vprintfmt+0x38a>
  8003af:	0f b6 c0             	movzbl %al,%eax
  8003b2:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003da:	83 fa 09             	cmp    $0x9,%edx
  8003dd:	77 39                	ja     800418 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003df:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e2:	eb e9                	jmp    8003cd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f5:	eb 27                	jmp    80041e <vprintfmt+0xdf>
  8003f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800401:	0f 49 c8             	cmovns %eax,%ecx
  800404:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040a:	eb 8c                	jmp    800398 <vprintfmt+0x59>
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800416:	eb 80                	jmp    800398 <vprintfmt+0x59>
  800418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 89 70 ff ff ff    	jns    800398 <vprintfmt+0x59>
				width = precision, precision = -1;
  800428:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800435:	e9 5e ff ff ff       	jmp    800398 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800440:	e9 53 ff ff ff       	jmp    800398 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	ff 30                	pushl  (%eax)
  800454:	ff d6                	call   *%esi
			break;
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045c:	e9 04 ff ff ff       	jmp    800365 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	99                   	cltd   
  80046d:	31 d0                	xor    %edx,%eax
  80046f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 0f             	cmp    $0xf,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x142>
  800476:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80047d:	85 d2                	test   %edx,%edx
  80047f:	75 18                	jne    800499 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800481:	50                   	push   %eax
  800482:	68 19 23 80 00       	push   $0x802319
  800487:	53                   	push   %ebx
  800488:	56                   	push   %esi
  800489:	e8 94 fe ff ff       	call   800322 <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800494:	e9 cc fe ff ff       	jmp    800365 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800499:	52                   	push   %edx
  80049a:	68 4d 27 80 00       	push   $0x80274d
  80049f:	53                   	push   %ebx
  8004a0:	56                   	push   %esi
  8004a1:	e8 7c fe ff ff       	call   800322 <printfmt>
  8004a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ac:	e9 b4 fe ff ff       	jmp    800365 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004bc:	85 ff                	test   %edi,%edi
  8004be:	b8 12 23 80 00       	mov    $0x802312,%eax
  8004c3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ca:	0f 8e 94 00 00 00    	jle    800564 <vprintfmt+0x225>
  8004d0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d4:	0f 84 98 00 00 00    	je     800572 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e0:	57                   	push   %edi
  8004e1:	e8 86 02 00 00       	call   80076c <strnlen>
  8004e6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e9:	29 c1                	sub    %eax,%ecx
  8004eb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ee:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004fb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	eb 0f                	jmp    80050e <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	ff 75 e0             	pushl  -0x20(%ebp)
  800506:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ef 01             	sub    $0x1,%edi
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	85 ff                	test   %edi,%edi
  800510:	7f ed                	jg     8004ff <vprintfmt+0x1c0>
  800512:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800515:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800518:	85 c9                	test   %ecx,%ecx
  80051a:	b8 00 00 00 00       	mov    $0x0,%eax
  80051f:	0f 49 c1             	cmovns %ecx,%eax
  800522:	29 c1                	sub    %eax,%ecx
  800524:	89 75 08             	mov    %esi,0x8(%ebp)
  800527:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052d:	89 cb                	mov    %ecx,%ebx
  80052f:	eb 4d                	jmp    80057e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800535:	74 1b                	je     800552 <vprintfmt+0x213>
  800537:	0f be c0             	movsbl %al,%eax
  80053a:	83 e8 20             	sub    $0x20,%eax
  80053d:	83 f8 5e             	cmp    $0x5e,%eax
  800540:	76 10                	jbe    800552 <vprintfmt+0x213>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	6a 3f                	push   $0x3f
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb 0d                	jmp    80055f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	52                   	push   %edx
  800559:	ff 55 08             	call   *0x8(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055f:	83 eb 01             	sub    $0x1,%ebx
  800562:	eb 1a                	jmp    80057e <vprintfmt+0x23f>
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800570:	eb 0c                	jmp    80057e <vprintfmt+0x23f>
  800572:	89 75 08             	mov    %esi,0x8(%ebp)
  800575:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800578:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057e:	83 c7 01             	add    $0x1,%edi
  800581:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800585:	0f be d0             	movsbl %al,%edx
  800588:	85 d2                	test   %edx,%edx
  80058a:	74 23                	je     8005af <vprintfmt+0x270>
  80058c:	85 f6                	test   %esi,%esi
  80058e:	78 a1                	js     800531 <vprintfmt+0x1f2>
  800590:	83 ee 01             	sub    $0x1,%esi
  800593:	79 9c                	jns    800531 <vprintfmt+0x1f2>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	eb 18                	jmp    8005b7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 20                	push   $0x20
  8005a5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 ef 01             	sub    $0x1,%edi
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	eb 08                	jmp    8005b7 <vprintfmt+0x278>
  8005af:	89 df                	mov    %ebx,%edi
  8005b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f e4                	jg     80059f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005be:	e9 a2 fd ff ff       	jmp    800365 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c3:	83 fa 01             	cmp    $0x1,%edx
  8005c6:	7e 16                	jle    8005de <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 08             	lea    0x8(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 50 04             	mov    0x4(%eax),%edx
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005dc:	eb 32                	jmp    800610 <vprintfmt+0x2d1>
	else if (lflag)
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 18                	je     8005fa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f8:	eb 16                	jmp    800610 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 c1                	mov    %eax,%ecx
  80060a:	c1 f9 1f             	sar    $0x1f,%ecx
  80060d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800610:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800613:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800616:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061f:	79 74                	jns    800695 <vprintfmt+0x356>
				putch('-', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 2d                	push   $0x2d
  800627:	ff d6                	call   *%esi
				num = -(long long) num;
  800629:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062f:	f7 d8                	neg    %eax
  800631:	83 d2 00             	adc    $0x0,%edx
  800634:	f7 da                	neg    %edx
  800636:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800639:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063e:	eb 55                	jmp    800695 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 83 fc ff ff       	call   8002cb <getuint>
			base = 10;
  800648:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064d:	eb 46                	jmp    800695 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 74 fc ff ff       	call   8002cb <getuint>
			base = 8;
  800657:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80065c:	eb 37                	jmp    800695 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 30                	push   $0x30
  800664:	ff d6                	call   *%esi
			putch('x', putdat);
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	6a 78                	push   $0x78
  80066c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800677:	8b 00                	mov    (%eax),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800681:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800686:	eb 0d                	jmp    800695 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
  80068b:	e8 3b fc ff ff       	call   8002cb <getuint>
			base = 16;
  800690:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800695:	83 ec 0c             	sub    $0xc,%esp
  800698:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069c:	57                   	push   %edi
  80069d:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a0:	51                   	push   %ecx
  8006a1:	52                   	push   %edx
  8006a2:	50                   	push   %eax
  8006a3:	89 da                	mov    %ebx,%edx
  8006a5:	89 f0                	mov    %esi,%eax
  8006a7:	e8 70 fb ff ff       	call   80021c <printnum>
			break;
  8006ac:	83 c4 20             	add    $0x20,%esp
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b2:	e9 ae fc ff ff       	jmp    800365 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	51                   	push   %ecx
  8006bc:	ff d6                	call   *%esi
			break;
  8006be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c4:	e9 9c fc ff ff       	jmp    800365 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	eb 03                	jmp    8006d9 <vprintfmt+0x39a>
  8006d6:	83 ef 01             	sub    $0x1,%edi
  8006d9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006dd:	75 f7                	jne    8006d6 <vprintfmt+0x397>
  8006df:	e9 81 fc ff ff       	jmp    800365 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e7:	5b                   	pop    %ebx
  8006e8:	5e                   	pop    %esi
  8006e9:	5f                   	pop    %edi
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 18             	sub    $0x18,%esp
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800702:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800709:	85 c0                	test   %eax,%eax
  80070b:	74 26                	je     800733 <vsnprintf+0x47>
  80070d:	85 d2                	test   %edx,%edx
  80070f:	7e 22                	jle    800733 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800711:	ff 75 14             	pushl  0x14(%ebp)
  800714:	ff 75 10             	pushl  0x10(%ebp)
  800717:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	68 05 03 80 00       	push   $0x800305
  800720:	e8 1a fc ff ff       	call   80033f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800725:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800728:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 05                	jmp    800738 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800743:	50                   	push   %eax
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	ff 75 08             	pushl  0x8(%ebp)
  80074d:	e8 9a ff ff ff       	call   8006ec <vsnprintf>
	va_end(ap);

	return rc;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	eb 03                	jmp    800764 <strlen+0x10>
		n++;
  800761:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800768:	75 f7                	jne    800761 <strlen+0xd>
		n++;
	return n;
}
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	ba 00 00 00 00       	mov    $0x0,%edx
  80077a:	eb 03                	jmp    80077f <strnlen+0x13>
		n++;
  80077c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	39 c2                	cmp    %eax,%edx
  800781:	74 08                	je     80078b <strnlen+0x1f>
  800783:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800787:	75 f3                	jne    80077c <strnlen+0x10>
  800789:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	53                   	push   %ebx
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800797:	89 c2                	mov    %eax,%edx
  800799:	83 c2 01             	add    $0x1,%edx
  80079c:	83 c1 01             	add    $0x1,%ecx
  80079f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a6:	84 db                	test   %bl,%bl
  8007a8:	75 ef                	jne    800799 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	53                   	push   %ebx
  8007b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b4:	53                   	push   %ebx
  8007b5:	e8 9a ff ff ff       	call   800754 <strlen>
  8007ba:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	01 d8                	add    %ebx,%eax
  8007c2:	50                   	push   %eax
  8007c3:	e8 c5 ff ff ff       	call   80078d <strcpy>
	return dst;
}
  8007c8:	89 d8                	mov    %ebx,%eax
  8007ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007da:	89 f3                	mov    %esi,%ebx
  8007dc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007df:	89 f2                	mov    %esi,%edx
  8007e1:	eb 0f                	jmp    8007f2 <strncpy+0x23>
		*dst++ = *src;
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	0f b6 01             	movzbl (%ecx),%eax
  8007e9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ec:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ef:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f2:	39 da                	cmp    %ebx,%edx
  8007f4:	75 ed                	jne    8007e3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	8b 55 10             	mov    0x10(%ebp),%edx
  80080a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080c:	85 d2                	test   %edx,%edx
  80080e:	74 21                	je     800831 <strlcpy+0x35>
  800810:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800814:	89 f2                	mov    %esi,%edx
  800816:	eb 09                	jmp    800821 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800818:	83 c2 01             	add    $0x1,%edx
  80081b:	83 c1 01             	add    $0x1,%ecx
  80081e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800821:	39 c2                	cmp    %eax,%edx
  800823:	74 09                	je     80082e <strlcpy+0x32>
  800825:	0f b6 19             	movzbl (%ecx),%ebx
  800828:	84 db                	test   %bl,%bl
  80082a:	75 ec                	jne    800818 <strlcpy+0x1c>
  80082c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80082e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800831:	29 f0                	sub    %esi,%eax
}
  800833:	5b                   	pop    %ebx
  800834:	5e                   	pop    %esi
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800840:	eb 06                	jmp    800848 <strcmp+0x11>
		p++, q++;
  800842:	83 c1 01             	add    $0x1,%ecx
  800845:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800848:	0f b6 01             	movzbl (%ecx),%eax
  80084b:	84 c0                	test   %al,%al
  80084d:	74 04                	je     800853 <strcmp+0x1c>
  80084f:	3a 02                	cmp    (%edx),%al
  800851:	74 ef                	je     800842 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 c0             	movzbl %al,%eax
  800856:	0f b6 12             	movzbl (%edx),%edx
  800859:	29 d0                	sub    %edx,%eax
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
  800867:	89 c3                	mov    %eax,%ebx
  800869:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strncmp+0x17>
		n--, p++, q++;
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800874:	39 d8                	cmp    %ebx,%eax
  800876:	74 15                	je     80088d <strncmp+0x30>
  800878:	0f b6 08             	movzbl (%eax),%ecx
  80087b:	84 c9                	test   %cl,%cl
  80087d:	74 04                	je     800883 <strncmp+0x26>
  80087f:	3a 0a                	cmp    (%edx),%cl
  800881:	74 eb                	je     80086e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 00             	movzbl (%eax),%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
  80088b:	eb 05                	jmp    800892 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800892:	5b                   	pop    %ebx
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089f:	eb 07                	jmp    8008a8 <strchr+0x13>
		if (*s == c)
  8008a1:	38 ca                	cmp    %cl,%dl
  8008a3:	74 0f                	je     8008b4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a5:	83 c0 01             	add    $0x1,%eax
  8008a8:	0f b6 10             	movzbl (%eax),%edx
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f2                	jne    8008a1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c0:	eb 03                	jmp    8008c5 <strfind+0xf>
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	74 04                	je     8008d0 <strfind+0x1a>
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	75 f2                	jne    8008c2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008de:	85 c9                	test   %ecx,%ecx
  8008e0:	74 36                	je     800918 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e8:	75 28                	jne    800912 <memset+0x40>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 23                	jne    800912 <memset+0x40>
		c &= 0xFF;
  8008ef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f3:	89 d3                	mov    %edx,%ebx
  8008f5:	c1 e3 08             	shl    $0x8,%ebx
  8008f8:	89 d6                	mov    %edx,%esi
  8008fa:	c1 e6 18             	shl    $0x18,%esi
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	c1 e0 10             	shl    $0x10,%eax
  800902:	09 f0                	or     %esi,%eax
  800904:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800906:	89 d8                	mov    %ebx,%eax
  800908:	09 d0                	or     %edx,%eax
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	fc                   	cld    
  80090e:	f3 ab                	rep stos %eax,%es:(%edi)
  800910:	eb 06                	jmp    800918 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800912:	8b 45 0c             	mov    0xc(%ebp),%eax
  800915:	fc                   	cld    
  800916:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800918:	89 f8                	mov    %edi,%eax
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	57                   	push   %edi
  800923:	56                   	push   %esi
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092d:	39 c6                	cmp    %eax,%esi
  80092f:	73 35                	jae    800966 <memmove+0x47>
  800931:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800934:	39 d0                	cmp    %edx,%eax
  800936:	73 2e                	jae    800966 <memmove+0x47>
		s += n;
		d += n;
  800938:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093b:	89 d6                	mov    %edx,%esi
  80093d:	09 fe                	or     %edi,%esi
  80093f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800945:	75 13                	jne    80095a <memmove+0x3b>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 0e                	jne    80095a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80094c:	83 ef 04             	sub    $0x4,%edi
  80094f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800952:	c1 e9 02             	shr    $0x2,%ecx
  800955:	fd                   	std    
  800956:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800958:	eb 09                	jmp    800963 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095a:	83 ef 01             	sub    $0x1,%edi
  80095d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800960:	fd                   	std    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800963:	fc                   	cld    
  800964:	eb 1d                	jmp    800983 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 f2                	mov    %esi,%edx
  800968:	09 c2                	or     %eax,%edx
  80096a:	f6 c2 03             	test   $0x3,%dl
  80096d:	75 0f                	jne    80097e <memmove+0x5f>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 0a                	jne    80097e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800974:	c1 e9 02             	shr    $0x2,%ecx
  800977:	89 c7                	mov    %eax,%edi
  800979:	fc                   	cld    
  80097a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097c:	eb 05                	jmp    800983 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098a:	ff 75 10             	pushl  0x10(%ebp)
  80098d:	ff 75 0c             	pushl  0xc(%ebp)
  800990:	ff 75 08             	pushl  0x8(%ebp)
  800993:	e8 87 ff ff ff       	call   80091f <memmove>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a5:	89 c6                	mov    %eax,%esi
  8009a7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009aa:	eb 1a                	jmp    8009c6 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ac:	0f b6 08             	movzbl (%eax),%ecx
  8009af:	0f b6 1a             	movzbl (%edx),%ebx
  8009b2:	38 d9                	cmp    %bl,%cl
  8009b4:	74 0a                	je     8009c0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b6:	0f b6 c1             	movzbl %cl,%eax
  8009b9:	0f b6 db             	movzbl %bl,%ebx
  8009bc:	29 d8                	sub    %ebx,%eax
  8009be:	eb 0f                	jmp    8009cf <memcmp+0x35>
		s1++, s2++;
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	39 f0                	cmp    %esi,%eax
  8009c8:	75 e2                	jne    8009ac <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009da:	89 c1                	mov    %eax,%ecx
  8009dc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009df:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e3:	eb 0a                	jmp    8009ef <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	39 da                	cmp    %ebx,%edx
  8009ea:	74 07                	je     8009f3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	39 c8                	cmp    %ecx,%eax
  8009f1:	72 f2                	jb     8009e5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	eb 03                	jmp    800a07 <strtol+0x11>
		s++;
  800a04:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a07:	0f b6 01             	movzbl (%ecx),%eax
  800a0a:	3c 20                	cmp    $0x20,%al
  800a0c:	74 f6                	je     800a04 <strtol+0xe>
  800a0e:	3c 09                	cmp    $0x9,%al
  800a10:	74 f2                	je     800a04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a12:	3c 2b                	cmp    $0x2b,%al
  800a14:	75 0a                	jne    800a20 <strtol+0x2a>
		s++;
  800a16:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1e:	eb 11                	jmp    800a31 <strtol+0x3b>
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	75 08                	jne    800a31 <strtol+0x3b>
		s++, neg = 1;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a37:	75 15                	jne    800a4e <strtol+0x58>
  800a39:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3c:	75 10                	jne    800a4e <strtol+0x58>
  800a3e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a42:	75 7c                	jne    800ac0 <strtol+0xca>
		s += 2, base = 16;
  800a44:	83 c1 02             	add    $0x2,%ecx
  800a47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4c:	eb 16                	jmp    800a64 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a4e:	85 db                	test   %ebx,%ebx
  800a50:	75 12                	jne    800a64 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a52:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 08                	jne    800a64 <strtol+0x6e>
		s++, base = 8;
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
  800a69:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6c:	0f b6 11             	movzbl (%ecx),%edx
  800a6f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a72:	89 f3                	mov    %esi,%ebx
  800a74:	80 fb 09             	cmp    $0x9,%bl
  800a77:	77 08                	ja     800a81 <strtol+0x8b>
			dig = *s - '0';
  800a79:	0f be d2             	movsbl %dl,%edx
  800a7c:	83 ea 30             	sub    $0x30,%edx
  800a7f:	eb 22                	jmp    800aa3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a81:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a84:	89 f3                	mov    %esi,%ebx
  800a86:	80 fb 19             	cmp    $0x19,%bl
  800a89:	77 08                	ja     800a93 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a8b:	0f be d2             	movsbl %dl,%edx
  800a8e:	83 ea 57             	sub    $0x57,%edx
  800a91:	eb 10                	jmp    800aa3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a93:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 19             	cmp    $0x19,%bl
  800a9b:	77 16                	ja     800ab3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a9d:	0f be d2             	movsbl %dl,%edx
  800aa0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa6:	7d 0b                	jge    800ab3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa8:	83 c1 01             	add    $0x1,%ecx
  800aab:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab1:	eb b9                	jmp    800a6c <strtol+0x76>

	if (endptr)
  800ab3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab7:	74 0d                	je     800ac6 <strtol+0xd0>
		*endptr = (char *) s;
  800ab9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abc:	89 0e                	mov    %ecx,(%esi)
  800abe:	eb 06                	jmp    800ac6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac0:	85 db                	test   %ebx,%ebx
  800ac2:	74 98                	je     800a5c <strtol+0x66>
  800ac4:	eb 9e                	jmp    800a64 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac6:	89 c2                	mov    %eax,%edx
  800ac8:	f7 da                	neg    %edx
  800aca:	85 ff                	test   %edi,%edi
  800acc:	0f 45 c2             	cmovne %edx,%eax
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	89 c6                	mov    %eax,%esi
  800aeb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 cb                	mov    %ecx,%ebx
  800b29:	89 cf                	mov    %ecx,%edi
  800b2b:	89 ce                	mov    %ecx,%esi
  800b2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	7e 17                	jle    800b4a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b33:	83 ec 0c             	sub    $0xc,%esp
  800b36:	50                   	push   %eax
  800b37:	6a 03                	push   $0x3
  800b39:	68 ff 25 80 00       	push   $0x8025ff
  800b3e:	6a 23                	push   $0x23
  800b40:	68 1c 26 80 00       	push   $0x80261c
  800b45:	e8 29 12 00 00       	call   801d73 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_yield>:

void
sys_yield(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	be 00 00 00 00       	mov    $0x0,%esi
  800b9e:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bac:	89 f7                	mov    %esi,%edi
  800bae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7e 17                	jle    800bcb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 04                	push   $0x4
  800bba:	68 ff 25 80 00       	push   $0x8025ff
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 1c 26 80 00       	push   $0x80261c
  800bc6:	e8 a8 11 00 00       	call   801d73 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	b8 05 00 00 00       	mov    $0x5,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bed:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7e 17                	jle    800c0d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 05                	push   $0x5
  800bfc:	68 ff 25 80 00       	push   $0x8025ff
  800c01:	6a 23                	push   $0x23
  800c03:	68 1c 26 80 00       	push   $0x80261c
  800c08:	e8 66 11 00 00       	call   801d73 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c23:	b8 06 00 00 00       	mov    $0x6,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 df                	mov    %ebx,%edi
  800c30:	89 de                	mov    %ebx,%esi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 06                	push   $0x6
  800c3e:	68 ff 25 80 00       	push   $0x8025ff
  800c43:	6a 23                	push   $0x23
  800c45:	68 1c 26 80 00       	push   $0x80261c
  800c4a:	e8 24 11 00 00       	call   801d73 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 08                	push   $0x8
  800c80:	68 ff 25 80 00       	push   $0x8025ff
  800c85:	6a 23                	push   $0x23
  800c87:	68 1c 26 80 00       	push   $0x80261c
  800c8c:	e8 e2 10 00 00       	call   801d73 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 09                	push   $0x9
  800cc2:	68 ff 25 80 00       	push   $0x8025ff
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 1c 26 80 00       	push   $0x80261c
  800cce:	e8 a0 10 00 00       	call   801d73 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 0a                	push   $0xa
  800d04:	68 ff 25 80 00       	push   $0x8025ff
  800d09:	6a 23                	push   $0x23
  800d0b:	68 1c 26 80 00       	push   $0x80261c
  800d10:	e8 5e 10 00 00       	call   801d73 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	be 00 00 00 00       	mov    $0x0,%esi
  800d28:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d39:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 cb                	mov    %ecx,%ebx
  800d58:	89 cf                	mov    %ecx,%edi
  800d5a:	89 ce                	mov    %ecx,%esi
  800d5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 0d                	push   $0xd
  800d68:	68 ff 25 80 00       	push   $0x8025ff
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 1c 26 80 00       	push   $0x80261c
  800d74:	e8 fa 0f 00 00       	call   801d73 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 cb                	mov    %ecx,%ebx
  800d96:	89 cf                	mov    %ecx,%edi
  800d98:	89 ce                	mov    %ecx,%esi
  800d9a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	53                   	push   %ebx
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dab:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dad:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800db1:	74 11                	je     800dc4 <pgfault+0x23>
  800db3:	89 d8                	mov    %ebx,%eax
  800db5:	c1 e8 0c             	shr    $0xc,%eax
  800db8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dbf:	f6 c4 08             	test   $0x8,%ah
  800dc2:	75 14                	jne    800dd8 <pgfault+0x37>
		panic("faulting access");
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	68 2a 26 80 00       	push   $0x80262a
  800dcc:	6a 1d                	push   $0x1d
  800dce:	68 3a 26 80 00       	push   $0x80263a
  800dd3:	e8 9b 0f 00 00       	call   801d73 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	6a 07                	push   $0x7
  800ddd:	68 00 f0 7f 00       	push   $0x7ff000
  800de2:	6a 00                	push   $0x0
  800de4:	e8 a7 fd ff ff       	call   800b90 <sys_page_alloc>
	if (r < 0) {
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	85 c0                	test   %eax,%eax
  800dee:	79 12                	jns    800e02 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800df0:	50                   	push   %eax
  800df1:	68 45 26 80 00       	push   $0x802645
  800df6:	6a 2b                	push   $0x2b
  800df8:	68 3a 26 80 00       	push   $0x80263a
  800dfd:	e8 71 0f 00 00       	call   801d73 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e02:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	68 00 10 00 00       	push   $0x1000
  800e10:	53                   	push   %ebx
  800e11:	68 00 f0 7f 00       	push   $0x7ff000
  800e16:	e8 6c fb ff ff       	call   800987 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e1b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e22:	53                   	push   %ebx
  800e23:	6a 00                	push   $0x0
  800e25:	68 00 f0 7f 00       	push   $0x7ff000
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 a2 fd ff ff       	call   800bd3 <sys_page_map>
	if (r < 0) {
  800e31:	83 c4 20             	add    $0x20,%esp
  800e34:	85 c0                	test   %eax,%eax
  800e36:	79 12                	jns    800e4a <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e38:	50                   	push   %eax
  800e39:	68 45 26 80 00       	push   $0x802645
  800e3e:	6a 32                	push   $0x32
  800e40:	68 3a 26 80 00       	push   $0x80263a
  800e45:	e8 29 0f 00 00       	call   801d73 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	6a 00                	push   $0x0
  800e54:	e8 bc fd ff ff       	call   800c15 <sys_page_unmap>
	if (r < 0) {
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	79 12                	jns    800e72 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e60:	50                   	push   %eax
  800e61:	68 45 26 80 00       	push   $0x802645
  800e66:	6a 36                	push   $0x36
  800e68:	68 3a 26 80 00       	push   $0x80263a
  800e6d:	e8 01 0f 00 00       	call   801d73 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e80:	68 a1 0d 80 00       	push   $0x800da1
  800e85:	e8 2f 0f 00 00       	call   801db9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e8a:	b8 07 00 00 00       	mov    $0x7,%eax
  800e8f:	cd 30                	int    $0x30
  800e91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	79 17                	jns    800eb2 <fork+0x3b>
		panic("fork fault %e");
  800e9b:	83 ec 04             	sub    $0x4,%esp
  800e9e:	68 5e 26 80 00       	push   $0x80265e
  800ea3:	68 83 00 00 00       	push   $0x83
  800ea8:	68 3a 26 80 00       	push   $0x80263a
  800ead:	e8 c1 0e 00 00       	call   801d73 <_panic>
  800eb2:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800eb4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eb8:	75 25                	jne    800edf <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eba:	e8 93 fc ff ff       	call   800b52 <sys_getenvid>
  800ebf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ec4:	89 c2                	mov    %eax,%edx
  800ec6:	c1 e2 07             	shl    $0x7,%edx
  800ec9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800ed0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	e9 61 01 00 00       	jmp    801040 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	6a 07                	push   $0x7
  800ee4:	68 00 f0 bf ee       	push   $0xeebff000
  800ee9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eec:	e8 9f fc ff ff       	call   800b90 <sys_page_alloc>
  800ef1:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ef4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ef9:	89 d8                	mov    %ebx,%eax
  800efb:	c1 e8 16             	shr    $0x16,%eax
  800efe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f05:	a8 01                	test   $0x1,%al
  800f07:	0f 84 fc 00 00 00    	je     801009 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f0d:	89 d8                	mov    %ebx,%eax
  800f0f:	c1 e8 0c             	shr    $0xc,%eax
  800f12:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f19:	f6 c2 01             	test   $0x1,%dl
  800f1c:	0f 84 e7 00 00 00    	je     801009 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f22:	89 c6                	mov    %eax,%esi
  800f24:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f27:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2e:	f6 c6 04             	test   $0x4,%dh
  800f31:	74 39                	je     800f6c <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f42:	50                   	push   %eax
  800f43:	56                   	push   %esi
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	6a 00                	push   $0x0
  800f48:	e8 86 fc ff ff       	call   800bd3 <sys_page_map>
		if (r < 0) {
  800f4d:	83 c4 20             	add    $0x20,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	0f 89 b1 00 00 00    	jns    801009 <fork+0x192>
		    	panic("sys page map fault %e");
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	68 6c 26 80 00       	push   $0x80266c
  800f60:	6a 53                	push   $0x53
  800f62:	68 3a 26 80 00       	push   $0x80263a
  800f67:	e8 07 0e 00 00       	call   801d73 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f73:	f6 c2 02             	test   $0x2,%dl
  800f76:	75 0c                	jne    800f84 <fork+0x10d>
  800f78:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7f:	f6 c4 08             	test   $0x8,%ah
  800f82:	74 5b                	je     800fdf <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	68 05 08 00 00       	push   $0x805
  800f8c:	56                   	push   %esi
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 3d fc ff ff       	call   800bd3 <sys_page_map>
		if (r < 0) {
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 14                	jns    800fb1 <fork+0x13a>
		    	panic("sys page map fault %e");
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	68 6c 26 80 00       	push   $0x80266c
  800fa5:	6a 5a                	push   $0x5a
  800fa7:	68 3a 26 80 00       	push   $0x80263a
  800fac:	e8 c2 0d 00 00       	call   801d73 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	68 05 08 00 00       	push   $0x805
  800fb9:	56                   	push   %esi
  800fba:	6a 00                	push   $0x0
  800fbc:	56                   	push   %esi
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 0f fc ff ff       	call   800bd3 <sys_page_map>
		if (r < 0) {
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	79 3e                	jns    801009 <fork+0x192>
		    	panic("sys page map fault %e");
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	68 6c 26 80 00       	push   $0x80266c
  800fd3:	6a 5e                	push   $0x5e
  800fd5:	68 3a 26 80 00       	push   $0x80263a
  800fda:	e8 94 0d 00 00       	call   801d73 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	6a 05                	push   $0x5
  800fe4:	56                   	push   %esi
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 e5 fb ff ff       	call   800bd3 <sys_page_map>
		if (r < 0) {
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	79 14                	jns    801009 <fork+0x192>
		    	panic("sys page map fault %e");
  800ff5:	83 ec 04             	sub    $0x4,%esp
  800ff8:	68 6c 26 80 00       	push   $0x80266c
  800ffd:	6a 63                	push   $0x63
  800fff:	68 3a 26 80 00       	push   $0x80263a
  801004:	e8 6a 0d 00 00       	call   801d73 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801009:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80100f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801015:	0f 85 de fe ff ff    	jne    800ef9 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80101b:	a1 04 40 80 00       	mov    0x804004,%eax
  801020:	8b 40 6c             	mov    0x6c(%eax),%eax
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	50                   	push   %eax
  801027:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80102a:	57                   	push   %edi
  80102b:	e8 ab fc ff ff       	call   800cdb <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	6a 02                	push   $0x2
  801035:	57                   	push   %edi
  801036:	e8 1c fc ff ff       	call   800c57 <sys_env_set_status>
	
	return envid;
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <sfork>:

envid_t
sfork(void)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80104b:	b8 00 00 00 00       	mov    $0x0,%eax
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	53                   	push   %ebx
  80105e:	68 84 26 80 00       	push   $0x802684
  801063:	e8 a0 f1 ff ff       	call   800208 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  801068:	89 1c 24             	mov    %ebx,(%esp)
  80106b:	e8 11 fd ff ff       	call   800d81 <sys_thread_create>
  801070:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801072:	83 c4 08             	add    $0x8,%esp
  801075:	53                   	push   %ebx
  801076:	68 84 26 80 00       	push   $0x802684
  80107b:	e8 88 f1 ff ff       	call   800208 <cprintf>
	return id;
}
  801080:	89 f0                	mov    %esi,%eax
  801082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	05 00 00 00 30       	add    $0x30000000,%eax
  801094:	c1 e8 0c             	shr    $0xc,%eax
}
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	c1 ea 16             	shr    $0x16,%edx
  8010c0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c7:	f6 c2 01             	test   $0x1,%dl
  8010ca:	74 11                	je     8010dd <fd_alloc+0x2d>
  8010cc:	89 c2                	mov    %eax,%edx
  8010ce:	c1 ea 0c             	shr    $0xc,%edx
  8010d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d8:	f6 c2 01             	test   $0x1,%dl
  8010db:	75 09                	jne    8010e6 <fd_alloc+0x36>
			*fd_store = fd;
  8010dd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010df:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e4:	eb 17                	jmp    8010fd <fd_alloc+0x4d>
  8010e6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010eb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f0:	75 c9                	jne    8010bb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010f8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801105:	83 f8 1f             	cmp    $0x1f,%eax
  801108:	77 36                	ja     801140 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80110a:	c1 e0 0c             	shl    $0xc,%eax
  80110d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801112:	89 c2                	mov    %eax,%edx
  801114:	c1 ea 16             	shr    $0x16,%edx
  801117:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111e:	f6 c2 01             	test   $0x1,%dl
  801121:	74 24                	je     801147 <fd_lookup+0x48>
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 0c             	shr    $0xc,%edx
  801128:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	74 1a                	je     80114e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
  801137:	89 02                	mov    %eax,(%edx)
	return 0;
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	eb 13                	jmp    801153 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801140:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801145:	eb 0c                	jmp    801153 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 05                	jmp    801153 <fd_lookup+0x54>
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115e:	ba 24 27 80 00       	mov    $0x802724,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801163:	eb 13                	jmp    801178 <dev_lookup+0x23>
  801165:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801168:	39 08                	cmp    %ecx,(%eax)
  80116a:	75 0c                	jne    801178 <dev_lookup+0x23>
			*dev = devtab[i];
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
  801176:	eb 2e                	jmp    8011a6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801178:	8b 02                	mov    (%edx),%eax
  80117a:	85 c0                	test   %eax,%eax
  80117c:	75 e7                	jne    801165 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80117e:	a1 04 40 80 00       	mov    0x804004,%eax
  801183:	8b 40 50             	mov    0x50(%eax),%eax
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	51                   	push   %ecx
  80118a:	50                   	push   %eax
  80118b:	68 a8 26 80 00       	push   $0x8026a8
  801190:	e8 73 f0 ff ff       	call   800208 <cprintf>
	*dev = 0;
  801195:	8b 45 0c             	mov    0xc(%ebp),%eax
  801198:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 10             	sub    $0x10,%esp
  8011b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c0:	c1 e8 0c             	shr    $0xc,%eax
  8011c3:	50                   	push   %eax
  8011c4:	e8 36 ff ff ff       	call   8010ff <fd_lookup>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 05                	js     8011d5 <fd_close+0x2d>
	    || fd != fd2)
  8011d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011d3:	74 0c                	je     8011e1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011d5:	84 db                	test   %bl,%bl
  8011d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011dc:	0f 44 c2             	cmove  %edx,%eax
  8011df:	eb 41                	jmp    801222 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	ff 36                	pushl  (%esi)
  8011ea:	e8 66 ff ff ff       	call   801155 <dev_lookup>
  8011ef:	89 c3                	mov    %eax,%ebx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 1a                	js     801212 <fd_close+0x6a>
		if (dev->dev_close)
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801203:	85 c0                	test   %eax,%eax
  801205:	74 0b                	je     801212 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	56                   	push   %esi
  80120b:	ff d0                	call   *%eax
  80120d:	89 c3                	mov    %eax,%ebx
  80120f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	56                   	push   %esi
  801216:	6a 00                	push   $0x0
  801218:	e8 f8 f9 ff ff       	call   800c15 <sys_page_unmap>
	return r;
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	89 d8                	mov    %ebx,%eax
}
  801222:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801232:	50                   	push   %eax
  801233:	ff 75 08             	pushl  0x8(%ebp)
  801236:	e8 c4 fe ff ff       	call   8010ff <fd_lookup>
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 10                	js     801252 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	6a 01                	push   $0x1
  801247:	ff 75 f4             	pushl  -0xc(%ebp)
  80124a:	e8 59 ff ff ff       	call   8011a8 <fd_close>
  80124f:	83 c4 10             	add    $0x10,%esp
}
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <close_all>:

void
close_all(void)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	53                   	push   %ebx
  801258:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80125b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	53                   	push   %ebx
  801264:	e8 c0 ff ff ff       	call   801229 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801269:	83 c3 01             	add    $0x1,%ebx
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	83 fb 20             	cmp    $0x20,%ebx
  801272:	75 ec                	jne    801260 <close_all+0xc>
		close(i);
}
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 2c             	sub    $0x2c,%esp
  801282:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801285:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	ff 75 08             	pushl  0x8(%ebp)
  80128c:	e8 6e fe ff ff       	call   8010ff <fd_lookup>
  801291:	83 c4 08             	add    $0x8,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	0f 88 c1 00 00 00    	js     80135d <dup+0xe4>
		return r;
	close(newfdnum);
  80129c:	83 ec 0c             	sub    $0xc,%esp
  80129f:	56                   	push   %esi
  8012a0:	e8 84 ff ff ff       	call   801229 <close>

	newfd = INDEX2FD(newfdnum);
  8012a5:	89 f3                	mov    %esi,%ebx
  8012a7:	c1 e3 0c             	shl    $0xc,%ebx
  8012aa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b0:	83 c4 04             	add    $0x4,%esp
  8012b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b6:	e8 de fd ff ff       	call   801099 <fd2data>
  8012bb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012bd:	89 1c 24             	mov    %ebx,(%esp)
  8012c0:	e8 d4 fd ff ff       	call   801099 <fd2data>
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012cb:	89 f8                	mov    %edi,%eax
  8012cd:	c1 e8 16             	shr    $0x16,%eax
  8012d0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d7:	a8 01                	test   $0x1,%al
  8012d9:	74 37                	je     801312 <dup+0x99>
  8012db:	89 f8                	mov    %edi,%eax
  8012dd:	c1 e8 0c             	shr    $0xc,%eax
  8012e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e7:	f6 c2 01             	test   $0x1,%dl
  8012ea:	74 26                	je     801312 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ff:	6a 00                	push   $0x0
  801301:	57                   	push   %edi
  801302:	6a 00                	push   $0x0
  801304:	e8 ca f8 ff ff       	call   800bd3 <sys_page_map>
  801309:	89 c7                	mov    %eax,%edi
  80130b:	83 c4 20             	add    $0x20,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 2e                	js     801340 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801312:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801315:	89 d0                	mov    %edx,%eax
  801317:	c1 e8 0c             	shr    $0xc,%eax
  80131a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	25 07 0e 00 00       	and    $0xe07,%eax
  801329:	50                   	push   %eax
  80132a:	53                   	push   %ebx
  80132b:	6a 00                	push   $0x0
  80132d:	52                   	push   %edx
  80132e:	6a 00                	push   $0x0
  801330:	e8 9e f8 ff ff       	call   800bd3 <sys_page_map>
  801335:	89 c7                	mov    %eax,%edi
  801337:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80133a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133c:	85 ff                	test   %edi,%edi
  80133e:	79 1d                	jns    80135d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	53                   	push   %ebx
  801344:	6a 00                	push   $0x0
  801346:	e8 ca f8 ff ff       	call   800c15 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801351:	6a 00                	push   $0x0
  801353:	e8 bd f8 ff ff       	call   800c15 <sys_page_unmap>
	return r;
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	89 f8                	mov    %edi,%eax
}
  80135d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5f                   	pop    %edi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 14             	sub    $0x14,%esp
  80136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	53                   	push   %ebx
  801374:	e8 86 fd ff ff       	call   8010ff <fd_lookup>
  801379:	83 c4 08             	add    $0x8,%esp
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 6d                	js     8013ef <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	ff 30                	pushl  (%eax)
  80138e:	e8 c2 fd ff ff       	call   801155 <dev_lookup>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 4c                	js     8013e6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80139d:	8b 42 08             	mov    0x8(%edx),%eax
  8013a0:	83 e0 03             	and    $0x3,%eax
  8013a3:	83 f8 01             	cmp    $0x1,%eax
  8013a6:	75 21                	jne    8013c9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ad:	8b 40 50             	mov    0x50(%eax),%eax
  8013b0:	83 ec 04             	sub    $0x4,%esp
  8013b3:	53                   	push   %ebx
  8013b4:	50                   	push   %eax
  8013b5:	68 e9 26 80 00       	push   $0x8026e9
  8013ba:	e8 49 ee ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c7:	eb 26                	jmp    8013ef <read+0x8a>
	}
	if (!dev->dev_read)
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	8b 40 08             	mov    0x8(%eax),%eax
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	74 17                	je     8013ea <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	ff 75 10             	pushl  0x10(%ebp)
  8013d9:	ff 75 0c             	pushl  0xc(%ebp)
  8013dc:	52                   	push   %edx
  8013dd:	ff d0                	call   *%eax
  8013df:	89 c2                	mov    %eax,%edx
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	eb 09                	jmp    8013ef <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	eb 05                	jmp    8013ef <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013ef:	89 d0                	mov    %edx,%eax
  8013f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	57                   	push   %edi
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801402:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	eb 21                	jmp    80142d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140c:	83 ec 04             	sub    $0x4,%esp
  80140f:	89 f0                	mov    %esi,%eax
  801411:	29 d8                	sub    %ebx,%eax
  801413:	50                   	push   %eax
  801414:	89 d8                	mov    %ebx,%eax
  801416:	03 45 0c             	add    0xc(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	57                   	push   %edi
  80141b:	e8 45 ff ff ff       	call   801365 <read>
		if (m < 0)
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 10                	js     801437 <readn+0x41>
			return m;
		if (m == 0)
  801427:	85 c0                	test   %eax,%eax
  801429:	74 0a                	je     801435 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142b:	01 c3                	add    %eax,%ebx
  80142d:	39 f3                	cmp    %esi,%ebx
  80142f:	72 db                	jb     80140c <readn+0x16>
  801431:	89 d8                	mov    %ebx,%eax
  801433:	eb 02                	jmp    801437 <readn+0x41>
  801435:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801437:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	53                   	push   %ebx
  801443:	83 ec 14             	sub    $0x14,%esp
  801446:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801449:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	53                   	push   %ebx
  80144e:	e8 ac fc ff ff       	call   8010ff <fd_lookup>
  801453:	83 c4 08             	add    $0x8,%esp
  801456:	89 c2                	mov    %eax,%edx
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 68                	js     8014c4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801466:	ff 30                	pushl  (%eax)
  801468:	e8 e8 fc ff ff       	call   801155 <dev_lookup>
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 47                	js     8014bb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801474:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801477:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80147b:	75 21                	jne    80149e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80147d:	a1 04 40 80 00       	mov    0x804004,%eax
  801482:	8b 40 50             	mov    0x50(%eax),%eax
  801485:	83 ec 04             	sub    $0x4,%esp
  801488:	53                   	push   %ebx
  801489:	50                   	push   %eax
  80148a:	68 05 27 80 00       	push   $0x802705
  80148f:	e8 74 ed ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149c:	eb 26                	jmp    8014c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a4:	85 d2                	test   %edx,%edx
  8014a6:	74 17                	je     8014bf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a8:	83 ec 04             	sub    $0x4,%esp
  8014ab:	ff 75 10             	pushl  0x10(%ebp)
  8014ae:	ff 75 0c             	pushl  0xc(%ebp)
  8014b1:	50                   	push   %eax
  8014b2:	ff d2                	call   *%edx
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	eb 09                	jmp    8014c4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	eb 05                	jmp    8014c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014c4:	89 d0                	mov    %edx,%eax
  8014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <seek>:

int
seek(int fdnum, off_t offset)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 75 08             	pushl  0x8(%ebp)
  8014d8:	e8 22 fc ff ff       	call   8010ff <fd_lookup>
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 0e                	js     8014f2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ea:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 14             	sub    $0x14,%esp
  8014fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	53                   	push   %ebx
  801503:	e8 f7 fb ff ff       	call   8010ff <fd_lookup>
  801508:	83 c4 08             	add    $0x8,%esp
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 65                	js     801576 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	ff 30                	pushl  (%eax)
  80151d:	e8 33 fc ff ff       	call   801155 <dev_lookup>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 44                	js     80156d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801530:	75 21                	jne    801553 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801532:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801537:	8b 40 50             	mov    0x50(%eax),%eax
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	53                   	push   %ebx
  80153e:	50                   	push   %eax
  80153f:	68 c8 26 80 00       	push   $0x8026c8
  801544:	e8 bf ec ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801551:	eb 23                	jmp    801576 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801553:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801556:	8b 52 18             	mov    0x18(%edx),%edx
  801559:	85 d2                	test   %edx,%edx
  80155b:	74 14                	je     801571 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	50                   	push   %eax
  801564:	ff d2                	call   *%edx
  801566:	89 c2                	mov    %eax,%edx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	eb 09                	jmp    801576 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	eb 05                	jmp    801576 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801571:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801576:	89 d0                	mov    %edx,%eax
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 14             	sub    $0x14,%esp
  801584:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801587:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	ff 75 08             	pushl  0x8(%ebp)
  80158e:	e8 6c fb ff ff       	call   8010ff <fd_lookup>
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	89 c2                	mov    %eax,%edx
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 58                	js     8015f4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a6:	ff 30                	pushl  (%eax)
  8015a8:	e8 a8 fb ff ff       	call   801155 <dev_lookup>
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 37                	js     8015eb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015bb:	74 32                	je     8015ef <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c7:	00 00 00 
	stat->st_isdir = 0;
  8015ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d1:	00 00 00 
	stat->st_dev = dev;
  8015d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	53                   	push   %ebx
  8015de:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e1:	ff 50 14             	call   *0x14(%eax)
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	eb 09                	jmp    8015f4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015eb:	89 c2                	mov    %eax,%edx
  8015ed:	eb 05                	jmp    8015f4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015f4:	89 d0                	mov    %edx,%eax
  8015f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	6a 00                	push   $0x0
  801605:	ff 75 08             	pushl  0x8(%ebp)
  801608:	e8 e3 01 00 00       	call   8017f0 <open>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 1b                	js     801631 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	ff 75 0c             	pushl  0xc(%ebp)
  80161c:	50                   	push   %eax
  80161d:	e8 5b ff ff ff       	call   80157d <fstat>
  801622:	89 c6                	mov    %eax,%esi
	close(fd);
  801624:	89 1c 24             	mov    %ebx,(%esp)
  801627:	e8 fd fb ff ff       	call   801229 <close>
	return r;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	89 f0                	mov    %esi,%eax
}
  801631:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	89 c6                	mov    %eax,%esi
  80163f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801641:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801648:	75 12                	jne    80165c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	6a 01                	push   $0x1
  80164f:	e8 cb 08 00 00       	call   801f1f <ipc_find_env>
  801654:	a3 00 40 80 00       	mov    %eax,0x804000
  801659:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80165c:	6a 07                	push   $0x7
  80165e:	68 00 50 80 00       	push   $0x805000
  801663:	56                   	push   %esi
  801664:	ff 35 00 40 80 00    	pushl  0x804000
  80166a:	e8 4e 08 00 00       	call   801ebd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166f:	83 c4 0c             	add    $0xc,%esp
  801672:	6a 00                	push   $0x0
  801674:	53                   	push   %ebx
  801675:	6a 00                	push   $0x0
  801677:	e8 cc 07 00 00       	call   801e48 <ipc_recv>
}
  80167c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	8b 40 0c             	mov    0xc(%eax),%eax
  80168f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801694:	8b 45 0c             	mov    0xc(%ebp),%eax
  801697:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169c:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a6:	e8 8d ff ff ff       	call   801638 <fsipc>
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c8:	e8 6b ff ff ff       	call   801638 <fsipc>
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016df:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ee:	e8 45 ff ff ff       	call   801638 <fsipc>
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 2c                	js     801723 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	68 00 50 80 00       	push   $0x805000
  8016ff:	53                   	push   %ebx
  801700:	e8 88 f0 ff ff       	call   80078d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801705:	a1 80 50 80 00       	mov    0x805080,%eax
  80170a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801710:	a1 84 50 80 00       	mov    0x805084,%eax
  801715:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 0c             	sub    $0xc,%esp
  80172e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801731:	8b 55 08             	mov    0x8(%ebp),%edx
  801734:	8b 52 0c             	mov    0xc(%edx),%edx
  801737:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80173d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801742:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801747:	0f 47 c2             	cmova  %edx,%eax
  80174a:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80174f:	50                   	push   %eax
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	68 08 50 80 00       	push   $0x805008
  801758:	e8 c2 f1 ff ff       	call   80091f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 04 00 00 00       	mov    $0x4,%eax
  801767:	e8 cc fe ff ff       	call   801638 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	8b 40 0c             	mov    0xc(%eax),%eax
  80177c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801781:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
  80178c:	b8 03 00 00 00       	mov    $0x3,%eax
  801791:	e8 a2 fe ff ff       	call   801638 <fsipc>
  801796:	89 c3                	mov    %eax,%ebx
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 4b                	js     8017e7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80179c:	39 c6                	cmp    %eax,%esi
  80179e:	73 16                	jae    8017b6 <devfile_read+0x48>
  8017a0:	68 34 27 80 00       	push   $0x802734
  8017a5:	68 3b 27 80 00       	push   $0x80273b
  8017aa:	6a 7c                	push   $0x7c
  8017ac:	68 50 27 80 00       	push   $0x802750
  8017b1:	e8 bd 05 00 00       	call   801d73 <_panic>
	assert(r <= PGSIZE);
  8017b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017bb:	7e 16                	jle    8017d3 <devfile_read+0x65>
  8017bd:	68 5b 27 80 00       	push   $0x80275b
  8017c2:	68 3b 27 80 00       	push   $0x80273b
  8017c7:	6a 7d                	push   $0x7d
  8017c9:	68 50 27 80 00       	push   $0x802750
  8017ce:	e8 a0 05 00 00       	call   801d73 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017d3:	83 ec 04             	sub    $0x4,%esp
  8017d6:	50                   	push   %eax
  8017d7:	68 00 50 80 00       	push   $0x805000
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	e8 3b f1 ff ff       	call   80091f <memmove>
	return r;
  8017e4:	83 c4 10             	add    $0x10,%esp
}
  8017e7:	89 d8                	mov    %ebx,%eax
  8017e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 20             	sub    $0x20,%esp
  8017f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017fa:	53                   	push   %ebx
  8017fb:	e8 54 ef ff ff       	call   800754 <strlen>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801808:	7f 67                	jg     801871 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801810:	50                   	push   %eax
  801811:	e8 9a f8 ff ff       	call   8010b0 <fd_alloc>
  801816:	83 c4 10             	add    $0x10,%esp
		return r;
  801819:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 57                	js     801876 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	53                   	push   %ebx
  801823:	68 00 50 80 00       	push   $0x805000
  801828:	e8 60 ef ff ff       	call   80078d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80182d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801830:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801835:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801838:	b8 01 00 00 00       	mov    $0x1,%eax
  80183d:	e8 f6 fd ff ff       	call   801638 <fsipc>
  801842:	89 c3                	mov    %eax,%ebx
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	79 14                	jns    80185f <open+0x6f>
		fd_close(fd, 0);
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	6a 00                	push   $0x0
  801850:	ff 75 f4             	pushl  -0xc(%ebp)
  801853:	e8 50 f9 ff ff       	call   8011a8 <fd_close>
		return r;
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	89 da                	mov    %ebx,%edx
  80185d:	eb 17                	jmp    801876 <open+0x86>
	}

	return fd2num(fd);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	e8 1f f8 ff ff       	call   801089 <fd2num>
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	eb 05                	jmp    801876 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801871:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801876:	89 d0                	mov    %edx,%eax
  801878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 08 00 00 00       	mov    $0x8,%eax
  80188d:	e8 a6 fd ff ff       	call   801638 <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	ff 75 08             	pushl  0x8(%ebp)
  8018a2:	e8 f2 f7 ff ff       	call   801099 <fd2data>
  8018a7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018a9:	83 c4 08             	add    $0x8,%esp
  8018ac:	68 67 27 80 00       	push   $0x802767
  8018b1:	53                   	push   %ebx
  8018b2:	e8 d6 ee ff ff       	call   80078d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018b7:	8b 46 04             	mov    0x4(%esi),%eax
  8018ba:	2b 06                	sub    (%esi),%eax
  8018bc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c9:	00 00 00 
	stat->st_dev = &devpipe;
  8018cc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018d3:	30 80 00 
	return 0;
}
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018de:	5b                   	pop    %ebx
  8018df:	5e                   	pop    %esi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018ec:	53                   	push   %ebx
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 21 f3 ff ff       	call   800c15 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018f4:	89 1c 24             	mov    %ebx,(%esp)
  8018f7:	e8 9d f7 ff ff       	call   801099 <fd2data>
  8018fc:	83 c4 08             	add    $0x8,%esp
  8018ff:	50                   	push   %eax
  801900:	6a 00                	push   $0x0
  801902:	e8 0e f3 ff ff       	call   800c15 <sys_page_unmap>
}
  801907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 1c             	sub    $0x1c,%esp
  801915:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801918:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80191a:	a1 04 40 80 00       	mov    0x804004,%eax
  80191f:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	ff 75 e0             	pushl  -0x20(%ebp)
  801928:	e8 32 06 00 00       	call   801f5f <pageref>
  80192d:	89 c3                	mov    %eax,%ebx
  80192f:	89 3c 24             	mov    %edi,(%esp)
  801932:	e8 28 06 00 00       	call   801f5f <pageref>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	39 c3                	cmp    %eax,%ebx
  80193c:	0f 94 c1             	sete   %cl
  80193f:	0f b6 c9             	movzbl %cl,%ecx
  801942:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801945:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80194b:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80194e:	39 ce                	cmp    %ecx,%esi
  801950:	74 1b                	je     80196d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801952:	39 c3                	cmp    %eax,%ebx
  801954:	75 c4                	jne    80191a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801956:	8b 42 60             	mov    0x60(%edx),%eax
  801959:	ff 75 e4             	pushl  -0x1c(%ebp)
  80195c:	50                   	push   %eax
  80195d:	56                   	push   %esi
  80195e:	68 6e 27 80 00       	push   $0x80276e
  801963:	e8 a0 e8 ff ff       	call   800208 <cprintf>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	eb ad                	jmp    80191a <_pipeisclosed+0xe>
	}
}
  80196d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801970:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801973:	5b                   	pop    %ebx
  801974:	5e                   	pop    %esi
  801975:	5f                   	pop    %edi
  801976:	5d                   	pop    %ebp
  801977:	c3                   	ret    

00801978 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	57                   	push   %edi
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
  80197e:	83 ec 28             	sub    $0x28,%esp
  801981:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801984:	56                   	push   %esi
  801985:	e8 0f f7 ff ff       	call   801099 <fd2data>
  80198a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	bf 00 00 00 00       	mov    $0x0,%edi
  801994:	eb 4b                	jmp    8019e1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801996:	89 da                	mov    %ebx,%edx
  801998:	89 f0                	mov    %esi,%eax
  80199a:	e8 6d ff ff ff       	call   80190c <_pipeisclosed>
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	75 48                	jne    8019eb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019a3:	e8 c9 f1 ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ab:	8b 0b                	mov    (%ebx),%ecx
  8019ad:	8d 51 20             	lea    0x20(%ecx),%edx
  8019b0:	39 d0                	cmp    %edx,%eax
  8019b2:	73 e2                	jae    801996 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019bb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	c1 fa 1f             	sar    $0x1f,%edx
  8019c3:	89 d1                	mov    %edx,%ecx
  8019c5:	c1 e9 1b             	shr    $0x1b,%ecx
  8019c8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019cb:	83 e2 1f             	and    $0x1f,%edx
  8019ce:	29 ca                	sub    %ecx,%edx
  8019d0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019d8:	83 c0 01             	add    $0x1,%eax
  8019db:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019de:	83 c7 01             	add    $0x1,%edi
  8019e1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019e4:	75 c2                	jne    8019a8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e9:	eb 05                	jmp    8019f0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019eb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5f                   	pop    %edi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	57                   	push   %edi
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 18             	sub    $0x18,%esp
  801a01:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a04:	57                   	push   %edi
  801a05:	e8 8f f6 ff ff       	call   801099 <fd2data>
  801a0a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a14:	eb 3d                	jmp    801a53 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a16:	85 db                	test   %ebx,%ebx
  801a18:	74 04                	je     801a1e <devpipe_read+0x26>
				return i;
  801a1a:	89 d8                	mov    %ebx,%eax
  801a1c:	eb 44                	jmp    801a62 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a1e:	89 f2                	mov    %esi,%edx
  801a20:	89 f8                	mov    %edi,%eax
  801a22:	e8 e5 fe ff ff       	call   80190c <_pipeisclosed>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	75 32                	jne    801a5d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a2b:	e8 41 f1 ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a30:	8b 06                	mov    (%esi),%eax
  801a32:	3b 46 04             	cmp    0x4(%esi),%eax
  801a35:	74 df                	je     801a16 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a37:	99                   	cltd   
  801a38:	c1 ea 1b             	shr    $0x1b,%edx
  801a3b:	01 d0                	add    %edx,%eax
  801a3d:	83 e0 1f             	and    $0x1f,%eax
  801a40:	29 d0                	sub    %edx,%eax
  801a42:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a4d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a50:	83 c3 01             	add    $0x1,%ebx
  801a53:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a56:	75 d8                	jne    801a30 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a58:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5b:	eb 05                	jmp    801a62 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a5d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5f                   	pop    %edi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a75:	50                   	push   %eax
  801a76:	e8 35 f6 ff ff       	call   8010b0 <fd_alloc>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	89 c2                	mov    %eax,%edx
  801a80:	85 c0                	test   %eax,%eax
  801a82:	0f 88 2c 01 00 00    	js     801bb4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a88:	83 ec 04             	sub    $0x4,%esp
  801a8b:	68 07 04 00 00       	push   $0x407
  801a90:	ff 75 f4             	pushl  -0xc(%ebp)
  801a93:	6a 00                	push   $0x0
  801a95:	e8 f6 f0 ff ff       	call   800b90 <sys_page_alloc>
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	89 c2                	mov    %eax,%edx
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	0f 88 0d 01 00 00    	js     801bb4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aad:	50                   	push   %eax
  801aae:	e8 fd f5 ff ff       	call   8010b0 <fd_alloc>
  801ab3:	89 c3                	mov    %eax,%ebx
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	0f 88 e2 00 00 00    	js     801ba2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac0:	83 ec 04             	sub    $0x4,%esp
  801ac3:	68 07 04 00 00       	push   $0x407
  801ac8:	ff 75 f0             	pushl  -0x10(%ebp)
  801acb:	6a 00                	push   $0x0
  801acd:	e8 be f0 ff ff       	call   800b90 <sys_page_alloc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 c3 00 00 00    	js     801ba2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	e8 af f5 ff ff       	call   801099 <fd2data>
  801aea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aec:	83 c4 0c             	add    $0xc,%esp
  801aef:	68 07 04 00 00       	push   $0x407
  801af4:	50                   	push   %eax
  801af5:	6a 00                	push   $0x0
  801af7:	e8 94 f0 ff ff       	call   800b90 <sys_page_alloc>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 89 00 00 00    	js     801b92 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b09:	83 ec 0c             	sub    $0xc,%esp
  801b0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0f:	e8 85 f5 ff ff       	call   801099 <fd2data>
  801b14:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b1b:	50                   	push   %eax
  801b1c:	6a 00                	push   $0x0
  801b1e:	56                   	push   %esi
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 ad f0 ff ff       	call   800bd3 <sys_page_map>
  801b26:	89 c3                	mov    %eax,%ebx
  801b28:	83 c4 20             	add    $0x20,%esp
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 55                	js     801b84 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b2f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b38:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b44:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b52:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5f:	e8 25 f5 ff ff       	call   801089 <fd2num>
  801b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b67:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b69:	83 c4 04             	add    $0x4,%esp
  801b6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6f:	e8 15 f5 ff ff       	call   801089 <fd2num>
  801b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b77:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b82:	eb 30                	jmp    801bb4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	56                   	push   %esi
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 86 f0 ff ff       	call   800c15 <sys_page_unmap>
  801b8f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b92:	83 ec 08             	sub    $0x8,%esp
  801b95:	ff 75 f0             	pushl  -0x10(%ebp)
  801b98:	6a 00                	push   $0x0
  801b9a:	e8 76 f0 ff ff       	call   800c15 <sys_page_unmap>
  801b9f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ba2:	83 ec 08             	sub    $0x8,%esp
  801ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 66 f0 ff ff       	call   800c15 <sys_page_unmap>
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bb4:	89 d0                	mov    %edx,%eax
  801bb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc6:	50                   	push   %eax
  801bc7:	ff 75 08             	pushl  0x8(%ebp)
  801bca:	e8 30 f5 ff ff       	call   8010ff <fd_lookup>
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	78 18                	js     801bee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdc:	e8 b8 f4 ff ff       	call   801099 <fd2data>
	return _pipeisclosed(fd, p);
  801be1:	89 c2                	mov    %eax,%edx
  801be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be6:	e8 21 fd ff ff       	call   80190c <_pipeisclosed>
  801beb:	83 c4 10             	add    $0x10,%esp
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c00:	68 86 27 80 00       	push   $0x802786
  801c05:	ff 75 0c             	pushl  0xc(%ebp)
  801c08:	e8 80 eb ff ff       	call   80078d <strcpy>
	return 0;
}
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	57                   	push   %edi
  801c18:	56                   	push   %esi
  801c19:	53                   	push   %ebx
  801c1a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c20:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c25:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2b:	eb 2d                	jmp    801c5a <devcons_write+0x46>
		m = n - tot;
  801c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c30:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c32:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c35:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c3a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	53                   	push   %ebx
  801c41:	03 45 0c             	add    0xc(%ebp),%eax
  801c44:	50                   	push   %eax
  801c45:	57                   	push   %edi
  801c46:	e8 d4 ec ff ff       	call   80091f <memmove>
		sys_cputs(buf, m);
  801c4b:	83 c4 08             	add    $0x8,%esp
  801c4e:	53                   	push   %ebx
  801c4f:	57                   	push   %edi
  801c50:	e8 7f ee ff ff       	call   800ad4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c55:	01 de                	add    %ebx,%esi
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	89 f0                	mov    %esi,%eax
  801c5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c5f:	72 cc                	jb     801c2d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c78:	74 2a                	je     801ca4 <devcons_read+0x3b>
  801c7a:	eb 05                	jmp    801c81 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c7c:	e8 f0 ee ff ff       	call   800b71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c81:	e8 6c ee ff ff       	call   800af2 <sys_cgetc>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	74 f2                	je     801c7c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 16                	js     801ca4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c8e:	83 f8 04             	cmp    $0x4,%eax
  801c91:	74 0c                	je     801c9f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c96:	88 02                	mov    %al,(%edx)
	return 1;
  801c98:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9d:	eb 05                	jmp    801ca4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cb2:	6a 01                	push   $0x1
  801cb4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	e8 17 ee ff ff       	call   800ad4 <sys_cputs>
}
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <getchar>:

int
getchar(void)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cc8:	6a 01                	push   $0x1
  801cca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccd:	50                   	push   %eax
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 90 f6 ff ff       	call   801365 <read>
	if (r < 0)
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 0f                	js     801ceb <getchar+0x29>
		return r;
	if (r < 1)
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	7e 06                	jle    801ce6 <getchar+0x24>
		return -E_EOF;
	return c;
  801ce0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ce4:	eb 05                	jmp    801ceb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ce6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf6:	50                   	push   %eax
  801cf7:	ff 75 08             	pushl  0x8(%ebp)
  801cfa:	e8 00 f4 ff ff       	call   8010ff <fd_lookup>
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 11                	js     801d17 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d0f:	39 10                	cmp    %edx,(%eax)
  801d11:	0f 94 c0             	sete   %al
  801d14:	0f b6 c0             	movzbl %al,%eax
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <opencons>:

int
opencons(void)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	e8 88 f3 ff ff       	call   8010b0 <fd_alloc>
  801d28:	83 c4 10             	add    $0x10,%esp
		return r;
  801d2b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 3e                	js     801d6f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	68 07 04 00 00       	push   $0x407
  801d39:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3c:	6a 00                	push   $0x0
  801d3e:	e8 4d ee ff ff       	call   800b90 <sys_page_alloc>
  801d43:	83 c4 10             	add    $0x10,%esp
		return r;
  801d46:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 23                	js     801d6f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d4c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d55:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	50                   	push   %eax
  801d65:	e8 1f f3 ff ff       	call   801089 <fd2num>
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	83 c4 10             	add    $0x10,%esp
}
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d78:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d7b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d81:	e8 cc ed ff ff       	call   800b52 <sys_getenvid>
  801d86:	83 ec 0c             	sub    $0xc,%esp
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	ff 75 08             	pushl  0x8(%ebp)
  801d8f:	56                   	push   %esi
  801d90:	50                   	push   %eax
  801d91:	68 94 27 80 00       	push   $0x802794
  801d96:	e8 6d e4 ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d9b:	83 c4 18             	add    $0x18,%esp
  801d9e:	53                   	push   %ebx
  801d9f:	ff 75 10             	pushl  0x10(%ebp)
  801da2:	e8 10 e4 ff ff       	call   8001b7 <vcprintf>
	cprintf("\n");
  801da7:	c7 04 24 d4 22 80 00 	movl   $0x8022d4,(%esp)
  801dae:	e8 55 e4 ff ff       	call   800208 <cprintf>
  801db3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801db6:	cc                   	int3   
  801db7:	eb fd                	jmp    801db6 <_panic+0x43>

00801db9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dbf:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc6:	75 2a                	jne    801df2 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	6a 07                	push   $0x7
  801dcd:	68 00 f0 bf ee       	push   $0xeebff000
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 b7 ed ff ff       	call   800b90 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	79 12                	jns    801df2 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801de0:	50                   	push   %eax
  801de1:	68 b8 27 80 00       	push   $0x8027b8
  801de6:	6a 23                	push   $0x23
  801de8:	68 bc 27 80 00       	push   $0x8027bc
  801ded:	e8 81 ff ff ff       	call   801d73 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	68 24 1e 80 00       	push   $0x801e24
  801e02:	6a 00                	push   $0x0
  801e04:	e8 d2 ee ff ff       	call   800cdb <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	79 12                	jns    801e22 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e10:	50                   	push   %eax
  801e11:	68 b8 27 80 00       	push   $0x8027b8
  801e16:	6a 2c                	push   $0x2c
  801e18:	68 bc 27 80 00       	push   $0x8027bc
  801e1d:	e8 51 ff ff ff       	call   801d73 <_panic>
	}
}
  801e22:	c9                   	leave  
  801e23:	c3                   	ret    

00801e24 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e24:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e25:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e2a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e2c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e2f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e33:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e38:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e3c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e3e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e41:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e42:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e45:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e46:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e47:	c3                   	ret    

00801e48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e56:	85 c0                	test   %eax,%eax
  801e58:	75 12                	jne    801e6c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	68 00 00 c0 ee       	push   $0xeec00000
  801e62:	e8 d9 ee ff ff       	call   800d40 <sys_ipc_recv>
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	eb 0c                	jmp    801e78 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e6c:	83 ec 0c             	sub    $0xc,%esp
  801e6f:	50                   	push   %eax
  801e70:	e8 cb ee ff ff       	call   800d40 <sys_ipc_recv>
  801e75:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e78:	85 f6                	test   %esi,%esi
  801e7a:	0f 95 c1             	setne  %cl
  801e7d:	85 db                	test   %ebx,%ebx
  801e7f:	0f 95 c2             	setne  %dl
  801e82:	84 d1                	test   %dl,%cl
  801e84:	74 09                	je     801e8f <ipc_recv+0x47>
  801e86:	89 c2                	mov    %eax,%edx
  801e88:	c1 ea 1f             	shr    $0x1f,%edx
  801e8b:	84 d2                	test   %dl,%dl
  801e8d:	75 27                	jne    801eb6 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e8f:	85 f6                	test   %esi,%esi
  801e91:	74 0a                	je     801e9d <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801e93:	a1 04 40 80 00       	mov    0x804004,%eax
  801e98:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e9b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e9d:	85 db                	test   %ebx,%ebx
  801e9f:	74 0d                	je     801eae <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ea1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801eac:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eae:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb3:	8b 40 78             	mov    0x78(%eax),%eax
}
  801eb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    

00801ebd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	57                   	push   %edi
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ecf:	85 db                	test   %ebx,%ebx
  801ed1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ed6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ed9:	ff 75 14             	pushl  0x14(%ebp)
  801edc:	53                   	push   %ebx
  801edd:	56                   	push   %esi
  801ede:	57                   	push   %edi
  801edf:	e8 39 ee ff ff       	call   800d1d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	c1 ea 1f             	shr    $0x1f,%edx
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	84 d2                	test   %dl,%dl
  801eee:	74 17                	je     801f07 <ipc_send+0x4a>
  801ef0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef3:	74 12                	je     801f07 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ef5:	50                   	push   %eax
  801ef6:	68 ca 27 80 00       	push   $0x8027ca
  801efb:	6a 47                	push   $0x47
  801efd:	68 d8 27 80 00       	push   $0x8027d8
  801f02:	e8 6c fe ff ff       	call   801d73 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0a:	75 07                	jne    801f13 <ipc_send+0x56>
			sys_yield();
  801f0c:	e8 60 ec ff ff       	call   800b71 <sys_yield>
  801f11:	eb c6                	jmp    801ed9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f13:	85 c0                	test   %eax,%eax
  801f15:	75 c2                	jne    801ed9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5f                   	pop    %edi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f25:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f2a:	89 c2                	mov    %eax,%edx
  801f2c:	c1 e2 07             	shl    $0x7,%edx
  801f2f:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801f36:	8b 52 58             	mov    0x58(%edx),%edx
  801f39:	39 ca                	cmp    %ecx,%edx
  801f3b:	75 11                	jne    801f4e <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f3d:	89 c2                	mov    %eax,%edx
  801f3f:	c1 e2 07             	shl    $0x7,%edx
  801f42:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801f49:	8b 40 50             	mov    0x50(%eax),%eax
  801f4c:	eb 0f                	jmp    801f5d <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f4e:	83 c0 01             	add    $0x1,%eax
  801f51:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f56:	75 d2                	jne    801f2a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f65:	89 d0                	mov    %edx,%eax
  801f67:	c1 e8 16             	shr    $0x16,%eax
  801f6a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f71:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f76:	f6 c1 01             	test   $0x1,%cl
  801f79:	74 1d                	je     801f98 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f7b:	c1 ea 0c             	shr    $0xc,%edx
  801f7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f85:	f6 c2 01             	test   $0x1,%dl
  801f88:	74 0e                	je     801f98 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f8a:	c1 ea 0c             	shr    $0xc,%edx
  801f8d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f94:	ef 
  801f95:	0f b7 c0             	movzwl %ax,%eax
}
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    
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
