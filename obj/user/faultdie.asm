
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
  800045:	68 e0 1e 80 00       	push   $0x801ee0
  80004a:	e8 6c 01 00 00       	call   8001bb <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 b1 0a 00 00       	call   800b05 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 68 0a 00 00       	call   800ac4 <sys_env_destroy>
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
  80006c:	e8 c3 0c 00 00       	call   800d34 <set_pgfault_handler>
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
  800093:	e8 6d 0a 00 00       	call   800b05 <sys_getenvid>
  800098:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80009e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000a3:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a8:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000ad:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000b0:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000b6:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000b9:	39 c8                	cmp    %ecx,%eax
  8000bb:	0f 44 fb             	cmove  %ebx,%edi
  8000be:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000c3:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000c6:	83 c2 01             	add    $0x1,%edx
  8000c9:	83 c3 7c             	add    $0x7c,%ebx
  8000cc:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000d2:	75 d9                	jne    8000ad <libmain+0x2d>
  8000d4:	89 f0                	mov    %esi,%eax
  8000d6:	84 c0                	test   %al,%al
  8000d8:	74 06                	je     8000e0 <libmain+0x60>
  8000da:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000e4:	7e 0a                	jle    8000f0 <libmain+0x70>
		binaryname = argv[0];
  8000e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e9:	8b 00                	mov    (%eax),%eax
  8000eb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	ff 75 0c             	pushl  0xc(%ebp)
  8000f6:	ff 75 08             	pushl  0x8(%ebp)
  8000f9:	e8 63 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 0b 00 00 00       	call   80010e <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800114:	e8 75 0e 00 00       	call   800f8e <close_all>
	sys_env_destroy(0);
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	6a 00                	push   $0x0
  80011e:	e8 a1 09 00 00       	call   800ac4 <sys_env_destroy>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 04             	sub    $0x4,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 13                	mov    (%ebx),%edx
  800134:	8d 42 01             	lea    0x1(%edx),%eax
  800137:	89 03                	mov    %eax,(%ebx)
  800139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	75 1a                	jne    800161 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	68 ff 00 00 00       	push   $0xff
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	50                   	push   %eax
  800153:	e8 2f 09 00 00       	call   800a87 <sys_cputs>
		b->idx = 0;
  800158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800161:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800165:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800173:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017a:	00 00 00 
	b.cnt = 0;
  80017d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800184:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800187:	ff 75 0c             	pushl  0xc(%ebp)
  80018a:	ff 75 08             	pushl  0x8(%ebp)
  80018d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800193:	50                   	push   %eax
  800194:	68 28 01 80 00       	push   $0x800128
  800199:	e8 54 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019e:	83 c4 08             	add    $0x8,%esp
  8001a1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 d4 08 00 00       	call   800a87 <sys_cputs>

	return b.cnt;
}
  8001b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c4:	50                   	push   %eax
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	e8 9d ff ff ff       	call   80016a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 1c             	sub    $0x1c,%esp
  8001d8:	89 c7                	mov    %eax,%edi
  8001da:	89 d6                	mov    %edx,%esi
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f6:	39 d3                	cmp    %edx,%ebx
  8001f8:	72 05                	jb     8001ff <printnum+0x30>
  8001fa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fd:	77 45                	ja     800244 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	ff 75 18             	pushl  0x18(%ebp)
  800205:	8b 45 14             	mov    0x14(%ebp),%eax
  800208:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020b:	53                   	push   %ebx
  80020c:	ff 75 10             	pushl  0x10(%ebp)
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	ff 75 e4             	pushl  -0x1c(%ebp)
  800215:	ff 75 e0             	pushl  -0x20(%ebp)
  800218:	ff 75 dc             	pushl  -0x24(%ebp)
  80021b:	ff 75 d8             	pushl  -0x28(%ebp)
  80021e:	e8 1d 1a 00 00       	call   801c40 <__udivdi3>
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	89 f2                	mov    %esi,%edx
  80022a:	89 f8                	mov    %edi,%eax
  80022c:	e8 9e ff ff ff       	call   8001cf <printnum>
  800231:	83 c4 20             	add    $0x20,%esp
  800234:	eb 18                	jmp    80024e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	ff 75 18             	pushl  0x18(%ebp)
  80023d:	ff d7                	call   *%edi
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	eb 03                	jmp    800247 <printnum+0x78>
  800244:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	83 eb 01             	sub    $0x1,%ebx
  80024a:	85 db                	test   %ebx,%ebx
  80024c:	7f e8                	jg     800236 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	83 ec 04             	sub    $0x4,%esp
  800255:	ff 75 e4             	pushl  -0x1c(%ebp)
  800258:	ff 75 e0             	pushl  -0x20(%ebp)
  80025b:	ff 75 dc             	pushl  -0x24(%ebp)
  80025e:	ff 75 d8             	pushl  -0x28(%ebp)
  800261:	e8 0a 1b 00 00       	call   801d70 <__umoddi3>
  800266:	83 c4 14             	add    $0x14,%esp
  800269:	0f be 80 06 1f 80 00 	movsbl 0x801f06(%eax),%eax
  800270:	50                   	push   %eax
  800271:	ff d7                	call   *%edi
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x38>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c7:	73 0a                	jae    8002d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	88 02                	mov    %al,(%edx)
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002de:	50                   	push   %eax
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	e8 05 00 00 00       	call   8002f2 <vprintfmt>
	va_end(ap);
}
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 2c             	sub    $0x2c,%esp
  8002fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800301:	8b 7d 10             	mov    0x10(%ebp),%edi
  800304:	eb 12                	jmp    800318 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800306:	85 c0                	test   %eax,%eax
  800308:	0f 84 89 03 00 00    	je     800697 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	53                   	push   %ebx
  800312:	50                   	push   %eax
  800313:	ff d6                	call   *%esi
  800315:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800318:	83 c7 01             	add    $0x1,%edi
  80031b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031f:	83 f8 25             	cmp    $0x25,%eax
  800322:	75 e2                	jne    800306 <vprintfmt+0x14>
  800324:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800328:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800336:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 07                	jmp    80034b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8d 47 01             	lea    0x1(%edi),%eax
  80034e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800351:	0f b6 07             	movzbl (%edi),%eax
  800354:	0f b6 c8             	movzbl %al,%ecx
  800357:	83 e8 23             	sub    $0x23,%eax
  80035a:	3c 55                	cmp    $0x55,%al
  80035c:	0f 87 1a 03 00 00    	ja     80067c <vprintfmt+0x38a>
  800362:	0f b6 c0             	movzbl %al,%eax
  800365:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800373:	eb d6                	jmp    80034b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800380:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800383:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800387:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80038a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80038d:	83 fa 09             	cmp    $0x9,%edx
  800390:	77 39                	ja     8003cb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800392:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800395:	eb e9                	jmp    800380 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 48 04             	lea    0x4(%eax),%ecx
  80039d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a8:	eb 27                	jmp    8003d1 <vprintfmt+0xdf>
  8003aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	0f 49 c8             	cmovns %eax,%ecx
  8003b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	eb 8c                	jmp    80034b <vprintfmt+0x59>
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c9:	eb 80                	jmp    80034b <vprintfmt+0x59>
  8003cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ce:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	0f 89 70 ff ff ff    	jns    80034b <vprintfmt+0x59>
				width = precision, precision = -1;
  8003db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	e9 5e ff ff ff       	jmp    80034b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ed:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f3:	e9 53 ff ff ff       	jmp    80034b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	53                   	push   %ebx
  800405:	ff 30                	pushl  (%eax)
  800407:	ff d6                	call   *%esi
			break;
  800409:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040f:	e9 04 ff ff ff       	jmp    800318 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	99                   	cltd   
  800420:	31 d0                	xor    %edx,%eax
  800422:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800424:	83 f8 0f             	cmp    $0xf,%eax
  800427:	7f 0b                	jg     800434 <vprintfmt+0x142>
  800429:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  800430:	85 d2                	test   %edx,%edx
  800432:	75 18                	jne    80044c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800434:	50                   	push   %eax
  800435:	68 1e 1f 80 00       	push   $0x801f1e
  80043a:	53                   	push   %ebx
  80043b:	56                   	push   %esi
  80043c:	e8 94 fe ff ff       	call   8002d5 <printfmt>
  800441:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800447:	e9 cc fe ff ff       	jmp    800318 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044c:	52                   	push   %edx
  80044d:	68 e1 22 80 00       	push   $0x8022e1
  800452:	53                   	push   %ebx
  800453:	56                   	push   %esi
  800454:	e8 7c fe ff ff       	call   8002d5 <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045f:	e9 b4 fe ff ff       	jmp    800318 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046f:	85 ff                	test   %edi,%edi
  800471:	b8 17 1f 80 00       	mov    $0x801f17,%eax
  800476:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800479:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047d:	0f 8e 94 00 00 00    	jle    800517 <vprintfmt+0x225>
  800483:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800487:	0f 84 98 00 00 00    	je     800525 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 d0             	pushl  -0x30(%ebp)
  800493:	57                   	push   %edi
  800494:	e8 86 02 00 00       	call   80071f <strnlen>
  800499:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049c:	29 c1                	sub    %eax,%ecx
  80049e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ae:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	eb 0f                	jmp    8004c1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 ef 01             	sub    $0x1,%edi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 ff                	test   %edi,%edi
  8004c3:	7f ed                	jg     8004b2 <vprintfmt+0x1c0>
  8004c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004cb:	85 c9                	test   %ecx,%ecx
  8004cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d2:	0f 49 c1             	cmovns %ecx,%eax
  8004d5:	29 c1                	sub    %eax,%ecx
  8004d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e0:	89 cb                	mov    %ecx,%ebx
  8004e2:	eb 4d                	jmp    800531 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e8:	74 1b                	je     800505 <vprintfmt+0x213>
  8004ea:	0f be c0             	movsbl %al,%eax
  8004ed:	83 e8 20             	sub    $0x20,%eax
  8004f0:	83 f8 5e             	cmp    $0x5e,%eax
  8004f3:	76 10                	jbe    800505 <vprintfmt+0x213>
					putch('?', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	6a 3f                	push   $0x3f
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	eb 0d                	jmp    800512 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	52                   	push   %edx
  80050c:	ff 55 08             	call   *0x8(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	83 eb 01             	sub    $0x1,%ebx
  800515:	eb 1a                	jmp    800531 <vprintfmt+0x23f>
  800517:	89 75 08             	mov    %esi,0x8(%ebp)
  80051a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800520:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800523:	eb 0c                	jmp    800531 <vprintfmt+0x23f>
  800525:	89 75 08             	mov    %esi,0x8(%ebp)
  800528:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800531:	83 c7 01             	add    $0x1,%edi
  800534:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800538:	0f be d0             	movsbl %al,%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 23                	je     800562 <vprintfmt+0x270>
  80053f:	85 f6                	test   %esi,%esi
  800541:	78 a1                	js     8004e4 <vprintfmt+0x1f2>
  800543:	83 ee 01             	sub    $0x1,%esi
  800546:	79 9c                	jns    8004e4 <vprintfmt+0x1f2>
  800548:	89 df                	mov    %ebx,%edi
  80054a:	8b 75 08             	mov    0x8(%ebp),%esi
  80054d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800550:	eb 18                	jmp    80056a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	53                   	push   %ebx
  800556:	6a 20                	push   $0x20
  800558:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055a:	83 ef 01             	sub    $0x1,%edi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb 08                	jmp    80056a <vprintfmt+0x278>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f e4                	jg     800552 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800571:	e9 a2 fd ff ff       	jmp    800318 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800576:	83 fa 01             	cmp    $0x1,%edx
  800579:	7e 16                	jle    800591 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 08             	lea    0x8(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 50 04             	mov    0x4(%eax),%edx
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	eb 32                	jmp    8005c3 <vprintfmt+0x2d1>
	else if (lflag)
  800591:	85 d2                	test   %edx,%edx
  800593:	74 18                	je     8005ad <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	89 c1                	mov    %eax,%ecx
  8005a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ab:	eb 16                	jmp    8005c3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	89 c1                	mov    %eax,%ecx
  8005bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d2:	79 74                	jns    800648 <vprintfmt+0x356>
				putch('-', putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 2d                	push   $0x2d
  8005da:	ff d6                	call   *%esi
				num = -(long long) num;
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e2:	f7 d8                	neg    %eax
  8005e4:	83 d2 00             	adc    $0x0,%edx
  8005e7:	f7 da                	neg    %edx
  8005e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f1:	eb 55                	jmp    800648 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 83 fc ff ff       	call   80027e <getuint>
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800600:	eb 46                	jmp    800648 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 74 fc ff ff       	call   80027e <getuint>
			base = 8;
  80060a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060f:	eb 37                	jmp    800648 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 30                	push   $0x30
  800617:	ff d6                	call   *%esi
			putch('x', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 78                	push   $0x78
  80061f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800631:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800634:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 3b fc ff ff       	call   80027e <getuint>
			base = 16;
  800643:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064f:	57                   	push   %edi
  800650:	ff 75 e0             	pushl  -0x20(%ebp)
  800653:	51                   	push   %ecx
  800654:	52                   	push   %edx
  800655:	50                   	push   %eax
  800656:	89 da                	mov    %ebx,%edx
  800658:	89 f0                	mov    %esi,%eax
  80065a:	e8 70 fb ff ff       	call   8001cf <printnum>
			break;
  80065f:	83 c4 20             	add    $0x20,%esp
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800665:	e9 ae fc ff ff       	jmp    800318 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	51                   	push   %ecx
  80066f:	ff d6                	call   *%esi
			break;
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800677:	e9 9c fc ff ff       	jmp    800318 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 25                	push   $0x25
  800682:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	eb 03                	jmp    80068c <vprintfmt+0x39a>
  800689:	83 ef 01             	sub    $0x1,%edi
  80068c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800690:	75 f7                	jne    800689 <vprintfmt+0x397>
  800692:	e9 81 fc ff ff       	jmp    800318 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800697:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069a:	5b                   	pop    %ebx
  80069b:	5e                   	pop    %esi
  80069c:	5f                   	pop    %edi
  80069d:	5d                   	pop    %ebp
  80069e:	c3                   	ret    

0080069f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	83 ec 18             	sub    $0x18,%esp
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 26                	je     8006e6 <vsnprintf+0x47>
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	7e 22                	jle    8006e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c4:	ff 75 14             	pushl  0x14(%ebp)
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	68 b8 02 80 00       	push   $0x8002b8
  8006d3:	e8 1a fc ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 05                	jmp    8006eb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f6:	50                   	push   %eax
  8006f7:	ff 75 10             	pushl  0x10(%ebp)
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	ff 75 08             	pushl  0x8(%ebp)
  800700:	e8 9a ff ff ff       	call   80069f <vsnprintf>
	va_end(ap);

	return rc;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	b8 00 00 00 00       	mov    $0x0,%eax
  800712:	eb 03                	jmp    800717 <strlen+0x10>
		n++;
  800714:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800717:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071b:	75 f7                	jne    800714 <strlen+0xd>
		n++;
	return n;
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800725:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	ba 00 00 00 00       	mov    $0x0,%edx
  80072d:	eb 03                	jmp    800732 <strnlen+0x13>
		n++;
  80072f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800732:	39 c2                	cmp    %eax,%edx
  800734:	74 08                	je     80073e <strnlen+0x1f>
  800736:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073a:	75 f3                	jne    80072f <strnlen+0x10>
  80073c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074a:	89 c2                	mov    %eax,%edx
  80074c:	83 c2 01             	add    $0x1,%edx
  80074f:	83 c1 01             	add    $0x1,%ecx
  800752:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800756:	88 5a ff             	mov    %bl,-0x1(%edx)
  800759:	84 db                	test   %bl,%bl
  80075b:	75 ef                	jne    80074c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075d:	5b                   	pop    %ebx
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800767:	53                   	push   %ebx
  800768:	e8 9a ff ff ff       	call   800707 <strlen>
  80076d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	01 d8                	add    %ebx,%eax
  800775:	50                   	push   %eax
  800776:	e8 c5 ff ff ff       	call   800740 <strcpy>
	return dst;
}
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	56                   	push   %esi
  800786:	53                   	push   %ebx
  800787:	8b 75 08             	mov    0x8(%ebp),%esi
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078d:	89 f3                	mov    %esi,%ebx
  80078f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800792:	89 f2                	mov    %esi,%edx
  800794:	eb 0f                	jmp    8007a5 <strncpy+0x23>
		*dst++ = *src;
  800796:	83 c2 01             	add    $0x1,%edx
  800799:	0f b6 01             	movzbl (%ecx),%eax
  80079c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079f:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a5:	39 da                	cmp    %ebx,%edx
  8007a7:	75 ed                	jne    800796 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a9:	89 f0                	mov    %esi,%eax
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8007bd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 21                	je     8007e4 <strlcpy+0x35>
  8007c3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 09                	jmp    8007d4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d4:	39 c2                	cmp    %eax,%edx
  8007d6:	74 09                	je     8007e1 <strlcpy+0x32>
  8007d8:	0f b6 19             	movzbl (%ecx),%ebx
  8007db:	84 db                	test   %bl,%bl
  8007dd:	75 ec                	jne    8007cb <strlcpy+0x1c>
  8007df:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e4:	29 f0                	sub    %esi,%eax
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f3:	eb 06                	jmp    8007fb <strcmp+0x11>
		p++, q++;
  8007f5:	83 c1 01             	add    $0x1,%ecx
  8007f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fb:	0f b6 01             	movzbl (%ecx),%eax
  8007fe:	84 c0                	test   %al,%al
  800800:	74 04                	je     800806 <strcmp+0x1c>
  800802:	3a 02                	cmp    (%edx),%al
  800804:	74 ef                	je     8007f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800806:	0f b6 c0             	movzbl %al,%eax
  800809:	0f b6 12             	movzbl (%edx),%edx
  80080c:	29 d0                	sub    %edx,%eax
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	89 c3                	mov    %eax,%ebx
  80081c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081f:	eb 06                	jmp    800827 <strncmp+0x17>
		n--, p++, q++;
  800821:	83 c0 01             	add    $0x1,%eax
  800824:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800827:	39 d8                	cmp    %ebx,%eax
  800829:	74 15                	je     800840 <strncmp+0x30>
  80082b:	0f b6 08             	movzbl (%eax),%ecx
  80082e:	84 c9                	test   %cl,%cl
  800830:	74 04                	je     800836 <strncmp+0x26>
  800832:	3a 0a                	cmp    (%edx),%cl
  800834:	74 eb                	je     800821 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	0f b6 00             	movzbl (%eax),%eax
  800839:	0f b6 12             	movzbl (%edx),%edx
  80083c:	29 d0                	sub    %edx,%eax
  80083e:	eb 05                	jmp    800845 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800845:	5b                   	pop    %ebx
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800852:	eb 07                	jmp    80085b <strchr+0x13>
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 0f                	je     800867 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	0f b6 10             	movzbl (%eax),%edx
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f2                	jne    800854 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800873:	eb 03                	jmp    800878 <strfind+0xf>
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087b:	38 ca                	cmp    %cl,%dl
  80087d:	74 04                	je     800883 <strfind+0x1a>
  80087f:	84 d2                	test   %dl,%dl
  800881:	75 f2                	jne    800875 <strfind+0xc>
			break;
	return (char *) s;
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	57                   	push   %edi
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800891:	85 c9                	test   %ecx,%ecx
  800893:	74 36                	je     8008cb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800895:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089b:	75 28                	jne    8008c5 <memset+0x40>
  80089d:	f6 c1 03             	test   $0x3,%cl
  8008a0:	75 23                	jne    8008c5 <memset+0x40>
		c &= 0xFF;
  8008a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a6:	89 d3                	mov    %edx,%ebx
  8008a8:	c1 e3 08             	shl    $0x8,%ebx
  8008ab:	89 d6                	mov    %edx,%esi
  8008ad:	c1 e6 18             	shl    $0x18,%esi
  8008b0:	89 d0                	mov    %edx,%eax
  8008b2:	c1 e0 10             	shl    $0x10,%eax
  8008b5:	09 f0                	or     %esi,%eax
  8008b7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b9:	89 d8                	mov    %ebx,%eax
  8008bb:	09 d0                	or     %edx,%eax
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fc                   	cld    
  8008c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c3:	eb 06                	jmp    8008cb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	fc                   	cld    
  8008c9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cb:	89 f8                	mov    %edi,%eax
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e0:	39 c6                	cmp    %eax,%esi
  8008e2:	73 35                	jae    800919 <memmove+0x47>
  8008e4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e7:	39 d0                	cmp    %edx,%eax
  8008e9:	73 2e                	jae    800919 <memmove+0x47>
		s += n;
		d += n;
  8008eb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	09 fe                	or     %edi,%esi
  8008f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f8:	75 13                	jne    80090d <memmove+0x3b>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0e                	jne    80090d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ff:	83 ef 04             	sub    $0x4,%edi
  800902:	8d 72 fc             	lea    -0x4(%edx),%esi
  800905:	c1 e9 02             	shr    $0x2,%ecx
  800908:	fd                   	std    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 09                	jmp    800916 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090d:	83 ef 01             	sub    $0x1,%edi
  800910:	8d 72 ff             	lea    -0x1(%edx),%esi
  800913:	fd                   	std    
  800914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800916:	fc                   	cld    
  800917:	eb 1d                	jmp    800936 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800919:	89 f2                	mov    %esi,%edx
  80091b:	09 c2                	or     %eax,%edx
  80091d:	f6 c2 03             	test   $0x3,%dl
  800920:	75 0f                	jne    800931 <memmove+0x5f>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	75 0a                	jne    800931 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800927:	c1 e9 02             	shr    $0x2,%ecx
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092f:	eb 05                	jmp    800936 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800931:	89 c7                	mov    %eax,%edi
  800933:	fc                   	cld    
  800934:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800936:	5e                   	pop    %esi
  800937:	5f                   	pop    %edi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093d:	ff 75 10             	pushl  0x10(%ebp)
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	ff 75 08             	pushl  0x8(%ebp)
  800946:	e8 87 ff ff ff       	call   8008d2 <memmove>
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 55 0c             	mov    0xc(%ebp),%edx
  800958:	89 c6                	mov    %eax,%esi
  80095a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095d:	eb 1a                	jmp    800979 <memcmp+0x2c>
		if (*s1 != *s2)
  80095f:	0f b6 08             	movzbl (%eax),%ecx
  800962:	0f b6 1a             	movzbl (%edx),%ebx
  800965:	38 d9                	cmp    %bl,%cl
  800967:	74 0a                	je     800973 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800969:	0f b6 c1             	movzbl %cl,%eax
  80096c:	0f b6 db             	movzbl %bl,%ebx
  80096f:	29 d8                	sub    %ebx,%eax
  800971:	eb 0f                	jmp    800982 <memcmp+0x35>
		s1++, s2++;
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800979:	39 f0                	cmp    %esi,%eax
  80097b:	75 e2                	jne    80095f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098d:	89 c1                	mov    %eax,%ecx
  80098f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800992:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800996:	eb 0a                	jmp    8009a2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800998:	0f b6 10             	movzbl (%eax),%edx
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	74 07                	je     8009a6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099f:	83 c0 01             	add    $0x1,%eax
  8009a2:	39 c8                	cmp    %ecx,%eax
  8009a4:	72 f2                	jb     800998 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b5:	eb 03                	jmp    8009ba <strtol+0x11>
		s++;
  8009b7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	3c 20                	cmp    $0x20,%al
  8009bf:	74 f6                	je     8009b7 <strtol+0xe>
  8009c1:	3c 09                	cmp    $0x9,%al
  8009c3:	74 f2                	je     8009b7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c5:	3c 2b                	cmp    $0x2b,%al
  8009c7:	75 0a                	jne    8009d3 <strtol+0x2a>
		s++;
  8009c9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d1:	eb 11                	jmp    8009e4 <strtol+0x3b>
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d8:	3c 2d                	cmp    $0x2d,%al
  8009da:	75 08                	jne    8009e4 <strtol+0x3b>
		s++, neg = 1;
  8009dc:	83 c1 01             	add    $0x1,%ecx
  8009df:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ea:	75 15                	jne    800a01 <strtol+0x58>
  8009ec:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ef:	75 10                	jne    800a01 <strtol+0x58>
  8009f1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f5:	75 7c                	jne    800a73 <strtol+0xca>
		s += 2, base = 16;
  8009f7:	83 c1 02             	add    $0x2,%ecx
  8009fa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ff:	eb 16                	jmp    800a17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a01:	85 db                	test   %ebx,%ebx
  800a03:	75 12                	jne    800a17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0d:	75 08                	jne    800a17 <strtol+0x6e>
		s++, base = 8;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1f:	0f b6 11             	movzbl (%ecx),%edx
  800a22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 09             	cmp    $0x9,%bl
  800a2a:	77 08                	ja     800a34 <strtol+0x8b>
			dig = *s - '0';
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 30             	sub    $0x30,%edx
  800a32:	eb 22                	jmp    800a56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a37:	89 f3                	mov    %esi,%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3e:	0f be d2             	movsbl %dl,%edx
  800a41:	83 ea 57             	sub    $0x57,%edx
  800a44:	eb 10                	jmp    800a56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a49:	89 f3                	mov    %esi,%ebx
  800a4b:	80 fb 19             	cmp    $0x19,%bl
  800a4e:	77 16                	ja     800a66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a50:	0f be d2             	movsbl %dl,%edx
  800a53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a59:	7d 0b                	jge    800a66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a64:	eb b9                	jmp    800a1f <strtol+0x76>

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 0d                	je     800a79 <strtol+0xd0>
		*endptr = (char *) s;
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	89 0e                	mov    %ecx,(%esi)
  800a71:	eb 06                	jmp    800a79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	85 db                	test   %ebx,%ebx
  800a75:	74 98                	je     800a0f <strtol+0x66>
  800a77:	eb 9e                	jmp    800a17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	f7 da                	neg    %edx
  800a7d:	85 ff                	test   %edi,%edi
  800a7f:	0f 45 c2             	cmovne %edx,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a95:	8b 55 08             	mov    0x8(%ebp),%edx
  800a98:	89 c3                	mov    %eax,%ebx
  800a9a:	89 c7                	mov    %eax,%edi
  800a9c:	89 c6                	mov    %eax,%esi
  800a9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab5:	89 d1                	mov    %edx,%ecx
  800ab7:	89 d3                	mov    %edx,%ebx
  800ab9:	89 d7                	mov    %edx,%edi
  800abb:	89 d6                	mov    %edx,%esi
  800abd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad7:	8b 55 08             	mov    0x8(%ebp),%edx
  800ada:	89 cb                	mov    %ecx,%ebx
  800adc:	89 cf                	mov    %ecx,%edi
  800ade:	89 ce                	mov    %ecx,%esi
  800ae0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	7e 17                	jle    800afd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	50                   	push   %eax
  800aea:	6a 03                	push   $0x3
  800aec:	68 ff 21 80 00       	push   $0x8021ff
  800af1:	6a 23                	push   $0x23
  800af3:	68 1c 22 80 00       	push   $0x80221c
  800af8:	e8 b0 0f 00 00       	call   801aad <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 02 00 00 00       	mov    $0x2,%eax
  800b15:	89 d1                	mov    %edx,%ecx
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_yield>:

void
sys_yield(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	be 00 00 00 00       	mov    $0x0,%esi
  800b51:	b8 04 00 00 00       	mov    $0x4,%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5f:	89 f7                	mov    %esi,%edi
  800b61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7e 17                	jle    800b7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	50                   	push   %eax
  800b6b:	6a 04                	push   $0x4
  800b6d:	68 ff 21 80 00       	push   $0x8021ff
  800b72:	6a 23                	push   $0x23
  800b74:	68 1c 22 80 00       	push   $0x80221c
  800b79:	e8 2f 0f 00 00       	call   801aad <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7e 17                	jle    800bc0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	50                   	push   %eax
  800bad:	6a 05                	push   $0x5
  800baf:	68 ff 21 80 00       	push   $0x8021ff
  800bb4:	6a 23                	push   $0x23
  800bb6:	68 1c 22 80 00       	push   $0x80221c
  800bbb:	e8 ed 0e 00 00       	call   801aad <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 df                	mov    %ebx,%edi
  800be3:	89 de                	mov    %ebx,%esi
  800be5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 17                	jle    800c02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 06                	push   $0x6
  800bf1:	68 ff 21 80 00       	push   $0x8021ff
  800bf6:	6a 23                	push   $0x23
  800bf8:	68 1c 22 80 00       	push   $0x80221c
  800bfd:	e8 ab 0e 00 00       	call   801aad <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	89 de                	mov    %ebx,%esi
  800c27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 17                	jle    800c44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 08                	push   $0x8
  800c33:	68 ff 21 80 00       	push   $0x8021ff
  800c38:	6a 23                	push   $0x23
  800c3a:	68 1c 22 80 00       	push   $0x80221c
  800c3f:	e8 69 0e 00 00       	call   801aad <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 17                	jle    800c86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	50                   	push   %eax
  800c73:	6a 09                	push   $0x9
  800c75:	68 ff 21 80 00       	push   $0x8021ff
  800c7a:	6a 23                	push   $0x23
  800c7c:	68 1c 22 80 00       	push   $0x80221c
  800c81:	e8 27 0e 00 00       	call   801aad <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 0a                	push   $0xa
  800cb7:	68 ff 21 80 00       	push   $0x8021ff
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 1c 22 80 00       	push   $0x80221c
  800cc3:	e8 e5 0d 00 00       	call   801aad <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	be 00 00 00 00       	mov    $0x0,%esi
  800cdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 0d                	push   $0xd
  800d1b:	68 ff 21 80 00       	push   $0x8021ff
  800d20:	6a 23                	push   $0x23
  800d22:	68 1c 22 80 00       	push   $0x80221c
  800d27:	e8 81 0d 00 00       	call   801aad <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d3a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d41:	75 2a                	jne    800d6d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	6a 07                	push   $0x7
  800d48:	68 00 f0 bf ee       	push   $0xeebff000
  800d4d:	6a 00                	push   $0x0
  800d4f:	e8 ef fd ff ff       	call   800b43 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 12                	jns    800d6d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800d5b:	50                   	push   %eax
  800d5c:	68 2a 22 80 00       	push   $0x80222a
  800d61:	6a 23                	push   $0x23
  800d63:	68 2e 22 80 00       	push   $0x80222e
  800d68:	e8 40 0d 00 00       	call   801aad <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800d75:	83 ec 08             	sub    $0x8,%esp
  800d78:	68 9f 0d 80 00       	push   $0x800d9f
  800d7d:	6a 00                	push   $0x0
  800d7f:	e8 0a ff ff ff       	call   800c8e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800d84:	83 c4 10             	add    $0x10,%esp
  800d87:	85 c0                	test   %eax,%eax
  800d89:	79 12                	jns    800d9d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800d8b:	50                   	push   %eax
  800d8c:	68 2a 22 80 00       	push   $0x80222a
  800d91:	6a 2c                	push   $0x2c
  800d93:	68 2e 22 80 00       	push   $0x80222e
  800d98:	e8 10 0d 00 00       	call   801aad <_panic>
	}
}
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d9f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800da0:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800da5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800da7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800daa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800dae:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800db3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800db7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800db9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800dbc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800dbd:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800dc0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800dc1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dc2:	c3                   	ret    

00800dc3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	05 00 00 00 30       	add    $0x30000000,%eax
  800dce:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	05 00 00 00 30       	add    $0x30000000,%eax
  800dde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df5:	89 c2                	mov    %eax,%edx
  800df7:	c1 ea 16             	shr    $0x16,%edx
  800dfa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e01:	f6 c2 01             	test   $0x1,%dl
  800e04:	74 11                	je     800e17 <fd_alloc+0x2d>
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	c1 ea 0c             	shr    $0xc,%edx
  800e0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e12:	f6 c2 01             	test   $0x1,%dl
  800e15:	75 09                	jne    800e20 <fd_alloc+0x36>
			*fd_store = fd;
  800e17:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	eb 17                	jmp    800e37 <fd_alloc+0x4d>
  800e20:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e25:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e2a:	75 c9                	jne    800df5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e2c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e32:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3f:	83 f8 1f             	cmp    $0x1f,%eax
  800e42:	77 36                	ja     800e7a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e44:	c1 e0 0c             	shl    $0xc,%eax
  800e47:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e4c:	89 c2                	mov    %eax,%edx
  800e4e:	c1 ea 16             	shr    $0x16,%edx
  800e51:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e58:	f6 c2 01             	test   $0x1,%dl
  800e5b:	74 24                	je     800e81 <fd_lookup+0x48>
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	c1 ea 0c             	shr    $0xc,%edx
  800e62:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e69:	f6 c2 01             	test   $0x1,%dl
  800e6c:	74 1a                	je     800e88 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e71:	89 02                	mov    %eax,(%edx)
	return 0;
  800e73:	b8 00 00 00 00       	mov    $0x0,%eax
  800e78:	eb 13                	jmp    800e8d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7f:	eb 0c                	jmp    800e8d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e86:	eb 05                	jmp    800e8d <fd_lookup+0x54>
  800e88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e98:	ba b8 22 80 00       	mov    $0x8022b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e9d:	eb 13                	jmp    800eb2 <dev_lookup+0x23>
  800e9f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ea2:	39 08                	cmp    %ecx,(%eax)
  800ea4:	75 0c                	jne    800eb2 <dev_lookup+0x23>
			*dev = devtab[i];
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	eb 2e                	jmp    800ee0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb2:	8b 02                	mov    (%edx),%eax
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	75 e7                	jne    800e9f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eb8:	a1 04 40 80 00       	mov    0x804004,%eax
  800ebd:	8b 40 48             	mov    0x48(%eax),%eax
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	51                   	push   %ecx
  800ec4:	50                   	push   %eax
  800ec5:	68 3c 22 80 00       	push   $0x80223c
  800eca:	e8 ec f2 ff ff       	call   8001bb <cprintf>
	*dev = 0;
  800ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 10             	sub    $0x10,%esp
  800eea:	8b 75 08             	mov    0x8(%ebp),%esi
  800eed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef3:	50                   	push   %eax
  800ef4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800efa:	c1 e8 0c             	shr    $0xc,%eax
  800efd:	50                   	push   %eax
  800efe:	e8 36 ff ff ff       	call   800e39 <fd_lookup>
  800f03:	83 c4 08             	add    $0x8,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	78 05                	js     800f0f <fd_close+0x2d>
	    || fd != fd2)
  800f0a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f0d:	74 0c                	je     800f1b <fd_close+0x39>
		return (must_exist ? r : 0);
  800f0f:	84 db                	test   %bl,%bl
  800f11:	ba 00 00 00 00       	mov    $0x0,%edx
  800f16:	0f 44 c2             	cmove  %edx,%eax
  800f19:	eb 41                	jmp    800f5c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f1b:	83 ec 08             	sub    $0x8,%esp
  800f1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f21:	50                   	push   %eax
  800f22:	ff 36                	pushl  (%esi)
  800f24:	e8 66 ff ff ff       	call   800e8f <dev_lookup>
  800f29:	89 c3                	mov    %eax,%ebx
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	78 1a                	js     800f4c <fd_close+0x6a>
		if (dev->dev_close)
  800f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f35:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f38:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	74 0b                	je     800f4c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	56                   	push   %esi
  800f45:	ff d0                	call   *%eax
  800f47:	89 c3                	mov    %eax,%ebx
  800f49:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f4c:	83 ec 08             	sub    $0x8,%esp
  800f4f:	56                   	push   %esi
  800f50:	6a 00                	push   $0x0
  800f52:	e8 71 fc ff ff       	call   800bc8 <sys_page_unmap>
	return r;
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	89 d8                	mov    %ebx,%eax
}
  800f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	ff 75 08             	pushl  0x8(%ebp)
  800f70:	e8 c4 fe ff ff       	call   800e39 <fd_lookup>
  800f75:	83 c4 08             	add    $0x8,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 10                	js     800f8c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	6a 01                	push   $0x1
  800f81:	ff 75 f4             	pushl  -0xc(%ebp)
  800f84:	e8 59 ff ff ff       	call   800ee2 <fd_close>
  800f89:	83 c4 10             	add    $0x10,%esp
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <close_all>:

void
close_all(void)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	53                   	push   %ebx
  800f92:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f95:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	53                   	push   %ebx
  800f9e:	e8 c0 ff ff ff       	call   800f63 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa3:	83 c3 01             	add    $0x1,%ebx
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	83 fb 20             	cmp    $0x20,%ebx
  800fac:	75 ec                	jne    800f9a <close_all+0xc>
		close(i);
}
  800fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 2c             	sub    $0x2c,%esp
  800fbc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fbf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	ff 75 08             	pushl  0x8(%ebp)
  800fc6:	e8 6e fe ff ff       	call   800e39 <fd_lookup>
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	0f 88 c1 00 00 00    	js     801097 <dup+0xe4>
		return r;
	close(newfdnum);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	56                   	push   %esi
  800fda:	e8 84 ff ff ff       	call   800f63 <close>

	newfd = INDEX2FD(newfdnum);
  800fdf:	89 f3                	mov    %esi,%ebx
  800fe1:	c1 e3 0c             	shl    $0xc,%ebx
  800fe4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fea:	83 c4 04             	add    $0x4,%esp
  800fed:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff0:	e8 de fd ff ff       	call   800dd3 <fd2data>
  800ff5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ff7:	89 1c 24             	mov    %ebx,(%esp)
  800ffa:	e8 d4 fd ff ff       	call   800dd3 <fd2data>
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801005:	89 f8                	mov    %edi,%eax
  801007:	c1 e8 16             	shr    $0x16,%eax
  80100a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801011:	a8 01                	test   $0x1,%al
  801013:	74 37                	je     80104c <dup+0x99>
  801015:	89 f8                	mov    %edi,%eax
  801017:	c1 e8 0c             	shr    $0xc,%eax
  80101a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801021:	f6 c2 01             	test   $0x1,%dl
  801024:	74 26                	je     80104c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	25 07 0e 00 00       	and    $0xe07,%eax
  801035:	50                   	push   %eax
  801036:	ff 75 d4             	pushl  -0x2c(%ebp)
  801039:	6a 00                	push   $0x0
  80103b:	57                   	push   %edi
  80103c:	6a 00                	push   $0x0
  80103e:	e8 43 fb ff ff       	call   800b86 <sys_page_map>
  801043:	89 c7                	mov    %eax,%edi
  801045:	83 c4 20             	add    $0x20,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 2e                	js     80107a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80104f:	89 d0                	mov    %edx,%eax
  801051:	c1 e8 0c             	shr    $0xc,%eax
  801054:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	25 07 0e 00 00       	and    $0xe07,%eax
  801063:	50                   	push   %eax
  801064:	53                   	push   %ebx
  801065:	6a 00                	push   $0x0
  801067:	52                   	push   %edx
  801068:	6a 00                	push   $0x0
  80106a:	e8 17 fb ff ff       	call   800b86 <sys_page_map>
  80106f:	89 c7                	mov    %eax,%edi
  801071:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801074:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801076:	85 ff                	test   %edi,%edi
  801078:	79 1d                	jns    801097 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	53                   	push   %ebx
  80107e:	6a 00                	push   $0x0
  801080:	e8 43 fb ff ff       	call   800bc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801085:	83 c4 08             	add    $0x8,%esp
  801088:	ff 75 d4             	pushl  -0x2c(%ebp)
  80108b:	6a 00                	push   $0x0
  80108d:	e8 36 fb ff ff       	call   800bc8 <sys_page_unmap>
	return r;
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	89 f8                	mov    %edi,%eax
}
  801097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 14             	sub    $0x14,%esp
  8010a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	53                   	push   %ebx
  8010ae:	e8 86 fd ff ff       	call   800e39 <fd_lookup>
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	89 c2                	mov    %eax,%edx
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 6d                	js     801129 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c2:	50                   	push   %eax
  8010c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c6:	ff 30                	pushl  (%eax)
  8010c8:	e8 c2 fd ff ff       	call   800e8f <dev_lookup>
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 4c                	js     801120 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010d7:	8b 42 08             	mov    0x8(%edx),%eax
  8010da:	83 e0 03             	and    $0x3,%eax
  8010dd:	83 f8 01             	cmp    $0x1,%eax
  8010e0:	75 21                	jne    801103 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e7:	8b 40 48             	mov    0x48(%eax),%eax
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	53                   	push   %ebx
  8010ee:	50                   	push   %eax
  8010ef:	68 7d 22 80 00       	push   $0x80227d
  8010f4:	e8 c2 f0 ff ff       	call   8001bb <cprintf>
		return -E_INVAL;
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801101:	eb 26                	jmp    801129 <read+0x8a>
	}
	if (!dev->dev_read)
  801103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801106:	8b 40 08             	mov    0x8(%eax),%eax
  801109:	85 c0                	test   %eax,%eax
  80110b:	74 17                	je     801124 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	ff 75 10             	pushl  0x10(%ebp)
  801113:	ff 75 0c             	pushl  0xc(%ebp)
  801116:	52                   	push   %edx
  801117:	ff d0                	call   *%eax
  801119:	89 c2                	mov    %eax,%edx
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	eb 09                	jmp    801129 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801120:	89 c2                	mov    %eax,%edx
  801122:	eb 05                	jmp    801129 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801124:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801129:	89 d0                	mov    %edx,%eax
  80112b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801144:	eb 21                	jmp    801167 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	89 f0                	mov    %esi,%eax
  80114b:	29 d8                	sub    %ebx,%eax
  80114d:	50                   	push   %eax
  80114e:	89 d8                	mov    %ebx,%eax
  801150:	03 45 0c             	add    0xc(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	57                   	push   %edi
  801155:	e8 45 ff ff ff       	call   80109f <read>
		if (m < 0)
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 10                	js     801171 <readn+0x41>
			return m;
		if (m == 0)
  801161:	85 c0                	test   %eax,%eax
  801163:	74 0a                	je     80116f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801165:	01 c3                	add    %eax,%ebx
  801167:	39 f3                	cmp    %esi,%ebx
  801169:	72 db                	jb     801146 <readn+0x16>
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	eb 02                	jmp    801171 <readn+0x41>
  80116f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801171:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5f                   	pop    %edi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	53                   	push   %ebx
  80117d:	83 ec 14             	sub    $0x14,%esp
  801180:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801183:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801186:	50                   	push   %eax
  801187:	53                   	push   %ebx
  801188:	e8 ac fc ff ff       	call   800e39 <fd_lookup>
  80118d:	83 c4 08             	add    $0x8,%esp
  801190:	89 c2                	mov    %eax,%edx
  801192:	85 c0                	test   %eax,%eax
  801194:	78 68                	js     8011fe <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a0:	ff 30                	pushl  (%eax)
  8011a2:	e8 e8 fc ff ff       	call   800e8f <dev_lookup>
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 47                	js     8011f5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b5:	75 21                	jne    8011d8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bc:	8b 40 48             	mov    0x48(%eax),%eax
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	53                   	push   %ebx
  8011c3:	50                   	push   %eax
  8011c4:	68 99 22 80 00       	push   $0x802299
  8011c9:	e8 ed ef ff ff       	call   8001bb <cprintf>
		return -E_INVAL;
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d6:	eb 26                	jmp    8011fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011db:	8b 52 0c             	mov    0xc(%edx),%edx
  8011de:	85 d2                	test   %edx,%edx
  8011e0:	74 17                	je     8011f9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	ff 75 10             	pushl  0x10(%ebp)
  8011e8:	ff 75 0c             	pushl  0xc(%ebp)
  8011eb:	50                   	push   %eax
  8011ec:	ff d2                	call   *%edx
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	eb 09                	jmp    8011fe <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	eb 05                	jmp    8011fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011fe:	89 d0                	mov    %edx,%eax
  801200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <seek>:

int
seek(int fdnum, off_t offset)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	ff 75 08             	pushl  0x8(%ebp)
  801212:	e8 22 fc ff ff       	call   800e39 <fd_lookup>
  801217:	83 c4 08             	add    $0x8,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 0e                	js     80122c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80121e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801221:	8b 55 0c             	mov    0xc(%ebp),%edx
  801224:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	53                   	push   %ebx
  801232:	83 ec 14             	sub    $0x14,%esp
  801235:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801238:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	53                   	push   %ebx
  80123d:	e8 f7 fb ff ff       	call   800e39 <fd_lookup>
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	89 c2                	mov    %eax,%edx
  801247:	85 c0                	test   %eax,%eax
  801249:	78 65                	js     8012b0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801255:	ff 30                	pushl  (%eax)
  801257:	e8 33 fc ff ff       	call   800e8f <dev_lookup>
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 44                	js     8012a7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801266:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80126a:	75 21                	jne    80128d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80126c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801271:	8b 40 48             	mov    0x48(%eax),%eax
  801274:	83 ec 04             	sub    $0x4,%esp
  801277:	53                   	push   %ebx
  801278:	50                   	push   %eax
  801279:	68 5c 22 80 00       	push   $0x80225c
  80127e:	e8 38 ef ff ff       	call   8001bb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80128b:	eb 23                	jmp    8012b0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80128d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801290:	8b 52 18             	mov    0x18(%edx),%edx
  801293:	85 d2                	test   %edx,%edx
  801295:	74 14                	je     8012ab <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	ff 75 0c             	pushl  0xc(%ebp)
  80129d:	50                   	push   %eax
  80129e:	ff d2                	call   *%edx
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	eb 09                	jmp    8012b0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	eb 05                	jmp    8012b0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b0:	89 d0                	mov    %edx,%eax
  8012b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 14             	sub    $0x14,%esp
  8012be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 08             	pushl  0x8(%ebp)
  8012c8:	e8 6c fb ff ff       	call   800e39 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	89 c2                	mov    %eax,%edx
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 58                	js     80132e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e0:	ff 30                	pushl  (%eax)
  8012e2:	e8 a8 fb ff ff       	call   800e8f <dev_lookup>
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 37                	js     801325 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012f5:	74 32                	je     801329 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801301:	00 00 00 
	stat->st_isdir = 0;
  801304:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80130b:	00 00 00 
	stat->st_dev = dev;
  80130e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	53                   	push   %ebx
  801318:	ff 75 f0             	pushl  -0x10(%ebp)
  80131b:	ff 50 14             	call   *0x14(%eax)
  80131e:	89 c2                	mov    %eax,%edx
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	eb 09                	jmp    80132e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801325:	89 c2                	mov    %eax,%edx
  801327:	eb 05                	jmp    80132e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801329:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80132e:	89 d0                	mov    %edx,%eax
  801330:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	56                   	push   %esi
  801339:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	6a 00                	push   $0x0
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 e3 01 00 00       	call   80152a <open>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 1b                	js     80136b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	ff 75 0c             	pushl  0xc(%ebp)
  801356:	50                   	push   %eax
  801357:	e8 5b ff ff ff       	call   8012b7 <fstat>
  80135c:	89 c6                	mov    %eax,%esi
	close(fd);
  80135e:	89 1c 24             	mov    %ebx,(%esp)
  801361:	e8 fd fb ff ff       	call   800f63 <close>
	return r;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	89 f0                	mov    %esi,%eax
}
  80136b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	89 c6                	mov    %eax,%esi
  801379:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80137b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801382:	75 12                	jne    801396 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	6a 01                	push   $0x1
  801389:	e8 39 08 00 00       	call   801bc7 <ipc_find_env>
  80138e:	a3 00 40 80 00       	mov    %eax,0x804000
  801393:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801396:	6a 07                	push   $0x7
  801398:	68 00 50 80 00       	push   $0x805000
  80139d:	56                   	push   %esi
  80139e:	ff 35 00 40 80 00    	pushl  0x804000
  8013a4:	e8 bc 07 00 00       	call   801b65 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013a9:	83 c4 0c             	add    $0xc,%esp
  8013ac:	6a 00                	push   $0x0
  8013ae:	53                   	push   %ebx
  8013af:	6a 00                	push   $0x0
  8013b1:	e8 3d 07 00 00       	call   801af3 <ipc_recv>
}
  8013b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e0:	e8 8d ff ff ff       	call   801372 <fsipc>
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801402:	e8 6b ff ff ff       	call   801372 <fsipc>
}
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	53                   	push   %ebx
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
  801416:	8b 40 0c             	mov    0xc(%eax),%eax
  801419:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80141e:	ba 00 00 00 00       	mov    $0x0,%edx
  801423:	b8 05 00 00 00       	mov    $0x5,%eax
  801428:	e8 45 ff ff ff       	call   801372 <fsipc>
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 2c                	js     80145d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	68 00 50 80 00       	push   $0x805000
  801439:	53                   	push   %ebx
  80143a:	e8 01 f3 ff ff       	call   800740 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80143f:	a1 80 50 80 00       	mov    0x805080,%eax
  801444:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80144a:	a1 84 50 80 00       	mov    0x805084,%eax
  80144f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80146b:	8b 55 08             	mov    0x8(%ebp),%edx
  80146e:	8b 52 0c             	mov    0xc(%edx),%edx
  801471:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801477:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80147c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801481:	0f 47 c2             	cmova  %edx,%eax
  801484:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801489:	50                   	push   %eax
  80148a:	ff 75 0c             	pushl  0xc(%ebp)
  80148d:	68 08 50 80 00       	push   $0x805008
  801492:	e8 3b f4 ff ff       	call   8008d2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a1:	e8 cc fe ff ff       	call   801372 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014bb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cb:	e8 a2 fe ff ff       	call   801372 <fsipc>
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 4b                	js     801521 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014d6:	39 c6                	cmp    %eax,%esi
  8014d8:	73 16                	jae    8014f0 <devfile_read+0x48>
  8014da:	68 c8 22 80 00       	push   $0x8022c8
  8014df:	68 cf 22 80 00       	push   $0x8022cf
  8014e4:	6a 7c                	push   $0x7c
  8014e6:	68 e4 22 80 00       	push   $0x8022e4
  8014eb:	e8 bd 05 00 00       	call   801aad <_panic>
	assert(r <= PGSIZE);
  8014f0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f5:	7e 16                	jle    80150d <devfile_read+0x65>
  8014f7:	68 ef 22 80 00       	push   $0x8022ef
  8014fc:	68 cf 22 80 00       	push   $0x8022cf
  801501:	6a 7d                	push   $0x7d
  801503:	68 e4 22 80 00       	push   $0x8022e4
  801508:	e8 a0 05 00 00       	call   801aad <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	50                   	push   %eax
  801511:	68 00 50 80 00       	push   $0x805000
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	e8 b4 f3 ff ff       	call   8008d2 <memmove>
	return r;
  80151e:	83 c4 10             	add    $0x10,%esp
}
  801521:	89 d8                	mov    %ebx,%eax
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 20             	sub    $0x20,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801534:	53                   	push   %ebx
  801535:	e8 cd f1 ff ff       	call   800707 <strlen>
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801542:	7f 67                	jg     8015ab <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	e8 9a f8 ff ff       	call   800dea <fd_alloc>
  801550:	83 c4 10             	add    $0x10,%esp
		return r;
  801553:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801555:	85 c0                	test   %eax,%eax
  801557:	78 57                	js     8015b0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	53                   	push   %ebx
  80155d:	68 00 50 80 00       	push   $0x805000
  801562:	e8 d9 f1 ff ff       	call   800740 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80156f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801572:	b8 01 00 00 00       	mov    $0x1,%eax
  801577:	e8 f6 fd ff ff       	call   801372 <fsipc>
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	79 14                	jns    801599 <open+0x6f>
		fd_close(fd, 0);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	6a 00                	push   $0x0
  80158a:	ff 75 f4             	pushl  -0xc(%ebp)
  80158d:	e8 50 f9 ff ff       	call   800ee2 <fd_close>
		return r;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	89 da                	mov    %ebx,%edx
  801597:	eb 17                	jmp    8015b0 <open+0x86>
	}

	return fd2num(fd);
  801599:	83 ec 0c             	sub    $0xc,%esp
  80159c:	ff 75 f4             	pushl  -0xc(%ebp)
  80159f:	e8 1f f8 ff ff       	call   800dc3 <fd2num>
  8015a4:	89 c2                	mov    %eax,%edx
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	eb 05                	jmp    8015b0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ab:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015b0:	89 d0                	mov    %edx,%eax
  8015b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c7:	e8 a6 fd ff ff       	call   801372 <fsipc>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 f2 f7 ff ff       	call   800dd3 <fd2data>
  8015e1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	68 fb 22 80 00       	push   $0x8022fb
  8015eb:	53                   	push   %ebx
  8015ec:	e8 4f f1 ff ff       	call   800740 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015f1:	8b 46 04             	mov    0x4(%esi),%eax
  8015f4:	2b 06                	sub    (%esi),%eax
  8015f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801603:	00 00 00 
	stat->st_dev = &devpipe;
  801606:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80160d:	30 80 00 
	return 0;
}
  801610:	b8 00 00 00 00       	mov    $0x0,%eax
  801615:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	53                   	push   %ebx
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801626:	53                   	push   %ebx
  801627:	6a 00                	push   $0x0
  801629:	e8 9a f5 ff ff       	call   800bc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80162e:	89 1c 24             	mov    %ebx,(%esp)
  801631:	e8 9d f7 ff ff       	call   800dd3 <fd2data>
  801636:	83 c4 08             	add    $0x8,%esp
  801639:	50                   	push   %eax
  80163a:	6a 00                	push   $0x0
  80163c:	e8 87 f5 ff ff       	call   800bc8 <sys_page_unmap>
}
  801641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	83 ec 1c             	sub    $0x1c,%esp
  80164f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801652:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801654:	a1 04 40 80 00       	mov    0x804004,%eax
  801659:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	ff 75 e0             	pushl  -0x20(%ebp)
  801662:	e8 99 05 00 00       	call   801c00 <pageref>
  801667:	89 c3                	mov    %eax,%ebx
  801669:	89 3c 24             	mov    %edi,(%esp)
  80166c:	e8 8f 05 00 00       	call   801c00 <pageref>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	39 c3                	cmp    %eax,%ebx
  801676:	0f 94 c1             	sete   %cl
  801679:	0f b6 c9             	movzbl %cl,%ecx
  80167c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80167f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801685:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801688:	39 ce                	cmp    %ecx,%esi
  80168a:	74 1b                	je     8016a7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80168c:	39 c3                	cmp    %eax,%ebx
  80168e:	75 c4                	jne    801654 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801690:	8b 42 58             	mov    0x58(%edx),%eax
  801693:	ff 75 e4             	pushl  -0x1c(%ebp)
  801696:	50                   	push   %eax
  801697:	56                   	push   %esi
  801698:	68 02 23 80 00       	push   $0x802302
  80169d:	e8 19 eb ff ff       	call   8001bb <cprintf>
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb ad                	jmp    801654 <_pipeisclosed+0xe>
	}
}
  8016a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ad:	5b                   	pop    %ebx
  8016ae:	5e                   	pop    %esi
  8016af:	5f                   	pop    %edi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	57                   	push   %edi
  8016b6:	56                   	push   %esi
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 28             	sub    $0x28,%esp
  8016bb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016be:	56                   	push   %esi
  8016bf:	e8 0f f7 ff ff       	call   800dd3 <fd2data>
  8016c4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8016ce:	eb 4b                	jmp    80171b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016d0:	89 da                	mov    %ebx,%edx
  8016d2:	89 f0                	mov    %esi,%eax
  8016d4:	e8 6d ff ff ff       	call   801646 <_pipeisclosed>
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	75 48                	jne    801725 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016dd:	e8 42 f4 ff ff       	call   800b24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e5:	8b 0b                	mov    (%ebx),%ecx
  8016e7:	8d 51 20             	lea    0x20(%ecx),%edx
  8016ea:	39 d0                	cmp    %edx,%eax
  8016ec:	73 e2                	jae    8016d0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016f5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	c1 fa 1f             	sar    $0x1f,%edx
  8016fd:	89 d1                	mov    %edx,%ecx
  8016ff:	c1 e9 1b             	shr    $0x1b,%ecx
  801702:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801705:	83 e2 1f             	and    $0x1f,%edx
  801708:	29 ca                	sub    %ecx,%edx
  80170a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80170e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801712:	83 c0 01             	add    $0x1,%eax
  801715:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801718:	83 c7 01             	add    $0x1,%edi
  80171b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80171e:	75 c2                	jne    8016e2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801720:	8b 45 10             	mov    0x10(%ebp),%eax
  801723:	eb 05                	jmp    80172a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80172a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5f                   	pop    %edi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	57                   	push   %edi
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	83 ec 18             	sub    $0x18,%esp
  80173b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80173e:	57                   	push   %edi
  80173f:	e8 8f f6 ff ff       	call   800dd3 <fd2data>
  801744:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174e:	eb 3d                	jmp    80178d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801750:	85 db                	test   %ebx,%ebx
  801752:	74 04                	je     801758 <devpipe_read+0x26>
				return i;
  801754:	89 d8                	mov    %ebx,%eax
  801756:	eb 44                	jmp    80179c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801758:	89 f2                	mov    %esi,%edx
  80175a:	89 f8                	mov    %edi,%eax
  80175c:	e8 e5 fe ff ff       	call   801646 <_pipeisclosed>
  801761:	85 c0                	test   %eax,%eax
  801763:	75 32                	jne    801797 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801765:	e8 ba f3 ff ff       	call   800b24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80176a:	8b 06                	mov    (%esi),%eax
  80176c:	3b 46 04             	cmp    0x4(%esi),%eax
  80176f:	74 df                	je     801750 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801771:	99                   	cltd   
  801772:	c1 ea 1b             	shr    $0x1b,%edx
  801775:	01 d0                	add    %edx,%eax
  801777:	83 e0 1f             	and    $0x1f,%eax
  80177a:	29 d0                	sub    %edx,%eax
  80177c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801784:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801787:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178a:	83 c3 01             	add    $0x1,%ebx
  80178d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801790:	75 d8                	jne    80176a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801792:	8b 45 10             	mov    0x10(%ebp),%eax
  801795:	eb 05                	jmp    80179c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80179c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5f                   	pop    %edi
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	e8 35 f6 ff ff       	call   800dea <fd_alloc>
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	0f 88 2c 01 00 00    	js     8018ee <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	68 07 04 00 00       	push   $0x407
  8017ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 6f f3 ff ff       	call   800b43 <sys_page_alloc>
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	0f 88 0d 01 00 00    	js     8018ee <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017e1:	83 ec 0c             	sub    $0xc,%esp
  8017e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e7:	50                   	push   %eax
  8017e8:	e8 fd f5 ff ff       	call   800dea <fd_alloc>
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	0f 88 e2 00 00 00    	js     8018dc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	68 07 04 00 00       	push   $0x407
  801802:	ff 75 f0             	pushl  -0x10(%ebp)
  801805:	6a 00                	push   $0x0
  801807:	e8 37 f3 ff ff       	call   800b43 <sys_page_alloc>
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	85 c0                	test   %eax,%eax
  801813:	0f 88 c3 00 00 00    	js     8018dc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	ff 75 f4             	pushl  -0xc(%ebp)
  80181f:	e8 af f5 ff ff       	call   800dd3 <fd2data>
  801824:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801826:	83 c4 0c             	add    $0xc,%esp
  801829:	68 07 04 00 00       	push   $0x407
  80182e:	50                   	push   %eax
  80182f:	6a 00                	push   $0x0
  801831:	e8 0d f3 ff ff       	call   800b43 <sys_page_alloc>
  801836:	89 c3                	mov    %eax,%ebx
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	0f 88 89 00 00 00    	js     8018cc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801843:	83 ec 0c             	sub    $0xc,%esp
  801846:	ff 75 f0             	pushl  -0x10(%ebp)
  801849:	e8 85 f5 ff ff       	call   800dd3 <fd2data>
  80184e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801855:	50                   	push   %eax
  801856:	6a 00                	push   $0x0
  801858:	56                   	push   %esi
  801859:	6a 00                	push   $0x0
  80185b:	e8 26 f3 ff ff       	call   800b86 <sys_page_map>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	83 c4 20             	add    $0x20,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	78 55                	js     8018be <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801869:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801872:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801874:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801877:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80187e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801887:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801889:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	ff 75 f4             	pushl  -0xc(%ebp)
  801899:	e8 25 f5 ff ff       	call   800dc3 <fd2num>
  80189e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018a3:	83 c4 04             	add    $0x4,%esp
  8018a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a9:	e8 15 f5 ff ff       	call   800dc3 <fd2num>
  8018ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bc:	eb 30                	jmp    8018ee <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	56                   	push   %esi
  8018c2:	6a 00                	push   $0x0
  8018c4:	e8 ff f2 ff ff       	call   800bc8 <sys_page_unmap>
  8018c9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d2:	6a 00                	push   $0x0
  8018d4:	e8 ef f2 ff ff       	call   800bc8 <sys_page_unmap>
  8018d9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 df f2 ff ff       	call   800bc8 <sys_page_unmap>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018ee:	89 d0                	mov    %edx,%eax
  8018f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f3:	5b                   	pop    %ebx
  8018f4:	5e                   	pop    %esi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	ff 75 08             	pushl  0x8(%ebp)
  801904:	e8 30 f5 ff ff       	call   800e39 <fd_lookup>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 18                	js     801928 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	ff 75 f4             	pushl  -0xc(%ebp)
  801916:	e8 b8 f4 ff ff       	call   800dd3 <fd2data>
	return _pipeisclosed(fd, p);
  80191b:	89 c2                	mov    %eax,%edx
  80191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801920:	e8 21 fd ff ff       	call   801646 <_pipeisclosed>
  801925:	83 c4 10             	add    $0x10,%esp
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80193a:	68 1a 23 80 00       	push   $0x80231a
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	e8 f9 ed ff ff       	call   800740 <strcpy>
	return 0;
}
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80195a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80195f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801965:	eb 2d                	jmp    801994 <devcons_write+0x46>
		m = n - tot;
  801967:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80196a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80196c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80196f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801974:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	53                   	push   %ebx
  80197b:	03 45 0c             	add    0xc(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	57                   	push   %edi
  801980:	e8 4d ef ff ff       	call   8008d2 <memmove>
		sys_cputs(buf, m);
  801985:	83 c4 08             	add    $0x8,%esp
  801988:	53                   	push   %ebx
  801989:	57                   	push   %edi
  80198a:	e8 f8 f0 ff ff       	call   800a87 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80198f:	01 de                	add    %ebx,%esi
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	89 f0                	mov    %esi,%eax
  801996:	3b 75 10             	cmp    0x10(%ebp),%esi
  801999:	72 cc                	jb     801967 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80199b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5f                   	pop    %edi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019b2:	74 2a                	je     8019de <devcons_read+0x3b>
  8019b4:	eb 05                	jmp    8019bb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019b6:	e8 69 f1 ff ff       	call   800b24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019bb:	e8 e5 f0 ff ff       	call   800aa5 <sys_cgetc>
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	74 f2                	je     8019b6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 16                	js     8019de <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019c8:	83 f8 04             	cmp    $0x4,%eax
  8019cb:	74 0c                	je     8019d9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d0:	88 02                	mov    %al,(%edx)
	return 1;
  8019d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d7:	eb 05                	jmp    8019de <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019ec:	6a 01                	push   $0x1
  8019ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	e8 90 f0 ff ff       	call   800a87 <sys_cputs>
}
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <getchar>:

int
getchar(void)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a02:	6a 01                	push   $0x1
  801a04:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a07:	50                   	push   %eax
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 90 f6 ff ff       	call   80109f <read>
	if (r < 0)
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 0f                	js     801a25 <getchar+0x29>
		return r;
	if (r < 1)
  801a16:	85 c0                	test   %eax,%eax
  801a18:	7e 06                	jle    801a20 <getchar+0x24>
		return -E_EOF;
	return c;
  801a1a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a1e:	eb 05                	jmp    801a25 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a20:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	ff 75 08             	pushl  0x8(%ebp)
  801a34:	e8 00 f4 ff ff       	call   800e39 <fd_lookup>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 11                	js     801a51 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a43:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a49:	39 10                	cmp    %edx,(%eax)
  801a4b:	0f 94 c0             	sete   %al
  801a4e:	0f b6 c0             	movzbl %al,%eax
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <opencons>:

int
opencons(void)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5c:	50                   	push   %eax
  801a5d:	e8 88 f3 ff ff       	call   800dea <fd_alloc>
  801a62:	83 c4 10             	add    $0x10,%esp
		return r;
  801a65:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 3e                	js     801aa9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a6b:	83 ec 04             	sub    $0x4,%esp
  801a6e:	68 07 04 00 00       	push   $0x407
  801a73:	ff 75 f4             	pushl  -0xc(%ebp)
  801a76:	6a 00                	push   $0x0
  801a78:	e8 c6 f0 ff ff       	call   800b43 <sys_page_alloc>
  801a7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a80:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 23                	js     801aa9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	50                   	push   %eax
  801a9f:	e8 1f f3 ff ff       	call   800dc3 <fd2num>
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	83 c4 10             	add    $0x10,%esp
}
  801aa9:	89 d0                	mov    %edx,%eax
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ab2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801abb:	e8 45 f0 ff ff       	call   800b05 <sys_getenvid>
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	ff 75 0c             	pushl  0xc(%ebp)
  801ac6:	ff 75 08             	pushl  0x8(%ebp)
  801ac9:	56                   	push   %esi
  801aca:	50                   	push   %eax
  801acb:	68 28 23 80 00       	push   $0x802328
  801ad0:	e8 e6 e6 ff ff       	call   8001bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ad5:	83 c4 18             	add    $0x18,%esp
  801ad8:	53                   	push   %ebx
  801ad9:	ff 75 10             	pushl  0x10(%ebp)
  801adc:	e8 89 e6 ff ff       	call   80016a <vcprintf>
	cprintf("\n");
  801ae1:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  801ae8:	e8 ce e6 ff ff       	call   8001bb <cprintf>
  801aed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801af0:	cc                   	int3   
  801af1:	eb fd                	jmp    801af0 <_panic+0x43>

00801af3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	8b 75 08             	mov    0x8(%ebp),%esi
  801afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b01:	85 c0                	test   %eax,%eax
  801b03:	75 12                	jne    801b17 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	68 00 00 c0 ee       	push   $0xeec00000
  801b0d:	e8 e1 f1 ff ff       	call   800cf3 <sys_ipc_recv>
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	eb 0c                	jmp    801b23 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	50                   	push   %eax
  801b1b:	e8 d3 f1 ff ff       	call   800cf3 <sys_ipc_recv>
  801b20:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b23:	85 f6                	test   %esi,%esi
  801b25:	0f 95 c1             	setne  %cl
  801b28:	85 db                	test   %ebx,%ebx
  801b2a:	0f 95 c2             	setne  %dl
  801b2d:	84 d1                	test   %dl,%cl
  801b2f:	74 09                	je     801b3a <ipc_recv+0x47>
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	c1 ea 1f             	shr    $0x1f,%edx
  801b36:	84 d2                	test   %dl,%dl
  801b38:	75 24                	jne    801b5e <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b3a:	85 f6                	test   %esi,%esi
  801b3c:	74 0a                	je     801b48 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b43:	8b 40 74             	mov    0x74(%eax),%eax
  801b46:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b48:	85 db                	test   %ebx,%ebx
  801b4a:	74 0a                	je     801b56 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801b4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b51:	8b 40 78             	mov    0x78(%eax),%eax
  801b54:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b56:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	57                   	push   %edi
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b77:	85 db                	test   %ebx,%ebx
  801b79:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b7e:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b81:	ff 75 14             	pushl  0x14(%ebp)
  801b84:	53                   	push   %ebx
  801b85:	56                   	push   %esi
  801b86:	57                   	push   %edi
  801b87:	e8 44 f1 ff ff       	call   800cd0 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	c1 ea 1f             	shr    $0x1f,%edx
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	84 d2                	test   %dl,%dl
  801b96:	74 17                	je     801baf <ipc_send+0x4a>
  801b98:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b9b:	74 12                	je     801baf <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b9d:	50                   	push   %eax
  801b9e:	68 4c 23 80 00       	push   $0x80234c
  801ba3:	6a 47                	push   $0x47
  801ba5:	68 5a 23 80 00       	push   $0x80235a
  801baa:	e8 fe fe ff ff       	call   801aad <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801baf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb2:	75 07                	jne    801bbb <ipc_send+0x56>
			sys_yield();
  801bb4:	e8 6b ef ff ff       	call   800b24 <sys_yield>
  801bb9:	eb c6                	jmp    801b81 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	75 c2                	jne    801b81 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc2:	5b                   	pop    %ebx
  801bc3:	5e                   	pop    %esi
  801bc4:	5f                   	pop    %edi
  801bc5:	5d                   	pop    %ebp
  801bc6:	c3                   	ret    

00801bc7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bd5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bdb:	8b 52 50             	mov    0x50(%edx),%edx
  801bde:	39 ca                	cmp    %ecx,%edx
  801be0:	75 0d                	jne    801bef <ipc_find_env+0x28>
			return envs[i].env_id;
  801be2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801be5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bea:	8b 40 48             	mov    0x48(%eax),%eax
  801bed:	eb 0f                	jmp    801bfe <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bef:	83 c0 01             	add    $0x1,%eax
  801bf2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf7:	75 d9                	jne    801bd2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c06:	89 d0                	mov    %edx,%eax
  801c08:	c1 e8 16             	shr    $0x16,%eax
  801c0b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c12:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c17:	f6 c1 01             	test   $0x1,%cl
  801c1a:	74 1d                	je     801c39 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c1c:	c1 ea 0c             	shr    $0xc,%edx
  801c1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c26:	f6 c2 01             	test   $0x1,%dl
  801c29:	74 0e                	je     801c39 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c2b:	c1 ea 0c             	shr    $0xc,%edx
  801c2e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c35:	ef 
  801c36:	0f b7 c0             	movzwl %ax,%eax
}
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    
  801c3b:	66 90                	xchg   %ax,%ax
  801c3d:	66 90                	xchg   %ax,%ax
  801c3f:	90                   	nop

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 f6                	test   %esi,%esi
  801c59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5d:	89 ca                	mov    %ecx,%edx
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	75 3d                	jne    801ca0 <__udivdi3+0x60>
  801c63:	39 cf                	cmp    %ecx,%edi
  801c65:	0f 87 c5 00 00 00    	ja     801d30 <__udivdi3+0xf0>
  801c6b:	85 ff                	test   %edi,%edi
  801c6d:	89 fd                	mov    %edi,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f7                	div    %edi
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 c8                	mov    %ecx,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c1                	mov    %eax,%ecx
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	89 cf                	mov    %ecx,%edi
  801c88:	f7 f5                	div    %ebp
  801c8a:	89 c3                	mov    %eax,%ebx
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
  801ca0:	39 ce                	cmp    %ecx,%esi
  801ca2:	77 74                	ja     801d18 <__udivdi3+0xd8>
  801ca4:	0f bd fe             	bsr    %esi,%edi
  801ca7:	83 f7 1f             	xor    $0x1f,%edi
  801caa:	0f 84 98 00 00 00    	je     801d48 <__udivdi3+0x108>
  801cb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	89 c5                	mov    %eax,%ebp
  801cb9:	29 fb                	sub    %edi,%ebx
  801cbb:	d3 e6                	shl    %cl,%esi
  801cbd:	89 d9                	mov    %ebx,%ecx
  801cbf:	d3 ed                	shr    %cl,%ebp
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	09 ee                	or     %ebp,%esi
  801cc7:	89 d9                	mov    %ebx,%ecx
  801cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccd:	89 d5                	mov    %edx,%ebp
  801ccf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cd3:	d3 ed                	shr    %cl,%ebp
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e2                	shl    %cl,%edx
  801cd9:	89 d9                	mov    %ebx,%ecx
  801cdb:	d3 e8                	shr    %cl,%eax
  801cdd:	09 c2                	or     %eax,%edx
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	89 ea                	mov    %ebp,%edx
  801ce3:	f7 f6                	div    %esi
  801ce5:	89 d5                	mov    %edx,%ebp
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	f7 64 24 0c          	mull   0xc(%esp)
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	72 10                	jb     801d01 <__udivdi3+0xc1>
  801cf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e6                	shl    %cl,%esi
  801cf9:	39 c6                	cmp    %eax,%esi
  801cfb:	73 07                	jae    801d04 <__udivdi3+0xc4>
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	75 03                	jne    801d04 <__udivdi3+0xc4>
  801d01:	83 eb 01             	sub    $0x1,%ebx
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 d8                	mov    %ebx,%eax
  801d08:	89 fa                	mov    %edi,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	31 ff                	xor    %edi,%edi
  801d1a:	31 db                	xor    %ebx,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	f7 f7                	div    %edi
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 1c             	add    $0x1c,%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	39 ce                	cmp    %ecx,%esi
  801d4a:	72 0c                	jb     801d58 <__udivdi3+0x118>
  801d4c:	31 db                	xor    %ebx,%ebx
  801d4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d52:	0f 87 34 ff ff ff    	ja     801c8c <__udivdi3+0x4c>
  801d58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d5d:	e9 2a ff ff ff       	jmp    801c8c <__udivdi3+0x4c>
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 d2                	test   %edx,%edx
  801d89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d91:	89 f3                	mov    %esi,%ebx
  801d93:	89 3c 24             	mov    %edi,(%esp)
  801d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9a:	75 1c                	jne    801db8 <__umoddi3+0x48>
  801d9c:	39 f7                	cmp    %esi,%edi
  801d9e:	76 50                	jbe    801df0 <__umoddi3+0x80>
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	f7 f7                	div    %edi
  801da6:	89 d0                	mov    %edx,%eax
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	77 52                	ja     801e10 <__umoddi3+0xa0>
  801dbe:	0f bd ea             	bsr    %edx,%ebp
  801dc1:	83 f5 1f             	xor    $0x1f,%ebp
  801dc4:	75 5a                	jne    801e20 <__umoddi3+0xb0>
  801dc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	39 0c 24             	cmp    %ecx,(%esp)
  801dd3:	0f 86 d7 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ddd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	85 ff                	test   %edi,%edi
  801df2:	89 fd                	mov    %edi,%ebp
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 c8                	mov    %ecx,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	eb 99                	jmp    801da8 <__umoddi3+0x38>
  801e0f:	90                   	nop
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	83 c4 1c             	add    $0x1c,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5f                   	pop    %edi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	8b 34 24             	mov    (%esp),%esi
  801e23:	bf 20 00 00 00       	mov    $0x20,%edi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	29 ef                	sub    %ebp,%edi
  801e2c:	d3 e0                	shl    %cl,%eax
  801e2e:	89 f9                	mov    %edi,%ecx
  801e30:	89 f2                	mov    %esi,%edx
  801e32:	d3 ea                	shr    %cl,%edx
  801e34:	89 e9                	mov    %ebp,%ecx
  801e36:	09 c2                	or     %eax,%edx
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	89 14 24             	mov    %edx,(%esp)
  801e3d:	89 f2                	mov    %esi,%edx
  801e3f:	d3 e2                	shl    %cl,%edx
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	89 c6                	mov    %eax,%esi
  801e51:	d3 e3                	shl    %cl,%ebx
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 d0                	mov    %edx,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	09 d8                	or     %ebx,%eax
  801e5d:	89 d3                	mov    %edx,%ebx
  801e5f:	89 f2                	mov    %esi,%edx
  801e61:	f7 34 24             	divl   (%esp)
  801e64:	89 d6                	mov    %edx,%esi
  801e66:	d3 e3                	shl    %cl,%ebx
  801e68:	f7 64 24 04          	mull   0x4(%esp)
  801e6c:	39 d6                	cmp    %edx,%esi
  801e6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e72:	89 d1                	mov    %edx,%ecx
  801e74:	89 c3                	mov    %eax,%ebx
  801e76:	72 08                	jb     801e80 <__umoddi3+0x110>
  801e78:	75 11                	jne    801e8b <__umoddi3+0x11b>
  801e7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e7e:	73 0b                	jae    801e8b <__umoddi3+0x11b>
  801e80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e84:	1b 14 24             	sbb    (%esp),%edx
  801e87:	89 d1                	mov    %edx,%ecx
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e8f:	29 da                	sub    %ebx,%edx
  801e91:	19 ce                	sbb    %ecx,%esi
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e0                	shl    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	d3 ee                	shr    %cl,%esi
  801ea1:	09 d0                	or     %edx,%eax
  801ea3:	89 f2                	mov    %esi,%edx
  801ea5:	83 c4 1c             	add    $0x1c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 f9                	sub    %edi,%ecx
  801eb2:	19 d6                	sbb    %edx,%esi
  801eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebc:	e9 18 ff ff ff       	jmp    801dd9 <__umoddi3+0x69>
