
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 e0 1e 80 00       	push   $0x801ee0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 02 08 00 00       	call   800860 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 e3 1e 80 00       	push   $0x801ee3
  80008f:	6a 01                	push   $0x1
  800091:	e8 ea 10 00 00       	call   801180 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 d9 06 00 00       	call   80077d <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 ce 10 00 00       	call   801180 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 23 23 80 00       	push   $0x802323
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 ad 10 00 00       	call   801180 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e7:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000ee:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000f1:	e8 85 0a 00 00       	call   800b7b <sys_getenvid>
  8000f6:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	50                   	push   %eax
  8000fc:	68 e8 1e 80 00       	push   $0x801ee8
  800101:	e8 2b 01 00 00       	call   800231 <cprintf>
  800106:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80010c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800119:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80011e:	89 c1                	mov    %eax,%ecx
  800120:	c1 e1 07             	shl    $0x7,%ecx
  800123:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80012a:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80012d:	39 cb                	cmp    %ecx,%ebx
  80012f:	0f 44 fa             	cmove  %edx,%edi
  800132:	b9 01 00 00 00       	mov    $0x1,%ecx
  800137:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80013a:	83 c0 01             	add    $0x1,%eax
  80013d:	81 c2 84 00 00 00    	add    $0x84,%edx
  800143:	3d 00 04 00 00       	cmp    $0x400,%eax
  800148:	75 d4                	jne    80011e <libmain+0x40>
  80014a:	89 f0                	mov    %esi,%eax
  80014c:	84 c0                	test   %al,%al
  80014e:	74 06                	je     800156 <libmain+0x78>
  800150:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80015a:	7e 0a                	jle    800166 <libmain+0x88>
		binaryname = argv[0];
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015f:	8b 00                	mov    (%eax),%eax
  800161:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800166:	83 ec 08             	sub    $0x8,%esp
  800169:	ff 75 0c             	pushl  0xc(%ebp)
  80016c:	ff 75 08             	pushl  0x8(%ebp)
  80016f:	e8 bf fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800174:	e8 0b 00 00 00       	call   800184 <exit>
}
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018a:	e8 06 0e 00 00       	call   800f95 <close_all>
	sys_env_destroy(0);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	6a 00                	push   $0x0
  800194:	e8 a1 09 00 00       	call   800b3a <sys_env_destroy>
}
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 2f 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 d4 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 b7 19 00 00       	call   801c50 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 a4 1a 00 00       	call   801d80 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 11 1f 80 00 	movsbl 0x801f11(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 89 03 00 00    	je     80070d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 1a 03 00 00    	ja     8006f2 <vprintfmt+0x38a>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 29 1f 80 00       	push   $0x801f29
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 f1 22 80 00       	push   $0x8022f1
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 22 1f 80 00       	mov    $0x801f22,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 86 02 00 00       	call   800795 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 74                	jns    8006be <vprintfmt+0x356>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 2d                	push   $0x2d
  800650:	ff d6                	call   *%esi
				num = -(long long) num;
  800652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800667:	eb 55                	jmp    8006be <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 83 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800676:	eb 46                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 74 fc ff ff       	call   8002f4 <getuint>
			base = 8;
  800680:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800685:	eb 37                	jmp    8006be <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 30                	push   $0x30
  80068d:	ff d6                	call   *%esi
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 78                	push   $0x78
  800695:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 3b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 70 fb ff ff       	call   800245 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 ae fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	51                   	push   %ecx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x39a>
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800706:	75 f7                	jne    8006ff <vprintfmt+0x397>
  800708:	e9 81 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 22                	jle    80075c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 2e 03 80 00       	push   $0x80032e
  800749:	e8 1a fc ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 9a ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 03                	jmp    80078d <strlen+0x10>
		n++;
  80078a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f7                	jne    80078a <strlen+0xd>
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	eb 03                	jmp    8007a8 <strnlen+0x13>
		n++;
  8007a5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 08                	je     8007b4 <strnlen+0x1f>
  8007ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b0:	75 f3                	jne    8007a5 <strnlen+0x10>
  8007b2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9a ff ff ff       	call   80077d <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 55 10             	mov    0x10(%ebp),%edx
  800833:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800835:	85 d2                	test   %edx,%edx
  800837:	74 21                	je     80085a <strlcpy+0x35>
  800839:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 09                	jmp    80084a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084a:	39 c2                	cmp    %eax,%edx
  80084c:	74 09                	je     800857 <strlcpy+0x32>
  80084e:	0f b6 19             	movzbl (%ecx),%ebx
  800851:	84 db                	test   %bl,%bl
  800853:	75 ec                	jne    800841 <strlcpy+0x1c>
  800855:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800857:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085a:	29 f0                	sub    %esi,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800869:	eb 06                	jmp    800871 <strcmp+0x11>
		p++, q++;
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	84 c0                	test   %al,%al
  800876:	74 04                	je     80087c <strcmp+0x1c>
  800878:	3a 02                	cmp    (%edx),%al
  80087a:	74 ef                	je     80086b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 c0             	movzbl %al,%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800895:	eb 06                	jmp    80089d <strncmp+0x17>
		n--, p++, q++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	39 d8                	cmp    %ebx,%eax
  80089f:	74 15                	je     8008b6 <strncmp+0x30>
  8008a1:	0f b6 08             	movzbl (%eax),%ecx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 04                	je     8008ac <strncmp+0x26>
  8008a8:	3a 0a                	cmp    (%edx),%cl
  8008aa:	74 eb                	je     800897 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 00             	movzbl (%eax),%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb 05                	jmp    8008bb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 07                	jmp    8008d1 <strchr+0x13>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0f                	je     8008dd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 03                	jmp    8008ee <strfind+0xf>
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 04                	je     8008f9 <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strfind+0xc>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 36                	je     800941 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 28                	jne    80093b <memset+0x40>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 23                	jne    80093b <memset+0x40>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 35                	jae    80098f <memmove+0x47>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2e                	jae    80098f <memmove+0x47>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 13                	jne    800983 <memmove+0x3b>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1d                	jmp    8009ac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0f                	jne    8009a7 <memmove+0x5f>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0a                	jne    8009a7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 05                	jmp    8009ac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 87 ff ff ff       	call   800948 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 1a                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 0a                	je     8009e9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 0f                	jmp    8009f8 <memcmp+0x35>
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 f0                	cmp    %esi,%eax
  8009f1:	75 e2                	jne    8009d5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a03:	89 c1                	mov    %eax,%ecx
  800a05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0c:	eb 0a                	jmp    800a18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	39 da                	cmp    %ebx,%edx
  800a13:	74 07                	je     800a1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	39 c8                	cmp    %ecx,%eax
  800a1a:	72 f2                	jb     800a0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 03                	jmp    800a30 <strtol+0x11>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f6                	je     800a2d <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f2                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x2a>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 11                	jmp    800a5a <strtol+0x3b>
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 08                	jne    800a5a <strtol+0x3b>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 15                	jne    800a77 <strtol+0x58>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 10                	jne    800a77 <strtol+0x58>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	75 7c                	jne    800ae9 <strtol+0xca>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 16                	jmp    800a8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 12                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 08                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 11             	movzbl (%ecx),%edx
  800a98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x8b>
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
  800aa8:	eb 22                	jmp    800acc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 57             	sub    $0x57,%edx
  800aba:	eb 10                	jmp    800acc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 16                	ja     800adc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acf:	7d 0b                	jge    800adc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ada:	eb b9                	jmp    800a95 <strtol+0x76>

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 0d                	je     800aef <strtol+0xd0>
		*endptr = (char *) s;
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	89 0e                	mov    %ecx,(%esi)
  800ae7:	eb 06                	jmp    800aef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	74 98                	je     800a85 <strtol+0x66>
  800aed:	eb 9e                	jmp    800a8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 1f 22 80 00       	push   $0x80221f
  800b67:	6a 23                	push   $0x23
  800b69:	68 3c 22 80 00       	push   $0x80223c
  800b6e:	e8 41 0f 00 00       	call   801ab4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 1f 22 80 00       	push   $0x80221f
  800be8:	6a 23                	push   $0x23
  800bea:	68 3c 22 80 00       	push   $0x80223c
  800bef:	e8 c0 0e 00 00       	call   801ab4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 1f 22 80 00       	push   $0x80221f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 3c 22 80 00       	push   $0x80223c
  800c31:	e8 7e 0e 00 00       	call   801ab4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 1f 22 80 00       	push   $0x80221f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 3c 22 80 00       	push   $0x80223c
  800c73:	e8 3c 0e 00 00       	call   801ab4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 1f 22 80 00       	push   $0x80221f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 3c 22 80 00       	push   $0x80223c
  800cb5:	e8 fa 0d 00 00       	call   801ab4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 1f 22 80 00       	push   $0x80221f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 3c 22 80 00       	push   $0x80223c
  800cf7:	e8 b8 0d 00 00       	call   801ab4 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 1f 22 80 00       	push   $0x80221f
  800d32:	6a 23                	push   $0x23
  800d34:	68 3c 22 80 00       	push   $0x80223c
  800d39:	e8 76 0d 00 00       	call   801ab4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 1f 22 80 00       	push   $0x80221f
  800d96:	6a 23                	push   $0x23
  800d98:	68 3c 22 80 00       	push   $0x80223c
  800d9d:	e8 12 0d 00 00       	call   801ab4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 cb                	mov    %ecx,%ebx
  800dbf:	89 cf                	mov    %ecx,%edi
  800dc1:	89 ce                	mov    %ecx,%esi
  800dc3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd5:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	05 00 00 00 30       	add    $0x30000000,%eax
  800de5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 16             	shr    $0x16,%edx
  800e01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 11                	je     800e1e <fd_alloc+0x2d>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	75 09                	jne    800e27 <fd_alloc+0x36>
			*fd_store = fd;
  800e1e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e20:	b8 00 00 00 00       	mov    $0x0,%eax
  800e25:	eb 17                	jmp    800e3e <fd_alloc+0x4d>
  800e27:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e2c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e31:	75 c9                	jne    800dfc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e33:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e39:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e46:	83 f8 1f             	cmp    $0x1f,%eax
  800e49:	77 36                	ja     800e81 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e4b:	c1 e0 0c             	shl    $0xc,%eax
  800e4e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	c1 ea 16             	shr    $0x16,%edx
  800e58:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5f:	f6 c2 01             	test   $0x1,%dl
  800e62:	74 24                	je     800e88 <fd_lookup+0x48>
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 0c             	shr    $0xc,%edx
  800e69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	74 1a                	je     800e8f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e78:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	eb 13                	jmp    800e94 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e86:	eb 0c                	jmp    800e94 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8d:	eb 05                	jmp    800e94 <fd_lookup+0x54>
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9f:	ba c8 22 80 00       	mov    $0x8022c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea4:	eb 13                	jmp    800eb9 <dev_lookup+0x23>
  800ea6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ea9:	39 08                	cmp    %ecx,(%eax)
  800eab:	75 0c                	jne    800eb9 <dev_lookup+0x23>
			*dev = devtab[i];
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 2e                	jmp    800ee7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb9:	8b 02                	mov    (%edx),%eax
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	75 e7                	jne    800ea6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ebf:	a1 04 40 80 00       	mov    0x804004,%eax
  800ec4:	8b 40 50             	mov    0x50(%eax),%eax
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	51                   	push   %ecx
  800ecb:	50                   	push   %eax
  800ecc:	68 4c 22 80 00       	push   $0x80224c
  800ed1:	e8 5b f3 ff ff       	call   800231 <cprintf>
	*dev = 0;
  800ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	83 ec 10             	sub    $0x10,%esp
  800ef1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efa:	50                   	push   %eax
  800efb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f01:	c1 e8 0c             	shr    $0xc,%eax
  800f04:	50                   	push   %eax
  800f05:	e8 36 ff ff ff       	call   800e40 <fd_lookup>
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 05                	js     800f16 <fd_close+0x2d>
	    || fd != fd2)
  800f11:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f14:	74 0c                	je     800f22 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f16:	84 db                	test   %bl,%bl
  800f18:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1d:	0f 44 c2             	cmove  %edx,%eax
  800f20:	eb 41                	jmp    800f63 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 36                	pushl  (%esi)
  800f2b:	e8 66 ff ff ff       	call   800e96 <dev_lookup>
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 1a                	js     800f53 <fd_close+0x6a>
		if (dev->dev_close)
  800f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 0b                	je     800f53 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	56                   	push   %esi
  800f4c:	ff d0                	call   *%eax
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 e0 fc ff ff       	call   800c3e <sys_page_unmap>
	return r;
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	89 d8                	mov    %ebx,%eax
}
  800f63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 c4 fe ff ff       	call   800e40 <fd_lookup>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 10                	js     800f93 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	6a 01                	push   $0x1
  800f88:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8b:	e8 59 ff ff ff       	call   800ee9 <fd_close>
  800f90:	83 c4 10             	add    $0x10,%esp
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <close_all>:

void
close_all(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	53                   	push   %ebx
  800f99:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	53                   	push   %ebx
  800fa5:	e8 c0 ff ff ff       	call   800f6a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800faa:	83 c3 01             	add    $0x1,%ebx
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	83 fb 20             	cmp    $0x20,%ebx
  800fb3:	75 ec                	jne    800fa1 <close_all+0xc>
		close(i);
}
  800fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 2c             	sub    $0x2c,%esp
  800fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	ff 75 08             	pushl  0x8(%ebp)
  800fcd:	e8 6e fe ff ff       	call   800e40 <fd_lookup>
  800fd2:	83 c4 08             	add    $0x8,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	0f 88 c1 00 00 00    	js     80109e <dup+0xe4>
		return r;
	close(newfdnum);
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	56                   	push   %esi
  800fe1:	e8 84 ff ff ff       	call   800f6a <close>

	newfd = INDEX2FD(newfdnum);
  800fe6:	89 f3                	mov    %esi,%ebx
  800fe8:	c1 e3 0c             	shl    $0xc,%ebx
  800feb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff1:	83 c4 04             	add    $0x4,%esp
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	e8 de fd ff ff       	call   800dda <fd2data>
  800ffc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ffe:	89 1c 24             	mov    %ebx,(%esp)
  801001:	e8 d4 fd ff ff       	call   800dda <fd2data>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100c:	89 f8                	mov    %edi,%eax
  80100e:	c1 e8 16             	shr    $0x16,%eax
  801011:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801018:	a8 01                	test   $0x1,%al
  80101a:	74 37                	je     801053 <dup+0x99>
  80101c:	89 f8                	mov    %edi,%eax
  80101e:	c1 e8 0c             	shr    $0xc,%eax
  801021:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801028:	f6 c2 01             	test   $0x1,%dl
  80102b:	74 26                	je     801053 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	25 07 0e 00 00       	and    $0xe07,%eax
  80103c:	50                   	push   %eax
  80103d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801040:	6a 00                	push   $0x0
  801042:	57                   	push   %edi
  801043:	6a 00                	push   $0x0
  801045:	e8 b2 fb ff ff       	call   800bfc <sys_page_map>
  80104a:	89 c7                	mov    %eax,%edi
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 2e                	js     801081 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801053:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801056:	89 d0                	mov    %edx,%eax
  801058:	c1 e8 0c             	shr    $0xc,%eax
  80105b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	25 07 0e 00 00       	and    $0xe07,%eax
  80106a:	50                   	push   %eax
  80106b:	53                   	push   %ebx
  80106c:	6a 00                	push   $0x0
  80106e:	52                   	push   %edx
  80106f:	6a 00                	push   $0x0
  801071:	e8 86 fb ff ff       	call   800bfc <sys_page_map>
  801076:	89 c7                	mov    %eax,%edi
  801078:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80107b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107d:	85 ff                	test   %edi,%edi
  80107f:	79 1d                	jns    80109e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	53                   	push   %ebx
  801085:	6a 00                	push   $0x0
  801087:	e8 b2 fb ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108c:	83 c4 08             	add    $0x8,%esp
  80108f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801092:	6a 00                	push   $0x0
  801094:	e8 a5 fb ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	89 f8                	mov    %edi,%eax
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 14             	sub    $0x14,%esp
  8010ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	53                   	push   %ebx
  8010b5:	e8 86 fd ff ff       	call   800e40 <fd_lookup>
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 6d                	js     801130 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cd:	ff 30                	pushl  (%eax)
  8010cf:	e8 c2 fd ff ff       	call   800e96 <dev_lookup>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 4c                	js     801127 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010de:	8b 42 08             	mov    0x8(%edx),%eax
  8010e1:	83 e0 03             	and    $0x3,%eax
  8010e4:	83 f8 01             	cmp    $0x1,%eax
  8010e7:	75 21                	jne    80110a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ee:	8b 40 50             	mov    0x50(%eax),%eax
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	53                   	push   %ebx
  8010f5:	50                   	push   %eax
  8010f6:	68 8d 22 80 00       	push   $0x80228d
  8010fb:	e8 31 f1 ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801108:	eb 26                	jmp    801130 <read+0x8a>
	}
	if (!dev->dev_read)
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	8b 40 08             	mov    0x8(%eax),%eax
  801110:	85 c0                	test   %eax,%eax
  801112:	74 17                	je     80112b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	ff 75 10             	pushl  0x10(%ebp)
  80111a:	ff 75 0c             	pushl  0xc(%ebp)
  80111d:	52                   	push   %edx
  80111e:	ff d0                	call   *%eax
  801120:	89 c2                	mov    %eax,%edx
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	eb 09                	jmp    801130 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801127:	89 c2                	mov    %eax,%edx
  801129:	eb 05                	jmp    801130 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80112b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801130:	89 d0                	mov    %edx,%eax
  801132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	8b 7d 08             	mov    0x8(%ebp),%edi
  801143:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	eb 21                	jmp    80116e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	89 f0                	mov    %esi,%eax
  801152:	29 d8                	sub    %ebx,%eax
  801154:	50                   	push   %eax
  801155:	89 d8                	mov    %ebx,%eax
  801157:	03 45 0c             	add    0xc(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	57                   	push   %edi
  80115c:	e8 45 ff ff ff       	call   8010a6 <read>
		if (m < 0)
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 10                	js     801178 <readn+0x41>
			return m;
		if (m == 0)
  801168:	85 c0                	test   %eax,%eax
  80116a:	74 0a                	je     801176 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116c:	01 c3                	add    %eax,%ebx
  80116e:	39 f3                	cmp    %esi,%ebx
  801170:	72 db                	jb     80114d <readn+0x16>
  801172:	89 d8                	mov    %ebx,%eax
  801174:	eb 02                	jmp    801178 <readn+0x41>
  801176:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 ac fc ff ff       	call   800e40 <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	89 c2                	mov    %eax,%edx
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 68                	js     801205 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	ff 30                	pushl  (%eax)
  8011a9:	e8 e8 fc ff ff       	call   800e96 <dev_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 47                	js     8011fc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bc:	75 21                	jne    8011df <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011be:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c3:	8b 40 50             	mov    0x50(%eax),%eax
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	53                   	push   %ebx
  8011ca:	50                   	push   %eax
  8011cb:	68 a9 22 80 00       	push   $0x8022a9
  8011d0:	e8 5c f0 ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011dd:	eb 26                	jmp    801205 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e5:	85 d2                	test   %edx,%edx
  8011e7:	74 17                	je     801200 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	ff 75 10             	pushl  0x10(%ebp)
  8011ef:	ff 75 0c             	pushl  0xc(%ebp)
  8011f2:	50                   	push   %eax
  8011f3:	ff d2                	call   *%edx
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	eb 09                	jmp    801205 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	eb 05                	jmp    801205 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801200:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801205:	89 d0                	mov    %edx,%eax
  801207:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <seek>:

int
seek(int fdnum, off_t offset)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801212:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 75 08             	pushl  0x8(%ebp)
  801219:	e8 22 fc ff ff       	call   800e40 <fd_lookup>
  80121e:	83 c4 08             	add    $0x8,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 0e                	js     801233 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801225:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 14             	sub    $0x14,%esp
  80123c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	53                   	push   %ebx
  801244:	e8 f7 fb ff ff       	call   800e40 <fd_lookup>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 65                	js     8012b7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125c:	ff 30                	pushl  (%eax)
  80125e:	e8 33 fc ff ff       	call   800e96 <dev_lookup>
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 44                	js     8012ae <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801271:	75 21                	jne    801294 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801273:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801278:	8b 40 50             	mov    0x50(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	53                   	push   %ebx
  80127f:	50                   	push   %eax
  801280:	68 6c 22 80 00       	push   $0x80226c
  801285:	e8 a7 ef ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801292:	eb 23                	jmp    8012b7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 18             	mov    0x18(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 14                	je     8012b2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	ff 75 0c             	pushl  0xc(%ebp)
  8012a4:	50                   	push   %eax
  8012a5:	ff d2                	call   *%edx
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	eb 09                	jmp    8012b7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	eb 05                	jmp    8012b7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b7:	89 d0                	mov    %edx,%eax
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 14             	sub    $0x14,%esp
  8012c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 6c fb ff ff       	call   800e40 <fd_lookup>
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 58                	js     801335 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	ff 30                	pushl  (%eax)
  8012e9:	e8 a8 fb ff ff       	call   800e96 <dev_lookup>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 37                	js     80132c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fc:	74 32                	je     801330 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801301:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801308:	00 00 00 
	stat->st_isdir = 0;
  80130b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801312:	00 00 00 
	stat->st_dev = dev;
  801315:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	53                   	push   %ebx
  80131f:	ff 75 f0             	pushl  -0x10(%ebp)
  801322:	ff 50 14             	call   *0x14(%eax)
  801325:	89 c2                	mov    %eax,%edx
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	eb 09                	jmp    801335 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	eb 05                	jmp    801335 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801330:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801335:	89 d0                	mov    %edx,%eax
  801337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	6a 00                	push   $0x0
  801346:	ff 75 08             	pushl  0x8(%ebp)
  801349:	e8 e3 01 00 00       	call   801531 <open>
  80134e:	89 c3                	mov    %eax,%ebx
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 1b                	js     801372 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	ff 75 0c             	pushl  0xc(%ebp)
  80135d:	50                   	push   %eax
  80135e:	e8 5b ff ff ff       	call   8012be <fstat>
  801363:	89 c6                	mov    %eax,%esi
	close(fd);
  801365:	89 1c 24             	mov    %ebx,(%esp)
  801368:	e8 fd fb ff ff       	call   800f6a <close>
	return r;
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	89 f0                	mov    %esi,%eax
}
  801372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	89 c6                	mov    %eax,%esi
  801380:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801382:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801389:	75 12                	jne    80139d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	6a 01                	push   $0x1
  801390:	e8 3c 08 00 00       	call   801bd1 <ipc_find_env>
  801395:	a3 00 40 80 00       	mov    %eax,0x804000
  80139a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139d:	6a 07                	push   $0x7
  80139f:	68 00 50 80 00       	push   $0x805000
  8013a4:	56                   	push   %esi
  8013a5:	ff 35 00 40 80 00    	pushl  0x804000
  8013ab:	e8 bf 07 00 00       	call   801b6f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b0:	83 c4 0c             	add    $0xc,%esp
  8013b3:	6a 00                	push   $0x0
  8013b5:	53                   	push   %ebx
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 3d 07 00 00       	call   801afa <ipc_recv>
}
  8013bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e7:	e8 8d ff ff ff       	call   801379 <fsipc>
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 06 00 00 00       	mov    $0x6,%eax
  801409:	e8 6b ff ff ff       	call   801379 <fsipc>
}
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	53                   	push   %ebx
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	8b 40 0c             	mov    0xc(%eax),%eax
  801420:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	b8 05 00 00 00       	mov    $0x5,%eax
  80142f:	e8 45 ff ff ff       	call   801379 <fsipc>
  801434:	85 c0                	test   %eax,%eax
  801436:	78 2c                	js     801464 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	68 00 50 80 00       	push   $0x805000
  801440:	53                   	push   %ebx
  801441:	e8 70 f3 ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801446:	a1 80 50 80 00       	mov    0x805080,%eax
  80144b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801451:	a1 84 50 80 00       	mov    0x805084,%eax
  801456:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801464:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801472:	8b 55 08             	mov    0x8(%ebp),%edx
  801475:	8b 52 0c             	mov    0xc(%edx),%edx
  801478:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80147e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801483:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801488:	0f 47 c2             	cmova  %edx,%eax
  80148b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801490:	50                   	push   %eax
  801491:	ff 75 0c             	pushl  0xc(%ebp)
  801494:	68 08 50 80 00       	push   $0x805008
  801499:	e8 aa f4 ff ff       	call   800948 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80149e:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a8:	e8 cc fe ff ff       	call   801379 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014c2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8014d2:	e8 a2 fe ff ff       	call   801379 <fsipc>
  8014d7:	89 c3                	mov    %eax,%ebx
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 4b                	js     801528 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014dd:	39 c6                	cmp    %eax,%esi
  8014df:	73 16                	jae    8014f7 <devfile_read+0x48>
  8014e1:	68 d8 22 80 00       	push   $0x8022d8
  8014e6:	68 df 22 80 00       	push   $0x8022df
  8014eb:	6a 7c                	push   $0x7c
  8014ed:	68 f4 22 80 00       	push   $0x8022f4
  8014f2:	e8 bd 05 00 00       	call   801ab4 <_panic>
	assert(r <= PGSIZE);
  8014f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014fc:	7e 16                	jle    801514 <devfile_read+0x65>
  8014fe:	68 ff 22 80 00       	push   $0x8022ff
  801503:	68 df 22 80 00       	push   $0x8022df
  801508:	6a 7d                	push   $0x7d
  80150a:	68 f4 22 80 00       	push   $0x8022f4
  80150f:	e8 a0 05 00 00       	call   801ab4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	50                   	push   %eax
  801518:	68 00 50 80 00       	push   $0x805000
  80151d:	ff 75 0c             	pushl  0xc(%ebp)
  801520:	e8 23 f4 ff ff       	call   800948 <memmove>
	return r;
  801525:	83 c4 10             	add    $0x10,%esp
}
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 20             	sub    $0x20,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80153b:	53                   	push   %ebx
  80153c:	e8 3c f2 ff ff       	call   80077d <strlen>
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801549:	7f 67                	jg     8015b2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	e8 9a f8 ff ff       	call   800df1 <fd_alloc>
  801557:	83 c4 10             	add    $0x10,%esp
		return r;
  80155a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 57                	js     8015b7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	53                   	push   %ebx
  801564:	68 00 50 80 00       	push   $0x805000
  801569:	e8 48 f2 ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80156e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801571:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801576:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801579:	b8 01 00 00 00       	mov    $0x1,%eax
  80157e:	e8 f6 fd ff ff       	call   801379 <fsipc>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	79 14                	jns    8015a0 <open+0x6f>
		fd_close(fd, 0);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	6a 00                	push   $0x0
  801591:	ff 75 f4             	pushl  -0xc(%ebp)
  801594:	e8 50 f9 ff ff       	call   800ee9 <fd_close>
		return r;
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	89 da                	mov    %ebx,%edx
  80159e:	eb 17                	jmp    8015b7 <open+0x86>
	}

	return fd2num(fd);
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a6:	e8 1f f8 ff ff       	call   800dca <fd2num>
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 05                	jmp    8015b7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015b7:	89 d0                	mov    %edx,%eax
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c9:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ce:	e8 a6 fd ff ff       	call   801379 <fsipc>
}
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    

008015d5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	e8 f2 f7 ff ff       	call   800dda <fd2data>
  8015e8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	68 0b 23 80 00       	push   $0x80230b
  8015f2:	53                   	push   %ebx
  8015f3:	e8 be f1 ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015f8:	8b 46 04             	mov    0x4(%esi),%eax
  8015fb:	2b 06                	sub    (%esi),%eax
  8015fd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801603:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160a:	00 00 00 
	stat->st_dev = &devpipe;
  80160d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801614:	30 80 00 
	return 0;
}
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
  80161c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 0c             	sub    $0xc,%esp
  80162a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80162d:	53                   	push   %ebx
  80162e:	6a 00                	push   $0x0
  801630:	e8 09 f6 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801635:	89 1c 24             	mov    %ebx,(%esp)
  801638:	e8 9d f7 ff ff       	call   800dda <fd2data>
  80163d:	83 c4 08             	add    $0x8,%esp
  801640:	50                   	push   %eax
  801641:	6a 00                	push   $0x0
  801643:	e8 f6 f5 ff ff       	call   800c3e <sys_page_unmap>
}
  801648:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	57                   	push   %edi
  801651:	56                   	push   %esi
  801652:	53                   	push   %ebx
  801653:	83 ec 1c             	sub    $0x1c,%esp
  801656:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801659:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80165b:	a1 04 40 80 00       	mov    0x804004,%eax
  801660:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	ff 75 e0             	pushl  -0x20(%ebp)
  801669:	e8 a3 05 00 00       	call   801c11 <pageref>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	89 3c 24             	mov    %edi,(%esp)
  801673:	e8 99 05 00 00       	call   801c11 <pageref>
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	39 c3                	cmp    %eax,%ebx
  80167d:	0f 94 c1             	sete   %cl
  801680:	0f b6 c9             	movzbl %cl,%ecx
  801683:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801686:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80168c:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80168f:	39 ce                	cmp    %ecx,%esi
  801691:	74 1b                	je     8016ae <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801693:	39 c3                	cmp    %eax,%ebx
  801695:	75 c4                	jne    80165b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801697:	8b 42 60             	mov    0x60(%edx),%eax
  80169a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169d:	50                   	push   %eax
  80169e:	56                   	push   %esi
  80169f:	68 12 23 80 00       	push   $0x802312
  8016a4:	e8 88 eb ff ff       	call   800231 <cprintf>
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	eb ad                	jmp    80165b <_pipeisclosed+0xe>
	}
}
  8016ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5f                   	pop    %edi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 28             	sub    $0x28,%esp
  8016c2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016c5:	56                   	push   %esi
  8016c6:	e8 0f f7 ff ff       	call   800dda <fd2data>
  8016cb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8016d5:	eb 4b                	jmp    801722 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016d7:	89 da                	mov    %ebx,%edx
  8016d9:	89 f0                	mov    %esi,%eax
  8016db:	e8 6d ff ff ff       	call   80164d <_pipeisclosed>
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	75 48                	jne    80172c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016e4:	e8 b1 f4 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e9:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ec:	8b 0b                	mov    (%ebx),%ecx
  8016ee:	8d 51 20             	lea    0x20(%ecx),%edx
  8016f1:	39 d0                	cmp    %edx,%eax
  8016f3:	73 e2                	jae    8016d7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016fc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	c1 fa 1f             	sar    $0x1f,%edx
  801704:	89 d1                	mov    %edx,%ecx
  801706:	c1 e9 1b             	shr    $0x1b,%ecx
  801709:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80170c:	83 e2 1f             	and    $0x1f,%edx
  80170f:	29 ca                	sub    %ecx,%edx
  801711:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801715:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801719:	83 c0 01             	add    $0x1,%eax
  80171c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171f:	83 c7 01             	add    $0x1,%edi
  801722:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801725:	75 c2                	jne    8016e9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801727:	8b 45 10             	mov    0x10(%ebp),%eax
  80172a:	eb 05                	jmp    801731 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80172c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801731:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5f                   	pop    %edi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	57                   	push   %edi
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 18             	sub    $0x18,%esp
  801742:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801745:	57                   	push   %edi
  801746:	e8 8f f6 ff ff       	call   800dda <fd2data>
  80174b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	bb 00 00 00 00       	mov    $0x0,%ebx
  801755:	eb 3d                	jmp    801794 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801757:	85 db                	test   %ebx,%ebx
  801759:	74 04                	je     80175f <devpipe_read+0x26>
				return i;
  80175b:	89 d8                	mov    %ebx,%eax
  80175d:	eb 44                	jmp    8017a3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80175f:	89 f2                	mov    %esi,%edx
  801761:	89 f8                	mov    %edi,%eax
  801763:	e8 e5 fe ff ff       	call   80164d <_pipeisclosed>
  801768:	85 c0                	test   %eax,%eax
  80176a:	75 32                	jne    80179e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80176c:	e8 29 f4 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801771:	8b 06                	mov    (%esi),%eax
  801773:	3b 46 04             	cmp    0x4(%esi),%eax
  801776:	74 df                	je     801757 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801778:	99                   	cltd   
  801779:	c1 ea 1b             	shr    $0x1b,%edx
  80177c:	01 d0                	add    %edx,%eax
  80177e:	83 e0 1f             	and    $0x1f,%eax
  801781:	29 d0                	sub    %edx,%eax
  801783:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80178e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801791:	83 c3 01             	add    $0x1,%ebx
  801794:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801797:	75 d8                	jne    801771 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801799:	8b 45 10             	mov    0x10(%ebp),%eax
  80179c:	eb 05                	jmp    8017a3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80179e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5f                   	pop    %edi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	e8 35 f6 ff ff       	call   800df1 <fd_alloc>
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	0f 88 2c 01 00 00    	js     8018f5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	68 07 04 00 00       	push   $0x407
  8017d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 de f3 ff ff       	call   800bb9 <sys_page_alloc>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	89 c2                	mov    %eax,%edx
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	0f 88 0d 01 00 00    	js     8018f5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017e8:	83 ec 0c             	sub    $0xc,%esp
  8017eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ee:	50                   	push   %eax
  8017ef:	e8 fd f5 ff ff       	call   800df1 <fd_alloc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	0f 88 e2 00 00 00    	js     8018e3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801801:	83 ec 04             	sub    $0x4,%esp
  801804:	68 07 04 00 00       	push   $0x407
  801809:	ff 75 f0             	pushl  -0x10(%ebp)
  80180c:	6a 00                	push   $0x0
  80180e:	e8 a6 f3 ff ff       	call   800bb9 <sys_page_alloc>
  801813:	89 c3                	mov    %eax,%ebx
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	85 c0                	test   %eax,%eax
  80181a:	0f 88 c3 00 00 00    	js     8018e3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	ff 75 f4             	pushl  -0xc(%ebp)
  801826:	e8 af f5 ff ff       	call   800dda <fd2data>
  80182b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182d:	83 c4 0c             	add    $0xc,%esp
  801830:	68 07 04 00 00       	push   $0x407
  801835:	50                   	push   %eax
  801836:	6a 00                	push   $0x0
  801838:	e8 7c f3 ff ff       	call   800bb9 <sys_page_alloc>
  80183d:	89 c3                	mov    %eax,%ebx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	0f 88 89 00 00 00    	js     8018d3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	ff 75 f0             	pushl  -0x10(%ebp)
  801850:	e8 85 f5 ff ff       	call   800dda <fd2data>
  801855:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80185c:	50                   	push   %eax
  80185d:	6a 00                	push   $0x0
  80185f:	56                   	push   %esi
  801860:	6a 00                	push   $0x0
  801862:	e8 95 f3 ff ff       	call   800bfc <sys_page_map>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 20             	add    $0x20,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 55                	js     8018c5 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801870:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801885:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801893:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a0:	e8 25 f5 ff ff       	call   800dca <fd2num>
  8018a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018aa:	83 c4 04             	add    $0x4,%esp
  8018ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b0:	e8 15 f5 ff ff       	call   800dca <fd2num>
  8018b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b8:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	eb 30                	jmp    8018f5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	56                   	push   %esi
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 6e f3 ff ff       	call   800c3e <sys_page_unmap>
  8018d0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d9:	6a 00                	push   $0x0
  8018db:	e8 5e f3 ff ff       	call   800c3e <sys_page_unmap>
  8018e0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e9:	6a 00                	push   $0x0
  8018eb:	e8 4e f3 ff ff       	call   800c3e <sys_page_unmap>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018f5:	89 d0                	mov    %edx,%eax
  8018f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801904:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	ff 75 08             	pushl  0x8(%ebp)
  80190b:	e8 30 f5 ff ff       	call   800e40 <fd_lookup>
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	78 18                	js     80192f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	ff 75 f4             	pushl  -0xc(%ebp)
  80191d:	e8 b8 f4 ff ff       	call   800dda <fd2data>
	return _pipeisclosed(fd, p);
  801922:	89 c2                	mov    %eax,%edx
  801924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801927:	e8 21 fd ff ff       	call   80164d <_pipeisclosed>
  80192c:	83 c4 10             	add    $0x10,%esp
}
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801941:	68 2a 23 80 00       	push   $0x80232a
  801946:	ff 75 0c             	pushl  0xc(%ebp)
  801949:	e8 68 ee ff ff       	call   8007b6 <strcpy>
	return 0;
}
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801961:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801966:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196c:	eb 2d                	jmp    80199b <devcons_write+0x46>
		m = n - tot;
  80196e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801971:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801973:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801976:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80197b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80197e:	83 ec 04             	sub    $0x4,%esp
  801981:	53                   	push   %ebx
  801982:	03 45 0c             	add    0xc(%ebp),%eax
  801985:	50                   	push   %eax
  801986:	57                   	push   %edi
  801987:	e8 bc ef ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  80198c:	83 c4 08             	add    $0x8,%esp
  80198f:	53                   	push   %ebx
  801990:	57                   	push   %edi
  801991:	e8 67 f1 ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801996:	01 de                	add    %ebx,%esi
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	89 f0                	mov    %esi,%eax
  80199d:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019a0:	72 cc                	jb     80196e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5f                   	pop    %edi
  8019a8:	5d                   	pop    %ebp
  8019a9:	c3                   	ret    

008019aa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019b9:	74 2a                	je     8019e5 <devcons_read+0x3b>
  8019bb:	eb 05                	jmp    8019c2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019bd:	e8 d8 f1 ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019c2:	e8 54 f1 ff ff       	call   800b1b <sys_cgetc>
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	74 f2                	je     8019bd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 16                	js     8019e5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019cf:	83 f8 04             	cmp    $0x4,%eax
  8019d2:	74 0c                	je     8019e0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d7:	88 02                	mov    %al,(%edx)
	return 1;
  8019d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019de:	eb 05                	jmp    8019e5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019f3:	6a 01                	push   $0x1
  8019f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f8:	50                   	push   %eax
  8019f9:	e8 ff f0 ff ff       	call   800afd <sys_cputs>
}
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <getchar>:

int
getchar(void)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a09:	6a 01                	push   $0x1
  801a0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a0e:	50                   	push   %eax
  801a0f:	6a 00                	push   $0x0
  801a11:	e8 90 f6 ff ff       	call   8010a6 <read>
	if (r < 0)
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 0f                	js     801a2c <getchar+0x29>
		return r;
	if (r < 1)
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	7e 06                	jle    801a27 <getchar+0x24>
		return -E_EOF;
	return c;
  801a21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a25:	eb 05                	jmp    801a2c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a37:	50                   	push   %eax
  801a38:	ff 75 08             	pushl  0x8(%ebp)
  801a3b:	e8 00 f4 ff ff       	call   800e40 <fd_lookup>
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 11                	js     801a58 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a50:	39 10                	cmp    %edx,(%eax)
  801a52:	0f 94 c0             	sete   %al
  801a55:	0f b6 c0             	movzbl %al,%eax
}
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <opencons>:

int
opencons(void)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a63:	50                   	push   %eax
  801a64:	e8 88 f3 ff ff       	call   800df1 <fd_alloc>
  801a69:	83 c4 10             	add    $0x10,%esp
		return r;
  801a6c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 3e                	js     801ab0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a72:	83 ec 04             	sub    $0x4,%esp
  801a75:	68 07 04 00 00       	push   $0x407
  801a7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 35 f1 ff ff       	call   800bb9 <sys_page_alloc>
  801a84:	83 c4 10             	add    $0x10,%esp
		return r;
  801a87:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 23                	js     801ab0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a96:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	50                   	push   %eax
  801aa6:	e8 1f f3 ff ff       	call   800dca <fd2num>
  801aab:	89 c2                	mov    %eax,%edx
  801aad:	83 c4 10             	add    $0x10,%esp
}
  801ab0:	89 d0                	mov    %edx,%eax
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ab9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801abc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ac2:	e8 b4 f0 ff ff       	call   800b7b <sys_getenvid>
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	ff 75 0c             	pushl  0xc(%ebp)
  801acd:	ff 75 08             	pushl  0x8(%ebp)
  801ad0:	56                   	push   %esi
  801ad1:	50                   	push   %eax
  801ad2:	68 38 23 80 00       	push   $0x802338
  801ad7:	e8 55 e7 ff ff       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801adc:	83 c4 18             	add    $0x18,%esp
  801adf:	53                   	push   %ebx
  801ae0:	ff 75 10             	pushl  0x10(%ebp)
  801ae3:	e8 f8 e6 ff ff       	call   8001e0 <vcprintf>
	cprintf("\n");
  801ae8:	c7 04 24 23 23 80 00 	movl   $0x802323,(%esp)
  801aef:	e8 3d e7 ff ff       	call   800231 <cprintf>
  801af4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801af7:	cc                   	int3   
  801af8:	eb fd                	jmp    801af7 <_panic+0x43>

00801afa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	8b 75 08             	mov    0x8(%ebp),%esi
  801b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	75 12                	jne    801b1e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b0c:	83 ec 0c             	sub    $0xc,%esp
  801b0f:	68 00 00 c0 ee       	push   $0xeec00000
  801b14:	e8 50 f2 ff ff       	call   800d69 <sys_ipc_recv>
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	eb 0c                	jmp    801b2a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	50                   	push   %eax
  801b22:	e8 42 f2 ff ff       	call   800d69 <sys_ipc_recv>
  801b27:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b2a:	85 f6                	test   %esi,%esi
  801b2c:	0f 95 c1             	setne  %cl
  801b2f:	85 db                	test   %ebx,%ebx
  801b31:	0f 95 c2             	setne  %dl
  801b34:	84 d1                	test   %dl,%cl
  801b36:	74 09                	je     801b41 <ipc_recv+0x47>
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	c1 ea 1f             	shr    $0x1f,%edx
  801b3d:	84 d2                	test   %dl,%dl
  801b3f:	75 27                	jne    801b68 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b41:	85 f6                	test   %esi,%esi
  801b43:	74 0a                	je     801b4f <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b45:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4a:	8b 40 7c             	mov    0x7c(%eax),%eax
  801b4d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b4f:	85 db                	test   %ebx,%ebx
  801b51:	74 0d                	je     801b60 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801b53:	a1 04 40 80 00       	mov    0x804004,%eax
  801b58:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801b5e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b60:	a1 04 40 80 00       	mov    0x804004,%eax
  801b65:	8b 40 78             	mov    0x78(%eax),%eax
}
  801b68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	57                   	push   %edi
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	83 ec 0c             	sub    $0xc,%esp
  801b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b81:	85 db                	test   %ebx,%ebx
  801b83:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b88:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b8b:	ff 75 14             	pushl  0x14(%ebp)
  801b8e:	53                   	push   %ebx
  801b8f:	56                   	push   %esi
  801b90:	57                   	push   %edi
  801b91:	e8 b0 f1 ff ff       	call   800d46 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	c1 ea 1f             	shr    $0x1f,%edx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	84 d2                	test   %dl,%dl
  801ba0:	74 17                	je     801bb9 <ipc_send+0x4a>
  801ba2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba5:	74 12                	je     801bb9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ba7:	50                   	push   %eax
  801ba8:	68 5c 23 80 00       	push   $0x80235c
  801bad:	6a 47                	push   $0x47
  801baf:	68 6a 23 80 00       	push   $0x80236a
  801bb4:	e8 fb fe ff ff       	call   801ab4 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801bb9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bbc:	75 07                	jne    801bc5 <ipc_send+0x56>
			sys_yield();
  801bbe:	e8 d7 ef ff ff       	call   800b9a <sys_yield>
  801bc3:	eb c6                	jmp    801b8b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	75 c2                	jne    801b8b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bdc:	89 c2                	mov    %eax,%edx
  801bde:	c1 e2 07             	shl    $0x7,%edx
  801be1:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801be8:	8b 52 58             	mov    0x58(%edx),%edx
  801beb:	39 ca                	cmp    %ecx,%edx
  801bed:	75 11                	jne    801c00 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801bef:	89 c2                	mov    %eax,%edx
  801bf1:	c1 e2 07             	shl    $0x7,%edx
  801bf4:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801bfb:	8b 40 50             	mov    0x50(%eax),%eax
  801bfe:	eb 0f                	jmp    801c0f <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c00:	83 c0 01             	add    $0x1,%eax
  801c03:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c08:	75 d2                	jne    801bdc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c17:	89 d0                	mov    %edx,%eax
  801c19:	c1 e8 16             	shr    $0x16,%eax
  801c1c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c28:	f6 c1 01             	test   $0x1,%cl
  801c2b:	74 1d                	je     801c4a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c2d:	c1 ea 0c             	shr    $0xc,%edx
  801c30:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c37:	f6 c2 01             	test   $0x1,%dl
  801c3a:	74 0e                	je     801c4a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c3c:	c1 ea 0c             	shr    $0xc,%edx
  801c3f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c46:	ef 
  801c47:	0f b7 c0             	movzwl %ax,%eax
}
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 1c             	sub    $0x1c,%esp
  801c57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c67:	85 f6                	test   %esi,%esi
  801c69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6d:	89 ca                	mov    %ecx,%edx
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	75 3d                	jne    801cb0 <__udivdi3+0x60>
  801c73:	39 cf                	cmp    %ecx,%edi
  801c75:	0f 87 c5 00 00 00    	ja     801d40 <__udivdi3+0xf0>
  801c7b:	85 ff                	test   %edi,%edi
  801c7d:	89 fd                	mov    %edi,%ebp
  801c7f:	75 0b                	jne    801c8c <__udivdi3+0x3c>
  801c81:	b8 01 00 00 00       	mov    $0x1,%eax
  801c86:	31 d2                	xor    %edx,%edx
  801c88:	f7 f7                	div    %edi
  801c8a:	89 c5                	mov    %eax,%ebp
  801c8c:	89 c8                	mov    %ecx,%eax
  801c8e:	31 d2                	xor    %edx,%edx
  801c90:	f7 f5                	div    %ebp
  801c92:	89 c1                	mov    %eax,%ecx
  801c94:	89 d8                	mov    %ebx,%eax
  801c96:	89 cf                	mov    %ecx,%edi
  801c98:	f7 f5                	div    %ebp
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	39 ce                	cmp    %ecx,%esi
  801cb2:	77 74                	ja     801d28 <__udivdi3+0xd8>
  801cb4:	0f bd fe             	bsr    %esi,%edi
  801cb7:	83 f7 1f             	xor    $0x1f,%edi
  801cba:	0f 84 98 00 00 00    	je     801d58 <__udivdi3+0x108>
  801cc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	89 c5                	mov    %eax,%ebp
  801cc9:	29 fb                	sub    %edi,%ebx
  801ccb:	d3 e6                	shl    %cl,%esi
  801ccd:	89 d9                	mov    %ebx,%ecx
  801ccf:	d3 ed                	shr    %cl,%ebp
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 e0                	shl    %cl,%eax
  801cd5:	09 ee                	or     %ebp,%esi
  801cd7:	89 d9                	mov    %ebx,%ecx
  801cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdd:	89 d5                	mov    %edx,%ebp
  801cdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ce3:	d3 ed                	shr    %cl,%ebp
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e2                	shl    %cl,%edx
  801ce9:	89 d9                	mov    %ebx,%ecx
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	09 c2                	or     %eax,%edx
  801cef:	89 d0                	mov    %edx,%eax
  801cf1:	89 ea                	mov    %ebp,%edx
  801cf3:	f7 f6                	div    %esi
  801cf5:	89 d5                	mov    %edx,%ebp
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	f7 64 24 0c          	mull   0xc(%esp)
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	72 10                	jb     801d11 <__udivdi3+0xc1>
  801d01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	d3 e6                	shl    %cl,%esi
  801d09:	39 c6                	cmp    %eax,%esi
  801d0b:	73 07                	jae    801d14 <__udivdi3+0xc4>
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	75 03                	jne    801d14 <__udivdi3+0xc4>
  801d11:	83 eb 01             	sub    $0x1,%ebx
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 d8                	mov    %ebx,%eax
  801d18:	89 fa                	mov    %edi,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	31 ff                	xor    %edi,%edi
  801d2a:	31 db                	xor    %ebx,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
  801d38:	90                   	nop
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 d8                	mov    %ebx,%eax
  801d42:	f7 f7                	div    %edi
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 fa                	mov    %edi,%edx
  801d4c:	83 c4 1c             	add    $0x1c,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	39 ce                	cmp    %ecx,%esi
  801d5a:	72 0c                	jb     801d68 <__udivdi3+0x118>
  801d5c:	31 db                	xor    %ebx,%ebx
  801d5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d62:	0f 87 34 ff ff ff    	ja     801c9c <__udivdi3+0x4c>
  801d68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d6d:	e9 2a ff ff ff       	jmp    801c9c <__udivdi3+0x4c>
  801d72:	66 90                	xchg   %ax,%ax
  801d74:	66 90                	xchg   %ax,%ax
  801d76:	66 90                	xchg   %ax,%ax
  801d78:	66 90                	xchg   %ax,%ax
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	55                   	push   %ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 1c             	sub    $0x1c,%esp
  801d87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d97:	85 d2                	test   %edx,%edx
  801d99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 f3                	mov    %esi,%ebx
  801da3:	89 3c 24             	mov    %edi,(%esp)
  801da6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801daa:	75 1c                	jne    801dc8 <__umoddi3+0x48>
  801dac:	39 f7                	cmp    %esi,%edi
  801dae:	76 50                	jbe    801e00 <__umoddi3+0x80>
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	f7 f7                	div    %edi
  801db6:	89 d0                	mov    %edx,%eax
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	83 c4 1c             	add    $0x1c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    
  801dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc8:	39 f2                	cmp    %esi,%edx
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	77 52                	ja     801e20 <__umoddi3+0xa0>
  801dce:	0f bd ea             	bsr    %edx,%ebp
  801dd1:	83 f5 1f             	xor    $0x1f,%ebp
  801dd4:	75 5a                	jne    801e30 <__umoddi3+0xb0>
  801dd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	39 0c 24             	cmp    %ecx,(%esp)
  801de3:	0f 86 d7 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801de9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ded:	8b 54 24 04          	mov    0x4(%esp),%edx
  801df1:	83 c4 1c             	add    $0x1c,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	85 ff                	test   %edi,%edi
  801e02:	89 fd                	mov    %edi,%ebp
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 c8                	mov    %ecx,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	eb 99                	jmp    801db8 <__umoddi3+0x38>
  801e1f:	90                   	nop
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 1c             	add    $0x1c,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	8b 34 24             	mov    (%esp),%esi
  801e33:	bf 20 00 00 00       	mov    $0x20,%edi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	29 ef                	sub    %ebp,%edi
  801e3c:	d3 e0                	shl    %cl,%eax
  801e3e:	89 f9                	mov    %edi,%ecx
  801e40:	89 f2                	mov    %esi,%edx
  801e42:	d3 ea                	shr    %cl,%edx
  801e44:	89 e9                	mov    %ebp,%ecx
  801e46:	09 c2                	or     %eax,%edx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 14 24             	mov    %edx,(%esp)
  801e4d:	89 f2                	mov    %esi,%edx
  801e4f:	d3 e2                	shl    %cl,%edx
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	89 c6                	mov    %eax,%esi
  801e61:	d3 e3                	shl    %cl,%ebx
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	09 d8                	or     %ebx,%eax
  801e6d:	89 d3                	mov    %edx,%ebx
  801e6f:	89 f2                	mov    %esi,%edx
  801e71:	f7 34 24             	divl   (%esp)
  801e74:	89 d6                	mov    %edx,%esi
  801e76:	d3 e3                	shl    %cl,%ebx
  801e78:	f7 64 24 04          	mull   0x4(%esp)
  801e7c:	39 d6                	cmp    %edx,%esi
  801e7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e82:	89 d1                	mov    %edx,%ecx
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	72 08                	jb     801e90 <__umoddi3+0x110>
  801e88:	75 11                	jne    801e9b <__umoddi3+0x11b>
  801e8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e8e:	73 0b                	jae    801e9b <__umoddi3+0x11b>
  801e90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e94:	1b 14 24             	sbb    (%esp),%edx
  801e97:	89 d1                	mov    %edx,%ecx
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e9f:	29 da                	sub    %ebx,%edx
  801ea1:	19 ce                	sbb    %ecx,%esi
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 f0                	mov    %esi,%eax
  801ea7:	d3 e0                	shl    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	d3 ea                	shr    %cl,%edx
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	d3 ee                	shr    %cl,%esi
  801eb1:	09 d0                	or     %edx,%eax
  801eb3:	89 f2                	mov    %esi,%edx
  801eb5:	83 c4 1c             	add    $0x1c,%esp
  801eb8:	5b                   	pop    %ebx
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 f9                	sub    %edi,%ecx
  801ec2:	19 d6                	sbb    %edx,%esi
  801ec4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ecc:	e9 18 ff ff ff       	jmp    801de9 <__umoddi3+0x69>
