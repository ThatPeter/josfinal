
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 60 1e 80 00       	push   $0x801e60
  800056:	e8 58 01 00 00       	call   8001b3 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	57                   	push   %edi
  800064:	56                   	push   %esi
  800065:	53                   	push   %ebx
  800066:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800069:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800070:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800073:	e8 85 0a 00 00       	call   800afd <sys_getenvid>
  800078:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	50                   	push   %eax
  80007e:	68 70 1e 80 00       	push   $0x801e70
  800083:	e8 2b 01 00 00       	call   8001b3 <cprintf>
  800088:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  80008e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000a0:	89 c1                	mov    %eax,%ecx
  8000a2:	c1 e1 07             	shl    $0x7,%ecx
  8000a5:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000ac:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000af:	39 cb                	cmp    %ecx,%ebx
  8000b1:	0f 44 fa             	cmove  %edx,%edi
  8000b4:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000b9:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000bc:	83 c0 01             	add    $0x1,%eax
  8000bf:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000c5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000ca:	75 d4                	jne    8000a0 <libmain+0x40>
  8000cc:	89 f0                	mov    %esi,%eax
  8000ce:	84 c0                	test   %al,%al
  8000d0:	74 06                	je     8000d8 <libmain+0x78>
  8000d2:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000dc:	7e 0a                	jle    8000e8 <libmain+0x88>
		binaryname = argv[0];
  8000de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e1:	8b 00                	mov    (%eax),%eax
  8000e3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	ff 75 0c             	pushl  0xc(%ebp)
  8000ee:	ff 75 08             	pushl  0x8(%ebp)
  8000f1:	e8 3d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f6:	e8 0b 00 00 00       	call   800106 <exit>
}
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010c:	e8 06 0e 00 00       	call   800f17 <close_all>
	sys_env_destroy(0);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	6a 00                	push   $0x0
  800116:	e8 a1 09 00 00       	call   800abc <sys_env_destroy>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	75 1a                	jne    800159 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	68 ff 00 00 00       	push   $0xff
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 2f 09 00 00       	call   800a7f <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800156:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800159:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800172:	00 00 00 
	b.cnt = 0;
  800175:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017f:	ff 75 0c             	pushl  0xc(%ebp)
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018b:	50                   	push   %eax
  80018c:	68 20 01 80 00       	push   $0x800120
  800191:	e8 54 01 00 00       	call   8002ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800196:	83 c4 08             	add    $0x8,%esp
  800199:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 d4 08 00 00       	call   800a7f <sys_cputs>

	return b.cnt;
}
  8001ab:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bc:	50                   	push   %eax
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	e8 9d ff ff ff       	call   800162 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 1c             	sub    $0x1c,%esp
  8001d0:	89 c7                	mov    %eax,%edi
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001eb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ee:	39 d3                	cmp    %edx,%ebx
  8001f0:	72 05                	jb     8001f7 <printnum+0x30>
  8001f2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f5:	77 45                	ja     80023c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	ff 75 18             	pushl  0x18(%ebp)
  8001fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800200:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020d:	ff 75 e0             	pushl  -0x20(%ebp)
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	e8 b5 19 00 00       	call   801bd0 <__udivdi3>
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	52                   	push   %edx
  80021f:	50                   	push   %eax
  800220:	89 f2                	mov    %esi,%edx
  800222:	89 f8                	mov    %edi,%eax
  800224:	e8 9e ff ff ff       	call   8001c7 <printnum>
  800229:	83 c4 20             	add    $0x20,%esp
  80022c:	eb 18                	jmp    800246 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	56                   	push   %esi
  800232:	ff 75 18             	pushl  0x18(%ebp)
  800235:	ff d7                	call   *%edi
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	eb 03                	jmp    80023f <printnum+0x78>
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023f:	83 eb 01             	sub    $0x1,%ebx
  800242:	85 db                	test   %ebx,%ebx
  800244:	7f e8                	jg     80022e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	56                   	push   %esi
  80024a:	83 ec 04             	sub    $0x4,%esp
  80024d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800250:	ff 75 e0             	pushl  -0x20(%ebp)
  800253:	ff 75 dc             	pushl  -0x24(%ebp)
  800256:	ff 75 d8             	pushl  -0x28(%ebp)
  800259:	e8 a2 1a 00 00       	call   801d00 <__umoddi3>
  80025e:	83 c4 14             	add    $0x14,%esp
  800261:	0f be 80 99 1e 80 00 	movsbl 0x801e99(%eax),%eax
  800268:	50                   	push   %eax
  800269:	ff d7                	call   *%edi
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	88 02                	mov    %al,(%edx)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d6:	50                   	push   %eax
  8002d7:	ff 75 10             	pushl  0x10(%ebp)
  8002da:	ff 75 0c             	pushl  0xc(%ebp)
  8002dd:	ff 75 08             	pushl  0x8(%ebp)
  8002e0:	e8 05 00 00 00       	call   8002ea <vprintfmt>
	va_end(ap);
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 2c             	sub    $0x2c,%esp
  8002f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fc:	eb 12                	jmp    800310 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fe:	85 c0                	test   %eax,%eax
  800300:	0f 84 89 03 00 00    	je     80068f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	53                   	push   %ebx
  80030a:	50                   	push   %eax
  80030b:	ff d6                	call   *%esi
  80030d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800310:	83 c7 01             	add    $0x1,%edi
  800313:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800317:	83 f8 25             	cmp    $0x25,%eax
  80031a:	75 e2                	jne    8002fe <vprintfmt+0x14>
  80031c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800320:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800327:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800335:	ba 00 00 00 00       	mov    $0x0,%edx
  80033a:	eb 07                	jmp    800343 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8d 47 01             	lea    0x1(%edi),%eax
  800346:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800349:	0f b6 07             	movzbl (%edi),%eax
  80034c:	0f b6 c8             	movzbl %al,%ecx
  80034f:	83 e8 23             	sub    $0x23,%eax
  800352:	3c 55                	cmp    $0x55,%al
  800354:	0f 87 1a 03 00 00    	ja     800674 <vprintfmt+0x38a>
  80035a:	0f b6 c0             	movzbl %al,%eax
  80035d:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800367:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036b:	eb d6                	jmp    800343 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800370:	b8 00 00 00 00       	mov    $0x0,%eax
  800375:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800378:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800382:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800385:	83 fa 09             	cmp    $0x9,%edx
  800388:	77 39                	ja     8003c3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038d:	eb e9                	jmp    800378 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038f:	8b 45 14             	mov    0x14(%ebp),%eax
  800392:	8d 48 04             	lea    0x4(%eax),%ecx
  800395:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a0:	eb 27                	jmp    8003c9 <vprintfmt+0xdf>
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ac:	0f 49 c8             	cmovns %eax,%ecx
  8003af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	eb 8c                	jmp    800343 <vprintfmt+0x59>
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c1:	eb 80                	jmp    800343 <vprintfmt+0x59>
  8003c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cd:	0f 89 70 ff ff ff    	jns    800343 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e0:	e9 5e ff ff ff       	jmp    800343 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003eb:	e9 53 ff ff ff       	jmp    800343 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	53                   	push   %ebx
  8003fd:	ff 30                	pushl  (%eax)
  8003ff:	ff d6                	call   *%esi
			break;
  800401:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800407:	e9 04 ff ff ff       	jmp    800310 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	99                   	cltd   
  800418:	31 d0                	xor    %edx,%eax
  80041a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041c:	83 f8 0f             	cmp    $0xf,%eax
  80041f:	7f 0b                	jg     80042c <vprintfmt+0x142>
  800421:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800428:	85 d2                	test   %edx,%edx
  80042a:	75 18                	jne    800444 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042c:	50                   	push   %eax
  80042d:	68 b1 1e 80 00       	push   $0x801eb1
  800432:	53                   	push   %ebx
  800433:	56                   	push   %esi
  800434:	e8 94 fe ff ff       	call   8002cd <printfmt>
  800439:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043f:	e9 cc fe ff ff       	jmp    800310 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800444:	52                   	push   %edx
  800445:	68 71 22 80 00       	push   $0x802271
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 7c fe ff ff       	call   8002cd <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	e9 b4 fe ff ff       	jmp    800310 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800467:	85 ff                	test   %edi,%edi
  800469:	b8 aa 1e 80 00       	mov    $0x801eaa,%eax
  80046e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800475:	0f 8e 94 00 00 00    	jle    80050f <vprintfmt+0x225>
  80047b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047f:	0f 84 98 00 00 00    	je     80051d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 d0             	pushl  -0x30(%ebp)
  80048b:	57                   	push   %edi
  80048c:	e8 86 02 00 00       	call   800717 <strnlen>
  800491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	eb 0f                	jmp    8004b9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ef 01             	sub    $0x1,%edi
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	7f ed                	jg     8004aa <vprintfmt+0x1c0>
  8004bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c3:	85 c9                	test   %ecx,%ecx
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	0f 49 c1             	cmovns %ecx,%eax
  8004cd:	29 c1                	sub    %eax,%ecx
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	89 cb                	mov    %ecx,%ebx
  8004da:	eb 4d                	jmp    800529 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e0:	74 1b                	je     8004fd <vprintfmt+0x213>
  8004e2:	0f be c0             	movsbl %al,%eax
  8004e5:	83 e8 20             	sub    $0x20,%eax
  8004e8:	83 f8 5e             	cmp    $0x5e,%eax
  8004eb:	76 10                	jbe    8004fd <vprintfmt+0x213>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 0d                	jmp    80050a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	52                   	push   %edx
  800504:	ff 55 08             	call   *0x8(%ebp)
  800507:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	83 eb 01             	sub    $0x1,%ebx
  80050d:	eb 1a                	jmp    800529 <vprintfmt+0x23f>
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051b:	eb 0c                	jmp    800529 <vprintfmt+0x23f>
  80051d:	89 75 08             	mov    %esi,0x8(%ebp)
  800520:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800523:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800526:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800530:	0f be d0             	movsbl %al,%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	74 23                	je     80055a <vprintfmt+0x270>
  800537:	85 f6                	test   %esi,%esi
  800539:	78 a1                	js     8004dc <vprintfmt+0x1f2>
  80053b:	83 ee 01             	sub    $0x1,%esi
  80053e:	79 9c                	jns    8004dc <vprintfmt+0x1f2>
  800540:	89 df                	mov    %ebx,%edi
  800542:	8b 75 08             	mov    0x8(%ebp),%esi
  800545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800548:	eb 18                	jmp    800562 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 20                	push   $0x20
  800550:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	83 ef 01             	sub    $0x1,%edi
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	eb 08                	jmp    800562 <vprintfmt+0x278>
  80055a:	89 df                	mov    %ebx,%edi
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800562:	85 ff                	test   %edi,%edi
  800564:	7f e4                	jg     80054a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800569:	e9 a2 fd ff ff       	jmp    800310 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056e:	83 fa 01             	cmp    $0x1,%edx
  800571:	7e 16                	jle    800589 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 08             	lea    0x8(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 50 04             	mov    0x4(%eax),%edx
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	eb 32                	jmp    8005bb <vprintfmt+0x2d1>
	else if (lflag)
  800589:	85 d2                	test   %edx,%edx
  80058b:	74 18                	je     8005a5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 c1                	mov    %eax,%ecx
  80059d:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a3:	eb 16                	jmp    8005bb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 c1                	mov    %eax,%ecx
  8005b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ca:	79 74                	jns    800640 <vprintfmt+0x356>
				putch('-', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 2d                	push   $0x2d
  8005d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005da:	f7 d8                	neg    %eax
  8005dc:	83 d2 00             	adc    $0x0,%edx
  8005df:	f7 da                	neg    %edx
  8005e1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e9:	eb 55                	jmp    800640 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 83 fc ff ff       	call   800276 <getuint>
			base = 10;
  8005f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f8:	eb 46                	jmp    800640 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 74 fc ff ff       	call   800276 <getuint>
			base = 8;
  800602:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800607:	eb 37                	jmp    800640 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 30                	push   $0x30
  80060f:	ff d6                	call   *%esi
			putch('x', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 78                	push   $0x78
  800617:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800629:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 3b fc ff ff       	call   800276 <getuint>
			base = 16;
  80063b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800647:	57                   	push   %edi
  800648:	ff 75 e0             	pushl  -0x20(%ebp)
  80064b:	51                   	push   %ecx
  80064c:	52                   	push   %edx
  80064d:	50                   	push   %eax
  80064e:	89 da                	mov    %ebx,%edx
  800650:	89 f0                	mov    %esi,%eax
  800652:	e8 70 fb ff ff       	call   8001c7 <printnum>
			break;
  800657:	83 c4 20             	add    $0x20,%esp
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065d:	e9 ae fc ff ff       	jmp    800310 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	51                   	push   %ecx
  800667:	ff d6                	call   *%esi
			break;
  800669:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066f:	e9 9c fc ff ff       	jmp    800310 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 25                	push   $0x25
  80067a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	eb 03                	jmp    800684 <vprintfmt+0x39a>
  800681:	83 ef 01             	sub    $0x1,%edi
  800684:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800688:	75 f7                	jne    800681 <vprintfmt+0x397>
  80068a:	e9 81 fc ff ff       	jmp    800310 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800692:	5b                   	pop    %ebx
  800693:	5e                   	pop    %esi
  800694:	5f                   	pop    %edi
  800695:	5d                   	pop    %ebp
  800696:	c3                   	ret    

00800697 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 18             	sub    $0x18,%esp
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 26                	je     8006de <vsnprintf+0x47>
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	7e 22                	jle    8006de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bc:	ff 75 14             	pushl  0x14(%ebp)
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c5:	50                   	push   %eax
  8006c6:	68 b0 02 80 00       	push   $0x8002b0
  8006cb:	e8 1a fc ff ff       	call   8002ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb 05                	jmp    8006e3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ee:	50                   	push   %eax
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	ff 75 08             	pushl  0x8(%ebp)
  8006f8:	e8 9a ff ff ff       	call   800697 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800705:	b8 00 00 00 00       	mov    $0x0,%eax
  80070a:	eb 03                	jmp    80070f <strlen+0x10>
		n++;
  80070c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800713:	75 f7                	jne    80070c <strlen+0xd>
		n++;
	return n;
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
  800725:	eb 03                	jmp    80072a <strnlen+0x13>
		n++;
  800727:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072a:	39 c2                	cmp    %eax,%edx
  80072c:	74 08                	je     800736 <strnlen+0x1f>
  80072e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800732:	75 f3                	jne    800727 <strnlen+0x10>
  800734:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800742:	89 c2                	mov    %eax,%edx
  800744:	83 c2 01             	add    $0x1,%edx
  800747:	83 c1 01             	add    $0x1,%ecx
  80074a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800751:	84 db                	test   %bl,%bl
  800753:	75 ef                	jne    800744 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800755:	5b                   	pop    %ebx
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075f:	53                   	push   %ebx
  800760:	e8 9a ff ff ff       	call   8006ff <strlen>
  800765:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800768:	ff 75 0c             	pushl  0xc(%ebp)
  80076b:	01 d8                	add    %ebx,%eax
  80076d:	50                   	push   %eax
  80076e:	e8 c5 ff ff ff       	call   800738 <strcpy>
	return dst;
}
  800773:	89 d8                	mov    %ebx,%eax
  800775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	56                   	push   %esi
  80077e:	53                   	push   %ebx
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800785:	89 f3                	mov    %esi,%ebx
  800787:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078a:	89 f2                	mov    %esi,%edx
  80078c:	eb 0f                	jmp    80079d <strncpy+0x23>
		*dst++ = *src;
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	0f b6 01             	movzbl (%ecx),%eax
  800794:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800797:	80 39 01             	cmpb   $0x1,(%ecx)
  80079a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	39 da                	cmp    %ebx,%edx
  80079f:	75 ed                	jne    80078e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	74 21                	je     8007dc <strlcpy+0x35>
  8007bb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bf:	89 f2                	mov    %esi,%edx
  8007c1:	eb 09                	jmp    8007cc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cc:	39 c2                	cmp    %eax,%edx
  8007ce:	74 09                	je     8007d9 <strlcpy+0x32>
  8007d0:	0f b6 19             	movzbl (%ecx),%ebx
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ec                	jne    8007c3 <strlcpy+0x1c>
  8007d7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dc:	29 f0                	sub    %esi,%eax
}
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007eb:	eb 06                	jmp    8007f3 <strcmp+0x11>
		p++, q++;
  8007ed:	83 c1 01             	add    $0x1,%ecx
  8007f0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 04                	je     8007fe <strcmp+0x1c>
  8007fa:	3a 02                	cmp    (%edx),%al
  8007fc:	74 ef                	je     8007ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 c0             	movzbl %al,%eax
  800801:	0f b6 12             	movzbl (%edx),%edx
  800804:	29 d0                	sub    %edx,%eax
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	89 c3                	mov    %eax,%ebx
  800814:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800817:	eb 06                	jmp    80081f <strncmp+0x17>
		n--, p++, q++;
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081f:	39 d8                	cmp    %ebx,%eax
  800821:	74 15                	je     800838 <strncmp+0x30>
  800823:	0f b6 08             	movzbl (%eax),%ecx
  800826:	84 c9                	test   %cl,%cl
  800828:	74 04                	je     80082e <strncmp+0x26>
  80082a:	3a 0a                	cmp    (%edx),%cl
  80082c:	74 eb                	je     800819 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 00             	movzbl (%eax),%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
  800836:	eb 05                	jmp    80083d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083d:	5b                   	pop    %ebx
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084a:	eb 07                	jmp    800853 <strchr+0x13>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 0f                	je     80085f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	0f b6 10             	movzbl (%eax),%edx
  800856:	84 d2                	test   %dl,%dl
  800858:	75 f2                	jne    80084c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 03                	jmp    800870 <strfind+0xf>
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800873:	38 ca                	cmp    %cl,%dl
  800875:	74 04                	je     80087b <strfind+0x1a>
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f2                	jne    80086d <strfind+0xc>
			break;
	return (char *) s;
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 7d 08             	mov    0x8(%ebp),%edi
  800886:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 36                	je     8008c3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800893:	75 28                	jne    8008bd <memset+0x40>
  800895:	f6 c1 03             	test   $0x3,%cl
  800898:	75 23                	jne    8008bd <memset+0x40>
		c &= 0xFF;
  80089a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089e:	89 d3                	mov    %edx,%ebx
  8008a0:	c1 e3 08             	shl    $0x8,%ebx
  8008a3:	89 d6                	mov    %edx,%esi
  8008a5:	c1 e6 18             	shl    $0x18,%esi
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	c1 e0 10             	shl    $0x10,%eax
  8008ad:	09 f0                	or     %esi,%eax
  8008af:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	09 d0                	or     %edx,%eax
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
  8008b8:	fc                   	cld    
  8008b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bb:	eb 06                	jmp    8008c3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	fc                   	cld    
  8008c1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d8:	39 c6                	cmp    %eax,%esi
  8008da:	73 35                	jae    800911 <memmove+0x47>
  8008dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008df:	39 d0                	cmp    %edx,%eax
  8008e1:	73 2e                	jae    800911 <memmove+0x47>
		s += n;
		d += n;
  8008e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	09 fe                	or     %edi,%esi
  8008ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f0:	75 13                	jne    800905 <memmove+0x3b>
  8008f2:	f6 c1 03             	test   $0x3,%cl
  8008f5:	75 0e                	jne    800905 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f7:	83 ef 04             	sub    $0x4,%edi
  8008fa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	fd                   	std    
  800901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800903:	eb 09                	jmp    80090e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800905:	83 ef 01             	sub    $0x1,%edi
  800908:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090b:	fd                   	std    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090e:	fc                   	cld    
  80090f:	eb 1d                	jmp    80092e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800911:	89 f2                	mov    %esi,%edx
  800913:	09 c2                	or     %eax,%edx
  800915:	f6 c2 03             	test   $0x3,%dl
  800918:	75 0f                	jne    800929 <memmove+0x5f>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 0a                	jne    800929 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091f:	c1 e9 02             	shr    $0x2,%ecx
  800922:	89 c7                	mov    %eax,%edi
  800924:	fc                   	cld    
  800925:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800927:	eb 05                	jmp    80092e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	ff 75 0c             	pushl  0xc(%ebp)
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 87 ff ff ff       	call   8008ca <memmove>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c6                	mov    %eax,%esi
  800952:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800955:	eb 1a                	jmp    800971 <memcmp+0x2c>
		if (*s1 != *s2)
  800957:	0f b6 08             	movzbl (%eax),%ecx
  80095a:	0f b6 1a             	movzbl (%edx),%ebx
  80095d:	38 d9                	cmp    %bl,%cl
  80095f:	74 0a                	je     80096b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c1             	movzbl %cl,%eax
  800964:	0f b6 db             	movzbl %bl,%ebx
  800967:	29 d8                	sub    %ebx,%eax
  800969:	eb 0f                	jmp    80097a <memcmp+0x35>
		s1++, s2++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	39 f0                	cmp    %esi,%eax
  800973:	75 e2                	jne    800957 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800985:	89 c1                	mov    %eax,%ecx
  800987:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098e:	eb 0a                	jmp    80099a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800990:	0f b6 10             	movzbl (%eax),%edx
  800993:	39 da                	cmp    %ebx,%edx
  800995:	74 07                	je     80099e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	39 c8                	cmp    %ecx,%eax
  80099c:	72 f2                	jb     800990 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ad:	eb 03                	jmp    8009b2 <strtol+0x11>
		s++;
  8009af:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b2:	0f b6 01             	movzbl (%ecx),%eax
  8009b5:	3c 20                	cmp    $0x20,%al
  8009b7:	74 f6                	je     8009af <strtol+0xe>
  8009b9:	3c 09                	cmp    $0x9,%al
  8009bb:	74 f2                	je     8009af <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bd:	3c 2b                	cmp    $0x2b,%al
  8009bf:	75 0a                	jne    8009cb <strtol+0x2a>
		s++;
  8009c1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c9:	eb 11                	jmp    8009dc <strtol+0x3b>
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d0:	3c 2d                	cmp    $0x2d,%al
  8009d2:	75 08                	jne    8009dc <strtol+0x3b>
		s++, neg = 1;
  8009d4:	83 c1 01             	add    $0x1,%ecx
  8009d7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e2:	75 15                	jne    8009f9 <strtol+0x58>
  8009e4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e7:	75 10                	jne    8009f9 <strtol+0x58>
  8009e9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ed:	75 7c                	jne    800a6b <strtol+0xca>
		s += 2, base = 16;
  8009ef:	83 c1 02             	add    $0x2,%ecx
  8009f2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f7:	eb 16                	jmp    800a0f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	75 12                	jne    800a0f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a02:	80 39 30             	cmpb   $0x30,(%ecx)
  800a05:	75 08                	jne    800a0f <strtol+0x6e>
		s++, base = 8;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a17:	0f b6 11             	movzbl (%ecx),%edx
  800a1a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1d:	89 f3                	mov    %esi,%ebx
  800a1f:	80 fb 09             	cmp    $0x9,%bl
  800a22:	77 08                	ja     800a2c <strtol+0x8b>
			dig = *s - '0';
  800a24:	0f be d2             	movsbl %dl,%edx
  800a27:	83 ea 30             	sub    $0x30,%edx
  800a2a:	eb 22                	jmp    800a4e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2f:	89 f3                	mov    %esi,%ebx
  800a31:	80 fb 19             	cmp    $0x19,%bl
  800a34:	77 08                	ja     800a3e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a36:	0f be d2             	movsbl %dl,%edx
  800a39:	83 ea 57             	sub    $0x57,%edx
  800a3c:	eb 10                	jmp    800a4e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a41:	89 f3                	mov    %esi,%ebx
  800a43:	80 fb 19             	cmp    $0x19,%bl
  800a46:	77 16                	ja     800a5e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a48:	0f be d2             	movsbl %dl,%edx
  800a4b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a51:	7d 0b                	jge    800a5e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5c:	eb b9                	jmp    800a17 <strtol+0x76>

	if (endptr)
  800a5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a62:	74 0d                	je     800a71 <strtol+0xd0>
		*endptr = (char *) s;
  800a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a67:	89 0e                	mov    %ecx,(%esi)
  800a69:	eb 06                	jmp    800a71 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6b:	85 db                	test   %ebx,%ebx
  800a6d:	74 98                	je     800a07 <strtol+0x66>
  800a6f:	eb 9e                	jmp    800a0f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	f7 da                	neg    %edx
  800a75:	85 ff                	test   %edi,%edi
  800a77:	0f 45 c2             	cmovne %edx,%eax
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a90:	89 c3                	mov    %eax,%ebx
  800a92:	89 c7                	mov    %eax,%edi
  800a94:	89 c6                	mov    %eax,%esi
  800a96:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa8:	b8 01 00 00 00       	mov    $0x1,%eax
  800aad:	89 d1                	mov    %edx,%ecx
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	89 d7                	mov    %edx,%edi
  800ab3:	89 d6                	mov    %edx,%esi
  800ab5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aca:	b8 03 00 00 00       	mov    $0x3,%eax
  800acf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad2:	89 cb                	mov    %ecx,%ebx
  800ad4:	89 cf                	mov    %ecx,%edi
  800ad6:	89 ce                	mov    %ecx,%esi
  800ad8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ada:	85 c0                	test   %eax,%eax
  800adc:	7e 17                	jle    800af5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	50                   	push   %eax
  800ae2:	6a 03                	push   $0x3
  800ae4:	68 9f 21 80 00       	push   $0x80219f
  800ae9:	6a 23                	push   $0x23
  800aeb:	68 bc 21 80 00       	push   $0x8021bc
  800af0:	e8 41 0f 00 00       	call   801a36 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_yield>:

void
sys_yield(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	be 00 00 00 00       	mov    $0x0,%esi
  800b49:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b57:	89 f7                	mov    %esi,%edi
  800b59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 17                	jle    800b76 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 04                	push   $0x4
  800b65:	68 9f 21 80 00       	push   $0x80219f
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 bc 21 80 00       	push   $0x8021bc
  800b71:	e8 c0 0e 00 00       	call   801a36 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b98:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 05                	push   $0x5
  800ba7:	68 9f 21 80 00       	push   $0x80219f
  800bac:	6a 23                	push   $0x23
  800bae:	68 bc 21 80 00       	push   $0x8021bc
  800bb3:	e8 7e 0e 00 00       	call   801a36 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bce:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 df                	mov    %ebx,%edi
  800bdb:	89 de                	mov    %ebx,%esi
  800bdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 17                	jle    800bfa <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	50                   	push   %eax
  800be7:	6a 06                	push   $0x6
  800be9:	68 9f 21 80 00       	push   $0x80219f
  800bee:	6a 23                	push   $0x23
  800bf0:	68 bc 21 80 00       	push   $0x8021bc
  800bf5:	e8 3c 0e 00 00       	call   801a36 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c10:	b8 08 00 00 00       	mov    $0x8,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	89 df                	mov    %ebx,%edi
  800c1d:	89 de                	mov    %ebx,%esi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 08                	push   $0x8
  800c2b:	68 9f 21 80 00       	push   $0x80219f
  800c30:	6a 23                	push   $0x23
  800c32:	68 bc 21 80 00       	push   $0x8021bc
  800c37:	e8 fa 0d 00 00       	call   801a36 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 09 00 00 00       	mov    $0x9,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 09                	push   $0x9
  800c6d:	68 9f 21 80 00       	push   $0x80219f
  800c72:	6a 23                	push   $0x23
  800c74:	68 bc 21 80 00       	push   $0x8021bc
  800c79:	e8 b8 0d 00 00       	call   801a36 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 0a                	push   $0xa
  800caf:	68 9f 21 80 00       	push   $0x80219f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 bc 21 80 00       	push   $0x8021bc
  800cbb:	e8 76 0d 00 00       	call   801a36 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 cb                	mov    %ecx,%ebx
  800d03:	89 cf                	mov    %ecx,%edi
  800d05:	89 ce                	mov    %ecx,%esi
  800d07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 17                	jle    800d24 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 0d                	push   $0xd
  800d13:	68 9f 21 80 00       	push   $0x80219f
  800d18:	6a 23                	push   $0x23
  800d1a:	68 bc 21 80 00       	push   $0x8021bc
  800d1f:	e8 12 0d 00 00       	call   801a36 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	05 00 00 00 30       	add    $0x30000000,%eax
  800d57:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	05 00 00 00 30       	add    $0x30000000,%eax
  800d67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	c1 ea 16             	shr    $0x16,%edx
  800d83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8a:	f6 c2 01             	test   $0x1,%dl
  800d8d:	74 11                	je     800da0 <fd_alloc+0x2d>
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	c1 ea 0c             	shr    $0xc,%edx
  800d94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9b:	f6 c2 01             	test   $0x1,%dl
  800d9e:	75 09                	jne    800da9 <fd_alloc+0x36>
			*fd_store = fd;
  800da0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da2:	b8 00 00 00 00       	mov    $0x0,%eax
  800da7:	eb 17                	jmp    800dc0 <fd_alloc+0x4d>
  800da9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db3:	75 c9                	jne    800d7e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dbb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc8:	83 f8 1f             	cmp    $0x1f,%eax
  800dcb:	77 36                	ja     800e03 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcd:	c1 e0 0c             	shl    $0xc,%eax
  800dd0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 16             	shr    $0x16,%edx
  800dda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de1:	f6 c2 01             	test   $0x1,%dl
  800de4:	74 24                	je     800e0a <fd_lookup+0x48>
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 0c             	shr    $0xc,%edx
  800deb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	74 1a                	je     800e11 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfa:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	eb 13                	jmp    800e16 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e08:	eb 0c                	jmp    800e16 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0f:	eb 05                	jmp    800e16 <fd_lookup+0x54>
  800e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e21:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e26:	eb 13                	jmp    800e3b <dev_lookup+0x23>
  800e28:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2b:	39 08                	cmp    %ecx,(%eax)
  800e2d:	75 0c                	jne    800e3b <dev_lookup+0x23>
			*dev = devtab[i];
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	eb 2e                	jmp    800e69 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3b:	8b 02                	mov    (%edx),%eax
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	75 e7                	jne    800e28 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e41:	a1 08 40 80 00       	mov    0x804008,%eax
  800e46:	8b 40 50             	mov    0x50(%eax),%eax
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	51                   	push   %ecx
  800e4d:	50                   	push   %eax
  800e4e:	68 cc 21 80 00       	push   $0x8021cc
  800e53:	e8 5b f3 ff ff       	call   8001b3 <cprintf>
	*dev = 0;
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 10             	sub    $0x10,%esp
  800e73:	8b 75 08             	mov    0x8(%ebp),%esi
  800e76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7c:	50                   	push   %eax
  800e7d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e83:	c1 e8 0c             	shr    $0xc,%eax
  800e86:	50                   	push   %eax
  800e87:	e8 36 ff ff ff       	call   800dc2 <fd_lookup>
  800e8c:	83 c4 08             	add    $0x8,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 05                	js     800e98 <fd_close+0x2d>
	    || fd != fd2)
  800e93:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e96:	74 0c                	je     800ea4 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e98:	84 db                	test   %bl,%bl
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	0f 44 c2             	cmove  %edx,%eax
  800ea2:	eb 41                	jmp    800ee5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eaa:	50                   	push   %eax
  800eab:	ff 36                	pushl  (%esi)
  800ead:	e8 66 ff ff ff       	call   800e18 <dev_lookup>
  800eb2:	89 c3                	mov    %eax,%ebx
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 1a                	js     800ed5 <fd_close+0x6a>
		if (dev->dev_close)
  800ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	74 0b                	je     800ed5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	56                   	push   %esi
  800ece:	ff d0                	call   *%eax
  800ed0:	89 c3                	mov    %eax,%ebx
  800ed2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	56                   	push   %esi
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 e0 fc ff ff       	call   800bc0 <sys_page_unmap>
	return r;
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	89 d8                	mov    %ebx,%eax
}
  800ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef5:	50                   	push   %eax
  800ef6:	ff 75 08             	pushl  0x8(%ebp)
  800ef9:	e8 c4 fe ff ff       	call   800dc2 <fd_lookup>
  800efe:	83 c4 08             	add    $0x8,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 10                	js     800f15 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	6a 01                	push   $0x1
  800f0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0d:	e8 59 ff ff ff       	call   800e6b <fd_close>
  800f12:	83 c4 10             	add    $0x10,%esp
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <close_all>:

void
close_all(void)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	53                   	push   %ebx
  800f1b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	53                   	push   %ebx
  800f27:	e8 c0 ff ff ff       	call   800eec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2c:	83 c3 01             	add    $0x1,%ebx
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	83 fb 20             	cmp    $0x20,%ebx
  800f35:	75 ec                	jne    800f23 <close_all+0xc>
		close(i);
}
  800f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	83 ec 2c             	sub    $0x2c,%esp
  800f45:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f48:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 75 08             	pushl  0x8(%ebp)
  800f4f:	e8 6e fe ff ff       	call   800dc2 <fd_lookup>
  800f54:	83 c4 08             	add    $0x8,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	0f 88 c1 00 00 00    	js     801020 <dup+0xe4>
		return r;
	close(newfdnum);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	56                   	push   %esi
  800f63:	e8 84 ff ff ff       	call   800eec <close>

	newfd = INDEX2FD(newfdnum);
  800f68:	89 f3                	mov    %esi,%ebx
  800f6a:	c1 e3 0c             	shl    $0xc,%ebx
  800f6d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f73:	83 c4 04             	add    $0x4,%esp
  800f76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f79:	e8 de fd ff ff       	call   800d5c <fd2data>
  800f7e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f80:	89 1c 24             	mov    %ebx,(%esp)
  800f83:	e8 d4 fd ff ff       	call   800d5c <fd2data>
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8e:	89 f8                	mov    %edi,%eax
  800f90:	c1 e8 16             	shr    $0x16,%eax
  800f93:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9a:	a8 01                	test   $0x1,%al
  800f9c:	74 37                	je     800fd5 <dup+0x99>
  800f9e:	89 f8                	mov    %edi,%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
  800fa3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800faa:	f6 c2 01             	test   $0x1,%dl
  800fad:	74 26                	je     800fd5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800faf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbe:	50                   	push   %eax
  800fbf:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc2:	6a 00                	push   $0x0
  800fc4:	57                   	push   %edi
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 b2 fb ff ff       	call   800b7e <sys_page_map>
  800fcc:	89 c7                	mov    %eax,%edi
  800fce:	83 c4 20             	add    $0x20,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 2e                	js     801003 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd8:	89 d0                	mov    %edx,%eax
  800fda:	c1 e8 0c             	shr    $0xc,%eax
  800fdd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fec:	50                   	push   %eax
  800fed:	53                   	push   %ebx
  800fee:	6a 00                	push   $0x0
  800ff0:	52                   	push   %edx
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 86 fb ff ff       	call   800b7e <sys_page_map>
  800ff8:	89 c7                	mov    %eax,%edi
  800ffa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ffd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fff:	85 ff                	test   %edi,%edi
  801001:	79 1d                	jns    801020 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	53                   	push   %ebx
  801007:	6a 00                	push   $0x0
  801009:	e8 b2 fb ff ff       	call   800bc0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	ff 75 d4             	pushl  -0x2c(%ebp)
  801014:	6a 00                	push   $0x0
  801016:	e8 a5 fb ff ff       	call   800bc0 <sys_page_unmap>
	return r;
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	89 f8                	mov    %edi,%eax
}
  801020:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801023:	5b                   	pop    %ebx
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	53                   	push   %ebx
  80102c:	83 ec 14             	sub    $0x14,%esp
  80102f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801032:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	53                   	push   %ebx
  801037:	e8 86 fd ff ff       	call   800dc2 <fd_lookup>
  80103c:	83 c4 08             	add    $0x8,%esp
  80103f:	89 c2                	mov    %eax,%edx
  801041:	85 c0                	test   %eax,%eax
  801043:	78 6d                	js     8010b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801045:	83 ec 08             	sub    $0x8,%esp
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104f:	ff 30                	pushl  (%eax)
  801051:	e8 c2 fd ff ff       	call   800e18 <dev_lookup>
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 4c                	js     8010a9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801060:	8b 42 08             	mov    0x8(%edx),%eax
  801063:	83 e0 03             	and    $0x3,%eax
  801066:	83 f8 01             	cmp    $0x1,%eax
  801069:	75 21                	jne    80108c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106b:	a1 08 40 80 00       	mov    0x804008,%eax
  801070:	8b 40 50             	mov    0x50(%eax),%eax
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	53                   	push   %ebx
  801077:	50                   	push   %eax
  801078:	68 0d 22 80 00       	push   $0x80220d
  80107d:	e8 31 f1 ff ff       	call   8001b3 <cprintf>
		return -E_INVAL;
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80108a:	eb 26                	jmp    8010b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80108c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108f:	8b 40 08             	mov    0x8(%eax),%eax
  801092:	85 c0                	test   %eax,%eax
  801094:	74 17                	je     8010ad <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	ff 75 10             	pushl  0x10(%ebp)
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	52                   	push   %edx
  8010a0:	ff d0                	call   *%eax
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	eb 09                	jmp    8010b2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	eb 05                	jmp    8010b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010b2:	89 d0                	mov    %edx,%eax
  8010b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cd:	eb 21                	jmp    8010f0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	89 f0                	mov    %esi,%eax
  8010d4:	29 d8                	sub    %ebx,%eax
  8010d6:	50                   	push   %eax
  8010d7:	89 d8                	mov    %ebx,%eax
  8010d9:	03 45 0c             	add    0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	57                   	push   %edi
  8010de:	e8 45 ff ff ff       	call   801028 <read>
		if (m < 0)
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 10                	js     8010fa <readn+0x41>
			return m;
		if (m == 0)
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	74 0a                	je     8010f8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ee:	01 c3                	add    %eax,%ebx
  8010f0:	39 f3                	cmp    %esi,%ebx
  8010f2:	72 db                	jb     8010cf <readn+0x16>
  8010f4:	89 d8                	mov    %ebx,%eax
  8010f6:	eb 02                	jmp    8010fa <readn+0x41>
  8010f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	53                   	push   %ebx
  801106:	83 ec 14             	sub    $0x14,%esp
  801109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	53                   	push   %ebx
  801111:	e8 ac fc ff ff       	call   800dc2 <fd_lookup>
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	89 c2                	mov    %eax,%edx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 68                	js     801187 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801129:	ff 30                	pushl  (%eax)
  80112b:	e8 e8 fc ff ff       	call   800e18 <dev_lookup>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	78 47                	js     80117e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113e:	75 21                	jne    801161 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801140:	a1 08 40 80 00       	mov    0x804008,%eax
  801145:	8b 40 50             	mov    0x50(%eax),%eax
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	53                   	push   %ebx
  80114c:	50                   	push   %eax
  80114d:	68 29 22 80 00       	push   $0x802229
  801152:	e8 5c f0 ff ff       	call   8001b3 <cprintf>
		return -E_INVAL;
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80115f:	eb 26                	jmp    801187 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801161:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801164:	8b 52 0c             	mov    0xc(%edx),%edx
  801167:	85 d2                	test   %edx,%edx
  801169:	74 17                	je     801182 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	ff 75 10             	pushl  0x10(%ebp)
  801171:	ff 75 0c             	pushl  0xc(%ebp)
  801174:	50                   	push   %eax
  801175:	ff d2                	call   *%edx
  801177:	89 c2                	mov    %eax,%edx
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	eb 09                	jmp    801187 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117e:	89 c2                	mov    %eax,%edx
  801180:	eb 05                	jmp    801187 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801182:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801187:	89 d0                	mov    %edx,%eax
  801189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <seek>:

int
seek(int fdnum, off_t offset)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801194:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	ff 75 08             	pushl  0x8(%ebp)
  80119b:	e8 22 fc ff ff       	call   800dc2 <fd_lookup>
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 0e                	js     8011b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 14             	sub    $0x14,%esp
  8011be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	53                   	push   %ebx
  8011c6:	e8 f7 fb ff ff       	call   800dc2 <fd_lookup>
  8011cb:	83 c4 08             	add    $0x8,%esp
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 65                	js     801239 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	ff 30                	pushl  (%eax)
  8011e0:	e8 33 fc ff ff       	call   800e18 <dev_lookup>
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 44                	js     801230 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f3:	75 21                	jne    801216 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011fa:	8b 40 50             	mov    0x50(%eax),%eax
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	53                   	push   %ebx
  801201:	50                   	push   %eax
  801202:	68 ec 21 80 00       	push   $0x8021ec
  801207:	e8 a7 ef ff ff       	call   8001b3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801214:	eb 23                	jmp    801239 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801216:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801219:	8b 52 18             	mov    0x18(%edx),%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	74 14                	je     801234 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	ff 75 0c             	pushl  0xc(%ebp)
  801226:	50                   	push   %eax
  801227:	ff d2                	call   *%edx
  801229:	89 c2                	mov    %eax,%edx
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	eb 09                	jmp    801239 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801230:	89 c2                	mov    %eax,%edx
  801232:	eb 05                	jmp    801239 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801234:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801239:	89 d0                	mov    %edx,%eax
  80123b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 14             	sub    $0x14,%esp
  801247:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 6c fb ff ff       	call   800dc2 <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	89 c2                	mov    %eax,%edx
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 58                	js     8012b7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	ff 30                	pushl  (%eax)
  80126b:	e8 a8 fb ff ff       	call   800e18 <dev_lookup>
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 37                	js     8012ae <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80127e:	74 32                	je     8012b2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801280:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801283:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128a:	00 00 00 
	stat->st_isdir = 0;
  80128d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801294:	00 00 00 
	stat->st_dev = dev;
  801297:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a4:	ff 50 14             	call   *0x14(%eax)
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	eb 09                	jmp    8012b7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	eb 05                	jmp    8012b7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b7:	89 d0                	mov    %edx,%eax
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	6a 00                	push   $0x0
  8012c8:	ff 75 08             	pushl  0x8(%ebp)
  8012cb:	e8 e3 01 00 00       	call   8014b3 <open>
  8012d0:	89 c3                	mov    %eax,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 1b                	js     8012f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	50                   	push   %eax
  8012e0:	e8 5b ff ff ff       	call   801240 <fstat>
  8012e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e7:	89 1c 24             	mov    %ebx,(%esp)
  8012ea:	e8 fd fb ff ff       	call   800eec <close>
	return r;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	89 f0                	mov    %esi,%eax
}
  8012f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	89 c6                	mov    %eax,%esi
  801302:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801304:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130b:	75 12                	jne    80131f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	6a 01                	push   $0x1
  801312:	e8 3c 08 00 00       	call   801b53 <ipc_find_env>
  801317:	a3 00 40 80 00       	mov    %eax,0x804000
  80131c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131f:	6a 07                	push   $0x7
  801321:	68 00 50 80 00       	push   $0x805000
  801326:	56                   	push   %esi
  801327:	ff 35 00 40 80 00    	pushl  0x804000
  80132d:	e8 bf 07 00 00       	call   801af1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801332:	83 c4 0c             	add    $0xc,%esp
  801335:	6a 00                	push   $0x0
  801337:	53                   	push   %ebx
  801338:	6a 00                	push   $0x0
  80133a:	e8 3d 07 00 00       	call   801a7c <ipc_recv>
}
  80133f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
  80134f:	8b 40 0c             	mov    0xc(%eax),%eax
  801352:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 02 00 00 00       	mov    $0x2,%eax
  801369:	e8 8d ff ff ff       	call   8012fb <fsipc>
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	8b 40 0c             	mov    0xc(%eax),%eax
  80137c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	b8 06 00 00 00       	mov    $0x6,%eax
  80138b:	e8 6b ff ff ff       	call   8012fb <fsipc>
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 04             	sub    $0x4,%esp
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b1:	e8 45 ff ff ff       	call   8012fb <fsipc>
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 2c                	js     8013e6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	68 00 50 80 00       	push   $0x805000
  8013c2:	53                   	push   %ebx
  8013c3:	e8 70 f3 ff ff       	call   800738 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d3:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fa:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801400:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801405:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80140a:	0f 47 c2             	cmova  %edx,%eax
  80140d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801412:	50                   	push   %eax
  801413:	ff 75 0c             	pushl  0xc(%ebp)
  801416:	68 08 50 80 00       	push   $0x805008
  80141b:	e8 aa f4 ff ff       	call   8008ca <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801420:	ba 00 00 00 00       	mov    $0x0,%edx
  801425:	b8 04 00 00 00       	mov    $0x4,%eax
  80142a:	e8 cc fe ff ff       	call   8012fb <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	8b 40 0c             	mov    0xc(%eax),%eax
  80143f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801444:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80144a:	ba 00 00 00 00       	mov    $0x0,%edx
  80144f:	b8 03 00 00 00       	mov    $0x3,%eax
  801454:	e8 a2 fe ff ff       	call   8012fb <fsipc>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 4b                	js     8014aa <devfile_read+0x79>
		return r;
	assert(r <= n);
  80145f:	39 c6                	cmp    %eax,%esi
  801461:	73 16                	jae    801479 <devfile_read+0x48>
  801463:	68 58 22 80 00       	push   $0x802258
  801468:	68 5f 22 80 00       	push   $0x80225f
  80146d:	6a 7c                	push   $0x7c
  80146f:	68 74 22 80 00       	push   $0x802274
  801474:	e8 bd 05 00 00       	call   801a36 <_panic>
	assert(r <= PGSIZE);
  801479:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80147e:	7e 16                	jle    801496 <devfile_read+0x65>
  801480:	68 7f 22 80 00       	push   $0x80227f
  801485:	68 5f 22 80 00       	push   $0x80225f
  80148a:	6a 7d                	push   $0x7d
  80148c:	68 74 22 80 00       	push   $0x802274
  801491:	e8 a0 05 00 00       	call   801a36 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	50                   	push   %eax
  80149a:	68 00 50 80 00       	push   $0x805000
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	e8 23 f4 ff ff       	call   8008ca <memmove>
	return r;
  8014a7:	83 c4 10             	add    $0x10,%esp
}
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014af:	5b                   	pop    %ebx
  8014b0:	5e                   	pop    %esi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 20             	sub    $0x20,%esp
  8014ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014bd:	53                   	push   %ebx
  8014be:	e8 3c f2 ff ff       	call   8006ff <strlen>
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014cb:	7f 67                	jg     801534 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	e8 9a f8 ff ff       	call   800d73 <fd_alloc>
  8014d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014dc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 57                	js     801539 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	53                   	push   %ebx
  8014e6:	68 00 50 80 00       	push   $0x805000
  8014eb:	e8 48 f2 ff ff       	call   800738 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801500:	e8 f6 fd ff ff       	call   8012fb <fsipc>
  801505:	89 c3                	mov    %eax,%ebx
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	79 14                	jns    801522 <open+0x6f>
		fd_close(fd, 0);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	6a 00                	push   $0x0
  801513:	ff 75 f4             	pushl  -0xc(%ebp)
  801516:	e8 50 f9 ff ff       	call   800e6b <fd_close>
		return r;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	89 da                	mov    %ebx,%edx
  801520:	eb 17                	jmp    801539 <open+0x86>
	}

	return fd2num(fd);
  801522:	83 ec 0c             	sub    $0xc,%esp
  801525:	ff 75 f4             	pushl  -0xc(%ebp)
  801528:	e8 1f f8 ff ff       	call   800d4c <fd2num>
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	eb 05                	jmp    801539 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801534:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801539:	89 d0                	mov    %edx,%eax
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 08 00 00 00       	mov    $0x8,%eax
  801550:	e8 a6 fd ff ff       	call   8012fb <fsipc>
}
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	e8 f2 f7 ff ff       	call   800d5c <fd2data>
  80156a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	68 8b 22 80 00       	push   $0x80228b
  801574:	53                   	push   %ebx
  801575:	e8 be f1 ff ff       	call   800738 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80157a:	8b 46 04             	mov    0x4(%esi),%eax
  80157d:	2b 06                	sub    (%esi),%eax
  80157f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801585:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80158c:	00 00 00 
	stat->st_dev = &devpipe;
  80158f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801596:	30 80 00 
	return 0;
}
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
  80159e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015af:	53                   	push   %ebx
  8015b0:	6a 00                	push   $0x0
  8015b2:	e8 09 f6 ff ff       	call   800bc0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b7:	89 1c 24             	mov    %ebx,(%esp)
  8015ba:	e8 9d f7 ff ff       	call   800d5c <fd2data>
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	50                   	push   %eax
  8015c3:	6a 00                	push   $0x0
  8015c5:	e8 f6 f5 ff ff       	call   800bc0 <sys_page_unmap>
}
  8015ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	57                   	push   %edi
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 1c             	sub    $0x1c,%esp
  8015d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015db:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e2:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e5:	83 ec 0c             	sub    $0xc,%esp
  8015e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015eb:	e8 a3 05 00 00       	call   801b93 <pageref>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	89 3c 24             	mov    %edi,(%esp)
  8015f5:	e8 99 05 00 00       	call   801b93 <pageref>
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	39 c3                	cmp    %eax,%ebx
  8015ff:	0f 94 c1             	sete   %cl
  801602:	0f b6 c9             	movzbl %cl,%ecx
  801605:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801608:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80160e:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801611:	39 ce                	cmp    %ecx,%esi
  801613:	74 1b                	je     801630 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801615:	39 c3                	cmp    %eax,%ebx
  801617:	75 c4                	jne    8015dd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801619:	8b 42 60             	mov    0x60(%edx),%eax
  80161c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161f:	50                   	push   %eax
  801620:	56                   	push   %esi
  801621:	68 92 22 80 00       	push   $0x802292
  801626:	e8 88 eb ff ff       	call   8001b3 <cprintf>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb ad                	jmp    8015dd <_pipeisclosed+0xe>
	}
}
  801630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801633:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801636:	5b                   	pop    %ebx
  801637:	5e                   	pop    %esi
  801638:	5f                   	pop    %edi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	57                   	push   %edi
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 28             	sub    $0x28,%esp
  801644:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801647:	56                   	push   %esi
  801648:	e8 0f f7 ff ff       	call   800d5c <fd2data>
  80164d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	bf 00 00 00 00       	mov    $0x0,%edi
  801657:	eb 4b                	jmp    8016a4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801659:	89 da                	mov    %ebx,%edx
  80165b:	89 f0                	mov    %esi,%eax
  80165d:	e8 6d ff ff ff       	call   8015cf <_pipeisclosed>
  801662:	85 c0                	test   %eax,%eax
  801664:	75 48                	jne    8016ae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801666:	e8 b1 f4 ff ff       	call   800b1c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80166b:	8b 43 04             	mov    0x4(%ebx),%eax
  80166e:	8b 0b                	mov    (%ebx),%ecx
  801670:	8d 51 20             	lea    0x20(%ecx),%edx
  801673:	39 d0                	cmp    %edx,%eax
  801675:	73 e2                	jae    801659 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801677:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80167e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801681:	89 c2                	mov    %eax,%edx
  801683:	c1 fa 1f             	sar    $0x1f,%edx
  801686:	89 d1                	mov    %edx,%ecx
  801688:	c1 e9 1b             	shr    $0x1b,%ecx
  80168b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80168e:	83 e2 1f             	and    $0x1f,%edx
  801691:	29 ca                	sub    %ecx,%edx
  801693:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801697:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80169b:	83 c0 01             	add    $0x1,%eax
  80169e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a1:	83 c7 01             	add    $0x1,%edi
  8016a4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a7:	75 c2                	jne    80166b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ac:	eb 05                	jmp    8016b3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 18             	sub    $0x18,%esp
  8016c4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c7:	57                   	push   %edi
  8016c8:	e8 8f f6 ff ff       	call   800d5c <fd2data>
  8016cd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d7:	eb 3d                	jmp    801716 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016d9:	85 db                	test   %ebx,%ebx
  8016db:	74 04                	je     8016e1 <devpipe_read+0x26>
				return i;
  8016dd:	89 d8                	mov    %ebx,%eax
  8016df:	eb 44                	jmp    801725 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e1:	89 f2                	mov    %esi,%edx
  8016e3:	89 f8                	mov    %edi,%eax
  8016e5:	e8 e5 fe ff ff       	call   8015cf <_pipeisclosed>
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	75 32                	jne    801720 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016ee:	e8 29 f4 ff ff       	call   800b1c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f3:	8b 06                	mov    (%esi),%eax
  8016f5:	3b 46 04             	cmp    0x4(%esi),%eax
  8016f8:	74 df                	je     8016d9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016fa:	99                   	cltd   
  8016fb:	c1 ea 1b             	shr    $0x1b,%edx
  8016fe:	01 d0                	add    %edx,%eax
  801700:	83 e0 1f             	and    $0x1f,%eax
  801703:	29 d0                	sub    %edx,%eax
  801705:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80170a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801710:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801713:	83 c3 01             	add    $0x1,%ebx
  801716:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801719:	75 d8                	jne    8016f3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80171b:	8b 45 10             	mov    0x10(%ebp),%eax
  80171e:	eb 05                	jmp    801725 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801720:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801725:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	e8 35 f6 ff ff       	call   800d73 <fd_alloc>
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	89 c2                	mov    %eax,%edx
  801743:	85 c0                	test   %eax,%eax
  801745:	0f 88 2c 01 00 00    	js     801877 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174b:	83 ec 04             	sub    $0x4,%esp
  80174e:	68 07 04 00 00       	push   $0x407
  801753:	ff 75 f4             	pushl  -0xc(%ebp)
  801756:	6a 00                	push   $0x0
  801758:	e8 de f3 ff ff       	call   800b3b <sys_page_alloc>
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	89 c2                	mov    %eax,%edx
  801762:	85 c0                	test   %eax,%eax
  801764:	0f 88 0d 01 00 00    	js     801877 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	e8 fd f5 ff ff       	call   800d73 <fd_alloc>
  801776:	89 c3                	mov    %eax,%ebx
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	0f 88 e2 00 00 00    	js     801865 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801783:	83 ec 04             	sub    $0x4,%esp
  801786:	68 07 04 00 00       	push   $0x407
  80178b:	ff 75 f0             	pushl  -0x10(%ebp)
  80178e:	6a 00                	push   $0x0
  801790:	e8 a6 f3 ff ff       	call   800b3b <sys_page_alloc>
  801795:	89 c3                	mov    %eax,%ebx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	0f 88 c3 00 00 00    	js     801865 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a8:	e8 af f5 ff ff       	call   800d5c <fd2data>
  8017ad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017af:	83 c4 0c             	add    $0xc,%esp
  8017b2:	68 07 04 00 00       	push   $0x407
  8017b7:	50                   	push   %eax
  8017b8:	6a 00                	push   $0x0
  8017ba:	e8 7c f3 ff ff       	call   800b3b <sys_page_alloc>
  8017bf:	89 c3                	mov    %eax,%ebx
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	0f 88 89 00 00 00    	js     801855 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cc:	83 ec 0c             	sub    $0xc,%esp
  8017cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d2:	e8 85 f5 ff ff       	call   800d5c <fd2data>
  8017d7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017de:	50                   	push   %eax
  8017df:	6a 00                	push   $0x0
  8017e1:	56                   	push   %esi
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 95 f3 ff ff       	call   800b7e <sys_page_map>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	83 c4 20             	add    $0x20,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 55                	js     801847 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801807:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801810:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80181c:	83 ec 0c             	sub    $0xc,%esp
  80181f:	ff 75 f4             	pushl  -0xc(%ebp)
  801822:	e8 25 f5 ff ff       	call   800d4c <fd2num>
  801827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80182c:	83 c4 04             	add    $0x4,%esp
  80182f:	ff 75 f0             	pushl  -0x10(%ebp)
  801832:	e8 15 f5 ff ff       	call   800d4c <fd2num>
  801837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	ba 00 00 00 00       	mov    $0x0,%edx
  801845:	eb 30                	jmp    801877 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	56                   	push   %esi
  80184b:	6a 00                	push   $0x0
  80184d:	e8 6e f3 ff ff       	call   800bc0 <sys_page_unmap>
  801852:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	ff 75 f0             	pushl  -0x10(%ebp)
  80185b:	6a 00                	push   $0x0
  80185d:	e8 5e f3 ff ff       	call   800bc0 <sys_page_unmap>
  801862:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	ff 75 f4             	pushl  -0xc(%ebp)
  80186b:	6a 00                	push   $0x0
  80186d:	e8 4e f3 ff ff       	call   800bc0 <sys_page_unmap>
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801877:	89 d0                	mov    %edx,%eax
  801879:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801886:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801889:	50                   	push   %eax
  80188a:	ff 75 08             	pushl  0x8(%ebp)
  80188d:	e8 30 f5 ff ff       	call   800dc2 <fd_lookup>
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	78 18                	js     8018b1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	ff 75 f4             	pushl  -0xc(%ebp)
  80189f:	e8 b8 f4 ff ff       	call   800d5c <fd2data>
	return _pipeisclosed(fd, p);
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a9:	e8 21 fd ff ff       	call   8015cf <_pipeisclosed>
  8018ae:	83 c4 10             	add    $0x10,%esp
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c3:	68 aa 22 80 00       	push   $0x8022aa
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	e8 68 ee ff ff       	call   800738 <strcpy>
	return 0;
}
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	57                   	push   %edi
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ee:	eb 2d                	jmp    80191d <devcons_write+0x46>
		m = n - tot;
  8018f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018fd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	53                   	push   %ebx
  801904:	03 45 0c             	add    0xc(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	57                   	push   %edi
  801909:	e8 bc ef ff ff       	call   8008ca <memmove>
		sys_cputs(buf, m);
  80190e:	83 c4 08             	add    $0x8,%esp
  801911:	53                   	push   %ebx
  801912:	57                   	push   %edi
  801913:	e8 67 f1 ff ff       	call   800a7f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801918:	01 de                	add    %ebx,%esi
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	89 f0                	mov    %esi,%eax
  80191f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801922:	72 cc                	jb     8018f0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801924:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5f                   	pop    %edi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801937:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80193b:	74 2a                	je     801967 <devcons_read+0x3b>
  80193d:	eb 05                	jmp    801944 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80193f:	e8 d8 f1 ff ff       	call   800b1c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801944:	e8 54 f1 ff ff       	call   800a9d <sys_cgetc>
  801949:	85 c0                	test   %eax,%eax
  80194b:	74 f2                	je     80193f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 16                	js     801967 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801951:	83 f8 04             	cmp    $0x4,%eax
  801954:	74 0c                	je     801962 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801956:	8b 55 0c             	mov    0xc(%ebp),%edx
  801959:	88 02                	mov    %al,(%edx)
	return 1;
  80195b:	b8 01 00 00 00       	mov    $0x1,%eax
  801960:	eb 05                	jmp    801967 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801975:	6a 01                	push   $0x1
  801977:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197a:	50                   	push   %eax
  80197b:	e8 ff f0 ff ff       	call   800a7f <sys_cputs>
}
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <getchar>:

int
getchar(void)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80198b:	6a 01                	push   $0x1
  80198d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801990:	50                   	push   %eax
  801991:	6a 00                	push   $0x0
  801993:	e8 90 f6 ff ff       	call   801028 <read>
	if (r < 0)
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 0f                	js     8019ae <getchar+0x29>
		return r;
	if (r < 1)
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	7e 06                	jle    8019a9 <getchar+0x24>
		return -E_EOF;
	return c;
  8019a3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a7:	eb 05                	jmp    8019ae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b9:	50                   	push   %eax
  8019ba:	ff 75 08             	pushl  0x8(%ebp)
  8019bd:	e8 00 f4 ff ff       	call   800dc2 <fd_lookup>
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 11                	js     8019da <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d2:	39 10                	cmp    %edx,(%eax)
  8019d4:	0f 94 c0             	sete   %al
  8019d7:	0f b6 c0             	movzbl %al,%eax
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <opencons>:

int
opencons(void)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e5:	50                   	push   %eax
  8019e6:	e8 88 f3 ff ff       	call   800d73 <fd_alloc>
  8019eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ee:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 3e                	js     801a32 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f4:	83 ec 04             	sub    $0x4,%esp
  8019f7:	68 07 04 00 00       	push   $0x407
  8019fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 35 f1 ff ff       	call   800b3b <sys_page_alloc>
  801a06:	83 c4 10             	add    $0x10,%esp
		return r;
  801a09:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 23                	js     801a32 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a18:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	50                   	push   %eax
  801a28:	e8 1f f3 ff ff       	call   800d4c <fd2num>
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	83 c4 10             	add    $0x10,%esp
}
  801a32:	89 d0                	mov    %edx,%eax
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a3b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a3e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a44:	e8 b4 f0 ff ff       	call   800afd <sys_getenvid>
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 0c             	pushl  0xc(%ebp)
  801a4f:	ff 75 08             	pushl  0x8(%ebp)
  801a52:	56                   	push   %esi
  801a53:	50                   	push   %eax
  801a54:	68 b8 22 80 00       	push   $0x8022b8
  801a59:	e8 55 e7 ff ff       	call   8001b3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a5e:	83 c4 18             	add    $0x18,%esp
  801a61:	53                   	push   %ebx
  801a62:	ff 75 10             	pushl  0x10(%ebp)
  801a65:	e8 f8 e6 ff ff       	call   800162 <vcprintf>
	cprintf("\n");
  801a6a:	c7 04 24 6c 1e 80 00 	movl   $0x801e6c,(%esp)
  801a71:	e8 3d e7 ff ff       	call   8001b3 <cprintf>
  801a76:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a79:	cc                   	int3   
  801a7a:	eb fd                	jmp    801a79 <_panic+0x43>

00801a7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	8b 75 08             	mov    0x8(%ebp),%esi
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	75 12                	jne    801aa0 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	68 00 00 c0 ee       	push   $0xeec00000
  801a96:	e8 50 f2 ff ff       	call   800ceb <sys_ipc_recv>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	eb 0c                	jmp    801aac <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	50                   	push   %eax
  801aa4:	e8 42 f2 ff ff       	call   800ceb <sys_ipc_recv>
  801aa9:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801aac:	85 f6                	test   %esi,%esi
  801aae:	0f 95 c1             	setne  %cl
  801ab1:	85 db                	test   %ebx,%ebx
  801ab3:	0f 95 c2             	setne  %dl
  801ab6:	84 d1                	test   %dl,%cl
  801ab8:	74 09                	je     801ac3 <ipc_recv+0x47>
  801aba:	89 c2                	mov    %eax,%edx
  801abc:	c1 ea 1f             	shr    $0x1f,%edx
  801abf:	84 d2                	test   %dl,%dl
  801ac1:	75 27                	jne    801aea <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ac3:	85 f6                	test   %esi,%esi
  801ac5:	74 0a                	je     801ad1 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ac7:	a1 08 40 80 00       	mov    0x804008,%eax
  801acc:	8b 40 7c             	mov    0x7c(%eax),%eax
  801acf:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ad1:	85 db                	test   %ebx,%ebx
  801ad3:	74 0d                	je     801ae2 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ad5:	a1 08 40 80 00       	mov    0x804008,%eax
  801ada:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ae0:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ae2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ae7:	8b 40 78             	mov    0x78(%eax),%eax
}
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	57                   	push   %edi
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b03:	85 db                	test   %ebx,%ebx
  801b05:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b0a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b0d:	ff 75 14             	pushl  0x14(%ebp)
  801b10:	53                   	push   %ebx
  801b11:	56                   	push   %esi
  801b12:	57                   	push   %edi
  801b13:	e8 b0 f1 ff ff       	call   800cc8 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b18:	89 c2                	mov    %eax,%edx
  801b1a:	c1 ea 1f             	shr    $0x1f,%edx
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	84 d2                	test   %dl,%dl
  801b22:	74 17                	je     801b3b <ipc_send+0x4a>
  801b24:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b27:	74 12                	je     801b3b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b29:	50                   	push   %eax
  801b2a:	68 dc 22 80 00       	push   $0x8022dc
  801b2f:	6a 47                	push   $0x47
  801b31:	68 ea 22 80 00       	push   $0x8022ea
  801b36:	e8 fb fe ff ff       	call   801a36 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b3b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b3e:	75 07                	jne    801b47 <ipc_send+0x56>
			sys_yield();
  801b40:	e8 d7 ef ff ff       	call   800b1c <sys_yield>
  801b45:	eb c6                	jmp    801b0d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b47:	85 c0                	test   %eax,%eax
  801b49:	75 c2                	jne    801b0d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	c1 e2 07             	shl    $0x7,%edx
  801b63:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b6a:	8b 52 58             	mov    0x58(%edx),%edx
  801b6d:	39 ca                	cmp    %ecx,%edx
  801b6f:	75 11                	jne    801b82 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	c1 e2 07             	shl    $0x7,%edx
  801b76:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b7d:	8b 40 50             	mov    0x50(%eax),%eax
  801b80:	eb 0f                	jmp    801b91 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b82:	83 c0 01             	add    $0x1,%eax
  801b85:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8a:	75 d2                	jne    801b5e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b99:	89 d0                	mov    %edx,%eax
  801b9b:	c1 e8 16             	shr    $0x16,%eax
  801b9e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baa:	f6 c1 01             	test   $0x1,%cl
  801bad:	74 1d                	je     801bcc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801baf:	c1 ea 0c             	shr    $0xc,%edx
  801bb2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bb9:	f6 c2 01             	test   $0x1,%dl
  801bbc:	74 0e                	je     801bcc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bbe:	c1 ea 0c             	shr    $0xc,%edx
  801bc1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bc8:	ef 
  801bc9:	0f b7 c0             	movzwl %ax,%eax
}
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    
  801bce:	66 90                	xchg   %ax,%ax

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
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
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
