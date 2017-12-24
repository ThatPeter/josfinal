
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 e6 0a 00 00       	call   800b26 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 f7 0c 00 00       	call   800d55 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 60 1e 80 00       	push   $0x801e60
  80006a:	e8 6d 01 00 00       	call   8001dc <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 71 1e 80 00       	push   $0x801e71
  800083:	e8 54 01 00 00       	call   8001dc <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 2b 0d 00 00       	call   800dc7 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000aa:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000b1:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000b4:	e8 6d 0a 00 00       	call   800b26 <sys_getenvid>
  8000b9:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000bf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000c4:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000ce:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000d1:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000d7:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000da:	39 c8                	cmp    %ecx,%eax
  8000dc:	0f 44 fb             	cmove  %ebx,%edi
  8000df:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000e4:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000e7:	83 c2 01             	add    $0x1,%edx
  8000ea:	83 c3 7c             	add    $0x7c,%ebx
  8000ed:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000f3:	75 d9                	jne    8000ce <libmain+0x2d>
  8000f5:	89 f0                	mov    %esi,%eax
  8000f7:	84 c0                	test   %al,%al
  8000f9:	74 06                	je     800101 <libmain+0x60>
  8000fb:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800101:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800105:	7e 0a                	jle    800111 <libmain+0x70>
		binaryname = argv[0];
  800107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010a:	8b 00                	mov    (%eax),%eax
  80010c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	ff 75 0c             	pushl  0xc(%ebp)
  800117:	ff 75 08             	pushl  0x8(%ebp)
  80011a:	e8 14 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0b 00 00 00       	call   80012f <exit>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800135:	e8 f3 0e 00 00       	call   80102d <close_all>
	sys_env_destroy(0);
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	6a 00                	push   $0x0
  80013f:	e8 a1 09 00 00       	call   800ae5 <sys_env_destroy>
}
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	53                   	push   %ebx
  80014d:	83 ec 04             	sub    $0x4,%esp
  800150:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800153:	8b 13                	mov    (%ebx),%edx
  800155:	8d 42 01             	lea    0x1(%edx),%eax
  800158:	89 03                	mov    %eax,(%ebx)
  80015a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800161:	3d ff 00 00 00       	cmp    $0xff,%eax
  800166:	75 1a                	jne    800182 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	68 ff 00 00 00       	push   $0xff
  800170:	8d 43 08             	lea    0x8(%ebx),%eax
  800173:	50                   	push   %eax
  800174:	e8 2f 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  800179:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800182:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800194:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019b:	00 00 00 
	b.cnt = 0;
  80019e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a8:	ff 75 0c             	pushl  0xc(%ebp)
  8001ab:	ff 75 08             	pushl  0x8(%ebp)
  8001ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b4:	50                   	push   %eax
  8001b5:	68 49 01 80 00       	push   $0x800149
  8001ba:	e8 54 01 00 00       	call   800313 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bf:	83 c4 08             	add    $0x8,%esp
  8001c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ce:	50                   	push   %eax
  8001cf:	e8 d4 08 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  8001d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e5:	50                   	push   %eax
  8001e6:	ff 75 08             	pushl  0x8(%ebp)
  8001e9:	e8 9d ff ff ff       	call   80018b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 1c             	sub    $0x1c,%esp
  8001f9:	89 c7                	mov    %eax,%edi
  8001fb:	89 d6                	mov    %edx,%esi
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	8b 55 0c             	mov    0xc(%ebp),%edx
  800203:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800206:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800209:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800211:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800214:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800217:	39 d3                	cmp    %edx,%ebx
  800219:	72 05                	jb     800220 <printnum+0x30>
  80021b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021e:	77 45                	ja     800265 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	ff 75 18             	pushl  0x18(%ebp)
  800226:	8b 45 14             	mov    0x14(%ebp),%eax
  800229:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80022c:	53                   	push   %ebx
  80022d:	ff 75 10             	pushl  0x10(%ebp)
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	ff 75 e4             	pushl  -0x1c(%ebp)
  800236:	ff 75 e0             	pushl  -0x20(%ebp)
  800239:	ff 75 dc             	pushl  -0x24(%ebp)
  80023c:	ff 75 d8             	pushl  -0x28(%ebp)
  80023f:	e8 8c 19 00 00       	call   801bd0 <__udivdi3>
  800244:	83 c4 18             	add    $0x18,%esp
  800247:	52                   	push   %edx
  800248:	50                   	push   %eax
  800249:	89 f2                	mov    %esi,%edx
  80024b:	89 f8                	mov    %edi,%eax
  80024d:	e8 9e ff ff ff       	call   8001f0 <printnum>
  800252:	83 c4 20             	add    $0x20,%esp
  800255:	eb 18                	jmp    80026f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	56                   	push   %esi
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	ff d7                	call   *%edi
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	eb 03                	jmp    800268 <printnum+0x78>
  800265:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	85 db                	test   %ebx,%ebx
  80026d:	7f e8                	jg     800257 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	56                   	push   %esi
  800273:	83 ec 04             	sub    $0x4,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 79 1a 00 00       	call   801d00 <__umoddi3>
  800287:	83 c4 14             	add    $0x14,%esp
  80028a:	0f be 80 92 1e 80 00 	movsbl 0x801e92(%eax),%eax
  800291:	50                   	push   %eax
  800292:	ff d7                	call   *%edi
}
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a2:	83 fa 01             	cmp    $0x1,%edx
  8002a5:	7e 0e                	jle    8002b5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	8b 52 04             	mov    0x4(%edx),%edx
  8002b3:	eb 22                	jmp    8002d7 <getuint+0x38>
	else if (lflag)
  8002b5:	85 d2                	test   %edx,%edx
  8002b7:	74 10                	je     8002c9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	eb 0e                	jmp    8002d7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e8:	73 0a                	jae    8002f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	88 02                	mov    %al,(%edx)
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ff:	50                   	push   %eax
  800300:	ff 75 10             	pushl  0x10(%ebp)
  800303:	ff 75 0c             	pushl  0xc(%ebp)
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	e8 05 00 00 00       	call   800313 <vprintfmt>
	va_end(ap);
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	c9                   	leave  
  800312:	c3                   	ret    

00800313 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 2c             	sub    $0x2c,%esp
  80031c:	8b 75 08             	mov    0x8(%ebp),%esi
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800322:	8b 7d 10             	mov    0x10(%ebp),%edi
  800325:	eb 12                	jmp    800339 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800327:	85 c0                	test   %eax,%eax
  800329:	0f 84 89 03 00 00    	je     8006b8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	53                   	push   %ebx
  800333:	50                   	push   %eax
  800334:	ff d6                	call   *%esi
  800336:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	83 c7 01             	add    $0x1,%edi
  80033c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800340:	83 f8 25             	cmp    $0x25,%eax
  800343:	75 e2                	jne    800327 <vprintfmt+0x14>
  800345:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800349:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800350:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800357:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
  800363:	eb 07                	jmp    80036c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800368:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8d 47 01             	lea    0x1(%edi),%eax
  80036f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800372:	0f b6 07             	movzbl (%edi),%eax
  800375:	0f b6 c8             	movzbl %al,%ecx
  800378:	83 e8 23             	sub    $0x23,%eax
  80037b:	3c 55                	cmp    $0x55,%al
  80037d:	0f 87 1a 03 00 00    	ja     80069d <vprintfmt+0x38a>
  800383:	0f b6 c0             	movzbl %al,%eax
  800386:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800390:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800394:	eb d6                	jmp    80036c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	b8 00 00 00 00       	mov    $0x0,%eax
  80039e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ab:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ae:	83 fa 09             	cmp    $0x9,%edx
  8003b1:	77 39                	ja     8003ec <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b6:	eb e9                	jmp    8003a1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003be:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c9:	eb 27                	jmp    8003f2 <vprintfmt+0xdf>
  8003cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d5:	0f 49 c8             	cmovns %eax,%ecx
  8003d8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003de:	eb 8c                	jmp    80036c <vprintfmt+0x59>
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ea:	eb 80                	jmp    80036c <vprintfmt+0x59>
  8003ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ef:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f6:	0f 89 70 ff ff ff    	jns    80036c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800402:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800409:	e9 5e ff ff ff       	jmp    80036c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800414:	e9 53 ff ff ff       	jmp    80036c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	53                   	push   %ebx
  800426:	ff 30                	pushl  (%eax)
  800428:	ff d6                	call   *%esi
			break;
  80042a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800430:	e9 04 ff ff ff       	jmp    800339 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	99                   	cltd   
  800441:	31 d0                	xor    %edx,%eax
  800443:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800445:	83 f8 0f             	cmp    $0xf,%eax
  800448:	7f 0b                	jg     800455 <vprintfmt+0x142>
  80044a:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	75 18                	jne    80046d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800455:	50                   	push   %eax
  800456:	68 aa 1e 80 00       	push   $0x801eaa
  80045b:	53                   	push   %ebx
  80045c:	56                   	push   %esi
  80045d:	e8 94 fe ff ff       	call   8002f6 <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800468:	e9 cc fe ff ff       	jmp    800339 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046d:	52                   	push   %edx
  80046e:	68 89 22 80 00       	push   $0x802289
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 7c fe ff ff       	call   8002f6 <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800480:	e9 b4 fe ff ff       	jmp    800339 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800490:	85 ff                	test   %edi,%edi
  800492:	b8 a3 1e 80 00       	mov    $0x801ea3,%eax
  800497:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	0f 8e 94 00 00 00    	jle    800538 <vprintfmt+0x225>
  8004a4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a8:	0f 84 98 00 00 00    	je     800546 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b4:	57                   	push   %edi
  8004b5:	e8 86 02 00 00       	call   800740 <strnlen>
  8004ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bd:	29 c1                	sub    %eax,%ecx
  8004bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	eb 0f                	jmp    8004e2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004da:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	83 ef 01             	sub    $0x1,%edi
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	85 ff                	test   %edi,%edi
  8004e4:	7f ed                	jg     8004d3 <vprintfmt+0x1c0>
  8004e6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ec:	85 c9                	test   %ecx,%ecx
  8004ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f3:	0f 49 c1             	cmovns %ecx,%eax
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800501:	89 cb                	mov    %ecx,%ebx
  800503:	eb 4d                	jmp    800552 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800505:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800509:	74 1b                	je     800526 <vprintfmt+0x213>
  80050b:	0f be c0             	movsbl %al,%eax
  80050e:	83 e8 20             	sub    $0x20,%eax
  800511:	83 f8 5e             	cmp    $0x5e,%eax
  800514:	76 10                	jbe    800526 <vprintfmt+0x213>
					putch('?', putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	6a 3f                	push   $0x3f
  80051e:	ff 55 08             	call   *0x8(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	eb 0d                	jmp    800533 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 0c             	pushl  0xc(%ebp)
  80052c:	52                   	push   %edx
  80052d:	ff 55 08             	call   *0x8(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800533:	83 eb 01             	sub    $0x1,%ebx
  800536:	eb 1a                	jmp    800552 <vprintfmt+0x23f>
  800538:	89 75 08             	mov    %esi,0x8(%ebp)
  80053b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800541:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800544:	eb 0c                	jmp    800552 <vprintfmt+0x23f>
  800546:	89 75 08             	mov    %esi,0x8(%ebp)
  800549:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	0f be d0             	movsbl %al,%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	74 23                	je     800583 <vprintfmt+0x270>
  800560:	85 f6                	test   %esi,%esi
  800562:	78 a1                	js     800505 <vprintfmt+0x1f2>
  800564:	83 ee 01             	sub    $0x1,%esi
  800567:	79 9c                	jns    800505 <vprintfmt+0x1f2>
  800569:	89 df                	mov    %ebx,%edi
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800571:	eb 18                	jmp    80058b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	53                   	push   %ebx
  800577:	6a 20                	push   $0x20
  800579:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	83 ef 01             	sub    $0x1,%edi
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb 08                	jmp    80058b <vprintfmt+0x278>
  800583:	89 df                	mov    %ebx,%edi
  800585:	8b 75 08             	mov    0x8(%ebp),%esi
  800588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058b:	85 ff                	test   %edi,%edi
  80058d:	7f e4                	jg     800573 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800592:	e9 a2 fd ff ff       	jmp    800339 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800597:	83 fa 01             	cmp    $0x1,%edx
  80059a:	7e 16                	jle    8005b2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 08             	lea    0x8(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 50 04             	mov    0x4(%eax),%edx
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b0:	eb 32                	jmp    8005e4 <vprintfmt+0x2d1>
	else if (lflag)
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	74 18                	je     8005ce <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c4:	89 c1                	mov    %eax,%ecx
  8005c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cc:	eb 16                	jmp    8005e4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dc:	89 c1                	mov    %eax,%ecx
  8005de:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f3:	79 74                	jns    800669 <vprintfmt+0x356>
				putch('-', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 2d                	push   $0x2d
  8005fb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800600:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800603:	f7 d8                	neg    %eax
  800605:	83 d2 00             	adc    $0x0,%edx
  800608:	f7 da                	neg    %edx
  80060a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800612:	eb 55                	jmp    800669 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 83 fc ff ff       	call   80029f <getuint>
			base = 10;
  80061c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800621:	eb 46                	jmp    800669 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 74 fc ff ff       	call   80029f <getuint>
			base = 8;
  80062b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800630:	eb 37                	jmp    800669 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 30                	push   $0x30
  800638:	ff d6                	call   *%esi
			putch('x', putdat);
  80063a:	83 c4 08             	add    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 78                	push   $0x78
  800640:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800652:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800655:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80065a:	eb 0d                	jmp    800669 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 3b fc ff ff       	call   80029f <getuint>
			base = 16;
  800664:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800669:	83 ec 0c             	sub    $0xc,%esp
  80066c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800670:	57                   	push   %edi
  800671:	ff 75 e0             	pushl  -0x20(%ebp)
  800674:	51                   	push   %ecx
  800675:	52                   	push   %edx
  800676:	50                   	push   %eax
  800677:	89 da                	mov    %ebx,%edx
  800679:	89 f0                	mov    %esi,%eax
  80067b:	e8 70 fb ff ff       	call   8001f0 <printnum>
			break;
  800680:	83 c4 20             	add    $0x20,%esp
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800686:	e9 ae fc ff ff       	jmp    800339 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	51                   	push   %ecx
  800690:	ff d6                	call   *%esi
			break;
  800692:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800698:	e9 9c fc ff ff       	jmp    800339 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 25                	push   $0x25
  8006a3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	eb 03                	jmp    8006ad <vprintfmt+0x39a>
  8006aa:	83 ef 01             	sub    $0x1,%edi
  8006ad:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b1:	75 f7                	jne    8006aa <vprintfmt+0x397>
  8006b3:	e9 81 fc ff ff       	jmp    800339 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bb:	5b                   	pop    %ebx
  8006bc:	5e                   	pop    %esi
  8006bd:	5f                   	pop    %edi
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	83 ec 18             	sub    $0x18,%esp
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	74 26                	je     800707 <vsnprintf+0x47>
  8006e1:	85 d2                	test   %edx,%edx
  8006e3:	7e 22                	jle    800707 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e5:	ff 75 14             	pushl  0x14(%ebp)
  8006e8:	ff 75 10             	pushl  0x10(%ebp)
  8006eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	68 d9 02 80 00       	push   $0x8002d9
  8006f4:	e8 1a fc ff ff       	call   800313 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 05                	jmp    80070c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    

0080070e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800714:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800717:	50                   	push   %eax
  800718:	ff 75 10             	pushl  0x10(%ebp)
  80071b:	ff 75 0c             	pushl  0xc(%ebp)
  80071e:	ff 75 08             	pushl  0x8(%ebp)
  800721:	e8 9a ff ff ff       	call   8006c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	eb 03                	jmp    800738 <strlen+0x10>
		n++;
  800735:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800738:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073c:	75 f7                	jne    800735 <strlen+0xd>
		n++;
	return n;
}
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800746:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
  80074e:	eb 03                	jmp    800753 <strnlen+0x13>
		n++;
  800750:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800753:	39 c2                	cmp    %eax,%edx
  800755:	74 08                	je     80075f <strnlen+0x1f>
  800757:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80075b:	75 f3                	jne    800750 <strnlen+0x10>
  80075d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	53                   	push   %ebx
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076b:	89 c2                	mov    %eax,%edx
  80076d:	83 c2 01             	add    $0x1,%edx
  800770:	83 c1 01             	add    $0x1,%ecx
  800773:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800777:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077a:	84 db                	test   %bl,%bl
  80077c:	75 ef                	jne    80076d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077e:	5b                   	pop    %ebx
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	53                   	push   %ebx
  800785:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800788:	53                   	push   %ebx
  800789:	e8 9a ff ff ff       	call   800728 <strlen>
  80078e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	01 d8                	add    %ebx,%eax
  800796:	50                   	push   %eax
  800797:	e8 c5 ff ff ff       	call   800761 <strcpy>
	return dst;
}
  80079c:	89 d8                	mov    %ebx,%eax
  80079e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ae:	89 f3                	mov    %esi,%ebx
  8007b0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b3:	89 f2                	mov    %esi,%edx
  8007b5:	eb 0f                	jmp    8007c6 <strncpy+0x23>
		*dst++ = *src;
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	0f b6 01             	movzbl (%ecx),%eax
  8007bd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c6:	39 da                	cmp    %ebx,%edx
  8007c8:	75 ed                	jne    8007b7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ca:	89 f0                	mov    %esi,%eax
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	56                   	push   %esi
  8007d4:	53                   	push   %ebx
  8007d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007db:	8b 55 10             	mov    0x10(%ebp),%edx
  8007de:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	74 21                	je     800805 <strlcpy+0x35>
  8007e4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e8:	89 f2                	mov    %esi,%edx
  8007ea:	eb 09                	jmp    8007f5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	83 c1 01             	add    $0x1,%ecx
  8007f2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f5:	39 c2                	cmp    %eax,%edx
  8007f7:	74 09                	je     800802 <strlcpy+0x32>
  8007f9:	0f b6 19             	movzbl (%ecx),%ebx
  8007fc:	84 db                	test   %bl,%bl
  8007fe:	75 ec                	jne    8007ec <strlcpy+0x1c>
  800800:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800802:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800805:	29 f0                	sub    %esi,%eax
}
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800814:	eb 06                	jmp    80081c <strcmp+0x11>
		p++, q++;
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081c:	0f b6 01             	movzbl (%ecx),%eax
  80081f:	84 c0                	test   %al,%al
  800821:	74 04                	je     800827 <strcmp+0x1c>
  800823:	3a 02                	cmp    (%edx),%al
  800825:	74 ef                	je     800816 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800827:	0f b6 c0             	movzbl %al,%eax
  80082a:	0f b6 12             	movzbl (%edx),%edx
  80082d:	29 d0                	sub    %edx,%eax
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083b:	89 c3                	mov    %eax,%ebx
  80083d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800840:	eb 06                	jmp    800848 <strncmp+0x17>
		n--, p++, q++;
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800848:	39 d8                	cmp    %ebx,%eax
  80084a:	74 15                	je     800861 <strncmp+0x30>
  80084c:	0f b6 08             	movzbl (%eax),%ecx
  80084f:	84 c9                	test   %cl,%cl
  800851:	74 04                	je     800857 <strncmp+0x26>
  800853:	3a 0a                	cmp    (%edx),%cl
  800855:	74 eb                	je     800842 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 00             	movzbl (%eax),%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
  80085f:	eb 05                	jmp    800866 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800873:	eb 07                	jmp    80087c <strchr+0x13>
		if (*s == c)
  800875:	38 ca                	cmp    %cl,%dl
  800877:	74 0f                	je     800888 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	0f b6 10             	movzbl (%eax),%edx
  80087f:	84 d2                	test   %dl,%dl
  800881:	75 f2                	jne    800875 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800894:	eb 03                	jmp    800899 <strfind+0xf>
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 04                	je     8008a4 <strfind+0x1a>
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f2                	jne    800896 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	57                   	push   %edi
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
  8008ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b2:	85 c9                	test   %ecx,%ecx
  8008b4:	74 36                	je     8008ec <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bc:	75 28                	jne    8008e6 <memset+0x40>
  8008be:	f6 c1 03             	test   $0x3,%cl
  8008c1:	75 23                	jne    8008e6 <memset+0x40>
		c &= 0xFF;
  8008c3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c7:	89 d3                	mov    %edx,%ebx
  8008c9:	c1 e3 08             	shl    $0x8,%ebx
  8008cc:	89 d6                	mov    %edx,%esi
  8008ce:	c1 e6 18             	shl    $0x18,%esi
  8008d1:	89 d0                	mov    %edx,%eax
  8008d3:	c1 e0 10             	shl    $0x10,%eax
  8008d6:	09 f0                	or     %esi,%eax
  8008d8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008da:	89 d8                	mov    %ebx,%eax
  8008dc:	09 d0                	or     %edx,%eax
  8008de:	c1 e9 02             	shr    $0x2,%ecx
  8008e1:	fc                   	cld    
  8008e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e4:	eb 06                	jmp    8008ec <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	fc                   	cld    
  8008ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ec:	89 f8                	mov    %edi,%eax
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800901:	39 c6                	cmp    %eax,%esi
  800903:	73 35                	jae    80093a <memmove+0x47>
  800905:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800908:	39 d0                	cmp    %edx,%eax
  80090a:	73 2e                	jae    80093a <memmove+0x47>
		s += n;
		d += n;
  80090c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 d6                	mov    %edx,%esi
  800911:	09 fe                	or     %edi,%esi
  800913:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800919:	75 13                	jne    80092e <memmove+0x3b>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 0e                	jne    80092e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800920:	83 ef 04             	sub    $0x4,%edi
  800923:	8d 72 fc             	lea    -0x4(%edx),%esi
  800926:	c1 e9 02             	shr    $0x2,%ecx
  800929:	fd                   	std    
  80092a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092c:	eb 09                	jmp    800937 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092e:	83 ef 01             	sub    $0x1,%edi
  800931:	8d 72 ff             	lea    -0x1(%edx),%esi
  800934:	fd                   	std    
  800935:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800937:	fc                   	cld    
  800938:	eb 1d                	jmp    800957 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	89 f2                	mov    %esi,%edx
  80093c:	09 c2                	or     %eax,%edx
  80093e:	f6 c2 03             	test   $0x3,%dl
  800941:	75 0f                	jne    800952 <memmove+0x5f>
  800943:	f6 c1 03             	test   $0x3,%cl
  800946:	75 0a                	jne    800952 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800948:	c1 e9 02             	shr    $0x2,%ecx
  80094b:	89 c7                	mov    %eax,%edi
  80094d:	fc                   	cld    
  80094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800950:	eb 05                	jmp    800957 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800952:	89 c7                	mov    %eax,%edi
  800954:	fc                   	cld    
  800955:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095e:	ff 75 10             	pushl  0x10(%ebp)
  800961:	ff 75 0c             	pushl  0xc(%ebp)
  800964:	ff 75 08             	pushl  0x8(%ebp)
  800967:	e8 87 ff ff ff       	call   8008f3 <memmove>
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
  800979:	89 c6                	mov    %eax,%esi
  80097b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	eb 1a                	jmp    80099a <memcmp+0x2c>
		if (*s1 != *s2)
  800980:	0f b6 08             	movzbl (%eax),%ecx
  800983:	0f b6 1a             	movzbl (%edx),%ebx
  800986:	38 d9                	cmp    %bl,%cl
  800988:	74 0a                	je     800994 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80098a:	0f b6 c1             	movzbl %cl,%eax
  80098d:	0f b6 db             	movzbl %bl,%ebx
  800990:	29 d8                	sub    %ebx,%eax
  800992:	eb 0f                	jmp    8009a3 <memcmp+0x35>
		s1++, s2++;
  800994:	83 c0 01             	add    $0x1,%eax
  800997:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	39 f0                	cmp    %esi,%eax
  80099c:	75 e2                	jne    800980 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ae:	89 c1                	mov    %eax,%ecx
  8009b0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b7:	eb 0a                	jmp    8009c3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b9:	0f b6 10             	movzbl (%eax),%edx
  8009bc:	39 da                	cmp    %ebx,%edx
  8009be:	74 07                	je     8009c7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	39 c8                	cmp    %ecx,%eax
  8009c5:	72 f2                	jb     8009b9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d6:	eb 03                	jmp    8009db <strtol+0x11>
		s++;
  8009d8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009db:	0f b6 01             	movzbl (%ecx),%eax
  8009de:	3c 20                	cmp    $0x20,%al
  8009e0:	74 f6                	je     8009d8 <strtol+0xe>
  8009e2:	3c 09                	cmp    $0x9,%al
  8009e4:	74 f2                	je     8009d8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e6:	3c 2b                	cmp    $0x2b,%al
  8009e8:	75 0a                	jne    8009f4 <strtol+0x2a>
		s++;
  8009ea:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f2:	eb 11                	jmp    800a05 <strtol+0x3b>
  8009f4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f9:	3c 2d                	cmp    $0x2d,%al
  8009fb:	75 08                	jne    800a05 <strtol+0x3b>
		s++, neg = 1;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a05:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0b:	75 15                	jne    800a22 <strtol+0x58>
  800a0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a10:	75 10                	jne    800a22 <strtol+0x58>
  800a12:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a16:	75 7c                	jne    800a94 <strtol+0xca>
		s += 2, base = 16;
  800a18:	83 c1 02             	add    $0x2,%ecx
  800a1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a20:	eb 16                	jmp    800a38 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a22:	85 db                	test   %ebx,%ebx
  800a24:	75 12                	jne    800a38 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a26:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2e:	75 08                	jne    800a38 <strtol+0x6e>
		s++, base = 8;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a40:	0f b6 11             	movzbl (%ecx),%edx
  800a43:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	80 fb 09             	cmp    $0x9,%bl
  800a4b:	77 08                	ja     800a55 <strtol+0x8b>
			dig = *s - '0';
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 30             	sub    $0x30,%edx
  800a53:	eb 22                	jmp    800a77 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a55:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	80 fb 19             	cmp    $0x19,%bl
  800a5d:	77 08                	ja     800a67 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 57             	sub    $0x57,%edx
  800a65:	eb 10                	jmp    800a77 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a67:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 19             	cmp    $0x19,%bl
  800a6f:	77 16                	ja     800a87 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a77:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a7a:	7d 0b                	jge    800a87 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a83:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a85:	eb b9                	jmp    800a40 <strtol+0x76>

	if (endptr)
  800a87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8b:	74 0d                	je     800a9a <strtol+0xd0>
		*endptr = (char *) s;
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	89 0e                	mov    %ecx,(%esi)
  800a92:	eb 06                	jmp    800a9a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	74 98                	je     800a30 <strtol+0x66>
  800a98:	eb 9e                	jmp    800a38 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a9a:	89 c2                	mov    %eax,%edx
  800a9c:	f7 da                	neg    %edx
  800a9e:	85 ff                	test   %edi,%edi
  800aa0:	0f 45 c2             	cmovne %edx,%eax
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	b8 03 00 00 00       	mov    $0x3,%eax
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 17                	jle    800b1e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	6a 03                	push   $0x3
  800b0d:	68 9f 21 80 00       	push   $0x80219f
  800b12:	6a 23                	push   $0x23
  800b14:	68 bc 21 80 00       	push   $0x8021bc
  800b19:	e8 2e 10 00 00       	call   801b4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 02 00 00 00       	mov    $0x2,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_yield>:

void
sys_yield(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	be 00 00 00 00       	mov    $0x0,%esi
  800b72:	b8 04 00 00 00       	mov    $0x4,%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	89 f7                	mov    %esi,%edi
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 17                	jle    800b9f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 04                	push   $0x4
  800b8e:	68 9f 21 80 00       	push   $0x80219f
  800b93:	6a 23                	push   $0x23
  800b95:	68 bc 21 80 00       	push   $0x8021bc
  800b9a:	e8 ad 0f 00 00       	call   801b4c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 05                	push   $0x5
  800bd0:	68 9f 21 80 00       	push   $0x80219f
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 bc 21 80 00       	push   $0x8021bc
  800bdc:	e8 6b 0f 00 00       	call   801b4c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800bf7:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c0a:	7e 17                	jle    800c23 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 06                	push   $0x6
  800c12:	68 9f 21 80 00       	push   $0x80219f
  800c17:	6a 23                	push   $0x23
  800c19:	68 bc 21 80 00       	push   $0x8021bc
  800c1e:	e8 29 0f 00 00       	call   801b4c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c39:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c4c:	7e 17                	jle    800c65 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 08                	push   $0x8
  800c54:	68 9f 21 80 00       	push   $0x80219f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 bc 21 80 00       	push   $0x8021bc
  800c60:	e8 e7 0e 00 00       	call   801b4c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c7b:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 09                	push   $0x9
  800c96:	68 9f 21 80 00       	push   $0x80219f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 bc 21 80 00       	push   $0x8021bc
  800ca2:	e8 a5 0e 00 00       	call   801b4c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 0a                	push   $0xa
  800cd8:	68 9f 21 80 00       	push   $0x80219f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 bc 21 80 00       	push   $0x8021bc
  800ce4:	e8 63 0e 00 00       	call   801b4c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	be 00 00 00 00       	mov    $0x0,%esi
  800cfc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 0d                	push   $0xd
  800d3c:	68 9f 21 80 00       	push   $0x80219f
  800d41:	6a 23                	push   $0x23
  800d43:	68 bc 21 80 00       	push   $0x8021bc
  800d48:	e8 ff 0d 00 00       	call   801b4c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  800d63:	85 c0                	test   %eax,%eax
  800d65:	75 12                	jne    800d79 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	68 00 00 c0 ee       	push   $0xeec00000
  800d6f:	e8 a0 ff ff ff       	call   800d14 <sys_ipc_recv>
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	eb 0c                	jmp    800d85 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	e8 92 ff ff ff       	call   800d14 <sys_ipc_recv>
  800d82:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  800d85:	85 f6                	test   %esi,%esi
  800d87:	0f 95 c1             	setne  %cl
  800d8a:	85 db                	test   %ebx,%ebx
  800d8c:	0f 95 c2             	setne  %dl
  800d8f:	84 d1                	test   %dl,%cl
  800d91:	74 09                	je     800d9c <ipc_recv+0x47>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 1f             	shr    $0x1f,%edx
  800d98:	84 d2                	test   %dl,%dl
  800d9a:	75 24                	jne    800dc0 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  800d9c:	85 f6                	test   %esi,%esi
  800d9e:	74 0a                	je     800daa <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  800da0:	a1 04 40 80 00       	mov    0x804004,%eax
  800da5:	8b 40 74             	mov    0x74(%eax),%eax
  800da8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  800daa:	85 db                	test   %ebx,%ebx
  800dac:	74 0a                	je     800db8 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  800dae:	a1 04 40 80 00       	mov    0x804004,%eax
  800db3:	8b 40 78             	mov    0x78(%eax),%eax
  800db6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  800db8:	a1 04 40 80 00       	mov    0x804004,%eax
  800dbd:	8b 40 70             	mov    0x70(%eax),%eax
}
  800dc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  800dd9:	85 db                	test   %ebx,%ebx
  800ddb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800de0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800de3:	ff 75 14             	pushl  0x14(%ebp)
  800de6:	53                   	push   %ebx
  800de7:	56                   	push   %esi
  800de8:	57                   	push   %edi
  800de9:	e8 03 ff ff ff       	call   800cf1 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	c1 ea 1f             	shr    $0x1f,%edx
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	84 d2                	test   %dl,%dl
  800df8:	74 17                	je     800e11 <ipc_send+0x4a>
  800dfa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800dfd:	74 12                	je     800e11 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  800dff:	50                   	push   %eax
  800e00:	68 ca 21 80 00       	push   $0x8021ca
  800e05:	6a 47                	push   $0x47
  800e07:	68 d8 21 80 00       	push   $0x8021d8
  800e0c:	e8 3b 0d 00 00       	call   801b4c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  800e11:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e14:	75 07                	jne    800e1d <ipc_send+0x56>
			sys_yield();
  800e16:	e8 2a fd ff ff       	call   800b45 <sys_yield>
  800e1b:	eb c6                	jmp    800de3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	75 c2                	jne    800de3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e3d:	8b 52 50             	mov    0x50(%edx),%edx
  800e40:	39 ca                	cmp    %ecx,%edx
  800e42:	75 0d                	jne    800e51 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4c:	8b 40 48             	mov    0x48(%eax),%eax
  800e4f:	eb 0f                	jmp    800e60 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e51:	83 c0 01             	add    $0x1,%eax
  800e54:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e59:	75 d9                	jne    800e34 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e82:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 16             	shr    $0x16,%edx
  800e99:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	74 11                	je     800eb6 <fd_alloc+0x2d>
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	c1 ea 0c             	shr    $0xc,%edx
  800eaa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	75 09                	jne    800ebf <fd_alloc+0x36>
			*fd_store = fd;
  800eb6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	eb 17                	jmp    800ed6 <fd_alloc+0x4d>
  800ebf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ec9:	75 c9                	jne    800e94 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ede:	83 f8 1f             	cmp    $0x1f,%eax
  800ee1:	77 36                	ja     800f19 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee3:	c1 e0 0c             	shl    $0xc,%eax
  800ee6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	c1 ea 16             	shr    $0x16,%edx
  800ef0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef7:	f6 c2 01             	test   $0x1,%dl
  800efa:	74 24                	je     800f20 <fd_lookup+0x48>
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	c1 ea 0c             	shr    $0xc,%edx
  800f01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f08:	f6 c2 01             	test   $0x1,%dl
  800f0b:	74 1a                	je     800f27 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f10:	89 02                	mov    %eax,(%edx)
	return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	eb 13                	jmp    800f2c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1e:	eb 0c                	jmp    800f2c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f25:	eb 05                	jmp    800f2c <fd_lookup+0x54>
  800f27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f37:	ba 60 22 80 00       	mov    $0x802260,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3c:	eb 13                	jmp    800f51 <dev_lookup+0x23>
  800f3e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f41:	39 08                	cmp    %ecx,(%eax)
  800f43:	75 0c                	jne    800f51 <dev_lookup+0x23>
			*dev = devtab[i];
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	eb 2e                	jmp    800f7f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f51:	8b 02                	mov    (%edx),%eax
  800f53:	85 c0                	test   %eax,%eax
  800f55:	75 e7                	jne    800f3e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f57:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5c:	8b 40 48             	mov    0x48(%eax),%eax
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	51                   	push   %ecx
  800f63:	50                   	push   %eax
  800f64:	68 e4 21 80 00       	push   $0x8021e4
  800f69:	e8 6e f2 ff ff       	call   8001dc <cprintf>
	*dev = 0;
  800f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 10             	sub    $0x10,%esp
  800f89:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f92:	50                   	push   %eax
  800f93:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f99:	c1 e8 0c             	shr    $0xc,%eax
  800f9c:	50                   	push   %eax
  800f9d:	e8 36 ff ff ff       	call   800ed8 <fd_lookup>
  800fa2:	83 c4 08             	add    $0x8,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 05                	js     800fae <fd_close+0x2d>
	    || fd != fd2)
  800fa9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fac:	74 0c                	je     800fba <fd_close+0x39>
		return (must_exist ? r : 0);
  800fae:	84 db                	test   %bl,%bl
  800fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb5:	0f 44 c2             	cmove  %edx,%eax
  800fb8:	eb 41                	jmp    800ffb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 36                	pushl  (%esi)
  800fc3:	e8 66 ff ff ff       	call   800f2e <dev_lookup>
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 1a                	js     800feb <fd_close+0x6a>
		if (dev->dev_close)
  800fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	74 0b                	je     800feb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	56                   	push   %esi
  800fe4:	ff d0                	call   *%eax
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	56                   	push   %esi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 f3 fb ff ff       	call   800be9 <sys_page_unmap>
	return r;
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	89 d8                	mov    %ebx,%eax
}
  800ffb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 c4 fe ff ff       	call   800ed8 <fd_lookup>
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	78 10                	js     80102b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	6a 01                	push   $0x1
  801020:	ff 75 f4             	pushl  -0xc(%ebp)
  801023:	e8 59 ff ff ff       	call   800f81 <fd_close>
  801028:	83 c4 10             	add    $0x10,%esp
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <close_all>:

void
close_all(void)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	53                   	push   %ebx
  801031:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	53                   	push   %ebx
  80103d:	e8 c0 ff ff ff       	call   801002 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801042:	83 c3 01             	add    $0x1,%ebx
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	83 fb 20             	cmp    $0x20,%ebx
  80104b:	75 ec                	jne    801039 <close_all+0xc>
		close(i);
}
  80104d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 2c             	sub    $0x2c,%esp
  80105b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80105e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 6e fe ff ff       	call   800ed8 <fd_lookup>
  80106a:	83 c4 08             	add    $0x8,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	0f 88 c1 00 00 00    	js     801136 <dup+0xe4>
		return r;
	close(newfdnum);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	56                   	push   %esi
  801079:	e8 84 ff ff ff       	call   801002 <close>

	newfd = INDEX2FD(newfdnum);
  80107e:	89 f3                	mov    %esi,%ebx
  801080:	c1 e3 0c             	shl    $0xc,%ebx
  801083:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801089:	83 c4 04             	add    $0x4,%esp
  80108c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108f:	e8 de fd ff ff       	call   800e72 <fd2data>
  801094:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801096:	89 1c 24             	mov    %ebx,(%esp)
  801099:	e8 d4 fd ff ff       	call   800e72 <fd2data>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a4:	89 f8                	mov    %edi,%eax
  8010a6:	c1 e8 16             	shr    $0x16,%eax
  8010a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b0:	a8 01                	test   $0x1,%al
  8010b2:	74 37                	je     8010eb <dup+0x99>
  8010b4:	89 f8                	mov    %edi,%eax
  8010b6:	c1 e8 0c             	shr    $0xc,%eax
  8010b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c0:	f6 c2 01             	test   $0x1,%dl
  8010c3:	74 26                	je     8010eb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d4:	50                   	push   %eax
  8010d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d8:	6a 00                	push   $0x0
  8010da:	57                   	push   %edi
  8010db:	6a 00                	push   $0x0
  8010dd:	e8 c5 fa ff ff       	call   800ba7 <sys_page_map>
  8010e2:	89 c7                	mov    %eax,%edi
  8010e4:	83 c4 20             	add    $0x20,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 2e                	js     801119 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ee:	89 d0                	mov    %edx,%eax
  8010f0:	c1 e8 0c             	shr    $0xc,%eax
  8010f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801102:	50                   	push   %eax
  801103:	53                   	push   %ebx
  801104:	6a 00                	push   $0x0
  801106:	52                   	push   %edx
  801107:	6a 00                	push   $0x0
  801109:	e8 99 fa ff ff       	call   800ba7 <sys_page_map>
  80110e:	89 c7                	mov    %eax,%edi
  801110:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801113:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801115:	85 ff                	test   %edi,%edi
  801117:	79 1d                	jns    801136 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801119:	83 ec 08             	sub    $0x8,%esp
  80111c:	53                   	push   %ebx
  80111d:	6a 00                	push   $0x0
  80111f:	e8 c5 fa ff ff       	call   800be9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112a:	6a 00                	push   $0x0
  80112c:	e8 b8 fa ff ff       	call   800be9 <sys_page_unmap>
	return r;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	89 f8                	mov    %edi,%eax
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	53                   	push   %ebx
  801142:	83 ec 14             	sub    $0x14,%esp
  801145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801148:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	53                   	push   %ebx
  80114d:	e8 86 fd ff ff       	call   800ed8 <fd_lookup>
  801152:	83 c4 08             	add    $0x8,%esp
  801155:	89 c2                	mov    %eax,%edx
  801157:	85 c0                	test   %eax,%eax
  801159:	78 6d                	js     8011c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	ff 30                	pushl  (%eax)
  801167:	e8 c2 fd ff ff       	call   800f2e <dev_lookup>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 4c                	js     8011bf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801173:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801176:	8b 42 08             	mov    0x8(%edx),%eax
  801179:	83 e0 03             	and    $0x3,%eax
  80117c:	83 f8 01             	cmp    $0x1,%eax
  80117f:	75 21                	jne    8011a2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801181:	a1 04 40 80 00       	mov    0x804004,%eax
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	53                   	push   %ebx
  80118d:	50                   	push   %eax
  80118e:	68 25 22 80 00       	push   $0x802225
  801193:	e8 44 f0 ff ff       	call   8001dc <cprintf>
		return -E_INVAL;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a0:	eb 26                	jmp    8011c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a5:	8b 40 08             	mov    0x8(%eax),%eax
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	74 17                	je     8011c3 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	ff 75 10             	pushl  0x10(%ebp)
  8011b2:	ff 75 0c             	pushl  0xc(%ebp)
  8011b5:	52                   	push   %edx
  8011b6:	ff d0                	call   *%eax
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	eb 09                	jmp    8011c8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	eb 05                	jmp    8011c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011c8:	89 d0                	mov    %edx,%eax
  8011ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	57                   	push   %edi
  8011d3:	56                   	push   %esi
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e3:	eb 21                	jmp    801206 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	89 f0                	mov    %esi,%eax
  8011ea:	29 d8                	sub    %ebx,%eax
  8011ec:	50                   	push   %eax
  8011ed:	89 d8                	mov    %ebx,%eax
  8011ef:	03 45 0c             	add    0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	57                   	push   %edi
  8011f4:	e8 45 ff ff ff       	call   80113e <read>
		if (m < 0)
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 10                	js     801210 <readn+0x41>
			return m;
		if (m == 0)
  801200:	85 c0                	test   %eax,%eax
  801202:	74 0a                	je     80120e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801204:	01 c3                	add    %eax,%ebx
  801206:	39 f3                	cmp    %esi,%ebx
  801208:	72 db                	jb     8011e5 <readn+0x16>
  80120a:	89 d8                	mov    %ebx,%eax
  80120c:	eb 02                	jmp    801210 <readn+0x41>
  80120e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 14             	sub    $0x14,%esp
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	53                   	push   %ebx
  801227:	e8 ac fc ff ff       	call   800ed8 <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	89 c2                	mov    %eax,%edx
  801231:	85 c0                	test   %eax,%eax
  801233:	78 68                	js     80129d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	ff 30                	pushl  (%eax)
  801241:	e8 e8 fc ff ff       	call   800f2e <dev_lookup>
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 47                	js     801294 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801254:	75 21                	jne    801277 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801256:	a1 04 40 80 00       	mov    0x804004,%eax
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	68 41 22 80 00       	push   $0x802241
  801268:	e8 6f ef ff ff       	call   8001dc <cprintf>
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801275:	eb 26                	jmp    80129d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127a:	8b 52 0c             	mov    0xc(%edx),%edx
  80127d:	85 d2                	test   %edx,%edx
  80127f:	74 17                	je     801298 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	ff 75 10             	pushl  0x10(%ebp)
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	50                   	push   %eax
  80128b:	ff d2                	call   *%edx
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	eb 09                	jmp    80129d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	89 c2                	mov    %eax,%edx
  801296:	eb 05                	jmp    80129d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801298:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80129d:	89 d0                	mov    %edx,%eax
  80129f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 75 08             	pushl  0x8(%ebp)
  8012b1:	e8 22 fc ff ff       	call   800ed8 <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 0e                	js     8012cb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 14             	sub    $0x14,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	53                   	push   %ebx
  8012dc:	e8 f7 fb ff ff       	call   800ed8 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	89 c2                	mov    %eax,%edx
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 65                	js     80134f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	ff 30                	pushl  (%eax)
  8012f6:	e8 33 fc ff ff       	call   800f2e <dev_lookup>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 44                	js     801346 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801309:	75 21                	jne    80132c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801310:	8b 40 48             	mov    0x48(%eax),%eax
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	53                   	push   %ebx
  801317:	50                   	push   %eax
  801318:	68 04 22 80 00       	push   $0x802204
  80131d:	e8 ba ee ff ff       	call   8001dc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132a:	eb 23                	jmp    80134f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	8b 52 18             	mov    0x18(%edx),%edx
  801332:	85 d2                	test   %edx,%edx
  801334:	74 14                	je     80134a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	ff 75 0c             	pushl  0xc(%ebp)
  80133c:	50                   	push   %eax
  80133d:	ff d2                	call   *%edx
  80133f:	89 c2                	mov    %eax,%edx
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	eb 09                	jmp    80134f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801346:	89 c2                	mov    %eax,%edx
  801348:	eb 05                	jmp    80134f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80134f:	89 d0                	mov    %edx,%eax
  801351:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 14             	sub    $0x14,%esp
  80135d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	ff 75 08             	pushl  0x8(%ebp)
  801367:	e8 6c fb ff ff       	call   800ed8 <fd_lookup>
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	89 c2                	mov    %eax,%edx
  801371:	85 c0                	test   %eax,%eax
  801373:	78 58                	js     8013cd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137f:	ff 30                	pushl  (%eax)
  801381:	e8 a8 fb ff ff       	call   800f2e <dev_lookup>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 37                	js     8013c4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801390:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801394:	74 32                	je     8013c8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801396:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801399:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a0:	00 00 00 
	stat->st_isdir = 0;
  8013a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013aa:	00 00 00 
	stat->st_dev = dev;
  8013ad:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ba:	ff 50 14             	call   *0x14(%eax)
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	eb 09                	jmp    8013cd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	eb 05                	jmp    8013cd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013cd:	89 d0                	mov    %edx,%eax
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	6a 00                	push   $0x0
  8013de:	ff 75 08             	pushl  0x8(%ebp)
  8013e1:	e8 e3 01 00 00       	call   8015c9 <open>
  8013e6:	89 c3                	mov    %eax,%ebx
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 1b                	js     80140a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	50                   	push   %eax
  8013f6:	e8 5b ff ff ff       	call   801356 <fstat>
  8013fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013fd:	89 1c 24             	mov    %ebx,(%esp)
  801400:	e8 fd fb ff ff       	call   801002 <close>
	return r;
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	89 f0                	mov    %esi,%eax
}
  80140a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	89 c6                	mov    %eax,%esi
  801418:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801421:	75 12                	jne    801435 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	6a 01                	push   $0x1
  801428:	e8 fc f9 ff ff       	call   800e29 <ipc_find_env>
  80142d:	a3 00 40 80 00       	mov    %eax,0x804000
  801432:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801435:	6a 07                	push   $0x7
  801437:	68 00 50 80 00       	push   $0x805000
  80143c:	56                   	push   %esi
  80143d:	ff 35 00 40 80 00    	pushl  0x804000
  801443:	e8 7f f9 ff ff       	call   800dc7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801448:	83 c4 0c             	add    $0xc,%esp
  80144b:	6a 00                	push   $0x0
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	e8 00 f9 ff ff       	call   800d55 <ipc_recv>
}
  801455:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	8b 40 0c             	mov    0xc(%eax),%eax
  801468:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80146d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801470:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	b8 02 00 00 00       	mov    $0x2,%eax
  80147f:	e8 8d ff ff ff       	call   801411 <fsipc>
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	8b 40 0c             	mov    0xc(%eax),%eax
  801492:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a1:	e8 6b ff ff ff       	call   801411 <fsipc>
}
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c7:	e8 45 ff ff ff       	call   801411 <fsipc>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 2c                	js     8014fc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	68 00 50 80 00       	push   $0x805000
  8014d8:	53                   	push   %ebx
  8014d9:	e8 83 f2 ff ff       	call   800761 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014de:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80150a:	8b 55 08             	mov    0x8(%ebp),%edx
  80150d:	8b 52 0c             	mov    0xc(%edx),%edx
  801510:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801516:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80151b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801520:	0f 47 c2             	cmova  %edx,%eax
  801523:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801528:	50                   	push   %eax
  801529:	ff 75 0c             	pushl  0xc(%ebp)
  80152c:	68 08 50 80 00       	push   $0x805008
  801531:	e8 bd f3 ff ff       	call   8008f3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801536:	ba 00 00 00 00       	mov    $0x0,%edx
  80153b:	b8 04 00 00 00       	mov    $0x4,%eax
  801540:	e8 cc fe ff ff       	call   801411 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
  80154c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154f:	8b 45 08             	mov    0x8(%ebp),%eax
  801552:	8b 40 0c             	mov    0xc(%eax),%eax
  801555:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	b8 03 00 00 00       	mov    $0x3,%eax
  80156a:	e8 a2 fe ff ff       	call   801411 <fsipc>
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	85 c0                	test   %eax,%eax
  801573:	78 4b                	js     8015c0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801575:	39 c6                	cmp    %eax,%esi
  801577:	73 16                	jae    80158f <devfile_read+0x48>
  801579:	68 70 22 80 00       	push   $0x802270
  80157e:	68 77 22 80 00       	push   $0x802277
  801583:	6a 7c                	push   $0x7c
  801585:	68 8c 22 80 00       	push   $0x80228c
  80158a:	e8 bd 05 00 00       	call   801b4c <_panic>
	assert(r <= PGSIZE);
  80158f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801594:	7e 16                	jle    8015ac <devfile_read+0x65>
  801596:	68 97 22 80 00       	push   $0x802297
  80159b:	68 77 22 80 00       	push   $0x802277
  8015a0:	6a 7d                	push   $0x7d
  8015a2:	68 8c 22 80 00       	push   $0x80228c
  8015a7:	e8 a0 05 00 00       	call   801b4c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	50                   	push   %eax
  8015b0:	68 00 50 80 00       	push   $0x805000
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	e8 36 f3 ff ff       	call   8008f3 <memmove>
	return r;
  8015bd:	83 c4 10             	add    $0x10,%esp
}
  8015c0:	89 d8                	mov    %ebx,%eax
  8015c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 20             	sub    $0x20,%esp
  8015d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d3:	53                   	push   %ebx
  8015d4:	e8 4f f1 ff ff       	call   800728 <strlen>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e1:	7f 67                	jg     80164a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	e8 9a f8 ff ff       	call   800e89 <fd_alloc>
  8015ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 57                	js     80164f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	68 00 50 80 00       	push   $0x805000
  801601:	e8 5b f1 ff ff       	call   800761 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801606:	8b 45 0c             	mov    0xc(%ebp),%eax
  801609:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801611:	b8 01 00 00 00       	mov    $0x1,%eax
  801616:	e8 f6 fd ff ff       	call   801411 <fsipc>
  80161b:	89 c3                	mov    %eax,%ebx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	79 14                	jns    801638 <open+0x6f>
		fd_close(fd, 0);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	6a 00                	push   $0x0
  801629:	ff 75 f4             	pushl  -0xc(%ebp)
  80162c:	e8 50 f9 ff ff       	call   800f81 <fd_close>
		return r;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	89 da                	mov    %ebx,%edx
  801636:	eb 17                	jmp    80164f <open+0x86>
	}

	return fd2num(fd);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	ff 75 f4             	pushl  -0xc(%ebp)
  80163e:	e8 1f f8 ff ff       	call   800e62 <fd2num>
  801643:	89 c2                	mov    %eax,%edx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 05                	jmp    80164f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164f:	89 d0                	mov    %edx,%eax
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165c:	ba 00 00 00 00       	mov    $0x0,%edx
  801661:	b8 08 00 00 00       	mov    $0x8,%eax
  801666:	e8 a6 fd ff ff       	call   801411 <fsipc>
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801675:	83 ec 0c             	sub    $0xc,%esp
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	e8 f2 f7 ff ff       	call   800e72 <fd2data>
  801680:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	68 a3 22 80 00       	push   $0x8022a3
  80168a:	53                   	push   %ebx
  80168b:	e8 d1 f0 ff ff       	call   800761 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801690:	8b 46 04             	mov    0x4(%esi),%eax
  801693:	2b 06                	sub    (%esi),%eax
  801695:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80169b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a2:	00 00 00 
	stat->st_dev = &devpipe;
  8016a5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016ac:	30 80 00 
	return 0;
}
  8016af:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c5:	53                   	push   %ebx
  8016c6:	6a 00                	push   $0x0
  8016c8:	e8 1c f5 ff ff       	call   800be9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 9d f7 ff ff       	call   800e72 <fd2data>
  8016d5:	83 c4 08             	add    $0x8,%esp
  8016d8:	50                   	push   %eax
  8016d9:	6a 00                	push   $0x0
  8016db:	e8 09 f5 ff ff       	call   800be9 <sys_page_unmap>
}
  8016e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	57                   	push   %edi
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 1c             	sub    $0x1c,%esp
  8016ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016f1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016fb:	83 ec 0c             	sub    $0xc,%esp
  8016fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801701:	e8 8c 04 00 00       	call   801b92 <pageref>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	89 3c 24             	mov    %edi,(%esp)
  80170b:	e8 82 04 00 00       	call   801b92 <pageref>
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	39 c3                	cmp    %eax,%ebx
  801715:	0f 94 c1             	sete   %cl
  801718:	0f b6 c9             	movzbl %cl,%ecx
  80171b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80171e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801724:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801727:	39 ce                	cmp    %ecx,%esi
  801729:	74 1b                	je     801746 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80172b:	39 c3                	cmp    %eax,%ebx
  80172d:	75 c4                	jne    8016f3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80172f:	8b 42 58             	mov    0x58(%edx),%eax
  801732:	ff 75 e4             	pushl  -0x1c(%ebp)
  801735:	50                   	push   %eax
  801736:	56                   	push   %esi
  801737:	68 aa 22 80 00       	push   $0x8022aa
  80173c:	e8 9b ea ff ff       	call   8001dc <cprintf>
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	eb ad                	jmp    8016f3 <_pipeisclosed+0xe>
	}
}
  801746:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5e                   	pop    %esi
  80174e:	5f                   	pop    %edi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	57                   	push   %edi
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	83 ec 28             	sub    $0x28,%esp
  80175a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80175d:	56                   	push   %esi
  80175e:	e8 0f f7 ff ff       	call   800e72 <fd2data>
  801763:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	bf 00 00 00 00       	mov    $0x0,%edi
  80176d:	eb 4b                	jmp    8017ba <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80176f:	89 da                	mov    %ebx,%edx
  801771:	89 f0                	mov    %esi,%eax
  801773:	e8 6d ff ff ff       	call   8016e5 <_pipeisclosed>
  801778:	85 c0                	test   %eax,%eax
  80177a:	75 48                	jne    8017c4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80177c:	e8 c4 f3 ff ff       	call   800b45 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801781:	8b 43 04             	mov    0x4(%ebx),%eax
  801784:	8b 0b                	mov    (%ebx),%ecx
  801786:	8d 51 20             	lea    0x20(%ecx),%edx
  801789:	39 d0                	cmp    %edx,%eax
  80178b:	73 e2                	jae    80176f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80178d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801790:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801794:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801797:	89 c2                	mov    %eax,%edx
  801799:	c1 fa 1f             	sar    $0x1f,%edx
  80179c:	89 d1                	mov    %edx,%ecx
  80179e:	c1 e9 1b             	shr    $0x1b,%ecx
  8017a1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017a4:	83 e2 1f             	and    $0x1f,%edx
  8017a7:	29 ca                	sub    %ecx,%edx
  8017a9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b1:	83 c0 01             	add    $0x1,%eax
  8017b4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b7:	83 c7 01             	add    $0x1,%edi
  8017ba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017bd:	75 c2                	jne    801781 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c2:	eb 05                	jmp    8017c9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5f                   	pop    %edi
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	57                   	push   %edi
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 18             	sub    $0x18,%esp
  8017da:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017dd:	57                   	push   %edi
  8017de:	e8 8f f6 ff ff       	call   800e72 <fd2data>
  8017e3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ed:	eb 3d                	jmp    80182c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017ef:	85 db                	test   %ebx,%ebx
  8017f1:	74 04                	je     8017f7 <devpipe_read+0x26>
				return i;
  8017f3:	89 d8                	mov    %ebx,%eax
  8017f5:	eb 44                	jmp    80183b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017f7:	89 f2                	mov    %esi,%edx
  8017f9:	89 f8                	mov    %edi,%eax
  8017fb:	e8 e5 fe ff ff       	call   8016e5 <_pipeisclosed>
  801800:	85 c0                	test   %eax,%eax
  801802:	75 32                	jne    801836 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801804:	e8 3c f3 ff ff       	call   800b45 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801809:	8b 06                	mov    (%esi),%eax
  80180b:	3b 46 04             	cmp    0x4(%esi),%eax
  80180e:	74 df                	je     8017ef <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801810:	99                   	cltd   
  801811:	c1 ea 1b             	shr    $0x1b,%edx
  801814:	01 d0                	add    %edx,%eax
  801816:	83 e0 1f             	and    $0x1f,%eax
  801819:	29 d0                	sub    %edx,%eax
  80181b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801823:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801826:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801829:	83 c3 01             	add    $0x1,%ebx
  80182c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80182f:	75 d8                	jne    801809 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801831:	8b 45 10             	mov    0x10(%ebp),%eax
  801834:	eb 05                	jmp    80183b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80183b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	56                   	push   %esi
  801847:	53                   	push   %ebx
  801848:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80184b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184e:	50                   	push   %eax
  80184f:	e8 35 f6 ff ff       	call   800e89 <fd_alloc>
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	89 c2                	mov    %eax,%edx
  801859:	85 c0                	test   %eax,%eax
  80185b:	0f 88 2c 01 00 00    	js     80198d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801861:	83 ec 04             	sub    $0x4,%esp
  801864:	68 07 04 00 00       	push   $0x407
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	6a 00                	push   $0x0
  80186e:	e8 f1 f2 ff ff       	call   800b64 <sys_page_alloc>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 c2                	mov    %eax,%edx
  801878:	85 c0                	test   %eax,%eax
  80187a:	0f 88 0d 01 00 00    	js     80198d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	e8 fd f5 ff ff       	call   800e89 <fd_alloc>
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	85 c0                	test   %eax,%eax
  801893:	0f 88 e2 00 00 00    	js     80197b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	68 07 04 00 00       	push   $0x407
  8018a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a4:	6a 00                	push   $0x0
  8018a6:	e8 b9 f2 ff ff       	call   800b64 <sys_page_alloc>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	0f 88 c3 00 00 00    	js     80197b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018be:	e8 af f5 ff ff       	call   800e72 <fd2data>
  8018c3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c5:	83 c4 0c             	add    $0xc,%esp
  8018c8:	68 07 04 00 00       	push   $0x407
  8018cd:	50                   	push   %eax
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 8f f2 ff ff       	call   800b64 <sys_page_alloc>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 88 89 00 00 00    	js     80196b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e8:	e8 85 f5 ff ff       	call   800e72 <fd2data>
  8018ed:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018f4:	50                   	push   %eax
  8018f5:	6a 00                	push   $0x0
  8018f7:	56                   	push   %esi
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 a8 f2 ff ff       	call   800ba7 <sys_page_map>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 20             	add    $0x20,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 55                	js     80195d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801908:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801916:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80191d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801928:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	ff 75 f4             	pushl  -0xc(%ebp)
  801938:	e8 25 f5 ff ff       	call   800e62 <fd2num>
  80193d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801940:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801942:	83 c4 04             	add    $0x4,%esp
  801945:	ff 75 f0             	pushl  -0x10(%ebp)
  801948:	e8 15 f5 ff ff       	call   800e62 <fd2num>
  80194d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801950:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	ba 00 00 00 00       	mov    $0x0,%edx
  80195b:	eb 30                	jmp    80198d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	56                   	push   %esi
  801961:	6a 00                	push   $0x0
  801963:	e8 81 f2 ff ff       	call   800be9 <sys_page_unmap>
  801968:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	ff 75 f0             	pushl  -0x10(%ebp)
  801971:	6a 00                	push   $0x0
  801973:	e8 71 f2 ff ff       	call   800be9 <sys_page_unmap>
  801978:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	ff 75 f4             	pushl  -0xc(%ebp)
  801981:	6a 00                	push   $0x0
  801983:	e8 61 f2 ff ff       	call   800be9 <sys_page_unmap>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80198d:	89 d0                	mov    %edx,%eax
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199f:	50                   	push   %eax
  8019a0:	ff 75 08             	pushl  0x8(%ebp)
  8019a3:	e8 30 f5 ff ff       	call   800ed8 <fd_lookup>
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 18                	js     8019c7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b5:	e8 b8 f4 ff ff       	call   800e72 <fd2data>
	return _pipeisclosed(fd, p);
  8019ba:	89 c2                	mov    %eax,%edx
  8019bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bf:	e8 21 fd ff ff       	call   8016e5 <_pipeisclosed>
  8019c4:	83 c4 10             	add    $0x10,%esp
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019d9:	68 c2 22 80 00       	push   $0x8022c2
  8019de:	ff 75 0c             	pushl  0xc(%ebp)
  8019e1:	e8 7b ed ff ff       	call   800761 <strcpy>
	return 0;
}
  8019e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	57                   	push   %edi
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019fe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a04:	eb 2d                	jmp    801a33 <devcons_write+0x46>
		m = n - tot;
  801a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a09:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a0b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a0e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a13:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a16:	83 ec 04             	sub    $0x4,%esp
  801a19:	53                   	push   %ebx
  801a1a:	03 45 0c             	add    0xc(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	57                   	push   %edi
  801a1f:	e8 cf ee ff ff       	call   8008f3 <memmove>
		sys_cputs(buf, m);
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	53                   	push   %ebx
  801a28:	57                   	push   %edi
  801a29:	e8 7a f0 ff ff       	call   800aa8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a2e:	01 de                	add    %ebx,%esi
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	89 f0                	mov    %esi,%eax
  801a35:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a38:	72 cc                	jb     801a06 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5f                   	pop    %edi
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 08             	sub    $0x8,%esp
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a51:	74 2a                	je     801a7d <devcons_read+0x3b>
  801a53:	eb 05                	jmp    801a5a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a55:	e8 eb f0 ff ff       	call   800b45 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a5a:	e8 67 f0 ff ff       	call   800ac6 <sys_cgetc>
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	74 f2                	je     801a55 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 16                	js     801a7d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a67:	83 f8 04             	cmp    $0x4,%eax
  801a6a:	74 0c                	je     801a78 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6f:	88 02                	mov    %al,(%edx)
	return 1;
  801a71:	b8 01 00 00 00       	mov    $0x1,%eax
  801a76:	eb 05                	jmp    801a7d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a8b:	6a 01                	push   $0x1
  801a8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	e8 12 f0 ff ff       	call   800aa8 <sys_cputs>
}
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <getchar>:

int
getchar(void)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aa1:	6a 01                	push   $0x1
  801aa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 90 f6 ff ff       	call   80113e <read>
	if (r < 0)
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 0f                	js     801ac4 <getchar+0x29>
		return r;
	if (r < 1)
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	7e 06                	jle    801abf <getchar+0x24>
		return -E_EOF;
	return c;
  801ab9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801abd:	eb 05                	jmp    801ac4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801abf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801acc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	ff 75 08             	pushl  0x8(%ebp)
  801ad3:	e8 00 f4 ff ff       	call   800ed8 <fd_lookup>
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 11                	js     801af0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae8:	39 10                	cmp    %edx,(%eax)
  801aea:	0f 94 c0             	sete   %al
  801aed:	0f b6 c0             	movzbl %al,%eax
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <opencons>:

int
opencons(void)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801af8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afb:	50                   	push   %eax
  801afc:	e8 88 f3 ff ff       	call   800e89 <fd_alloc>
  801b01:	83 c4 10             	add    $0x10,%esp
		return r;
  801b04:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 3e                	js     801b48 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	68 07 04 00 00       	push   $0x407
  801b12:	ff 75 f4             	pushl  -0xc(%ebp)
  801b15:	6a 00                	push   $0x0
  801b17:	e8 48 f0 ff ff       	call   800b64 <sys_page_alloc>
  801b1c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b1f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 23                	js     801b48 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	50                   	push   %eax
  801b3e:	e8 1f f3 ff ff       	call   800e62 <fd2num>
  801b43:	89 c2                	mov    %eax,%edx
  801b45:	83 c4 10             	add    $0x10,%esp
}
  801b48:	89 d0                	mov    %edx,%eax
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b51:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b54:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b5a:	e8 c7 ef ff ff       	call   800b26 <sys_getenvid>
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	ff 75 0c             	pushl  0xc(%ebp)
  801b65:	ff 75 08             	pushl  0x8(%ebp)
  801b68:	56                   	push   %esi
  801b69:	50                   	push   %eax
  801b6a:	68 d0 22 80 00       	push   $0x8022d0
  801b6f:	e8 68 e6 ff ff       	call   8001dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b74:	83 c4 18             	add    $0x18,%esp
  801b77:	53                   	push   %ebx
  801b78:	ff 75 10             	pushl  0x10(%ebp)
  801b7b:	e8 0b e6 ff ff       	call   80018b <vcprintf>
	cprintf("\n");
  801b80:	c7 04 24 bb 22 80 00 	movl   $0x8022bb,(%esp)
  801b87:	e8 50 e6 ff ff       	call   8001dc <cprintf>
  801b8c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b8f:	cc                   	int3   
  801b90:	eb fd                	jmp    801b8f <_panic+0x43>

00801b92 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b98:	89 d0                	mov    %edx,%eax
  801b9a:	c1 e8 16             	shr    $0x16,%eax
  801b9d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba9:	f6 c1 01             	test   $0x1,%cl
  801bac:	74 1d                	je     801bcb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bae:	c1 ea 0c             	shr    $0xc,%edx
  801bb1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bb8:	f6 c2 01             	test   $0x1,%dl
  801bbb:	74 0e                	je     801bcb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bbd:	c1 ea 0c             	shr    $0xc,%edx
  801bc0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bc7:	ef 
  801bc8:	0f b7 c0             	movzwl %ax,%eax
}
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    
  801bcd:	66 90                	xchg   %ax,%ax
  801bcf:	90                   	nop

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
