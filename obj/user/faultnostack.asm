
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 40 0d 80 00       	push   $0x800d40
  80003e:	6a 00                	push   $0x0
  800040:	e8 35 0c 00 00       	call   800c7a <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	57                   	push   %edi
  800058:	56                   	push   %esi
  800059:	53                   	push   %ebx
  80005a:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800064:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800067:	e8 85 0a 00 00       	call   800af1 <sys_getenvid>
  80006c:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	50                   	push   %eax
  800072:	68 00 1f 80 00       	push   $0x801f00
  800077:	e8 2b 01 00 00       	call   8001a7 <cprintf>
  80007c:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800082:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800094:	89 c1                	mov    %eax,%ecx
  800096:	c1 e1 07             	shl    $0x7,%ecx
  800099:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000a0:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000a3:	39 cb                	cmp    %ecx,%ebx
  8000a5:	0f 44 fa             	cmove  %edx,%edi
  8000a8:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000ad:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000b0:	83 c0 01             	add    $0x1,%eax
  8000b3:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000b9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000be:	75 d4                	jne    800094 <libmain+0x40>
  8000c0:	89 f0                	mov    %esi,%eax
  8000c2:	84 c0                	test   %al,%al
  8000c4:	74 06                	je     8000cc <libmain+0x78>
  8000c6:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000d0:	7e 0a                	jle    8000dc <libmain+0x88>
		binaryname = argv[0];
  8000d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d5:	8b 00                	mov    (%eax),%eax
  8000d7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000dc:	83 ec 08             	sub    $0x8,%esp
  8000df:	ff 75 0c             	pushl  0xc(%ebp)
  8000e2:	ff 75 08             	pushl  0x8(%ebp)
  8000e5:	e8 49 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ea:	e8 0b 00 00 00       	call   8000fa <exit>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800100:	e8 2a 0e 00 00       	call   800f2f <close_all>
	sys_env_destroy(0);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	6a 00                	push   $0x0
  80010a:	e8 a1 09 00 00       	call   800ab0 <sys_env_destroy>
}
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	c9                   	leave  
  800113:	c3                   	ret    

00800114 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	53                   	push   %ebx
  800118:	83 ec 04             	sub    $0x4,%esp
  80011b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011e:	8b 13                	mov    (%ebx),%edx
  800120:	8d 42 01             	lea    0x1(%edx),%eax
  800123:	89 03                	mov    %eax,(%ebx)
  800125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800128:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800131:	75 1a                	jne    80014d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800133:	83 ec 08             	sub    $0x8,%esp
  800136:	68 ff 00 00 00       	push   $0xff
  80013b:	8d 43 08             	lea    0x8(%ebx),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 2f 09 00 00       	call   800a73 <sys_cputs>
		b->idx = 0;
  800144:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800166:	00 00 00 
	b.cnt = 0;
  800169:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800170:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800173:	ff 75 0c             	pushl  0xc(%ebp)
  800176:	ff 75 08             	pushl  0x8(%ebp)
  800179:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	68 14 01 80 00       	push   $0x800114
  800185:	e8 54 01 00 00       	call   8002de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018a:	83 c4 08             	add    $0x8,%esp
  80018d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800193:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800199:	50                   	push   %eax
  80019a:	e8 d4 08 00 00       	call   800a73 <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	50                   	push   %eax
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	e8 9d ff ff ff       	call   800156 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 1c             	sub    $0x1c,%esp
  8001c4:	89 c7                	mov    %eax,%edi
  8001c6:	89 d6                	mov    %edx,%esi
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001df:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e2:	39 d3                	cmp    %edx,%ebx
  8001e4:	72 05                	jb     8001eb <printnum+0x30>
  8001e6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e9:	77 45                	ja     800230 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 18             	pushl  0x18(%ebp)
  8001f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f7:	53                   	push   %ebx
  8001f8:	ff 75 10             	pushl  0x10(%ebp)
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800201:	ff 75 e0             	pushl  -0x20(%ebp)
  800204:	ff 75 dc             	pushl  -0x24(%ebp)
  800207:	ff 75 d8             	pushl  -0x28(%ebp)
  80020a:	e8 51 1a 00 00       	call   801c60 <__udivdi3>
  80020f:	83 c4 18             	add    $0x18,%esp
  800212:	52                   	push   %edx
  800213:	50                   	push   %eax
  800214:	89 f2                	mov    %esi,%edx
  800216:	89 f8                	mov    %edi,%eax
  800218:	e8 9e ff ff ff       	call   8001bb <printnum>
  80021d:	83 c4 20             	add    $0x20,%esp
  800220:	eb 18                	jmp    80023a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	ff 75 18             	pushl  0x18(%ebp)
  800229:	ff d7                	call   *%edi
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 03                	jmp    800233 <printnum+0x78>
  800230:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800233:	83 eb 01             	sub    $0x1,%ebx
  800236:	85 db                	test   %ebx,%ebx
  800238:	7f e8                	jg     800222 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	56                   	push   %esi
  80023e:	83 ec 04             	sub    $0x4,%esp
  800241:	ff 75 e4             	pushl  -0x1c(%ebp)
  800244:	ff 75 e0             	pushl  -0x20(%ebp)
  800247:	ff 75 dc             	pushl  -0x24(%ebp)
  80024a:	ff 75 d8             	pushl  -0x28(%ebp)
  80024d:	e8 3e 1b 00 00       	call   801d90 <__umoddi3>
  800252:	83 c4 14             	add    $0x14,%esp
  800255:	0f be 80 29 1f 80 00 	movsbl 0x801f29(%eax),%eax
  80025c:	50                   	push   %eax
  80025d:	ff d7                	call   *%edi
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026d:	83 fa 01             	cmp    $0x1,%edx
  800270:	7e 0e                	jle    800280 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 08             	lea    0x8(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	8b 52 04             	mov    0x4(%edx),%edx
  80027e:	eb 22                	jmp    8002a2 <getuint+0x38>
	else if (lflag)
  800280:	85 d2                	test   %edx,%edx
  800282:	74 10                	je     800294 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	eb 0e                	jmp    8002a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    

008002a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002aa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b3:	73 0a                	jae    8002bf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	88 02                	mov    %al,(%edx)
}
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ca:	50                   	push   %eax
  8002cb:	ff 75 10             	pushl  0x10(%ebp)
  8002ce:	ff 75 0c             	pushl  0xc(%ebp)
  8002d1:	ff 75 08             	pushl  0x8(%ebp)
  8002d4:	e8 05 00 00 00       	call   8002de <vprintfmt>
	va_end(ap);
}
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
  8002e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ed:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f0:	eb 12                	jmp    800304 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f2:	85 c0                	test   %eax,%eax
  8002f4:	0f 84 89 03 00 00    	je     800683 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	53                   	push   %ebx
  8002fe:	50                   	push   %eax
  8002ff:	ff d6                	call   *%esi
  800301:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800304:	83 c7 01             	add    $0x1,%edi
  800307:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030b:	83 f8 25             	cmp    $0x25,%eax
  80030e:	75 e2                	jne    8002f2 <vprintfmt+0x14>
  800310:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800314:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800322:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
  80032e:	eb 07                	jmp    800337 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800333:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8d 47 01             	lea    0x1(%edi),%eax
  80033a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033d:	0f b6 07             	movzbl (%edi),%eax
  800340:	0f b6 c8             	movzbl %al,%ecx
  800343:	83 e8 23             	sub    $0x23,%eax
  800346:	3c 55                	cmp    $0x55,%al
  800348:	0f 87 1a 03 00 00    	ja     800668 <vprintfmt+0x38a>
  80034e:	0f b6 c0             	movzbl %al,%eax
  800351:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035f:	eb d6                	jmp    800337 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800364:	b8 00 00 00 00       	mov    $0x0,%eax
  800369:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800373:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800376:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800379:	83 fa 09             	cmp    $0x9,%edx
  80037c:	77 39                	ja     8003b7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800381:	eb e9                	jmp    80036c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 48 04             	lea    0x4(%eax),%ecx
  800389:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038c:	8b 00                	mov    (%eax),%eax
  80038e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800394:	eb 27                	jmp    8003bd <vprintfmt+0xdf>
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	85 c0                	test   %eax,%eax
  80039b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a0:	0f 49 c8             	cmovns %eax,%ecx
  8003a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	eb 8c                	jmp    800337 <vprintfmt+0x59>
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b5:	eb 80                	jmp    800337 <vprintfmt+0x59>
  8003b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ba:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c1:	0f 89 70 ff ff ff    	jns    800337 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d4:	e9 5e ff ff ff       	jmp    800337 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003df:	e9 53 ff ff ff       	jmp    800337 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	53                   	push   %ebx
  8003f1:	ff 30                	pushl  (%eax)
  8003f3:	ff d6                	call   *%esi
			break;
  8003f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fb:	e9 04 ff ff ff       	jmp    800304 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	99                   	cltd   
  80040c:	31 d0                	xor    %edx,%eax
  80040e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800410:	83 f8 0f             	cmp    $0xf,%eax
  800413:	7f 0b                	jg     800420 <vprintfmt+0x142>
  800415:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  80041c:	85 d2                	test   %edx,%edx
  80041e:	75 18                	jne    800438 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800420:	50                   	push   %eax
  800421:	68 41 1f 80 00       	push   $0x801f41
  800426:	53                   	push   %ebx
  800427:	56                   	push   %esi
  800428:	e8 94 fe ff ff       	call   8002c1 <printfmt>
  80042d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800433:	e9 cc fe ff ff       	jmp    800304 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800438:	52                   	push   %edx
  800439:	68 f1 22 80 00       	push   $0x8022f1
  80043e:	53                   	push   %ebx
  80043f:	56                   	push   %esi
  800440:	e8 7c fe ff ff       	call   8002c1 <printfmt>
  800445:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044b:	e9 b4 fe ff ff       	jmp    800304 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045b:	85 ff                	test   %edi,%edi
  80045d:	b8 3a 1f 80 00       	mov    $0x801f3a,%eax
  800462:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800465:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800469:	0f 8e 94 00 00 00    	jle    800503 <vprintfmt+0x225>
  80046f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800473:	0f 84 98 00 00 00    	je     800511 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	ff 75 d0             	pushl  -0x30(%ebp)
  80047f:	57                   	push   %edi
  800480:	e8 86 02 00 00       	call   80070b <strnlen>
  800485:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800488:	29 c1                	sub    %eax,%ecx
  80048a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800490:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800494:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800497:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049c:	eb 0f                	jmp    8004ad <vprintfmt+0x1cf>
					putch(padc, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	53                   	push   %ebx
  8004a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ef 01             	sub    $0x1,%edi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	85 ff                	test   %edi,%edi
  8004af:	7f ed                	jg     80049e <vprintfmt+0x1c0>
  8004b1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b7:	85 c9                	test   %ecx,%ecx
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	0f 49 c1             	cmovns %ecx,%eax
  8004c1:	29 c1                	sub    %eax,%ecx
  8004c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cc:	89 cb                	mov    %ecx,%ebx
  8004ce:	eb 4d                	jmp    80051d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d4:	74 1b                	je     8004f1 <vprintfmt+0x213>
  8004d6:	0f be c0             	movsbl %al,%eax
  8004d9:	83 e8 20             	sub    $0x20,%eax
  8004dc:	83 f8 5e             	cmp    $0x5e,%eax
  8004df:	76 10                	jbe    8004f1 <vprintfmt+0x213>
					putch('?', putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	6a 3f                	push   $0x3f
  8004e9:	ff 55 08             	call   *0x8(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	eb 0d                	jmp    8004fe <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	52                   	push   %edx
  8004f8:	ff 55 08             	call   *0x8(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	83 eb 01             	sub    $0x1,%ebx
  800501:	eb 1a                	jmp    80051d <vprintfmt+0x23f>
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050f:	eb 0c                	jmp    80051d <vprintfmt+0x23f>
  800511:	89 75 08             	mov    %esi,0x8(%ebp)
  800514:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800517:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051d:	83 c7 01             	add    $0x1,%edi
  800520:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800524:	0f be d0             	movsbl %al,%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	74 23                	je     80054e <vprintfmt+0x270>
  80052b:	85 f6                	test   %esi,%esi
  80052d:	78 a1                	js     8004d0 <vprintfmt+0x1f2>
  80052f:	83 ee 01             	sub    $0x1,%esi
  800532:	79 9c                	jns    8004d0 <vprintfmt+0x1f2>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	eb 18                	jmp    800556 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 20                	push   $0x20
  800544:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x278>
  80054e:	89 df                	mov    %ebx,%edi
  800550:	8b 75 08             	mov    0x8(%ebp),%esi
  800553:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800556:	85 ff                	test   %edi,%edi
  800558:	7f e4                	jg     80053e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055d:	e9 a2 fd ff ff       	jmp    800304 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800562:	83 fa 01             	cmp    $0x1,%edx
  800565:	7e 16                	jle    80057d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 08             	lea    0x8(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 50 04             	mov    0x4(%eax),%edx
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057b:	eb 32                	jmp    8005af <vprintfmt+0x2d1>
	else if (lflag)
  80057d:	85 d2                	test   %edx,%edx
  80057f:	74 18                	je     800599 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 c1                	mov    %eax,%ecx
  800591:	c1 f9 1f             	sar    $0x1f,%ecx
  800594:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800597:	eb 16                	jmp    8005af <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 c1                	mov    %eax,%ecx
  8005a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005be:	79 74                	jns    800634 <vprintfmt+0x356>
				putch('-', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 2d                	push   $0x2d
  8005c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ce:	f7 d8                	neg    %eax
  8005d0:	83 d2 00             	adc    $0x0,%edx
  8005d3:	f7 da                	neg    %edx
  8005d5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005dd:	eb 55                	jmp    800634 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 83 fc ff ff       	call   80026a <getuint>
			base = 10;
  8005e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ec:	eb 46                	jmp    800634 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 74 fc ff ff       	call   80026a <getuint>
			base = 8;
  8005f6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fb:	eb 37                	jmp    800634 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 30                	push   $0x30
  800603:	ff d6                	call   *%esi
			putch('x', putdat);
  800605:	83 c4 08             	add    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 78                	push   $0x78
  80060b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800620:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800625:	eb 0d                	jmp    800634 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 3b fc ff ff       	call   80026a <getuint>
			base = 16;
  80062f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063b:	57                   	push   %edi
  80063c:	ff 75 e0             	pushl  -0x20(%ebp)
  80063f:	51                   	push   %ecx
  800640:	52                   	push   %edx
  800641:	50                   	push   %eax
  800642:	89 da                	mov    %ebx,%edx
  800644:	89 f0                	mov    %esi,%eax
  800646:	e8 70 fb ff ff       	call   8001bb <printnum>
			break;
  80064b:	83 c4 20             	add    $0x20,%esp
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800651:	e9 ae fc ff ff       	jmp    800304 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	51                   	push   %ecx
  80065b:	ff d6                	call   *%esi
			break;
  80065d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800663:	e9 9c fc ff ff       	jmp    800304 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 25                	push   $0x25
  80066e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb 03                	jmp    800678 <vprintfmt+0x39a>
  800675:	83 ef 01             	sub    $0x1,%edi
  800678:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067c:	75 f7                	jne    800675 <vprintfmt+0x397>
  80067e:	e9 81 fc ff ff       	jmp    800304 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800686:	5b                   	pop    %ebx
  800687:	5e                   	pop    %esi
  800688:	5f                   	pop    %edi
  800689:	5d                   	pop    %ebp
  80068a:	c3                   	ret    

0080068b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	83 ec 18             	sub    $0x18,%esp
  800691:	8b 45 08             	mov    0x8(%ebp),%eax
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800697:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	74 26                	je     8006d2 <vsnprintf+0x47>
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	7e 22                	jle    8006d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b0:	ff 75 14             	pushl  0x14(%ebp)
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	68 a4 02 80 00       	push   $0x8002a4
  8006bf:	e8 1a fc ff ff       	call   8002de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	eb 05                	jmp    8006d7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e2:	50                   	push   %eax
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	ff 75 08             	pushl  0x8(%ebp)
  8006ec:	e8 9a ff ff ff       	call   80068b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fe:	eb 03                	jmp    800703 <strlen+0x10>
		n++;
  800700:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800707:	75 f7                	jne    800700 <strlen+0xd>
		n++;
	return n;
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800714:	ba 00 00 00 00       	mov    $0x0,%edx
  800719:	eb 03                	jmp    80071e <strnlen+0x13>
		n++;
  80071b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	39 c2                	cmp    %eax,%edx
  800720:	74 08                	je     80072a <strnlen+0x1f>
  800722:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800726:	75 f3                	jne    80071b <strnlen+0x10>
  800728:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800736:	89 c2                	mov    %eax,%edx
  800738:	83 c2 01             	add    $0x1,%edx
  80073b:	83 c1 01             	add    $0x1,%ecx
  80073e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800742:	88 5a ff             	mov    %bl,-0x1(%edx)
  800745:	84 db                	test   %bl,%bl
  800747:	75 ef                	jne    800738 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800749:	5b                   	pop    %ebx
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800753:	53                   	push   %ebx
  800754:	e8 9a ff ff ff       	call   8006f3 <strlen>
  800759:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	01 d8                	add    %ebx,%eax
  800761:	50                   	push   %eax
  800762:	e8 c5 ff ff ff       	call   80072c <strcpy>
	return dst;
}
  800767:	89 d8                	mov    %ebx,%eax
  800769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	56                   	push   %esi
  800772:	53                   	push   %ebx
  800773:	8b 75 08             	mov    0x8(%ebp),%esi
  800776:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800779:	89 f3                	mov    %esi,%ebx
  80077b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	89 f2                	mov    %esi,%edx
  800780:	eb 0f                	jmp    800791 <strncpy+0x23>
		*dst++ = *src;
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	0f b6 01             	movzbl (%ecx),%eax
  800788:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078b:	80 39 01             	cmpb   $0x1,(%ecx)
  80078e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	39 da                	cmp    %ebx,%edx
  800793:	75 ed                	jne    800782 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800795:	89 f0                	mov    %esi,%eax
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 21                	je     8007d0 <strlcpy+0x35>
  8007af:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b3:	89 f2                	mov    %esi,%edx
  8007b5:	eb 09                	jmp    8007c0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c0:	39 c2                	cmp    %eax,%edx
  8007c2:	74 09                	je     8007cd <strlcpy+0x32>
  8007c4:	0f b6 19             	movzbl (%ecx),%ebx
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 ec                	jne    8007b7 <strlcpy+0x1c>
  8007cb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d0:	29 f0                	sub    %esi,%eax
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007df:	eb 06                	jmp    8007e7 <strcmp+0x11>
		p++, q++;
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e7:	0f b6 01             	movzbl (%ecx),%eax
  8007ea:	84 c0                	test   %al,%al
  8007ec:	74 04                	je     8007f2 <strcmp+0x1c>
  8007ee:	3a 02                	cmp    (%edx),%al
  8007f0:	74 ef                	je     8007e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f2:	0f b6 c0             	movzbl %al,%eax
  8007f5:	0f b6 12             	movzbl (%edx),%edx
  8007f8:	29 d0                	sub    %edx,%eax
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 c3                	mov    %eax,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080b:	eb 06                	jmp    800813 <strncmp+0x17>
		n--, p++, q++;
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800813:	39 d8                	cmp    %ebx,%eax
  800815:	74 15                	je     80082c <strncmp+0x30>
  800817:	0f b6 08             	movzbl (%eax),%ecx
  80081a:	84 c9                	test   %cl,%cl
  80081c:	74 04                	je     800822 <strncmp+0x26>
  80081e:	3a 0a                	cmp    (%edx),%cl
  800820:	74 eb                	je     80080d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 00             	movzbl (%eax),%eax
  800825:	0f b6 12             	movzbl (%edx),%edx
  800828:	29 d0                	sub    %edx,%eax
  80082a:	eb 05                	jmp    800831 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083e:	eb 07                	jmp    800847 <strchr+0x13>
		if (*s == c)
  800840:	38 ca                	cmp    %cl,%dl
  800842:	74 0f                	je     800853 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800844:	83 c0 01             	add    $0x1,%eax
  800847:	0f b6 10             	movzbl (%eax),%edx
  80084a:	84 d2                	test   %dl,%dl
  80084c:	75 f2                	jne    800840 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085f:	eb 03                	jmp    800864 <strfind+0xf>
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800867:	38 ca                	cmp    %cl,%dl
  800869:	74 04                	je     80086f <strfind+0x1a>
  80086b:	84 d2                	test   %dl,%dl
  80086d:	75 f2                	jne    800861 <strfind+0xc>
			break;
	return (char *) s;
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	57                   	push   %edi
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	74 36                	je     8008b7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800881:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800887:	75 28                	jne    8008b1 <memset+0x40>
  800889:	f6 c1 03             	test   $0x3,%cl
  80088c:	75 23                	jne    8008b1 <memset+0x40>
		c &= 0xFF;
  80088e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800892:	89 d3                	mov    %edx,%ebx
  800894:	c1 e3 08             	shl    $0x8,%ebx
  800897:	89 d6                	mov    %edx,%esi
  800899:	c1 e6 18             	shl    $0x18,%esi
  80089c:	89 d0                	mov    %edx,%eax
  80089e:	c1 e0 10             	shl    $0x10,%eax
  8008a1:	09 f0                	or     %esi,%eax
  8008a3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a5:	89 d8                	mov    %ebx,%eax
  8008a7:	09 d0                	or     %edx,%eax
  8008a9:	c1 e9 02             	shr    $0x2,%ecx
  8008ac:	fc                   	cld    
  8008ad:	f3 ab                	rep stos %eax,%es:(%edi)
  8008af:	eb 06                	jmp    8008b7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b4:	fc                   	cld    
  8008b5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5f                   	pop    %edi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cc:	39 c6                	cmp    %eax,%esi
  8008ce:	73 35                	jae    800905 <memmove+0x47>
  8008d0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d3:	39 d0                	cmp    %edx,%eax
  8008d5:	73 2e                	jae    800905 <memmove+0x47>
		s += n;
		d += n;
  8008d7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	09 fe                	or     %edi,%esi
  8008de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e4:	75 13                	jne    8008f9 <memmove+0x3b>
  8008e6:	f6 c1 03             	test   $0x3,%cl
  8008e9:	75 0e                	jne    8008f9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008eb:	83 ef 04             	sub    $0x4,%edi
  8008ee:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
  8008f4:	fd                   	std    
  8008f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f7:	eb 09                	jmp    800902 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f9:	83 ef 01             	sub    $0x1,%edi
  8008fc:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ff:	fd                   	std    
  800900:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800902:	fc                   	cld    
  800903:	eb 1d                	jmp    800922 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	89 f2                	mov    %esi,%edx
  800907:	09 c2                	or     %eax,%edx
  800909:	f6 c2 03             	test   $0x3,%dl
  80090c:	75 0f                	jne    80091d <memmove+0x5f>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0a                	jne    80091d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800913:	c1 e9 02             	shr    $0x2,%ecx
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091b:	eb 05                	jmp    800922 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	fc                   	cld    
  800920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800929:	ff 75 10             	pushl  0x10(%ebp)
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 87 ff ff ff       	call   8008be <memmove>
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
  800944:	89 c6                	mov    %eax,%esi
  800946:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800949:	eb 1a                	jmp    800965 <memcmp+0x2c>
		if (*s1 != *s2)
  80094b:	0f b6 08             	movzbl (%eax),%ecx
  80094e:	0f b6 1a             	movzbl (%edx),%ebx
  800951:	38 d9                	cmp    %bl,%cl
  800953:	74 0a                	je     80095f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800955:	0f b6 c1             	movzbl %cl,%eax
  800958:	0f b6 db             	movzbl %bl,%ebx
  80095b:	29 d8                	sub    %ebx,%eax
  80095d:	eb 0f                	jmp    80096e <memcmp+0x35>
		s1++, s2++;
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800965:	39 f0                	cmp    %esi,%eax
  800967:	75 e2                	jne    80094b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800979:	89 c1                	mov    %eax,%ecx
  80097b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80097e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800982:	eb 0a                	jmp    80098e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800984:	0f b6 10             	movzbl (%eax),%edx
  800987:	39 da                	cmp    %ebx,%edx
  800989:	74 07                	je     800992 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	39 c8                	cmp    %ecx,%eax
  800990:	72 f2                	jb     800984 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a1:	eb 03                	jmp    8009a6 <strtol+0x11>
		s++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a6:	0f b6 01             	movzbl (%ecx),%eax
  8009a9:	3c 20                	cmp    $0x20,%al
  8009ab:	74 f6                	je     8009a3 <strtol+0xe>
  8009ad:	3c 09                	cmp    $0x9,%al
  8009af:	74 f2                	je     8009a3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b1:	3c 2b                	cmp    $0x2b,%al
  8009b3:	75 0a                	jne    8009bf <strtol+0x2a>
		s++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bd:	eb 11                	jmp    8009d0 <strtol+0x3b>
  8009bf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c4:	3c 2d                	cmp    $0x2d,%al
  8009c6:	75 08                	jne    8009d0 <strtol+0x3b>
		s++, neg = 1;
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d6:	75 15                	jne    8009ed <strtol+0x58>
  8009d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009db:	75 10                	jne    8009ed <strtol+0x58>
  8009dd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e1:	75 7c                	jne    800a5f <strtol+0xca>
		s += 2, base = 16;
  8009e3:	83 c1 02             	add    $0x2,%ecx
  8009e6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009eb:	eb 16                	jmp    800a03 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ed:	85 db                	test   %ebx,%ebx
  8009ef:	75 12                	jne    800a03 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f9:	75 08                	jne    800a03 <strtol+0x6e>
		s++, base = 8;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0b:	0f b6 11             	movzbl (%ecx),%edx
  800a0e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 09             	cmp    $0x9,%bl
  800a16:	77 08                	ja     800a20 <strtol+0x8b>
			dig = *s - '0';
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 30             	sub    $0x30,%edx
  800a1e:	eb 22                	jmp    800a42 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a20:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a23:	89 f3                	mov    %esi,%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 08                	ja     800a32 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2a:	0f be d2             	movsbl %dl,%edx
  800a2d:	83 ea 57             	sub    $0x57,%edx
  800a30:	eb 10                	jmp    800a42 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a35:	89 f3                	mov    %esi,%ebx
  800a37:	80 fb 19             	cmp    $0x19,%bl
  800a3a:	77 16                	ja     800a52 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3c:	0f be d2             	movsbl %dl,%edx
  800a3f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a45:	7d 0b                	jge    800a52 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a50:	eb b9                	jmp    800a0b <strtol+0x76>

	if (endptr)
  800a52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a56:	74 0d                	je     800a65 <strtol+0xd0>
		*endptr = (char *) s;
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5b:	89 0e                	mov    %ecx,(%esi)
  800a5d:	eb 06                	jmp    800a65 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	74 98                	je     8009fb <strtol+0x66>
  800a63:	eb 9e                	jmp    800a03 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a65:	89 c2                	mov    %eax,%edx
  800a67:	f7 da                	neg    %edx
  800a69:	85 ff                	test   %edi,%edi
  800a6b:	0f 45 c2             	cmovne %edx,%eax
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a81:	8b 55 08             	mov    0x8(%ebp),%edx
  800a84:	89 c3                	mov    %eax,%ebx
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	89 c6                	mov    %eax,%esi
  800a8a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa1:	89 d1                	mov    %edx,%ecx
  800aa3:	89 d3                	mov    %edx,%ebx
  800aa5:	89 d7                	mov    %edx,%edi
  800aa7:	89 d6                	mov    %edx,%esi
  800aa9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac6:	89 cb                	mov    %ecx,%ebx
  800ac8:	89 cf                	mov    %ecx,%edi
  800aca:	89 ce                	mov    %ecx,%esi
  800acc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	7e 17                	jle    800ae9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad2:	83 ec 0c             	sub    $0xc,%esp
  800ad5:	50                   	push   %eax
  800ad6:	6a 03                	push   $0x3
  800ad8:	68 1f 22 80 00       	push   $0x80221f
  800add:	6a 23                	push   $0x23
  800adf:	68 3c 22 80 00       	push   $0x80223c
  800ae4:	e8 65 0f 00 00       	call   801a4e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af7:	ba 00 00 00 00       	mov    $0x0,%edx
  800afc:	b8 02 00 00 00       	mov    $0x2,%eax
  800b01:	89 d1                	mov    %edx,%ecx
  800b03:	89 d3                	mov    %edx,%ebx
  800b05:	89 d7                	mov    %edx,%edi
  800b07:	89 d6                	mov    %edx,%esi
  800b09:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_yield>:

void
sys_yield(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	be 00 00 00 00       	mov    $0x0,%esi
  800b3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4b:	89 f7                	mov    %esi,%edi
  800b4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	7e 17                	jle    800b6a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	50                   	push   %eax
  800b57:	6a 04                	push   $0x4
  800b59:	68 1f 22 80 00       	push   $0x80221f
  800b5e:	6a 23                	push   $0x23
  800b60:	68 3c 22 80 00       	push   $0x80223c
  800b65:	e8 e4 0e 00 00       	call   801a4e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 17                	jle    800bac <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	83 ec 0c             	sub    $0xc,%esp
  800b98:	50                   	push   %eax
  800b99:	6a 05                	push   $0x5
  800b9b:	68 1f 22 80 00       	push   $0x80221f
  800ba0:	6a 23                	push   $0x23
  800ba2:	68 3c 22 80 00       	push   $0x80223c
  800ba7:	e8 a2 0e 00 00       	call   801a4e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 df                	mov    %ebx,%edi
  800bcf:	89 de                	mov    %ebx,%esi
  800bd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 17                	jle    800bee <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	50                   	push   %eax
  800bdb:	6a 06                	push   $0x6
  800bdd:	68 1f 22 80 00       	push   $0x80221f
  800be2:	6a 23                	push   $0x23
  800be4:	68 3c 22 80 00       	push   $0x80223c
  800be9:	e8 60 0e 00 00       	call   801a4e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c04:	b8 08 00 00 00       	mov    $0x8,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 df                	mov    %ebx,%edi
  800c11:	89 de                	mov    %ebx,%esi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 08                	push   $0x8
  800c1f:	68 1f 22 80 00       	push   $0x80221f
  800c24:	6a 23                	push   $0x23
  800c26:	68 3c 22 80 00       	push   $0x80223c
  800c2b:	e8 1e 0e 00 00       	call   801a4e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c46:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 df                	mov    %ebx,%edi
  800c53:	89 de                	mov    %ebx,%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 09                	push   $0x9
  800c61:	68 1f 22 80 00       	push   $0x80221f
  800c66:	6a 23                	push   $0x23
  800c68:	68 3c 22 80 00       	push   $0x80223c
  800c6d:	e8 dc 0d 00 00       	call   801a4e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 0a                	push   $0xa
  800ca3:	68 1f 22 80 00       	push   $0x80221f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 3c 22 80 00       	push   $0x80223c
  800caf:	e8 9a 0d 00 00       	call   801a4e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	be 00 00 00 00       	mov    $0x0,%esi
  800cc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ced:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 cb                	mov    %ecx,%ebx
  800cf7:	89 cf                	mov    %ecx,%edi
  800cf9:	89 ce                	mov    %ecx,%esi
  800cfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 17                	jle    800d18 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 0d                	push   $0xd
  800d07:	68 1f 22 80 00       	push   $0x80221f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 3c 22 80 00       	push   $0x80223c
  800d13:	e8 36 0d 00 00       	call   801a4e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 cb                	mov    %ecx,%ebx
  800d35:	89 cf                	mov    %ecx,%edi
  800d37:	89 ce                	mov    %ecx,%esi
  800d39:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d41:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800d46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d48:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800d4b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800d4f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800d54:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800d58:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800d5a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800d5d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800d5e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800d61:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800d62:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800d63:	c3                   	ret    

00800d64 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d84:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d91:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	c1 ea 16             	shr    $0x16,%edx
  800d9b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da2:	f6 c2 01             	test   $0x1,%dl
  800da5:	74 11                	je     800db8 <fd_alloc+0x2d>
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	c1 ea 0c             	shr    $0xc,%edx
  800dac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db3:	f6 c2 01             	test   $0x1,%dl
  800db6:	75 09                	jne    800dc1 <fd_alloc+0x36>
			*fd_store = fd;
  800db8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbf:	eb 17                	jmp    800dd8 <fd_alloc+0x4d>
  800dc1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dcb:	75 c9                	jne    800d96 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dcd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de0:	83 f8 1f             	cmp    $0x1f,%eax
  800de3:	77 36                	ja     800e1b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de5:	c1 e0 0c             	shl    $0xc,%eax
  800de8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ded:	89 c2                	mov    %eax,%edx
  800def:	c1 ea 16             	shr    $0x16,%edx
  800df2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df9:	f6 c2 01             	test   $0x1,%dl
  800dfc:	74 24                	je     800e22 <fd_lookup+0x48>
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	c1 ea 0c             	shr    $0xc,%edx
  800e03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0a:	f6 c2 01             	test   $0x1,%dl
  800e0d:	74 1a                	je     800e29 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e12:	89 02                	mov    %eax,(%edx)
	return 0;
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
  800e19:	eb 13                	jmp    800e2e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e20:	eb 0c                	jmp    800e2e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e27:	eb 05                	jmp    800e2e <fd_lookup+0x54>
  800e29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 08             	sub    $0x8,%esp
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	ba c8 22 80 00       	mov    $0x8022c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e3e:	eb 13                	jmp    800e53 <dev_lookup+0x23>
  800e40:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e43:	39 08                	cmp    %ecx,(%eax)
  800e45:	75 0c                	jne    800e53 <dev_lookup+0x23>
			*dev = devtab[i];
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e51:	eb 2e                	jmp    800e81 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e53:	8b 02                	mov    (%edx),%eax
  800e55:	85 c0                	test   %eax,%eax
  800e57:	75 e7                	jne    800e40 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e59:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5e:	8b 40 50             	mov    0x50(%eax),%eax
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	51                   	push   %ecx
  800e65:	50                   	push   %eax
  800e66:	68 4c 22 80 00       	push   $0x80224c
  800e6b:	e8 37 f3 ff ff       	call   8001a7 <cprintf>
	*dev = 0;
  800e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 10             	sub    $0x10,%esp
  800e8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e94:	50                   	push   %eax
  800e95:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e9b:	c1 e8 0c             	shr    $0xc,%eax
  800e9e:	50                   	push   %eax
  800e9f:	e8 36 ff ff ff       	call   800dda <fd_lookup>
  800ea4:	83 c4 08             	add    $0x8,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	78 05                	js     800eb0 <fd_close+0x2d>
	    || fd != fd2)
  800eab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eae:	74 0c                	je     800ebc <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb0:	84 db                	test   %bl,%bl
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	0f 44 c2             	cmove  %edx,%eax
  800eba:	eb 41                	jmp    800efd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec2:	50                   	push   %eax
  800ec3:	ff 36                	pushl  (%esi)
  800ec5:	e8 66 ff ff ff       	call   800e30 <dev_lookup>
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	78 1a                	js     800eed <fd_close+0x6a>
		if (dev->dev_close)
  800ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	74 0b                	je     800eed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	56                   	push   %esi
  800ee6:	ff d0                	call   *%eax
  800ee8:	89 c3                	mov    %eax,%ebx
  800eea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eed:	83 ec 08             	sub    $0x8,%esp
  800ef0:	56                   	push   %esi
  800ef1:	6a 00                	push   $0x0
  800ef3:	e8 bc fc ff ff       	call   800bb4 <sys_page_unmap>
	return r;
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	89 d8                	mov    %ebx,%eax
}
  800efd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	ff 75 08             	pushl  0x8(%ebp)
  800f11:	e8 c4 fe ff ff       	call   800dda <fd_lookup>
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 10                	js     800f2d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f1d:	83 ec 08             	sub    $0x8,%esp
  800f20:	6a 01                	push   $0x1
  800f22:	ff 75 f4             	pushl  -0xc(%ebp)
  800f25:	e8 59 ff ff ff       	call   800e83 <fd_close>
  800f2a:	83 c4 10             	add    $0x10,%esp
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <close_all>:

void
close_all(void)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	53                   	push   %ebx
  800f3f:	e8 c0 ff ff ff       	call   800f04 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f44:	83 c3 01             	add    $0x1,%ebx
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	83 fb 20             	cmp    $0x20,%ebx
  800f4d:	75 ec                	jne    800f3b <close_all+0xc>
		close(i);
}
  800f4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 2c             	sub    $0x2c,%esp
  800f5d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	ff 75 08             	pushl  0x8(%ebp)
  800f67:	e8 6e fe ff ff       	call   800dda <fd_lookup>
  800f6c:	83 c4 08             	add    $0x8,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	0f 88 c1 00 00 00    	js     801038 <dup+0xe4>
		return r;
	close(newfdnum);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	56                   	push   %esi
  800f7b:	e8 84 ff ff ff       	call   800f04 <close>

	newfd = INDEX2FD(newfdnum);
  800f80:	89 f3                	mov    %esi,%ebx
  800f82:	c1 e3 0c             	shl    $0xc,%ebx
  800f85:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f8b:	83 c4 04             	add    $0x4,%esp
  800f8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f91:	e8 de fd ff ff       	call   800d74 <fd2data>
  800f96:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f98:	89 1c 24             	mov    %ebx,(%esp)
  800f9b:	e8 d4 fd ff ff       	call   800d74 <fd2data>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fa6:	89 f8                	mov    %edi,%eax
  800fa8:	c1 e8 16             	shr    $0x16,%eax
  800fab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb2:	a8 01                	test   $0x1,%al
  800fb4:	74 37                	je     800fed <dup+0x99>
  800fb6:	89 f8                	mov    %edi,%eax
  800fb8:	c1 e8 0c             	shr    $0xc,%eax
  800fbb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc2:	f6 c2 01             	test   $0x1,%dl
  800fc5:	74 26                	je     800fed <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd6:	50                   	push   %eax
  800fd7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fda:	6a 00                	push   $0x0
  800fdc:	57                   	push   %edi
  800fdd:	6a 00                	push   $0x0
  800fdf:	e8 8e fb ff ff       	call   800b72 <sys_page_map>
  800fe4:	89 c7                	mov    %eax,%edi
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 2e                	js     80101b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff0:	89 d0                	mov    %edx,%eax
  800ff2:	c1 e8 0c             	shr    $0xc,%eax
  800ff5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	25 07 0e 00 00       	and    $0xe07,%eax
  801004:	50                   	push   %eax
  801005:	53                   	push   %ebx
  801006:	6a 00                	push   $0x0
  801008:	52                   	push   %edx
  801009:	6a 00                	push   $0x0
  80100b:	e8 62 fb ff ff       	call   800b72 <sys_page_map>
  801010:	89 c7                	mov    %eax,%edi
  801012:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801015:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801017:	85 ff                	test   %edi,%edi
  801019:	79 1d                	jns    801038 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	53                   	push   %ebx
  80101f:	6a 00                	push   $0x0
  801021:	e8 8e fb ff ff       	call   800bb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801026:	83 c4 08             	add    $0x8,%esp
  801029:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102c:	6a 00                	push   $0x0
  80102e:	e8 81 fb ff ff       	call   800bb4 <sys_page_unmap>
	return r;
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	89 f8                	mov    %edi,%eax
}
  801038:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	53                   	push   %ebx
  801044:	83 ec 14             	sub    $0x14,%esp
  801047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80104a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	53                   	push   %ebx
  80104f:	e8 86 fd ff ff       	call   800dda <fd_lookup>
  801054:	83 c4 08             	add    $0x8,%esp
  801057:	89 c2                	mov    %eax,%edx
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 6d                	js     8010ca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801063:	50                   	push   %eax
  801064:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801067:	ff 30                	pushl  (%eax)
  801069:	e8 c2 fd ff ff       	call   800e30 <dev_lookup>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	78 4c                	js     8010c1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801075:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801078:	8b 42 08             	mov    0x8(%edx),%eax
  80107b:	83 e0 03             	and    $0x3,%eax
  80107e:	83 f8 01             	cmp    $0x1,%eax
  801081:	75 21                	jne    8010a4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801083:	a1 04 40 80 00       	mov    0x804004,%eax
  801088:	8b 40 50             	mov    0x50(%eax),%eax
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	53                   	push   %ebx
  80108f:	50                   	push   %eax
  801090:	68 8d 22 80 00       	push   $0x80228d
  801095:	e8 0d f1 ff ff       	call   8001a7 <cprintf>
		return -E_INVAL;
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010a2:	eb 26                	jmp    8010ca <read+0x8a>
	}
	if (!dev->dev_read)
  8010a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a7:	8b 40 08             	mov    0x8(%eax),%eax
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	74 17                	je     8010c5 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	ff 75 10             	pushl  0x10(%ebp)
  8010b4:	ff 75 0c             	pushl  0xc(%ebp)
  8010b7:	52                   	push   %edx
  8010b8:	ff d0                	call   *%eax
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	eb 09                	jmp    8010ca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	eb 05                	jmp    8010ca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e5:	eb 21                	jmp    801108 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010e7:	83 ec 04             	sub    $0x4,%esp
  8010ea:	89 f0                	mov    %esi,%eax
  8010ec:	29 d8                	sub    %ebx,%eax
  8010ee:	50                   	push   %eax
  8010ef:	89 d8                	mov    %ebx,%eax
  8010f1:	03 45 0c             	add    0xc(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	57                   	push   %edi
  8010f6:	e8 45 ff ff ff       	call   801040 <read>
		if (m < 0)
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 10                	js     801112 <readn+0x41>
			return m;
		if (m == 0)
  801102:	85 c0                	test   %eax,%eax
  801104:	74 0a                	je     801110 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801106:	01 c3                	add    %eax,%ebx
  801108:	39 f3                	cmp    %esi,%ebx
  80110a:	72 db                	jb     8010e7 <readn+0x16>
  80110c:	89 d8                	mov    %ebx,%eax
  80110e:	eb 02                	jmp    801112 <readn+0x41>
  801110:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	53                   	push   %ebx
  80111e:	83 ec 14             	sub    $0x14,%esp
  801121:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801124:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	53                   	push   %ebx
  801129:	e8 ac fc ff ff       	call   800dda <fd_lookup>
  80112e:	83 c4 08             	add    $0x8,%esp
  801131:	89 c2                	mov    %eax,%edx
  801133:	85 c0                	test   %eax,%eax
  801135:	78 68                	js     80119f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801137:	83 ec 08             	sub    $0x8,%esp
  80113a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801141:	ff 30                	pushl  (%eax)
  801143:	e8 e8 fc ff ff       	call   800e30 <dev_lookup>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 47                	js     801196 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80114f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801152:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801156:	75 21                	jne    801179 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801158:	a1 04 40 80 00       	mov    0x804004,%eax
  80115d:	8b 40 50             	mov    0x50(%eax),%eax
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	53                   	push   %ebx
  801164:	50                   	push   %eax
  801165:	68 a9 22 80 00       	push   $0x8022a9
  80116a:	e8 38 f0 ff ff       	call   8001a7 <cprintf>
		return -E_INVAL;
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801177:	eb 26                	jmp    80119f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801179:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80117c:	8b 52 0c             	mov    0xc(%edx),%edx
  80117f:	85 d2                	test   %edx,%edx
  801181:	74 17                	je     80119a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	ff 75 10             	pushl  0x10(%ebp)
  801189:	ff 75 0c             	pushl  0xc(%ebp)
  80118c:	50                   	push   %eax
  80118d:	ff d2                	call   *%edx
  80118f:	89 c2                	mov    %eax,%edx
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	eb 09                	jmp    80119f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801196:	89 c2                	mov    %eax,%edx
  801198:	eb 05                	jmp    80119f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80119a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80119f:	89 d0                	mov    %edx,%eax
  8011a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	ff 75 08             	pushl  0x8(%ebp)
  8011b3:	e8 22 fc ff ff       	call   800dda <fd_lookup>
  8011b8:	83 c4 08             	add    $0x8,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 0e                	js     8011cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 14             	sub    $0x14,%esp
  8011d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	53                   	push   %ebx
  8011de:	e8 f7 fb ff ff       	call   800dda <fd_lookup>
  8011e3:	83 c4 08             	add    $0x8,%esp
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 65                	js     801251 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ec:	83 ec 08             	sub    $0x8,%esp
  8011ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	ff 30                	pushl  (%eax)
  8011f8:	e8 33 fc ff ff       	call   800e30 <dev_lookup>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 44                	js     801248 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801207:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120b:	75 21                	jne    80122e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80120d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801212:	8b 40 50             	mov    0x50(%eax),%eax
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	53                   	push   %ebx
  801219:	50                   	push   %eax
  80121a:	68 6c 22 80 00       	push   $0x80226c
  80121f:	e8 83 ef ff ff       	call   8001a7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80122c:	eb 23                	jmp    801251 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80122e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801231:	8b 52 18             	mov    0x18(%edx),%edx
  801234:	85 d2                	test   %edx,%edx
  801236:	74 14                	je     80124c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	ff 75 0c             	pushl  0xc(%ebp)
  80123e:	50                   	push   %eax
  80123f:	ff d2                	call   *%edx
  801241:	89 c2                	mov    %eax,%edx
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	eb 09                	jmp    801251 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	89 c2                	mov    %eax,%edx
  80124a:	eb 05                	jmp    801251 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80124c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801251:	89 d0                	mov    %edx,%eax
  801253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 14             	sub    $0x14,%esp
  80125f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801262:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	ff 75 08             	pushl  0x8(%ebp)
  801269:	e8 6c fb ff ff       	call   800dda <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	89 c2                	mov    %eax,%edx
  801273:	85 c0                	test   %eax,%eax
  801275:	78 58                	js     8012cf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 a8 fb ff ff       	call   800e30 <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 37                	js     8012c6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80128f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801292:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801296:	74 32                	je     8012ca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801298:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80129b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a2:	00 00 00 
	stat->st_isdir = 0;
  8012a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ac:	00 00 00 
	stat->st_dev = dev;
  8012af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012bc:	ff 50 14             	call   *0x14(%eax)
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	eb 09                	jmp    8012cf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	eb 05                	jmp    8012cf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012cf:	89 d0                	mov    %edx,%eax
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	56                   	push   %esi
  8012da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	6a 00                	push   $0x0
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 e3 01 00 00       	call   8014cb <open>
  8012e8:	89 c3                	mov    %eax,%ebx
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 1b                	js     80130c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	ff 75 0c             	pushl  0xc(%ebp)
  8012f7:	50                   	push   %eax
  8012f8:	e8 5b ff ff ff       	call   801258 <fstat>
  8012fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ff:	89 1c 24             	mov    %ebx,(%esp)
  801302:	e8 fd fb ff ff       	call   800f04 <close>
	return r;
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	89 f0                	mov    %esi,%eax
}
  80130c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	56                   	push   %esi
  801317:	53                   	push   %ebx
  801318:	89 c6                	mov    %eax,%esi
  80131a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80131c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801323:	75 12                	jne    801337 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801325:	83 ec 0c             	sub    $0xc,%esp
  801328:	6a 01                	push   $0x1
  80132a:	e8 a7 08 00 00       	call   801bd6 <ipc_find_env>
  80132f:	a3 00 40 80 00       	mov    %eax,0x804000
  801334:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801337:	6a 07                	push   $0x7
  801339:	68 00 50 80 00       	push   $0x805000
  80133e:	56                   	push   %esi
  80133f:	ff 35 00 40 80 00    	pushl  0x804000
  801345:	e8 2a 08 00 00       	call   801b74 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80134a:	83 c4 0c             	add    $0xc,%esp
  80134d:	6a 00                	push   $0x0
  80134f:	53                   	push   %ebx
  801350:	6a 00                	push   $0x0
  801352:	e8 a8 07 00 00       	call   801aff <ipc_recv>
}
  801357:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5e                   	pop    %esi
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	8b 40 0c             	mov    0xc(%eax),%eax
  80136a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80136f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801372:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801377:	ba 00 00 00 00       	mov    $0x0,%edx
  80137c:	b8 02 00 00 00       	mov    $0x2,%eax
  801381:	e8 8d ff ff ff       	call   801313 <fsipc>
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	8b 40 0c             	mov    0xc(%eax),%eax
  801394:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801399:	ba 00 00 00 00       	mov    $0x0,%edx
  80139e:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a3:	e8 6b ff ff ff       	call   801313 <fsipc>
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ba:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c9:	e8 45 ff ff ff       	call   801313 <fsipc>
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 2c                	js     8013fe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	68 00 50 80 00       	push   $0x805000
  8013da:	53                   	push   %ebx
  8013db:	e8 4c f3 ff ff       	call   80072c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e0:	a1 80 50 80 00       	mov    0x805080,%eax
  8013e5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013eb:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140c:	8b 55 08             	mov    0x8(%ebp),%edx
  80140f:	8b 52 0c             	mov    0xc(%edx),%edx
  801412:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801418:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80141d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801422:	0f 47 c2             	cmova  %edx,%eax
  801425:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80142a:	50                   	push   %eax
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	68 08 50 80 00       	push   $0x805008
  801433:	e8 86 f4 ff ff       	call   8008be <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 04 00 00 00       	mov    $0x4,%eax
  801442:	e8 cc fe ff ff       	call   801313 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8b 40 0c             	mov    0xc(%eax),%eax
  801457:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80145c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	b8 03 00 00 00       	mov    $0x3,%eax
  80146c:	e8 a2 fe ff ff       	call   801313 <fsipc>
  801471:	89 c3                	mov    %eax,%ebx
  801473:	85 c0                	test   %eax,%eax
  801475:	78 4b                	js     8014c2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801477:	39 c6                	cmp    %eax,%esi
  801479:	73 16                	jae    801491 <devfile_read+0x48>
  80147b:	68 d8 22 80 00       	push   $0x8022d8
  801480:	68 df 22 80 00       	push   $0x8022df
  801485:	6a 7c                	push   $0x7c
  801487:	68 f4 22 80 00       	push   $0x8022f4
  80148c:	e8 bd 05 00 00       	call   801a4e <_panic>
	assert(r <= PGSIZE);
  801491:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801496:	7e 16                	jle    8014ae <devfile_read+0x65>
  801498:	68 ff 22 80 00       	push   $0x8022ff
  80149d:	68 df 22 80 00       	push   $0x8022df
  8014a2:	6a 7d                	push   $0x7d
  8014a4:	68 f4 22 80 00       	push   $0x8022f4
  8014a9:	e8 a0 05 00 00       	call   801a4e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	50                   	push   %eax
  8014b2:	68 00 50 80 00       	push   $0x805000
  8014b7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ba:	e8 ff f3 ff ff       	call   8008be <memmove>
	return r;
  8014bf:	83 c4 10             	add    $0x10,%esp
}
  8014c2:	89 d8                	mov    %ebx,%eax
  8014c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 20             	sub    $0x20,%esp
  8014d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014d5:	53                   	push   %ebx
  8014d6:	e8 18 f2 ff ff       	call   8006f3 <strlen>
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014e3:	7f 67                	jg     80154c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	e8 9a f8 ff ff       	call   800d8b <fd_alloc>
  8014f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014f4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 57                	js     801551 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	68 00 50 80 00       	push   $0x805000
  801503:	e8 24 f2 ff ff       	call   80072c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801510:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801513:	b8 01 00 00 00       	mov    $0x1,%eax
  801518:	e8 f6 fd ff ff       	call   801313 <fsipc>
  80151d:	89 c3                	mov    %eax,%ebx
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	79 14                	jns    80153a <open+0x6f>
		fd_close(fd, 0);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	6a 00                	push   $0x0
  80152b:	ff 75 f4             	pushl  -0xc(%ebp)
  80152e:	e8 50 f9 ff ff       	call   800e83 <fd_close>
		return r;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	89 da                	mov    %ebx,%edx
  801538:	eb 17                	jmp    801551 <open+0x86>
	}

	return fd2num(fd);
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	ff 75 f4             	pushl  -0xc(%ebp)
  801540:	e8 1f f8 ff ff       	call   800d64 <fd2num>
  801545:	89 c2                	mov    %eax,%edx
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	eb 05                	jmp    801551 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80154c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801551:	89 d0                	mov    %edx,%eax
  801553:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80155e:	ba 00 00 00 00       	mov    $0x0,%edx
  801563:	b8 08 00 00 00       	mov    $0x8,%eax
  801568:	e8 a6 fd ff ff       	call   801313 <fsipc>
}
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
  801574:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	ff 75 08             	pushl  0x8(%ebp)
  80157d:	e8 f2 f7 ff ff       	call   800d74 <fd2data>
  801582:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801584:	83 c4 08             	add    $0x8,%esp
  801587:	68 0b 23 80 00       	push   $0x80230b
  80158c:	53                   	push   %ebx
  80158d:	e8 9a f1 ff ff       	call   80072c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801592:	8b 46 04             	mov    0x4(%esi),%eax
  801595:	2b 06                	sub    (%esi),%eax
  801597:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80159d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a4:	00 00 00 
	stat->st_dev = &devpipe;
  8015a7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015ae:	30 80 00 
	return 0;
}
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5e                   	pop    %esi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015c7:	53                   	push   %ebx
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 e5 f5 ff ff       	call   800bb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015cf:	89 1c 24             	mov    %ebx,(%esp)
  8015d2:	e8 9d f7 ff ff       	call   800d74 <fd2data>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	50                   	push   %eax
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 d2 f5 ff ff       	call   800bb4 <sys_page_unmap>
}
  8015e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	57                   	push   %edi
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 1c             	sub    $0x1c,%esp
  8015f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015f3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015fa:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	ff 75 e0             	pushl  -0x20(%ebp)
  801603:	e8 0e 06 00 00       	call   801c16 <pageref>
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	89 3c 24             	mov    %edi,(%esp)
  80160d:	e8 04 06 00 00       	call   801c16 <pageref>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	39 c3                	cmp    %eax,%ebx
  801617:	0f 94 c1             	sete   %cl
  80161a:	0f b6 c9             	movzbl %cl,%ecx
  80161d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801620:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801626:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801629:	39 ce                	cmp    %ecx,%esi
  80162b:	74 1b                	je     801648 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80162d:	39 c3                	cmp    %eax,%ebx
  80162f:	75 c4                	jne    8015f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801631:	8b 42 60             	mov    0x60(%edx),%eax
  801634:	ff 75 e4             	pushl  -0x1c(%ebp)
  801637:	50                   	push   %eax
  801638:	56                   	push   %esi
  801639:	68 12 23 80 00       	push   $0x802312
  80163e:	e8 64 eb ff ff       	call   8001a7 <cprintf>
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	eb ad                	jmp    8015f5 <_pipeisclosed+0xe>
	}
}
  801648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80164b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	57                   	push   %edi
  801657:	56                   	push   %esi
  801658:	53                   	push   %ebx
  801659:	83 ec 28             	sub    $0x28,%esp
  80165c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80165f:	56                   	push   %esi
  801660:	e8 0f f7 ff ff       	call   800d74 <fd2data>
  801665:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	bf 00 00 00 00       	mov    $0x0,%edi
  80166f:	eb 4b                	jmp    8016bc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801671:	89 da                	mov    %ebx,%edx
  801673:	89 f0                	mov    %esi,%eax
  801675:	e8 6d ff ff ff       	call   8015e7 <_pipeisclosed>
  80167a:	85 c0                	test   %eax,%eax
  80167c:	75 48                	jne    8016c6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80167e:	e8 8d f4 ff ff       	call   800b10 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801683:	8b 43 04             	mov    0x4(%ebx),%eax
  801686:	8b 0b                	mov    (%ebx),%ecx
  801688:	8d 51 20             	lea    0x20(%ecx),%edx
  80168b:	39 d0                	cmp    %edx,%eax
  80168d:	73 e2                	jae    801671 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80168f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801692:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801696:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801699:	89 c2                	mov    %eax,%edx
  80169b:	c1 fa 1f             	sar    $0x1f,%edx
  80169e:	89 d1                	mov    %edx,%ecx
  8016a0:	c1 e9 1b             	shr    $0x1b,%ecx
  8016a3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016a6:	83 e2 1f             	and    $0x1f,%edx
  8016a9:	29 ca                	sub    %ecx,%edx
  8016ab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016b3:	83 c0 01             	add    $0x1,%eax
  8016b6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b9:	83 c7 01             	add    $0x1,%edi
  8016bc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016bf:	75 c2                	jne    801683 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c4:	eb 05                	jmp    8016cb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ce:	5b                   	pop    %ebx
  8016cf:	5e                   	pop    %esi
  8016d0:	5f                   	pop    %edi
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	57                   	push   %edi
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 18             	sub    $0x18,%esp
  8016dc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016df:	57                   	push   %edi
  8016e0:	e8 8f f6 ff ff       	call   800d74 <fd2data>
  8016e5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ef:	eb 3d                	jmp    80172e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016f1:	85 db                	test   %ebx,%ebx
  8016f3:	74 04                	je     8016f9 <devpipe_read+0x26>
				return i;
  8016f5:	89 d8                	mov    %ebx,%eax
  8016f7:	eb 44                	jmp    80173d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016f9:	89 f2                	mov    %esi,%edx
  8016fb:	89 f8                	mov    %edi,%eax
  8016fd:	e8 e5 fe ff ff       	call   8015e7 <_pipeisclosed>
  801702:	85 c0                	test   %eax,%eax
  801704:	75 32                	jne    801738 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801706:	e8 05 f4 ff ff       	call   800b10 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80170b:	8b 06                	mov    (%esi),%eax
  80170d:	3b 46 04             	cmp    0x4(%esi),%eax
  801710:	74 df                	je     8016f1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801712:	99                   	cltd   
  801713:	c1 ea 1b             	shr    $0x1b,%edx
  801716:	01 d0                	add    %edx,%eax
  801718:	83 e0 1f             	and    $0x1f,%eax
  80171b:	29 d0                	sub    %edx,%eax
  80171d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801725:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801728:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172b:	83 c3 01             	add    $0x1,%ebx
  80172e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801731:	75 d8                	jne    80170b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801733:	8b 45 10             	mov    0x10(%ebp),%eax
  801736:	eb 05                	jmp    80173d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80174d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801750:	50                   	push   %eax
  801751:	e8 35 f6 ff ff       	call   800d8b <fd_alloc>
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	89 c2                	mov    %eax,%edx
  80175b:	85 c0                	test   %eax,%eax
  80175d:	0f 88 2c 01 00 00    	js     80188f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	68 07 04 00 00       	push   $0x407
  80176b:	ff 75 f4             	pushl  -0xc(%ebp)
  80176e:	6a 00                	push   $0x0
  801770:	e8 ba f3 ff ff       	call   800b2f <sys_page_alloc>
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	89 c2                	mov    %eax,%edx
  80177a:	85 c0                	test   %eax,%eax
  80177c:	0f 88 0d 01 00 00    	js     80188f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801788:	50                   	push   %eax
  801789:	e8 fd f5 ff ff       	call   800d8b <fd_alloc>
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	85 c0                	test   %eax,%eax
  801795:	0f 88 e2 00 00 00    	js     80187d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	68 07 04 00 00       	push   $0x407
  8017a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a6:	6a 00                	push   $0x0
  8017a8:	e8 82 f3 ff ff       	call   800b2f <sys_page_alloc>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	0f 88 c3 00 00 00    	js     80187d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017ba:	83 ec 0c             	sub    $0xc,%esp
  8017bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c0:	e8 af f5 ff ff       	call   800d74 <fd2data>
  8017c5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c7:	83 c4 0c             	add    $0xc,%esp
  8017ca:	68 07 04 00 00       	push   $0x407
  8017cf:	50                   	push   %eax
  8017d0:	6a 00                	push   $0x0
  8017d2:	e8 58 f3 ff ff       	call   800b2f <sys_page_alloc>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	0f 88 89 00 00 00    	js     80186d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ea:	e8 85 f5 ff ff       	call   800d74 <fd2data>
  8017ef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017f6:	50                   	push   %eax
  8017f7:	6a 00                	push   $0x0
  8017f9:	56                   	push   %esi
  8017fa:	6a 00                	push   $0x0
  8017fc:	e8 71 f3 ff ff       	call   800b72 <sys_page_map>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	83 c4 20             	add    $0x20,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 55                	js     80185f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80180a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801813:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801815:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801818:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80181f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801828:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80182a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801834:	83 ec 0c             	sub    $0xc,%esp
  801837:	ff 75 f4             	pushl  -0xc(%ebp)
  80183a:	e8 25 f5 ff ff       	call   800d64 <fd2num>
  80183f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801842:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801844:	83 c4 04             	add    $0x4,%esp
  801847:	ff 75 f0             	pushl  -0x10(%ebp)
  80184a:	e8 15 f5 ff ff       	call   800d64 <fd2num>
  80184f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801852:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	eb 30                	jmp    80188f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80185f:	83 ec 08             	sub    $0x8,%esp
  801862:	56                   	push   %esi
  801863:	6a 00                	push   $0x0
  801865:	e8 4a f3 ff ff       	call   800bb4 <sys_page_unmap>
  80186a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	ff 75 f0             	pushl  -0x10(%ebp)
  801873:	6a 00                	push   $0x0
  801875:	e8 3a f3 ff ff       	call   800bb4 <sys_page_unmap>
  80187a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	ff 75 f4             	pushl  -0xc(%ebp)
  801883:	6a 00                	push   $0x0
  801885:	e8 2a f3 ff ff       	call   800bb4 <sys_page_unmap>
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80188f:	89 d0                	mov    %edx,%eax
  801891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80189e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a1:	50                   	push   %eax
  8018a2:	ff 75 08             	pushl  0x8(%ebp)
  8018a5:	e8 30 f5 ff ff       	call   800dda <fd_lookup>
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 18                	js     8018c9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018b1:	83 ec 0c             	sub    $0xc,%esp
  8018b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b7:	e8 b8 f4 ff ff       	call   800d74 <fd2data>
	return _pipeisclosed(fd, p);
  8018bc:	89 c2                	mov    %eax,%edx
  8018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c1:	e8 21 fd ff ff       	call   8015e7 <_pipeisclosed>
  8018c6:	83 c4 10             	add    $0x10,%esp
}
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018db:	68 2a 23 80 00       	push   $0x80232a
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	e8 44 ee ff ff       	call   80072c <strcpy>
	return 0;
}
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	57                   	push   %edi
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018fb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801900:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801906:	eb 2d                	jmp    801935 <devcons_write+0x46>
		m = n - tot;
  801908:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80190b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80190d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801910:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801915:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	53                   	push   %ebx
  80191c:	03 45 0c             	add    0xc(%ebp),%eax
  80191f:	50                   	push   %eax
  801920:	57                   	push   %edi
  801921:	e8 98 ef ff ff       	call   8008be <memmove>
		sys_cputs(buf, m);
  801926:	83 c4 08             	add    $0x8,%esp
  801929:	53                   	push   %ebx
  80192a:	57                   	push   %edi
  80192b:	e8 43 f1 ff ff       	call   800a73 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801930:	01 de                	add    %ebx,%esi
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	89 f0                	mov    %esi,%eax
  801937:	3b 75 10             	cmp    0x10(%ebp),%esi
  80193a:	72 cc                	jb     801908 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80193c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80194f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801953:	74 2a                	je     80197f <devcons_read+0x3b>
  801955:	eb 05                	jmp    80195c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801957:	e8 b4 f1 ff ff       	call   800b10 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80195c:	e8 30 f1 ff ff       	call   800a91 <sys_cgetc>
  801961:	85 c0                	test   %eax,%eax
  801963:	74 f2                	je     801957 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801965:	85 c0                	test   %eax,%eax
  801967:	78 16                	js     80197f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801969:	83 f8 04             	cmp    $0x4,%eax
  80196c:	74 0c                	je     80197a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80196e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801971:	88 02                	mov    %al,(%edx)
	return 1;
  801973:	b8 01 00 00 00       	mov    $0x1,%eax
  801978:	eb 05                	jmp    80197f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80198d:	6a 01                	push   $0x1
  80198f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	e8 db f0 ff ff       	call   800a73 <sys_cputs>
}
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <getchar>:

int
getchar(void)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019a3:	6a 01                	push   $0x1
  8019a5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019a8:	50                   	push   %eax
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 90 f6 ff ff       	call   801040 <read>
	if (r < 0)
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 0f                	js     8019c6 <getchar+0x29>
		return r;
	if (r < 1)
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	7e 06                	jle    8019c1 <getchar+0x24>
		return -E_EOF;
	return c;
  8019bb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019bf:	eb 05                	jmp    8019c6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019c1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d1:	50                   	push   %eax
  8019d2:	ff 75 08             	pushl  0x8(%ebp)
  8019d5:	e8 00 f4 ff ff       	call   800dda <fd_lookup>
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 11                	js     8019f2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ea:	39 10                	cmp    %edx,(%eax)
  8019ec:	0f 94 c0             	sete   %al
  8019ef:	0f b6 c0             	movzbl %al,%eax
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <opencons>:

int
opencons(void)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	e8 88 f3 ff ff       	call   800d8b <fd_alloc>
  801a03:	83 c4 10             	add    $0x10,%esp
		return r;
  801a06:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 3e                	js     801a4a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a0c:	83 ec 04             	sub    $0x4,%esp
  801a0f:	68 07 04 00 00       	push   $0x407
  801a14:	ff 75 f4             	pushl  -0xc(%ebp)
  801a17:	6a 00                	push   $0x0
  801a19:	e8 11 f1 ff ff       	call   800b2f <sys_page_alloc>
  801a1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a21:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 23                	js     801a4a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a27:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a30:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a35:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	50                   	push   %eax
  801a40:	e8 1f f3 ff ff       	call   800d64 <fd2num>
  801a45:	89 c2                	mov    %eax,%edx
  801a47:	83 c4 10             	add    $0x10,%esp
}
  801a4a:	89 d0                	mov    %edx,%eax
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	56                   	push   %esi
  801a52:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a53:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a56:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a5c:	e8 90 f0 ff ff       	call   800af1 <sys_getenvid>
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	ff 75 0c             	pushl  0xc(%ebp)
  801a67:	ff 75 08             	pushl  0x8(%ebp)
  801a6a:	56                   	push   %esi
  801a6b:	50                   	push   %eax
  801a6c:	68 38 23 80 00       	push   $0x802338
  801a71:	e8 31 e7 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a76:	83 c4 18             	add    $0x18,%esp
  801a79:	53                   	push   %ebx
  801a7a:	ff 75 10             	pushl  0x10(%ebp)
  801a7d:	e8 d4 e6 ff ff       	call   800156 <vcprintf>
	cprintf("\n");
  801a82:	c7 04 24 23 23 80 00 	movl   $0x802323,(%esp)
  801a89:	e8 19 e7 ff ff       	call   8001a7 <cprintf>
  801a8e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a91:	cc                   	int3   
  801a92:	eb fd                	jmp    801a91 <_panic+0x43>

00801a94 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a9a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801aa1:	75 2a                	jne    801acd <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	6a 07                	push   $0x7
  801aa8:	68 00 f0 bf ee       	push   $0xeebff000
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 7b f0 ff ff       	call   800b2f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	79 12                	jns    801acd <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801abb:	50                   	push   %eax
  801abc:	68 5c 23 80 00       	push   $0x80235c
  801ac1:	6a 23                	push   $0x23
  801ac3:	68 60 23 80 00       	push   $0x802360
  801ac8:	e8 81 ff ff ff       	call   801a4e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ad5:	83 ec 08             	sub    $0x8,%esp
  801ad8:	68 40 0d 80 00       	push   $0x800d40
  801add:	6a 00                	push   $0x0
  801adf:	e8 96 f1 ff ff       	call   800c7a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	79 12                	jns    801afd <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801aeb:	50                   	push   %eax
  801aec:	68 5c 23 80 00       	push   $0x80235c
  801af1:	6a 2c                	push   $0x2c
  801af3:	68 60 23 80 00       	push   $0x802360
  801af8:	e8 51 ff ff ff       	call   801a4e <_panic>
	}
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	8b 75 08             	mov    0x8(%ebp),%esi
  801b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	75 12                	jne    801b23 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	68 00 00 c0 ee       	push   $0xeec00000
  801b19:	e8 c1 f1 ff ff       	call   800cdf <sys_ipc_recv>
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	eb 0c                	jmp    801b2f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	50                   	push   %eax
  801b27:	e8 b3 f1 ff ff       	call   800cdf <sys_ipc_recv>
  801b2c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b2f:	85 f6                	test   %esi,%esi
  801b31:	0f 95 c1             	setne  %cl
  801b34:	85 db                	test   %ebx,%ebx
  801b36:	0f 95 c2             	setne  %dl
  801b39:	84 d1                	test   %dl,%cl
  801b3b:	74 09                	je     801b46 <ipc_recv+0x47>
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	c1 ea 1f             	shr    $0x1f,%edx
  801b42:	84 d2                	test   %dl,%dl
  801b44:	75 27                	jne    801b6d <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b46:	85 f6                	test   %esi,%esi
  801b48:	74 0a                	je     801b54 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801b52:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b54:	85 db                	test   %ebx,%ebx
  801b56:	74 0d                	je     801b65 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801b58:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801b63:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b65:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6a:	8b 40 78             	mov    0x78(%eax),%eax
}
  801b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b80:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b86:	85 db                	test   %ebx,%ebx
  801b88:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b8d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b90:	ff 75 14             	pushl  0x14(%ebp)
  801b93:	53                   	push   %ebx
  801b94:	56                   	push   %esi
  801b95:	57                   	push   %edi
  801b96:	e8 21 f1 ff ff       	call   800cbc <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b9b:	89 c2                	mov    %eax,%edx
  801b9d:	c1 ea 1f             	shr    $0x1f,%edx
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	84 d2                	test   %dl,%dl
  801ba5:	74 17                	je     801bbe <ipc_send+0x4a>
  801ba7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801baa:	74 12                	je     801bbe <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801bac:	50                   	push   %eax
  801bad:	68 6e 23 80 00       	push   $0x80236e
  801bb2:	6a 47                	push   $0x47
  801bb4:	68 7c 23 80 00       	push   $0x80237c
  801bb9:	e8 90 fe ff ff       	call   801a4e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801bbe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bc1:	75 07                	jne    801bca <ipc_send+0x56>
			sys_yield();
  801bc3:	e8 48 ef ff ff       	call   800b10 <sys_yield>
  801bc8:	eb c6                	jmp    801b90 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	75 c2                	jne    801b90 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801be1:	89 c2                	mov    %eax,%edx
  801be3:	c1 e2 07             	shl    $0x7,%edx
  801be6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801bed:	8b 52 58             	mov    0x58(%edx),%edx
  801bf0:	39 ca                	cmp    %ecx,%edx
  801bf2:	75 11                	jne    801c05 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	c1 e2 07             	shl    $0x7,%edx
  801bf9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801c00:	8b 40 50             	mov    0x50(%eax),%eax
  801c03:	eb 0f                	jmp    801c14 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c05:	83 c0 01             	add    $0x1,%eax
  801c08:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c0d:	75 d2                	jne    801be1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1c:	89 d0                	mov    %edx,%eax
  801c1e:	c1 e8 16             	shr    $0x16,%eax
  801c21:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c28:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c2d:	f6 c1 01             	test   $0x1,%cl
  801c30:	74 1d                	je     801c4f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c32:	c1 ea 0c             	shr    $0xc,%edx
  801c35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c3c:	f6 c2 01             	test   $0x1,%dl
  801c3f:	74 0e                	je     801c4f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c41:	c1 ea 0c             	shr    $0xc,%edx
  801c44:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c4b:	ef 
  801c4c:	0f b7 c0             	movzwl %ax,%eax
}
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    
  801c51:	66 90                	xchg   %ax,%ax
  801c53:	66 90                	xchg   %ax,%ax
  801c55:	66 90                	xchg   %ax,%ax
  801c57:	66 90                	xchg   %ax,%ax
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__udivdi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 f6                	test   %esi,%esi
  801c79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7d:	89 ca                	mov    %ecx,%edx
  801c7f:	89 f8                	mov    %edi,%eax
  801c81:	75 3d                	jne    801cc0 <__udivdi3+0x60>
  801c83:	39 cf                	cmp    %ecx,%edi
  801c85:	0f 87 c5 00 00 00    	ja     801d50 <__udivdi3+0xf0>
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	89 fd                	mov    %edi,%ebp
  801c8f:	75 0b                	jne    801c9c <__udivdi3+0x3c>
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	31 d2                	xor    %edx,%edx
  801c98:	f7 f7                	div    %edi
  801c9a:	89 c5                	mov    %eax,%ebp
  801c9c:	89 c8                	mov    %ecx,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	f7 f5                	div    %ebp
  801ca2:	89 c1                	mov    %eax,%ecx
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	89 cf                	mov    %ecx,%edi
  801ca8:	f7 f5                	div    %ebp
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	39 ce                	cmp    %ecx,%esi
  801cc2:	77 74                	ja     801d38 <__udivdi3+0xd8>
  801cc4:	0f bd fe             	bsr    %esi,%edi
  801cc7:	83 f7 1f             	xor    $0x1f,%edi
  801cca:	0f 84 98 00 00 00    	je     801d68 <__udivdi3+0x108>
  801cd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	89 c5                	mov    %eax,%ebp
  801cd9:	29 fb                	sub    %edi,%ebx
  801cdb:	d3 e6                	shl    %cl,%esi
  801cdd:	89 d9                	mov    %ebx,%ecx
  801cdf:	d3 ed                	shr    %cl,%ebp
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	d3 e0                	shl    %cl,%eax
  801ce5:	09 ee                	or     %ebp,%esi
  801ce7:	89 d9                	mov    %ebx,%ecx
  801ce9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ced:	89 d5                	mov    %edx,%ebp
  801cef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cf3:	d3 ed                	shr    %cl,%ebp
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e2                	shl    %cl,%edx
  801cf9:	89 d9                	mov    %ebx,%ecx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	09 c2                	or     %eax,%edx
  801cff:	89 d0                	mov    %edx,%eax
  801d01:	89 ea                	mov    %ebp,%edx
  801d03:	f7 f6                	div    %esi
  801d05:	89 d5                	mov    %edx,%ebp
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	f7 64 24 0c          	mull   0xc(%esp)
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	72 10                	jb     801d21 <__udivdi3+0xc1>
  801d11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e6                	shl    %cl,%esi
  801d19:	39 c6                	cmp    %eax,%esi
  801d1b:	73 07                	jae    801d24 <__udivdi3+0xc4>
  801d1d:	39 d5                	cmp    %edx,%ebp
  801d1f:	75 03                	jne    801d24 <__udivdi3+0xc4>
  801d21:	83 eb 01             	sub    $0x1,%ebx
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 d8                	mov    %ebx,%eax
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	31 db                	xor    %ebx,%ebx
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	83 c4 1c             	add    $0x1c,%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
  801d48:	90                   	nop
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	f7 f7                	div    %edi
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 fa                	mov    %edi,%edx
  801d5c:	83 c4 1c             	add    $0x1c,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5f                   	pop    %edi
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    
  801d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d68:	39 ce                	cmp    %ecx,%esi
  801d6a:	72 0c                	jb     801d78 <__udivdi3+0x118>
  801d6c:	31 db                	xor    %ebx,%ebx
  801d6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d72:	0f 87 34 ff ff ff    	ja     801cac <__udivdi3+0x4c>
  801d78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d7d:	e9 2a ff ff ff       	jmp    801cac <__udivdi3+0x4c>
  801d82:	66 90                	xchg   %ax,%ax
  801d84:	66 90                	xchg   %ax,%ax
  801d86:	66 90                	xchg   %ax,%ax
  801d88:	66 90                	xchg   %ax,%ax
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	85 d2                	test   %edx,%edx
  801da9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db1:	89 f3                	mov    %esi,%ebx
  801db3:	89 3c 24             	mov    %edi,(%esp)
  801db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dba:	75 1c                	jne    801dd8 <__umoddi3+0x48>
  801dbc:	39 f7                	cmp    %esi,%edi
  801dbe:	76 50                	jbe    801e10 <__umoddi3+0x80>
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	f7 f7                	div    %edi
  801dc6:	89 d0                	mov    %edx,%eax
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	83 c4 1c             	add    $0x1c,%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
  801dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	77 52                	ja     801e30 <__umoddi3+0xa0>
  801dde:	0f bd ea             	bsr    %edx,%ebp
  801de1:	83 f5 1f             	xor    $0x1f,%ebp
  801de4:	75 5a                	jne    801e40 <__umoddi3+0xb0>
  801de6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	39 0c 24             	cmp    %ecx,(%esp)
  801df3:	0f 86 d7 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801df9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	85 ff                	test   %edi,%edi
  801e12:	89 fd                	mov    %edi,%ebp
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 c8                	mov    %ecx,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	eb 99                	jmp    801dc8 <__umoddi3+0x38>
  801e2f:	90                   	nop
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	83 c4 1c             	add    $0x1c,%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    
  801e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e40:	8b 34 24             	mov    (%esp),%esi
  801e43:	bf 20 00 00 00       	mov    $0x20,%edi
  801e48:	89 e9                	mov    %ebp,%ecx
  801e4a:	29 ef                	sub    %ebp,%edi
  801e4c:	d3 e0                	shl    %cl,%eax
  801e4e:	89 f9                	mov    %edi,%ecx
  801e50:	89 f2                	mov    %esi,%edx
  801e52:	d3 ea                	shr    %cl,%edx
  801e54:	89 e9                	mov    %ebp,%ecx
  801e56:	09 c2                	or     %eax,%edx
  801e58:	89 d8                	mov    %ebx,%eax
  801e5a:	89 14 24             	mov    %edx,(%esp)
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	d3 e2                	shl    %cl,%edx
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	89 c6                	mov    %eax,%esi
  801e71:	d3 e3                	shl    %cl,%ebx
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 d0                	mov    %edx,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	09 d8                	or     %ebx,%eax
  801e7d:	89 d3                	mov    %edx,%ebx
  801e7f:	89 f2                	mov    %esi,%edx
  801e81:	f7 34 24             	divl   (%esp)
  801e84:	89 d6                	mov    %edx,%esi
  801e86:	d3 e3                	shl    %cl,%ebx
  801e88:	f7 64 24 04          	mull   0x4(%esp)
  801e8c:	39 d6                	cmp    %edx,%esi
  801e8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e92:	89 d1                	mov    %edx,%ecx
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	72 08                	jb     801ea0 <__umoddi3+0x110>
  801e98:	75 11                	jne    801eab <__umoddi3+0x11b>
  801e9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e9e:	73 0b                	jae    801eab <__umoddi3+0x11b>
  801ea0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ea4:	1b 14 24             	sbb    (%esp),%edx
  801ea7:	89 d1                	mov    %edx,%ecx
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eaf:	29 da                	sub    %ebx,%edx
  801eb1:	19 ce                	sbb    %ecx,%esi
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	89 f0                	mov    %esi,%eax
  801eb7:	d3 e0                	shl    %cl,%eax
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	d3 ea                	shr    %cl,%edx
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	d3 ee                	shr    %cl,%esi
  801ec1:	09 d0                	or     %edx,%eax
  801ec3:	89 f2                	mov    %esi,%edx
  801ec5:	83 c4 1c             	add    $0x1c,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 f9                	sub    %edi,%ecx
  801ed2:	19 d6                	sbb    %edx,%esi
  801ed4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801edc:	e9 18 ff ff ff       	jmp    801df9 <__umoddi3+0x69>
