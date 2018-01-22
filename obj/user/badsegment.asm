
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800047:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80004e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800051:	e8 85 0a 00 00       	call   800adb <sys_getenvid>
  800056:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800058:	83 ec 08             	sub    $0x8,%esp
  80005b:	50                   	push   %eax
  80005c:	68 40 1e 80 00       	push   $0x801e40
  800061:	e8 2b 01 00 00       	call   800191 <cprintf>
  800066:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80006c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80007e:	89 c1                	mov    %eax,%ecx
  800080:	c1 e1 07             	shl    $0x7,%ecx
  800083:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80008a:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80008d:	39 cb                	cmp    %ecx,%ebx
  80008f:	0f 44 fa             	cmove  %edx,%edi
  800092:	b9 01 00 00 00       	mov    $0x1,%ecx
  800097:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000a8:	75 d4                	jne    80007e <libmain+0x40>
  8000aa:	89 f0                	mov    %esi,%eax
  8000ac:	84 c0                	test   %al,%al
  8000ae:	74 06                	je     8000b6 <libmain+0x78>
  8000b0:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ba:	7e 0a                	jle    8000c6 <libmain+0x88>
		binaryname = argv[0];
  8000bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000bf:	8b 00                	mov    (%eax),%eax
  8000c1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	ff 75 0c             	pushl  0xc(%ebp)
  8000cc:	ff 75 08             	pushl  0x8(%ebp)
  8000cf:	e8 5f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ea:	e8 06 0e 00 00       	call   800ef5 <close_all>
	sys_env_destroy(0);
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	6a 00                	push   $0x0
  8000f4:	e8 a1 09 00 00       	call   800a9a <sys_env_destroy>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	53                   	push   %ebx
  800102:	83 ec 04             	sub    $0x4,%esp
  800105:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800108:	8b 13                	mov    (%ebx),%edx
  80010a:	8d 42 01             	lea    0x1(%edx),%eax
  80010d:	89 03                	mov    %eax,(%ebx)
  80010f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800112:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	75 1a                	jne    800137 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 ff 00 00 00       	push   $0xff
  800125:	8d 43 08             	lea    0x8(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	e8 2f 09 00 00       	call   800a5d <sys_cputs>
		b->idx = 0;
  80012e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800134:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	68 fe 00 80 00       	push   $0x8000fe
  80016f:	e8 54 01 00 00       	call   8002c8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800174:	83 c4 08             	add    $0x8,%esp
  800177:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800183:	50                   	push   %eax
  800184:	e8 d4 08 00 00       	call   800a5d <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 9d ff ff ff       	call   800140 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 1c             	sub    $0x1c,%esp
  8001ae:	89 c7                	mov    %eax,%edi
  8001b0:	89 d6                	mov    %edx,%esi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cc:	39 d3                	cmp    %edx,%ebx
  8001ce:	72 05                	jb     8001d5 <printnum+0x30>
  8001d0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d3:	77 45                	ja     80021a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	ff 75 18             	pushl  0x18(%ebp)
  8001db:	8b 45 14             	mov    0x14(%ebp),%eax
  8001de:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e1:	53                   	push   %ebx
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 b7 19 00 00       	call   801bb0 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 9e ff ff ff       	call   8001a5 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 18                	jmp    800224 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb 03                	jmp    80021d <printnum+0x78>
  80021a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f e8                	jg     80020c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 a4 1a 00 00       	call   801ce0 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 69 1e 80 00 	movsbl 0x801e69(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800257:	83 fa 01             	cmp    $0x1,%edx
  80025a:	7e 0e                	jle    80026a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	8b 52 04             	mov    0x4(%edx),%edx
  800268:	eb 22                	jmp    80028c <getuint+0x38>
	else if (lflag)
  80026a:	85 d2                	test   %edx,%edx
  80026c:	74 10                	je     80027e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 04             	lea    0x4(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	ba 00 00 00 00       	mov    $0x0,%edx
  80027c:	eb 0e                	jmp    80028c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 04             	lea    0x4(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800294:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	3b 50 04             	cmp    0x4(%eax),%edx
  80029d:	73 0a                	jae    8002a9 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	88 02                	mov    %al,(%edx)
}
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b4:	50                   	push   %eax
  8002b5:	ff 75 10             	pushl  0x10(%ebp)
  8002b8:	ff 75 0c             	pushl  0xc(%ebp)
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 05 00 00 00       	call   8002c8 <vprintfmt>
	va_end(ap);
}
  8002c3:	83 c4 10             	add    $0x10,%esp
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 2c             	sub    $0x2c,%esp
  8002d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002da:	eb 12                	jmp    8002ee <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	0f 84 89 03 00 00    	je     80066d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	53                   	push   %ebx
  8002e8:	50                   	push   %eax
  8002e9:	ff d6                	call   *%esi
  8002eb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ee:	83 c7 01             	add    $0x1,%edi
  8002f1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f5:	83 f8 25             	cmp    $0x25,%eax
  8002f8:	75 e2                	jne    8002dc <vprintfmt+0x14>
  8002fa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fe:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800305:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800313:	ba 00 00 00 00       	mov    $0x0,%edx
  800318:	eb 07                	jmp    800321 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8d 47 01             	lea    0x1(%edi),%eax
  800324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800327:	0f b6 07             	movzbl (%edi),%eax
  80032a:	0f b6 c8             	movzbl %al,%ecx
  80032d:	83 e8 23             	sub    $0x23,%eax
  800330:	3c 55                	cmp    $0x55,%al
  800332:	0f 87 1a 03 00 00    	ja     800652 <vprintfmt+0x38a>
  800338:	0f b6 c0             	movzbl %al,%eax
  80033b:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800345:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800349:	eb d6                	jmp    800321 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034e:	b8 00 00 00 00       	mov    $0x0,%eax
  800353:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800356:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800359:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80035d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800360:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800363:	83 fa 09             	cmp    $0x9,%edx
  800366:	77 39                	ja     8003a1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800368:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036b:	eb e9                	jmp    800356 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036d:	8b 45 14             	mov    0x14(%ebp),%eax
  800370:	8d 48 04             	lea    0x4(%eax),%ecx
  800373:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800376:	8b 00                	mov    (%eax),%eax
  800378:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037e:	eb 27                	jmp    8003a7 <vprintfmt+0xdf>
  800380:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800383:	85 c0                	test   %eax,%eax
  800385:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038a:	0f 49 c8             	cmovns %eax,%ecx
  80038d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800393:	eb 8c                	jmp    800321 <vprintfmt+0x59>
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800398:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039f:	eb 80                	jmp    800321 <vprintfmt+0x59>
  8003a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ab:	0f 89 70 ff ff ff    	jns    800321 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003be:	e9 5e ff ff ff       	jmp    800321 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c9:	e9 53 ff ff ff       	jmp    800321 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	53                   	push   %ebx
  8003db:	ff 30                	pushl  (%eax)
  8003dd:	ff d6                	call   *%esi
			break;
  8003df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e5:	e9 04 ff ff ff       	jmp    8002ee <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	99                   	cltd   
  8003f6:	31 d0                	xor    %edx,%eax
  8003f8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fa:	83 f8 0f             	cmp    $0xf,%eax
  8003fd:	7f 0b                	jg     80040a <vprintfmt+0x142>
  8003ff:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800406:	85 d2                	test   %edx,%edx
  800408:	75 18                	jne    800422 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040a:	50                   	push   %eax
  80040b:	68 81 1e 80 00       	push   $0x801e81
  800410:	53                   	push   %ebx
  800411:	56                   	push   %esi
  800412:	e8 94 fe ff ff       	call   8002ab <printfmt>
  800417:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80041d:	e9 cc fe ff ff       	jmp    8002ee <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800422:	52                   	push   %edx
  800423:	68 31 22 80 00       	push   $0x802231
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	e8 7c fe ff ff       	call   8002ab <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800435:	e9 b4 fe ff ff       	jmp    8002ee <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800445:	85 ff                	test   %edi,%edi
  800447:	b8 7a 1e 80 00       	mov    $0x801e7a,%eax
  80044c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800453:	0f 8e 94 00 00 00    	jle    8004ed <vprintfmt+0x225>
  800459:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80045d:	0f 84 98 00 00 00    	je     8004fb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	ff 75 d0             	pushl  -0x30(%ebp)
  800469:	57                   	push   %edi
  80046a:	e8 86 02 00 00       	call   8006f5 <strnlen>
  80046f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800472:	29 c1                	sub    %eax,%ecx
  800474:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800481:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800484:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	eb 0f                	jmp    800497 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	53                   	push   %ebx
  80048c:	ff 75 e0             	pushl  -0x20(%ebp)
  80048f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	83 ef 01             	sub    $0x1,%edi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 ff                	test   %edi,%edi
  800499:	7f ed                	jg     800488 <vprintfmt+0x1c0>
  80049b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a1:	85 c9                	test   %ecx,%ecx
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	0f 49 c1             	cmovns %ecx,%eax
  8004ab:	29 c1                	sub    %eax,%ecx
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	89 cb                	mov    %ecx,%ebx
  8004b8:	eb 4d                	jmp    800507 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004be:	74 1b                	je     8004db <vprintfmt+0x213>
  8004c0:	0f be c0             	movsbl %al,%eax
  8004c3:	83 e8 20             	sub    $0x20,%eax
  8004c6:	83 f8 5e             	cmp    $0x5e,%eax
  8004c9:	76 10                	jbe    8004db <vprintfmt+0x213>
					putch('?', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	ff 75 0c             	pushl  0xc(%ebp)
  8004d1:	6a 3f                	push   $0x3f
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	eb 0d                	jmp    8004e8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	52                   	push   %edx
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e8:	83 eb 01             	sub    $0x1,%ebx
  8004eb:	eb 1a                	jmp    800507 <vprintfmt+0x23f>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	eb 0c                	jmp    800507 <vprintfmt+0x23f>
  8004fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800501:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800504:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800507:	83 c7 01             	add    $0x1,%edi
  80050a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050e:	0f be d0             	movsbl %al,%edx
  800511:	85 d2                	test   %edx,%edx
  800513:	74 23                	je     800538 <vprintfmt+0x270>
  800515:	85 f6                	test   %esi,%esi
  800517:	78 a1                	js     8004ba <vprintfmt+0x1f2>
  800519:	83 ee 01             	sub    $0x1,%esi
  80051c:	79 9c                	jns    8004ba <vprintfmt+0x1f2>
  80051e:	89 df                	mov    %ebx,%edi
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800526:	eb 18                	jmp    800540 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	6a 20                	push   $0x20
  80052e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 08                	jmp    800540 <vprintfmt+0x278>
  800538:	89 df                	mov    %ebx,%edi
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	85 ff                	test   %edi,%edi
  800542:	7f e4                	jg     800528 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800547:	e9 a2 fd ff ff       	jmp    8002ee <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054c:	83 fa 01             	cmp    $0x1,%edx
  80054f:	7e 16                	jle    800567 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 08             	lea    0x8(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 50 04             	mov    0x4(%eax),%edx
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800562:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800565:	eb 32                	jmp    800599 <vprintfmt+0x2d1>
	else if (lflag)
  800567:	85 d2                	test   %edx,%edx
  800569:	74 18                	je     800583 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800581:	eb 16                	jmp    800599 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800599:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a8:	79 74                	jns    80061e <vprintfmt+0x356>
				putch('-', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	6a 2d                	push   $0x2d
  8005b0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b8:	f7 d8                	neg    %eax
  8005ba:	83 d2 00             	adc    $0x0,%edx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c7:	eb 55                	jmp    80061e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 83 fc ff ff       	call   800254 <getuint>
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d6:	eb 46                	jmp    80061e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 74 fc ff ff       	call   800254 <getuint>
			base = 8;
  8005e0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e5:	eb 37                	jmp    80061e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	53                   	push   %ebx
  8005eb:	6a 30                	push   $0x30
  8005ed:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ef:	83 c4 08             	add    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 78                	push   $0x78
  8005f5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800607:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060f:	eb 0d                	jmp    80061e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 3b fc ff ff       	call   800254 <getuint>
			base = 16;
  800619:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061e:	83 ec 0c             	sub    $0xc,%esp
  800621:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800625:	57                   	push   %edi
  800626:	ff 75 e0             	pushl  -0x20(%ebp)
  800629:	51                   	push   %ecx
  80062a:	52                   	push   %edx
  80062b:	50                   	push   %eax
  80062c:	89 da                	mov    %ebx,%edx
  80062e:	89 f0                	mov    %esi,%eax
  800630:	e8 70 fb ff ff       	call   8001a5 <printnum>
			break;
  800635:	83 c4 20             	add    $0x20,%esp
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063b:	e9 ae fc ff ff       	jmp    8002ee <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	51                   	push   %ecx
  800645:	ff d6                	call   *%esi
			break;
  800647:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064d:	e9 9c fc ff ff       	jmp    8002ee <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 25                	push   $0x25
  800658:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	eb 03                	jmp    800662 <vprintfmt+0x39a>
  80065f:	83 ef 01             	sub    $0x1,%edi
  800662:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800666:	75 f7                	jne    80065f <vprintfmt+0x397>
  800668:	e9 81 fc ff ff       	jmp    8002ee <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800670:	5b                   	pop    %ebx
  800671:	5e                   	pop    %esi
  800672:	5f                   	pop    %edi
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 18             	sub    $0x18,%esp
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800681:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800684:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800688:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800692:	85 c0                	test   %eax,%eax
  800694:	74 26                	je     8006bc <vsnprintf+0x47>
  800696:	85 d2                	test   %edx,%edx
  800698:	7e 22                	jle    8006bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069a:	ff 75 14             	pushl  0x14(%ebp)
  80069d:	ff 75 10             	pushl  0x10(%ebp)
  8006a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	68 8e 02 80 00       	push   $0x80028e
  8006a9:	e8 1a fc ff ff       	call   8002c8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 05                	jmp    8006c1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cc:	50                   	push   %eax
  8006cd:	ff 75 10             	pushl  0x10(%ebp)
  8006d0:	ff 75 0c             	pushl  0xc(%ebp)
  8006d3:	ff 75 08             	pushl  0x8(%ebp)
  8006d6:	e8 9a ff ff ff       	call   800675 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	eb 03                	jmp    8006ed <strlen+0x10>
		n++;
  8006ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f1:	75 f7                	jne    8006ea <strlen+0xd>
		n++;
	return n;
}
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800703:	eb 03                	jmp    800708 <strnlen+0x13>
		n++;
  800705:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800708:	39 c2                	cmp    %eax,%edx
  80070a:	74 08                	je     800714 <strnlen+0x1f>
  80070c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800710:	75 f3                	jne    800705 <strnlen+0x10>
  800712:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800720:	89 c2                	mov    %eax,%edx
  800722:	83 c2 01             	add    $0x1,%edx
  800725:	83 c1 01             	add    $0x1,%ecx
  800728:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072f:	84 db                	test   %bl,%bl
  800731:	75 ef                	jne    800722 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800733:	5b                   	pop    %ebx
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073d:	53                   	push   %ebx
  80073e:	e8 9a ff ff ff       	call   8006dd <strlen>
  800743:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	50                   	push   %eax
  80074c:	e8 c5 ff ff ff       	call   800716 <strcpy>
	return dst;
}
  800751:	89 d8                	mov    %ebx,%eax
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	89 f3                	mov    %esi,%ebx
  800765:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800768:	89 f2                	mov    %esi,%edx
  80076a:	eb 0f                	jmp    80077b <strncpy+0x23>
		*dst++ = *src;
  80076c:	83 c2 01             	add    $0x1,%edx
  80076f:	0f b6 01             	movzbl (%ecx),%eax
  800772:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 39 01             	cmpb   $0x1,(%ecx)
  800778:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	39 da                	cmp    %ebx,%edx
  80077d:	75 ed                	jne    80076c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077f:	89 f0                	mov    %esi,%eax
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	8b 55 10             	mov    0x10(%ebp),%edx
  800793:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800795:	85 d2                	test   %edx,%edx
  800797:	74 21                	je     8007ba <strlcpy+0x35>
  800799:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079d:	89 f2                	mov    %esi,%edx
  80079f:	eb 09                	jmp    8007aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	83 c1 01             	add    $0x1,%ecx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 09                	je     8007b7 <strlcpy+0x32>
  8007ae:	0f b6 19             	movzbl (%ecx),%ebx
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ec                	jne    8007a1 <strlcpy+0x1c>
  8007b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ba:	29 f0                	sub    %esi,%eax
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c9:	eb 06                	jmp    8007d1 <strcmp+0x11>
		p++, q++;
  8007cb:	83 c1 01             	add    $0x1,%ecx
  8007ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d1:	0f b6 01             	movzbl (%ecx),%eax
  8007d4:	84 c0                	test   %al,%al
  8007d6:	74 04                	je     8007dc <strcmp+0x1c>
  8007d8:	3a 02                	cmp    (%edx),%al
  8007da:	74 ef                	je     8007cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dc:	0f b6 c0             	movzbl %al,%eax
  8007df:	0f b6 12             	movzbl (%edx),%edx
  8007e2:	29 d0                	sub    %edx,%eax
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	89 c3                	mov    %eax,%ebx
  8007f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f5:	eb 06                	jmp    8007fd <strncmp+0x17>
		n--, p++, q++;
  8007f7:	83 c0 01             	add    $0x1,%eax
  8007fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fd:	39 d8                	cmp    %ebx,%eax
  8007ff:	74 15                	je     800816 <strncmp+0x30>
  800801:	0f b6 08             	movzbl (%eax),%ecx
  800804:	84 c9                	test   %cl,%cl
  800806:	74 04                	je     80080c <strncmp+0x26>
  800808:	3a 0a                	cmp    (%edx),%cl
  80080a:	74 eb                	je     8007f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080c:	0f b6 00             	movzbl (%eax),%eax
  80080f:	0f b6 12             	movzbl (%edx),%edx
  800812:	29 d0                	sub    %edx,%eax
  800814:	eb 05                	jmp    80081b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081b:	5b                   	pop    %ebx
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800828:	eb 07                	jmp    800831 <strchr+0x13>
		if (*s == c)
  80082a:	38 ca                	cmp    %cl,%dl
  80082c:	74 0f                	je     80083d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	0f b6 10             	movzbl (%eax),%edx
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f2                	jne    80082a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800849:	eb 03                	jmp    80084e <strfind+0xf>
  80084b:	83 c0 01             	add    $0x1,%eax
  80084e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 04                	je     800859 <strfind+0x1a>
  800855:	84 d2                	test   %dl,%dl
  800857:	75 f2                	jne    80084b <strfind+0xc>
			break;
	return (char *) s;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	57                   	push   %edi
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 7d 08             	mov    0x8(%ebp),%edi
  800864:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800867:	85 c9                	test   %ecx,%ecx
  800869:	74 36                	je     8008a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800871:	75 28                	jne    80089b <memset+0x40>
  800873:	f6 c1 03             	test   $0x3,%cl
  800876:	75 23                	jne    80089b <memset+0x40>
		c &= 0xFF;
  800878:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087c:	89 d3                	mov    %edx,%ebx
  80087e:	c1 e3 08             	shl    $0x8,%ebx
  800881:	89 d6                	mov    %edx,%esi
  800883:	c1 e6 18             	shl    $0x18,%esi
  800886:	89 d0                	mov    %edx,%eax
  800888:	c1 e0 10             	shl    $0x10,%eax
  80088b:	09 f0                	or     %esi,%eax
  80088d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088f:	89 d8                	mov    %ebx,%eax
  800891:	09 d0                	or     %edx,%eax
  800893:	c1 e9 02             	shr    $0x2,%ecx
  800896:	fc                   	cld    
  800897:	f3 ab                	rep stos %eax,%es:(%edi)
  800899:	eb 06                	jmp    8008a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	fc                   	cld    
  80089f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b6:	39 c6                	cmp    %eax,%esi
  8008b8:	73 35                	jae    8008ef <memmove+0x47>
  8008ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bd:	39 d0                	cmp    %edx,%eax
  8008bf:	73 2e                	jae    8008ef <memmove+0x47>
		s += n;
		d += n;
  8008c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	09 fe                	or     %edi,%esi
  8008c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ce:	75 13                	jne    8008e3 <memmove+0x3b>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 0e                	jne    8008e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d5:	83 ef 04             	sub    $0x4,%edi
  8008d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008db:	c1 e9 02             	shr    $0x2,%ecx
  8008de:	fd                   	std    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 09                	jmp    8008ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e3:	83 ef 01             	sub    $0x1,%edi
  8008e6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e9:	fd                   	std    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ec:	fc                   	cld    
  8008ed:	eb 1d                	jmp    80090c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ef:	89 f2                	mov    %esi,%edx
  8008f1:	09 c2                	or     %eax,%edx
  8008f3:	f6 c2 03             	test   $0x3,%dl
  8008f6:	75 0f                	jne    800907 <memmove+0x5f>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 0a                	jne    800907 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	89 c7                	mov    %eax,%edi
  800902:	fc                   	cld    
  800903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800905:	eb 05                	jmp    80090c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800907:	89 c7                	mov    %eax,%edi
  800909:	fc                   	cld    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800913:	ff 75 10             	pushl  0x10(%ebp)
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	ff 75 08             	pushl  0x8(%ebp)
  80091c:	e8 87 ff ff ff       	call   8008a8 <memmove>
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	eb 1a                	jmp    80094f <memcmp+0x2c>
		if (*s1 != *s2)
  800935:	0f b6 08             	movzbl (%eax),%ecx
  800938:	0f b6 1a             	movzbl (%edx),%ebx
  80093b:	38 d9                	cmp    %bl,%cl
  80093d:	74 0a                	je     800949 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093f:	0f b6 c1             	movzbl %cl,%eax
  800942:	0f b6 db             	movzbl %bl,%ebx
  800945:	29 d8                	sub    %ebx,%eax
  800947:	eb 0f                	jmp    800958 <memcmp+0x35>
		s1++, s2++;
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	39 f0                	cmp    %esi,%eax
  800951:	75 e2                	jne    800935 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800963:	89 c1                	mov    %eax,%ecx
  800965:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800968:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096c:	eb 0a                	jmp    800978 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	39 da                	cmp    %ebx,%edx
  800973:	74 07                	je     80097c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	39 c8                	cmp    %ecx,%eax
  80097a:	72 f2                	jb     80096e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098b:	eb 03                	jmp    800990 <strtol+0x11>
		s++;
  80098d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800990:	0f b6 01             	movzbl (%ecx),%eax
  800993:	3c 20                	cmp    $0x20,%al
  800995:	74 f6                	je     80098d <strtol+0xe>
  800997:	3c 09                	cmp    $0x9,%al
  800999:	74 f2                	je     80098d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099b:	3c 2b                	cmp    $0x2b,%al
  80099d:	75 0a                	jne    8009a9 <strtol+0x2a>
		s++;
  80099f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a7:	eb 11                	jmp    8009ba <strtol+0x3b>
  8009a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ae:	3c 2d                	cmp    $0x2d,%al
  8009b0:	75 08                	jne    8009ba <strtol+0x3b>
		s++, neg = 1;
  8009b2:	83 c1 01             	add    $0x1,%ecx
  8009b5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c0:	75 15                	jne    8009d7 <strtol+0x58>
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 10                	jne    8009d7 <strtol+0x58>
  8009c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cb:	75 7c                	jne    800a49 <strtol+0xca>
		s += 2, base = 16;
  8009cd:	83 c1 02             	add    $0x2,%ecx
  8009d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d5:	eb 16                	jmp    8009ed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	75 12                	jne    8009ed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e3:	75 08                	jne    8009ed <strtol+0x6e>
		s++, base = 8;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f5:	0f b6 11             	movzbl (%ecx),%edx
  8009f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x8b>
			dig = *s - '0';
  800a02:	0f be d2             	movsbl %dl,%edx
  800a05:	83 ea 30             	sub    $0x30,%edx
  800a08:	eb 22                	jmp    800a2c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 19             	cmp    $0x19,%bl
  800a12:	77 08                	ja     800a1c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 57             	sub    $0x57,%edx
  800a1a:	eb 10                	jmp    800a2c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 16                	ja     800a3c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2f:	7d 0b                	jge    800a3c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3a:	eb b9                	jmp    8009f5 <strtol+0x76>

	if (endptr)
  800a3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a40:	74 0d                	je     800a4f <strtol+0xd0>
		*endptr = (char *) s;
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	89 0e                	mov    %ecx,(%esi)
  800a47:	eb 06                	jmp    800a4f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	74 98                	je     8009e5 <strtol+0x66>
  800a4d:	eb 9e                	jmp    8009ed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	f7 da                	neg    %edx
  800a53:	85 ff                	test   %edi,%edi
  800a55:	0f 45 c2             	cmovne %edx,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	89 c7                	mov    %eax,%edi
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8b:	89 d1                	mov    %edx,%ecx
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	89 d7                	mov    %edx,%edi
  800a91:	89 d6                	mov    %edx,%esi
  800a93:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa8:	b8 03 00 00 00       	mov    $0x3,%eax
  800aad:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab0:	89 cb                	mov    %ecx,%ebx
  800ab2:	89 cf                	mov    %ecx,%edi
  800ab4:	89 ce                	mov    %ecx,%esi
  800ab6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	7e 17                	jle    800ad3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	50                   	push   %eax
  800ac0:	6a 03                	push   $0x3
  800ac2:	68 5f 21 80 00       	push   $0x80215f
  800ac7:	6a 23                	push   $0x23
  800ac9:	68 7c 21 80 00       	push   $0x80217c
  800ace:	e8 41 0f 00 00       	call   801a14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_yield>:

void
sys_yield(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	be 00 00 00 00       	mov    $0x0,%esi
  800b27:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b35:	89 f7                	mov    %esi,%edi
  800b37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 04                	push   $0x4
  800b43:	68 5f 21 80 00       	push   $0x80215f
  800b48:	6a 23                	push   $0x23
  800b4a:	68 7c 21 80 00       	push   $0x80217c
  800b4f:	e8 c0 0e 00 00       	call   801a14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b76:	8b 75 18             	mov    0x18(%ebp),%esi
  800b79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 17                	jle    800b96 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 05                	push   $0x5
  800b85:	68 5f 21 80 00       	push   $0x80215f
  800b8a:	6a 23                	push   $0x23
  800b8c:	68 7c 21 80 00       	push   $0x80217c
  800b91:	e8 7e 0e 00 00       	call   801a14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bac:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 df                	mov    %ebx,%edi
  800bb9:	89 de                	mov    %ebx,%esi
  800bbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 06                	push   $0x6
  800bc7:	68 5f 21 80 00       	push   $0x80215f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 7c 21 80 00       	push   $0x80217c
  800bd3:	e8 3c 0e 00 00       	call   801a14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 08                	push   $0x8
  800c09:	68 5f 21 80 00       	push   $0x80215f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 7c 21 80 00       	push   $0x80217c
  800c15:	e8 fa 0d 00 00       	call   801a14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c30:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800c43:	7e 17                	jle    800c5c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 09                	push   $0x9
  800c4b:	68 5f 21 80 00       	push   $0x80215f
  800c50:	6a 23                	push   $0x23
  800c52:	68 7c 21 80 00       	push   $0x80217c
  800c57:	e8 b8 0d 00 00       	call   801a14 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c72:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c85:	7e 17                	jle    800c9e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 0a                	push   $0xa
  800c8d:	68 5f 21 80 00       	push   $0x80215f
  800c92:	6a 23                	push   $0x23
  800c94:	68 7c 21 80 00       	push   $0x80217c
  800c99:	e8 76 0d 00 00       	call   801a14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	be 00 00 00 00       	mov    $0x0,%esi
  800cb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 0d                	push   $0xd
  800cf1:	68 5f 21 80 00       	push   $0x80215f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 7c 21 80 00       	push   $0x80217c
  800cfd:	e8 12 0d 00 00       	call   801a14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d15:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 cb                	mov    %ecx,%ebx
  800d1f:	89 cf                	mov    %ecx,%edi
  800d21:	89 ce                	mov    %ecx,%esi
  800d23:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	05 00 00 00 30       	add    $0x30000000,%eax
  800d35:	c1 e8 0c             	shr    $0xc,%eax
}
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	05 00 00 00 30       	add    $0x30000000,%eax
  800d45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d57:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	c1 ea 16             	shr    $0x16,%edx
  800d61:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d68:	f6 c2 01             	test   $0x1,%dl
  800d6b:	74 11                	je     800d7e <fd_alloc+0x2d>
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	c1 ea 0c             	shr    $0xc,%edx
  800d72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d79:	f6 c2 01             	test   $0x1,%dl
  800d7c:	75 09                	jne    800d87 <fd_alloc+0x36>
			*fd_store = fd;
  800d7e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d80:	b8 00 00 00 00       	mov    $0x0,%eax
  800d85:	eb 17                	jmp    800d9e <fd_alloc+0x4d>
  800d87:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d8c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d91:	75 c9                	jne    800d5c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d93:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d99:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da6:	83 f8 1f             	cmp    $0x1f,%eax
  800da9:	77 36                	ja     800de1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dab:	c1 e0 0c             	shl    $0xc,%eax
  800dae:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db3:	89 c2                	mov    %eax,%edx
  800db5:	c1 ea 16             	shr    $0x16,%edx
  800db8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dbf:	f6 c2 01             	test   $0x1,%dl
  800dc2:	74 24                	je     800de8 <fd_lookup+0x48>
  800dc4:	89 c2                	mov    %eax,%edx
  800dc6:	c1 ea 0c             	shr    $0xc,%edx
  800dc9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd0:	f6 c2 01             	test   $0x1,%dl
  800dd3:	74 1a                	je     800def <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd8:	89 02                	mov    %eax,(%edx)
	return 0;
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddf:	eb 13                	jmp    800df4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de6:	eb 0c                	jmp    800df4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ded:	eb 05                	jmp    800df4 <fd_lookup+0x54>
  800def:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	83 ec 08             	sub    $0x8,%esp
  800dfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dff:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e04:	eb 13                	jmp    800e19 <dev_lookup+0x23>
  800e06:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e09:	39 08                	cmp    %ecx,(%eax)
  800e0b:	75 0c                	jne    800e19 <dev_lookup+0x23>
			*dev = devtab[i];
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e12:	b8 00 00 00 00       	mov    $0x0,%eax
  800e17:	eb 2e                	jmp    800e47 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e19:	8b 02                	mov    (%edx),%eax
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	75 e7                	jne    800e06 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e1f:	a1 04 40 80 00       	mov    0x804004,%eax
  800e24:	8b 40 50             	mov    0x50(%eax),%eax
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	51                   	push   %ecx
  800e2b:	50                   	push   %eax
  800e2c:	68 8c 21 80 00       	push   $0x80218c
  800e31:	e8 5b f3 ff ff       	call   800191 <cprintf>
	*dev = 0;
  800e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    

00800e49 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 10             	sub    $0x10,%esp
  800e51:	8b 75 08             	mov    0x8(%ebp),%esi
  800e54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5a:	50                   	push   %eax
  800e5b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e61:	c1 e8 0c             	shr    $0xc,%eax
  800e64:	50                   	push   %eax
  800e65:	e8 36 ff ff ff       	call   800da0 <fd_lookup>
  800e6a:	83 c4 08             	add    $0x8,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 05                	js     800e76 <fd_close+0x2d>
	    || fd != fd2)
  800e71:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e74:	74 0c                	je     800e82 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e76:	84 db                	test   %bl,%bl
  800e78:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7d:	0f 44 c2             	cmove  %edx,%eax
  800e80:	eb 41                	jmp    800ec3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e88:	50                   	push   %eax
  800e89:	ff 36                	pushl  (%esi)
  800e8b:	e8 66 ff ff ff       	call   800df6 <dev_lookup>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 1a                	js     800eb3 <fd_close+0x6a>
		if (dev->dev_close)
  800e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	74 0b                	je     800eb3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	56                   	push   %esi
  800eac:	ff d0                	call   *%eax
  800eae:	89 c3                	mov    %eax,%ebx
  800eb0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb3:	83 ec 08             	sub    $0x8,%esp
  800eb6:	56                   	push   %esi
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 e0 fc ff ff       	call   800b9e <sys_page_unmap>
	return r;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	89 d8                	mov    %ebx,%eax
}
  800ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed3:	50                   	push   %eax
  800ed4:	ff 75 08             	pushl  0x8(%ebp)
  800ed7:	e8 c4 fe ff ff       	call   800da0 <fd_lookup>
  800edc:	83 c4 08             	add    $0x8,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	78 10                	js     800ef3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	6a 01                	push   $0x1
  800ee8:	ff 75 f4             	pushl  -0xc(%ebp)
  800eeb:	e8 59 ff ff ff       	call   800e49 <fd_close>
  800ef0:	83 c4 10             	add    $0x10,%esp
}
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <close_all>:

void
close_all(void)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	53                   	push   %ebx
  800f05:	e8 c0 ff ff ff       	call   800eca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0a:	83 c3 01             	add    $0x1,%ebx
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	83 fb 20             	cmp    $0x20,%ebx
  800f13:	75 ec                	jne    800f01 <close_all+0xc>
		close(i);
}
  800f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 2c             	sub    $0x2c,%esp
  800f23:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f26:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f29:	50                   	push   %eax
  800f2a:	ff 75 08             	pushl  0x8(%ebp)
  800f2d:	e8 6e fe ff ff       	call   800da0 <fd_lookup>
  800f32:	83 c4 08             	add    $0x8,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	0f 88 c1 00 00 00    	js     800ffe <dup+0xe4>
		return r;
	close(newfdnum);
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	56                   	push   %esi
  800f41:	e8 84 ff ff ff       	call   800eca <close>

	newfd = INDEX2FD(newfdnum);
  800f46:	89 f3                	mov    %esi,%ebx
  800f48:	c1 e3 0c             	shl    $0xc,%ebx
  800f4b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f51:	83 c4 04             	add    $0x4,%esp
  800f54:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f57:	e8 de fd ff ff       	call   800d3a <fd2data>
  800f5c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f5e:	89 1c 24             	mov    %ebx,(%esp)
  800f61:	e8 d4 fd ff ff       	call   800d3a <fd2data>
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f6c:	89 f8                	mov    %edi,%eax
  800f6e:	c1 e8 16             	shr    $0x16,%eax
  800f71:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f78:	a8 01                	test   $0x1,%al
  800f7a:	74 37                	je     800fb3 <dup+0x99>
  800f7c:	89 f8                	mov    %edi,%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
  800f81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f88:	f6 c2 01             	test   $0x1,%dl
  800f8b:	74 26                	je     800fb3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9c:	50                   	push   %eax
  800f9d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa0:	6a 00                	push   $0x0
  800fa2:	57                   	push   %edi
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 b2 fb ff ff       	call   800b5c <sys_page_map>
  800faa:	89 c7                	mov    %eax,%edi
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 2e                	js     800fe1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb6:	89 d0                	mov    %edx,%eax
  800fb8:	c1 e8 0c             	shr    $0xc,%eax
  800fbb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fca:	50                   	push   %eax
  800fcb:	53                   	push   %ebx
  800fcc:	6a 00                	push   $0x0
  800fce:	52                   	push   %edx
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 86 fb ff ff       	call   800b5c <sys_page_map>
  800fd6:	89 c7                	mov    %eax,%edi
  800fd8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fdb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fdd:	85 ff                	test   %edi,%edi
  800fdf:	79 1d                	jns    800ffe <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	53                   	push   %ebx
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 b2 fb ff ff       	call   800b9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff2:	6a 00                	push   $0x0
  800ff4:	e8 a5 fb ff ff       	call   800b9e <sys_page_unmap>
	return r;
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	89 f8                	mov    %edi,%eax
}
  800ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	53                   	push   %ebx
  80100a:	83 ec 14             	sub    $0x14,%esp
  80100d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801010:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801013:	50                   	push   %eax
  801014:	53                   	push   %ebx
  801015:	e8 86 fd ff ff       	call   800da0 <fd_lookup>
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	89 c2                	mov    %eax,%edx
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 6d                	js     801090 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801029:	50                   	push   %eax
  80102a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80102d:	ff 30                	pushl  (%eax)
  80102f:	e8 c2 fd ff ff       	call   800df6 <dev_lookup>
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 4c                	js     801087 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80103e:	8b 42 08             	mov    0x8(%edx),%eax
  801041:	83 e0 03             	and    $0x3,%eax
  801044:	83 f8 01             	cmp    $0x1,%eax
  801047:	75 21                	jne    80106a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801049:	a1 04 40 80 00       	mov    0x804004,%eax
  80104e:	8b 40 50             	mov    0x50(%eax),%eax
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	53                   	push   %ebx
  801055:	50                   	push   %eax
  801056:	68 cd 21 80 00       	push   $0x8021cd
  80105b:	e8 31 f1 ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801068:	eb 26                	jmp    801090 <read+0x8a>
	}
	if (!dev->dev_read)
  80106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106d:	8b 40 08             	mov    0x8(%eax),%eax
  801070:	85 c0                	test   %eax,%eax
  801072:	74 17                	je     80108b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801074:	83 ec 04             	sub    $0x4,%esp
  801077:	ff 75 10             	pushl  0x10(%ebp)
  80107a:	ff 75 0c             	pushl  0xc(%ebp)
  80107d:	52                   	push   %edx
  80107e:	ff d0                	call   *%eax
  801080:	89 c2                	mov    %eax,%edx
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	eb 09                	jmp    801090 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801087:	89 c2                	mov    %eax,%edx
  801089:	eb 05                	jmp    801090 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80108b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801090:	89 d0                	mov    %edx,%eax
  801092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	eb 21                	jmp    8010ce <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ad:	83 ec 04             	sub    $0x4,%esp
  8010b0:	89 f0                	mov    %esi,%eax
  8010b2:	29 d8                	sub    %ebx,%eax
  8010b4:	50                   	push   %eax
  8010b5:	89 d8                	mov    %ebx,%eax
  8010b7:	03 45 0c             	add    0xc(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	57                   	push   %edi
  8010bc:	e8 45 ff ff ff       	call   801006 <read>
		if (m < 0)
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 10                	js     8010d8 <readn+0x41>
			return m;
		if (m == 0)
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	74 0a                	je     8010d6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cc:	01 c3                	add    %eax,%ebx
  8010ce:	39 f3                	cmp    %esi,%ebx
  8010d0:	72 db                	jb     8010ad <readn+0x16>
  8010d2:	89 d8                	mov    %ebx,%eax
  8010d4:	eb 02                	jmp    8010d8 <readn+0x41>
  8010d6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 14             	sub    $0x14,%esp
  8010e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	53                   	push   %ebx
  8010ef:	e8 ac fc ff ff       	call   800da0 <fd_lookup>
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 68                	js     801165 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801107:	ff 30                	pushl  (%eax)
  801109:	e8 e8 fc ff ff       	call   800df6 <dev_lookup>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 47                	js     80115c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801115:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801118:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80111c:	75 21                	jne    80113f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80111e:	a1 04 40 80 00       	mov    0x804004,%eax
  801123:	8b 40 50             	mov    0x50(%eax),%eax
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	53                   	push   %ebx
  80112a:	50                   	push   %eax
  80112b:	68 e9 21 80 00       	push   $0x8021e9
  801130:	e8 5c f0 ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113d:	eb 26                	jmp    801165 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80113f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801142:	8b 52 0c             	mov    0xc(%edx),%edx
  801145:	85 d2                	test   %edx,%edx
  801147:	74 17                	je     801160 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	ff 75 10             	pushl  0x10(%ebp)
  80114f:	ff 75 0c             	pushl  0xc(%ebp)
  801152:	50                   	push   %eax
  801153:	ff d2                	call   *%edx
  801155:	89 c2                	mov    %eax,%edx
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	eb 09                	jmp    801165 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	eb 05                	jmp    801165 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801160:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801165:	89 d0                	mov    %edx,%eax
  801167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <seek>:

int
seek(int fdnum, off_t offset)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801172:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	ff 75 08             	pushl  0x8(%ebp)
  801179:	e8 22 fc ff ff       	call   800da0 <fd_lookup>
  80117e:	83 c4 08             	add    $0x8,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	78 0e                	js     801193 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801185:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	53                   	push   %ebx
  801199:	83 ec 14             	sub    $0x14,%esp
  80119c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	53                   	push   %ebx
  8011a4:	e8 f7 fb ff ff       	call   800da0 <fd_lookup>
  8011a9:	83 c4 08             	add    $0x8,%esp
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 65                	js     801217 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bc:	ff 30                	pushl  (%eax)
  8011be:	e8 33 fc ff ff       	call   800df6 <dev_lookup>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 44                	js     80120e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d1:	75 21                	jne    8011f4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011d3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d8:	8b 40 50             	mov    0x50(%eax),%eax
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	53                   	push   %ebx
  8011df:	50                   	push   %eax
  8011e0:	68 ac 21 80 00       	push   $0x8021ac
  8011e5:	e8 a7 ef ff ff       	call   800191 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f2:	eb 23                	jmp    801217 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f7:	8b 52 18             	mov    0x18(%edx),%edx
  8011fa:	85 d2                	test   %edx,%edx
  8011fc:	74 14                	je     801212 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	ff 75 0c             	pushl  0xc(%ebp)
  801204:	50                   	push   %eax
  801205:	ff d2                	call   *%edx
  801207:	89 c2                	mov    %eax,%edx
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	eb 09                	jmp    801217 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120e:	89 c2                	mov    %eax,%edx
  801210:	eb 05                	jmp    801217 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801212:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801217:	89 d0                	mov    %edx,%eax
  801219:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	53                   	push   %ebx
  801222:	83 ec 14             	sub    $0x14,%esp
  801225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801228:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	e8 6c fb ff ff       	call   800da0 <fd_lookup>
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	89 c2                	mov    %eax,%edx
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 58                	js     801295 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801247:	ff 30                	pushl  (%eax)
  801249:	e8 a8 fb ff ff       	call   800df6 <dev_lookup>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 37                	js     80128c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801258:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125c:	74 32                	je     801290 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80125e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801261:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801268:	00 00 00 
	stat->st_isdir = 0;
  80126b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801272:	00 00 00 
	stat->st_dev = dev;
  801275:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	53                   	push   %ebx
  80127f:	ff 75 f0             	pushl  -0x10(%ebp)
  801282:	ff 50 14             	call   *0x14(%eax)
  801285:	89 c2                	mov    %eax,%edx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	eb 09                	jmp    801295 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	eb 05                	jmp    801295 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801290:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801295:	89 d0                	mov    %edx,%eax
  801297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	6a 00                	push   $0x0
  8012a6:	ff 75 08             	pushl  0x8(%ebp)
  8012a9:	e8 e3 01 00 00       	call   801491 <open>
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 1b                	js     8012d2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	ff 75 0c             	pushl  0xc(%ebp)
  8012bd:	50                   	push   %eax
  8012be:	e8 5b ff ff ff       	call   80121e <fstat>
  8012c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c5:	89 1c 24             	mov    %ebx,(%esp)
  8012c8:	e8 fd fb ff ff       	call   800eca <close>
	return r;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	89 f0                	mov    %esi,%eax
}
  8012d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	89 c6                	mov    %eax,%esi
  8012e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e9:	75 12                	jne    8012fd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	6a 01                	push   $0x1
  8012f0:	e8 3c 08 00 00       	call   801b31 <ipc_find_env>
  8012f5:	a3 00 40 80 00       	mov    %eax,0x804000
  8012fa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012fd:	6a 07                	push   $0x7
  8012ff:	68 00 50 80 00       	push   $0x805000
  801304:	56                   	push   %esi
  801305:	ff 35 00 40 80 00    	pushl  0x804000
  80130b:	e8 bf 07 00 00       	call   801acf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801310:	83 c4 0c             	add    $0xc,%esp
  801313:	6a 00                	push   $0x0
  801315:	53                   	push   %ebx
  801316:	6a 00                	push   $0x0
  801318:	e8 3d 07 00 00       	call   801a5a <ipc_recv>
}
  80131d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132a:	8b 45 08             	mov    0x8(%ebp),%eax
  80132d:	8b 40 0c             	mov    0xc(%eax),%eax
  801330:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801335:	8b 45 0c             	mov    0xc(%ebp),%eax
  801338:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80133d:	ba 00 00 00 00       	mov    $0x0,%edx
  801342:	b8 02 00 00 00       	mov    $0x2,%eax
  801347:	e8 8d ff ff ff       	call   8012d9 <fsipc>
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
  801357:	8b 40 0c             	mov    0xc(%eax),%eax
  80135a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 06 00 00 00       	mov    $0x6,%eax
  801369:	e8 6b ff ff ff       	call   8012d9 <fsipc>
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	53                   	push   %ebx
  801374:	83 ec 04             	sub    $0x4,%esp
  801377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	8b 40 0c             	mov    0xc(%eax),%eax
  801380:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801385:	ba 00 00 00 00       	mov    $0x0,%edx
  80138a:	b8 05 00 00 00       	mov    $0x5,%eax
  80138f:	e8 45 ff ff ff       	call   8012d9 <fsipc>
  801394:	85 c0                	test   %eax,%eax
  801396:	78 2c                	js     8013c4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	68 00 50 80 00       	push   $0x805000
  8013a0:	53                   	push   %ebx
  8013a1:	e8 70 f3 ff ff       	call   800716 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b1:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 0c             	sub    $0xc,%esp
  8013cf:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013de:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013e3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013e8:	0f 47 c2             	cmova  %edx,%eax
  8013eb:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013f0:	50                   	push   %eax
  8013f1:	ff 75 0c             	pushl  0xc(%ebp)
  8013f4:	68 08 50 80 00       	push   $0x805008
  8013f9:	e8 aa f4 ff ff       	call   8008a8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801403:	b8 04 00 00 00       	mov    $0x4,%eax
  801408:	e8 cc fe ff ff       	call   8012d9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	56                   	push   %esi
  801413:	53                   	push   %ebx
  801414:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	8b 40 0c             	mov    0xc(%eax),%eax
  80141d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801422:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801428:	ba 00 00 00 00       	mov    $0x0,%edx
  80142d:	b8 03 00 00 00       	mov    $0x3,%eax
  801432:	e8 a2 fe ff ff       	call   8012d9 <fsipc>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 4b                	js     801488 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80143d:	39 c6                	cmp    %eax,%esi
  80143f:	73 16                	jae    801457 <devfile_read+0x48>
  801441:	68 18 22 80 00       	push   $0x802218
  801446:	68 1f 22 80 00       	push   $0x80221f
  80144b:	6a 7c                	push   $0x7c
  80144d:	68 34 22 80 00       	push   $0x802234
  801452:	e8 bd 05 00 00       	call   801a14 <_panic>
	assert(r <= PGSIZE);
  801457:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80145c:	7e 16                	jle    801474 <devfile_read+0x65>
  80145e:	68 3f 22 80 00       	push   $0x80223f
  801463:	68 1f 22 80 00       	push   $0x80221f
  801468:	6a 7d                	push   $0x7d
  80146a:	68 34 22 80 00       	push   $0x802234
  80146f:	e8 a0 05 00 00       	call   801a14 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	50                   	push   %eax
  801478:	68 00 50 80 00       	push   $0x805000
  80147d:	ff 75 0c             	pushl  0xc(%ebp)
  801480:	e8 23 f4 ff ff       	call   8008a8 <memmove>
	return r;
  801485:	83 c4 10             	add    $0x10,%esp
}
  801488:	89 d8                	mov    %ebx,%eax
  80148a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 20             	sub    $0x20,%esp
  801498:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80149b:	53                   	push   %ebx
  80149c:	e8 3c f2 ff ff       	call   8006dd <strlen>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014a9:	7f 67                	jg     801512 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	e8 9a f8 ff ff       	call   800d51 <fd_alloc>
  8014b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ba:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 57                	js     801517 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	68 00 50 80 00       	push   $0x805000
  8014c9:	e8 48 f2 ff ff       	call   800716 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014de:	e8 f6 fd ff ff       	call   8012d9 <fsipc>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	79 14                	jns    801500 <open+0x6f>
		fd_close(fd, 0);
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	6a 00                	push   $0x0
  8014f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f4:	e8 50 f9 ff ff       	call   800e49 <fd_close>
		return r;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	89 da                	mov    %ebx,%edx
  8014fe:	eb 17                	jmp    801517 <open+0x86>
	}

	return fd2num(fd);
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	ff 75 f4             	pushl  -0xc(%ebp)
  801506:	e8 1f f8 ff ff       	call   800d2a <fd2num>
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	eb 05                	jmp    801517 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801512:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801517:	89 d0                	mov    %edx,%eax
  801519:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    

0080151e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 08 00 00 00       	mov    $0x8,%eax
  80152e:	e8 a6 fd ff ff       	call   8012d9 <fsipc>
}
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	56                   	push   %esi
  801539:	53                   	push   %ebx
  80153a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	ff 75 08             	pushl  0x8(%ebp)
  801543:	e8 f2 f7 ff ff       	call   800d3a <fd2data>
  801548:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80154a:	83 c4 08             	add    $0x8,%esp
  80154d:	68 4b 22 80 00       	push   $0x80224b
  801552:	53                   	push   %ebx
  801553:	e8 be f1 ff ff       	call   800716 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801558:	8b 46 04             	mov    0x4(%esi),%eax
  80155b:	2b 06                	sub    (%esi),%eax
  80155d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801563:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156a:	00 00 00 
	stat->st_dev = &devpipe;
  80156d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801574:	30 80 00 
	return 0;
}
  801577:	b8 00 00 00 00       	mov    $0x0,%eax
  80157c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    

00801583 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	53                   	push   %ebx
  801587:	83 ec 0c             	sub    $0xc,%esp
  80158a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80158d:	53                   	push   %ebx
  80158e:	6a 00                	push   $0x0
  801590:	e8 09 f6 ff ff       	call   800b9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801595:	89 1c 24             	mov    %ebx,(%esp)
  801598:	e8 9d f7 ff ff       	call   800d3a <fd2data>
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	50                   	push   %eax
  8015a1:	6a 00                	push   $0x0
  8015a3:	e8 f6 f5 ff ff       	call   800b9e <sys_page_unmap>
}
  8015a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	57                   	push   %edi
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 1c             	sub    $0x1c,%esp
  8015b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015b9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c0:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c9:	e8 a3 05 00 00       	call   801b71 <pageref>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	89 3c 24             	mov    %edi,(%esp)
  8015d3:	e8 99 05 00 00       	call   801b71 <pageref>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	39 c3                	cmp    %eax,%ebx
  8015dd:	0f 94 c1             	sete   %cl
  8015e0:	0f b6 c9             	movzbl %cl,%ecx
  8015e3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015e6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015ec:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015ef:	39 ce                	cmp    %ecx,%esi
  8015f1:	74 1b                	je     80160e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015f3:	39 c3                	cmp    %eax,%ebx
  8015f5:	75 c4                	jne    8015bb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f7:	8b 42 60             	mov    0x60(%edx),%eax
  8015fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fd:	50                   	push   %eax
  8015fe:	56                   	push   %esi
  8015ff:	68 52 22 80 00       	push   $0x802252
  801604:	e8 88 eb ff ff       	call   800191 <cprintf>
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb ad                	jmp    8015bb <_pipeisclosed+0xe>
	}
}
  80160e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801611:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801614:	5b                   	pop    %ebx
  801615:	5e                   	pop    %esi
  801616:	5f                   	pop    %edi
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	57                   	push   %edi
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	83 ec 28             	sub    $0x28,%esp
  801622:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801625:	56                   	push   %esi
  801626:	e8 0f f7 ff ff       	call   800d3a <fd2data>
  80162b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	bf 00 00 00 00       	mov    $0x0,%edi
  801635:	eb 4b                	jmp    801682 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801637:	89 da                	mov    %ebx,%edx
  801639:	89 f0                	mov    %esi,%eax
  80163b:	e8 6d ff ff ff       	call   8015ad <_pipeisclosed>
  801640:	85 c0                	test   %eax,%eax
  801642:	75 48                	jne    80168c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801644:	e8 b1 f4 ff ff       	call   800afa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801649:	8b 43 04             	mov    0x4(%ebx),%eax
  80164c:	8b 0b                	mov    (%ebx),%ecx
  80164e:	8d 51 20             	lea    0x20(%ecx),%edx
  801651:	39 d0                	cmp    %edx,%eax
  801653:	73 e2                	jae    801637 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801655:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801658:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80165c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80165f:	89 c2                	mov    %eax,%edx
  801661:	c1 fa 1f             	sar    $0x1f,%edx
  801664:	89 d1                	mov    %edx,%ecx
  801666:	c1 e9 1b             	shr    $0x1b,%ecx
  801669:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80166c:	83 e2 1f             	and    $0x1f,%edx
  80166f:	29 ca                	sub    %ecx,%edx
  801671:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801675:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801679:	83 c0 01             	add    $0x1,%eax
  80167c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80167f:	83 c7 01             	add    $0x1,%edi
  801682:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801685:	75 c2                	jne    801649 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801687:	8b 45 10             	mov    0x10(%ebp),%eax
  80168a:	eb 05                	jmp    801691 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80168c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801691:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5f                   	pop    %edi
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	57                   	push   %edi
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
  80169f:	83 ec 18             	sub    $0x18,%esp
  8016a2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016a5:	57                   	push   %edi
  8016a6:	e8 8f f6 ff ff       	call   800d3a <fd2data>
  8016ab:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b5:	eb 3d                	jmp    8016f4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b7:	85 db                	test   %ebx,%ebx
  8016b9:	74 04                	je     8016bf <devpipe_read+0x26>
				return i;
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	eb 44                	jmp    801703 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016bf:	89 f2                	mov    %esi,%edx
  8016c1:	89 f8                	mov    %edi,%eax
  8016c3:	e8 e5 fe ff ff       	call   8015ad <_pipeisclosed>
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	75 32                	jne    8016fe <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016cc:	e8 29 f4 ff ff       	call   800afa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016d1:	8b 06                	mov    (%esi),%eax
  8016d3:	3b 46 04             	cmp    0x4(%esi),%eax
  8016d6:	74 df                	je     8016b7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d8:	99                   	cltd   
  8016d9:	c1 ea 1b             	shr    $0x1b,%edx
  8016dc:	01 d0                	add    %edx,%eax
  8016de:	83 e0 1f             	and    $0x1f,%eax
  8016e1:	29 d0                	sub    %edx,%eax
  8016e3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016eb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ee:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f1:	83 c3 01             	add    $0x1,%ebx
  8016f4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016f7:	75 d8                	jne    8016d1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016fc:	eb 05                	jmp    801703 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016fe:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5f                   	pop    %edi
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	e8 35 f6 ff ff       	call   800d51 <fd_alloc>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	89 c2                	mov    %eax,%edx
  801721:	85 c0                	test   %eax,%eax
  801723:	0f 88 2c 01 00 00    	js     801855 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	68 07 04 00 00       	push   $0x407
  801731:	ff 75 f4             	pushl  -0xc(%ebp)
  801734:	6a 00                	push   $0x0
  801736:	e8 de f3 ff ff       	call   800b19 <sys_page_alloc>
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	89 c2                	mov    %eax,%edx
  801740:	85 c0                	test   %eax,%eax
  801742:	0f 88 0d 01 00 00    	js     801855 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801748:	83 ec 0c             	sub    $0xc,%esp
  80174b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	e8 fd f5 ff ff       	call   800d51 <fd_alloc>
  801754:	89 c3                	mov    %eax,%ebx
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	85 c0                	test   %eax,%eax
  80175b:	0f 88 e2 00 00 00    	js     801843 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801761:	83 ec 04             	sub    $0x4,%esp
  801764:	68 07 04 00 00       	push   $0x407
  801769:	ff 75 f0             	pushl  -0x10(%ebp)
  80176c:	6a 00                	push   $0x0
  80176e:	e8 a6 f3 ff ff       	call   800b19 <sys_page_alloc>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	0f 88 c3 00 00 00    	js     801843 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801780:	83 ec 0c             	sub    $0xc,%esp
  801783:	ff 75 f4             	pushl  -0xc(%ebp)
  801786:	e8 af f5 ff ff       	call   800d3a <fd2data>
  80178b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178d:	83 c4 0c             	add    $0xc,%esp
  801790:	68 07 04 00 00       	push   $0x407
  801795:	50                   	push   %eax
  801796:	6a 00                	push   $0x0
  801798:	e8 7c f3 ff ff       	call   800b19 <sys_page_alloc>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	0f 88 89 00 00 00    	js     801833 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b0:	e8 85 f5 ff ff       	call   800d3a <fd2data>
  8017b5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017bc:	50                   	push   %eax
  8017bd:	6a 00                	push   $0x0
  8017bf:	56                   	push   %esi
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 95 f3 ff ff       	call   800b5c <sys_page_map>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	83 c4 20             	add    $0x20,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 55                	js     801825 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017d0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017de:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017e5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ee:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017fa:	83 ec 0c             	sub    $0xc,%esp
  8017fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801800:	e8 25 f5 ff ff       	call   800d2a <fd2num>
  801805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801808:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80180a:	83 c4 04             	add    $0x4,%esp
  80180d:	ff 75 f0             	pushl  -0x10(%ebp)
  801810:	e8 15 f5 ff ff       	call   800d2a <fd2num>
  801815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801818:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	eb 30                	jmp    801855 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801825:	83 ec 08             	sub    $0x8,%esp
  801828:	56                   	push   %esi
  801829:	6a 00                	push   $0x0
  80182b:	e8 6e f3 ff ff       	call   800b9e <sys_page_unmap>
  801830:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	ff 75 f0             	pushl  -0x10(%ebp)
  801839:	6a 00                	push   $0x0
  80183b:	e8 5e f3 ff ff       	call   800b9e <sys_page_unmap>
  801840:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	ff 75 f4             	pushl  -0xc(%ebp)
  801849:	6a 00                	push   $0x0
  80184b:	e8 4e f3 ff ff       	call   800b9e <sys_page_unmap>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801855:	89 d0                	mov    %edx,%eax
  801857:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801864:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	ff 75 08             	pushl  0x8(%ebp)
  80186b:	e8 30 f5 ff ff       	call   800da0 <fd_lookup>
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	78 18                	js     80188f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801877:	83 ec 0c             	sub    $0xc,%esp
  80187a:	ff 75 f4             	pushl  -0xc(%ebp)
  80187d:	e8 b8 f4 ff ff       	call   800d3a <fd2data>
	return _pipeisclosed(fd, p);
  801882:	89 c2                	mov    %eax,%edx
  801884:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801887:	e8 21 fd ff ff       	call   8015ad <_pipeisclosed>
  80188c:	83 c4 10             	add    $0x10,%esp
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801894:	b8 00 00 00 00       	mov    $0x0,%eax
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018a1:	68 6a 22 80 00       	push   $0x80226a
  8018a6:	ff 75 0c             	pushl  0xc(%ebp)
  8018a9:	e8 68 ee ff ff       	call   800716 <strcpy>
	return 0;
}
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	57                   	push   %edi
  8018b9:	56                   	push   %esi
  8018ba:	53                   	push   %ebx
  8018bb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018cc:	eb 2d                	jmp    8018fb <devcons_write+0x46>
		m = n - tot;
  8018ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018d1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018d3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018d6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018db:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018de:	83 ec 04             	sub    $0x4,%esp
  8018e1:	53                   	push   %ebx
  8018e2:	03 45 0c             	add    0xc(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	57                   	push   %edi
  8018e7:	e8 bc ef ff ff       	call   8008a8 <memmove>
		sys_cputs(buf, m);
  8018ec:	83 c4 08             	add    $0x8,%esp
  8018ef:	53                   	push   %ebx
  8018f0:	57                   	push   %edi
  8018f1:	e8 67 f1 ff ff       	call   800a5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f6:	01 de                	add    %ebx,%esi
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	89 f0                	mov    %esi,%eax
  8018fd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801900:	72 cc                	jb     8018ce <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801902:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801915:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801919:	74 2a                	je     801945 <devcons_read+0x3b>
  80191b:	eb 05                	jmp    801922 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80191d:	e8 d8 f1 ff ff       	call   800afa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801922:	e8 54 f1 ff ff       	call   800a7b <sys_cgetc>
  801927:	85 c0                	test   %eax,%eax
  801929:	74 f2                	je     80191d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 16                	js     801945 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80192f:	83 f8 04             	cmp    $0x4,%eax
  801932:	74 0c                	je     801940 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801934:	8b 55 0c             	mov    0xc(%ebp),%edx
  801937:	88 02                	mov    %al,(%edx)
	return 1;
  801939:	b8 01 00 00 00       	mov    $0x1,%eax
  80193e:	eb 05                	jmp    801945 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801953:	6a 01                	push   $0x1
  801955:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801958:	50                   	push   %eax
  801959:	e8 ff f0 ff ff       	call   800a5d <sys_cputs>
}
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <getchar>:

int
getchar(void)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801969:	6a 01                	push   $0x1
  80196b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80196e:	50                   	push   %eax
  80196f:	6a 00                	push   $0x0
  801971:	e8 90 f6 ff ff       	call   801006 <read>
	if (r < 0)
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 0f                	js     80198c <getchar+0x29>
		return r;
	if (r < 1)
  80197d:	85 c0                	test   %eax,%eax
  80197f:	7e 06                	jle    801987 <getchar+0x24>
		return -E_EOF;
	return c;
  801981:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801985:	eb 05                	jmp    80198c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801987:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	ff 75 08             	pushl  0x8(%ebp)
  80199b:	e8 00 f4 ff ff       	call   800da0 <fd_lookup>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 11                	js     8019b8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019aa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b0:	39 10                	cmp    %edx,(%eax)
  8019b2:	0f 94 c0             	sete   %al
  8019b5:	0f b6 c0             	movzbl %al,%eax
}
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <opencons>:

int
opencons(void)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c3:	50                   	push   %eax
  8019c4:	e8 88 f3 ff ff       	call   800d51 <fd_alloc>
  8019c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019cc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 3e                	js     801a10 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019d2:	83 ec 04             	sub    $0x4,%esp
  8019d5:	68 07 04 00 00       	push   $0x407
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	6a 00                	push   $0x0
  8019df:	e8 35 f1 ff ff       	call   800b19 <sys_page_alloc>
  8019e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 23                	js     801a10 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ed:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	50                   	push   %eax
  801a06:	e8 1f f3 ff ff       	call   800d2a <fd2num>
  801a0b:	89 c2                	mov    %eax,%edx
  801a0d:	83 c4 10             	add    $0x10,%esp
}
  801a10:	89 d0                	mov    %edx,%eax
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a19:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a1c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a22:	e8 b4 f0 ff ff       	call   800adb <sys_getenvid>
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	ff 75 08             	pushl  0x8(%ebp)
  801a30:	56                   	push   %esi
  801a31:	50                   	push   %eax
  801a32:	68 78 22 80 00       	push   $0x802278
  801a37:	e8 55 e7 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a3c:	83 c4 18             	add    $0x18,%esp
  801a3f:	53                   	push   %ebx
  801a40:	ff 75 10             	pushl  0x10(%ebp)
  801a43:	e8 f8 e6 ff ff       	call   800140 <vcprintf>
	cprintf("\n");
  801a48:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a4f:	e8 3d e7 ff ff       	call   800191 <cprintf>
  801a54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a57:	cc                   	int3   
  801a58:	eb fd                	jmp    801a57 <_panic+0x43>

00801a5a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	75 12                	jne    801a7e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	68 00 00 c0 ee       	push   $0xeec00000
  801a74:	e8 50 f2 ff ff       	call   800cc9 <sys_ipc_recv>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb 0c                	jmp    801a8a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	50                   	push   %eax
  801a82:	e8 42 f2 ff ff       	call   800cc9 <sys_ipc_recv>
  801a87:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a8a:	85 f6                	test   %esi,%esi
  801a8c:	0f 95 c1             	setne  %cl
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	0f 95 c2             	setne  %dl
  801a94:	84 d1                	test   %dl,%cl
  801a96:	74 09                	je     801aa1 <ipc_recv+0x47>
  801a98:	89 c2                	mov    %eax,%edx
  801a9a:	c1 ea 1f             	shr    $0x1f,%edx
  801a9d:	84 d2                	test   %dl,%dl
  801a9f:	75 27                	jne    801ac8 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801aa1:	85 f6                	test   %esi,%esi
  801aa3:	74 0a                	je     801aaf <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801aa5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaa:	8b 40 7c             	mov    0x7c(%eax),%eax
  801aad:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	74 0d                	je     801ac0 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801abe:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ac0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac5:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	57                   	push   %edi
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ade:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ae1:	85 db                	test   %ebx,%ebx
  801ae3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801aeb:	ff 75 14             	pushl  0x14(%ebp)
  801aee:	53                   	push   %ebx
  801aef:	56                   	push   %esi
  801af0:	57                   	push   %edi
  801af1:	e8 b0 f1 ff ff       	call   800ca6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	c1 ea 1f             	shr    $0x1f,%edx
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	84 d2                	test   %dl,%dl
  801b00:	74 17                	je     801b19 <ipc_send+0x4a>
  801b02:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b05:	74 12                	je     801b19 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b07:	50                   	push   %eax
  801b08:	68 9c 22 80 00       	push   $0x80229c
  801b0d:	6a 47                	push   $0x47
  801b0f:	68 aa 22 80 00       	push   $0x8022aa
  801b14:	e8 fb fe ff ff       	call   801a14 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b19:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1c:	75 07                	jne    801b25 <ipc_send+0x56>
			sys_yield();
  801b1e:	e8 d7 ef ff ff       	call   800afa <sys_yield>
  801b23:	eb c6                	jmp    801aeb <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b25:	85 c0                	test   %eax,%eax
  801b27:	75 c2                	jne    801aeb <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5f                   	pop    %edi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	c1 e2 07             	shl    $0x7,%edx
  801b41:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b48:	8b 52 58             	mov    0x58(%edx),%edx
  801b4b:	39 ca                	cmp    %ecx,%edx
  801b4d:	75 11                	jne    801b60 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b4f:	89 c2                	mov    %eax,%edx
  801b51:	c1 e2 07             	shl    $0x7,%edx
  801b54:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b5b:	8b 40 50             	mov    0x50(%eax),%eax
  801b5e:	eb 0f                	jmp    801b6f <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b60:	83 c0 01             	add    $0x1,%eax
  801b63:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b68:	75 d2                	jne    801b3c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b77:	89 d0                	mov    %edx,%eax
  801b79:	c1 e8 16             	shr    $0x16,%eax
  801b7c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b88:	f6 c1 01             	test   $0x1,%cl
  801b8b:	74 1d                	je     801baa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b8d:	c1 ea 0c             	shr    $0xc,%edx
  801b90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b97:	f6 c2 01             	test   $0x1,%dl
  801b9a:	74 0e                	je     801baa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b9c:	c1 ea 0c             	shr    $0xc,%edx
  801b9f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba6:	ef 
  801ba7:	0f b7 c0             	movzwl %ax,%eax
}
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    
  801bac:	66 90                	xchg   %ax,%ax
  801bae:	66 90                	xchg   %ax,%ax

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
