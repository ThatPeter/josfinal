
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 1f 80 00       	push   $0x801f20
  80004a:	e8 84 01 00 00       	call   8001d3 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 c9 0a 00 00       	call   800b1d <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 80 0a 00 00       	call   800adc <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 fb 0c 00 00       	call   800d6c <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	57                   	push   %edi
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800089:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800090:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800093:	e8 85 0a 00 00       	call   800b1d <sys_getenvid>
  800098:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	50                   	push   %eax
  80009e:	68 3c 1f 80 00       	push   $0x801f3c
  8000a3:	e8 2b 01 00 00       	call   8001d3 <cprintf>
  8000a8:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000ae:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000c0:	89 c1                	mov    %eax,%ecx
  8000c2:	c1 e1 07             	shl    $0x7,%ecx
  8000c5:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000cc:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000cf:	39 cb                	cmp    %ecx,%ebx
  8000d1:	0f 44 fa             	cmove  %edx,%edi
  8000d4:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000d9:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000dc:	83 c0 01             	add    $0x1,%eax
  8000df:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000e5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000ea:	75 d4                	jne    8000c0 <libmain+0x40>
  8000ec:	89 f0                	mov    %esi,%eax
  8000ee:	84 c0                	test   %al,%al
  8000f0:	74 06                	je     8000f8 <libmain+0x78>
  8000f2:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000fc:	7e 0a                	jle    800108 <libmain+0x88>
		binaryname = argv[0];
  8000fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800101:	8b 00                	mov    (%eax),%eax
  800103:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	ff 75 0c             	pushl  0xc(%ebp)
  80010e:	ff 75 08             	pushl  0x8(%ebp)
  800111:	e8 4b ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  800116:	e8 0b 00 00 00       	call   800126 <exit>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5f                   	pop    %edi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012c:	e8 95 0e 00 00       	call   800fc6 <close_all>
	sys_env_destroy(0);
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	6a 00                	push   $0x0
  800136:	e8 a1 09 00 00       	call   800adc <sys_env_destroy>
}
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	53                   	push   %ebx
  800144:	83 ec 04             	sub    $0x4,%esp
  800147:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014a:	8b 13                	mov    (%ebx),%edx
  80014c:	8d 42 01             	lea    0x1(%edx),%eax
  80014f:	89 03                	mov    %eax,(%ebx)
  800151:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800154:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800158:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015d:	75 1a                	jne    800179 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80015f:	83 ec 08             	sub    $0x8,%esp
  800162:	68 ff 00 00 00       	push   $0xff
  800167:	8d 43 08             	lea    0x8(%ebx),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 2f 09 00 00       	call   800a9f <sys_cputs>
		b->idx = 0;
  800170:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800176:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800179:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800180:	c9                   	leave  
  800181:	c3                   	ret    

00800182 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800192:	00 00 00 
	b.cnt = 0;
  800195:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019f:	ff 75 0c             	pushl  0xc(%ebp)
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ab:	50                   	push   %eax
  8001ac:	68 40 01 80 00       	push   $0x800140
  8001b1:	e8 54 01 00 00       	call   80030a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b6:	83 c4 08             	add    $0x8,%esp
  8001b9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 d4 08 00 00       	call   800a9f <sys_cputs>

	return b.cnt;
}
  8001cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dc:	50                   	push   %eax
  8001dd:	ff 75 08             	pushl  0x8(%ebp)
  8001e0:	e8 9d ff ff ff       	call   800182 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 1c             	sub    $0x1c,%esp
  8001f0:	89 c7                	mov    %eax,%edi
  8001f2:	89 d6                	mov    %edx,%esi
  8001f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800200:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800203:	bb 00 00 00 00       	mov    $0x0,%ebx
  800208:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020e:	39 d3                	cmp    %edx,%ebx
  800210:	72 05                	jb     800217 <printnum+0x30>
  800212:	39 45 10             	cmp    %eax,0x10(%ebp)
  800215:	77 45                	ja     80025c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	ff 75 18             	pushl  0x18(%ebp)
  80021d:	8b 45 14             	mov    0x14(%ebp),%eax
  800220:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800223:	53                   	push   %ebx
  800224:	ff 75 10             	pushl  0x10(%ebp)
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022d:	ff 75 e0             	pushl  -0x20(%ebp)
  800230:	ff 75 dc             	pushl  -0x24(%ebp)
  800233:	ff 75 d8             	pushl  -0x28(%ebp)
  800236:	e8 45 1a 00 00       	call   801c80 <__udivdi3>
  80023b:	83 c4 18             	add    $0x18,%esp
  80023e:	52                   	push   %edx
  80023f:	50                   	push   %eax
  800240:	89 f2                	mov    %esi,%edx
  800242:	89 f8                	mov    %edi,%eax
  800244:	e8 9e ff ff ff       	call   8001e7 <printnum>
  800249:	83 c4 20             	add    $0x20,%esp
  80024c:	eb 18                	jmp    800266 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	ff 75 18             	pushl  0x18(%ebp)
  800255:	ff d7                	call   *%edi
  800257:	83 c4 10             	add    $0x10,%esp
  80025a:	eb 03                	jmp    80025f <printnum+0x78>
  80025c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	85 db                	test   %ebx,%ebx
  800264:	7f e8                	jg     80024e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800266:	83 ec 08             	sub    $0x8,%esp
  800269:	56                   	push   %esi
  80026a:	83 ec 04             	sub    $0x4,%esp
  80026d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800270:	ff 75 e0             	pushl  -0x20(%ebp)
  800273:	ff 75 dc             	pushl  -0x24(%ebp)
  800276:	ff 75 d8             	pushl  -0x28(%ebp)
  800279:	e8 32 1b 00 00       	call   801db0 <__umoddi3>
  80027e:	83 c4 14             	add    $0x14,%esp
  800281:	0f be 80 65 1f 80 00 	movsbl 0x801f65(%eax),%eax
  800288:	50                   	push   %eax
  800289:	ff d7                	call   *%edi
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800299:	83 fa 01             	cmp    $0x1,%edx
  80029c:	7e 0e                	jle    8002ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	8b 52 04             	mov    0x4(%edx),%edx
  8002aa:	eb 22                	jmp    8002ce <getuint+0x38>
	else if (lflag)
  8002ac:	85 d2                	test   %edx,%edx
  8002ae:	74 10                	je     8002c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 0e                	jmp    8002ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002df:	73 0a                	jae    8002eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e9:	88 02                	mov    %al,(%edx)
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f6:	50                   	push   %eax
  8002f7:	ff 75 10             	pushl  0x10(%ebp)
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	ff 75 08             	pushl  0x8(%ebp)
  800300:	e8 05 00 00 00       	call   80030a <vprintfmt>
	va_end(ap);
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 2c             	sub    $0x2c,%esp
  800313:	8b 75 08             	mov    0x8(%ebp),%esi
  800316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800319:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031c:	eb 12                	jmp    800330 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031e:	85 c0                	test   %eax,%eax
  800320:	0f 84 89 03 00 00    	je     8006af <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	53                   	push   %ebx
  80032a:	50                   	push   %eax
  80032b:	ff d6                	call   *%esi
  80032d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800330:	83 c7 01             	add    $0x1,%edi
  800333:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800337:	83 f8 25             	cmp    $0x25,%eax
  80033a:	75 e2                	jne    80031e <vprintfmt+0x14>
  80033c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800340:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800347:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	eb 07                	jmp    800363 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8d 47 01             	lea    0x1(%edi),%eax
  800366:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800369:	0f b6 07             	movzbl (%edi),%eax
  80036c:	0f b6 c8             	movzbl %al,%ecx
  80036f:	83 e8 23             	sub    $0x23,%eax
  800372:	3c 55                	cmp    $0x55,%al
  800374:	0f 87 1a 03 00 00    	ja     800694 <vprintfmt+0x38a>
  80037a:	0f b6 c0             	movzbl %al,%eax
  80037d:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800387:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038b:	eb d6                	jmp    800363 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800390:	b8 00 00 00 00       	mov    $0x0,%eax
  800395:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800398:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80039f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a5:	83 fa 09             	cmp    $0x9,%edx
  8003a8:	77 39                	ja     8003e3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ad:	eb e9                	jmp    800398 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c0:	eb 27                	jmp    8003e9 <vprintfmt+0xdf>
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cc:	0f 49 c8             	cmovns %eax,%ecx
  8003cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d5:	eb 8c                	jmp    800363 <vprintfmt+0x59>
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e1:	eb 80                	jmp    800363 <vprintfmt+0x59>
  8003e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ed:	0f 89 70 ff ff ff    	jns    800363 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800400:	e9 5e ff ff ff       	jmp    800363 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800405:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040b:	e9 53 ff ff ff       	jmp    800363 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	53                   	push   %ebx
  80041d:	ff 30                	pushl  (%eax)
  80041f:	ff d6                	call   *%esi
			break;
  800421:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800427:	e9 04 ff ff ff       	jmp    800330 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 50 04             	lea    0x4(%eax),%edx
  800432:	89 55 14             	mov    %edx,0x14(%ebp)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	99                   	cltd   
  800438:	31 d0                	xor    %edx,%eax
  80043a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043c:	83 f8 0f             	cmp    $0xf,%eax
  80043f:	7f 0b                	jg     80044c <vprintfmt+0x142>
  800441:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  800448:	85 d2                	test   %edx,%edx
  80044a:	75 18                	jne    800464 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044c:	50                   	push   %eax
  80044d:	68 7d 1f 80 00       	push   $0x801f7d
  800452:	53                   	push   %ebx
  800453:	56                   	push   %esi
  800454:	e8 94 fe ff ff       	call   8002ed <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045f:	e9 cc fe ff ff       	jmp    800330 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800464:	52                   	push   %edx
  800465:	68 41 23 80 00       	push   $0x802341
  80046a:	53                   	push   %ebx
  80046b:	56                   	push   %esi
  80046c:	e8 7c fe ff ff       	call   8002ed <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800477:	e9 b4 fe ff ff       	jmp    800330 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800487:	85 ff                	test   %edi,%edi
  800489:	b8 76 1f 80 00       	mov    $0x801f76,%eax
  80048e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800491:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800495:	0f 8e 94 00 00 00    	jle    80052f <vprintfmt+0x225>
  80049b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049f:	0f 84 98 00 00 00    	je     80053d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ab:	57                   	push   %edi
  8004ac:	e8 86 02 00 00       	call   800737 <strnlen>
  8004b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b4:	29 c1                	sub    %eax,%ecx
  8004b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c8:	eb 0f                	jmp    8004d9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	83 ef 01             	sub    $0x1,%edi
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	7f ed                	jg     8004ca <vprintfmt+0x1c0>
  8004dd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e3:	85 c9                	test   %ecx,%ecx
  8004e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ea:	0f 49 c1             	cmovns %ecx,%eax
  8004ed:	29 c1                	sub    %eax,%ecx
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	89 cb                	mov    %ecx,%ebx
  8004fa:	eb 4d                	jmp    800549 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800500:	74 1b                	je     80051d <vprintfmt+0x213>
  800502:	0f be c0             	movsbl %al,%eax
  800505:	83 e8 20             	sub    $0x20,%eax
  800508:	83 f8 5e             	cmp    $0x5e,%eax
  80050b:	76 10                	jbe    80051d <vprintfmt+0x213>
					putch('?', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	6a 3f                	push   $0x3f
  800515:	ff 55 08             	call   *0x8(%ebp)
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb 0d                	jmp    80052a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	ff 75 0c             	pushl  0xc(%ebp)
  800523:	52                   	push   %edx
  800524:	ff 55 08             	call   *0x8(%ebp)
  800527:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	83 eb 01             	sub    $0x1,%ebx
  80052d:	eb 1a                	jmp    800549 <vprintfmt+0x23f>
  80052f:	89 75 08             	mov    %esi,0x8(%ebp)
  800532:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800535:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800538:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053b:	eb 0c                	jmp    800549 <vprintfmt+0x23f>
  80053d:	89 75 08             	mov    %esi,0x8(%ebp)
  800540:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800546:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800549:	83 c7 01             	add    $0x1,%edi
  80054c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800550:	0f be d0             	movsbl %al,%edx
  800553:	85 d2                	test   %edx,%edx
  800555:	74 23                	je     80057a <vprintfmt+0x270>
  800557:	85 f6                	test   %esi,%esi
  800559:	78 a1                	js     8004fc <vprintfmt+0x1f2>
  80055b:	83 ee 01             	sub    $0x1,%esi
  80055e:	79 9c                	jns    8004fc <vprintfmt+0x1f2>
  800560:	89 df                	mov    %ebx,%edi
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
  800565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800568:	eb 18                	jmp    800582 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 20                	push   $0x20
  800570:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	83 ef 01             	sub    $0x1,%edi
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb 08                	jmp    800582 <vprintfmt+0x278>
  80057a:	89 df                	mov    %ebx,%edi
  80057c:	8b 75 08             	mov    0x8(%ebp),%esi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	85 ff                	test   %edi,%edi
  800584:	7f e4                	jg     80056a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	e9 a2 fd ff ff       	jmp    800330 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058e:	83 fa 01             	cmp    $0x1,%edx
  800591:	7e 16                	jle    8005a9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 08             	lea    0x8(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 50 04             	mov    0x4(%eax),%edx
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a7:	eb 32                	jmp    8005db <vprintfmt+0x2d1>
	else if (lflag)
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 18                	je     8005c5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	89 c1                	mov    %eax,%ecx
  8005bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c3:	eb 16                	jmp    8005db <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 c1                	mov    %eax,%ecx
  8005d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005de:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ea:	79 74                	jns    800660 <vprintfmt+0x356>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fa:	f7 d8                	neg    %eax
  8005fc:	83 d2 00             	adc    $0x0,%edx
  8005ff:	f7 da                	neg    %edx
  800601:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800604:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800609:	eb 55                	jmp    800660 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 83 fc ff ff       	call   800296 <getuint>
			base = 10;
  800613:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800618:	eb 46                	jmp    800660 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 74 fc ff ff       	call   800296 <getuint>
			base = 8;
  800622:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800627:	eb 37                	jmp    800660 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 30                	push   $0x30
  80062f:	ff d6                	call   *%esi
			putch('x', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 78                	push   $0x78
  800637:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800642:	8b 00                	mov    (%eax),%eax
  800644:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800649:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800651:	eb 0d                	jmp    800660 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 3b fc ff ff       	call   800296 <getuint>
			base = 16;
  80065b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800667:	57                   	push   %edi
  800668:	ff 75 e0             	pushl  -0x20(%ebp)
  80066b:	51                   	push   %ecx
  80066c:	52                   	push   %edx
  80066d:	50                   	push   %eax
  80066e:	89 da                	mov    %ebx,%edx
  800670:	89 f0                	mov    %esi,%eax
  800672:	e8 70 fb ff ff       	call   8001e7 <printnum>
			break;
  800677:	83 c4 20             	add    $0x20,%esp
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067d:	e9 ae fc ff ff       	jmp    800330 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	51                   	push   %ecx
  800687:	ff d6                	call   *%esi
			break;
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068f:	e9 9c fc ff ff       	jmp    800330 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 25                	push   $0x25
  80069a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb 03                	jmp    8006a4 <vprintfmt+0x39a>
  8006a1:	83 ef 01             	sub    $0x1,%edi
  8006a4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a8:	75 f7                	jne    8006a1 <vprintfmt+0x397>
  8006aa:	e9 81 fc ff ff       	jmp    800330 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b2:	5b                   	pop    %ebx
  8006b3:	5e                   	pop    %esi
  8006b4:	5f                   	pop    %edi
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 18             	sub    $0x18,%esp
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 26                	je     8006fe <vsnprintf+0x47>
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	7e 22                	jle    8006fe <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dc:	ff 75 14             	pushl  0x14(%ebp)
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e5:	50                   	push   %eax
  8006e6:	68 d0 02 80 00       	push   $0x8002d0
  8006eb:	e8 1a fc ff ff       	call   80030a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	50                   	push   %eax
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	e8 9a ff ff ff       	call   8006b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800725:	b8 00 00 00 00       	mov    $0x0,%eax
  80072a:	eb 03                	jmp    80072f <strlen+0x10>
		n++;
  80072c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800733:	75 f7                	jne    80072c <strlen+0xd>
		n++;
	return n;
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800740:	ba 00 00 00 00       	mov    $0x0,%edx
  800745:	eb 03                	jmp    80074a <strnlen+0x13>
		n++;
  800747:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074a:	39 c2                	cmp    %eax,%edx
  80074c:	74 08                	je     800756 <strnlen+0x1f>
  80074e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800752:	75 f3                	jne    800747 <strnlen+0x10>
  800754:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800762:	89 c2                	mov    %eax,%edx
  800764:	83 c2 01             	add    $0x1,%edx
  800767:	83 c1 01             	add    $0x1,%ecx
  80076a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800771:	84 db                	test   %bl,%bl
  800773:	75 ef                	jne    800764 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800775:	5b                   	pop    %ebx
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077f:	53                   	push   %ebx
  800780:	e8 9a ff ff ff       	call   80071f <strlen>
  800785:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	01 d8                	add    %ebx,%eax
  80078d:	50                   	push   %eax
  80078e:	e8 c5 ff ff ff       	call   800758 <strcpy>
	return dst;
}
  800793:	89 d8                	mov    %ebx,%eax
  800795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	56                   	push   %esi
  80079e:	53                   	push   %ebx
  80079f:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a5:	89 f3                	mov    %esi,%ebx
  8007a7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	89 f2                	mov    %esi,%edx
  8007ac:	eb 0f                	jmp    8007bd <strncpy+0x23>
		*dst++ = *src;
  8007ae:	83 c2 01             	add    $0x1,%edx
  8007b1:	0f b6 01             	movzbl (%ecx),%eax
  8007b4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ba:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bd:	39 da                	cmp    %ebx,%edx
  8007bf:	75 ed                	jne    8007ae <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	5b                   	pop    %ebx
  8007c4:	5e                   	pop    %esi
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 21                	je     8007fc <strlcpy+0x35>
  8007db:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007df:	89 f2                	mov    %esi,%edx
  8007e1:	eb 09                	jmp    8007ec <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	83 c1 01             	add    $0x1,%ecx
  8007e9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ec:	39 c2                	cmp    %eax,%edx
  8007ee:	74 09                	je     8007f9 <strlcpy+0x32>
  8007f0:	0f b6 19             	movzbl (%ecx),%ebx
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	75 ec                	jne    8007e3 <strlcpy+0x1c>
  8007f7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fc:	29 f0                	sub    %esi,%eax
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080b:	eb 06                	jmp    800813 <strcmp+0x11>
		p++, q++;
  80080d:	83 c1 01             	add    $0x1,%ecx
  800810:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800813:	0f b6 01             	movzbl (%ecx),%eax
  800816:	84 c0                	test   %al,%al
  800818:	74 04                	je     80081e <strcmp+0x1c>
  80081a:	3a 02                	cmp    (%edx),%al
  80081c:	74 ef                	je     80080d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081e:	0f b6 c0             	movzbl %al,%eax
  800821:	0f b6 12             	movzbl (%edx),%edx
  800824:	29 d0                	sub    %edx,%eax
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	89 c3                	mov    %eax,%ebx
  800834:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800837:	eb 06                	jmp    80083f <strncmp+0x17>
		n--, p++, q++;
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083f:	39 d8                	cmp    %ebx,%eax
  800841:	74 15                	je     800858 <strncmp+0x30>
  800843:	0f b6 08             	movzbl (%eax),%ecx
  800846:	84 c9                	test   %cl,%cl
  800848:	74 04                	je     80084e <strncmp+0x26>
  80084a:	3a 0a                	cmp    (%edx),%cl
  80084c:	74 eb                	je     800839 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 00             	movzbl (%eax),%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
  800856:	eb 05                	jmp    80085d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085d:	5b                   	pop    %ebx
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	eb 07                	jmp    800873 <strchr+0x13>
		if (*s == c)
  80086c:	38 ca                	cmp    %cl,%dl
  80086e:	74 0f                	je     80087f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	0f b6 10             	movzbl (%eax),%edx
  800876:	84 d2                	test   %dl,%dl
  800878:	75 f2                	jne    80086c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088b:	eb 03                	jmp    800890 <strfind+0xf>
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800893:	38 ca                	cmp    %cl,%dl
  800895:	74 04                	je     80089b <strfind+0x1a>
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f2                	jne    80088d <strfind+0xc>
			break;
	return (char *) s;
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	57                   	push   %edi
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 36                	je     8008e3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 28                	jne    8008dd <memset+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 23                	jne    8008dd <memset+0x40>
		c &= 0xFF;
  8008ba:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008be:	89 d3                	mov    %edx,%ebx
  8008c0:	c1 e3 08             	shl    $0x8,%ebx
  8008c3:	89 d6                	mov    %edx,%esi
  8008c5:	c1 e6 18             	shl    $0x18,%esi
  8008c8:	89 d0                	mov    %edx,%eax
  8008ca:	c1 e0 10             	shl    $0x10,%eax
  8008cd:	09 f0                	or     %esi,%eax
  8008cf:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d1:	89 d8                	mov    %ebx,%eax
  8008d3:	09 d0                	or     %edx,%eax
  8008d5:	c1 e9 02             	shr    $0x2,%ecx
  8008d8:	fc                   	cld    
  8008d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008db:	eb 06                	jmp    8008e3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e0:	fc                   	cld    
  8008e1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e3:	89 f8                	mov    %edi,%eax
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f8:	39 c6                	cmp    %eax,%esi
  8008fa:	73 35                	jae    800931 <memmove+0x47>
  8008fc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ff:	39 d0                	cmp    %edx,%eax
  800901:	73 2e                	jae    800931 <memmove+0x47>
		s += n;
		d += n;
  800903:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	89 d6                	mov    %edx,%esi
  800908:	09 fe                	or     %edi,%esi
  80090a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800910:	75 13                	jne    800925 <memmove+0x3b>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 0e                	jne    800925 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800917:	83 ef 04             	sub    $0x4,%edi
  80091a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091d:	c1 e9 02             	shr    $0x2,%ecx
  800920:	fd                   	std    
  800921:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800923:	eb 09                	jmp    80092e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800925:	83 ef 01             	sub    $0x1,%edi
  800928:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092b:	fd                   	std    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092e:	fc                   	cld    
  80092f:	eb 1d                	jmp    80094e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800931:	89 f2                	mov    %esi,%edx
  800933:	09 c2                	or     %eax,%edx
  800935:	f6 c2 03             	test   $0x3,%dl
  800938:	75 0f                	jne    800949 <memmove+0x5f>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0a                	jne    800949 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093f:	c1 e9 02             	shr    $0x2,%ecx
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800947:	eb 05                	jmp    80094e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800955:	ff 75 10             	pushl  0x10(%ebp)
  800958:	ff 75 0c             	pushl  0xc(%ebp)
  80095b:	ff 75 08             	pushl  0x8(%ebp)
  80095e:	e8 87 ff ff ff       	call   8008ea <memmove>
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	89 c6                	mov    %eax,%esi
  800972:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800975:	eb 1a                	jmp    800991 <memcmp+0x2c>
		if (*s1 != *s2)
  800977:	0f b6 08             	movzbl (%eax),%ecx
  80097a:	0f b6 1a             	movzbl (%edx),%ebx
  80097d:	38 d9                	cmp    %bl,%cl
  80097f:	74 0a                	je     80098b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800981:	0f b6 c1             	movzbl %cl,%eax
  800984:	0f b6 db             	movzbl %bl,%ebx
  800987:	29 d8                	sub    %ebx,%eax
  800989:	eb 0f                	jmp    80099a <memcmp+0x35>
		s1++, s2++;
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800991:	39 f0                	cmp    %esi,%eax
  800993:	75 e2                	jne    800977 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009aa:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ae:	eb 0a                	jmp    8009ba <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b0:	0f b6 10             	movzbl (%eax),%edx
  8009b3:	39 da                	cmp    %ebx,%edx
  8009b5:	74 07                	je     8009be <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b7:	83 c0 01             	add    $0x1,%eax
  8009ba:	39 c8                	cmp    %ecx,%eax
  8009bc:	72 f2                	jb     8009b0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cd:	eb 03                	jmp    8009d2 <strtol+0x11>
		s++;
  8009cf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d2:	0f b6 01             	movzbl (%ecx),%eax
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f6                	je     8009cf <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f2                	je     8009cf <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	75 0a                	jne    8009eb <strtol+0x2a>
		s++;
  8009e1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e9:	eb 11                	jmp    8009fc <strtol+0x3b>
  8009eb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f0:	3c 2d                	cmp    $0x2d,%al
  8009f2:	75 08                	jne    8009fc <strtol+0x3b>
		s++, neg = 1;
  8009f4:	83 c1 01             	add    $0x1,%ecx
  8009f7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a02:	75 15                	jne    800a19 <strtol+0x58>
  800a04:	80 39 30             	cmpb   $0x30,(%ecx)
  800a07:	75 10                	jne    800a19 <strtol+0x58>
  800a09:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0d:	75 7c                	jne    800a8b <strtol+0xca>
		s += 2, base = 16;
  800a0f:	83 c1 02             	add    $0x2,%ecx
  800a12:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a17:	eb 16                	jmp    800a2f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a19:	85 db                	test   %ebx,%ebx
  800a1b:	75 12                	jne    800a2f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a22:	80 39 30             	cmpb   $0x30,(%ecx)
  800a25:	75 08                	jne    800a2f <strtol+0x6e>
		s++, base = 8;
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a37:	0f b6 11             	movzbl (%ecx),%edx
  800a3a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3d:	89 f3                	mov    %esi,%ebx
  800a3f:	80 fb 09             	cmp    $0x9,%bl
  800a42:	77 08                	ja     800a4c <strtol+0x8b>
			dig = *s - '0';
  800a44:	0f be d2             	movsbl %dl,%edx
  800a47:	83 ea 30             	sub    $0x30,%edx
  800a4a:	eb 22                	jmp    800a6e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4f:	89 f3                	mov    %esi,%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 08                	ja     800a5e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a56:	0f be d2             	movsbl %dl,%edx
  800a59:	83 ea 57             	sub    $0x57,%edx
  800a5c:	eb 10                	jmp    800a6e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a61:	89 f3                	mov    %esi,%ebx
  800a63:	80 fb 19             	cmp    $0x19,%bl
  800a66:	77 16                	ja     800a7e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a68:	0f be d2             	movsbl %dl,%edx
  800a6b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a71:	7d 0b                	jge    800a7e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a73:	83 c1 01             	add    $0x1,%ecx
  800a76:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7c:	eb b9                	jmp    800a37 <strtol+0x76>

	if (endptr)
  800a7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a82:	74 0d                	je     800a91 <strtol+0xd0>
		*endptr = (char *) s;
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	89 0e                	mov    %ecx,(%esi)
  800a89:	eb 06                	jmp    800a91 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	74 98                	je     800a27 <strtol+0x66>
  800a8f:	eb 9e                	jmp    800a2f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	f7 da                	neg    %edx
  800a95:	85 ff                	test   %edi,%edi
  800a97:	0f 45 c2             	cmovne %edx,%eax
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aad:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	89 c7                	mov    %eax,%edi
  800ab4:	89 c6                	mov    %eax,%esi
  800ab6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cgetc>:

int
sys_cgetc(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 01 00 00 00       	mov    $0x1,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aea:	b8 03 00 00 00       	mov    $0x3,%eax
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	89 cb                	mov    %ecx,%ebx
  800af4:	89 cf                	mov    %ecx,%edi
  800af6:	89 ce                	mov    %ecx,%esi
  800af8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afa:	85 c0                	test   %eax,%eax
  800afc:	7e 17                	jle    800b15 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	50                   	push   %eax
  800b02:	6a 03                	push   $0x3
  800b04:	68 5f 22 80 00       	push   $0x80225f
  800b09:	6a 23                	push   $0x23
  800b0b:	68 7c 22 80 00       	push   $0x80227c
  800b10:	e8 d0 0f 00 00       	call   801ae5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_yield>:

void
sys_yield(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	be 00 00 00 00       	mov    $0x0,%esi
  800b69:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b77:	89 f7                	mov    %esi,%edi
  800b79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 17                	jle    800b96 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 04                	push   $0x4
  800b85:	68 5f 22 80 00       	push   $0x80225f
  800b8a:	6a 23                	push   $0x23
  800b8c:	68 7c 22 80 00       	push   $0x80227c
  800b91:	e8 4f 0f 00 00       	call   801ae5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ba7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 05                	push   $0x5
  800bc7:	68 5f 22 80 00       	push   $0x80225f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 7c 22 80 00       	push   $0x80227c
  800bd3:	e8 0d 0f 00 00       	call   801ae5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800bee:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c01:	7e 17                	jle    800c1a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 06                	push   $0x6
  800c09:	68 5f 22 80 00       	push   $0x80225f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 7c 22 80 00       	push   $0x80227c
  800c15:	e8 cb 0e 00 00       	call   801ae5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c30:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c43:	7e 17                	jle    800c5c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 08                	push   $0x8
  800c4b:	68 5f 22 80 00       	push   $0x80225f
  800c50:	6a 23                	push   $0x23
  800c52:	68 7c 22 80 00       	push   $0x80227c
  800c57:	e8 89 0e 00 00       	call   801ae5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c72:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800c85:	7e 17                	jle    800c9e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 09                	push   $0x9
  800c8d:	68 5f 22 80 00       	push   $0x80225f
  800c92:	6a 23                	push   $0x23
  800c94:	68 7c 22 80 00       	push   $0x80227c
  800c99:	e8 47 0e 00 00       	call   801ae5 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 0a                	push   $0xa
  800ccf:	68 5f 22 80 00       	push   $0x80225f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 7c 22 80 00       	push   $0x80227c
  800cdb:	e8 05 0e 00 00       	call   801ae5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	be 00 00 00 00       	mov    $0x0,%esi
  800cf3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d04:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 0d                	push   $0xd
  800d33:	68 5f 22 80 00       	push   $0x80225f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 7c 22 80 00       	push   $0x80227c
  800d3f:	e8 a1 0d 00 00       	call   801ae5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d57:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 cb                	mov    %ecx,%ebx
  800d61:	89 cf                	mov    %ecx,%edi
  800d63:	89 ce                	mov    %ecx,%esi
  800d65:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d72:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d79:	75 2a                	jne    800da5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	6a 07                	push   $0x7
  800d80:	68 00 f0 bf ee       	push   $0xeebff000
  800d85:	6a 00                	push   $0x0
  800d87:	e8 cf fd ff ff       	call   800b5b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	79 12                	jns    800da5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800d93:	50                   	push   %eax
  800d94:	68 8a 22 80 00       	push   $0x80228a
  800d99:	6a 23                	push   $0x23
  800d9b:	68 8e 22 80 00       	push   $0x80228e
  800da0:	e8 40 0d 00 00       	call   801ae5 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800dad:	83 ec 08             	sub    $0x8,%esp
  800db0:	68 d7 0d 80 00       	push   $0x800dd7
  800db5:	6a 00                	push   $0x0
  800db7:	e8 ea fe ff ff       	call   800ca6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	79 12                	jns    800dd5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800dc3:	50                   	push   %eax
  800dc4:	68 8a 22 80 00       	push   $0x80228a
  800dc9:	6a 2c                	push   $0x2c
  800dcb:	68 8e 22 80 00       	push   $0x80228e
  800dd0:	e8 10 0d 00 00       	call   801ae5 <_panic>
	}
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dd7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dd8:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800ddd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ddf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800de2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800de6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800deb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800def:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800df1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800df4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800df5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800df8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800df9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dfa:	c3                   	ret    

00800dfb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	05 00 00 00 30       	add    $0x30000000,%eax
  800e06:	c1 e8 0c             	shr    $0xc,%eax
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	05 00 00 00 30       	add    $0x30000000,%eax
  800e16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	c1 ea 16             	shr    $0x16,%edx
  800e32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e39:	f6 c2 01             	test   $0x1,%dl
  800e3c:	74 11                	je     800e4f <fd_alloc+0x2d>
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	c1 ea 0c             	shr    $0xc,%edx
  800e43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	75 09                	jne    800e58 <fd_alloc+0x36>
			*fd_store = fd;
  800e4f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	eb 17                	jmp    800e6f <fd_alloc+0x4d>
  800e58:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e62:	75 c9                	jne    800e2d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e64:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e6a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e77:	83 f8 1f             	cmp    $0x1f,%eax
  800e7a:	77 36                	ja     800eb2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7c:	c1 e0 0c             	shl    $0xc,%eax
  800e7f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	c1 ea 16             	shr    $0x16,%edx
  800e89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e90:	f6 c2 01             	test   $0x1,%dl
  800e93:	74 24                	je     800eb9 <fd_lookup+0x48>
  800e95:	89 c2                	mov    %eax,%edx
  800e97:	c1 ea 0c             	shr    $0xc,%edx
  800e9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea1:	f6 c2 01             	test   $0x1,%dl
  800ea4:	74 1a                	je     800ec0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea9:	89 02                	mov    %eax,(%edx)
	return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	eb 13                	jmp    800ec5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb7:	eb 0c                	jmp    800ec5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebe:	eb 05                	jmp    800ec5 <fd_lookup+0x54>
  800ec0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	ba 18 23 80 00       	mov    $0x802318,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed5:	eb 13                	jmp    800eea <dev_lookup+0x23>
  800ed7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eda:	39 08                	cmp    %ecx,(%eax)
  800edc:	75 0c                	jne    800eea <dev_lookup+0x23>
			*dev = devtab[i];
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 2e                	jmp    800f18 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eea:	8b 02                	mov    (%edx),%eax
  800eec:	85 c0                	test   %eax,%eax
  800eee:	75 e7                	jne    800ed7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef0:	a1 04 40 80 00       	mov    0x804004,%eax
  800ef5:	8b 40 50             	mov    0x50(%eax),%eax
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	51                   	push   %ecx
  800efc:	50                   	push   %eax
  800efd:	68 9c 22 80 00       	push   $0x80229c
  800f02:	e8 cc f2 ff ff       	call   8001d3 <cprintf>
	*dev = 0;
  800f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 10             	sub    $0x10,%esp
  800f22:	8b 75 08             	mov    0x8(%ebp),%esi
  800f25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f32:	c1 e8 0c             	shr    $0xc,%eax
  800f35:	50                   	push   %eax
  800f36:	e8 36 ff ff ff       	call   800e71 <fd_lookup>
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 05                	js     800f47 <fd_close+0x2d>
	    || fd != fd2)
  800f42:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f45:	74 0c                	je     800f53 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f47:	84 db                	test   %bl,%bl
  800f49:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4e:	0f 44 c2             	cmove  %edx,%eax
  800f51:	eb 41                	jmp    800f94 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f59:	50                   	push   %eax
  800f5a:	ff 36                	pushl  (%esi)
  800f5c:	e8 66 ff ff ff       	call   800ec7 <dev_lookup>
  800f61:	89 c3                	mov    %eax,%ebx
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 1a                	js     800f84 <fd_close+0x6a>
		if (dev->dev_close)
  800f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	74 0b                	je     800f84 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	56                   	push   %esi
  800f7d:	ff d0                	call   *%eax
  800f7f:	89 c3                	mov    %eax,%ebx
  800f81:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 51 fc ff ff       	call   800be0 <sys_page_unmap>
	return r;
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	89 d8                	mov    %ebx,%eax
}
  800f94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa4:	50                   	push   %eax
  800fa5:	ff 75 08             	pushl  0x8(%ebp)
  800fa8:	e8 c4 fe ff ff       	call   800e71 <fd_lookup>
  800fad:	83 c4 08             	add    $0x8,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 10                	js     800fc4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	6a 01                	push   $0x1
  800fb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbc:	e8 59 ff ff ff       	call   800f1a <fd_close>
  800fc1:	83 c4 10             	add    $0x10,%esp
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <close_all>:

void
close_all(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	53                   	push   %ebx
  800fd6:	e8 c0 ff ff ff       	call   800f9b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdb:	83 c3 01             	add    $0x1,%ebx
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	83 fb 20             	cmp    $0x20,%ebx
  800fe4:	75 ec                	jne    800fd2 <close_all+0xc>
		close(i);
}
  800fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 2c             	sub    $0x2c,%esp
  800ff4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 6e fe ff ff       	call   800e71 <fd_lookup>
  801003:	83 c4 08             	add    $0x8,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	0f 88 c1 00 00 00    	js     8010cf <dup+0xe4>
		return r;
	close(newfdnum);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	56                   	push   %esi
  801012:	e8 84 ff ff ff       	call   800f9b <close>

	newfd = INDEX2FD(newfdnum);
  801017:	89 f3                	mov    %esi,%ebx
  801019:	c1 e3 0c             	shl    $0xc,%ebx
  80101c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801022:	83 c4 04             	add    $0x4,%esp
  801025:	ff 75 e4             	pushl  -0x1c(%ebp)
  801028:	e8 de fd ff ff       	call   800e0b <fd2data>
  80102d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80102f:	89 1c 24             	mov    %ebx,(%esp)
  801032:	e8 d4 fd ff ff       	call   800e0b <fd2data>
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103d:	89 f8                	mov    %edi,%eax
  80103f:	c1 e8 16             	shr    $0x16,%eax
  801042:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801049:	a8 01                	test   $0x1,%al
  80104b:	74 37                	je     801084 <dup+0x99>
  80104d:	89 f8                	mov    %edi,%eax
  80104f:	c1 e8 0c             	shr    $0xc,%eax
  801052:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801059:	f6 c2 01             	test   $0x1,%dl
  80105c:	74 26                	je     801084 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80105e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	25 07 0e 00 00       	and    $0xe07,%eax
  80106d:	50                   	push   %eax
  80106e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801071:	6a 00                	push   $0x0
  801073:	57                   	push   %edi
  801074:	6a 00                	push   $0x0
  801076:	e8 23 fb ff ff       	call   800b9e <sys_page_map>
  80107b:	89 c7                	mov    %eax,%edi
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	78 2e                	js     8010b2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801084:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801087:	89 d0                	mov    %edx,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	25 07 0e 00 00       	and    $0xe07,%eax
  80109b:	50                   	push   %eax
  80109c:	53                   	push   %ebx
  80109d:	6a 00                	push   $0x0
  80109f:	52                   	push   %edx
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 f7 fa ff ff       	call   800b9e <sys_page_map>
  8010a7:	89 c7                	mov    %eax,%edi
  8010a9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ae:	85 ff                	test   %edi,%edi
  8010b0:	79 1d                	jns    8010cf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b2:	83 ec 08             	sub    $0x8,%esp
  8010b5:	53                   	push   %ebx
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 23 fb ff ff       	call   800be0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010bd:	83 c4 08             	add    $0x8,%esp
  8010c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 16 fb ff ff       	call   800be0 <sys_page_unmap>
	return r;
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	89 f8                	mov    %edi,%eax
}
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	53                   	push   %ebx
  8010db:	83 ec 14             	sub    $0x14,%esp
  8010de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	53                   	push   %ebx
  8010e6:	e8 86 fd ff ff       	call   800e71 <fd_lookup>
  8010eb:	83 c4 08             	add    $0x8,%esp
  8010ee:	89 c2                	mov    %eax,%edx
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	78 6d                	js     801161 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fe:	ff 30                	pushl  (%eax)
  801100:	e8 c2 fd ff ff       	call   800ec7 <dev_lookup>
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 4c                	js     801158 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110f:	8b 42 08             	mov    0x8(%edx),%eax
  801112:	83 e0 03             	and    $0x3,%eax
  801115:	83 f8 01             	cmp    $0x1,%eax
  801118:	75 21                	jne    80113b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111a:	a1 04 40 80 00       	mov    0x804004,%eax
  80111f:	8b 40 50             	mov    0x50(%eax),%eax
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	53                   	push   %ebx
  801126:	50                   	push   %eax
  801127:	68 dd 22 80 00       	push   $0x8022dd
  80112c:	e8 a2 f0 ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801139:	eb 26                	jmp    801161 <read+0x8a>
	}
	if (!dev->dev_read)
  80113b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113e:	8b 40 08             	mov    0x8(%eax),%eax
  801141:	85 c0                	test   %eax,%eax
  801143:	74 17                	je     80115c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	ff 75 10             	pushl  0x10(%ebp)
  80114b:	ff 75 0c             	pushl  0xc(%ebp)
  80114e:	52                   	push   %edx
  80114f:	ff d0                	call   *%eax
  801151:	89 c2                	mov    %eax,%edx
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	eb 09                	jmp    801161 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801158:	89 c2                	mov    %eax,%edx
  80115a:	eb 05                	jmp    801161 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80115c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801161:	89 d0                	mov    %edx,%eax
  801163:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	8b 7d 08             	mov    0x8(%ebp),%edi
  801174:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	eb 21                	jmp    80119f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117e:	83 ec 04             	sub    $0x4,%esp
  801181:	89 f0                	mov    %esi,%eax
  801183:	29 d8                	sub    %ebx,%eax
  801185:	50                   	push   %eax
  801186:	89 d8                	mov    %ebx,%eax
  801188:	03 45 0c             	add    0xc(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	57                   	push   %edi
  80118d:	e8 45 ff ff ff       	call   8010d7 <read>
		if (m < 0)
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 10                	js     8011a9 <readn+0x41>
			return m;
		if (m == 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	74 0a                	je     8011a7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119d:	01 c3                	add    %eax,%ebx
  80119f:	39 f3                	cmp    %esi,%ebx
  8011a1:	72 db                	jb     80117e <readn+0x16>
  8011a3:	89 d8                	mov    %ebx,%eax
  8011a5:	eb 02                	jmp    8011a9 <readn+0x41>
  8011a7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 14             	sub    $0x14,%esp
  8011b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	53                   	push   %ebx
  8011c0:	e8 ac fc ff ff       	call   800e71 <fd_lookup>
  8011c5:	83 c4 08             	add    $0x8,%esp
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 68                	js     801236 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d8:	ff 30                	pushl  (%eax)
  8011da:	e8 e8 fc ff ff       	call   800ec7 <dev_lookup>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 47                	js     80122d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ed:	75 21                	jne    801210 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f4:	8b 40 50             	mov    0x50(%eax),%eax
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	53                   	push   %ebx
  8011fb:	50                   	push   %eax
  8011fc:	68 f9 22 80 00       	push   $0x8022f9
  801201:	e8 cd ef ff ff       	call   8001d3 <cprintf>
		return -E_INVAL;
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120e:	eb 26                	jmp    801236 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801210:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801213:	8b 52 0c             	mov    0xc(%edx),%edx
  801216:	85 d2                	test   %edx,%edx
  801218:	74 17                	je     801231 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	ff 75 10             	pushl  0x10(%ebp)
  801220:	ff 75 0c             	pushl  0xc(%ebp)
  801223:	50                   	push   %eax
  801224:	ff d2                	call   *%edx
  801226:	89 c2                	mov    %eax,%edx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	eb 09                	jmp    801236 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	eb 05                	jmp    801236 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801231:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801236:	89 d0                	mov    %edx,%eax
  801238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <seek>:

int
seek(int fdnum, off_t offset)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801243:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 75 08             	pushl  0x8(%ebp)
  80124a:	e8 22 fc ff ff       	call   800e71 <fd_lookup>
  80124f:	83 c4 08             	add    $0x8,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 0e                	js     801264 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801256:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801259:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 14             	sub    $0x14,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	53                   	push   %ebx
  801275:	e8 f7 fb ff ff       	call   800e71 <fd_lookup>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	89 c2                	mov    %eax,%edx
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 65                	js     8012e8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	ff 30                	pushl  (%eax)
  80128f:	e8 33 fc ff ff       	call   800ec7 <dev_lookup>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 44                	js     8012df <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a2:	75 21                	jne    8012c5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a9:	8b 40 50             	mov    0x50(%eax),%eax
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	53                   	push   %ebx
  8012b0:	50                   	push   %eax
  8012b1:	68 bc 22 80 00       	push   $0x8022bc
  8012b6:	e8 18 ef ff ff       	call   8001d3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c3:	eb 23                	jmp    8012e8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c8:	8b 52 18             	mov    0x18(%edx),%edx
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	74 14                	je     8012e3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	ff 75 0c             	pushl  0xc(%ebp)
  8012d5:	50                   	push   %eax
  8012d6:	ff d2                	call   *%edx
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	eb 09                	jmp    8012e8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	eb 05                	jmp    8012e8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e8:	89 d0                	mov    %edx,%eax
  8012ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ed:	c9                   	leave  
  8012ee:	c3                   	ret    

008012ef <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 14             	sub    $0x14,%esp
  8012f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 08             	pushl  0x8(%ebp)
  801300:	e8 6c fb ff ff       	call   800e71 <fd_lookup>
  801305:	83 c4 08             	add    $0x8,%esp
  801308:	89 c2                	mov    %eax,%edx
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 58                	js     801366 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	ff 30                	pushl  (%eax)
  80131a:	e8 a8 fb ff ff       	call   800ec7 <dev_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 37                	js     80135d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801326:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801329:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132d:	74 32                	je     801361 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80132f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801332:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801339:	00 00 00 
	stat->st_isdir = 0;
  80133c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801343:	00 00 00 
	stat->st_dev = dev;
  801346:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	53                   	push   %ebx
  801350:	ff 75 f0             	pushl  -0x10(%ebp)
  801353:	ff 50 14             	call   *0x14(%eax)
  801356:	89 c2                	mov    %eax,%edx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	eb 09                	jmp    801366 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	eb 05                	jmp    801366 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801361:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801366:	89 d0                	mov    %edx,%eax
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	6a 00                	push   $0x0
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 e3 01 00 00       	call   801562 <open>
  80137f:	89 c3                	mov    %eax,%ebx
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 1b                	js     8013a3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	ff 75 0c             	pushl  0xc(%ebp)
  80138e:	50                   	push   %eax
  80138f:	e8 5b ff ff ff       	call   8012ef <fstat>
  801394:	89 c6                	mov    %eax,%esi
	close(fd);
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	e8 fd fb ff ff       	call   800f9b <close>
	return r;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	89 f0                	mov    %esi,%eax
}
  8013a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a6:	5b                   	pop    %ebx
  8013a7:	5e                   	pop    %esi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ba:	75 12                	jne    8013ce <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	6a 01                	push   $0x1
  8013c1:	e8 3c 08 00 00       	call   801c02 <ipc_find_env>
  8013c6:	a3 00 40 80 00       	mov    %eax,0x804000
  8013cb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ce:	6a 07                	push   $0x7
  8013d0:	68 00 50 80 00       	push   $0x805000
  8013d5:	56                   	push   %esi
  8013d6:	ff 35 00 40 80 00    	pushl  0x804000
  8013dc:	e8 bf 07 00 00       	call   801ba0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e1:	83 c4 0c             	add    $0xc,%esp
  8013e4:	6a 00                	push   $0x0
  8013e6:	53                   	push   %ebx
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 3d 07 00 00       	call   801b2b <ipc_recv>
}
  8013ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801401:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801406:	8b 45 0c             	mov    0xc(%ebp),%eax
  801409:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80140e:	ba 00 00 00 00       	mov    $0x0,%edx
  801413:	b8 02 00 00 00       	mov    $0x2,%eax
  801418:	e8 8d ff ff ff       	call   8013aa <fsipc>
}
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	8b 40 0c             	mov    0xc(%eax),%eax
  80142b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801430:	ba 00 00 00 00       	mov    $0x0,%edx
  801435:	b8 06 00 00 00       	mov    $0x6,%eax
  80143a:	e8 6b ff ff ff       	call   8013aa <fsipc>
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	8b 40 0c             	mov    0xc(%eax),%eax
  801451:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801456:	ba 00 00 00 00       	mov    $0x0,%edx
  80145b:	b8 05 00 00 00       	mov    $0x5,%eax
  801460:	e8 45 ff ff ff       	call   8013aa <fsipc>
  801465:	85 c0                	test   %eax,%eax
  801467:	78 2c                	js     801495 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	68 00 50 80 00       	push   $0x805000
  801471:	53                   	push   %ebx
  801472:	e8 e1 f2 ff ff       	call   800758 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801477:	a1 80 50 80 00       	mov    0x805080,%eax
  80147c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801482:	a1 84 50 80 00       	mov    0x805084,%eax
  801487:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014af:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014b4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014b9:	0f 47 c2             	cmova  %edx,%eax
  8014bc:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 0c             	pushl  0xc(%ebp)
  8014c5:	68 08 50 80 00       	push   $0x805008
  8014ca:	e8 1b f4 ff ff       	call   8008ea <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d9:	e8 cc fe ff ff       	call   8013aa <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014f3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801503:	e8 a2 fe ff ff       	call   8013aa <fsipc>
  801508:	89 c3                	mov    %eax,%ebx
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 4b                	js     801559 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80150e:	39 c6                	cmp    %eax,%esi
  801510:	73 16                	jae    801528 <devfile_read+0x48>
  801512:	68 28 23 80 00       	push   $0x802328
  801517:	68 2f 23 80 00       	push   $0x80232f
  80151c:	6a 7c                	push   $0x7c
  80151e:	68 44 23 80 00       	push   $0x802344
  801523:	e8 bd 05 00 00       	call   801ae5 <_panic>
	assert(r <= PGSIZE);
  801528:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80152d:	7e 16                	jle    801545 <devfile_read+0x65>
  80152f:	68 4f 23 80 00       	push   $0x80234f
  801534:	68 2f 23 80 00       	push   $0x80232f
  801539:	6a 7d                	push   $0x7d
  80153b:	68 44 23 80 00       	push   $0x802344
  801540:	e8 a0 05 00 00       	call   801ae5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	50                   	push   %eax
  801549:	68 00 50 80 00       	push   $0x805000
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	e8 94 f3 ff ff       	call   8008ea <memmove>
	return r;
  801556:	83 c4 10             	add    $0x10,%esp
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	53                   	push   %ebx
  801566:	83 ec 20             	sub    $0x20,%esp
  801569:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80156c:	53                   	push   %ebx
  80156d:	e8 ad f1 ff ff       	call   80071f <strlen>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80157a:	7f 67                	jg     8015e3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	e8 9a f8 ff ff       	call   800e22 <fd_alloc>
  801588:	83 c4 10             	add    $0x10,%esp
		return r;
  80158b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 57                	js     8015e8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	68 00 50 80 00       	push   $0x805000
  80159a:	e8 b9 f1 ff ff       	call   800758 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80159f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8015af:	e8 f6 fd ff ff       	call   8013aa <fsipc>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	79 14                	jns    8015d1 <open+0x6f>
		fd_close(fd, 0);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	6a 00                	push   $0x0
  8015c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c5:	e8 50 f9 ff ff       	call   800f1a <fd_close>
		return r;
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	89 da                	mov    %ebx,%edx
  8015cf:	eb 17                	jmp    8015e8 <open+0x86>
	}

	return fd2num(fd);
  8015d1:	83 ec 0c             	sub    $0xc,%esp
  8015d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d7:	e8 1f f8 ff ff       	call   800dfb <fd2num>
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	eb 05                	jmp    8015e8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015e3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015e8:	89 d0                	mov    %edx,%eax
  8015ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ff:	e8 a6 fd ff ff       	call   8013aa <fsipc>
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	56                   	push   %esi
  80160a:	53                   	push   %ebx
  80160b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	ff 75 08             	pushl  0x8(%ebp)
  801614:	e8 f2 f7 ff ff       	call   800e0b <fd2data>
  801619:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	68 5b 23 80 00       	push   $0x80235b
  801623:	53                   	push   %ebx
  801624:	e8 2f f1 ff ff       	call   800758 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801629:	8b 46 04             	mov    0x4(%esi),%eax
  80162c:	2b 06                	sub    (%esi),%eax
  80162e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801634:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163b:	00 00 00 
	stat->st_dev = &devpipe;
  80163e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801645:	30 80 00 
	return 0;
}
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
  80164d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801650:	5b                   	pop    %ebx
  801651:	5e                   	pop    %esi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80165e:	53                   	push   %ebx
  80165f:	6a 00                	push   $0x0
  801661:	e8 7a f5 ff ff       	call   800be0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801666:	89 1c 24             	mov    %ebx,(%esp)
  801669:	e8 9d f7 ff ff       	call   800e0b <fd2data>
  80166e:	83 c4 08             	add    $0x8,%esp
  801671:	50                   	push   %eax
  801672:	6a 00                	push   $0x0
  801674:	e8 67 f5 ff ff       	call   800be0 <sys_page_unmap>
}
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 1c             	sub    $0x1c,%esp
  801687:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80168a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80168c:	a1 04 40 80 00       	mov    0x804004,%eax
  801691:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	ff 75 e0             	pushl  -0x20(%ebp)
  80169a:	e8 a3 05 00 00       	call   801c42 <pageref>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	89 3c 24             	mov    %edi,(%esp)
  8016a4:	e8 99 05 00 00       	call   801c42 <pageref>
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	39 c3                	cmp    %eax,%ebx
  8016ae:	0f 94 c1             	sete   %cl
  8016b1:	0f b6 c9             	movzbl %cl,%ecx
  8016b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016b7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016bd:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8016c0:	39 ce                	cmp    %ecx,%esi
  8016c2:	74 1b                	je     8016df <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016c4:	39 c3                	cmp    %eax,%ebx
  8016c6:	75 c4                	jne    80168c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016c8:	8b 42 60             	mov    0x60(%edx),%eax
  8016cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ce:	50                   	push   %eax
  8016cf:	56                   	push   %esi
  8016d0:	68 62 23 80 00       	push   $0x802362
  8016d5:	e8 f9 ea ff ff       	call   8001d3 <cprintf>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb ad                	jmp    80168c <_pipeisclosed+0xe>
	}
}
  8016df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e5:	5b                   	pop    %ebx
  8016e6:	5e                   	pop    %esi
  8016e7:	5f                   	pop    %edi
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    

008016ea <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	57                   	push   %edi
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 28             	sub    $0x28,%esp
  8016f3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016f6:	56                   	push   %esi
  8016f7:	e8 0f f7 ff ff       	call   800e0b <fd2data>
  8016fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	bf 00 00 00 00       	mov    $0x0,%edi
  801706:	eb 4b                	jmp    801753 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801708:	89 da                	mov    %ebx,%edx
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	e8 6d ff ff ff       	call   80167e <_pipeisclosed>
  801711:	85 c0                	test   %eax,%eax
  801713:	75 48                	jne    80175d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801715:	e8 22 f4 ff ff       	call   800b3c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80171a:	8b 43 04             	mov    0x4(%ebx),%eax
  80171d:	8b 0b                	mov    (%ebx),%ecx
  80171f:	8d 51 20             	lea    0x20(%ecx),%edx
  801722:	39 d0                	cmp    %edx,%eax
  801724:	73 e2                	jae    801708 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801729:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80172d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801730:	89 c2                	mov    %eax,%edx
  801732:	c1 fa 1f             	sar    $0x1f,%edx
  801735:	89 d1                	mov    %edx,%ecx
  801737:	c1 e9 1b             	shr    $0x1b,%ecx
  80173a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80173d:	83 e2 1f             	and    $0x1f,%edx
  801740:	29 ca                	sub    %ecx,%edx
  801742:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801746:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80174a:	83 c0 01             	add    $0x1,%eax
  80174d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801750:	83 c7 01             	add    $0x1,%edi
  801753:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801756:	75 c2                	jne    80171a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801758:	8b 45 10             	mov    0x10(%ebp),%eax
  80175b:	eb 05                	jmp    801762 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5f                   	pop    %edi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	57                   	push   %edi
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 18             	sub    $0x18,%esp
  801773:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801776:	57                   	push   %edi
  801777:	e8 8f f6 ff ff       	call   800e0b <fd2data>
  80177c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	bb 00 00 00 00       	mov    $0x0,%ebx
  801786:	eb 3d                	jmp    8017c5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801788:	85 db                	test   %ebx,%ebx
  80178a:	74 04                	je     801790 <devpipe_read+0x26>
				return i;
  80178c:	89 d8                	mov    %ebx,%eax
  80178e:	eb 44                	jmp    8017d4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801790:	89 f2                	mov    %esi,%edx
  801792:	89 f8                	mov    %edi,%eax
  801794:	e8 e5 fe ff ff       	call   80167e <_pipeisclosed>
  801799:	85 c0                	test   %eax,%eax
  80179b:	75 32                	jne    8017cf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80179d:	e8 9a f3 ff ff       	call   800b3c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017a2:	8b 06                	mov    (%esi),%eax
  8017a4:	3b 46 04             	cmp    0x4(%esi),%eax
  8017a7:	74 df                	je     801788 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a9:	99                   	cltd   
  8017aa:	c1 ea 1b             	shr    $0x1b,%edx
  8017ad:	01 d0                	add    %edx,%eax
  8017af:	83 e0 1f             	and    $0x1f,%eax
  8017b2:	29 d0                	sub    %edx,%eax
  8017b4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017bc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017bf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c2:	83 c3 01             	add    $0x1,%ebx
  8017c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017c8:	75 d8                	jne    8017a2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8017cd:	eb 05                	jmp    8017d4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5f                   	pop    %edi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e7:	50                   	push   %eax
  8017e8:	e8 35 f6 ff ff       	call   800e22 <fd_alloc>
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	0f 88 2c 01 00 00    	js     801926 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	68 07 04 00 00       	push   $0x407
  801802:	ff 75 f4             	pushl  -0xc(%ebp)
  801805:	6a 00                	push   $0x0
  801807:	e8 4f f3 ff ff       	call   800b5b <sys_page_alloc>
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	89 c2                	mov    %eax,%edx
  801811:	85 c0                	test   %eax,%eax
  801813:	0f 88 0d 01 00 00    	js     801926 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	e8 fd f5 ff ff       	call   800e22 <fd_alloc>
  801825:	89 c3                	mov    %eax,%ebx
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	85 c0                	test   %eax,%eax
  80182c:	0f 88 e2 00 00 00    	js     801914 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	68 07 04 00 00       	push   $0x407
  80183a:	ff 75 f0             	pushl  -0x10(%ebp)
  80183d:	6a 00                	push   $0x0
  80183f:	e8 17 f3 ff ff       	call   800b5b <sys_page_alloc>
  801844:	89 c3                	mov    %eax,%ebx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	0f 88 c3 00 00 00    	js     801914 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	ff 75 f4             	pushl  -0xc(%ebp)
  801857:	e8 af f5 ff ff       	call   800e0b <fd2data>
  80185c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185e:	83 c4 0c             	add    $0xc,%esp
  801861:	68 07 04 00 00       	push   $0x407
  801866:	50                   	push   %eax
  801867:	6a 00                	push   $0x0
  801869:	e8 ed f2 ff ff       	call   800b5b <sys_page_alloc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	0f 88 89 00 00 00    	js     801904 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff 75 f0             	pushl  -0x10(%ebp)
  801881:	e8 85 f5 ff ff       	call   800e0b <fd2data>
  801886:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80188d:	50                   	push   %eax
  80188e:	6a 00                	push   $0x0
  801890:	56                   	push   %esi
  801891:	6a 00                	push   $0x0
  801893:	e8 06 f3 ff ff       	call   800b9e <sys_page_map>
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	83 c4 20             	add    $0x20,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 55                	js     8018f6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018a1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018aa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018b6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d1:	e8 25 f5 ff ff       	call   800dfb <fd2num>
  8018d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018db:	83 c4 04             	add    $0x4,%esp
  8018de:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e1:	e8 15 f5 ff ff       	call   800dfb <fd2num>
  8018e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e9:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f4:	eb 30                	jmp    801926 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	56                   	push   %esi
  8018fa:	6a 00                	push   $0x0
  8018fc:	e8 df f2 ff ff       	call   800be0 <sys_page_unmap>
  801901:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	ff 75 f0             	pushl  -0x10(%ebp)
  80190a:	6a 00                	push   $0x0
  80190c:	e8 cf f2 ff ff       	call   800be0 <sys_page_unmap>
  801911:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	ff 75 f4             	pushl  -0xc(%ebp)
  80191a:	6a 00                	push   $0x0
  80191c:	e8 bf f2 ff ff       	call   800be0 <sys_page_unmap>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801926:	89 d0                	mov    %edx,%eax
  801928:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801938:	50                   	push   %eax
  801939:	ff 75 08             	pushl  0x8(%ebp)
  80193c:	e8 30 f5 ff ff       	call   800e71 <fd_lookup>
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 18                	js     801960 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	ff 75 f4             	pushl  -0xc(%ebp)
  80194e:	e8 b8 f4 ff ff       	call   800e0b <fd2data>
	return _pipeisclosed(fd, p);
  801953:	89 c2                	mov    %eax,%edx
  801955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801958:	e8 21 fd ff ff       	call   80167e <_pipeisclosed>
  80195d:	83 c4 10             	add    $0x10,%esp
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801972:	68 7a 23 80 00       	push   $0x80237a
  801977:	ff 75 0c             	pushl  0xc(%ebp)
  80197a:	e8 d9 ed ff ff       	call   800758 <strcpy>
	return 0;
}
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	57                   	push   %edi
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
  80198c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801992:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801997:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80199d:	eb 2d                	jmp    8019cc <devcons_write+0x46>
		m = n - tot;
  80199f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019a2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019a4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019a7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019ac:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019af:	83 ec 04             	sub    $0x4,%esp
  8019b2:	53                   	push   %ebx
  8019b3:	03 45 0c             	add    0xc(%ebp),%eax
  8019b6:	50                   	push   %eax
  8019b7:	57                   	push   %edi
  8019b8:	e8 2d ef ff ff       	call   8008ea <memmove>
		sys_cputs(buf, m);
  8019bd:	83 c4 08             	add    $0x8,%esp
  8019c0:	53                   	push   %ebx
  8019c1:	57                   	push   %edi
  8019c2:	e8 d8 f0 ff ff       	call   800a9f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c7:	01 de                	add    %ebx,%esi
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	89 f0                	mov    %esi,%eax
  8019ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019d1:	72 cc                	jb     80199f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5f                   	pop    %edi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ea:	74 2a                	je     801a16 <devcons_read+0x3b>
  8019ec:	eb 05                	jmp    8019f3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ee:	e8 49 f1 ff ff       	call   800b3c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019f3:	e8 c5 f0 ff ff       	call   800abd <sys_cgetc>
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	74 f2                	je     8019ee <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 16                	js     801a16 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a00:	83 f8 04             	cmp    $0x4,%eax
  801a03:	74 0c                	je     801a11 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a08:	88 02                	mov    %al,(%edx)
	return 1;
  801a0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0f:	eb 05                	jmp    801a16 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a11:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a24:	6a 01                	push   $0x1
  801a26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a29:	50                   	push   %eax
  801a2a:	e8 70 f0 ff ff       	call   800a9f <sys_cputs>
}
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <getchar>:

int
getchar(void)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a3a:	6a 01                	push   $0x1
  801a3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a3f:	50                   	push   %eax
  801a40:	6a 00                	push   $0x0
  801a42:	e8 90 f6 ff ff       	call   8010d7 <read>
	if (r < 0)
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 0f                	js     801a5d <getchar+0x29>
		return r;
	if (r < 1)
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	7e 06                	jle    801a58 <getchar+0x24>
		return -E_EOF;
	return c;
  801a52:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a56:	eb 05                	jmp    801a5d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a58:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	ff 75 08             	pushl  0x8(%ebp)
  801a6c:	e8 00 f4 ff ff       	call   800e71 <fd_lookup>
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 11                	js     801a89 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a81:	39 10                	cmp    %edx,(%eax)
  801a83:	0f 94 c0             	sete   %al
  801a86:	0f b6 c0             	movzbl %al,%eax
}
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <opencons>:

int
opencons(void)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a94:	50                   	push   %eax
  801a95:	e8 88 f3 ff ff       	call   800e22 <fd_alloc>
  801a9a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a9d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 3e                	js     801ae1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	68 07 04 00 00       	push   $0x407
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 a6 f0 ff ff       	call   800b5b <sys_page_alloc>
  801ab5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 23                	js     801ae1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801abe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	50                   	push   %eax
  801ad7:	e8 1f f3 ff ff       	call   800dfb <fd2num>
  801adc:	89 c2                	mov    %eax,%edx
  801ade:	83 c4 10             	add    $0x10,%esp
}
  801ae1:	89 d0                	mov    %edx,%eax
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aed:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801af3:	e8 25 f0 ff ff       	call   800b1d <sys_getenvid>
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 0c             	pushl  0xc(%ebp)
  801afe:	ff 75 08             	pushl  0x8(%ebp)
  801b01:	56                   	push   %esi
  801b02:	50                   	push   %eax
  801b03:	68 88 23 80 00       	push   $0x802388
  801b08:	e8 c6 e6 ff ff       	call   8001d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b0d:	83 c4 18             	add    $0x18,%esp
  801b10:	53                   	push   %ebx
  801b11:	ff 75 10             	pushl  0x10(%ebp)
  801b14:	e8 69 e6 ff ff       	call   800182 <vcprintf>
	cprintf("\n");
  801b19:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  801b20:	e8 ae e6 ff ff       	call   8001d3 <cprintf>
  801b25:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b28:	cc                   	int3   
  801b29:	eb fd                	jmp    801b28 <_panic+0x43>

00801b2b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	8b 75 08             	mov    0x8(%ebp),%esi
  801b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	75 12                	jne    801b4f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	68 00 00 c0 ee       	push   $0xeec00000
  801b45:	e8 c1 f1 ff ff       	call   800d0b <sys_ipc_recv>
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	eb 0c                	jmp    801b5b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	50                   	push   %eax
  801b53:	e8 b3 f1 ff ff       	call   800d0b <sys_ipc_recv>
  801b58:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b5b:	85 f6                	test   %esi,%esi
  801b5d:	0f 95 c1             	setne  %cl
  801b60:	85 db                	test   %ebx,%ebx
  801b62:	0f 95 c2             	setne  %dl
  801b65:	84 d1                	test   %dl,%cl
  801b67:	74 09                	je     801b72 <ipc_recv+0x47>
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	c1 ea 1f             	shr    $0x1f,%edx
  801b6e:	84 d2                	test   %dl,%dl
  801b70:	75 27                	jne    801b99 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b72:	85 f6                	test   %esi,%esi
  801b74:	74 0a                	je     801b80 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b76:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7b:	8b 40 7c             	mov    0x7c(%eax),%eax
  801b7e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b80:	85 db                	test   %ebx,%ebx
  801b82:	74 0d                	je     801b91 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801b84:	a1 04 40 80 00       	mov    0x804004,%eax
  801b89:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801b8f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b91:	a1 04 40 80 00       	mov    0x804004,%eax
  801b96:	8b 40 78             	mov    0x78(%eax),%eax
}
  801b99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801bb2:	85 db                	test   %ebx,%ebx
  801bb4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bb9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bbc:	ff 75 14             	pushl  0x14(%ebp)
  801bbf:	53                   	push   %ebx
  801bc0:	56                   	push   %esi
  801bc1:	57                   	push   %edi
  801bc2:	e8 21 f1 ff ff       	call   800ce8 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	c1 ea 1f             	shr    $0x1f,%edx
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	84 d2                	test   %dl,%dl
  801bd1:	74 17                	je     801bea <ipc_send+0x4a>
  801bd3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bd6:	74 12                	je     801bea <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801bd8:	50                   	push   %eax
  801bd9:	68 ac 23 80 00       	push   $0x8023ac
  801bde:	6a 47                	push   $0x47
  801be0:	68 ba 23 80 00       	push   $0x8023ba
  801be5:	e8 fb fe ff ff       	call   801ae5 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801bea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bed:	75 07                	jne    801bf6 <ipc_send+0x56>
			sys_yield();
  801bef:	e8 48 ef ff ff       	call   800b3c <sys_yield>
  801bf4:	eb c6                	jmp    801bbc <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	75 c2                	jne    801bbc <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c0d:	89 c2                	mov    %eax,%edx
  801c0f:	c1 e2 07             	shl    $0x7,%edx
  801c12:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801c19:	8b 52 58             	mov    0x58(%edx),%edx
  801c1c:	39 ca                	cmp    %ecx,%edx
  801c1e:	75 11                	jne    801c31 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	c1 e2 07             	shl    $0x7,%edx
  801c25:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801c2c:	8b 40 50             	mov    0x50(%eax),%eax
  801c2f:	eb 0f                	jmp    801c40 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c31:	83 c0 01             	add    $0x1,%eax
  801c34:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c39:	75 d2                	jne    801c0d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c48:	89 d0                	mov    %edx,%eax
  801c4a:	c1 e8 16             	shr    $0x16,%eax
  801c4d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c54:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c59:	f6 c1 01             	test   $0x1,%cl
  801c5c:	74 1d                	je     801c7b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c5e:	c1 ea 0c             	shr    $0xc,%edx
  801c61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c68:	f6 c2 01             	test   $0x1,%dl
  801c6b:	74 0e                	je     801c7b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c6d:	c1 ea 0c             	shr    $0xc,%edx
  801c70:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c77:	ef 
  801c78:	0f b7 c0             	movzwl %ax,%eax
}
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 f6                	test   %esi,%esi
  801c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9d:	89 ca                	mov    %ecx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	75 3d                	jne    801ce0 <__udivdi3+0x60>
  801ca3:	39 cf                	cmp    %ecx,%edi
  801ca5:	0f 87 c5 00 00 00    	ja     801d70 <__udivdi3+0xf0>
  801cab:	85 ff                	test   %edi,%edi
  801cad:	89 fd                	mov    %edi,%ebp
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x3c>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp
  801cbc:	89 c8                	mov    %ecx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	89 cf                	mov    %ecx,%edi
  801cc8:	f7 f5                	div    %ebp
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	77 74                	ja     801d58 <__udivdi3+0xd8>
  801ce4:	0f bd fe             	bsr    %esi,%edi
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	0f 84 98 00 00 00    	je     801d88 <__udivdi3+0x108>
  801cf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	29 fb                	sub    %edi,%ebx
  801cfb:	d3 e6                	shl    %cl,%esi
  801cfd:	89 d9                	mov    %ebx,%ecx
  801cff:	d3 ed                	shr    %cl,%ebp
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e0                	shl    %cl,%eax
  801d05:	09 ee                	or     %ebp,%esi
  801d07:	89 d9                	mov    %ebx,%ecx
  801d09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0d:	89 d5                	mov    %edx,%ebp
  801d0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d13:	d3 ed                	shr    %cl,%ebp
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e2                	shl    %cl,%edx
  801d19:	89 d9                	mov    %ebx,%ecx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	89 ea                	mov    %ebp,%edx
  801d23:	f7 f6                	div    %esi
  801d25:	89 d5                	mov    %edx,%ebp
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	f7 64 24 0c          	mull   0xc(%esp)
  801d2d:	39 d5                	cmp    %edx,%ebp
  801d2f:	72 10                	jb     801d41 <__udivdi3+0xc1>
  801d31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e6                	shl    %cl,%esi
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	73 07                	jae    801d44 <__udivdi3+0xc4>
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	75 03                	jne    801d44 <__udivdi3+0xc4>
  801d41:	83 eb 01             	sub    $0x1,%ebx
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	31 ff                	xor    %edi,%edi
  801d5a:	31 db                	xor    %ebx,%ebx
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	89 fa                	mov    %edi,%edx
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
  801d68:	90                   	nop
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	f7 f7                	div    %edi
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 fa                	mov    %edi,%edx
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	39 ce                	cmp    %ecx,%esi
  801d8a:	72 0c                	jb     801d98 <__udivdi3+0x118>
  801d8c:	31 db                	xor    %ebx,%ebx
  801d8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d92:	0f 87 34 ff ff ff    	ja     801ccc <__udivdi3+0x4c>
  801d98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d9d:	e9 2a ff ff ff       	jmp    801ccc <__udivdi3+0x4c>
  801da2:	66 90                	xchg   %ax,%ax
  801da4:	66 90                	xchg   %ax,%ax
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	66 90                	xchg   %ax,%ax
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 d2                	test   %edx,%edx
  801dc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd1:	89 f3                	mov    %esi,%ebx
  801dd3:	89 3c 24             	mov    %edi,(%esp)
  801dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dda:	75 1c                	jne    801df8 <__umoddi3+0x48>
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	76 50                	jbe    801e30 <__umoddi3+0x80>
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	f7 f7                	div    %edi
  801de6:	89 d0                	mov    %edx,%eax
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	39 f2                	cmp    %esi,%edx
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	77 52                	ja     801e50 <__umoddi3+0xa0>
  801dfe:	0f bd ea             	bsr    %edx,%ebp
  801e01:	83 f5 1f             	xor    $0x1f,%ebp
  801e04:	75 5a                	jne    801e60 <__umoddi3+0xb0>
  801e06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	39 0c 24             	cmp    %ecx,(%esp)
  801e13:	0f 86 d7 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e21:	83 c4 1c             	add    $0x1c,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	85 ff                	test   %edi,%edi
  801e32:	89 fd                	mov    %edi,%ebp
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 f0                	mov    %esi,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 c8                	mov    %ecx,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	eb 99                	jmp    801de8 <__umoddi3+0x38>
  801e4f:	90                   	nop
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	83 c4 1c             	add    $0x1c,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	8b 34 24             	mov    (%esp),%esi
  801e63:	bf 20 00 00 00       	mov    $0x20,%edi
  801e68:	89 e9                	mov    %ebp,%ecx
  801e6a:	29 ef                	sub    %ebp,%edi
  801e6c:	d3 e0                	shl    %cl,%eax
  801e6e:	89 f9                	mov    %edi,%ecx
  801e70:	89 f2                	mov    %esi,%edx
  801e72:	d3 ea                	shr    %cl,%edx
  801e74:	89 e9                	mov    %ebp,%ecx
  801e76:	09 c2                	or     %eax,%edx
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	89 14 24             	mov    %edx,(%esp)
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	d3 e2                	shl    %cl,%edx
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	89 c6                	mov    %eax,%esi
  801e91:	d3 e3                	shl    %cl,%ebx
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 d0                	mov    %edx,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	09 d8                	or     %ebx,%eax
  801e9d:	89 d3                	mov    %edx,%ebx
  801e9f:	89 f2                	mov    %esi,%edx
  801ea1:	f7 34 24             	divl   (%esp)
  801ea4:	89 d6                	mov    %edx,%esi
  801ea6:	d3 e3                	shl    %cl,%ebx
  801ea8:	f7 64 24 04          	mull   0x4(%esp)
  801eac:	39 d6                	cmp    %edx,%esi
  801eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb2:	89 d1                	mov    %edx,%ecx
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	72 08                	jb     801ec0 <__umoddi3+0x110>
  801eb8:	75 11                	jne    801ecb <__umoddi3+0x11b>
  801eba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ebe:	73 0b                	jae    801ecb <__umoddi3+0x11b>
  801ec0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ec4:	1b 14 24             	sbb    (%esp),%edx
  801ec7:	89 d1                	mov    %edx,%ecx
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ecf:	29 da                	sub    %ebx,%edx
  801ed1:	19 ce                	sbb    %ecx,%esi
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 f0                	mov    %esi,%eax
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	d3 ea                	shr    %cl,%edx
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	09 d0                	or     %edx,%eax
  801ee3:	89 f2                	mov    %esi,%edx
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 f9                	sub    %edi,%ecx
  801ef2:	19 d6                	sbb    %edx,%esi
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801efc:	e9 18 ff ff ff       	jmp    801e19 <__umoddi3+0x69>
