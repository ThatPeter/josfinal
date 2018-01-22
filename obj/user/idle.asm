
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 60 	movl   $0x801e60,0x803000
  800040:	1e 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 be 0a 00 00       	call   800b06 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	57                   	push   %edi
  80004e:	56                   	push   %esi
  80004f:	53                   	push   %ebx
  800050:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80005a:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80005d:	e8 85 0a 00 00       	call   800ae7 <sys_getenvid>
  800062:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	50                   	push   %eax
  800068:	68 68 1e 80 00       	push   $0x801e68
  80006d:	e8 2b 01 00 00       	call   80019d <cprintf>
  800072:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800078:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800085:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80008a:	89 c1                	mov    %eax,%ecx
  80008c:	c1 e1 07             	shl    $0x7,%ecx
  80008f:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800096:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800099:	39 cb                	cmp    %ecx,%ebx
  80009b:	0f 44 fa             	cmove  %edx,%edi
  80009e:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a3:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a6:	83 c0 01             	add    $0x1,%eax
  8000a9:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000b4:	75 d4                	jne    80008a <libmain+0x40>
  8000b6:	89 f0                	mov    %esi,%eax
  8000b8:	84 c0                	test   %al,%al
  8000ba:	74 06                	je     8000c2 <libmain+0x78>
  8000bc:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c6:	7e 0a                	jle    8000d2 <libmain+0x88>
		binaryname = argv[0];
  8000c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cb:	8b 00                	mov    (%eax),%eax
  8000cd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	ff 75 0c             	pushl  0xc(%ebp)
  8000d8:	ff 75 08             	pushl  0x8(%ebp)
  8000db:	e8 53 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f6:	e8 06 0e 00 00       	call   800f01 <close_all>
	sys_env_destroy(0);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	6a 00                	push   $0x0
  800100:	e8 a1 09 00 00       	call   800aa6 <sys_env_destroy>
}
  800105:	83 c4 10             	add    $0x10,%esp
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	53                   	push   %ebx
  80010e:	83 ec 04             	sub    $0x4,%esp
  800111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800114:	8b 13                	mov    (%ebx),%edx
  800116:	8d 42 01             	lea    0x1(%edx),%eax
  800119:	89 03                	mov    %eax,(%ebx)
  80011b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800122:	3d ff 00 00 00       	cmp    $0xff,%eax
  800127:	75 1a                	jne    800143 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 2f 09 00 00       	call   800a69 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800143:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800155:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015c:	00 00 00 
	b.cnt = 0;
  80015f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800166:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800169:	ff 75 0c             	pushl  0xc(%ebp)
  80016c:	ff 75 08             	pushl  0x8(%ebp)
  80016f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800175:	50                   	push   %eax
  800176:	68 0a 01 80 00       	push   $0x80010a
  80017b:	e8 54 01 00 00       	call   8002d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800180:	83 c4 08             	add    $0x8,%esp
  800183:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800189:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018f:	50                   	push   %eax
  800190:	e8 d4 08 00 00       	call   800a69 <sys_cputs>

	return b.cnt;
}
  800195:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a6:	50                   	push   %eax
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	e8 9d ff ff ff       	call   80014c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	57                   	push   %edi
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	83 ec 1c             	sub    $0x1c,%esp
  8001ba:	89 c7                	mov    %eax,%edi
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d8:	39 d3                	cmp    %edx,%ebx
  8001da:	72 05                	jb     8001e1 <printnum+0x30>
  8001dc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001df:	77 45                	ja     800226 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	ff 75 18             	pushl  0x18(%ebp)
  8001e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ea:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ed:	53                   	push   %ebx
  8001ee:	ff 75 10             	pushl  0x10(%ebp)
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	e8 bb 19 00 00       	call   801bc0 <__udivdi3>
  800205:	83 c4 18             	add    $0x18,%esp
  800208:	52                   	push   %edx
  800209:	50                   	push   %eax
  80020a:	89 f2                	mov    %esi,%edx
  80020c:	89 f8                	mov    %edi,%eax
  80020e:	e8 9e ff ff ff       	call   8001b1 <printnum>
  800213:	83 c4 20             	add    $0x20,%esp
  800216:	eb 18                	jmp    800230 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	56                   	push   %esi
  80021c:	ff 75 18             	pushl  0x18(%ebp)
  80021f:	ff d7                	call   *%edi
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	eb 03                	jmp    800229 <printnum+0x78>
  800226:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800229:	83 eb 01             	sub    $0x1,%ebx
  80022c:	85 db                	test   %ebx,%ebx
  80022e:	7f e8                	jg     800218 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	56                   	push   %esi
  800234:	83 ec 04             	sub    $0x4,%esp
  800237:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023a:	ff 75 e0             	pushl  -0x20(%ebp)
  80023d:	ff 75 dc             	pushl  -0x24(%ebp)
  800240:	ff 75 d8             	pushl  -0x28(%ebp)
  800243:	e8 a8 1a 00 00       	call   801cf0 <__umoddi3>
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	0f be 80 91 1e 80 00 	movsbl 0x801e91(%eax),%eax
  800252:	50                   	push   %eax
  800253:	ff d7                	call   *%edi
}
  800255:	83 c4 10             	add    $0x10,%esp
  800258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5f                   	pop    %edi
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800263:	83 fa 01             	cmp    $0x1,%edx
  800266:	7e 0e                	jle    800276 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	8b 52 04             	mov    0x4(%edx),%edx
  800274:	eb 22                	jmp    800298 <getuint+0x38>
	else if (lflag)
  800276:	85 d2                	test   %edx,%edx
  800278:	74 10                	je     80028a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
  800288:	eb 0e                	jmp    800298 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a9:	73 0a                	jae    8002b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	88 02                	mov    %al,(%edx)
}
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c0:	50                   	push   %eax
  8002c1:	ff 75 10             	pushl  0x10(%ebp)
  8002c4:	ff 75 0c             	pushl  0xc(%ebp)
  8002c7:	ff 75 08             	pushl  0x8(%ebp)
  8002ca:	e8 05 00 00 00       	call   8002d4 <vprintfmt>
	va_end(ap);
}
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 2c             	sub    $0x2c,%esp
  8002dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e6:	eb 12                	jmp    8002fa <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 89 03 00 00    	je     800679 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	53                   	push   %ebx
  8002f4:	50                   	push   %eax
  8002f5:	ff d6                	call   *%esi
  8002f7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fa:	83 c7 01             	add    $0x1,%edi
  8002fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800301:	83 f8 25             	cmp    $0x25,%eax
  800304:	75 e2                	jne    8002e8 <vprintfmt+0x14>
  800306:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800311:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800318:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
  800324:	eb 07                	jmp    80032d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800329:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8d 47 01             	lea    0x1(%edi),%eax
  800330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800333:	0f b6 07             	movzbl (%edi),%eax
  800336:	0f b6 c8             	movzbl %al,%ecx
  800339:	83 e8 23             	sub    $0x23,%eax
  80033c:	3c 55                	cmp    $0x55,%al
  80033e:	0f 87 1a 03 00 00    	ja     80065e <vprintfmt+0x38a>
  800344:	0f b6 c0             	movzbl %al,%eax
  800347:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800351:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800355:	eb d6                	jmp    80032d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035a:	b8 00 00 00 00       	mov    $0x0,%eax
  80035f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800365:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800369:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80036c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80036f:	83 fa 09             	cmp    $0x9,%edx
  800372:	77 39                	ja     8003ad <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800374:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800377:	eb e9                	jmp    800362 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 48 04             	lea    0x4(%eax),%ecx
  80037f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 27                	jmp    8003b3 <vprintfmt+0xdf>
  80038c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038f:	85 c0                	test   %eax,%eax
  800391:	b9 00 00 00 00       	mov    $0x0,%ecx
  800396:	0f 49 c8             	cmovns %eax,%ecx
  800399:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039f:	eb 8c                	jmp    80032d <vprintfmt+0x59>
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ab:	eb 80                	jmp    80032d <vprintfmt+0x59>
  8003ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b7:	0f 89 70 ff ff ff    	jns    80032d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ca:	e9 5e ff ff ff       	jmp    80032d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d5:	e9 53 ff ff ff       	jmp    80032d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 50 04             	lea    0x4(%eax),%edx
  8003e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	ff 30                	pushl  (%eax)
  8003e9:	ff d6                	call   *%esi
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f1:	e9 04 ff ff ff       	jmp    8002fa <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 50 04             	lea    0x4(%eax),%edx
  8003fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	99                   	cltd   
  800402:	31 d0                	xor    %edx,%eax
  800404:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x142>
  80040b:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 18                	jne    80042e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 a9 1e 80 00       	push   $0x801ea9
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 94 fe ff ff       	call   8002b7 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800429:	e9 cc fe ff ff       	jmp    8002fa <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80042e:	52                   	push   %edx
  80042f:	68 71 22 80 00       	push   $0x802271
  800434:	53                   	push   %ebx
  800435:	56                   	push   %esi
  800436:	e8 7c fe ff ff       	call   8002b7 <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800441:	e9 b4 fe ff ff       	jmp    8002fa <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800451:	85 ff                	test   %edi,%edi
  800453:	b8 a2 1e 80 00       	mov    $0x801ea2,%eax
  800458:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045f:	0f 8e 94 00 00 00    	jle    8004f9 <vprintfmt+0x225>
  800465:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800469:	0f 84 98 00 00 00    	je     800507 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	ff 75 d0             	pushl  -0x30(%ebp)
  800475:	57                   	push   %edi
  800476:	e8 86 02 00 00       	call   800701 <strnlen>
  80047b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047e:	29 c1                	sub    %eax,%ecx
  800480:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800483:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800486:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800490:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	eb 0f                	jmp    8004a3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	53                   	push   %ebx
  800498:	ff 75 e0             	pushl  -0x20(%ebp)
  80049b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	83 ef 01             	sub    $0x1,%edi
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	85 ff                	test   %edi,%edi
  8004a5:	7f ed                	jg     800494 <vprintfmt+0x1c0>
  8004a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004aa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ad:	85 c9                	test   %ecx,%ecx
  8004af:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b4:	0f 49 c1             	cmovns %ecx,%eax
  8004b7:	29 c1                	sub    %eax,%ecx
  8004b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c2:	89 cb                	mov    %ecx,%ebx
  8004c4:	eb 4d                	jmp    800513 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ca:	74 1b                	je     8004e7 <vprintfmt+0x213>
  8004cc:	0f be c0             	movsbl %al,%eax
  8004cf:	83 e8 20             	sub    $0x20,%eax
  8004d2:	83 f8 5e             	cmp    $0x5e,%eax
  8004d5:	76 10                	jbe    8004e7 <vprintfmt+0x213>
					putch('?', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	6a 3f                	push   $0x3f
  8004df:	ff 55 08             	call   *0x8(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb 0d                	jmp    8004f4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 0c             	pushl  0xc(%ebp)
  8004ed:	52                   	push   %edx
  8004ee:	ff 55 08             	call   *0x8(%ebp)
  8004f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f4:	83 eb 01             	sub    $0x1,%ebx
  8004f7:	eb 1a                	jmp    800513 <vprintfmt+0x23f>
  8004f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800502:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800505:	eb 0c                	jmp    800513 <vprintfmt+0x23f>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	83 c7 01             	add    $0x1,%edi
  800516:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051a:	0f be d0             	movsbl %al,%edx
  80051d:	85 d2                	test   %edx,%edx
  80051f:	74 23                	je     800544 <vprintfmt+0x270>
  800521:	85 f6                	test   %esi,%esi
  800523:	78 a1                	js     8004c6 <vprintfmt+0x1f2>
  800525:	83 ee 01             	sub    $0x1,%esi
  800528:	79 9c                	jns    8004c6 <vprintfmt+0x1f2>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	eb 18                	jmp    80054c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	53                   	push   %ebx
  800538:	6a 20                	push   $0x20
  80053a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053c:	83 ef 01             	sub    $0x1,%edi
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	eb 08                	jmp    80054c <vprintfmt+0x278>
  800544:	89 df                	mov    %ebx,%edi
  800546:	8b 75 08             	mov    0x8(%ebp),%esi
  800549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054c:	85 ff                	test   %edi,%edi
  80054e:	7f e4                	jg     800534 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	e9 a2 fd ff ff       	jmp    8002fa <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800558:	83 fa 01             	cmp    $0x1,%edx
  80055b:	7e 16                	jle    800573 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 08             	lea    0x8(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 50 04             	mov    0x4(%eax),%edx
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800571:	eb 32                	jmp    8005a5 <vprintfmt+0x2d1>
	else if (lflag)
  800573:	85 d2                	test   %edx,%edx
  800575:	74 18                	je     80058f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058d:	eb 16                	jmp    8005a5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 04             	lea    0x4(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059d:	89 c1                	mov    %eax,%ecx
  80059f:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b4:	79 74                	jns    80062a <vprintfmt+0x356>
				putch('-', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 2d                	push   $0x2d
  8005bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8005be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c4:	f7 d8                	neg    %eax
  8005c6:	83 d2 00             	adc    $0x0,%edx
  8005c9:	f7 da                	neg    %edx
  8005cb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d3:	eb 55                	jmp    80062a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 83 fc ff ff       	call   800260 <getuint>
			base = 10;
  8005dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e2:	eb 46                	jmp    80062a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e7:	e8 74 fc ff ff       	call   800260 <getuint>
			base = 8;
  8005ec:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005f1:	eb 37                	jmp    80062a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 30                	push   $0x30
  8005f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fb:	83 c4 08             	add    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 78                	push   $0x78
  800601:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800613:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800616:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061b:	eb 0d                	jmp    80062a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061d:	8d 45 14             	lea    0x14(%ebp),%eax
  800620:	e8 3b fc ff ff       	call   800260 <getuint>
			base = 16;
  800625:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062a:	83 ec 0c             	sub    $0xc,%esp
  80062d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800631:	57                   	push   %edi
  800632:	ff 75 e0             	pushl  -0x20(%ebp)
  800635:	51                   	push   %ecx
  800636:	52                   	push   %edx
  800637:	50                   	push   %eax
  800638:	89 da                	mov    %ebx,%edx
  80063a:	89 f0                	mov    %esi,%eax
  80063c:	e8 70 fb ff ff       	call   8001b1 <printnum>
			break;
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	e9 ae fc ff ff       	jmp    8002fa <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	51                   	push   %ecx
  800651:	ff d6                	call   *%esi
			break;
  800653:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800659:	e9 9c fc ff ff       	jmp    8002fa <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 25                	push   $0x25
  800664:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	eb 03                	jmp    80066e <vprintfmt+0x39a>
  80066b:	83 ef 01             	sub    $0x1,%edi
  80066e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800672:	75 f7                	jne    80066b <vprintfmt+0x397>
  800674:	e9 81 fc ff ff       	jmp    8002fa <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	83 ec 18             	sub    $0x18,%esp
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800690:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800694:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 26                	je     8006c8 <vsnprintf+0x47>
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	7e 22                	jle    8006c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a6:	ff 75 14             	pushl  0x14(%ebp)
  8006a9:	ff 75 10             	pushl  0x10(%ebp)
  8006ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006af:	50                   	push   %eax
  8006b0:	68 9a 02 80 00       	push   $0x80029a
  8006b5:	e8 1a fc ff ff       	call   8002d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	eb 05                	jmp    8006cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 9a ff ff ff       	call   800681 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f4:	eb 03                	jmp    8006f9 <strlen+0x10>
		n++;
  8006f6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fd:	75 f7                	jne    8006f6 <strlen+0xd>
		n++;
	return n;
}
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800707:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070a:	ba 00 00 00 00       	mov    $0x0,%edx
  80070f:	eb 03                	jmp    800714 <strnlen+0x13>
		n++;
  800711:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800714:	39 c2                	cmp    %eax,%edx
  800716:	74 08                	je     800720 <strnlen+0x1f>
  800718:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071c:	75 f3                	jne    800711 <strnlen+0x10>
  80071e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	53                   	push   %ebx
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072c:	89 c2                	mov    %eax,%edx
  80072e:	83 c2 01             	add    $0x1,%edx
  800731:	83 c1 01             	add    $0x1,%ecx
  800734:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800738:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073b:	84 db                	test   %bl,%bl
  80073d:	75 ef                	jne    80072e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073f:	5b                   	pop    %ebx
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	53                   	push   %ebx
  800746:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800749:	53                   	push   %ebx
  80074a:	e8 9a ff ff ff       	call   8006e9 <strlen>
  80074f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	01 d8                	add    %ebx,%eax
  800757:	50                   	push   %eax
  800758:	e8 c5 ff ff ff       	call   800722 <strcpy>
	return dst;
}
  80075d:	89 d8                	mov    %ebx,%eax
  80075f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	56                   	push   %esi
  800768:	53                   	push   %ebx
  800769:	8b 75 08             	mov    0x8(%ebp),%esi
  80076c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076f:	89 f3                	mov    %esi,%ebx
  800771:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800774:	89 f2                	mov    %esi,%edx
  800776:	eb 0f                	jmp    800787 <strncpy+0x23>
		*dst++ = *src;
  800778:	83 c2 01             	add    $0x1,%edx
  80077b:	0f b6 01             	movzbl (%ecx),%eax
  80077e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800781:	80 39 01             	cmpb   $0x1,(%ecx)
  800784:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	39 da                	cmp    %ebx,%edx
  800789:	75 ed                	jne    800778 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078b:	89 f0                	mov    %esi,%eax
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079c:	8b 55 10             	mov    0x10(%ebp),%edx
  80079f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 21                	je     8007c6 <strlcpy+0x35>
  8007a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	eb 09                	jmp    8007b6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ad:	83 c2 01             	add    $0x1,%edx
  8007b0:	83 c1 01             	add    $0x1,%ecx
  8007b3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b6:	39 c2                	cmp    %eax,%edx
  8007b8:	74 09                	je     8007c3 <strlcpy+0x32>
  8007ba:	0f b6 19             	movzbl (%ecx),%ebx
  8007bd:	84 db                	test   %bl,%bl
  8007bf:	75 ec                	jne    8007ad <strlcpy+0x1c>
  8007c1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c6:	29 f0                	sub    %esi,%eax
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d5:	eb 06                	jmp    8007dd <strcmp+0x11>
		p++, q++;
  8007d7:	83 c1 01             	add    $0x1,%ecx
  8007da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007dd:	0f b6 01             	movzbl (%ecx),%eax
  8007e0:	84 c0                	test   %al,%al
  8007e2:	74 04                	je     8007e8 <strcmp+0x1c>
  8007e4:	3a 02                	cmp    (%edx),%al
  8007e6:	74 ef                	je     8007d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e8:	0f b6 c0             	movzbl %al,%eax
  8007eb:	0f b6 12             	movzbl (%edx),%edx
  8007ee:	29 d0                	sub    %edx,%eax
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	89 c3                	mov    %eax,%ebx
  8007fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800801:	eb 06                	jmp    800809 <strncmp+0x17>
		n--, p++, q++;
  800803:	83 c0 01             	add    $0x1,%eax
  800806:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800809:	39 d8                	cmp    %ebx,%eax
  80080b:	74 15                	je     800822 <strncmp+0x30>
  80080d:	0f b6 08             	movzbl (%eax),%ecx
  800810:	84 c9                	test   %cl,%cl
  800812:	74 04                	je     800818 <strncmp+0x26>
  800814:	3a 0a                	cmp    (%edx),%cl
  800816:	74 eb                	je     800803 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800818:	0f b6 00             	movzbl (%eax),%eax
  80081b:	0f b6 12             	movzbl (%edx),%edx
  80081e:	29 d0                	sub    %edx,%eax
  800820:	eb 05                	jmp    800827 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800834:	eb 07                	jmp    80083d <strchr+0x13>
		if (*s == c)
  800836:	38 ca                	cmp    %cl,%dl
  800838:	74 0f                	je     800849 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	0f b6 10             	movzbl (%eax),%edx
  800840:	84 d2                	test   %dl,%dl
  800842:	75 f2                	jne    800836 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800855:	eb 03                	jmp    80085a <strfind+0xf>
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085d:	38 ca                	cmp    %cl,%dl
  80085f:	74 04                	je     800865 <strfind+0x1a>
  800861:	84 d2                	test   %dl,%dl
  800863:	75 f2                	jne    800857 <strfind+0xc>
			break;
	return (char *) s;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800873:	85 c9                	test   %ecx,%ecx
  800875:	74 36                	je     8008ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800877:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087d:	75 28                	jne    8008a7 <memset+0x40>
  80087f:	f6 c1 03             	test   $0x3,%cl
  800882:	75 23                	jne    8008a7 <memset+0x40>
		c &= 0xFF;
  800884:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800888:	89 d3                	mov    %edx,%ebx
  80088a:	c1 e3 08             	shl    $0x8,%ebx
  80088d:	89 d6                	mov    %edx,%esi
  80088f:	c1 e6 18             	shl    $0x18,%esi
  800892:	89 d0                	mov    %edx,%eax
  800894:	c1 e0 10             	shl    $0x10,%eax
  800897:	09 f0                	or     %esi,%eax
  800899:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089b:	89 d8                	mov    %ebx,%eax
  80089d:	09 d0                	or     %edx,%eax
  80089f:	c1 e9 02             	shr    $0x2,%ecx
  8008a2:	fc                   	cld    
  8008a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a5:	eb 06                	jmp    8008ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ad:	89 f8                	mov    %edi,%eax
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c2:	39 c6                	cmp    %eax,%esi
  8008c4:	73 35                	jae    8008fb <memmove+0x47>
  8008c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c9:	39 d0                	cmp    %edx,%eax
  8008cb:	73 2e                	jae    8008fb <memmove+0x47>
		s += n;
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	89 d6                	mov    %edx,%esi
  8008d2:	09 fe                	or     %edi,%esi
  8008d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008da:	75 13                	jne    8008ef <memmove+0x3b>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 0e                	jne    8008ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e1:	83 ef 04             	sub    $0x4,%edi
  8008e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
  8008ea:	fd                   	std    
  8008eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ed:	eb 09                	jmp    8008f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ef:	83 ef 01             	sub    $0x1,%edi
  8008f2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f5:	fd                   	std    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f8:	fc                   	cld    
  8008f9:	eb 1d                	jmp    800918 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	89 f2                	mov    %esi,%edx
  8008fd:	09 c2                	or     %eax,%edx
  8008ff:	f6 c2 03             	test   $0x3,%dl
  800902:	75 0f                	jne    800913 <memmove+0x5f>
  800904:	f6 c1 03             	test   $0x3,%cl
  800907:	75 0a                	jne    800913 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800909:	c1 e9 02             	shr    $0x2,%ecx
  80090c:	89 c7                	mov    %eax,%edi
  80090e:	fc                   	cld    
  80090f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800911:	eb 05                	jmp    800918 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800913:	89 c7                	mov    %eax,%edi
  800915:	fc                   	cld    
  800916:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091f:	ff 75 10             	pushl  0x10(%ebp)
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	ff 75 08             	pushl  0x8(%ebp)
  800928:	e8 87 ff ff ff       	call   8008b4 <memmove>
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	89 c6                	mov    %eax,%esi
  80093c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093f:	eb 1a                	jmp    80095b <memcmp+0x2c>
		if (*s1 != *s2)
  800941:	0f b6 08             	movzbl (%eax),%ecx
  800944:	0f b6 1a             	movzbl (%edx),%ebx
  800947:	38 d9                	cmp    %bl,%cl
  800949:	74 0a                	je     800955 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094b:	0f b6 c1             	movzbl %cl,%eax
  80094e:	0f b6 db             	movzbl %bl,%ebx
  800951:	29 d8                	sub    %ebx,%eax
  800953:	eb 0f                	jmp    800964 <memcmp+0x35>
		s1++, s2++;
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095b:	39 f0                	cmp    %esi,%eax
  80095d:	75 e2                	jne    800941 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096f:	89 c1                	mov    %eax,%ecx
  800971:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800974:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800978:	eb 0a                	jmp    800984 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097a:	0f b6 10             	movzbl (%eax),%edx
  80097d:	39 da                	cmp    %ebx,%edx
  80097f:	74 07                	je     800988 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	39 c8                	cmp    %ecx,%eax
  800986:	72 f2                	jb     80097a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	57                   	push   %edi
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	eb 03                	jmp    80099c <strtol+0x11>
		s++;
  800999:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	3c 20                	cmp    $0x20,%al
  8009a1:	74 f6                	je     800999 <strtol+0xe>
  8009a3:	3c 09                	cmp    $0x9,%al
  8009a5:	74 f2                	je     800999 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a7:	3c 2b                	cmp    $0x2b,%al
  8009a9:	75 0a                	jne    8009b5 <strtol+0x2a>
		s++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b3:	eb 11                	jmp    8009c6 <strtol+0x3b>
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ba:	3c 2d                	cmp    $0x2d,%al
  8009bc:	75 08                	jne    8009c6 <strtol+0x3b>
		s++, neg = 1;
  8009be:	83 c1 01             	add    $0x1,%ecx
  8009c1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cc:	75 15                	jne    8009e3 <strtol+0x58>
  8009ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d1:	75 10                	jne    8009e3 <strtol+0x58>
  8009d3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d7:	75 7c                	jne    800a55 <strtol+0xca>
		s += 2, base = 16;
  8009d9:	83 c1 02             	add    $0x2,%ecx
  8009dc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e1:	eb 16                	jmp    8009f9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e3:	85 db                	test   %ebx,%ebx
  8009e5:	75 12                	jne    8009f9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ec:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ef:	75 08                	jne    8009f9 <strtol+0x6e>
		s++, base = 8;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a01:	0f b6 11             	movzbl (%ecx),%edx
  800a04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a07:	89 f3                	mov    %esi,%ebx
  800a09:	80 fb 09             	cmp    $0x9,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x8b>
			dig = *s - '0';
  800a0e:	0f be d2             	movsbl %dl,%edx
  800a11:	83 ea 30             	sub    $0x30,%edx
  800a14:	eb 22                	jmp    800a38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	80 fb 19             	cmp    $0x19,%bl
  800a1e:	77 08                	ja     800a28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a20:	0f be d2             	movsbl %dl,%edx
  800a23:	83 ea 57             	sub    $0x57,%edx
  800a26:	eb 10                	jmp    800a38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 16                	ja     800a48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a32:	0f be d2             	movsbl %dl,%edx
  800a35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3b:	7d 0b                	jge    800a48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a46:	eb b9                	jmp    800a01 <strtol+0x76>

	if (endptr)
  800a48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4c:	74 0d                	je     800a5b <strtol+0xd0>
		*endptr = (char *) s;
  800a4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a51:	89 0e                	mov    %ecx,(%esi)
  800a53:	eb 06                	jmp    800a5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	74 98                	je     8009f1 <strtol+0x66>
  800a59:	eb 9e                	jmp    8009f9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	f7 da                	neg    %edx
  800a5f:	85 ff                	test   %edi,%edi
  800a61:	0f 45 c2             	cmovne %edx,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a77:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	89 c6                	mov    %eax,%esi
  800a80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 01 00 00 00       	mov    $0x1,%eax
  800a97:	89 d1                	mov    %edx,%ecx
  800a99:	89 d3                	mov    %edx,%ebx
  800a9b:	89 d7                	mov    %edx,%edi
  800a9d:	89 d6                	mov    %edx,%esi
  800a9f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab9:	8b 55 08             	mov    0x8(%ebp),%edx
  800abc:	89 cb                	mov    %ecx,%ebx
  800abe:	89 cf                	mov    %ecx,%edi
  800ac0:	89 ce                	mov    %ecx,%esi
  800ac2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac4:	85 c0                	test   %eax,%eax
  800ac6:	7e 17                	jle    800adf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	50                   	push   %eax
  800acc:	6a 03                	push   $0x3
  800ace:	68 9f 21 80 00       	push   $0x80219f
  800ad3:	6a 23                	push   $0x23
  800ad5:	68 bc 21 80 00       	push   $0x8021bc
  800ada:	e8 41 0f 00 00       	call   801a20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 02 00 00 00       	mov    $0x2,%eax
  800af7:	89 d1                	mov    %edx,%ecx
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	89 d7                	mov    %edx,%edi
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_yield>:

void
sys_yield(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	be 00 00 00 00       	mov    $0x0,%esi
  800b33:	b8 04 00 00 00       	mov    $0x4,%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b41:	89 f7                	mov    %esi,%edi
  800b43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 17                	jle    800b60 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	6a 04                	push   $0x4
  800b4f:	68 9f 21 80 00       	push   $0x80219f
  800b54:	6a 23                	push   $0x23
  800b56:	68 bc 21 80 00       	push   $0x8021bc
  800b5b:	e8 c0 0e 00 00       	call   801a20 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b71:	b8 05 00 00 00       	mov    $0x5,%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b82:	8b 75 18             	mov    0x18(%ebp),%esi
  800b85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 05                	push   $0x5
  800b91:	68 9f 21 80 00       	push   $0x80219f
  800b96:	6a 23                	push   $0x23
  800b98:	68 bc 21 80 00       	push   $0x8021bc
  800b9d:	e8 7e 0e 00 00       	call   801a20 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc3:	89 df                	mov    %ebx,%edi
  800bc5:	89 de                	mov    %ebx,%esi
  800bc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 17                	jle    800be4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 06                	push   $0x6
  800bd3:	68 9f 21 80 00       	push   $0x80219f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 bc 21 80 00       	push   $0x8021bc
  800bdf:	e8 3c 0e 00 00       	call   801a20 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 df                	mov    %ebx,%edi
  800c07:	89 de                	mov    %ebx,%esi
  800c09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 08                	push   $0x8
  800c15:	68 9f 21 80 00       	push   $0x80219f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 bc 21 80 00       	push   $0x8021bc
  800c21:	e8 fa 0d 00 00       	call   801a20 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	89 de                	mov    %ebx,%esi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 09                	push   $0x9
  800c57:	68 9f 21 80 00       	push   $0x80219f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 bc 21 80 00       	push   $0x8021bc
  800c63:	e8 b8 0d 00 00       	call   801a20 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 0a                	push   $0xa
  800c99:	68 9f 21 80 00       	push   $0x80219f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 bc 21 80 00       	push   $0x8021bc
  800ca5:	e8 76 0d 00 00       	call   801a20 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	be 00 00 00 00       	mov    $0x0,%esi
  800cbd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cce:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	89 cb                	mov    %ecx,%ebx
  800ced:	89 cf                	mov    %ecx,%edi
  800cef:	89 ce                	mov    %ecx,%esi
  800cf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 17                	jle    800d0e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 0d                	push   $0xd
  800cfd:	68 9f 21 80 00       	push   $0x80219f
  800d02:	6a 23                	push   $0x23
  800d04:	68 bc 21 80 00       	push   $0x8021bc
  800d09:	e8 12 0d 00 00       	call   801a20 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d21:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 cb                	mov    %ecx,%ebx
  800d2b:	89 cf                	mov    %ecx,%edi
  800d2d:	89 ce                	mov    %ecx,%esi
  800d2f:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d41:	c1 e8 0c             	shr    $0xc,%eax
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d56:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d63:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	c1 ea 16             	shr    $0x16,%edx
  800d6d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d74:	f6 c2 01             	test   $0x1,%dl
  800d77:	74 11                	je     800d8a <fd_alloc+0x2d>
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	c1 ea 0c             	shr    $0xc,%edx
  800d7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d85:	f6 c2 01             	test   $0x1,%dl
  800d88:	75 09                	jne    800d93 <fd_alloc+0x36>
			*fd_store = fd;
  800d8a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d91:	eb 17                	jmp    800daa <fd_alloc+0x4d>
  800d93:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d98:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d9d:	75 c9                	jne    800d68 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d9f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800da5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800db2:	83 f8 1f             	cmp    $0x1f,%eax
  800db5:	77 36                	ja     800ded <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800db7:	c1 e0 0c             	shl    $0xc,%eax
  800dba:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	c1 ea 16             	shr    $0x16,%edx
  800dc4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dcb:	f6 c2 01             	test   $0x1,%dl
  800dce:	74 24                	je     800df4 <fd_lookup+0x48>
  800dd0:	89 c2                	mov    %eax,%edx
  800dd2:	c1 ea 0c             	shr    $0xc,%edx
  800dd5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddc:	f6 c2 01             	test   $0x1,%dl
  800ddf:	74 1a                	je     800dfb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800de1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de4:	89 02                	mov    %eax,(%edx)
	return 0;
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
  800deb:	eb 13                	jmp    800e00 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ded:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df2:	eb 0c                	jmp    800e00 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df9:	eb 05                	jmp    800e00 <fd_lookup+0x54>
  800dfb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 08             	sub    $0x8,%esp
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e10:	eb 13                	jmp    800e25 <dev_lookup+0x23>
  800e12:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e15:	39 08                	cmp    %ecx,(%eax)
  800e17:	75 0c                	jne    800e25 <dev_lookup+0x23>
			*dev = devtab[i];
  800e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e23:	eb 2e                	jmp    800e53 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e25:	8b 02                	mov    (%edx),%eax
  800e27:	85 c0                	test   %eax,%eax
  800e29:	75 e7                	jne    800e12 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e2b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e30:	8b 40 50             	mov    0x50(%eax),%eax
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	51                   	push   %ecx
  800e37:	50                   	push   %eax
  800e38:	68 cc 21 80 00       	push   $0x8021cc
  800e3d:	e8 5b f3 ff ff       	call   80019d <cprintf>
	*dev = 0;
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    

00800e55 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 10             	sub    $0x10,%esp
  800e5d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e66:	50                   	push   %eax
  800e67:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e6d:	c1 e8 0c             	shr    $0xc,%eax
  800e70:	50                   	push   %eax
  800e71:	e8 36 ff ff ff       	call   800dac <fd_lookup>
  800e76:	83 c4 08             	add    $0x8,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	78 05                	js     800e82 <fd_close+0x2d>
	    || fd != fd2)
  800e7d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e80:	74 0c                	je     800e8e <fd_close+0x39>
		return (must_exist ? r : 0);
  800e82:	84 db                	test   %bl,%bl
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	0f 44 c2             	cmove  %edx,%eax
  800e8c:	eb 41                	jmp    800ecf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e94:	50                   	push   %eax
  800e95:	ff 36                	pushl  (%esi)
  800e97:	e8 66 ff ff ff       	call   800e02 <dev_lookup>
  800e9c:	89 c3                	mov    %eax,%ebx
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	78 1a                	js     800ebf <fd_close+0x6a>
		if (dev->dev_close)
  800ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eab:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	74 0b                	je     800ebf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	56                   	push   %esi
  800eb8:	ff d0                	call   *%eax
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	56                   	push   %esi
  800ec3:	6a 00                	push   $0x0
  800ec5:	e8 e0 fc ff ff       	call   800baa <sys_page_unmap>
	return r;
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	89 d8                	mov    %ebx,%eax
}
  800ecf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800edc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edf:	50                   	push   %eax
  800ee0:	ff 75 08             	pushl  0x8(%ebp)
  800ee3:	e8 c4 fe ff ff       	call   800dac <fd_lookup>
  800ee8:	83 c4 08             	add    $0x8,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 10                	js     800eff <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	6a 01                	push   $0x1
  800ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef7:	e8 59 ff ff ff       	call   800e55 <fd_close>
  800efc:	83 c4 10             	add    $0x10,%esp
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <close_all>:

void
close_all(void)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	53                   	push   %ebx
  800f05:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f08:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	53                   	push   %ebx
  800f11:	e8 c0 ff ff ff       	call   800ed6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f16:	83 c3 01             	add    $0x1,%ebx
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	83 fb 20             	cmp    $0x20,%ebx
  800f1f:	75 ec                	jne    800f0d <close_all+0xc>
		close(i);
}
  800f21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 2c             	sub    $0x2c,%esp
  800f2f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f35:	50                   	push   %eax
  800f36:	ff 75 08             	pushl  0x8(%ebp)
  800f39:	e8 6e fe ff ff       	call   800dac <fd_lookup>
  800f3e:	83 c4 08             	add    $0x8,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	0f 88 c1 00 00 00    	js     80100a <dup+0xe4>
		return r;
	close(newfdnum);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	56                   	push   %esi
  800f4d:	e8 84 ff ff ff       	call   800ed6 <close>

	newfd = INDEX2FD(newfdnum);
  800f52:	89 f3                	mov    %esi,%ebx
  800f54:	c1 e3 0c             	shl    $0xc,%ebx
  800f57:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f5d:	83 c4 04             	add    $0x4,%esp
  800f60:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f63:	e8 de fd ff ff       	call   800d46 <fd2data>
  800f68:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f6a:	89 1c 24             	mov    %ebx,(%esp)
  800f6d:	e8 d4 fd ff ff       	call   800d46 <fd2data>
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f78:	89 f8                	mov    %edi,%eax
  800f7a:	c1 e8 16             	shr    $0x16,%eax
  800f7d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f84:	a8 01                	test   $0x1,%al
  800f86:	74 37                	je     800fbf <dup+0x99>
  800f88:	89 f8                	mov    %edi,%eax
  800f8a:	c1 e8 0c             	shr    $0xc,%eax
  800f8d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f94:	f6 c2 01             	test   $0x1,%dl
  800f97:	74 26                	je     800fbf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fac:	6a 00                	push   $0x0
  800fae:	57                   	push   %edi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 b2 fb ff ff       	call   800b68 <sys_page_map>
  800fb6:	89 c7                	mov    %eax,%edi
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 2e                	js     800fed <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fbf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fc2:	89 d0                	mov    %edx,%eax
  800fc4:	c1 e8 0c             	shr    $0xc,%eax
  800fc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd6:	50                   	push   %eax
  800fd7:	53                   	push   %ebx
  800fd8:	6a 00                	push   $0x0
  800fda:	52                   	push   %edx
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 86 fb ff ff       	call   800b68 <sys_page_map>
  800fe2:	89 c7                	mov    %eax,%edi
  800fe4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fe7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe9:	85 ff                	test   %edi,%edi
  800feb:	79 1d                	jns    80100a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	53                   	push   %ebx
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 b2 fb ff ff       	call   800baa <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ff8:	83 c4 08             	add    $0x8,%esp
  800ffb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffe:	6a 00                	push   $0x0
  801000:	e8 a5 fb ff ff       	call   800baa <sys_page_unmap>
	return r;
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	89 f8                	mov    %edi,%eax
}
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	53                   	push   %ebx
  801016:	83 ec 14             	sub    $0x14,%esp
  801019:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80101c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101f:	50                   	push   %eax
  801020:	53                   	push   %ebx
  801021:	e8 86 fd ff ff       	call   800dac <fd_lookup>
  801026:	83 c4 08             	add    $0x8,%esp
  801029:	89 c2                	mov    %eax,%edx
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 6d                	js     80109c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801039:	ff 30                	pushl  (%eax)
  80103b:	e8 c2 fd ff ff       	call   800e02 <dev_lookup>
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	78 4c                	js     801093 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801047:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80104a:	8b 42 08             	mov    0x8(%edx),%eax
  80104d:	83 e0 03             	and    $0x3,%eax
  801050:	83 f8 01             	cmp    $0x1,%eax
  801053:	75 21                	jne    801076 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801055:	a1 04 40 80 00       	mov    0x804004,%eax
  80105a:	8b 40 50             	mov    0x50(%eax),%eax
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	53                   	push   %ebx
  801061:	50                   	push   %eax
  801062:	68 0d 22 80 00       	push   $0x80220d
  801067:	e8 31 f1 ff ff       	call   80019d <cprintf>
		return -E_INVAL;
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801074:	eb 26                	jmp    80109c <read+0x8a>
	}
	if (!dev->dev_read)
  801076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801079:	8b 40 08             	mov    0x8(%eax),%eax
  80107c:	85 c0                	test   %eax,%eax
  80107e:	74 17                	je     801097 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801080:	83 ec 04             	sub    $0x4,%esp
  801083:	ff 75 10             	pushl  0x10(%ebp)
  801086:	ff 75 0c             	pushl  0xc(%ebp)
  801089:	52                   	push   %edx
  80108a:	ff d0                	call   *%eax
  80108c:	89 c2                	mov    %eax,%edx
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	eb 09                	jmp    80109c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801093:	89 c2                	mov    %eax,%edx
  801095:	eb 05                	jmp    80109c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801097:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80109c:	89 d0                	mov    %edx,%eax
  80109e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b7:	eb 21                	jmp    8010da <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	89 f0                	mov    %esi,%eax
  8010be:	29 d8                	sub    %ebx,%eax
  8010c0:	50                   	push   %eax
  8010c1:	89 d8                	mov    %ebx,%eax
  8010c3:	03 45 0c             	add    0xc(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	57                   	push   %edi
  8010c8:	e8 45 ff ff ff       	call   801012 <read>
		if (m < 0)
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 10                	js     8010e4 <readn+0x41>
			return m;
		if (m == 0)
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	74 0a                	je     8010e2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d8:	01 c3                	add    %eax,%ebx
  8010da:	39 f3                	cmp    %esi,%ebx
  8010dc:	72 db                	jb     8010b9 <readn+0x16>
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	eb 02                	jmp    8010e4 <readn+0x41>
  8010e2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 14             	sub    $0x14,%esp
  8010f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f9:	50                   	push   %eax
  8010fa:	53                   	push   %ebx
  8010fb:	e8 ac fc ff ff       	call   800dac <fd_lookup>
  801100:	83 c4 08             	add    $0x8,%esp
  801103:	89 c2                	mov    %eax,%edx
  801105:	85 c0                	test   %eax,%eax
  801107:	78 68                	js     801171 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801113:	ff 30                	pushl  (%eax)
  801115:	e8 e8 fc ff ff       	call   800e02 <dev_lookup>
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 47                	js     801168 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801121:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801124:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801128:	75 21                	jne    80114b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80112a:	a1 04 40 80 00       	mov    0x804004,%eax
  80112f:	8b 40 50             	mov    0x50(%eax),%eax
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	53                   	push   %ebx
  801136:	50                   	push   %eax
  801137:	68 29 22 80 00       	push   $0x802229
  80113c:	e8 5c f0 ff ff       	call   80019d <cprintf>
		return -E_INVAL;
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801149:	eb 26                	jmp    801171 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80114b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80114e:	8b 52 0c             	mov    0xc(%edx),%edx
  801151:	85 d2                	test   %edx,%edx
  801153:	74 17                	je     80116c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	ff 75 10             	pushl  0x10(%ebp)
  80115b:	ff 75 0c             	pushl  0xc(%ebp)
  80115e:	50                   	push   %eax
  80115f:	ff d2                	call   *%edx
  801161:	89 c2                	mov    %eax,%edx
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	eb 09                	jmp    801171 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801168:	89 c2                	mov    %eax,%edx
  80116a:	eb 05                	jmp    801171 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80116c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801171:	89 d0                	mov    %edx,%eax
  801173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <seek>:

int
seek(int fdnum, off_t offset)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	ff 75 08             	pushl  0x8(%ebp)
  801185:	e8 22 fc ff ff       	call   800dac <fd_lookup>
  80118a:	83 c4 08             	add    $0x8,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 0e                	js     80119f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801191:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801194:	8b 55 0c             	mov    0xc(%ebp),%edx
  801197:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    

008011a1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 14             	sub    $0x14,%esp
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	53                   	push   %ebx
  8011b0:	e8 f7 fb ff ff       	call   800dac <fd_lookup>
  8011b5:	83 c4 08             	add    $0x8,%esp
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 65                	js     801223 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	ff 30                	pushl  (%eax)
  8011ca:	e8 33 fc ff ff       	call   800e02 <dev_lookup>
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 44                	js     80121a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011dd:	75 21                	jne    801200 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011df:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e4:	8b 40 50             	mov    0x50(%eax),%eax
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	53                   	push   %ebx
  8011eb:	50                   	push   %eax
  8011ec:	68 ec 21 80 00       	push   $0x8021ec
  8011f1:	e8 a7 ef ff ff       	call   80019d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011fe:	eb 23                	jmp    801223 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801200:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801203:	8b 52 18             	mov    0x18(%edx),%edx
  801206:	85 d2                	test   %edx,%edx
  801208:	74 14                	je     80121e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	ff 75 0c             	pushl  0xc(%ebp)
  801210:	50                   	push   %eax
  801211:	ff d2                	call   *%edx
  801213:	89 c2                	mov    %eax,%edx
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	eb 09                	jmp    801223 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	eb 05                	jmp    801223 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80121e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801223:	89 d0                	mov    %edx,%eax
  801225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	53                   	push   %ebx
  80122e:	83 ec 14             	sub    $0x14,%esp
  801231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801234:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 6c fb ff ff       	call   800dac <fd_lookup>
  801240:	83 c4 08             	add    $0x8,%esp
  801243:	89 c2                	mov    %eax,%edx
  801245:	85 c0                	test   %eax,%eax
  801247:	78 58                	js     8012a1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	ff 30                	pushl  (%eax)
  801255:	e8 a8 fb ff ff       	call   800e02 <dev_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 37                	js     801298 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801261:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801264:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801268:	74 32                	je     80129c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80126a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80126d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801274:	00 00 00 
	stat->st_isdir = 0;
  801277:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80127e:	00 00 00 
	stat->st_dev = dev;
  801281:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	53                   	push   %ebx
  80128b:	ff 75 f0             	pushl  -0x10(%ebp)
  80128e:	ff 50 14             	call   *0x14(%eax)
  801291:	89 c2                	mov    %eax,%edx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb 09                	jmp    8012a1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801298:	89 c2                	mov    %eax,%edx
  80129a:	eb 05                	jmp    8012a1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80129c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012a1:	89 d0                	mov    %edx,%eax
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	6a 00                	push   $0x0
  8012b2:	ff 75 08             	pushl  0x8(%ebp)
  8012b5:	e8 e3 01 00 00       	call   80149d <open>
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 1b                	js     8012de <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	ff 75 0c             	pushl  0xc(%ebp)
  8012c9:	50                   	push   %eax
  8012ca:	e8 5b ff ff ff       	call   80122a <fstat>
  8012cf:	89 c6                	mov    %eax,%esi
	close(fd);
  8012d1:	89 1c 24             	mov    %ebx,(%esp)
  8012d4:	e8 fd fb ff ff       	call   800ed6 <close>
	return r;
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	89 f0                	mov    %esi,%eax
}
  8012de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	89 c6                	mov    %eax,%esi
  8012ec:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012ee:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012f5:	75 12                	jne    801309 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012f7:	83 ec 0c             	sub    $0xc,%esp
  8012fa:	6a 01                	push   $0x1
  8012fc:	e8 3c 08 00 00       	call   801b3d <ipc_find_env>
  801301:	a3 00 40 80 00       	mov    %eax,0x804000
  801306:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801309:	6a 07                	push   $0x7
  80130b:	68 00 50 80 00       	push   $0x805000
  801310:	56                   	push   %esi
  801311:	ff 35 00 40 80 00    	pushl  0x804000
  801317:	e8 bf 07 00 00       	call   801adb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80131c:	83 c4 0c             	add    $0xc,%esp
  80131f:	6a 00                	push   $0x0
  801321:	53                   	push   %ebx
  801322:	6a 00                	push   $0x0
  801324:	e8 3d 07 00 00       	call   801a66 <ipc_recv>
}
  801329:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801336:	8b 45 08             	mov    0x8(%ebp),%eax
  801339:	8b 40 0c             	mov    0xc(%eax),%eax
  80133c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801341:	8b 45 0c             	mov    0xc(%ebp),%eax
  801344:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801349:	ba 00 00 00 00       	mov    $0x0,%edx
  80134e:	b8 02 00 00 00       	mov    $0x2,%eax
  801353:	e8 8d ff ff ff       	call   8012e5 <fsipc>
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801360:	8b 45 08             	mov    0x8(%ebp),%eax
  801363:	8b 40 0c             	mov    0xc(%eax),%eax
  801366:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80136b:	ba 00 00 00 00       	mov    $0x0,%edx
  801370:	b8 06 00 00 00       	mov    $0x6,%eax
  801375:	e8 6b ff ff ff       	call   8012e5 <fsipc>
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	8b 40 0c             	mov    0xc(%eax),%eax
  80138c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801391:	ba 00 00 00 00       	mov    $0x0,%edx
  801396:	b8 05 00 00 00       	mov    $0x5,%eax
  80139b:	e8 45 ff ff ff       	call   8012e5 <fsipc>
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 2c                	js     8013d0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	68 00 50 80 00       	push   $0x805000
  8013ac:	53                   	push   %ebx
  8013ad:	e8 70 f3 ff ff       	call   800722 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8013b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8013c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013de:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8013e4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013ea:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013ef:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013f4:	0f 47 c2             	cmova  %edx,%eax
  8013f7:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013fc:	50                   	push   %eax
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	68 08 50 80 00       	push   $0x805008
  801405:	e8 aa f4 ff ff       	call   8008b4 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80140a:	ba 00 00 00 00       	mov    $0x0,%edx
  80140f:	b8 04 00 00 00       	mov    $0x4,%eax
  801414:	e8 cc fe ff ff       	call   8012e5 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	56                   	push   %esi
  80141f:	53                   	push   %ebx
  801420:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	8b 40 0c             	mov    0xc(%eax),%eax
  801429:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80142e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801434:	ba 00 00 00 00       	mov    $0x0,%edx
  801439:	b8 03 00 00 00       	mov    $0x3,%eax
  80143e:	e8 a2 fe ff ff       	call   8012e5 <fsipc>
  801443:	89 c3                	mov    %eax,%ebx
  801445:	85 c0                	test   %eax,%eax
  801447:	78 4b                	js     801494 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801449:	39 c6                	cmp    %eax,%esi
  80144b:	73 16                	jae    801463 <devfile_read+0x48>
  80144d:	68 58 22 80 00       	push   $0x802258
  801452:	68 5f 22 80 00       	push   $0x80225f
  801457:	6a 7c                	push   $0x7c
  801459:	68 74 22 80 00       	push   $0x802274
  80145e:	e8 bd 05 00 00       	call   801a20 <_panic>
	assert(r <= PGSIZE);
  801463:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801468:	7e 16                	jle    801480 <devfile_read+0x65>
  80146a:	68 7f 22 80 00       	push   $0x80227f
  80146f:	68 5f 22 80 00       	push   $0x80225f
  801474:	6a 7d                	push   $0x7d
  801476:	68 74 22 80 00       	push   $0x802274
  80147b:	e8 a0 05 00 00       	call   801a20 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	50                   	push   %eax
  801484:	68 00 50 80 00       	push   $0x805000
  801489:	ff 75 0c             	pushl  0xc(%ebp)
  80148c:	e8 23 f4 ff ff       	call   8008b4 <memmove>
	return r;
  801491:	83 c4 10             	add    $0x10,%esp
}
  801494:	89 d8                	mov    %ebx,%eax
  801496:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    

0080149d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 20             	sub    $0x20,%esp
  8014a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014a7:	53                   	push   %ebx
  8014a8:	e8 3c f2 ff ff       	call   8006e9 <strlen>
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b5:	7f 67                	jg     80151e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b7:	83 ec 0c             	sub    $0xc,%esp
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	e8 9a f8 ff ff       	call   800d5d <fd_alloc>
  8014c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 57                	js     801523 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	53                   	push   %ebx
  8014d0:	68 00 50 80 00       	push   $0x805000
  8014d5:	e8 48 f2 ff ff       	call   800722 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014dd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ea:	e8 f6 fd ff ff       	call   8012e5 <fsipc>
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	79 14                	jns    80150c <open+0x6f>
		fd_close(fd, 0);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	6a 00                	push   $0x0
  8014fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801500:	e8 50 f9 ff ff       	call   800e55 <fd_close>
		return r;
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	89 da                	mov    %ebx,%edx
  80150a:	eb 17                	jmp    801523 <open+0x86>
	}

	return fd2num(fd);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	ff 75 f4             	pushl  -0xc(%ebp)
  801512:	e8 1f f8 ff ff       	call   800d36 <fd2num>
  801517:	89 c2                	mov    %eax,%edx
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	eb 05                	jmp    801523 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80151e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801530:	ba 00 00 00 00       	mov    $0x0,%edx
  801535:	b8 08 00 00 00       	mov    $0x8,%eax
  80153a:	e8 a6 fd ff ff       	call   8012e5 <fsipc>
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	ff 75 08             	pushl  0x8(%ebp)
  80154f:	e8 f2 f7 ff ff       	call   800d46 <fd2data>
  801554:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801556:	83 c4 08             	add    $0x8,%esp
  801559:	68 8b 22 80 00       	push   $0x80228b
  80155e:	53                   	push   %ebx
  80155f:	e8 be f1 ff ff       	call   800722 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801564:	8b 46 04             	mov    0x4(%esi),%eax
  801567:	2b 06                	sub    (%esi),%eax
  801569:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80156f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801576:	00 00 00 
	stat->st_dev = &devpipe;
  801579:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801580:	30 80 00 
	return 0;
}
  801583:	b8 00 00 00 00       	mov    $0x0,%eax
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801599:	53                   	push   %ebx
  80159a:	6a 00                	push   $0x0
  80159c:	e8 09 f6 ff ff       	call   800baa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a1:	89 1c 24             	mov    %ebx,(%esp)
  8015a4:	e8 9d f7 ff ff       	call   800d46 <fd2data>
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	50                   	push   %eax
  8015ad:	6a 00                	push   $0x0
  8015af:	e8 f6 f5 ff ff       	call   800baa <sys_page_unmap>
}
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 1c             	sub    $0x1c,%esp
  8015c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cc:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d5:	e8 a3 05 00 00       	call   801b7d <pageref>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	89 3c 24             	mov    %edi,(%esp)
  8015df:	e8 99 05 00 00       	call   801b7d <pageref>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	39 c3                	cmp    %eax,%ebx
  8015e9:	0f 94 c1             	sete   %cl
  8015ec:	0f b6 c9             	movzbl %cl,%ecx
  8015ef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015f2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015f8:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015fb:	39 ce                	cmp    %ecx,%esi
  8015fd:	74 1b                	je     80161a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015ff:	39 c3                	cmp    %eax,%ebx
  801601:	75 c4                	jne    8015c7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801603:	8b 42 60             	mov    0x60(%edx),%eax
  801606:	ff 75 e4             	pushl  -0x1c(%ebp)
  801609:	50                   	push   %eax
  80160a:	56                   	push   %esi
  80160b:	68 92 22 80 00       	push   $0x802292
  801610:	e8 88 eb ff ff       	call   80019d <cprintf>
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb ad                	jmp    8015c7 <_pipeisclosed+0xe>
	}
}
  80161a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80161d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801620:	5b                   	pop    %ebx
  801621:	5e                   	pop    %esi
  801622:	5f                   	pop    %edi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	57                   	push   %edi
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
  80162b:	83 ec 28             	sub    $0x28,%esp
  80162e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801631:	56                   	push   %esi
  801632:	e8 0f f7 ff ff       	call   800d46 <fd2data>
  801637:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	bf 00 00 00 00       	mov    $0x0,%edi
  801641:	eb 4b                	jmp    80168e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801643:	89 da                	mov    %ebx,%edx
  801645:	89 f0                	mov    %esi,%eax
  801647:	e8 6d ff ff ff       	call   8015b9 <_pipeisclosed>
  80164c:	85 c0                	test   %eax,%eax
  80164e:	75 48                	jne    801698 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801650:	e8 b1 f4 ff ff       	call   800b06 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801655:	8b 43 04             	mov    0x4(%ebx),%eax
  801658:	8b 0b                	mov    (%ebx),%ecx
  80165a:	8d 51 20             	lea    0x20(%ecx),%edx
  80165d:	39 d0                	cmp    %edx,%eax
  80165f:	73 e2                	jae    801643 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801664:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801668:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	c1 fa 1f             	sar    $0x1f,%edx
  801670:	89 d1                	mov    %edx,%ecx
  801672:	c1 e9 1b             	shr    $0x1b,%ecx
  801675:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801678:	83 e2 1f             	and    $0x1f,%edx
  80167b:	29 ca                	sub    %ecx,%edx
  80167d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801681:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801685:	83 c0 01             	add    $0x1,%eax
  801688:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80168b:	83 c7 01             	add    $0x1,%edi
  80168e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801691:	75 c2                	jne    801655 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801693:	8b 45 10             	mov    0x10(%ebp),%eax
  801696:	eb 05                	jmp    80169d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801698:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80169d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a0:	5b                   	pop    %ebx
  8016a1:	5e                   	pop    %esi
  8016a2:	5f                   	pop    %edi
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	57                   	push   %edi
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 18             	sub    $0x18,%esp
  8016ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016b1:	57                   	push   %edi
  8016b2:	e8 8f f6 ff ff       	call   800d46 <fd2data>
  8016b7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c1:	eb 3d                	jmp    801700 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016c3:	85 db                	test   %ebx,%ebx
  8016c5:	74 04                	je     8016cb <devpipe_read+0x26>
				return i;
  8016c7:	89 d8                	mov    %ebx,%eax
  8016c9:	eb 44                	jmp    80170f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016cb:	89 f2                	mov    %esi,%edx
  8016cd:	89 f8                	mov    %edi,%eax
  8016cf:	e8 e5 fe ff ff       	call   8015b9 <_pipeisclosed>
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	75 32                	jne    80170a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016d8:	e8 29 f4 ff ff       	call   800b06 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016dd:	8b 06                	mov    (%esi),%eax
  8016df:	3b 46 04             	cmp    0x4(%esi),%eax
  8016e2:	74 df                	je     8016c3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e4:	99                   	cltd   
  8016e5:	c1 ea 1b             	shr    $0x1b,%edx
  8016e8:	01 d0                	add    %edx,%eax
  8016ea:	83 e0 1f             	and    $0x1f,%eax
  8016ed:	29 d0                	sub    %edx,%eax
  8016ef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016fa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fd:	83 c3 01             	add    $0x1,%ebx
  801700:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801703:	75 d8                	jne    8016dd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801705:	8b 45 10             	mov    0x10(%ebp),%eax
  801708:	eb 05                	jmp    80170f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80170f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80171f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	e8 35 f6 ff ff       	call   800d5d <fd_alloc>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	85 c0                	test   %eax,%eax
  80172f:	0f 88 2c 01 00 00    	js     801861 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	68 07 04 00 00       	push   $0x407
  80173d:	ff 75 f4             	pushl  -0xc(%ebp)
  801740:	6a 00                	push   $0x0
  801742:	e8 de f3 ff ff       	call   800b25 <sys_page_alloc>
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	85 c0                	test   %eax,%eax
  80174e:	0f 88 0d 01 00 00    	js     801861 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	e8 fd f5 ff ff       	call   800d5d <fd_alloc>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	0f 88 e2 00 00 00    	js     80184f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	68 07 04 00 00       	push   $0x407
  801775:	ff 75 f0             	pushl  -0x10(%ebp)
  801778:	6a 00                	push   $0x0
  80177a:	e8 a6 f3 ff ff       	call   800b25 <sys_page_alloc>
  80177f:	89 c3                	mov    %eax,%ebx
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	0f 88 c3 00 00 00    	js     80184f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80178c:	83 ec 0c             	sub    $0xc,%esp
  80178f:	ff 75 f4             	pushl  -0xc(%ebp)
  801792:	e8 af f5 ff ff       	call   800d46 <fd2data>
  801797:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801799:	83 c4 0c             	add    $0xc,%esp
  80179c:	68 07 04 00 00       	push   $0x407
  8017a1:	50                   	push   %eax
  8017a2:	6a 00                	push   $0x0
  8017a4:	e8 7c f3 ff ff       	call   800b25 <sys_page_alloc>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	0f 88 89 00 00 00    	js     80183f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bc:	e8 85 f5 ff ff       	call   800d46 <fd2data>
  8017c1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c8:	50                   	push   %eax
  8017c9:	6a 00                	push   $0x0
  8017cb:	56                   	push   %esi
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 95 f3 ff ff       	call   800b68 <sys_page_map>
  8017d3:	89 c3                	mov    %eax,%ebx
  8017d5:	83 c4 20             	add    $0x20,%esp
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 55                	js     801831 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017dc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017f1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	ff 75 f4             	pushl  -0xc(%ebp)
  80180c:	e8 25 f5 ff ff       	call   800d36 <fd2num>
  801811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801814:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801816:	83 c4 04             	add    $0x4,%esp
  801819:	ff 75 f0             	pushl  -0x10(%ebp)
  80181c:	e8 15 f5 ff ff       	call   800d36 <fd2num>
  801821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801824:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	ba 00 00 00 00       	mov    $0x0,%edx
  80182f:	eb 30                	jmp    801861 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	56                   	push   %esi
  801835:	6a 00                	push   $0x0
  801837:	e8 6e f3 ff ff       	call   800baa <sys_page_unmap>
  80183c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	ff 75 f0             	pushl  -0x10(%ebp)
  801845:	6a 00                	push   $0x0
  801847:	e8 5e f3 ff ff       	call   800baa <sys_page_unmap>
  80184c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	ff 75 f4             	pushl  -0xc(%ebp)
  801855:	6a 00                	push   $0x0
  801857:	e8 4e f3 ff ff       	call   800baa <sys_page_unmap>
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801861:	89 d0                	mov    %edx,%eax
  801863:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801873:	50                   	push   %eax
  801874:	ff 75 08             	pushl  0x8(%ebp)
  801877:	e8 30 f5 ff ff       	call   800dac <fd_lookup>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 18                	js     80189b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	ff 75 f4             	pushl  -0xc(%ebp)
  801889:	e8 b8 f4 ff ff       	call   800d46 <fd2data>
	return _pipeisclosed(fd, p);
  80188e:	89 c2                	mov    %eax,%edx
  801890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801893:	e8 21 fd ff ff       	call   8015b9 <_pipeisclosed>
  801898:	83 c4 10             	add    $0x10,%esp
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018ad:	68 aa 22 80 00       	push   $0x8022aa
  8018b2:	ff 75 0c             	pushl  0xc(%ebp)
  8018b5:	e8 68 ee ff ff       	call   800722 <strcpy>
	return 0;
}
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	57                   	push   %edi
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018cd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d8:	eb 2d                	jmp    801907 <devcons_write+0x46>
		m = n - tot;
  8018da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018dd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018df:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018e2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018e7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ea:	83 ec 04             	sub    $0x4,%esp
  8018ed:	53                   	push   %ebx
  8018ee:	03 45 0c             	add    0xc(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	57                   	push   %edi
  8018f3:	e8 bc ef ff ff       	call   8008b4 <memmove>
		sys_cputs(buf, m);
  8018f8:	83 c4 08             	add    $0x8,%esp
  8018fb:	53                   	push   %ebx
  8018fc:	57                   	push   %edi
  8018fd:	e8 67 f1 ff ff       	call   800a69 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801902:	01 de                	add    %ebx,%esi
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	89 f0                	mov    %esi,%eax
  801909:	3b 75 10             	cmp    0x10(%ebp),%esi
  80190c:	72 cc                	jb     8018da <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80190e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5f                   	pop    %edi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801921:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801925:	74 2a                	je     801951 <devcons_read+0x3b>
  801927:	eb 05                	jmp    80192e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801929:	e8 d8 f1 ff ff       	call   800b06 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80192e:	e8 54 f1 ff ff       	call   800a87 <sys_cgetc>
  801933:	85 c0                	test   %eax,%eax
  801935:	74 f2                	je     801929 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801937:	85 c0                	test   %eax,%eax
  801939:	78 16                	js     801951 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80193b:	83 f8 04             	cmp    $0x4,%eax
  80193e:	74 0c                	je     80194c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801940:	8b 55 0c             	mov    0xc(%ebp),%edx
  801943:	88 02                	mov    %al,(%edx)
	return 1;
  801945:	b8 01 00 00 00       	mov    $0x1,%eax
  80194a:	eb 05                	jmp    801951 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80195f:	6a 01                	push   $0x1
  801961:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	e8 ff f0 ff ff       	call   800a69 <sys_cputs>
}
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <getchar>:

int
getchar(void)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801975:	6a 01                	push   $0x1
  801977:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197a:	50                   	push   %eax
  80197b:	6a 00                	push   $0x0
  80197d:	e8 90 f6 ff ff       	call   801012 <read>
	if (r < 0)
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	78 0f                	js     801998 <getchar+0x29>
		return r;
	if (r < 1)
  801989:	85 c0                	test   %eax,%eax
  80198b:	7e 06                	jle    801993 <getchar+0x24>
		return -E_EOF;
	return c;
  80198d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801991:	eb 05                	jmp    801998 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801993:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a3:	50                   	push   %eax
  8019a4:	ff 75 08             	pushl  0x8(%ebp)
  8019a7:	e8 00 f4 ff ff       	call   800dac <fd_lookup>
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 11                	js     8019c4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019bc:	39 10                	cmp    %edx,(%eax)
  8019be:	0f 94 c0             	sete   %al
  8019c1:	0f b6 c0             	movzbl %al,%eax
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <opencons>:

int
opencons(void)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	e8 88 f3 ff ff       	call   800d5d <fd_alloc>
  8019d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 3e                	js     801a1c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019de:	83 ec 04             	sub    $0x4,%esp
  8019e1:	68 07 04 00 00       	push   $0x407
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 35 f1 ff ff       	call   800b25 <sys_page_alloc>
  8019f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 23                	js     801a1c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a02:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a07:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	50                   	push   %eax
  801a12:	e8 1f f3 ff ff       	call   800d36 <fd2num>
  801a17:	89 c2                	mov    %eax,%edx
  801a19:	83 c4 10             	add    $0x10,%esp
}
  801a1c:	89 d0                	mov    %edx,%eax
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a25:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a28:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a2e:	e8 b4 f0 ff ff       	call   800ae7 <sys_getenvid>
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	ff 75 0c             	pushl  0xc(%ebp)
  801a39:	ff 75 08             	pushl  0x8(%ebp)
  801a3c:	56                   	push   %esi
  801a3d:	50                   	push   %eax
  801a3e:	68 b8 22 80 00       	push   $0x8022b8
  801a43:	e8 55 e7 ff ff       	call   80019d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a48:	83 c4 18             	add    $0x18,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	ff 75 10             	pushl  0x10(%ebp)
  801a4f:	e8 f8 e6 ff ff       	call   80014c <vcprintf>
	cprintf("\n");
  801a54:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a5b:	e8 3d e7 ff ff       	call   80019d <cprintf>
  801a60:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a63:	cc                   	int3   
  801a64:	eb fd                	jmp    801a63 <_panic+0x43>

00801a66 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a74:	85 c0                	test   %eax,%eax
  801a76:	75 12                	jne    801a8a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	68 00 00 c0 ee       	push   $0xeec00000
  801a80:	e8 50 f2 ff ff       	call   800cd5 <sys_ipc_recv>
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb 0c                	jmp    801a96 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	50                   	push   %eax
  801a8e:	e8 42 f2 ff ff       	call   800cd5 <sys_ipc_recv>
  801a93:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a96:	85 f6                	test   %esi,%esi
  801a98:	0f 95 c1             	setne  %cl
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	0f 95 c2             	setne  %dl
  801aa0:	84 d1                	test   %dl,%cl
  801aa2:	74 09                	je     801aad <ipc_recv+0x47>
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	c1 ea 1f             	shr    $0x1f,%edx
  801aa9:	84 d2                	test   %dl,%dl
  801aab:	75 27                	jne    801ad4 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801aad:	85 f6                	test   %esi,%esi
  801aaf:	74 0a                	je     801abb <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ab1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab6:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ab9:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801abb:	85 db                	test   %ebx,%ebx
  801abd:	74 0d                	je     801acc <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801abf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801aca:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aed:	85 db                	test   %ebx,%ebx
  801aef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801af4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801af7:	ff 75 14             	pushl  0x14(%ebp)
  801afa:	53                   	push   %ebx
  801afb:	56                   	push   %esi
  801afc:	57                   	push   %edi
  801afd:	e8 b0 f1 ff ff       	call   800cb2 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	c1 ea 1f             	shr    $0x1f,%edx
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	84 d2                	test   %dl,%dl
  801b0c:	74 17                	je     801b25 <ipc_send+0x4a>
  801b0e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b11:	74 12                	je     801b25 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b13:	50                   	push   %eax
  801b14:	68 dc 22 80 00       	push   $0x8022dc
  801b19:	6a 47                	push   $0x47
  801b1b:	68 ea 22 80 00       	push   $0x8022ea
  801b20:	e8 fb fe ff ff       	call   801a20 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b25:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b28:	75 07                	jne    801b31 <ipc_send+0x56>
			sys_yield();
  801b2a:	e8 d7 ef ff ff       	call   800b06 <sys_yield>
  801b2f:	eb c6                	jmp    801af7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b31:	85 c0                	test   %eax,%eax
  801b33:	75 c2                	jne    801af7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5f                   	pop    %edi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b48:	89 c2                	mov    %eax,%edx
  801b4a:	c1 e2 07             	shl    $0x7,%edx
  801b4d:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b54:	8b 52 58             	mov    0x58(%edx),%edx
  801b57:	39 ca                	cmp    %ecx,%edx
  801b59:	75 11                	jne    801b6c <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b5b:	89 c2                	mov    %eax,%edx
  801b5d:	c1 e2 07             	shl    $0x7,%edx
  801b60:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b67:	8b 40 50             	mov    0x50(%eax),%eax
  801b6a:	eb 0f                	jmp    801b7b <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6c:	83 c0 01             	add    $0x1,%eax
  801b6f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b74:	75 d2                	jne    801b48 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b83:	89 d0                	mov    %edx,%eax
  801b85:	c1 e8 16             	shr    $0x16,%eax
  801b88:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b94:	f6 c1 01             	test   $0x1,%cl
  801b97:	74 1d                	je     801bb6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b99:	c1 ea 0c             	shr    $0xc,%edx
  801b9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba3:	f6 c2 01             	test   $0x1,%dl
  801ba6:	74 0e                	je     801bb6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba8:	c1 ea 0c             	shr    $0xc,%edx
  801bab:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb2:	ef 
  801bb3:	0f b7 c0             	movzwl %ax,%eax
}
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	66 90                	xchg   %ax,%ax
  801bba:	66 90                	xchg   %ax,%ax
  801bbc:	66 90                	xchg   %ax,%ax
  801bbe:	66 90                	xchg   %ax,%ax

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
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
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
