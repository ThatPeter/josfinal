
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 24 0a 00 00       	call   800a66 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	57                   	push   %edi
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800057:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80005a:	e8 85 0a 00 00       	call   800ae4 <sys_getenvid>
  80005f:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800061:	83 ec 08             	sub    $0x8,%esp
  800064:	50                   	push   %eax
  800065:	68 60 1e 80 00       	push   $0x801e60
  80006a:	e8 2b 01 00 00       	call   80019a <cprintf>
  80006f:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800075:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800082:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800087:	89 c1                	mov    %eax,%ecx
  800089:	c1 e1 07             	shl    $0x7,%ecx
  80008c:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800093:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800096:	39 cb                	cmp    %ecx,%ebx
  800098:	0f 44 fa             	cmove  %edx,%edi
  80009b:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a0:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a3:	83 c0 01             	add    $0x1,%eax
  8000a6:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000b1:	75 d4                	jne    800087 <libmain+0x40>
  8000b3:	89 f0                	mov    %esi,%eax
  8000b5:	84 c0                	test   %al,%al
  8000b7:	74 06                	je     8000bf <libmain+0x78>
  8000b9:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c3:	7e 0a                	jle    8000cf <libmain+0x88>
		binaryname = argv[0];
  8000c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c8:	8b 00                	mov    (%eax),%eax
  8000ca:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	ff 75 0c             	pushl  0xc(%ebp)
  8000d5:	ff 75 08             	pushl  0x8(%ebp)
  8000d8:	e8 56 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dd:	e8 0b 00 00 00       	call   8000ed <exit>
}
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f3:	e8 06 0e 00 00       	call   800efe <close_all>
	sys_env_destroy(0);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	6a 00                	push   $0x0
  8000fd:	e8 a1 09 00 00       	call   800aa3 <sys_env_destroy>
}
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	c9                   	leave  
  800106:	c3                   	ret    

00800107 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	53                   	push   %ebx
  80010b:	83 ec 04             	sub    $0x4,%esp
  80010e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800111:	8b 13                	mov    (%ebx),%edx
  800113:	8d 42 01             	lea    0x1(%edx),%eax
  800116:	89 03                	mov    %eax,(%ebx)
  800118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800124:	75 1a                	jne    800140 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	68 ff 00 00 00       	push   $0xff
  80012e:	8d 43 08             	lea    0x8(%ebx),%eax
  800131:	50                   	push   %eax
  800132:	e8 2f 09 00 00       	call   800a66 <sys_cputs>
		b->idx = 0;
  800137:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800140:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800144:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800152:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800159:	00 00 00 
	b.cnt = 0;
  80015c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800163:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800172:	50                   	push   %eax
  800173:	68 07 01 80 00       	push   $0x800107
  800178:	e8 54 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017d:	83 c4 08             	add    $0x8,%esp
  800180:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800186:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	e8 d4 08 00 00       	call   800a66 <sys_cputs>

	return b.cnt;
}
  800192:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800198:	c9                   	leave  
  800199:	c3                   	ret    

0080019a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a3:	50                   	push   %eax
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	e8 9d ff ff ff       	call   800149 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    

008001ae <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	57                   	push   %edi
  8001b2:	56                   	push   %esi
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 1c             	sub    $0x1c,%esp
  8001b7:	89 c7                	mov    %eax,%edi
  8001b9:	89 d6                	mov    %edx,%esi
  8001bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d5:	39 d3                	cmp    %edx,%ebx
  8001d7:	72 05                	jb     8001de <printnum+0x30>
  8001d9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001dc:	77 45                	ja     800223 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001de:	83 ec 0c             	sub    $0xc,%esp
  8001e1:	ff 75 18             	pushl  0x18(%ebp)
  8001e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ea:	53                   	push   %ebx
  8001eb:	ff 75 10             	pushl  0x10(%ebp)
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fd:	e8 be 19 00 00       	call   801bc0 <__udivdi3>
  800202:	83 c4 18             	add    $0x18,%esp
  800205:	52                   	push   %edx
  800206:	50                   	push   %eax
  800207:	89 f2                	mov    %esi,%edx
  800209:	89 f8                	mov    %edi,%eax
  80020b:	e8 9e ff ff ff       	call   8001ae <printnum>
  800210:	83 c4 20             	add    $0x20,%esp
  800213:	eb 18                	jmp    80022d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	56                   	push   %esi
  800219:	ff 75 18             	pushl  0x18(%ebp)
  80021c:	ff d7                	call   *%edi
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	eb 03                	jmp    800226 <printnum+0x78>
  800223:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800226:	83 eb 01             	sub    $0x1,%ebx
  800229:	85 db                	test   %ebx,%ebx
  80022b:	7f e8                	jg     800215 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	83 ec 04             	sub    $0x4,%esp
  800234:	ff 75 e4             	pushl  -0x1c(%ebp)
  800237:	ff 75 e0             	pushl  -0x20(%ebp)
  80023a:	ff 75 dc             	pushl  -0x24(%ebp)
  80023d:	ff 75 d8             	pushl  -0x28(%ebp)
  800240:	e8 ab 1a 00 00       	call   801cf0 <__umoddi3>
  800245:	83 c4 14             	add    $0x14,%esp
  800248:	0f be 80 89 1e 80 00 	movsbl 0x801e89(%eax),%eax
  80024f:	50                   	push   %eax
  800250:	ff d7                	call   *%edi
}
  800252:	83 c4 10             	add    $0x10,%esp
  800255:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800258:	5b                   	pop    %ebx
  800259:	5e                   	pop    %esi
  80025a:	5f                   	pop    %edi
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800260:	83 fa 01             	cmp    $0x1,%edx
  800263:	7e 0e                	jle    800273 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800265:	8b 10                	mov    (%eax),%edx
  800267:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	8b 52 04             	mov    0x4(%edx),%edx
  800271:	eb 22                	jmp    800295 <getuint+0x38>
	else if (lflag)
  800273:	85 d2                	test   %edx,%edx
  800275:	74 10                	je     800287 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	ba 00 00 00 00       	mov    $0x0,%edx
  800285:	eb 0e                	jmp    800295 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800287:	8b 10                	mov    (%eax),%edx
  800289:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 02                	mov    (%edx),%eax
  800290:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 0a                	jae    8002b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	88 02                	mov    %al,(%edx)
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
	va_end(ap);
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 2c             	sub    $0x2c,%esp
  8002da:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e3:	eb 12                	jmp    8002f7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	0f 84 89 03 00 00    	je     800676 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	53                   	push   %ebx
  8002f1:	50                   	push   %eax
  8002f2:	ff d6                	call   *%esi
  8002f4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f7:	83 c7 01             	add    $0x1,%edi
  8002fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fe:	83 f8 25             	cmp    $0x25,%eax
  800301:	75 e2                	jne    8002e5 <vprintfmt+0x14>
  800303:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800307:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800315:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
  800321:	eb 07                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800326:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 07             	movzbl (%edi),%eax
  800333:	0f b6 c8             	movzbl %al,%ecx
  800336:	83 e8 23             	sub    $0x23,%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 1a 03 00 00    	ja     80065b <vprintfmt+0x38a>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb d6                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
  80035c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800362:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800366:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800369:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80036c:	83 fa 09             	cmp    $0x9,%edx
  80036f:	77 39                	ja     8003aa <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800374:	eb e9                	jmp    80035f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 48 04             	lea    0x4(%eax),%ecx
  80037c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037f:	8b 00                	mov    (%eax),%eax
  800381:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800387:	eb 27                	jmp    8003b0 <vprintfmt+0xdf>
  800389:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038c:	85 c0                	test   %eax,%eax
  80038e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800393:	0f 49 c8             	cmovns %eax,%ecx
  800396:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039c:	eb 8c                	jmp    80032a <vprintfmt+0x59>
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a8:	eb 80                	jmp    80032a <vprintfmt+0x59>
  8003aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ad:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b4:	0f 89 70 ff ff ff    	jns    80032a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c7:	e9 5e ff ff ff       	jmp    80032a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d2:	e9 53 ff ff ff       	jmp    80032a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 50 04             	lea    0x4(%eax),%edx
  8003dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	53                   	push   %ebx
  8003e4:	ff 30                	pushl  (%eax)
  8003e6:	ff d6                	call   *%esi
			break;
  8003e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ee:	e9 04 ff ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 50 04             	lea    0x4(%eax),%edx
  8003f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	99                   	cltd   
  8003ff:	31 d0                	xor    %edx,%eax
  800401:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800403:	83 f8 0f             	cmp    $0xf,%eax
  800406:	7f 0b                	jg     800413 <vprintfmt+0x142>
  800408:	8b 14 85 20 21 80 00 	mov    0x802120(,%eax,4),%edx
  80040f:	85 d2                	test   %edx,%edx
  800411:	75 18                	jne    80042b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800413:	50                   	push   %eax
  800414:	68 a1 1e 80 00       	push   $0x801ea1
  800419:	53                   	push   %ebx
  80041a:	56                   	push   %esi
  80041b:	e8 94 fe ff ff       	call   8002b4 <printfmt>
  800420:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800426:	e9 cc fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80042b:	52                   	push   %edx
  80042c:	68 51 22 80 00       	push   $0x802251
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 7c fe ff ff       	call   8002b4 <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043e:	e9 b4 fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044e:	85 ff                	test   %edi,%edi
  800450:	b8 9a 1e 80 00       	mov    $0x801e9a,%eax
  800455:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800458:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045c:	0f 8e 94 00 00 00    	jle    8004f6 <vprintfmt+0x225>
  800462:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800466:	0f 84 98 00 00 00    	je     800504 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 d0             	pushl  -0x30(%ebp)
  800472:	57                   	push   %edi
  800473:	e8 86 02 00 00       	call   8006fe <strnlen>
  800478:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047b:	29 c1                	sub    %eax,%ecx
  80047d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800480:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800483:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800487:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	eb 0f                	jmp    8004a0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	53                   	push   %ebx
  800495:	ff 75 e0             	pushl  -0x20(%ebp)
  800498:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049a:	83 ef 01             	sub    $0x1,%edi
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	85 ff                	test   %edi,%edi
  8004a2:	7f ed                	jg     800491 <vprintfmt+0x1c0>
  8004a4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004aa:	85 c9                	test   %ecx,%ecx
  8004ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b1:	0f 49 c1             	cmovns %ecx,%eax
  8004b4:	29 c1                	sub    %eax,%ecx
  8004b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bf:	89 cb                	mov    %ecx,%ebx
  8004c1:	eb 4d                	jmp    800510 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c7:	74 1b                	je     8004e4 <vprintfmt+0x213>
  8004c9:	0f be c0             	movsbl %al,%eax
  8004cc:	83 e8 20             	sub    $0x20,%eax
  8004cf:	83 f8 5e             	cmp    $0x5e,%eax
  8004d2:	76 10                	jbe    8004e4 <vprintfmt+0x213>
					putch('?', putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	6a 3f                	push   $0x3f
  8004dc:	ff 55 08             	call   *0x8(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb 0d                	jmp    8004f1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ea:	52                   	push   %edx
  8004eb:	ff 55 08             	call   *0x8(%ebp)
  8004ee:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f1:	83 eb 01             	sub    $0x1,%ebx
  8004f4:	eb 1a                	jmp    800510 <vprintfmt+0x23f>
  8004f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800502:	eb 0c                	jmp    800510 <vprintfmt+0x23f>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	83 c7 01             	add    $0x1,%edi
  800513:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800517:	0f be d0             	movsbl %al,%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	74 23                	je     800541 <vprintfmt+0x270>
  80051e:	85 f6                	test   %esi,%esi
  800520:	78 a1                	js     8004c3 <vprintfmt+0x1f2>
  800522:	83 ee 01             	sub    $0x1,%esi
  800525:	79 9c                	jns    8004c3 <vprintfmt+0x1f2>
  800527:	89 df                	mov    %ebx,%edi
  800529:	8b 75 08             	mov    0x8(%ebp),%esi
  80052c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052f:	eb 18                	jmp    800549 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	6a 20                	push   $0x20
  800537:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800539:	83 ef 01             	sub    $0x1,%edi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb 08                	jmp    800549 <vprintfmt+0x278>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	85 ff                	test   %edi,%edi
  80054b:	7f e4                	jg     800531 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800550:	e9 a2 fd ff ff       	jmp    8002f7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800555:	83 fa 01             	cmp    $0x1,%edx
  800558:	7e 16                	jle    800570 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 08             	lea    0x8(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 50 04             	mov    0x4(%eax),%edx
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056e:	eb 32                	jmp    8005a2 <vprintfmt+0x2d1>
	else if (lflag)
  800570:	85 d2                	test   %edx,%edx
  800572:	74 18                	je     80058c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 c1                	mov    %eax,%ecx
  800584:	c1 f9 1f             	sar    $0x1f,%ecx
  800587:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058a:	eb 16                	jmp    8005a2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	89 c1                	mov    %eax,%ecx
  80059c:	c1 f9 1f             	sar    $0x1f,%ecx
  80059f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ad:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b1:	79 74                	jns    800627 <vprintfmt+0x356>
				putch('-', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	6a 2d                	push   $0x2d
  8005b9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005be:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c1:	f7 d8                	neg    %eax
  8005c3:	83 d2 00             	adc    $0x0,%edx
  8005c6:	f7 da                	neg    %edx
  8005c8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d0:	eb 55                	jmp    800627 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 83 fc ff ff       	call   80025d <getuint>
			base = 10;
  8005da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005df:	eb 46                	jmp    800627 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 74 fc ff ff       	call   80025d <getuint>
			base = 8;
  8005e9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ee:	eb 37                	jmp    800627 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 30                	push   $0x30
  8005f6:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 78                	push   $0x78
  8005fe:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800610:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800613:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800618:	eb 0d                	jmp    800627 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 3b fc ff ff       	call   80025d <getuint>
			base = 16;
  800622:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800627:	83 ec 0c             	sub    $0xc,%esp
  80062a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062e:	57                   	push   %edi
  80062f:	ff 75 e0             	pushl  -0x20(%ebp)
  800632:	51                   	push   %ecx
  800633:	52                   	push   %edx
  800634:	50                   	push   %eax
  800635:	89 da                	mov    %ebx,%edx
  800637:	89 f0                	mov    %esi,%eax
  800639:	e8 70 fb ff ff       	call   8001ae <printnum>
			break;
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	e9 ae fc ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	51                   	push   %ecx
  80064e:	ff d6                	call   *%esi
			break;
  800650:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800656:	e9 9c fc ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 25                	push   $0x25
  800661:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 03                	jmp    80066b <vprintfmt+0x39a>
  800668:	83 ef 01             	sub    $0x1,%edi
  80066b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066f:	75 f7                	jne    800668 <vprintfmt+0x397>
  800671:	e9 81 fc ff ff       	jmp    8002f7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 18             	sub    $0x18,%esp
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800691:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069b:	85 c0                	test   %eax,%eax
  80069d:	74 26                	je     8006c5 <vsnprintf+0x47>
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	7e 22                	jle    8006c5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a3:	ff 75 14             	pushl  0x14(%ebp)
  8006a6:	ff 75 10             	pushl  0x10(%ebp)
  8006a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ac:	50                   	push   %eax
  8006ad:	68 97 02 80 00       	push   $0x800297
  8006b2:	e8 1a fc ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 05                	jmp    8006ca <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d5:	50                   	push   %eax
  8006d6:	ff 75 10             	pushl  0x10(%ebp)
  8006d9:	ff 75 0c             	pushl  0xc(%ebp)
  8006dc:	ff 75 08             	pushl  0x8(%ebp)
  8006df:	e8 9a ff ff ff       	call   80067e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	eb 03                	jmp    8006f6 <strlen+0x10>
		n++;
  8006f3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fa:	75 f7                	jne    8006f3 <strlen+0xd>
		n++;
	return n;
}
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800704:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	ba 00 00 00 00       	mov    $0x0,%edx
  80070c:	eb 03                	jmp    800711 <strnlen+0x13>
		n++;
  80070e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800711:	39 c2                	cmp    %eax,%edx
  800713:	74 08                	je     80071d <strnlen+0x1f>
  800715:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800719:	75 f3                	jne    80070e <strnlen+0x10>
  80071b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800729:	89 c2                	mov    %eax,%edx
  80072b:	83 c2 01             	add    $0x1,%edx
  80072e:	83 c1 01             	add    $0x1,%ecx
  800731:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800735:	88 5a ff             	mov    %bl,-0x1(%edx)
  800738:	84 db                	test   %bl,%bl
  80073a:	75 ef                	jne    80072b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073c:	5b                   	pop    %ebx
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800746:	53                   	push   %ebx
  800747:	e8 9a ff ff ff       	call   8006e6 <strlen>
  80074c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074f:	ff 75 0c             	pushl  0xc(%ebp)
  800752:	01 d8                	add    %ebx,%eax
  800754:	50                   	push   %eax
  800755:	e8 c5 ff ff ff       	call   80071f <strcpy>
	return dst;
}
  80075a:	89 d8                	mov    %ebx,%eax
  80075c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	56                   	push   %esi
  800765:	53                   	push   %ebx
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076c:	89 f3                	mov    %esi,%ebx
  80076e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800771:	89 f2                	mov    %esi,%edx
  800773:	eb 0f                	jmp    800784 <strncpy+0x23>
		*dst++ = *src;
  800775:	83 c2 01             	add    $0x1,%edx
  800778:	0f b6 01             	movzbl (%ecx),%eax
  80077b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077e:	80 39 01             	cmpb   $0x1,(%ecx)
  800781:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800784:	39 da                	cmp    %ebx,%edx
  800786:	75 ed                	jne    800775 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800788:	89 f0                	mov    %esi,%eax
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	56                   	push   %esi
  800792:	53                   	push   %ebx
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800799:	8b 55 10             	mov    0x10(%ebp),%edx
  80079c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 21                	je     8007c3 <strlcpy+0x35>
  8007a2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a6:	89 f2                	mov    %esi,%edx
  8007a8:	eb 09                	jmp    8007b3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b3:	39 c2                	cmp    %eax,%edx
  8007b5:	74 09                	je     8007c0 <strlcpy+0x32>
  8007b7:	0f b6 19             	movzbl (%ecx),%ebx
  8007ba:	84 db                	test   %bl,%bl
  8007bc:	75 ec                	jne    8007aa <strlcpy+0x1c>
  8007be:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c3:	29 f0                	sub    %esi,%eax
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d2:	eb 06                	jmp    8007da <strcmp+0x11>
		p++, q++;
  8007d4:	83 c1 01             	add    $0x1,%ecx
  8007d7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007da:	0f b6 01             	movzbl (%ecx),%eax
  8007dd:	84 c0                	test   %al,%al
  8007df:	74 04                	je     8007e5 <strcmp+0x1c>
  8007e1:	3a 02                	cmp    (%edx),%al
  8007e3:	74 ef                	je     8007d4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e5:	0f b6 c0             	movzbl %al,%eax
  8007e8:	0f b6 12             	movzbl (%edx),%edx
  8007eb:	29 d0                	sub    %edx,%eax
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 c3                	mov    %eax,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fe:	eb 06                	jmp    800806 <strncmp+0x17>
		n--, p++, q++;
  800800:	83 c0 01             	add    $0x1,%eax
  800803:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800806:	39 d8                	cmp    %ebx,%eax
  800808:	74 15                	je     80081f <strncmp+0x30>
  80080a:	0f b6 08             	movzbl (%eax),%ecx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	74 04                	je     800815 <strncmp+0x26>
  800811:	3a 0a                	cmp    (%edx),%cl
  800813:	74 eb                	je     800800 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800815:	0f b6 00             	movzbl (%eax),%eax
  800818:	0f b6 12             	movzbl (%edx),%edx
  80081b:	29 d0                	sub    %edx,%eax
  80081d:	eb 05                	jmp    800824 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800831:	eb 07                	jmp    80083a <strchr+0x13>
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 0f                	je     800846 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 10             	movzbl (%eax),%edx
  80083d:	84 d2                	test   %dl,%dl
  80083f:	75 f2                	jne    800833 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800852:	eb 03                	jmp    800857 <strfind+0xf>
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085a:	38 ca                	cmp    %cl,%dl
  80085c:	74 04                	je     800862 <strfind+0x1a>
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f2                	jne    800854 <strfind+0xc>
			break;
	return (char *) s;
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	53                   	push   %ebx
  80086a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800870:	85 c9                	test   %ecx,%ecx
  800872:	74 36                	je     8008aa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800874:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087a:	75 28                	jne    8008a4 <memset+0x40>
  80087c:	f6 c1 03             	test   $0x3,%cl
  80087f:	75 23                	jne    8008a4 <memset+0x40>
		c &= 0xFF;
  800881:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800885:	89 d3                	mov    %edx,%ebx
  800887:	c1 e3 08             	shl    $0x8,%ebx
  80088a:	89 d6                	mov    %edx,%esi
  80088c:	c1 e6 18             	shl    $0x18,%esi
  80088f:	89 d0                	mov    %edx,%eax
  800891:	c1 e0 10             	shl    $0x10,%eax
  800894:	09 f0                	or     %esi,%eax
  800896:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800898:	89 d8                	mov    %ebx,%eax
  80089a:	09 d0                	or     %edx,%eax
  80089c:	c1 e9 02             	shr    $0x2,%ecx
  80089f:	fc                   	cld    
  8008a0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a2:	eb 06                	jmp    8008aa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a7:	fc                   	cld    
  8008a8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008aa:	89 f8                	mov    %edi,%eax
  8008ac:	5b                   	pop    %ebx
  8008ad:	5e                   	pop    %esi
  8008ae:	5f                   	pop    %edi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bf:	39 c6                	cmp    %eax,%esi
  8008c1:	73 35                	jae    8008f8 <memmove+0x47>
  8008c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c6:	39 d0                	cmp    %edx,%eax
  8008c8:	73 2e                	jae    8008f8 <memmove+0x47>
		s += n;
		d += n;
  8008ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cd:	89 d6                	mov    %edx,%esi
  8008cf:	09 fe                	or     %edi,%esi
  8008d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d7:	75 13                	jne    8008ec <memmove+0x3b>
  8008d9:	f6 c1 03             	test   $0x3,%cl
  8008dc:	75 0e                	jne    8008ec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008de:	83 ef 04             	sub    $0x4,%edi
  8008e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e4:	c1 e9 02             	shr    $0x2,%ecx
  8008e7:	fd                   	std    
  8008e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ea:	eb 09                	jmp    8008f5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ec:	83 ef 01             	sub    $0x1,%edi
  8008ef:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f2:	fd                   	std    
  8008f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f5:	fc                   	cld    
  8008f6:	eb 1d                	jmp    800915 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	89 f2                	mov    %esi,%edx
  8008fa:	09 c2                	or     %eax,%edx
  8008fc:	f6 c2 03             	test   $0x3,%dl
  8008ff:	75 0f                	jne    800910 <memmove+0x5f>
  800901:	f6 c1 03             	test   $0x3,%cl
  800904:	75 0a                	jne    800910 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800906:	c1 e9 02             	shr    $0x2,%ecx
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 05                	jmp    800915 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800910:	89 c7                	mov    %eax,%edi
  800912:	fc                   	cld    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091c:	ff 75 10             	pushl  0x10(%ebp)
  80091f:	ff 75 0c             	pushl  0xc(%ebp)
  800922:	ff 75 08             	pushl  0x8(%ebp)
  800925:	e8 87 ff ff ff       	call   8008b1 <memmove>
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	89 c6                	mov    %eax,%esi
  800939:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093c:	eb 1a                	jmp    800958 <memcmp+0x2c>
		if (*s1 != *s2)
  80093e:	0f b6 08             	movzbl (%eax),%ecx
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	38 d9                	cmp    %bl,%cl
  800946:	74 0a                	je     800952 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800948:	0f b6 c1             	movzbl %cl,%eax
  80094b:	0f b6 db             	movzbl %bl,%ebx
  80094e:	29 d8                	sub    %ebx,%eax
  800950:	eb 0f                	jmp    800961 <memcmp+0x35>
		s1++, s2++;
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800958:	39 f0                	cmp    %esi,%eax
  80095a:	75 e2                	jne    80093e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096c:	89 c1                	mov    %eax,%ecx
  80096e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	eb 0a                	jmp    800981 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800977:	0f b6 10             	movzbl (%eax),%edx
  80097a:	39 da                	cmp    %ebx,%edx
  80097c:	74 07                	je     800985 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	39 c8                	cmp    %ecx,%eax
  800983:	72 f2                	jb     800977 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800985:	5b                   	pop    %ebx
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800994:	eb 03                	jmp    800999 <strtol+0x11>
		s++;
  800996:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	3c 20                	cmp    $0x20,%al
  80099e:	74 f6                	je     800996 <strtol+0xe>
  8009a0:	3c 09                	cmp    $0x9,%al
  8009a2:	74 f2                	je     800996 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a4:	3c 2b                	cmp    $0x2b,%al
  8009a6:	75 0a                	jne    8009b2 <strtol+0x2a>
		s++;
  8009a8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b0:	eb 11                	jmp    8009c3 <strtol+0x3b>
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b7:	3c 2d                	cmp    $0x2d,%al
  8009b9:	75 08                	jne    8009c3 <strtol+0x3b>
		s++, neg = 1;
  8009bb:	83 c1 01             	add    $0x1,%ecx
  8009be:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c9:	75 15                	jne    8009e0 <strtol+0x58>
  8009cb:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ce:	75 10                	jne    8009e0 <strtol+0x58>
  8009d0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d4:	75 7c                	jne    800a52 <strtol+0xca>
		s += 2, base = 16;
  8009d6:	83 c1 02             	add    $0x2,%ecx
  8009d9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009de:	eb 16                	jmp    8009f6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e0:	85 db                	test   %ebx,%ebx
  8009e2:	75 12                	jne    8009f6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ec:	75 08                	jne    8009f6 <strtol+0x6e>
		s++, base = 8;
  8009ee:	83 c1 01             	add    $0x1,%ecx
  8009f1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fe:	0f b6 11             	movzbl (%ecx),%edx
  800a01:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	80 fb 09             	cmp    $0x9,%bl
  800a09:	77 08                	ja     800a13 <strtol+0x8b>
			dig = *s - '0';
  800a0b:	0f be d2             	movsbl %dl,%edx
  800a0e:	83 ea 30             	sub    $0x30,%edx
  800a11:	eb 22                	jmp    800a35 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a13:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	80 fb 19             	cmp    $0x19,%bl
  800a1b:	77 08                	ja     800a25 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1d:	0f be d2             	movsbl %dl,%edx
  800a20:	83 ea 57             	sub    $0x57,%edx
  800a23:	eb 10                	jmp    800a35 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a25:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	80 fb 19             	cmp    $0x19,%bl
  800a2d:	77 16                	ja     800a45 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2f:	0f be d2             	movsbl %dl,%edx
  800a32:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a35:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a38:	7d 0b                	jge    800a45 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a41:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a43:	eb b9                	jmp    8009fe <strtol+0x76>

	if (endptr)
  800a45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a49:	74 0d                	je     800a58 <strtol+0xd0>
		*endptr = (char *) s;
  800a4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4e:	89 0e                	mov    %ecx,(%esi)
  800a50:	eb 06                	jmp    800a58 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	74 98                	je     8009ee <strtol+0x66>
  800a56:	eb 9e                	jmp    8009f6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a58:	89 c2                	mov    %eax,%edx
  800a5a:	f7 da                	neg    %edx
  800a5c:	85 ff                	test   %edi,%edi
  800a5e:	0f 45 c2             	cmovne %edx,%eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	89 c7                	mov    %eax,%edi
  800a7b:	89 c6                	mov    %eax,%esi
  800a7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800a94:	89 d1                	mov    %edx,%ecx
  800a96:	89 d3                	mov    %edx,%ebx
  800a98:	89 d7                	mov    %edx,%edi
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 cb                	mov    %ecx,%ebx
  800abb:	89 cf                	mov    %ecx,%edi
  800abd:	89 ce                	mov    %ecx,%esi
  800abf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	7e 17                	jle    800adc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac5:	83 ec 0c             	sub    $0xc,%esp
  800ac8:	50                   	push   %eax
  800ac9:	6a 03                	push   $0x3
  800acb:	68 7f 21 80 00       	push   $0x80217f
  800ad0:	6a 23                	push   $0x23
  800ad2:	68 9c 21 80 00       	push   $0x80219c
  800ad7:	e8 41 0f 00 00       	call   801a1d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 02 00 00 00       	mov    $0x2,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_yield>:

void
sys_yield(void)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b13:	89 d1                	mov    %edx,%ecx
  800b15:	89 d3                	mov    %edx,%ebx
  800b17:	89 d7                	mov    %edx,%edi
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	be 00 00 00 00       	mov    $0x0,%esi
  800b30:	b8 04 00 00 00       	mov    $0x4,%eax
  800b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3e:	89 f7                	mov    %esi,%edi
  800b40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b42:	85 c0                	test   %eax,%eax
  800b44:	7e 17                	jle    800b5d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	50                   	push   %eax
  800b4a:	6a 04                	push   $0x4
  800b4c:	68 7f 21 80 00       	push   $0x80217f
  800b51:	6a 23                	push   $0x23
  800b53:	68 9c 21 80 00       	push   $0x80219c
  800b58:	e8 c0 0e 00 00       	call   801a1d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 17                	jle    800b9f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 05                	push   $0x5
  800b8e:	68 7f 21 80 00       	push   $0x80217f
  800b93:	6a 23                	push   $0x23
  800b95:	68 9c 21 80 00       	push   $0x80219c
  800b9a:	e8 7e 0e 00 00       	call   801a1d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc0:	89 df                	mov    %ebx,%edi
  800bc2:	89 de                	mov    %ebx,%esi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 06                	push   $0x6
  800bd0:	68 7f 21 80 00       	push   $0x80217f
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 9c 21 80 00       	push   $0x80219c
  800bdc:	e8 3c 0e 00 00       	call   801a1d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	89 df                	mov    %ebx,%edi
  800c04:	89 de                	mov    %ebx,%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 08                	push   $0x8
  800c12:	68 7f 21 80 00       	push   $0x80217f
  800c17:	6a 23                	push   $0x23
  800c19:	68 9c 21 80 00       	push   $0x80219c
  800c1e:	e8 fa 0d 00 00       	call   801a1d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 09                	push   $0x9
  800c54:	68 7f 21 80 00       	push   $0x80217f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 9c 21 80 00       	push   $0x80219c
  800c60:	e8 b8 0d 00 00       	call   801a1d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 0a                	push   $0xa
  800c96:	68 7f 21 80 00       	push   $0x80217f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 9c 21 80 00       	push   $0x80219c
  800ca2:	e8 76 0d 00 00       	call   801a1d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	be 00 00 00 00       	mov    $0x0,%esi
  800cba:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 cb                	mov    %ecx,%ebx
  800cea:	89 cf                	mov    %ecx,%edi
  800cec:	89 ce                	mov    %ecx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 0d                	push   $0xd
  800cfa:	68 7f 21 80 00       	push   $0x80217f
  800cff:	6a 23                	push   $0x23
  800d01:	68 9c 21 80 00       	push   $0x80219c
  800d06:	e8 12 0d 00 00       	call   801a1d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 cb                	mov    %ecx,%ebx
  800d28:	89 cf                	mov    %ecx,%edi
  800d2a:	89 ce                	mov    %ecx,%esi
  800d2c:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	05 00 00 00 30       	add    $0x30000000,%eax
  800d3e:	c1 e8 0c             	shr    $0xc,%eax
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	05 00 00 00 30       	add    $0x30000000,%eax
  800d4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d53:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d60:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d65:	89 c2                	mov    %eax,%edx
  800d67:	c1 ea 16             	shr    $0x16,%edx
  800d6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d71:	f6 c2 01             	test   $0x1,%dl
  800d74:	74 11                	je     800d87 <fd_alloc+0x2d>
  800d76:	89 c2                	mov    %eax,%edx
  800d78:	c1 ea 0c             	shr    $0xc,%edx
  800d7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d82:	f6 c2 01             	test   $0x1,%dl
  800d85:	75 09                	jne    800d90 <fd_alloc+0x36>
			*fd_store = fd;
  800d87:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8e:	eb 17                	jmp    800da7 <fd_alloc+0x4d>
  800d90:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d95:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d9a:	75 c9                	jne    800d65 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d9c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800da2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800daf:	83 f8 1f             	cmp    $0x1f,%eax
  800db2:	77 36                	ja     800dea <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800db4:	c1 e0 0c             	shl    $0xc,%eax
  800db7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dbc:	89 c2                	mov    %eax,%edx
  800dbe:	c1 ea 16             	shr    $0x16,%edx
  800dc1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc8:	f6 c2 01             	test   $0x1,%dl
  800dcb:	74 24                	je     800df1 <fd_lookup+0x48>
  800dcd:	89 c2                	mov    %eax,%edx
  800dcf:	c1 ea 0c             	shr    $0xc,%edx
  800dd2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd9:	f6 c2 01             	test   $0x1,%dl
  800ddc:	74 1a                	je     800df8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de1:	89 02                	mov    %eax,(%edx)
	return 0;
  800de3:	b8 00 00 00 00       	mov    $0x0,%eax
  800de8:	eb 13                	jmp    800dfd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800def:	eb 0c                	jmp    800dfd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df6:	eb 05                	jmp    800dfd <fd_lookup+0x54>
  800df8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 08             	sub    $0x8,%esp
  800e05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e08:	ba 28 22 80 00       	mov    $0x802228,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e0d:	eb 13                	jmp    800e22 <dev_lookup+0x23>
  800e0f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e12:	39 08                	cmp    %ecx,(%eax)
  800e14:	75 0c                	jne    800e22 <dev_lookup+0x23>
			*dev = devtab[i];
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	eb 2e                	jmp    800e50 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e22:	8b 02                	mov    (%edx),%eax
  800e24:	85 c0                	test   %eax,%eax
  800e26:	75 e7                	jne    800e0f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e28:	a1 04 40 80 00       	mov    0x804004,%eax
  800e2d:	8b 40 50             	mov    0x50(%eax),%eax
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	51                   	push   %ecx
  800e34:	50                   	push   %eax
  800e35:	68 ac 21 80 00       	push   $0x8021ac
  800e3a:	e8 5b f3 ff ff       	call   80019a <cprintf>
	*dev = 0;
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 10             	sub    $0x10,%esp
  800e5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e63:	50                   	push   %eax
  800e64:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e6a:	c1 e8 0c             	shr    $0xc,%eax
  800e6d:	50                   	push   %eax
  800e6e:	e8 36 ff ff ff       	call   800da9 <fd_lookup>
  800e73:	83 c4 08             	add    $0x8,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	78 05                	js     800e7f <fd_close+0x2d>
	    || fd != fd2)
  800e7a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e7d:	74 0c                	je     800e8b <fd_close+0x39>
		return (must_exist ? r : 0);
  800e7f:	84 db                	test   %bl,%bl
  800e81:	ba 00 00 00 00       	mov    $0x0,%edx
  800e86:	0f 44 c2             	cmove  %edx,%eax
  800e89:	eb 41                	jmp    800ecc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 36                	pushl  (%esi)
  800e94:	e8 66 ff ff ff       	call   800dff <dev_lookup>
  800e99:	89 c3                	mov    %eax,%ebx
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	78 1a                	js     800ebc <fd_close+0x6a>
		if (dev->dev_close)
  800ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	74 0b                	je     800ebc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	56                   	push   %esi
  800eb5:	ff d0                	call   *%eax
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	56                   	push   %esi
  800ec0:	6a 00                	push   $0x0
  800ec2:	e8 e0 fc ff ff       	call   800ba7 <sys_page_unmap>
	return r;
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	89 d8                	mov    %ebx,%eax
}
  800ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	ff 75 08             	pushl  0x8(%ebp)
  800ee0:	e8 c4 fe ff ff       	call   800da9 <fd_lookup>
  800ee5:	83 c4 08             	add    $0x8,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 10                	js     800efc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800eec:	83 ec 08             	sub    $0x8,%esp
  800eef:	6a 01                	push   $0x1
  800ef1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef4:	e8 59 ff ff ff       	call   800e52 <fd_close>
  800ef9:	83 c4 10             	add    $0x10,%esp
}
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <close_all>:

void
close_all(void)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	53                   	push   %ebx
  800f02:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f05:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	53                   	push   %ebx
  800f0e:	e8 c0 ff ff ff       	call   800ed3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f13:	83 c3 01             	add    $0x1,%ebx
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	83 fb 20             	cmp    $0x20,%ebx
  800f1c:	75 ec                	jne    800f0a <close_all+0xc>
		close(i);
}
  800f1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 2c             	sub    $0x2c,%esp
  800f2c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f32:	50                   	push   %eax
  800f33:	ff 75 08             	pushl  0x8(%ebp)
  800f36:	e8 6e fe ff ff       	call   800da9 <fd_lookup>
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	0f 88 c1 00 00 00    	js     801007 <dup+0xe4>
		return r;
	close(newfdnum);
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	56                   	push   %esi
  800f4a:	e8 84 ff ff ff       	call   800ed3 <close>

	newfd = INDEX2FD(newfdnum);
  800f4f:	89 f3                	mov    %esi,%ebx
  800f51:	c1 e3 0c             	shl    $0xc,%ebx
  800f54:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f5a:	83 c4 04             	add    $0x4,%esp
  800f5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f60:	e8 de fd ff ff       	call   800d43 <fd2data>
  800f65:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f67:	89 1c 24             	mov    %ebx,(%esp)
  800f6a:	e8 d4 fd ff ff       	call   800d43 <fd2data>
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f75:	89 f8                	mov    %edi,%eax
  800f77:	c1 e8 16             	shr    $0x16,%eax
  800f7a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f81:	a8 01                	test   $0x1,%al
  800f83:	74 37                	je     800fbc <dup+0x99>
  800f85:	89 f8                	mov    %edi,%eax
  800f87:	c1 e8 0c             	shr    $0xc,%eax
  800f8a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f91:	f6 c2 01             	test   $0x1,%dl
  800f94:	74 26                	je     800fbc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa5:	50                   	push   %eax
  800fa6:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa9:	6a 00                	push   $0x0
  800fab:	57                   	push   %edi
  800fac:	6a 00                	push   $0x0
  800fae:	e8 b2 fb ff ff       	call   800b65 <sys_page_map>
  800fb3:	89 c7                	mov    %eax,%edi
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 2e                	js     800fea <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fbf:	89 d0                	mov    %edx,%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
  800fc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd3:	50                   	push   %eax
  800fd4:	53                   	push   %ebx
  800fd5:	6a 00                	push   $0x0
  800fd7:	52                   	push   %edx
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 86 fb ff ff       	call   800b65 <sys_page_map>
  800fdf:	89 c7                	mov    %eax,%edi
  800fe1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fe4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe6:	85 ff                	test   %edi,%edi
  800fe8:	79 1d                	jns    801007 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	53                   	push   %ebx
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 b2 fb ff ff       	call   800ba7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ff5:	83 c4 08             	add    $0x8,%esp
  800ff8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 a5 fb ff ff       	call   800ba7 <sys_page_unmap>
	return r;
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	89 f8                	mov    %edi,%eax
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	53                   	push   %ebx
  801013:	83 ec 14             	sub    $0x14,%esp
  801016:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801019:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101c:	50                   	push   %eax
  80101d:	53                   	push   %ebx
  80101e:	e8 86 fd ff ff       	call   800da9 <fd_lookup>
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	89 c2                	mov    %eax,%edx
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 6d                	js     801099 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801036:	ff 30                	pushl  (%eax)
  801038:	e8 c2 fd ff ff       	call   800dff <dev_lookup>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 4c                	js     801090 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801044:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801047:	8b 42 08             	mov    0x8(%edx),%eax
  80104a:	83 e0 03             	and    $0x3,%eax
  80104d:	83 f8 01             	cmp    $0x1,%eax
  801050:	75 21                	jne    801073 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801052:	a1 04 40 80 00       	mov    0x804004,%eax
  801057:	8b 40 50             	mov    0x50(%eax),%eax
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	53                   	push   %ebx
  80105e:	50                   	push   %eax
  80105f:	68 ed 21 80 00       	push   $0x8021ed
  801064:	e8 31 f1 ff ff       	call   80019a <cprintf>
		return -E_INVAL;
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801071:	eb 26                	jmp    801099 <read+0x8a>
	}
	if (!dev->dev_read)
  801073:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801076:	8b 40 08             	mov    0x8(%eax),%eax
  801079:	85 c0                	test   %eax,%eax
  80107b:	74 17                	je     801094 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80107d:	83 ec 04             	sub    $0x4,%esp
  801080:	ff 75 10             	pushl  0x10(%ebp)
  801083:	ff 75 0c             	pushl  0xc(%ebp)
  801086:	52                   	push   %edx
  801087:	ff d0                	call   *%eax
  801089:	89 c2                	mov    %eax,%edx
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	eb 09                	jmp    801099 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801090:	89 c2                	mov    %eax,%edx
  801092:	eb 05                	jmp    801099 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801094:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801099:	89 d0                	mov    %edx,%eax
  80109b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b4:	eb 21                	jmp    8010d7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	89 f0                	mov    %esi,%eax
  8010bb:	29 d8                	sub    %ebx,%eax
  8010bd:	50                   	push   %eax
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	03 45 0c             	add    0xc(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	57                   	push   %edi
  8010c5:	e8 45 ff ff ff       	call   80100f <read>
		if (m < 0)
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 10                	js     8010e1 <readn+0x41>
			return m;
		if (m == 0)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	74 0a                	je     8010df <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d5:	01 c3                	add    %eax,%ebx
  8010d7:	39 f3                	cmp    %esi,%ebx
  8010d9:	72 db                	jb     8010b6 <readn+0x16>
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	eb 02                	jmp    8010e1 <readn+0x41>
  8010df:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 14             	sub    $0x14,%esp
  8010f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	e8 ac fc ff ff       	call   800da9 <fd_lookup>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	89 c2                	mov    %eax,%edx
  801102:	85 c0                	test   %eax,%eax
  801104:	78 68                	js     80116e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801110:	ff 30                	pushl  (%eax)
  801112:	e8 e8 fc ff ff       	call   800dff <dev_lookup>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 47                	js     801165 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80111e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801121:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801125:	75 21                	jne    801148 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801127:	a1 04 40 80 00       	mov    0x804004,%eax
  80112c:	8b 40 50             	mov    0x50(%eax),%eax
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	53                   	push   %ebx
  801133:	50                   	push   %eax
  801134:	68 09 22 80 00       	push   $0x802209
  801139:	e8 5c f0 ff ff       	call   80019a <cprintf>
		return -E_INVAL;
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801146:	eb 26                	jmp    80116e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801148:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80114b:	8b 52 0c             	mov    0xc(%edx),%edx
  80114e:	85 d2                	test   %edx,%edx
  801150:	74 17                	je     801169 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801152:	83 ec 04             	sub    $0x4,%esp
  801155:	ff 75 10             	pushl  0x10(%ebp)
  801158:	ff 75 0c             	pushl  0xc(%ebp)
  80115b:	50                   	push   %eax
  80115c:	ff d2                	call   *%edx
  80115e:	89 c2                	mov    %eax,%edx
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	eb 09                	jmp    80116e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801165:	89 c2                	mov    %eax,%edx
  801167:	eb 05                	jmp    80116e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801169:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80116e:	89 d0                	mov    %edx,%eax
  801170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <seek>:

int
seek(int fdnum, off_t offset)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	ff 75 08             	pushl  0x8(%ebp)
  801182:	e8 22 fc ff ff       	call   800da9 <fd_lookup>
  801187:	83 c4 08             	add    $0x8,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 0e                	js     80119c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80118e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801191:	8b 55 0c             	mov    0xc(%ebp),%edx
  801194:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 14             	sub    $0x14,%esp
  8011a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	53                   	push   %ebx
  8011ad:	e8 f7 fb ff ff       	call   800da9 <fd_lookup>
  8011b2:	83 c4 08             	add    $0x8,%esp
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 65                	js     801220 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	ff 30                	pushl  (%eax)
  8011c7:	e8 33 fc ff ff       	call   800dff <dev_lookup>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 44                	js     801217 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011da:	75 21                	jne    8011fd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011dc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e1:	8b 40 50             	mov    0x50(%eax),%eax
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	53                   	push   %ebx
  8011e8:	50                   	push   %eax
  8011e9:	68 cc 21 80 00       	push   $0x8021cc
  8011ee:	e8 a7 ef ff ff       	call   80019a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011fb:	eb 23                	jmp    801220 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801200:	8b 52 18             	mov    0x18(%edx),%edx
  801203:	85 d2                	test   %edx,%edx
  801205:	74 14                	je     80121b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	ff 75 0c             	pushl  0xc(%ebp)
  80120d:	50                   	push   %eax
  80120e:	ff d2                	call   *%edx
  801210:	89 c2                	mov    %eax,%edx
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	eb 09                	jmp    801220 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801217:	89 c2                	mov    %eax,%edx
  801219:	eb 05                	jmp    801220 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80121b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801220:	89 d0                	mov    %edx,%eax
  801222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	53                   	push   %ebx
  80122b:	83 ec 14             	sub    $0x14,%esp
  80122e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801231:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	ff 75 08             	pushl  0x8(%ebp)
  801238:	e8 6c fb ff ff       	call   800da9 <fd_lookup>
  80123d:	83 c4 08             	add    $0x8,%esp
  801240:	89 c2                	mov    %eax,%edx
  801242:	85 c0                	test   %eax,%eax
  801244:	78 58                	js     80129e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	ff 30                	pushl  (%eax)
  801252:	e8 a8 fb ff ff       	call   800dff <dev_lookup>
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 37                	js     801295 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80125e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801261:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801265:	74 32                	je     801299 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801267:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80126a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801271:	00 00 00 
	stat->st_isdir = 0;
  801274:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80127b:	00 00 00 
	stat->st_dev = dev;
  80127e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	53                   	push   %ebx
  801288:	ff 75 f0             	pushl  -0x10(%ebp)
  80128b:	ff 50 14             	call   *0x14(%eax)
  80128e:	89 c2                	mov    %eax,%edx
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	eb 09                	jmp    80129e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801295:	89 c2                	mov    %eax,%edx
  801297:	eb 05                	jmp    80129e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801299:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80129e:	89 d0                	mov    %edx,%eax
  8012a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	56                   	push   %esi
  8012a9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	6a 00                	push   $0x0
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 e3 01 00 00       	call   80149a <open>
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 1b                	js     8012db <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	ff 75 0c             	pushl  0xc(%ebp)
  8012c6:	50                   	push   %eax
  8012c7:	e8 5b ff ff ff       	call   801227 <fstat>
  8012cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ce:	89 1c 24             	mov    %ebx,(%esp)
  8012d1:	e8 fd fb ff ff       	call   800ed3 <close>
	return r;
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	89 f0                	mov    %esi,%eax
}
  8012db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	89 c6                	mov    %eax,%esi
  8012e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012f2:	75 12                	jne    801306 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012f4:	83 ec 0c             	sub    $0xc,%esp
  8012f7:	6a 01                	push   $0x1
  8012f9:	e8 3c 08 00 00       	call   801b3a <ipc_find_env>
  8012fe:	a3 00 40 80 00       	mov    %eax,0x804000
  801303:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801306:	6a 07                	push   $0x7
  801308:	68 00 50 80 00       	push   $0x805000
  80130d:	56                   	push   %esi
  80130e:	ff 35 00 40 80 00    	pushl  0x804000
  801314:	e8 bf 07 00 00       	call   801ad8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801319:	83 c4 0c             	add    $0xc,%esp
  80131c:	6a 00                	push   $0x0
  80131e:	53                   	push   %ebx
  80131f:	6a 00                	push   $0x0
  801321:	e8 3d 07 00 00       	call   801a63 <ipc_recv>
}
  801326:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	8b 40 0c             	mov    0xc(%eax),%eax
  801339:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80133e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801341:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801346:	ba 00 00 00 00       	mov    $0x0,%edx
  80134b:	b8 02 00 00 00       	mov    $0x2,%eax
  801350:	e8 8d ff ff ff       	call   8012e2 <fsipc>
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	8b 40 0c             	mov    0xc(%eax),%eax
  801363:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801368:	ba 00 00 00 00       	mov    $0x0,%edx
  80136d:	b8 06 00 00 00       	mov    $0x6,%eax
  801372:	e8 6b ff ff ff       	call   8012e2 <fsipc>
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	53                   	push   %ebx
  80137d:	83 ec 04             	sub    $0x4,%esp
  801380:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	8b 40 0c             	mov    0xc(%eax),%eax
  801389:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80138e:	ba 00 00 00 00       	mov    $0x0,%edx
  801393:	b8 05 00 00 00       	mov    $0x5,%eax
  801398:	e8 45 ff ff ff       	call   8012e2 <fsipc>
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 2c                	js     8013cd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	68 00 50 80 00       	push   $0x805000
  8013a9:	53                   	push   %ebx
  8013aa:	e8 70 f3 ff ff       	call   80071f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013af:	a1 80 50 80 00       	mov    0x805080,%eax
  8013b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ba:	a1 84 50 80 00       	mov    0x805084,%eax
  8013bf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    

008013d2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013db:	8b 55 08             	mov    0x8(%ebp),%edx
  8013de:	8b 52 0c             	mov    0xc(%edx),%edx
  8013e1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013e7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013ec:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013f1:	0f 47 c2             	cmova  %edx,%eax
  8013f4:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013f9:	50                   	push   %eax
  8013fa:	ff 75 0c             	pushl  0xc(%ebp)
  8013fd:	68 08 50 80 00       	push   $0x805008
  801402:	e8 aa f4 ff ff       	call   8008b1 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	b8 04 00 00 00       	mov    $0x4,%eax
  801411:	e8 cc fe ff ff       	call   8012e2 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
  801423:	8b 40 0c             	mov    0xc(%eax),%eax
  801426:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80142b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	b8 03 00 00 00       	mov    $0x3,%eax
  80143b:	e8 a2 fe ff ff       	call   8012e2 <fsipc>
  801440:	89 c3                	mov    %eax,%ebx
  801442:	85 c0                	test   %eax,%eax
  801444:	78 4b                	js     801491 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801446:	39 c6                	cmp    %eax,%esi
  801448:	73 16                	jae    801460 <devfile_read+0x48>
  80144a:	68 38 22 80 00       	push   $0x802238
  80144f:	68 3f 22 80 00       	push   $0x80223f
  801454:	6a 7c                	push   $0x7c
  801456:	68 54 22 80 00       	push   $0x802254
  80145b:	e8 bd 05 00 00       	call   801a1d <_panic>
	assert(r <= PGSIZE);
  801460:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801465:	7e 16                	jle    80147d <devfile_read+0x65>
  801467:	68 5f 22 80 00       	push   $0x80225f
  80146c:	68 3f 22 80 00       	push   $0x80223f
  801471:	6a 7d                	push   $0x7d
  801473:	68 54 22 80 00       	push   $0x802254
  801478:	e8 a0 05 00 00       	call   801a1d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80147d:	83 ec 04             	sub    $0x4,%esp
  801480:	50                   	push   %eax
  801481:	68 00 50 80 00       	push   $0x805000
  801486:	ff 75 0c             	pushl  0xc(%ebp)
  801489:	e8 23 f4 ff ff       	call   8008b1 <memmove>
	return r;
  80148e:	83 c4 10             	add    $0x10,%esp
}
  801491:	89 d8                	mov    %ebx,%eax
  801493:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801496:	5b                   	pop    %ebx
  801497:	5e                   	pop    %esi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 20             	sub    $0x20,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014a4:	53                   	push   %ebx
  8014a5:	e8 3c f2 ff ff       	call   8006e6 <strlen>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b2:	7f 67                	jg     80151b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	e8 9a f8 ff ff       	call   800d5a <fd_alloc>
  8014c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 57                	js     801520 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	53                   	push   %ebx
  8014cd:	68 00 50 80 00       	push   $0x805000
  8014d2:	e8 48 f2 ff ff       	call   80071f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014da:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e7:	e8 f6 fd ff ff       	call   8012e2 <fsipc>
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	79 14                	jns    801509 <open+0x6f>
		fd_close(fd, 0);
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	6a 00                	push   $0x0
  8014fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fd:	e8 50 f9 ff ff       	call   800e52 <fd_close>
		return r;
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	89 da                	mov    %ebx,%edx
  801507:	eb 17                	jmp    801520 <open+0x86>
	}

	return fd2num(fd);
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	ff 75 f4             	pushl  -0xc(%ebp)
  80150f:	e8 1f f8 ff ff       	call   800d33 <fd2num>
  801514:	89 c2                	mov    %eax,%edx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	eb 05                	jmp    801520 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80151b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801520:	89 d0                	mov    %edx,%eax
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80152d:	ba 00 00 00 00       	mov    $0x0,%edx
  801532:	b8 08 00 00 00       	mov    $0x8,%eax
  801537:	e8 a6 fd ff ff       	call   8012e2 <fsipc>
}
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	56                   	push   %esi
  801542:	53                   	push   %ebx
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	ff 75 08             	pushl  0x8(%ebp)
  80154c:	e8 f2 f7 ff ff       	call   800d43 <fd2data>
  801551:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	68 6b 22 80 00       	push   $0x80226b
  80155b:	53                   	push   %ebx
  80155c:	e8 be f1 ff ff       	call   80071f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801561:	8b 46 04             	mov    0x4(%esi),%eax
  801564:	2b 06                	sub    (%esi),%eax
  801566:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80156c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801573:	00 00 00 
	stat->st_dev = &devpipe;
  801576:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80157d:	30 80 00 
	return 0;
}
  801580:	b8 00 00 00 00       	mov    $0x0,%eax
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801596:	53                   	push   %ebx
  801597:	6a 00                	push   $0x0
  801599:	e8 09 f6 ff ff       	call   800ba7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80159e:	89 1c 24             	mov    %ebx,(%esp)
  8015a1:	e8 9d f7 ff ff       	call   800d43 <fd2data>
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	50                   	push   %eax
  8015aa:	6a 00                	push   $0x0
  8015ac:	e8 f6 f5 ff ff       	call   800ba7 <sys_page_unmap>
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	57                   	push   %edi
  8015ba:	56                   	push   %esi
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 1c             	sub    $0x1c,%esp
  8015bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c9:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d2:	e8 a3 05 00 00       	call   801b7a <pageref>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	89 3c 24             	mov    %edi,(%esp)
  8015dc:	e8 99 05 00 00       	call   801b7a <pageref>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	39 c3                	cmp    %eax,%ebx
  8015e6:	0f 94 c1             	sete   %cl
  8015e9:	0f b6 c9             	movzbl %cl,%ecx
  8015ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015ef:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015f5:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015f8:	39 ce                	cmp    %ecx,%esi
  8015fa:	74 1b                	je     801617 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015fc:	39 c3                	cmp    %eax,%ebx
  8015fe:	75 c4                	jne    8015c4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801600:	8b 42 60             	mov    0x60(%edx),%eax
  801603:	ff 75 e4             	pushl  -0x1c(%ebp)
  801606:	50                   	push   %eax
  801607:	56                   	push   %esi
  801608:	68 72 22 80 00       	push   $0x802272
  80160d:	e8 88 eb ff ff       	call   80019a <cprintf>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	eb ad                	jmp    8015c4 <_pipeisclosed+0xe>
	}
}
  801617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80161a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161d:	5b                   	pop    %ebx
  80161e:	5e                   	pop    %esi
  80161f:	5f                   	pop    %edi
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    

00801622 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	57                   	push   %edi
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
  801628:	83 ec 28             	sub    $0x28,%esp
  80162b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80162e:	56                   	push   %esi
  80162f:	e8 0f f7 ff ff       	call   800d43 <fd2data>
  801634:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	bf 00 00 00 00       	mov    $0x0,%edi
  80163e:	eb 4b                	jmp    80168b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801640:	89 da                	mov    %ebx,%edx
  801642:	89 f0                	mov    %esi,%eax
  801644:	e8 6d ff ff ff       	call   8015b6 <_pipeisclosed>
  801649:	85 c0                	test   %eax,%eax
  80164b:	75 48                	jne    801695 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80164d:	e8 b1 f4 ff ff       	call   800b03 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801652:	8b 43 04             	mov    0x4(%ebx),%eax
  801655:	8b 0b                	mov    (%ebx),%ecx
  801657:	8d 51 20             	lea    0x20(%ecx),%edx
  80165a:	39 d0                	cmp    %edx,%eax
  80165c:	73 e2                	jae    801640 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801665:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801668:	89 c2                	mov    %eax,%edx
  80166a:	c1 fa 1f             	sar    $0x1f,%edx
  80166d:	89 d1                	mov    %edx,%ecx
  80166f:	c1 e9 1b             	shr    $0x1b,%ecx
  801672:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801675:	83 e2 1f             	and    $0x1f,%edx
  801678:	29 ca                	sub    %ecx,%edx
  80167a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80167e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801682:	83 c0 01             	add    $0x1,%eax
  801685:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801688:	83 c7 01             	add    $0x1,%edi
  80168b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80168e:	75 c2                	jne    801652 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801690:	8b 45 10             	mov    0x10(%ebp),%eax
  801693:	eb 05                	jmp    80169a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80169a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5f                   	pop    %edi
  8016a0:	5d                   	pop    %ebp
  8016a1:	c3                   	ret    

008016a2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	57                   	push   %edi
  8016a6:	56                   	push   %esi
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 18             	sub    $0x18,%esp
  8016ab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016ae:	57                   	push   %edi
  8016af:	e8 8f f6 ff ff       	call   800d43 <fd2data>
  8016b4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016be:	eb 3d                	jmp    8016fd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016c0:	85 db                	test   %ebx,%ebx
  8016c2:	74 04                	je     8016c8 <devpipe_read+0x26>
				return i;
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	eb 44                	jmp    80170c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016c8:	89 f2                	mov    %esi,%edx
  8016ca:	89 f8                	mov    %edi,%eax
  8016cc:	e8 e5 fe ff ff       	call   8015b6 <_pipeisclosed>
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	75 32                	jne    801707 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016d5:	e8 29 f4 ff ff       	call   800b03 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016da:	8b 06                	mov    (%esi),%eax
  8016dc:	3b 46 04             	cmp    0x4(%esi),%eax
  8016df:	74 df                	je     8016c0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e1:	99                   	cltd   
  8016e2:	c1 ea 1b             	shr    $0x1b,%edx
  8016e5:	01 d0                	add    %edx,%eax
  8016e7:	83 e0 1f             	and    $0x1f,%eax
  8016ea:	29 d0                	sub    %edx,%eax
  8016ec:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016f7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fa:	83 c3 01             	add    $0x1,%ebx
  8016fd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801700:	75 d8                	jne    8016da <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801702:	8b 45 10             	mov    0x10(%ebp),%eax
  801705:	eb 05                	jmp    80170c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801707:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80170c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5f                   	pop    %edi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80171c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171f:	50                   	push   %eax
  801720:	e8 35 f6 ff ff       	call   800d5a <fd_alloc>
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	89 c2                	mov    %eax,%edx
  80172a:	85 c0                	test   %eax,%eax
  80172c:	0f 88 2c 01 00 00    	js     80185e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	68 07 04 00 00       	push   $0x407
  80173a:	ff 75 f4             	pushl  -0xc(%ebp)
  80173d:	6a 00                	push   $0x0
  80173f:	e8 de f3 ff ff       	call   800b22 <sys_page_alloc>
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	89 c2                	mov    %eax,%edx
  801749:	85 c0                	test   %eax,%eax
  80174b:	0f 88 0d 01 00 00    	js     80185e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801751:	83 ec 0c             	sub    $0xc,%esp
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	e8 fd f5 ff ff       	call   800d5a <fd_alloc>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	85 c0                	test   %eax,%eax
  801764:	0f 88 e2 00 00 00    	js     80184c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	68 07 04 00 00       	push   $0x407
  801772:	ff 75 f0             	pushl  -0x10(%ebp)
  801775:	6a 00                	push   $0x0
  801777:	e8 a6 f3 ff ff       	call   800b22 <sys_page_alloc>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	0f 88 c3 00 00 00    	js     80184c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801789:	83 ec 0c             	sub    $0xc,%esp
  80178c:	ff 75 f4             	pushl  -0xc(%ebp)
  80178f:	e8 af f5 ff ff       	call   800d43 <fd2data>
  801794:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801796:	83 c4 0c             	add    $0xc,%esp
  801799:	68 07 04 00 00       	push   $0x407
  80179e:	50                   	push   %eax
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 7c f3 ff ff       	call   800b22 <sys_page_alloc>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	0f 88 89 00 00 00    	js     80183c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b3:	83 ec 0c             	sub    $0xc,%esp
  8017b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b9:	e8 85 f5 ff ff       	call   800d43 <fd2data>
  8017be:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c5:	50                   	push   %eax
  8017c6:	6a 00                	push   $0x0
  8017c8:	56                   	push   %esi
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 95 f3 ff ff       	call   800b65 <sys_page_map>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	83 c4 20             	add    $0x20,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 55                	js     80182e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017d9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	ff 75 f4             	pushl  -0xc(%ebp)
  801809:	e8 25 f5 ff ff       	call   800d33 <fd2num>
  80180e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801811:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801813:	83 c4 04             	add    $0x4,%esp
  801816:	ff 75 f0             	pushl  -0x10(%ebp)
  801819:	e8 15 f5 ff ff       	call   800d33 <fd2num>
  80181e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801821:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	eb 30                	jmp    80185e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	56                   	push   %esi
  801832:	6a 00                	push   $0x0
  801834:	e8 6e f3 ff ff       	call   800ba7 <sys_page_unmap>
  801839:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	ff 75 f0             	pushl  -0x10(%ebp)
  801842:	6a 00                	push   $0x0
  801844:	e8 5e f3 ff ff       	call   800ba7 <sys_page_unmap>
  801849:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	ff 75 f4             	pushl  -0xc(%ebp)
  801852:	6a 00                	push   $0x0
  801854:	e8 4e f3 ff ff       	call   800ba7 <sys_page_unmap>
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80185e:	89 d0                	mov    %edx,%eax
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801870:	50                   	push   %eax
  801871:	ff 75 08             	pushl  0x8(%ebp)
  801874:	e8 30 f5 ff ff       	call   800da9 <fd_lookup>
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 18                	js     801898 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	ff 75 f4             	pushl  -0xc(%ebp)
  801886:	e8 b8 f4 ff ff       	call   800d43 <fd2data>
	return _pipeisclosed(fd, p);
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801890:	e8 21 fd ff ff       	call   8015b6 <_pipeisclosed>
  801895:	83 c4 10             	add    $0x10,%esp
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018aa:	68 8a 22 80 00       	push   $0x80228a
  8018af:	ff 75 0c             	pushl  0xc(%ebp)
  8018b2:	e8 68 ee ff ff       	call   80071f <strcpy>
	return 0;
}
  8018b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	57                   	push   %edi
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ca:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d5:	eb 2d                	jmp    801904 <devcons_write+0x46>
		m = n - tot;
  8018d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018da:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018dc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018df:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018e4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	03 45 0c             	add    0xc(%ebp),%eax
  8018ee:	50                   	push   %eax
  8018ef:	57                   	push   %edi
  8018f0:	e8 bc ef ff ff       	call   8008b1 <memmove>
		sys_cputs(buf, m);
  8018f5:	83 c4 08             	add    $0x8,%esp
  8018f8:	53                   	push   %ebx
  8018f9:	57                   	push   %edi
  8018fa:	e8 67 f1 ff ff       	call   800a66 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ff:	01 de                	add    %ebx,%esi
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	89 f0                	mov    %esi,%eax
  801906:	3b 75 10             	cmp    0x10(%ebp),%esi
  801909:	72 cc                	jb     8018d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80190b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5e                   	pop    %esi
  801910:	5f                   	pop    %edi
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80191e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801922:	74 2a                	je     80194e <devcons_read+0x3b>
  801924:	eb 05                	jmp    80192b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801926:	e8 d8 f1 ff ff       	call   800b03 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80192b:	e8 54 f1 ff ff       	call   800a84 <sys_cgetc>
  801930:	85 c0                	test   %eax,%eax
  801932:	74 f2                	je     801926 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801934:	85 c0                	test   %eax,%eax
  801936:	78 16                	js     80194e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801938:	83 f8 04             	cmp    $0x4,%eax
  80193b:	74 0c                	je     801949 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80193d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801940:	88 02                	mov    %al,(%edx)
	return 1;
  801942:	b8 01 00 00 00       	mov    $0x1,%eax
  801947:	eb 05                	jmp    80194e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80195c:	6a 01                	push   $0x1
  80195e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	e8 ff f0 ff ff       	call   800a66 <sys_cputs>
}
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <getchar>:

int
getchar(void)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801972:	6a 01                	push   $0x1
  801974:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	6a 00                	push   $0x0
  80197a:	e8 90 f6 ff ff       	call   80100f <read>
	if (r < 0)
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	85 c0                	test   %eax,%eax
  801984:	78 0f                	js     801995 <getchar+0x29>
		return r;
	if (r < 1)
  801986:	85 c0                	test   %eax,%eax
  801988:	7e 06                	jle    801990 <getchar+0x24>
		return -E_EOF;
	return c;
  80198a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80198e:	eb 05                	jmp    801995 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801990:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a0:	50                   	push   %eax
  8019a1:	ff 75 08             	pushl  0x8(%ebp)
  8019a4:	e8 00 f4 ff ff       	call   800da9 <fd_lookup>
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 11                	js     8019c1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b9:	39 10                	cmp    %edx,(%eax)
  8019bb:	0f 94 c0             	sete   %al
  8019be:	0f b6 c0             	movzbl %al,%eax
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <opencons>:

int
opencons(void)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cc:	50                   	push   %eax
  8019cd:	e8 88 f3 ff ff       	call   800d5a <fd_alloc>
  8019d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 3e                	js     801a19 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	68 07 04 00 00       	push   $0x407
  8019e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 35 f1 ff ff       	call   800b22 <sys_page_alloc>
  8019ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 23                	js     801a19 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019f6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	50                   	push   %eax
  801a0f:	e8 1f f3 ff ff       	call   800d33 <fd2num>
  801a14:	89 c2                	mov    %eax,%edx
  801a16:	83 c4 10             	add    $0x10,%esp
}
  801a19:	89 d0                	mov    %edx,%eax
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a22:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a25:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a2b:	e8 b4 f0 ff ff       	call   800ae4 <sys_getenvid>
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	ff 75 08             	pushl  0x8(%ebp)
  801a39:	56                   	push   %esi
  801a3a:	50                   	push   %eax
  801a3b:	68 98 22 80 00       	push   $0x802298
  801a40:	e8 55 e7 ff ff       	call   80019a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a45:	83 c4 18             	add    $0x18,%esp
  801a48:	53                   	push   %ebx
  801a49:	ff 75 10             	pushl  0x10(%ebp)
  801a4c:	e8 f8 e6 ff ff       	call   800149 <vcprintf>
	cprintf("\n");
  801a51:	c7 04 24 83 22 80 00 	movl   $0x802283,(%esp)
  801a58:	e8 3d e7 ff ff       	call   80019a <cprintf>
  801a5d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a60:	cc                   	int3   
  801a61:	eb fd                	jmp    801a60 <_panic+0x43>

00801a63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a71:	85 c0                	test   %eax,%eax
  801a73:	75 12                	jne    801a87 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	68 00 00 c0 ee       	push   $0xeec00000
  801a7d:	e8 50 f2 ff ff       	call   800cd2 <sys_ipc_recv>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	eb 0c                	jmp    801a93 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	50                   	push   %eax
  801a8b:	e8 42 f2 ff ff       	call   800cd2 <sys_ipc_recv>
  801a90:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a93:	85 f6                	test   %esi,%esi
  801a95:	0f 95 c1             	setne  %cl
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	0f 95 c2             	setne  %dl
  801a9d:	84 d1                	test   %dl,%cl
  801a9f:	74 09                	je     801aaa <ipc_recv+0x47>
  801aa1:	89 c2                	mov    %eax,%edx
  801aa3:	c1 ea 1f             	shr    $0x1f,%edx
  801aa6:	84 d2                	test   %dl,%dl
  801aa8:	75 27                	jne    801ad1 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801aaa:	85 f6                	test   %esi,%esi
  801aac:	74 0a                	je     801ab8 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801aae:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab3:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ab6:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ab8:	85 db                	test   %ebx,%ebx
  801aba:	74 0d                	je     801ac9 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801abc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ac7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ad1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aea:	85 db                	test   %ebx,%ebx
  801aec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801af1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801af4:	ff 75 14             	pushl  0x14(%ebp)
  801af7:	53                   	push   %ebx
  801af8:	56                   	push   %esi
  801af9:	57                   	push   %edi
  801afa:	e8 b0 f1 ff ff       	call   800caf <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801aff:	89 c2                	mov    %eax,%edx
  801b01:	c1 ea 1f             	shr    $0x1f,%edx
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	84 d2                	test   %dl,%dl
  801b09:	74 17                	je     801b22 <ipc_send+0x4a>
  801b0b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0e:	74 12                	je     801b22 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b10:	50                   	push   %eax
  801b11:	68 bc 22 80 00       	push   $0x8022bc
  801b16:	6a 47                	push   $0x47
  801b18:	68 ca 22 80 00       	push   $0x8022ca
  801b1d:	e8 fb fe ff ff       	call   801a1d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b22:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b25:	75 07                	jne    801b2e <ipc_send+0x56>
			sys_yield();
  801b27:	e8 d7 ef ff ff       	call   800b03 <sys_yield>
  801b2c:	eb c6                	jmp    801af4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	75 c2                	jne    801af4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b45:	89 c2                	mov    %eax,%edx
  801b47:	c1 e2 07             	shl    $0x7,%edx
  801b4a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b51:	8b 52 58             	mov    0x58(%edx),%edx
  801b54:	39 ca                	cmp    %ecx,%edx
  801b56:	75 11                	jne    801b69 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b58:	89 c2                	mov    %eax,%edx
  801b5a:	c1 e2 07             	shl    $0x7,%edx
  801b5d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b64:	8b 40 50             	mov    0x50(%eax),%eax
  801b67:	eb 0f                	jmp    801b78 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b69:	83 c0 01             	add    $0x1,%eax
  801b6c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b71:	75 d2                	jne    801b45 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b80:	89 d0                	mov    %edx,%eax
  801b82:	c1 e8 16             	shr    $0x16,%eax
  801b85:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b91:	f6 c1 01             	test   $0x1,%cl
  801b94:	74 1d                	je     801bb3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b96:	c1 ea 0c             	shr    $0xc,%edx
  801b99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba0:	f6 c2 01             	test   $0x1,%dl
  801ba3:	74 0e                	je     801bb3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba5:	c1 ea 0c             	shr    $0xc,%edx
  801ba8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801baf:	ef 
  801bb0:	0f b7 c0             	movzwl %ax,%eax
}
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    
  801bb5:	66 90                	xchg   %ax,%ax
  801bb7:	66 90                	xchg   %ax,%ax
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

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
